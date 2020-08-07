/*
* Name: AccountTriggerHandler_Test
* Purpose: Test class for AccountTriggerHandler.
* Author: Nagarro
* Created Date: 11-Sept-2018
* Modification History
*  Modification #   Story/Defect#      Modified By     Date   Description
*/
@IsTest
public class AccountTriggerHandler_Test {
    
    @testSetup static void dataSetup(){
        
         Governance_Team_Fields__c objGTF = new Governance_Team_Fields__c(name='1', FIELD_LABEL_NAME__C = 'Parent Account', FIELD_API_NAME__C = 'ParentId',
                                                                        OBJECT_NAME__C = 'Account', DATA_TYPE__C = 'Lookup', LOOKUP_RELATIONSHIP_WITH__C = 'Account');
        insert objGTF;
        //TestDataUtility.CustomSettingData();
    }
    
    static testMethod void accountTriggerHandler_TestMethod()
    {
        ProfileNames__c p1 = new ProfileNames__c();
        p1.Name = 'Sales Leader';
        insert p1;
        
        ProfileNames__c p2 = new ProfileNames__c();
        p2.Name = 'System Administrator';
        insert p2;
        
        //TestDataUtility.CustomSettingData();
        Account accObj1 = TestDataUtility.createAccount('Account 123', null, null, false, 1)[0];
        
        
        DescribeFieldResult describe = Address__c.Country__c.getDescribe();
        List<PicklistEntry> availableValues = describe.getPicklistValues();
        
        DescribeFieldResult describeState = Address__c.State_Picklist__c.getDescribe();
        List<PicklistEntry> stateAvailableValues = describeState.getPicklistValues();
        
        Address__c businessLocationObj = TestDataUtility.createBusinessLocation(new List<Account>{accObj1}, 'BL1', 'City1', stateAvailableValues[0].getValue(), '1111111', '88888888888', 'US', 1)[0];
        
        Contact con = TestDataUtility.createContact(null, accObj1.Id, new List<Address__c>{businessLocationObj}, null, 'Test con1',
                                                    'contact@email.com', '(99999999999', true, null, 1)[0];
        
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        Update standardPricebook;
        
        Opportunity opp = TestDataUtility.createOpportunity(null, null, 'Opp1', con, accObj1, 'Prospecting', null, System.today(), null, 'Air', null, false, 1)[0];
        
        Account accObj2 = new Account();
        accObj2.Name = 'Acc 1234';
        accObj2.Type = 'Customer';
        accObj2.Address_Line_1__c = 'Address_Line 1';  
        accObj2.City__c = 'City';  
        accObj2.Country__c = 'AF';
        accObj2.Phone = '-123456789(01)'; 
        insert accObj2;
        accObj2.Phone = '-123456789(01'; 
        
        Account accObj3 = new Account();
        accObj3.Name = 'Acc 1234';
        accObj3.Type = 'Customer';
        accObj3.Address_Line_1__c = 'Address_Line 1';  
        accObj3.City__c = 'City';  
        accObj3.Country__c = 'AF';
        accObj3.CVIF__c = '1234';
        accObj3.Phone = '-123456789(01)'; 
        accObj3.Created_from_Lead_Conversion__c = true;
        insert accObj3;
        
        
        List<Account> accListToDelete = new List<Account>();
        accListToDelete.add(accObj1);
        accListToDelete.add(accObj2);
        accListToDelete.add(accObj3);
        update accListToDelete;
        
        test.startTest();
        System.assertNotEquals(opp.AccountId, NULL);
        System.assertEquals(businessLocationObj.Account__c, opp.AccountId);
        
        try
        {
            delete accListToDelete;
        }
        catch(Exception e)
        {
            System.debug('Exception in Account Test Class'+e.getMessage());
        }
        test.stopTest();
    }
    
