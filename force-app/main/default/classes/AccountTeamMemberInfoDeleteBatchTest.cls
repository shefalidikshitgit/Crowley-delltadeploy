/*
* Name: AccountTeamMemberInfoDeleteBatch
* Purpose: Test Class for Batchlass to delete 3 month old records in Account Team Member Info object.
* Author: Nagarro
* Created Date: 12-Feb-2020
* Modification History
*  Modification # #  Story/Defect#      Modified By     Date   Description
*/
@isTest(SeeAllData = false)
public class AccountTeamMemberInfoDeleteBatchTest {
    
    
    @testSetup
    static void setupTestData(){
        
        List<Account> accountList                   =   TestDataUtility.createAccount('Account 123', null, null, false, 1);
        DescribeFieldResult describeState           =   Address__c.State_Picklist__c.getDescribe();
        List<PicklistEntry> stateAvailableValues    =   describeState.getPicklistValues();
        List<Address__c> businessLocationList       =   TestDataUtility.createBusinessLocation(new List<Account>{accountList[0]}, 'BL1', 'City1', stateAvailableValues[0].getValue(), '1111111', '88888888888', 'US', 1);
        
    }
    
    static testMethod void accountTeamMemberInfoDelete(){
        Test.startTest();
        String CRON_EXP = '0 0 0 15 3 ? *';
        String jobId = System.schedule('AccountTeamMemberInfoDeleteBatchSchedule',  CRON_EXP, new AccountTeamMemberInfoDeleteBatchSchedule());
        Test.stopTest();
    }

}