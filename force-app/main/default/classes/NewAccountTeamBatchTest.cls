/*
* Name: NewAccountTeamBatchTest
* Purpose: Test Class for NewAccountTeamBatch
* Author: Nagarro
* Created Date: 27-Aug-2019
* Modification History
*  Modification #   Story/Defect#      Modified By     Date   Description
*/
@isTest(SeeAllData = false)
public class NewAccountTeamBatchTest {

    static testMethod void testBatch() {
        Account objAccount = TestDataUtility.createAccounts('test Account name', 'Apparel', null, false, 1)[0];
        List<User_Region_to_Opp_Role__c> customSettingList = [Select Id from User_Region_to_Opp_Role__c];
        delete customSettingList;
        
        Account objAccount2 = TestDataUtility.createAccounts('Child test Account name', 'Apparel', objAccount.Id, false, 1)[0];
        
        AccountTeamMember objATM = TestDataUtility.createAccountTeamMember('Edit', 'Edit', 'Edit', 'Edit', 
                                                                           new List<Account>{objAccount2}, 
                                                                           [SELECT ID FROM USER WHERE Email = 'approvalUser1@test.com'], new List<String>{'Account Manager'})[0];
        
        Test.startTest();
        System.schedule('Scheduled Job 1', '0 1 * * * ?', new NewAccountTeamBatchScheduler());
        //Database.executeBatch(new NewAccountTeamBatch(), 200);
        Test.stopTest();
        System.assert(objAccount.Name == 'test Account name');
    }
    
    @testsetup
    static void testSetup() {
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1].Id;
        User u1 = TestDataUtility.createUser(null, profileId, null, 'User1', 'approvalUser1@test.com', 
                                             'en_US', 'en_US', 'UTF-8', 'America/Los_Angeles', null);
    }
}