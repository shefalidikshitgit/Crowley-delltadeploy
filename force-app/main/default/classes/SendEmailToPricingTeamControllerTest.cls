/*
* Name: SendEmailToPricingTeamControllerTest
* Purpose: Test class for Email Sent Functionality For Pricing Quote On Click of Send Email button for SendEmailToPricingTeamController Class.
* Author: Nagarro
* Created Date: 13-April-2019
* Modification History
*  Modification #   Story/Defect#      Modified By     Date   Description
*/
@isTest
private class SendEmailToPricingTeamControllerTest {
    
    @TestSetup
    static void setupData()
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        GovernanceTeamEmail__c govEmail = new GovernanceTeamEmail__c();
        govEmail.Name = 'test@test.com';
        insert govEmail;
        
        Account accObj1 = TestDataUtility.createAccount('Account 123', null, null, true, 1)[0];
        
        DescribeFieldResult describeState = Address__c.State_Picklist__c.getDescribe();
        List<PicklistEntry> stateAvailableValues = describeState.getPicklistValues();
        
        Address__c businessLocationObj = TestDataUtility.createBusinessLocation(new List<Account>{accObj1}, 'BL1', 'City1', 
                                                                                stateAvailableValues[0].getValue(), '1111111', '88888888888', 
                                                                                'US', 1)[0];
        
        Contact con = TestDataUtility.createContact(null, null, new List<Address__c>{businessLocationObj}, null, 'Test con1', 
                                                    'contact@email.com', '99999999999', true, null, 1)[0];
        
        
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        Update standardPricebook;
    }
    
    // Test Method to check Email Send Functionality In case of Email Send Successfully.
    private static testMethod void validateSendEmailToPricng(){
        String customLabelValue =  System.Label.PricingTeamEmail;
        Opportunity opp = TestDataUtility.createOpportunity(null, null, 'Opp1', [Select Id FROM Contact Where LastName ='Test con1'][0], 
                                                            [SELECT Id FROM Account WHERE Name ='Account 123'][0], 'Prospecting', null, System.today(), 
                                                            null, 'Air', 'CaribbeanBreakbulk@Crowley.com', false, 1)[0];
        
        
        Test.startTest();
        Opportunity opp1 = [Select id , name , PricingTeamEmailPicklist__c from Opportunity where name = 'Opp1' Limit 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(opp1);
        SendEmailToPricingTeamController stpc = new SendEmailToPricingTeamController(sc);
        stpc.sendEmail();
        System.assert(stpc.redirect() != null);
        Test.stopTest();
    }
    
    // Test Method to check Email Send Functionality In case of invalid Email ID.
    private static testMethod void validateSendEmailToPricngFail(){
        String customLabelValue =  System.Label.PricingTeamEmail;
        Opportunity opp = TestDataUtility.createOpportunity(null, null, 'Opp1', [Select Id FROM Contact Where LastName ='Test con1'][0], 
                                                            [SELECT Id FROM Account WHERE Name ='Account 123'][0], 'Prospecting', null, System.today(), 
                                                            null, 'Air', 'CaribbeanBreakbulk@Crowley.com', false, 1)[0];
        
        Test.startTest();
        Opportunity opp2 = [Select id , name , PricingTeamEmailPicklist__c from Opportunity where name = 'Opp1' Limit 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(opp2);
        SendEmailToPricingTeamController stpc = new SendEmailToPricingTeamController(sc);
        stpc.sendEmail();
        System.assert(stpc.redirect() != null);
        Test.stopTest();
    }
}