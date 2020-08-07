/*
* Name: BusinessLocationHandler_Test
* Purpose: Test class for AddressTriggerHandler.
* Author: Nagarro
* Created Date: 11-Oct-2018
* Modification History
*  Modification #   Story/Defect#      Modified By     Date   Description
*/
@isTest
public class BusinessLocationHandler_Test {
    
    @testSetup static void dataSetup(){
        Governance_Team_Fields__c objGTF = new Governance_Team_Fields__c(name='1', FIELD_LABEL_NAME__C = 'Address Line 1', FIELD_API_NAME__C = 'Address_Line_1__c',
                                                                        OBJECT_NAME__C = 'Business Location', DATA_TYPE__C = 'Text', LOOKUP_RELATIONSHIP_WITH__C = '');
        insert objGTF;
        List<Account> accList = TestDataUtility.createAccounts('Test Account', 'Customer', null, null, false, 1);
        TestDataUtility.createBusinessLocation(accList, 'Test BL', 'Test City', null, null, null, 'IN', 1);
    }
    
    static testMethod void businessLocationHandler_TestMethod()
    { 
        List<User_Region_to_Opp_Role__c> customSetting = [Select Id from User_Region_to_Opp_Role__c];
            
        delete customSetting;
        Account accObj = TestDataUtility.createAccount('Account 123', null, null, false, 1)[0];
        
        DescribeFieldResult describe = Address__c.Country__c.getDescribe();
        List<PicklistEntry> availableValues = describe.getPicklistValues();
        
        DescribeFieldResult describeState = Address__c.State_Picklist__c.getDescribe();
        List<PicklistEntry> stateAvailableValues = describeState.getPicklistValues();
        
        List<Address__c> lstBusinessLocations = TestDataUtility.createBusinessLocation(new List<Account>{accObj}, 'BL1', 'City1', stateAvailableValues[0].getValue(), '1111111', '88888888888', 'US', 2);
        
        
        Contact con= TestDataUtility.createContact(null, null, new List<Address__c>{lstBusinessLocations[0]}, null, 'Test con1',
                                                   'con@email.com', '99999999999', false, null, 1)[0];
        
        List<Address__c> businessLocationListToDelete = new List<Address__c>();
        businessLocationListToDelete.add(lstBusinessLocations[0]);
        businessLocationListToDelete.add(lstBusinessLocations[1]);
        
        test.startTest();
        System.assertNotEquals(lstBusinessLocations[0].Country__c, NULL);
        System.assertNotEquals(lstBusinessLocations[1].Country__c, NULL);
        System.assertNotEquals(lstBusinessLocations[0].Account__c, NULL);
        System.assertEquals(lstBusinessLocations[0].Id, con.Address__c);
        
        try
        {
            delete businessLocationListToDelete;
        }
        catch(Exception e)
        {
            System.debug('Exception in Business Location Test Class'+e.getMessage());
        }
        test.stopTest();
    }
    
    static testMethod void testCreateTrackHistoryRecord(){
        Test.startTest();
        List<Address__c> objAddress = [SELECT Id, Name, Address_Line_1__c FROM Address__c WHERE Address_Line_1__c = 'Test BL'];
        for(Address__c addObj: objAddress){
        
            addObj.Address_Line_1__c = 'Address Line 11';
        }
        update objAddress;
        
        List<Track_History__c> objTrackHistory = [SELECT Previous_Value__c, New_Value__c FROM Track_History__c WHERE Object_Name__c = 'Business Location' AND Operation__c = 'Modified' ORDER BY CreatedDate DESC];
        for(Track_History__c trackHistory: objTrackHistory){
            System.assert(trackHistory.Previous_Value__c ==  'Address Line 1');
            System.assert(trackHistory.New_Value__c ==  'Address Line 11');
        }
        Test.stopTest();
    }
}