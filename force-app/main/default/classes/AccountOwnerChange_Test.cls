/*
* Name: AccountOwnerChange_Test
* Purpose: Test class for AccountOwnerChangeController and AccountOwneChangeHelper 
* Author: Nagarro
* Created Date: 11-Apr-2019
* Modification History
*  Modification #   Story/Defect#      Modified By     Date[MM/DD/YYYY]   Description
                    Code coverage       Priyanka        09/13/2019          
*/        
@isTest
public class AccountOwnerChange_Test {
    
    static testMethod void accountOwnerChangeTestMethod()
    {
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1].Id;
        Account acc, acc2;
        
        User m1 = TestDataUtility.createUser(null, profileId, null, 'USA SYSTEM ADMIN', 'USASYSTEMADMIN@test.com', 
                                             'en_US', 'en_US', 'UTF-8', 'America/Los_Angeles', null);
        
        User u1 = TestDataUtility.createUser(null, profileId, null, 'user1', 'approvalUser1@test.com', 
                                             'en_US', 'en_US', 'UTF-8', 'America/Los_Angeles', m1.Id);
        
        User u2 = TestDataUtility.createUser(null, profileId, null, 'User2', 'approvalUser2@test.com', 
        
                                             'en_US', 'en_US', 'UTF-8', 'America/Los_Angeles', m1.Id);
        
                                                     
        System.runAs(m1) {
        
            DescribeFieldResult describe = Address__c.Country__c.getDescribe();
            List<PicklistEntry> availableValues = describe.getPicklistValues();
            DescribeFieldResult describeState = Address__c.State_Picklist__c.getDescribe();
            List<PicklistEntry> stateAvailableValues = describeState.getPicklistValues();
            Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Create_Record').getRecordTypeId();
            
            ProfilesHavingCheckboxAccess__c obj1 = new ProfilesHavingCheckboxAccess__c();
            obj1.Name = 'System Administrator';
            insert obj1;
            
            
            acc = TestDataUtility.createAccount('ApprovalProcessAccount_TestClass',  u1.Id, u2.Id, 'Approved', 1)[0];
            List<User_Region_to_Opp_Role__c> customSettingList = [Select Id from User_Region_to_Opp_Role__c];
            delete customSettingList;
            List<Account> accListChild = TestDataUtility.createAccounts('Child Account', 'Customer', 'Agriculture', acc.Id, false, 1);
            
            Address__c businessLocationObj2 = TestDataUtility.createBusinessLocation(new List<Account>{acc}, 'BL11', 'City11', 
                                                                                    stateAvailableValues[0].getValue(), '1134111', '86788888888', 
                                                                                    'US', 1)[0];
            Contact con2 = TestDataUtility.createContact(recordTypeId, acc.Id, new List<Address__c>{businessLocationObj2}, null, 
                                                       'Test con1', 'contact@email.com', '99999999999', false, 
                                                       u1.Id, 1)[0]; 
                                                       
            acc.TimeofStep3Approval__c = system.now()+2;
            List<Account> accList = new List<Account>();
            accList.add(acc);
            update accList;
            acc = new Account();
            acc = accList[0];
            
            AccountTeamMember atm = TestDataUtility.createAccountTeamMember('Edit', 'Edit', 
                                                                            'Edit', 'Edit', 
                                                                            new List<Account>{acc}, 
                                                                            new List<User>{u1}, new List<String>{'Account Manager'})[0];
            
            Pricebook2 standardPricebook = new Pricebook2(
                Id = Test.getStandardPricebookId(),
                
                IsActive = true
            );
             
            Update standardPricebook;
           // Case case1 = TestDataUtility.createCase(acc.Id, 'Web', u1.Id, 'New', 1)[0];
            
            TriggerHandler.bypass('OpportunityTriggerHandler');TriggerHandler.bypass('ContactTriggerHandler');TriggerHandler.bypass('CaseTriggerHandler');TriggerHandler.bypass('TaskTriggerHandler');
            //Case case1 = TestDataUtility.createCase(acc.Id, 'Web', u1.Id, 'New', 1)[0];
            List<Opportunity> listOpp = TestDataUtility.createOpportunity(null, null, 'Opp1', null, acc, ConstantClass.PROSPECTING_OPP_STAGE, null, System.today(), null, 'CrowleyFresh;', null, false, 1);
            
            Contract contractObj = TestDataUtility.createContract(acc.Id,u1.Id, 2, null, listOpp, null, null, 1)[0];
            
            Opportunity opp1 = TestDataUtility.createOpportunity(null, u1.Id, 'Opp1', null, 
                                                                 new Account(Id = acc.Id), 'Prospecting', null, 
                                                                 System.today(), null, null, null, false, 1)[0];
            
            OpportunityTeamMember otm = TestDataUtility.createOpportunityTeamMember('Edit', new List<Opportunity>{new Opportunity(Id = opp1.Id)}, new List<User>{new User(Id = u1.Id)}, new List<String>{'Account Manager'})[0];
            
            Address__c businessLocationObj = TestDataUtility.createBusinessLocation(new List<Account>{acc}, 'BL1', 'City1', 
                                                                                    stateAvailableValues[0].getValue(), '1111111', '88888888888', 
                                                                                    'US', 1)[0];
            
            System.assertNotEquals(NULL, businessLocationObj.Country__c);
            
            
            System.assertNotEquals(NULL, recordTypeId);
            
            Contact con= TestDataUtility.createContact(recordTypeId, acc.Id, new List<Address__c>{businessLocationObj}, null, 
                                                       'Test confect2', 'contact23@email.com', '99999999988', false, 
                                                       u1.Id, 1)[0];
            
            Task t = TestDataUtility.createTask(null, null, null, 'Normal', 'Open', acc.Id, 'Test Task',
                                                System.today()+1, con.Id, u1.Id, 1)[0];
            System.assertEquals(con.Id, t.WhoId);
            
            test.startTest();
            
            Approval.ProcessSubmitRequest app1 = new Approval.ProcessSubmitrequest();
  
            app1.setObjectId(acc.Id);
  
            Approval.ProcessResult result1 = Approval.process(app1);
            
            // Verify that the results are as expected
            System.assert(result1.isSuccess());
            System.assertEquals('Pending', result1.getInstanceStatus(), 'Instance Status'+result1.getInstanceStatus());  
            
            ApexPages.StandardController sc = new ApexPages.StandardController(acc);
            AccountOwnerChangeController accountOwnerChangeControllerObj = new AccountOwnerChangeController(sc);
            accountOwnerChangeControllerObj.displayPopup();
            accountOwnerChangeControllerObj.closePopup();
            accountOwnerChangeControllerObj.initiateProcess();
            accountOwnerChangeControllerObj.accountSelected();
            accountOwnerChangeControllerObj.validatePage();
  
            acc.Proposed_Account_Owner__c = u1.Id;
  
            acc.OwnerId = u1.Id;
  
            update acc;
  
            System.assertEquals(acc.OwnerId, acc.Proposed_Account_Owner__c);
            
            acc.Proposed_Account_Owner__c = u1.Id;
  
            System.assertEquals(u1.Id, acc.Proposed_Account_Owner__c);
            
            acc.userWhoProposedNewOwner__c = u1.Id; 
  
            System.assertEquals(u1.Id, acc.userWhoProposedNewOwner__c);
            
            acc.PreviousOwnersManager__c = acc.userWhoProposedNewOwner__c;
            System.assertEquals(u1.Id, acc.PreviousOwnersManager__c);
            
            acc.Proposed_Owners_Manager__c = u1.Id;
            System.assertEquals(u1.Id, acc.Proposed_Owners_Manager__c);
            
            acc.Approval_Process_Action__c = 'APPROVED';
            System.assertEquals('APPROVED', acc.Approval_Process_Action__c);
            
            acc.ApprovalProcessInitiatedOn__c = Date.today();
            System.assertEquals(Date.today(), acc.ApprovalProcessInitiatedOn__c);
            accountOwnerChangeControllerObj.onLoad();
            accountOwnerChangeControllerObj.validatePage();
            accountOwnerChangeControllerObj.checkCurrentUserAuthorizedToApprove(acc);
            accountOwnerChangeControllerObj.approveProcess();
            
            AccountOwnerChangeHelper.sendEmailToNewAndOldAccountOwner(acc);
          
    
            
            
            
            
            Approval.ProcessSubmitRequest app2 = new Approval.ProcessSubmitrequest();
            app2.setObjectId(acc.Id);
  
            Approval.ProcessResult result2 = Approval.process(app2);
  
            accountOwnerChangeControllerObj.rejectProcess();
            
            Approval.ProcessSubmitRequest app3 = new Approval.ProcessSubmitrequest();
            app3.setObjectId(acc.Id);
  
            Approval.ProcessResult result3 = Approval.process(app3);
            accountOwnerChangeControllerObj.abortProcess();
            accountOwnerChangeControllerObj.notificationPopup();
            accountOwnerChangeControllerObj.getAllFields();
            accountOwnerChangeControllerObj.moveToAccountDetail();
            
            Map<Id, Account> newAccountMap = new Map<Id,Account>();
            Map<Id, Account> oldAccountMap = new Map<Id,Account>();
            acc.Proposed_Account_Owner__c = u1.Id;
            newAccountMap.put(acc.Id , acc);
            oldAccountMap.put(acc.Id , acc);
  
            
            AccountOwnerChangeHelper.transferOwners(newAccountMap, oldAccountMap);
           // accList[0].Proposed_Account_Owner__c = u2.Id;
           // update accList;
            TriggerHandler.clearBypass('OpportunityTriggerHandler');TriggerHandler.clearBypass('ContactTriggerHandler');TriggerHandler.clearBypass('CaseTriggerHandler');TriggerHandler.clearBypass('TaskTriggerHandler');
            /*map<Id,Account> accmap = new map<Id,Account>();
            accmap.put(acc.Id,acc);
            AccountOwnerChangeHelper.getMapAccIdChildAccList(accmap);*/
            test.stopTest();
        }
    }
    
}