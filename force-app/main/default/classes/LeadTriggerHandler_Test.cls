/*
* Name: LeadTriggerHandler_Test
* Purpose: Test class for LeadTriggerHandler.
* Author: Nagarro
* Created Date: 25-Sept-2018
* Modification History
*  Modification #   Story/Defect#      Modified By     Date   Description
*/
@isTest
public class LeadTriggerHandler_Test {
    
    @testSetup static void setup() {
        
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1].Id;
        User u = TestDataUtility.createUser(null, profileId, null, 'Admin', 'adminemail@test.com', 
                                            'en_US', 'en_US', 'UTF-8', 'America/Los_Angeles', null);
        
        User u1 = TestDataUtility.createUser(null, profileId, null, 'Admin1', 'adminemail1@test.com', 
                                            'en_US', 'en_US', 'UTF-8', 'America/Los_Angeles', null);
        
        //Market Manager profile
        Id marketManagerProfileId = [SELECT Id FROM Profile WHERE Name = 'Sales Manager' Limit 1].Id;
        User marketManager = TestDataUtility.createUser(null, marketManagerProfileId, null, 'Manager', 'marektm1@test.com', 
                                                        'en_US', 'en_US', 'UTF-8', 'America/Los_Angeles', null);
        marketManager.Region__c = 'PRT - Puerto Rico';
        update marketManager;
        System.debug('marketManager: ' + marketManager.Id);
        //Assign Market Manager permission set
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Permission_Set_For_Marketing_Managers'];
        insert new PermissionSetAssignment(AssigneeId = marketManager.id, PermissionSetId = ps.Id);
        
        //Sales agent profile
        Id salesAgentProfileId = [SELECT Id FROM Profile WHERE Name = 'Sales Agent' Limit 1].Id;
        User salesAgent = TestDataUtility.createUser(null, salesAgentProfileId, null, 'Agent', 'salesagent1@test.com', 
                                                     'en_US', 'en_US', 'UTF-8', 'America/Los_Angeles', marketManager.Id);
        salesAgent.Region__c = 'PRT - Puerto Rico';
        update salesAgent;
        System.debug('salesAgent: ' + salesAgent.Id);
        System.debug('salesAgent manager: ' + salesAgent.ManagerId);
        
        
        Group USAGroup = new Group(Name='Queue - USA', type='Queue');
        insert USAGroup;
        
        GroupMember USAGroupMember = new GroupMember(UserOrGroupId = u1.Id, GroupId=USAGroup.Id);
        insert USAGroupMember;

        QueuesObject USAQueue = new QueueSObject(QueueID = USAGroup.id, SobjectType = 'Lead');
        insert USAQueue;

        Group CARGroup = new Group(Name='Queue - CAR', type='Queue');
        insert CARGroup;

        GroupMember CARGroupMember = new GroupMember(UserOrGroupId = u.Id, GroupId=CARGroup.Id);
        insert CARGroupMember;

        QueuesObject CARQueue = new QueueSObject(QueueID = CARGroup.id, SobjectType = 'Lead');
        insert CARQueue;

