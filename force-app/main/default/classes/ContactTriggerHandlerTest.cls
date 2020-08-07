/*
* Name: ContactTriggerHandlerTest
* Purpose: Test class for ContactTriggerHandler.
* Author: Nagarro
* Created Date: 11-Sept-2018
* Modification History
*  Modification #   Story/Defect#      Modified By     Date   Description
*/
@IsTest
public class ContactTriggerHandlerTest {
    
    @isTest private static void contactTriggerHandler_TestMethod(){    
        
        ProfileNames__c p1 = new ProfileNames__c();
        p1.Name = 'Sales Leader';
        insert p1;
        
        ProfileNames__c p2 = new ProfileNames__c();
        p2.Name = 'System Administrator';
        insert p2;
        
        List<Account> lstAccObj = TestDataUtility.createAccount('Account 123', null, null, TRUE, 1);
        
        GovernanceTeamEmail__c govEmail = new GovernanceTeamEmail__c();
        govEmail.Name = 'test@test.com';
        insert govEmail;
        
        DescribeFieldResult describe = Address__c.Country__c.getDescribe();
        List<PicklistEntry> availableValues = describe.getPicklistValues();
        
        DescribeFieldResult describeState = Address__c.State_Picklist__c.getDescribe();
        List<PicklistEntry> stateAvailableValues = describeState.getPicklistValues();
        
        List<Address__c> lstBusinessLocationObj = TestDataUtility.createBusinessLocation(lstAccObj, 'BL1', 'City1', stateAvailableValues[0].getValue(), '1111111', '88888888888', 'US', 1);
        System.assertNotEquals(NULL, lstBusinessLocationObj[0].Country__c);
        
        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Create_Record').getRecordTypeId();
        System.assertNotEquals(NULL, recordTypeId);
        
        Contact con = TestDataUtility.createContact(recordTypeId, null, lstBusinessLocationObj, null, 'Test con1', 'contact@email.com', '99999999999', true, null, 1)[0];
        System.assertEquals(lstBusinessLocationObj[0].Id, con.Address__c);
        
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        Update standardPricebook;
        
        Opportunity opp = TestDataUtility.createOpportunity(null, null, 'Opp1', con, 
                                                            lstAccObj[0], 'Prospecting', null, System.today(), 
                                                            null, 'Air', null, false, 1)[0];
        
        List<Contact> conListToDelete = new List<Contact>();
        conListToDelete.add(con);
        
        test.startTest();
        System.assertNotEquals(NULL, opp);
        try
        {
            delete conListToDelete;
        }
        catch(Exception e)
        {
            System.debug('Exception in Contact Test Class'+e.getMessage());
        }
        test.stopTest();
        
    }
}