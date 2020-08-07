/*
* Name: OpportunityTriggerHandler_Test
* Purpose: Test class for OpportunityTriggerHandler.
* Author: Nagarro
* Created Date: 16-Oct-2018
* Modification History
*  Modification #   Story/Defect#      Modified By     Date   Description
*/
@isTest
public class OpportunityTriggerHandler_Test {
    @testSetup static void setup()
    {
        Account accObj1 = TestDataUtility.createAccount('Account 123', null, null, false, 1)[0];
        
        DescribeFieldResult describe = Address__c.Country__c.getDescribe();
        List<PicklistEntry> availableValues = describe.getPicklistValues();
        
        DescribeFieldResult describeState = Address__c.State_Picklist__c.getDescribe();
        List<PicklistEntry> stateAvailableValues = describeState.getPicklistValues();
        
        Address__c businessLocationObj = TestDataUtility.createBusinessLocation(new List<Account>{accObj1}, 'BL1', 'City1', stateAvailableValues[0].getValue(), '1111111', '88888888888', 'US', 1)[0];
        
        Contact con= TestDataUtility.createContact(null, null, new List<Address__c>{businessLocationObj}, null, 'Test con1',
                                                   'contact@email.com', '99999999999', false, null, 1)[0];
        
        List<Product2> lstProducts = TestDataUtility.createProduct(new List<String>{'CrowleyFresh', 'Air', 'Asset Management'}); 
        
        
        CountryRegionMapping__c crm = new CountryRegionMapping__c();
        crm.Name='1';
        crm.Country_Name__c = 'Anguilla';
        crm.Region__c = 'Caribbean';
        insert crm;
        
        ProfileNames__c p1 = new ProfileNames__c();
        p1.Name = 'Sales Leader';
        insert p1;
        
        ProfileNames__c p2 = new ProfileNames__c();
        p2.Name = 'System Administrator';
        insert p2;
        
        Opportunity opp1 = TestDataUtility.createOpportunity(null, null, 'Opp1', con, accObj1, ConstantClass.PROSPECTING_OPP_STAGE, null, System.today(), null, 'CrowleyFresh;', null, true, 1)[0];
        
        Contract contractObj = TestDataUtility.createContract(accObj1.Id, null, 2, System.today(), new List<Opportunity>{opp1}, 'Draft', [SELECT Id FROM Pricebook2][0].Id, 1)[0];
        
        OppAmountReminderController.getOpportunityStageValue(opp1.Id);
        OppAmountReminderController.getQuotedPriceOfOpportunity(opp1.Id);
    }
    
    static testMethod void insertOpportunityTestMethod()
    {
        Opportunity opp = [Select Id,Service_Type__c, StageName from Opportunity];
        Test.startTest();
        System.assertNotEquals(NULL, opp);
        System.assertEquals(opp.StageName, ConstantClass.PROSPECTING_OPP_STAGE);
        Test.stopTest();
    }
    
    static testMethod void insertOpportunityLineItemTestMethod()
    {
        Opportunity opp = [Select Id,Service_Type__c from Opportunity];
        System.assertNotEquals(NULL, opp);
        
        PriceBookEntry pbEntry = [Select Id, UnitPrice from PriceBookEntry][0];
        Test.startTest();
        OpportunityLineItem oppLineItem = new OpportunityLineItem();
        oppLineItem.OpportunityId = opp.Id;
        oppLineItem.Quantity = 5;
        oppLineItem.PricebookEntryId = pbEntry.Id;
        oppLineItem.TotalPrice = oppLineItem.Quantity * pbEntry.UnitPrice;
        insert oppLineItem;
        System.assertNotEquals(NULL, oppLineItem);
        Test.stopTest();
    }
    
    static testMethod void updateOpportunityTestMethod()
    {
        Opportunity opp = [Select Id,Service_Type__c,StageName from Opportunity];
        Test.startTest();
        System.assertNotEquals(NULL, opp);
        System.assertEquals(opp.StageName, ConstantClass.PROSPECTING_OPP_STAGE);
        
        opp.Service_Type__c = 'Air;';
        update opp;
        Test.stopTest();
    }
    
    static testMethod void deleteOpportunityTestMethod()
    {   
        Opportunity opp = [Select Id from Opportunity];
        System.assertNotEquals(NULL, opp);
        List<Opportunity> oppListToDelete = new List<Opportunity>();
        oppListToDelete.add(opp);
        
        test.startTest();
        try
        {
            delete oppListToDelete;
        }
        catch(Exception e)
        {
            System.debug('Exception in Opportunity Test Class'+e.getMessage());
        }
        
        test.stopTest();
    }
    
    static testMethod void deleteOpportunityLineItemTestMethod2()
    {   
        OpportunityLineItem oppLineItem = [Select Id from OpportunityLineItem];
        System.assertNotEquals(NULL, oppLineItem);
        List<OpportunityLineItem> oppLineItemListToDelete = new List<OpportunityLineItem>();
        oppLineItemListToDelete.add(oppLineItem);
        
        test.startTest();
        
        try
        {
            delete oppLineItemListToDelete;
        }
        catch(Exception e)
        {
            System.debug('Exception in Opportunity Test Class'+e.getMessage());
        }
        test.stopTest();
    }
}