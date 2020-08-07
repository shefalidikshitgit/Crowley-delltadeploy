/*
* Name: OpportunitySplitControllerTest
* Purpose: Test class for OpportunitySplitController
* Author: Nagarro
* Created Date: 1-Mar-2019
* Modification History
*  Modification #   Story/Defect#      Modified By     Date   Description
*/
@isTest(seeAllData=false)
public class OpportunitySplitControllerTest {
    
    /*
    * Method Name: testGetOpportunityLineItems
    * Purpose: test method for OpportunitySplitController.getOpportunityLineItems
    */
    public static testMethod void testGetOpportunityLineItems() {
        createOpportunityLineItem();
        List<OpportunitySplitServiceWrapper> lstOpportunitySplitServiceWrapper = OpportunitySplitController.getOpportunityLineItems([SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity'][0].Id, 'DESKTOP_CLOSED_WON');
        System.assert(lstOpportunitySplitServiceWrapper.size() > 0);
    }
    
    /*
    * Method Name: testSaveSplitOpportunity
    * Purpose: test method for OpportunitySplitController.saveSplitOpportunity
    */
    public static testMethod void testSaveSplitOpportunity() {
        createOpportunityLineItem();
        Test.startTest();
        List<OpportunitySplitServiceWrapper> lstOpportunitySplitServiceWrapper = OpportunitySplitController.getOpportunityLineItems([SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity'][0].Id, 'DESKTOP_CLOSED_WON');
        lstOpportunitySplitServiceWrapper[0].boolServiceStatus = true;
        lstOpportunitySplitServiceWrapper[1].boolServiceStatus = true;
        lstOpportunitySplitServiceWrapper[2].boolServiceStatus = false;
        //Check split success
        System.assert(OpportunitySplitController.saveSplitOpportunity([SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity'][0].Id, lstOpportunitySplitServiceWrapper));
        Test.stopTest();
    }
    
    /*
    * Method Name: testSaveSplitOpportunityNegative
    * Purpose: negative test method for OpportunitySplitController.saveSplitOpportunity
    */
    public static testMethod void testSaveSplitOpportunityNegative() {
        createOpportunityLineItem();
        List<OpportunitySplitServiceWrapper> lstOpportunitySplitServiceWrapper = OpportunitySplitController.getOpportunityLineItems([SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity'][0].Id, 'DESKTOP_CLOSED_WON');
        lstOpportunitySplitServiceWrapper[0].boolServiceStatus = true;
        lstOpportunitySplitServiceWrapper[1].boolServiceStatus = true;
        lstOpportunitySplitServiceWrapper[2].boolServiceStatus = false;
        //Check split failure
        System.assert(OpportunitySplitController.saveSplitOpportunity(null, lstOpportunitySplitServiceWrapper) == false);
    }
    
    /*
    * Method Name: testGetOpportunity
    * Purpose: test method for OpportunitySplitController.getOpportunity
    */
    public static testMethod void testGetOpportunity() {
        createOpportunityLineItem();
        System.assert(OpportunitySplitController.getOpportunity([SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity'][0].Id).OpportunityLineItems.size() > 0);
    }
    
    /*
    * Method Name: testGetWonAndLostOppSize
    * Purpose: test method for OpportunitySplitController.getWonAndLostOppSize
    */
    public static testMethod void testGetWonAndLostOppSize() {
        Map<String, Decimal> mapWonLostOppSize = new Map<String, Decimal>();
        createOpportunityLineItem();
        Test.startTest();
        List<OpportunitySplitServiceWrapper> lstOpportunitySplitServiceWrapper = OpportunitySplitController.getOpportunityLineItems([SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity'][0].Id, 'DESKTOP_CLOSED_WON');
        lstOpportunitySplitServiceWrapper[0].boolServiceStatus = true;
        lstOpportunitySplitServiceWrapper[1].boolServiceStatus = true;
        lstOpportunitySplitServiceWrapper[2].boolServiceStatus = false;
        OpportunitySplitController.saveSplitOpportunity([SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity'][0].Id, lstOpportunitySplitServiceWrapper);
       
        mapWonLostOppSize = OpportunitySplitController.getWonAndLostOppSize([SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity'][0].Id);
        System.assert(mapWonLostOppSize.get('WON_OPP_SIZE') == 4.00);
        System.assert(mapWonLostOppSize.get('LOST_OPP_SIZE') == 2.00);
        Test.stopTest();
    }
    
    /*
    * Method Name: testGetUIThemeDescription
    * Purpose: test method for OpportunitySplitController.getUIThemeDescription
    */
    public static testMethod void testGetUIThemeDescription() {
        List<String> lstTheme = new List<String>{'Theme1', 'Theme2', 'Theme3', 'Theme4d', 'Theme4t', 'Theme4u', 'PortalDefault', 'Webstore'};
        System.assert(lstTheme.contains(OpportunitySplitController.getUIThemeDescription()));
    }
    
    /*
    * Method Name: testRestoreLostOpportunityLineItem
    * Purpose: test method for OpportunitySplitController.restoreLostOpportunityLineItem
    */
    public static testMethod void testRestoreLostOpportunityLineItem() {        
        createOpportunityLineItem();
        Test.startTest();
        List<OpportunitySplitServiceWrapper> lstOpportunitySplitServiceWrapper = OpportunitySplitController.getOpportunityLineItems([SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity'][0].Id, 'DESKTOP_CLOSED_WON');
        lstOpportunitySplitServiceWrapper[0].boolServiceStatus = true;
        lstOpportunitySplitServiceWrapper[1].boolServiceStatus = true;
        lstOpportunitySplitServiceWrapper[2].boolServiceStatus = false;
        OpportunitySplitController.saveSplitOpportunity([SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity'][0].Id, lstOpportunitySplitServiceWrapper);
		System.assert([SELECT Id, Amount FROM Opportunity WHERE Name = 'Test Opportunity'][0].Amount == 4);
        
        Opportunity objOpportunity = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity'][0];
        objOpportunity.StageName = 'Proposal Presented';
        update objOpportunity;
        System.assert([SELECT Id, Amount FROM Opportunity WHERE Name = 'Test Opportunity'][0].Amount == 6);
        Test.stopTest();
    }
    
    /*
    * Method Name: testDataSetup
    * Purpose: Prepare test data
    */
    @testSetup
    public static void testDataSetup() {
        //Create Account
        List<Account> lstTestAccounts = TestDataUtility.createAccount('Test Account', 'Apparel', null, false, 1);
        
        //Create Child Account
        TestDataUtility.createAccount('Child Test Account', 'Apparel', lstTestAccounts[0].Id, false, 1);
        
        DescribeFieldResult describe = Address__c.State_Picklist__c.getDescribe();
        List<PicklistEntry> availableValues = describe.getPicklistValues();
        
        //Create business location
        List<Address__c> lstAddress = TestDataUtility.createBusinessLocation(lstTestAccounts, 'Test Address line 1', 'Test City', availableValues[0].getValue(), '123456', null, 'US', 1);
        
        //Create Contact
        List<Contact> lstTestContact =  TestDataUtility.createContact(null, null, lstAddress, null, 'Test LastName', 'test@testExample.com', null, false, null, 1);

        //Create Opportunity
        Id idOpportunityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Record').getRecordTypeId();
        List<Opportunity> lstTestOpportunity = TestDataUtility.createOpportunity(idOpportunityRecordTypeId, null, 'Test Opportunity', lstTestContact[0], lstTestAccounts[0], 'Prospecting', 'USA - United States', Date.today(), Date.today(), 'Air', null, false, 1);
        
        //Create products
        List<Product2> lstProducts = TestDataUtility.createProduct(new List<String>{'Air', 'Insurance', 'Asset Management'}); 
    }
    
    /*
    * Method Name: createOpportunityLineItem
    * Purpose: Prepare test data
    */
    private static void createOpportunityLineItem() {
        //Create Opportunity LineItems
        TestDataUtility.createOpportunityLineItem([SELECT Id FROM Opportunity][0], [SELECT Id FROM Product2], 1, 2);
    }
}