    static testMethod void testCreateTrackHistoryRecord() {
        List<Account> accList = TestDataUtility.createAccounts('Test Account', 'Customer', null, null, false, 2);
        List<Account> lstAccount = [SELECT Id FROM Account];
        Account objPrntAcc = lstAccount[0];
        Account objChldAcc = lstAccount[1];
        objChldAcc.ParentId = objPrntAcc.Id;
        update objChldAcc;
        for( Track_History__c objTrackHistory : [SELECT Previous_Value__c, New_Value__c FROM Track_History__c WHERE Object_Name__c = 'Account' AND Operation__c = 'Modified' ORDER BY CreatedDate DESC]) {
            System.assert(objTrackHistory.Previous_Value__c ==  null);
            System.assert(objTrackHistory.New_Value__c ==  'Test Account');
        }
    }
    
    static testMethod void testDeleteAccounts(){
        ProfileNames__c p1 = new ProfileNames__c();
        p1.Name = 'Sales Leader';
        insert p1;
        
        ProfileNames__c p2 = new ProfileNames__c();
        p2.Name = 'System Administrator';
        insert p2;
        
        ProfileNames__c p3 = new ProfileNames__c();
        p3.Name = 'Data Steward';
        insert p3;
        
        Account accObj1 = TestDataUtility.createAccount('Account 123', null, null, false, 1)[0];
        
        
        DescribeFieldResult describe = Address__c.Country__c.getDescribe();
        List<PicklistEntry> availableValues = describe.getPicklistValues();
        
        DescribeFieldResult describeState = Address__c.State_Picklist__c.getDescribe();
        List<PicklistEntry> stateAvailableValues = describeState.getPicklistValues();
        
        Address__c businessLocationObj = TestDataUtility.createBusinessLocation(new List<Account>{accObj1}, 'BL1', 'City1', stateAvailableValues[0].getValue(), '1111111', '88888888888', 'US', 1)[0];
        
        Contact con = TestDataUtility.createContact(null, accObj1.Id, new List<Address__c>{businessLocationObj}, null, 'Test con1',
                                                    'contact@email.com', '(99999999999', true, null, 1)[0];
        
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        Update standardPricebook;
        
        Opportunity opp = TestDataUtility.createOpportunity(null, null, 'Opp1', con, accObj1, 'Prospecting', null, System.today(), null, 'Air', null, false, 1)[0];
        
        Account accObj2 = new Account();
        accObj2.Name = 'Acc 1234';
        accObj2.Type = 'Customer';
        accObj2.Address_Line_1__c = 'Address_Line 1';  
        accObj2.City__c = 'City';  
        accObj2.Country__c = 'AF';
        accObj2.Phone = '-123456789(01)'; 
        insert accObj2;
        accObj2.Phone = '-123456789(01'; 
        
        Account accObj3 = new Account();
        accObj3.Name = 'Acc 1234';
        accObj3.Type = 'Customer';
        accObj3.Address_Line_1__c = 'Address_Line 1';  
        accObj3.City__c = 'City';  
        accObj3.Country__c = 'AF';
        accObj3.CVIF__c = '1234';
        accObj3.Phone = '-123456789(01)'; 
        accObj3.Created_from_Lead_Conversion__c = true;
        insert accObj3;
        
        
        List<Account> accListToDelete = new List<Account>();
        accListToDelete.add(accObj1);
        accListToDelete.add(accObj2);
        accListToDelete.add(accObj3);
        update accListToDelete;
        
        test.startTest();
        System.assertNotEquals(opp.AccountId, NULL);
        System.assertEquals(businessLocationObj.Account__c, opp.AccountId);
        
        Profile p11 = [SELECT Id FROM Profile WHERE Name='Data Steward']; 
        User u1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p11.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');
        Profile p22 = [SELECT Id FROM Profile WHERE Name='Sales Leader']; 
        User u2 = new User(Alias = 'standt1', Email='standarduser1@testorg.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p22.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser1@testorg.com');
        
        try
        {
            System.runAs(u1){
                delete accListToDelete;
            }
            System.runAs(u2){
                delete accListToDelete;
            }
        }
        catch(Exception e)
        {
            System.debug('Exception in Account Test Class'+e.getMessage());
        }
        test.stopTest();
    }
}