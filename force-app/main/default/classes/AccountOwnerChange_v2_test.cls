@isTest
public class AccountOwnerChange_v2_test {
    
    static testMethod void accountOwnerChangeTestMethod()
    {   
        //test
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1].Id;
        Id profileId2 = [SELECT Id FROM Profile WHERE Name = 'Sales Rep' Limit 1].Id;
        Id profileId3 = [SELECT Id FROM Profile WHERE Name = 'Sales Manager' Limit 1].Id;
        Account acc, acc2, acc3;
        
        User m1 = TestDataUtility.createUser(null, profileId, null, 'USA SYSTEM ADMIN', 'USASYSTEMADMIN@test.com', 
                                             'en_US', 'en_US', 'UTF-8', 'America/Los_Angeles', null);
        
        User u1 = TestDataUtility.createUser(null, profileId2, null, 'user1', 'approvalUser1@test.com', 
                                             'en_US', 'en_US', 'UTF-8', 'America/Los_Angeles', m1.Id);
        
        u1.Region__c = 'TRK - Trucking Team';
        update u1;
        
        User u2 = TestDataUtility.createUser(null, profileId3, null, 'User2', 'approvalUser2@test.com', 
        
                                             'en_US', 'en_US', 'UTF-8', 'America/Los_Angeles', m1.Id);
        
        u2.Region__c = 'USA - United States';
        update u2;
        
        User u3 = TestDataUtility.createUser(null, profileId3, null, 'User2', 'approvalUser2@test.com', 
        
                                             'en_US', 'en_US', 'UTF-8', 'America/Los_Angeles', m1.Id);
        
        u3.Region__c = 'PRT - Puerto Rico';
        update u3;
        
