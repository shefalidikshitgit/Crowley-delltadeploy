/*
* Name: EmailMessageTriggerHandler_Test
* Purpose: Test class for EmailMessageTriggerHandler class.
* Author: Nagarro
* Created Date: 6-Mar-2019
* Modification History
*  Modification #   Story/Defect#      Modified By     Date   Description
*/
@isTest
public class EmailMessageTriggerHandler_Test {
    
    static testMethod void emailMessageTriggerHandler_TestMethod()
    {
        Account accObj = TestDataUtility.createAccount('Account 123', null, null, false, 1)[0];
        
        DescribeFieldResult describe = Address__c.Country__c.getDescribe();
        List<PicklistEntry> availableValues = describe.getPicklistValues();
        
        DescribeFieldResult describeState = Address__c.State_Picklist__c.getDescribe();
        List<PicklistEntry> stateAvailableValues = describeState.getPicklistValues();
        
        Address__c businessLocationObj = TestDataUtility.createBusinessLocation(new List<Account>{accObj}, 'BL1', 'City1', stateAvailableValues[0].getValue(), '1111111', '88888888888', 'US', 1)[0];
        
        Contact con= TestDataUtility.createContact(null, null, new List<Address__c>{businessLocationObj}, null, 'Test con1',
                                                   'contact@email.com', '99999999999', false, null, 1)[0];
        
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        Update standardPricebook;
        
        Opportunity opp = TestDataUtility.createOpportunity(null, null, 'Opp1', con, accObj, ConstantClass.PROPOSAL_PRICE_QUOTE_OPP_STAGE, 
                                                            null, System.today(), System.today(), 'CrowleyFresh', null, false, 1)[0];
        
        System.assertEquals(opp.StageName, ConstantClass.PROPOSAL_PRICE_QUOTE_OPP_STAGE);
        
        EmailMessage outGoingMail= TestDataUtility.createEmailMessage('test@test.com', con.Email, 'This is the message subject.', 'This is the message body. Send Quote '+opp.Id, opp.id);  
        
        Test.startTest();
        System.assertEquals(opp.Id, outGoingMail.RelatedToId);
        System.assertEquals(outGoingMail.TextBody.contains('Send Quote '+opp.Id), true);
        Test.stopTest();
    }
    
    static testMethod void resolvingCaseOnEmail(){
        List<Account> accs = TestDataUtility.createAccount('TestAccount', 'Crowley', null, false, 1);
        List<Case> cases = TestDataUtility.createCase(accs[0].Id, 'Web', Userinfo.getUserId(), 'Open', 1);
        List<RecordType> rts = [Select Id, Name From RecordType Where Name='BL Revision' limit 1];
        if(!rts.isEmpty()){
        	cases[0].RecordTypeId = rts[0].Id;   
            cases[0].Case_Auto_Close__c = true;
            cases[0].Status = 'Resolving Case';
            cases[0].BL_Resolution_Category__c = 'No correction needed';
            update cases[0]; 
            Test.startTest();
            EmailMessage outGoingMail= TestDataUtility.createEmailMessage('test@test.com', 'test@test.com', 'This is the message subject.', 'This is the message body. Send Quote '+cases[0].Id, cases[0].id);  
            System.assertEquals(cases[0].Id, outGoingMail.RelatedToId);
            System.assertEquals(outGoingMail.TextBody.contains('Send Quote '+cases[0].Id), true);
        }
        
        Test.stopTest();
        
    }
}