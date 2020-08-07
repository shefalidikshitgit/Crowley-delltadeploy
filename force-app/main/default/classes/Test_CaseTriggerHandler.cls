@isTest
public class Test_CaseTriggerHandler {
    public static List<Entitlement> createEntitlement(String strEntitlementName, Id idAccount, Integer intNumOfEntitlements){
        List<Entitlement> entitlements = new List<Entitlement>();
        for(Integer intIndex = 0; intIndex < intNumOfEntitlements; intIndex++) {
            Entitlement entObj = new Entitlement();
            entObj.AccountId = idAccount;
            entObj.Name = strEntitlementName;
            entitlements.add(entObj);
        }       
        insert entitlements;
        return entitlements;
    }

    @testSetup
    static void setUp(){
        
    }
    
    static testMethod void test_updateEntitlement(){
        List<Account> accounts = TestDataUtility.createAccount('ABC Company', 'IT', null, false, 1);    
        List<Entitlement> entitlements = createEntitlement('BL Revision',accounts[0].Id, 1);
        //System.Label.BL_Revision_Entitlements = entitlements[0].Id;
        RecordType rt = [Select Id, Name From RecordType Where Name='Create BL Revision' Limit 1];
        List<Case> cases = TestDataUtility.createCase(rt.Id, accounts[0].Id, null, null, null, null, 'Web', UserInfo.getUserId(), 'Open', 1);
        List<Case> entitledCases = [Select Id, Entitlement.Name, RecordType.Name From Case Where Id=:cases[0].Id];
    }
    
