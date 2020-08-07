/*
* Name: GoalRelationshipTriggerHandlerTest  
* Purpose: Test class of GoalRelationshipTriggerHandler
* Author: Nagarro
* Created Date: 06-Feb-2020
* Modification History
*  Modification #   Story/Defect#      Modified By     Date   Description
*/
@isTest(seeAllData=false)
public class GoalRelationshipTriggerHandlerTest {

    @isTest
    static void checkAndPreventDeleteTest() {
        try {
            delete [SELECT Id FROM Goal_Initiative__c];
        } catch(Exception objEx) {
            System.assert(objEx.getMessage().contains(Label.AINI_GI_DELETION_NOT_ALLOWED));
        }  
    }
    /*
    * Method Name: testDataSetup
    * Purpose: Prepare test data
    */
    @testSetup
    public static void testDataSetup() {
        //Create Account
        List<Account> lstTestAccounts = TestDataUtility.createAccount('Test Account', 'Apparel', null, false, 1);
        
        //Create Initiative
        List<Initiative__c> lstInitiative = TestDataUtility.createInitiative('Test Initiative', 1);
        
        //Goal Initiative
        Goal_Initiative__c objGoalInitiative = TestDataUtility.createInitiativeRelationship(lstInitiative[0].Id, lstTestAccounts[0].Id);
    }
}