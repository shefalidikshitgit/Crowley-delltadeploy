/*
* Name: OpportunityTeamMemberTriggerHandlerTest
* Purpose: Test class for OpportunityTeamMemberTriggerHandler
* Author: Nagarro
* Created Date: 05/04/2020
* Modification History
* Modification #   Story/Defect#      Modified By     Date   Description
*
*/
@isTest
public class OpportunityTeamMemberTriggerHandlerTest {
    
    @testSetup static void setup(){
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
        p1.Name = 'Sales Agent';
        insert p1;
        
        ProfileNames__c p2 = new ProfileNames__c();
        p2.Name = 'System Administrator';
        insert p2;
        
        Id salesAgentProfileId = [SELECT Id FROM Profile WHERE Name = 'Sales Agent' Limit 1].Id;
        
        User salesAgent = TestDataUtility.createUser(null, salesAgentProfileId, null, 'Agent', 'salesagent1@test.com', 
                                             'en_US', 'en_US', 'UTF-8', 'America/Los_Angeles', null);
        Opportunity opp1 = TestDataUtility.createOpportunity(null, null, 'Opp1', con, accObj1, ConstantClass.PROSPECTING_OPP_STAGE, null, System.today(), null, 'CrowleyFresh;', null, true, 1)[0];
        
        Contract contractObj = TestDataUtility.createContract(accObj1.Id, null, 2, System.today(), new List<Opportunity>{opp1}, 'Draft', [SELECT Id FROM Pricebook2][0].Id, 1)[0];

    }
    static testMethod void addOpportunityTeamMemberTest(){
        
        User salesAgent =[Select Id from User where name='Agent'];
                
        Test.startTest();
        List<Opportunity> oppList = [Select Id from Opportunity];
        
        OpportunityTeamMember oppTeamMem = new OpportunityTeamMember();
        oppTeamMem.OpportunityId = oppList[0].Id;
        oppTeamMem.OpportunityAccessLevel = 'Read';
        oppTeamMem.TeamMemberRole = 'Sales Agent';
        oppTeamMem.UserId = salesAgent.Id;
        
        insert oppTeamMem;
        
        oppTeamMem.OpportunityAccessLevel = 'Edit';
        update oppTeamMem;
        
        
        Test.stopTest();
    }

}