        System.runAs(new User(Id = UserInfo.getUserId())) {
            CountryRegionMapping__c crm = new CountryRegionMapping__c();
            crm.Name='1';
            crm.Country_Name__c = 'United States';
            crm.Region__c = 'USA';
            insert crm;
            
            Lead leadObj1 = TestDataUtility.createLead('Test', 'Test', 'test@test.com', 'ABC Ltd.', 
                                                       ConstantClass.LEADSOURCE, 'Carriers', 'Air', 'ASSOCIATE', 
                                                       true, u.Id, 'US', 'TEST', 
                                                       'GA', '123456', 'TEST', 1)[0];

            Lead leadObj2 = TestDataUtility.createLead('Test1', 'Test 23', 'test11@test.com', 'ABC Ltd.', 
                                                       ConstantClass.LEADSOURCE, 'Carriers', 'Air', 'ASSOCIATE', 
                                                       true, [SELECT id FROM Group WHERE Name='Queue - CAR' LIMIT 1].Id, 'US', 'TEST', 
                                                       'GA', '234567', 'TEST', 1)[0];
            
            Lead leadObj3 = TestDataUtility.createLead('Test2', 'Test 22', 'test22@test.com', 'ABC Ltd.', 
                                                       ConstantClass.LEADSOURCE, 'Carriers', 'Air', 'ASSOCIATE', 
                                                       true, [SELECT id FROM Group WHERE Name='Queue - CAR' LIMIT 1].Id, 'US', 'TEST', 
                                                       'GA','234575', 'TEST', 1)[0];
            
            Lead leadObj4 = TestDataUtility.createLead('Test3', 'Test 33', 'test33@test.com', 'ABC Ltd.', 
                                                       ConstantClass.LEADSOURCE, 'Carriers', 'Air', 'ASSOCIATE', 
                                                       true, [SELECT id FROM Group WHERE Name='Queue - CAR' LIMIT 1].Id, 'US', 'TEST', 
                                                       'GA','234575', 'TEST', 1)[0];

            
            Account accObj1 =  TestDataUtility.createAccount('Account 123', null, null, false, 1)[0];
            system.debug('acccccccccccccccccccccccccccccccccccccccc'+accObj1.Id);
            
            GovernanceTeamEmail__c govEmail = new GovernanceTeamEmail__c();
            govEmail.Name = 'test@test.com';
            insert govEmail;
            
            DescribeFieldResult describe1 = Address__c.Country__c.getDescribe();
            List<PicklistEntry> availableValues1 = describe1.getPicklistValues();
            
            DescribeFieldResult describeState = Address__c.State_Picklist__c.getDescribe();
            List<PicklistEntry> stateAvailableValues = describeState.getPicklistValues();
            
            Address__c businessLocationObj = TestDataUtility.createBusinessLocation(new List<Account>{accObj1}, 'BL1', 'City1', stateAvailableValues[0].getValue(), '1111111', '88888888888', 'US', 1)[0];
            
            Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Create_Record').getRecordTypeId();
            
            System.assertNotEquals(NULL, recordTypeId);
            
            Contact con= TestDataUtility.createContact(null, accObj1.Id, new List<Address__c>{businessLocationObj}, null, 'Test con1',
                                                       'contact@email.com', '(99999999999', true, null, 1)[0];
        	
        }
    }
    
    static testMethod void insertTestMethod2(){
       Lead leadObj4 = [Select Id, Phone from lead  WHERE FirstName='Test3' LIMIT 1];
        test.startTest();
        try{
           leadObj4.Phone = '2222234' ;
            
            leadObj4.MobilePhone = '2222234';
            
            update leadObj4;
        
        }catch(exception e){
            system.debug(e.getMessage());
        }
       test.stopTest();
        
    }
    
    static testMethod void insertTestMethod1(){
           Lead leadObj3 = [Select Id, Phone from lead  WHERE FirstName='Test2' LIMIT 1];
           system.debug('phone23456--------------'+leadObj3.Phone);
        test.startTest();
       try{
           leadObj3.Phone = '233333345' ;
            update leadObj3;
        
        }catch(exception e){
            system.debug(e.getMessage());
        }
        
        try{
           leadObj3.Phone = null ;
            update leadObj3;
        
        }catch(exception e){
            system.debug(e.getMessage());
        }
       
        
       try{
           leadObj3.Phone = 'qwertyui' ;
            update leadObj3;
        
        }catch(exception e){
            system.debug(e.getMessage());
        }        
       test.stopTest();
        
        
        
    }
    
    
    
    static testMethod void insertTestMethod()
    {
        Lead leadObj1 = [Select Id, OwnerId, Company,IsConverted from lead  WHERE FirstName='Test' LIMIT 1];

        
        Contact con = [Select Id from Contact];
        Account acc = [Select Id from Account];
        

        User admin = [SELECT Id FROM User WHERE Name='Admin' LIMIT 1];


        System.assertNotEquals(NULL, leadObj1);
        System.assertNotEquals(NULL, con);
        System.assertNotEquals(NULL, acc);
        
        Task t = TestDataUtility.createTask(null, 'Task', null, 'Normal', 'Open', null, 
                                            'Lead Follow Up- '+ leadObj1.Company, System.today(), 
                                            leadObj1.Id, leadObj1.OwnerId, 1)[0];
        
                                            
        
        System.assertNotEquals(NULL, t);
        t.Status  = 'Completed';
        update t;
        
        
        
        Test.startTest();
        leadObj1.Hot_Lead__c = true;
        update leadObj1;
        
        
        
        try{
            leadObj1.Phone = '1222223';
        	update leadObj1;
        }catch(exception e){
            system.debug(e.getMessage());
        }
        
        
       
        
        
        try{
            leadObj1.Phone = 'abc';
        	update leadObj1;
        }catch(exception e){
            system.debug(e.getMessage());
        }
        
        
        
        System.runAs(admin) {
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(leadObj1.id);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus('Qualified');
        lc.setAccountId(acc.Id);
        lc.setContactId(con.Id);
        
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        
        System.assert(lcr.isSuccess());
        System.assertEquals(leadObj1.OwnerId, t.OwnerId);
            
            
            
        
        
        
            Test.stopTest();  
           
        
        }
    }
    
   
    
    
    
    


        
        
        
                                            
        
       
        
        
        
                
        
       
        
        
       
        
        
        
        
        
           
        
        
    
    
    static testMethod void updateTestMethod()
    {
        Lead leadObj1 = [SELECT Id, Followup__c FROM Lead LIMIT 1];
        System.assertNotEquals(NULL, leadObj1);
        
        Test.startTest();
        leadObj1.Followup__c = FALSE;
        update leadObj1;
        Test.stopTest();
    }
    
    static testMethod void deleteTestMethod()
    {
        Lead leadObj1 = [SELECT Id FROM Lead LIMIT 1];
        
        Test.startTest();
        List<Lead> leadListToDelete = new List<Lead>();
        leadListToDelete.add(leadObj1);
        
        try
        {
            delete leadListToDelete;
            System.assert([SELECT Id FROM Lead WHERE Id = :leadObj1.Id].size() == 0);
        }
        catch(Exception e)
        {
            System.debug('Exception in Lead Test Class'+e.getMessage());
        }
        Test.stopTest();
    }

    static testMethod void changeLeadOwner()
    {
        User admin1 = [SELECT Id FROM User WHERE Name='Admin1' LIMIT 1];
        User admin = [SELECT Id FROM User WHERE Name='Admin' LIMIT 1];
        
        Lead leadObj1 = [SELECT Id, OwnerId, Followup__c FROM Lead WHERE FirstName = 'Test' LIMIT 1];
        System.assertNotEquals(NULL, leadObj1);

        Test.startTest();
            leadObj1.Followup__c = FALSE;
            leadObj1.OwnerId = [SELECT id FROM Group WHERE Name='Queue - CAR' LIMIT 1].Id;
            update leadObj1;
        Test.stopTest();
    }
    
    static testMethod void changeLeadOwner1()
    {
        User admin1 = [SELECT Id FROM User WHERE Name='Admin1' LIMIT 1];
        User admin = [SELECT Id FROM User WHERE Name='Admin' LIMIT 1];
        
        Lead leadObj1 = [SELECT Id, OwnerId, Followup__c FROM Lead WHERE FirstName = 'Test1' LIMIT 1];
        System.assertNotEquals(NULL, leadObj1);

        Test.startTest();
            leadObj1.Followup__c = FALSE;
            leadObj1.OwnerId = admin1.Id;
            update leadObj1;
        Test.stopTest();
    }
    //Test logic when lead created by Sales Agent,owner is changed to his Market Manager
    static testMethod void assignLeadOwnerToMarketManager(){
        
        User salesAgent = [SELECT Id FROM User WHERE Name='Agent' LIMIT 1];
        User marketManager = [SELECT Id FROM User WHERE Name='Manager' LIMIT 1];
        
        System.debug('salesAgent userid: ' + salesAgent.Id);
        System.debug('marketManager userid: ' + marketManager.Id);
        List<Product2> lstProducts = TestDataUtility.createProduct(new List<String>{'CrowleyFresh', 'Air', 'Asset Management'}); 
        
        Id leadId;
        Test.startTest();
        Lead leadObj = new lead();
        System.runAs(salesAgent){
            
            leadObj.FirstName = 'Sales';
            leadObj.LastName = 'Agent';
            leadObj.Email = 'test@test.com';
            leadObj.Company = 'ABC1234 Ltd.';
            leadObj.LeadSource = 'Other';
            leadObj.Industry = 'Apparel';
            leadObj.Service__c = 'Air';
            leadObj.Title = 'Test';
            leadObj.Followup__c = true;
            leadObj.OwnerId = UserInfo.getUserId();
            leadObj.Country='AF';
            leadObj.Country__c='AF';
            leadObj.PostalCode = '201010';
            leadObj.Postal_Code__c ='201010';
            leadObj.Phone = '12345678923';
            leadObj.Sales_Rep_Region__c = 'CAM - Central America';
            leadObj.Status = 'New';
            leadObj.Address_Line_1__c = 'New York';
            leadObj.Address_Line_2__c = 'New York';
            leadObj.Address_Line_3__c = 'New York';
            //leadObj.Conversion_Ready__c = True;
            leadObj.City ='New York';
            leadObj.City__c = 'New York';
            //leadObj.Created_from_Lead_Conversion__c =true;
            System.debug('before update');
            insert leadObj;
            System.debug('after update');
            
            //Contact c = [Select Id, Name from Contact where Name='Test con1'];
            //System.debug('contact: ' + c);
                
            leadId= leadObj.Id;
            System.debug('leadObj id: ' + leadObj.Id);
            System.debug('leadObj ownerid: ' + leadObj.OwnerId);
           }
        
        Lead leadobj2 = [Select Id,OwnerID,Owner.Name, Createdby.Name,createdbyId from Lead where Id = :leadId];
        
        List<Task> tasklist = new List<Task>([SELECT Id, Who.Id, Who.Type, Status FROM Task 
                                     WHERE Who.Type = 'Lead' and
                                    	Who.Id =:leadobj2.Id ]);
        
         
        
        
       // System.runAs(marketManager){
            for(Task t:tasklist){
                t.Status='Completed';
            }
            System.debug('tasklist: ' + tasklist);
            update tasklist;
            
            System.debug('leadobj2 owner: ' + leadobj2.Owner.Name );
            System.debug('leadobj2 owner: ' + leadobj2.createdby.Name);
            
            
                System.debug('runAS: ' + userInfo.getUserId());
                Database.leadConvert lc = new Database.leadConvert();
                lc.setLeadId(leadObj.Id);
                leadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
            	System.debug('convertStatus: ' + convertStatus);
                lc.setConvertedStatus(convertStatus.MasterLabel);
                Database.LeadConvertResult lcr = Database.convertLead(lc);
                System.debug('lcr isSuccess: ' + lcr.isSuccess());
                System.debug('acc id: ' +lcr.getAccountId());
                System.debug('con id: ' +lcr.getContactId());
                System.debug('opp id: ' +lcr.getOpportunityId()) ;
        		List<Lead> leadList = [Select Id, IsConverted from Lead where Id = :leadObj.Id];
            	System.debug('leadObj----------'+leadList);
                System.assert(lcr.isSuccess());
                
        //}
		Test.stopTest();   
    }
    static testMethod void initiativeConvertLead(){
        
        
        Initiative__c objInitiative = TestDataUtility.createInitiative('Test Initiative', 1)[0];
        
      
        
            Lead leadObj = new lead();
            leadObj.FirstName = 'Sales';
        	leadObj.Initiative__c = objInitiative.Id;
        	leadObj.Hot_Lead__c = true;
            leadObj.LastName = 'Agent';
            leadObj.Email = 'test@test.com';
            leadObj.Company = 'ABC1234 Ltd.';
            leadObj.LeadSource = 'Other';
            leadObj.Industry = 'Apparel';
            leadObj.Service__c = 'Air';
            leadObj.Title = 'Test';
            leadObj.Followup__c = true;
            leadObj.OwnerId = UserInfo.getUserId();
            leadObj.Country='AF';
            leadObj.Country__c='AF';
            leadObj.PostalCode = '201010';
            leadObj.Postal_Code__c ='201010';
            leadObj.Phone = '12345678923';
            leadObj.Sales_Rep_Region__c = 'CAM - Central America';
            leadObj.Status = 'New';
            leadObj.Address_Line_1__c = 'New York';
            leadObj.Address_Line_2__c = 'New York';
            leadObj.Address_Line_3__c = 'New York';
            leadObj.City ='New York';
            leadObj.City__c = 'New York';
            insert leadObj;
        Test.startTest();
        List<Task> tasklist = new List<Task>([SELECT Id, Who.Id, Who.Type, Status FROM Task 
                                              WHERE Who.Type = 'Lead' and
                                              Who.Id =:leadObj.Id ]);
        
        
        
        
        // System.runAs(marketManager){
        for(Task t:tasklist){
            t.Status='Completed';
        }
        System.debug('tasklist: ' + tasklist);
        update tasklist;
        
        

            
                System.debug('runAS: ' + userInfo.getUserId());
        		
                Database.leadConvert lc = new Database.leadConvert();
        		lc.setDoNotCreateOpportunity(true);
                lc.setLeadId(leadObj.Id);
                leadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
            	System.debug('convertStatus: ' + convertStatus);
                lc.setConvertedStatus(convertStatus.MasterLabel);
                Database.LeadConvertResult lcr = Database.convertLead(lc);
                System.debug('lcr isSuccess: ' + lcr.isSuccess());
                System.debug('acc id: ' +lcr.getAccountId());
                System.debug('con id: ' +lcr.getContactId());
                System.debug('opp id: ' +lcr.getOpportunityId()) ;
        		List<Lead> leadList = [Select Id, IsConverted from Lead where Id = :leadObj.Id];
            	System.debug('leadObj----------'+leadList);
                System.assert(lcr.isSuccess());
        		Test.stopTest();
        
        
    }
}