    static testMethod void test_parentCaseClosed(){
        List<Account> accs = TestDataUtility.createAccount('ABC Company', 'IT', null, false, 1);    
        //List<Entitlement> entitlements = createEntitlement('Tier 1 Entitlement',accounts[0].Id, 1);
        RecordType rt = [Select Id, Name From RecordType Where Name='Create BL Revision' Limit 1];
        Case parentCase = TestDataUtility.createBLRevisionCase(accs[0].Id, null, null, 'Subject', 'Test Data', 'Web', UserInfo.getUserId(), 'Open', 1)[0];
        parentCase.Subject = 'I am Parent';
        parentCase.OwnerId = UserInfo.getUserId();
        update parentCase;
        
        CaseTriggerHandler.reset();
        
        Case childCase = TestDataUtility.createPricingRateIssueCase(accs[0].Id, null, parentCase.Id, 'Subject2', 'Test Data', 'Web', UserInfo.getUserId(), 'Open', 1)[0];
        childCase.Subject = 'I am Child';
        childCase.OwnerId = UserInfo.getUserId();
        update childCase;
        
        CaseTriggerHandler.reset();
        
        Test.startTest();
        try{
            parentCase.Status = 'Closed Resolved';
            update parentCase;
        }catch(Exception ex){
            System.debug('exception -> '+ex.getMessage());
            System.assert(ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
        }
        System.debug('parentCase -> '+[Select Id, Status From Case Where Id=:parentCase.Id]);
        Test.stopTest();
    }
    
    static testMethod void test_checkDuplicateCases(){
        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Create_Record').getRecordTypeId();
        List<Account> accs = TestDataUtility.createAccount('Test Account 1', 'E-commerce', null, false, 1);
        Address__c businessLocationObj = TestDataUtility.createBusinessLocation(accs, 'BL11', 'City11', 
                                                                                'NY', '1134111', '86788888888', 
                                                                                'US', 1)[0];
        Contact con1 = TestDataUtility.createContact(recordTypeId, accs[0].Id, new List<Address__c>{businessLocationObj}, null, 
                                                     'Test contact 1', 'contact@email.com', '9999888899', false, 
                                                     UserInfo.getUserId(), 1)[0];        
        
        RecordType rt = [Select Id, Name From RecordType Where Name='Create BL Revision' Limit 1];
        Case cs1 = TestDataUtility.createCase(rt.Id, accs[0].Id, con1.Id, null, 'Subject', 'Test 1', 'Web', UserInfo.getUserId(), 'Open', 1)[0];
        Test.startTest();
        CaseTriggerHandler.reset();
        try{
            Case cs2 = TestDataUtility.createCase(rt.Id, accs[0].Id, con1.Id, null, 'Subject', 'Test 2', 'Web', UserInfo.getUserId(), 'Open', 1)[0];
        }catch(Exception ex){
            System.assert(ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
        }
        try{
            Case cs2 = TestDataUtility.createCase(rt.Id, accs[0].Id, con1.Id, null, 'Subject', 'Test 2', 'Web', System.Label.Email_to_Case_User, 'Open', 1)[0];
        }catch(Exception ex){
            System.assert(ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
        }
        
        
        Test.stopTest();
    }
    
    static testMethod void test_updateChildFieldsFromParent(){
        List<Account> accs = TestDataUtility.createAccount('Test Account 1', 'E-commerce', null, false, 1);
        Address__c businessLocationObj = TestDataUtility.createBusinessLocation(accs, 'BL11', 'City11', 
                                                                                'NY', '1134111', '86788888888', 
                                                                                'US', 1)[0];
        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Create_Record').getRecordTypeId();
        Contact con1 = TestDataUtility.createContact(recordTypeId, accs[0].Id, new List<Address__c>{businessLocationObj}, null, 
                                                     'Test contact 1', 'contact@email.com', '9999888899', false, 
                                                     UserInfo.getUserId(), 1)[0];        
        
        RecordType rt = [Select Id, Name From RecordType Where Name='Create BL Revision' Limit 1];
        
        Map<string, Schema.SObjectField> caseFieldMap = Case.SObjectType.getDescribe().fields.getMap();
        
        Case parentCase = TestDataUtility.createCase(rt.Id, accs[0].Id, con1.Id, null, 'Subject', null, 'Web', UserInfo.getUserId(), 'Open', 1)[0];
        parentCase = [Select id,Consignee_Name__c,Equipment_Type_Size__c,Contract_Number__c,Shipper_Name__c,Assignee_Pricing_Location__c,RecordTypeId,ContactId,Priority,BOL_Number__c,Voyage__c,Origin,Booking__c,Bill_to_Party__c,Move_Type__c
                     	From Case Where Id=:parentCase.Id];
        Map<string, Schema.SobjectField> caseFdMap = Case.getSobjectType().getDescribe().fields.getMap();
        Case cs1 = new Case();
        cs1.Id = parentCase.Id;
        cs1.Consignee_Name__c = accs[0].Id;
        cs1.ContactId=parentCase.ContactId;
        cs1.Origin=parentCase.Origin;
        cs1.Bill_to_Party__c= accs[0].Id;
        cs1.Move_Type__c = caseFdMap.get('move_type__c').getDescribe().getPicklistValues()[0].getValue();
        cs1.Assignee_Pricing_Location__c = caseFdMap.get('assignee_pricing_location__c').getDescribe().getPicklistValues()[0].getValue();
        cs1.Priority=caseFdMap.get('priority').getDescribe().getPicklistValues()[0].getValue();
        cs1.Booking__c='123456789123';
        cs1.BOL_Number__c='123409871234';
        cs1.Voyage__c='12345678';
        cs1.Shipper_Name__c=accs[0].Id;
        cs1.Consignee_Name__c=accs[0].Id;
        cs1.Equipment_Type_Size__c=caseFdMap.get('equipment_type_size__c').getDescribe().getPicklistValues()[0].getValue();
        cs1.Contract_Number__c='12345678';
        
        cs1.Type = caseFieldMap.get('type').getDescribe().getPicklistValues()[0].getValue();
		update cs1;
        cs1 = [Select RecordType.Name, Subject, Description From Case Where Id=:cs1.Id];
   
        Test.startTest();
        try{
            CaseTriggerHandler.reset();
            Case cs2 = TestDataUtility.createCase(rt.Id, accs[0].Id, con1.Id, cs1.Id, 'Subject2', null, 'Web', UserInfo.getUserId(), 'Open', 1)[0];
            cs1.RecordTypeId = System.Label.B_L_Revision_record_type;
            update cs1;
            CaseTriggerHandler.reset();
            Case cs3 = TestDataUtility.createCase(System.Label.B_L_Revision_record_type, accs[0].Id, con1.Id, cs1.Id, 'Subject3', null, 'Web', UserInfo.getUserId(), 'Open', 1)[0];
            
        }catch(Exception ex){
            //System.assert(ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION, Case already exists with same subject.'));
        }
        
        Test.stopTest();
    }
    
    static testMethod void test_updateParentCaseStatus_PricingRateIssueRT(){
        List<Account> accs = TestDataUtility.createAccount('Test Account 1', 'E-commerce', null, false, 1);
        RecordType rt = [Select Id, Name From RecordType Where Name='Create BL Revision' Limit 1];
        Case parentCase = TestDataUtility.createBLRevisionCase(accs[0].Id, null, null, 'Subject', 'Test Data', 'Web', UserInfo.getUserId(), 'Open', 1)[0];
        Test.startTest();
        
        CaseTriggerHandler.reset();
        Case childCase = TestDataUtility.createPricingRateIssueCase(accs[0].Id, null, parentCase.Id, 'Subject2', 'Test Data', 'Web', UserInfo.getUserId(), 'Open', 1)[0];
        
        Case pcs = [Select Id, Status, Subject From Case Where Id=:parentCase.Id];
        System.assert(pcs.Status == 'Awaiting more information');
        
        CaseTriggerHandler.reset();
        childCase.Status = 'Closed - Rate Not Feasible';
        update childCase;
        
        pcs = [Select Id, Status, Subject From Case Where Id=:parentCase.Id];
        System.assert(pcs.Status == 'Ready for Review');
        
        Test.stopTest();
    }
    
    static void assignPermissionSet(List<Id> userIds, String permissionSetName){
        Set<Id> permSetAssignees = new Set<Id>();
        Id permSetId = [Select Id, Name From PermissionSet Where Name=:permissionSetName Limit 1].Id;
        for(PermissionSetAssignment pas: [Select Id, AssigneeId, PermissionSetId, PermissionSet.Name From PermissionSetAssignment Where PermissionSetId=:permSetId]){
            permSetAssignees.add(pas.AssigneeId);
        }
        
        List<PermissionSetAssignment> permAssignments = new List<PermissionSetAssignment>();
        for(Id userId: userIds){
            if(!permSetAssignees.contains(userId)){
                permAssignments.add(new PermissionSetAssignment(AssigneeId=userId, PermissionSetId=permSetId));    
            }
        }
        insert permAssignments;
    }
    static List<User> getUsers(string profileName, integer numberOfUsers){
        
        Profile Profile1 = [SELECT Id, Name FROM Profile WHERE Name = :profileName];
        List<User> users = new List<User>();
        for(integer i=0; i<numberOfUsers; i++){
            users.add(new User(alias = ('sucrow'+i), email='test123@noemail.com',
                              emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                              localesidkey='en_US', profileid = Profile1.id, country='United States',IsActive =true,
                              timezonesidkey='America/Los_Angeles', username=('sampleuser180520'+i+'@crowley.com')));
        }
        insert users;
       
        List<Id> userIds = new List<Id>();
        for(User u: users){
            userIds.add(u.Id);
        }
        return users;
    }
    static testMethod void test_setParentAccount(){
        
        assignPermissionSet(new List<Id>{UserInfo.getUserId()}, 'Allow_to_Update_Parent_Account');
        User u = [Select Id From User Where Id=:UserInfo.getUserId()];
        System.runAs(u){
            List<Account> accounts = TestDataUtility.createAccounts('Test Account', 'E-commerce', null, false, 3);
            Account parentAcc = accounts[0];
            Account parentAcc2 = accounts[1];
            
            AccountTriggerHandler.clearRecursionVar();
            Account childAcc = accounts[2];
            childAcc.ParentId = parentAcc.Id;
            update childAcc;
            
            RecordType rt = [Select Id, Name From RecordType Where Name='Create BL Revision' Limit 1];
            
            // If case is being created with an account that has a parent account 
            Case cs = TestDataUtility.createBLRevisionCase(childAcc.Id, null, null, 'Subject', 'Test Data', 'Web', UserInfo.getUserId(), 'Open', 1)[0];
            CaseTriggerHandler.reset();
            
            AccountTriggerHandler.clearRecursionVar();
            // account is replaced with an account that has a parent account
            cs.AccountId = parentAcc2.Id;
            update cs;
            
            System.assert([Select Id, Parent_Account__c From Case Where Id=:cs.Id Limit 1].Parent_Account__c!=parentAcc2.Id);
            CaseTriggerHandler.reset();
            
            // account is cleared
            cs.AccountId = null;
            update cs;
            System.assert([Select Id, Parent_Account__c From Case Where Id=:cs.Id Limit 1].Parent_Account__c==null);
            CaseTriggerHandler.reset();
            
            Test.startTest();
            AccountTriggerHandler.clearRecursionVar();
            childAcc.ParentId = parentAcc.Id;
            update childAcc;
            
            AccountTriggerHandler.clearRecursionVar();
            
            Address__c businessLocationObj = TestDataUtility.createBusinessLocation(new List<Account>{childAcc}, 'BL11', 'City11', 
                                                                                    'NY', '1134111', '86788888888', 
                                                                                    'US', 1)[0];
            Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Create_Record').getRecordTypeId();
            Contact con1 = TestDataUtility.createContact(recordTypeId, childAcc.Id, new List<Address__c>{businessLocationObj}, null, 
                                                         'Test contact 1', 'contact@email.com', '9999888899', false, 
                                                         UserInfo.getUserId(), 1)[0];    
            Case cs2 = TestDataUtility.createBLRevisionCase(null, con1.Id, null, 'Subject', 'Test Data', 'Web', UserInfo.getUserId(), 'Open', 1)[0];
            System.assert([Select Id, Parent_Account__c From Case Where Id=:cs2.Id Limit 1].Parent_Account__c!=null);
            Test.stopTest();
        }
        
    }

	static testMethod void test_setCaseParentAccountOnContactUpdate(){
        
        assignPermissionSet(new List<Id>{UserInfo.getUserId()}, 'Allow_to_Update_Parent_Account');
        User u = [Select Id From User Where Id=:UserInfo.getUserId()];
        System.runAs(u){
            Test.startTest();
            //creating account
            List<Account> accounts = TestDataUtility.createAccounts('Test Account', 'E-commerce', null, false, 2);
            AccountTriggerHandler.clearRecursionVar();
            
            // creating an account and setting a parent account to this account
            Account parentAcc = accounts[0];
            Account childAcc = accounts[1];
            childAcc.ParentId = parentAcc.Id;
            update childAcc;
            
            AccountTriggerHandler.clearRecursionVar();
            
            // creating contact
            Address__c businessLocationObj = TestDataUtility.createBusinessLocation(new List<Account>{childAcc}, 'BL11', 'City11', 
                                                                                    'NY', '1134111', '86788888888', 
                                                                                    'US', 1)[0];
            Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Create_Record').getRecordTypeId();
            Contact con1 = TestDataUtility.createContact(recordTypeId, childAcc.Id, new List<Address__c>{businessLocationObj}, null, 
                                                         'Test contact 1', 'contact@email.com', '9999888899', false, 
                                                         UserInfo.getUserId(), 1)[0];    
            
            //creating case without account Id but contact Id
            Case cs2 = TestDataUtility.createBLRevisionCase(null, null, null, 'Subject', 'Test Data', 'Web', UserInfo.getUserId(), 'Open', 1)[0];
            CaseTriggerHandler.reset();
            
            cs2.ContactId = con1.Id;
            update cs2;
            //checking if the case Parent Account field gets auto set to contact account's parent account
            System.assert([Select Id, Parent_Account__c From Case Where Id=:cs2.Id Limit 1].Parent_Account__c!=null);
            
            Test.stopTest();
        }
    }
    
    static testMethod void test_parentAccountUpdatedonAccount(){
        
        assignPermissionSet(new List<Id>{UserInfo.getUserId()}, 'Allow_to_Update_Parent_Account');
        User u = [Select Id From User Where Id=:UserInfo.getUserId()];
        System.runAs(u){
            Test.startTest();
            //creating account
            List<Account> accounts = TestDataUtility.createAccounts('Test Account', 'E-commerce', null, false, 3);
            AccountTriggerHandler.clearRecursionVar();
            Account parentAcc = accounts[0];
            Account childAcc = accounts[1];
            Account parentAcc2 = accounts[2];
            
            childAcc.ParentId = parentAcc.Id;
            update childAcc;
            AccountTriggerHandler.clearRecursionVar();
            
            // If case is being created with an account that has a parent account 
            Case cs = TestDataUtility.createBLRevisionCase(childAcc.Id, null, null, 'Subject', 'Test Data', 'Web', UserInfo.getUserId(), 'Open', 1)[0];
            CaseTriggerHandler.reset();
            
            childAcc.ParentId = parentAcc2.Id;
            update childAcc;
            
            Test.stopTest();
            //checking if the case Parent Account field gets auto set to contact account's parent account
            System.assert([Select Id, Parent_Account__c From Case Where Id=:cs.Id Limit 1].Parent_Account__c==parentAcc2.Id);
        }
    }
    /*
    static testMethod void test_updateParentCaseStatus_PricingRateProposalRT(){
        List<Account> accs = TestDataUtility.createAccount('Test Account 1', 'E-commerce', null, false, 1);
        Id CreateBookingRequestRT;
        Id CreatePricingRateProposalRT;
        Id CreateBLRevisionRT;
        for(RecordType rt :[Select Id, Name From RecordType Where Name IN ('Create Booking Request','Create Pricing Rate Proposal','Create BL Revision')]){
            if(rt.Name == 'Create Booking Request')
                CreateBookingRequestRT = rt.Id;
            if(rt.Name == 'Create Pricing Rate Proposal')
                CreatePricingRateProposalRT = rt.Id;
            if(rt.Name == 'Create BL Revision')
                CreateBLRevisionRT = rt.Id;
        } 
        
        Case pcs1 = new Case();
        pcs1.AccountId = accs[0].Id;
        pcs1.Subject = 'Subject1';
        pcs1.Origin = 'Web';
        pcs1.OwnerId = UserInfo.getUserId();
        pcs1.Status = 'Open';
        pcs1.Load_Port__c = 'Anguilla, AI';
        pcs1.Final_Discharge_Port__c = 'Anguilla, AI';
        pcs1.Cargo_Available_Date__c = Date.today();
        pcs1.Freight_Type__c = 'Equipment';
        pcs1.Hazardous__c = 'Yes';
        pcs1.RecordTypeId = CreateBookingRequestRT;
        insert pcs1;
        
        Test.startTest();
        
        CaseTriggerHandler.reset();
        
        try{
        	Case childCase = TestDataUtility.createCase(CreatePricingRateProposalRT, accs[0].Id, null, pcs1.Id, 'Subject2', null, 'Web', UserInfo.getUserId(), 'Open', 1)[0];
        }catch(DMLException ex){
        	System.assert(ex.getMessage().contains('Please fill "Reason for requesting additional info" on Parent Case'));
        }
        
        Case tempCase = new Case();
        tempCase.Id = pcs1.Id;
        tempCase.Reason_for_requesting_additional_info__c = 'Awaiting Pricing Approval';
        update tempCase;
        
        CaseTriggerHandler.reset();
        
        Case childcs1 = new Case();
        childcs1.AccountId = accs[0].Id;
        childcs1.Origin = 'Web';
        childcs1.Type = 'Medium';
        childcs1.Subject = 'Subject2';
        childcs1.RecordTypeId = CreatePricingRateProposalRT;
        childcs1.ParentId = pcs1.Id;
        insert childcs1;
        
        CaseTriggerHandler.reset();
        
        Case pcs = [Select Id, Status, Subject From Case Where Id=:pcs1.Id];
        System.assert(pcs.Status == 'Awaiting more information');
        
        CaseTriggerHandler.reset();
        
        tempCase = new Case();
        tempCase.Id = childcs1.Id;
        tempCase.Status = 'Closed Resolved';
        update tempCase; 
        
        Case pcs2 = new Case();
        pcs2.AccountId = accs[0].Id;
        pcs2.Subject = 'Subject3';
        pcs2.Origin = 'Web';
        pcs2.OwnerId = UserInfo.getUserId();
        pcs2.Status = 'Open';
        pcs2.Load_Port__c = 'ANGUILLA';
        pcs2.Final_Discharge_Port__c = 'Anguilla, AI';
        pcs2.Cargo_Available_Date__c = Date.today();
        pcs2.Freight_Type__c = 'Equipment';
        pcs2.Hazardous__c = 'Yes';
        pcs2.RecordTypeId = CreateBLRevisionRT;
        insert pcs2;
        
        CaseTriggerHandler.reset();
        
        Case childcs2 = new Case();
        childcs2.AccountId = accs[0].Id;
        childcs2.Origin = 'Web';
        childcs2.Type = 'Medium';
        childcs2.Subject = 'Subject4';
        childcs2.RecordTypeId = CreatePricingRateProposalRT;
        childcs2.ParentId = pcs2.Id;
        insert childcs2;
        
        pcs2 = [Select Id, Status, Subject From Case Where Id=:pcs2.Id];
        
        System.debug('psc2 -> '+pcs2);
        System.assert(pcs2.Status == 'Quote Requested');
        
        Test.stopTest();
    }*/
    /*
    static testMethod void test_updateParentCaseStatus_CustomerInquiry(){
        Group q = [Select Id, Name, Type From Group Where Type='Queue' and Name='Customer Inquiry'];
        List<Account> accs = TestDataUtility.createAccount('ABC Company', 'IT', null, false, 1); 
		List<Address__c> addresses = [Select Id, Account__c From Address__c Where Account__c=:accs[0].Id];
        List<RecordType> contactRTs = [Select Id, Name, SobjectType From RecordType Where SobjectType='Contact' Limit 1];
        List<Contact> cts = TestDataUtility.createContact(contactRTs[0].Id, accs[0].Id, addresses, 'test', 'contact', 'test@yopmail.com', '9999888877', false, UserInfo.getUserId(), 1);
        
        Case parentCase = createCustomerInquiryCase(accs[0].Id, cts[0].Id, null, 'Subject1', 'Desc1', 'Web', q.Id, 'Open', 1)[0];
        CaseTriggerHandler.reset();
        Case childCase = TestDataUtility.createPricingRateIssueCase( accs[0].Id, cts[0].Id, parentCase.Id, 'Subject2', 'Desc2', 'Web', q.Id, 'Open', 1)[0];
        System.debug('customer inquiry flow if status awaiting information '+childCase);
        
        parentCase = [Select Id, Status, OwnerId From Case Where Id=: parentCase.Id];
        System.debug('parentCase -> '+parentCase);
        
        System.assert(parentCase.Status == 'Awaiting more information');
        
        CaseTriggerHandler.reset();
        
        Case closedChildCase = new Case();
        closedChildCase.Id = childCase.Id;
        closedChildCase.Status = 'Closed Resolved';
        //closedChildCase.Issue_Type__c = 'Pricing Issue';
        //closedChildCase.Resolution_Category__c = 'Contract Renewed';
        update closedChildCase;
        
        parentCase = [Select Id, RecordTypeId, Subject, Status From Case Where Id=:parentCase.Id];
        System.debug('customer inquiry flow if status Ready for Review -> '+parentCase);
        System.assert(parentCase.Status == 'Ready for Review');
    }
    */
    /*static testMethod void test_updateParentCaseStatus_BookingRequest(){
        List<Account> accounts = TestDataUtility.createAccount('ABC Company', 'IT', null, false, 1); 
        
        RecordType rt = [Select Id, Name From RecordType Where Name='Create Booking Request' Limit 1];
        Case case1 = TestDataUtility.createCase(rt.Id, accounts[0].Id, null, null, null, null, 'Web', UserInfo.getUserId(), 'Open', 1)[0];
        
        rt = [Select Id, Name From RecordType Where Name='Create Rate Proposal' Limit 1];
        Case case2 = TestDataUtility.createCase(rt.Id, accounts[0].Id, null, case1.Id, null, null, 'Web', UserInfo.getUserId(), 'Open', 1)[0];
    }*/
    
    /*static testMethod void test_updateChildCaseStatus(){
        Id Create_Existing_Customer_Rate_Request_RT = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Create Existing Customer Rate Request').getRecordTypeId();
    	Id Create_Pricing_Rate_Proposal_RT = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Create Pricing Rate Proposal').getRecordTypeId();
    	List<Account> accs = TestDataUtility.createAccount('Test Account 1', 'E-commerce', null, false, 1);
        
        Case pcs1 = new Case();
        pcs1.AccountId = accs[0].Id;
        pcs1.Subject = 'Subject1';
        pcs1.Origin = 'Web';
        pcs1.OwnerId = UserInfo.getUserId();
        pcs1.Status = 'Open';
        pcs1.Load_Port__c = 'ANGUILLA';
        pcs1.Final_Discharge_Port__c = 'Anguilla, AI';
        pcs1.Cargo_Available_Date__c = Date.today();
        pcs1.Freight_Type__c = 'Equipment';
        pcs1.Hazardous__c = 'Yes';
        pcs1.RecordTypeId = Create_Existing_Customer_Rate_Request_RT;
        pcs1.Request_Type__c = 'New Booking';
        insert pcs1;
        
        CaseTriggerHandler.reset();
        
        Case childcs1 = new Case();
        childcs1.AccountId = accs[0].Id;
        childcs1.Origin = 'Web';
        childcs1.Type = 'Medium';
        childcs1.Subject = 'Subject2';
        childcs1.RecordTypeId = Create_Pricing_Rate_Proposal_RT;
        childcs1.ParentId = pcs1.Id;
        insert childcs1;
        
        CaseTriggerHandler.reset();
        
        Case tempCs1 = new Case();
        tempCs1.Id = pcs1.Id;
        tempCs1.Feedback_Received__c = 'Partially Approved';
		update tempCs1;
    }*/
    
}