        System.runAs(m1) {
        
            DescribeFieldResult describe = Address__c.Country__c.getDescribe();
            List<PicklistEntry> availableValues = describe.getPicklistValues();
            DescribeFieldResult describeState = Address__c.State_Picklist__c.getDescribe();
            List<PicklistEntry> stateAvailableValues = describeState.getPicklistValues();
            Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Create_Record').getRecordTypeId();
            
            ProfilesHavingCheckboxAccess__c obj1 = new ProfilesHavingCheckboxAccess__c();
            obj1.Name = 'System Administrator';
            insert obj1;
            
            
            acc = TestDataUtility.createAccounts('Owner Change Test',  'Prospect', 'Apparel', null, false, 1)[0];
            
            List<User_Region_to_Opp_Role__c> customSettingList = [Select Id from User_Region_to_Opp_Role__c];
            delete customSettingList;
            
            acc2 = TestDataUtility.createAccounts('Account duplicate',  'Prospect', '', null, false, 1)[0];
            
            List<User_Region_to_Opp_Role__c> customSettingList2 = [Select Id from User_Region_to_Opp_Role__c];
            delete customSettingList2;
            
            acc2.Approval_Process_Action__c = ConstantClass.APPROVAL_PROCESS_ACTION_REJECTED;
            update acc2;
            
            acc3 = TestDataUtility.createAccounts('123 Test',  'Prospect', '', null, false, 1)[0];
            
            List<User_Region_to_Opp_Role__c> customSettingList3 = [Select Id from User_Region_to_Opp_Role__c];
            delete customSettingList3;
            
            acc3.Approval_Process_Action__c = ConstantClass.APPROVAL_PROCESS_ACTION_APPROVED;
            acc3.Keep_Account_Team__c = True;
            acc3.Keep_Opportunity_Team__c = True;
            //acc3.Proposed_Account_Owner__c = u3.Id;
            update acc3;
            
            List<Account> accListChild = TestDataUtility.createAccounts('Child Account', 'Prospect', 'Agriculture', acc.Id, false, 1);
            
            Address__c businessLocationObj2 = TestDataUtility.createBusinessLocation(new List<Account>{acc}, 'BL11', 'City11', 
                                                                                    stateAvailableValues[0].getValue(), '1134111', '86788888888', 
                                                                                    'US', 1)[0];
            Contact con2 = TestDataUtility.createContact(recordTypeId, acc.Id, new List<Address__c>{businessLocationObj2}, 'Owner', 
                                                       'Test con1', 'contact@email.com', '99999999999', false, 
                                                       u1.Id, 1)[0]; 
                                                       
            
            AccountTeamMember atm = TestDataUtility.createAccountTeamMember('Edit', 'Edit', 
                                                                            'Edit', 'Edit', 
                                                                            new List<Account>{acc}, 
                                                                            new List<User>{u1}, new List<String>{'TRK – Sales Rep'})[0];
            
            Pricebook2 standardPricebook = new Pricebook2(
                Id = Test.getStandardPricebookId(),
                
                IsActive = true
            );
             
            Update standardPricebook;
           // Case case1 = TestDataUtility.createCase(acc.Id, 'Web', u1.Id, 'New', 1)[0];
            
            TriggerHandler.bypass('OpportunityTriggerHandler');TriggerHandler.bypass('ContactTriggerHandler');TriggerHandler.bypass('CaseTriggerHandler');TriggerHandler.bypass('TaskTriggerHandler');
            //Case case1 = TestDataUtility.createCase(acc.Id, 'Web', u1.Id, 'New', 1)[0];
            List<Opportunity> listOpp = TestDataUtility.createOpportunity(null, null, 'Opp1', null, acc, ConstantClass.PROSPECTING_OPP_STAGE, null, System.today(), null, 'CrowleyFresh;', null, false, 1);
            
            //Contract contractObj = TestDataUtility.createContract(acc.Id,u1.Id, 2, null, listOpp, null, null, 1)[0];
            
            Opportunity opp1 = TestDataUtility.createOpportunity(null, m1.Id, 'Opp1', null, 
                                                                 new Account(Id = acc.Id), 'Prospecting', null, 
                                                                 System.today(), null, null, null, false, 1)[0];
            
            Opportunity opp2 = TestDataUtility.createOpportunity(null, m1.Id, 'Opp2', null, 
                                                                 new Account(Id = acc2.Id), 'Prospecting', null, 
                                                                 System.today(), null, null, null, false, 1)[0];
            
            OpportunityTeamMember otm = TestDataUtility.createOpportunityTeamMember('Edit', new List<Opportunity>{new Opportunity(Id = opp1.Id)}, new List<User>{new User(Id = u1.Id)}, new List<String>{'TRK – Sales Rep'})[0];
            
            Address__c businessLocationObj = TestDataUtility.createBusinessLocation(new List<Account>{acc}, 'BL1', 'City1', 
                                                                                    stateAvailableValues[0].getValue(), '1111111', '88888888888', 
                                                                                    'US', 1)[0];
            
            Address__c businessLocationObj3 = TestDataUtility.createBusinessLocation(new List<Account>{acc2}, 'BL3', 'City3', 
                                                                                    stateAvailableValues[0].getValue(), '1111113', '88888888883', 
                                                                                    'US', 1)[0];
            
            
            System.assertNotEquals(NULL, businessLocationObj.Country__c);
            
            
            System.assertNotEquals(NULL, recordTypeId);
            
            Contact con= TestDataUtility.createContact(recordTypeId, acc.Id, new List<Address__c>{businessLocationObj}, 'Owner', 
                                                       'Test confect2', 'contact23@email.com', '99999999988', false, 
                                                       m1.Id, 1)[0];
            
            Contact con3= TestDataUtility.createContact(recordTypeId, acc2.Id, new List<Address__c>{businessLocationObj3}, 'Owner', 
                                                       'Contact 24', 'test24test@email.com', '99999999988', false, 
                                                       m1.Id, 1)[0];
            
            Task t = TestDataUtility.createTask(null, null, null, 'Normal', 'Open', acc.Id, 'Test Task',
                                                System.today()+1, con.Id, m1.Id, 1)[0];
            
            
            System.assertEquals(con.Id, t.WhoId);
            
            Task t2 = TestDataUtility.createTask(null, null, null, 'Normal', 'Open', acc2.Id, 'Test Task',
                                                System.today()+1, con.Id, m1.Id, 1)[0];
            
            Event e = TestDataUtility.createEvent(null, null, null, acc.Id, 'Test Event',
                                                System.today(), System.now(), con.Id, m1.Id, 30, 1)[0];
            
            Event e2 = TestDataUtility.createEvent(null, null, null, acc2.Id, 'Test Event',
                                                System.today(), System.now(), con.Id, m1.Id, 30, 1)[0];
            
            Map<Id, Id> mapAccIdNewOwnerId = new Map<Id,Id>();
            Map<Id, Account> oldAccountMap = new Map<Id,Account>();
            List<Contact> contactList = new List<Contact>();
            List<Opportunity> OppList = new List<Opportunity>();
            Set<Id> accIdSet = new Set<Id>();
            
            oldAccountMap.put(acc2.Id , acc2);
            mapAccIdNewOwnerId.put(acc2.Id, u2.Id);
            contactList.add(con3);
            OppList.add(opp2);
            accIdSet.add(acc2.Id);
            
            test.startTest();
            
            
            acc.OwnerId = u1.Id;
            update acc;
            
            
            AccountOwnerChangeHelper_V2.transferActivityOwner(accIdSet, OppList, contactList, mapAccIdNewOwnerId, oldAccountMap);
            
            acc2.OwnerId = u2.Id;
            update acc2;
            
            
            acc3.OwnerId = u3.Id;
            update acc3;
            
   
            test.stopTest();
        }
    }
    

}