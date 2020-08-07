@isTest
public class AccountTeamTriggerHandler_Test {
    
    @testSetup static void dataSetup(){
        
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1].Id;
        Id profileId2 = [SELECT Id FROM Profile WHERE Name = 'Sales Rep' Limit 1].Id;
        
        User u1 = TestDataUtility.createUser(null, profileId, null, 'User1', 'approvalUser1@test.com', 
                                             'en_US', 'en_US', 'UTF-8', 'America/Los_Angeles', null);
        
        User u2 = TestDataUtility.createUser(null, profileId2, null, 'User2', 'approvalUser2@test.com', 
                                             'en_US', 'en_US', 'UTF-8', 'America/Los_Angeles',null);
        u2.region__c = 'PRT - Puerto Rico';
        
        update u2;
        
        User u3 = TestDataUtility.createUser(null, profileId2, null, 'User3', 'approvalUser3@test.com', 
                                             'en_US', 'en_US', 'UTF-8', 'America/Los_Angeles',null);
        
        u3.region__c = 'TRK - Trucking Team';
        
        update u3;
        
        
        System.runAs(u2){
            
            Account acc = TestDataUtility.createAccounts('Test Account Team53254**&&', 'Customer', null, null, false, 1)[0];
            
            List<User_Region_to_Opp_Role__c> customSetting = [Select Id from User_Region_to_Opp_Role__c];
            
            delete customSetting;
            
            Account accChild = TestDataUtility.createAccounts('Account Team Child324', 'Prospect', 'Beverages', acc.Id, false, 1)[0];
            
            DescribeFieldResult describe = Address__c.Country__c.getDescribe();
            List<PicklistEntry> availableValues = describe.getPicklistValues();
            
            DescribeFieldResult describeState = Address__c.State_Picklist__c.getDescribe();
            List<PicklistEntry> stateAvailableValues = describeState.getPicklistValues(); 
            
            Opportunity_Split_Constant__mdt objOpportunitySplitCustomMetadata = [SELECT Trigger_Handlers__c FROM Opportunity_Split_Constant__mdt WHERE DeveloperName = 'Bypass_Handlers' LIMIT 1];
            for(String strHandlerToBypass : new List<String>{'AddressTriggerHandler','ContactTriggerHandler'}) {
                TriggerHandler.bypass(strHandlerToBypass);
            }
            
            Address__c businessLocationObj = TestDataUtility.createBusinessLocation(new List<Account>{acc}, 'BL1', 'City1', stateAvailableValues[0].getValue(), '1111111', '88888888888', 'US', 1)[0];
            
            Contact con = TestDataUtility.createContact(null, acc.Id, new List<Address__c>{businessLocationObj}, null, 'Test con1',
                                                        'contact@email.com', '(99999999999', true, null, 1)[0];
            
            
            for(String strHandlerToBypass : new List<String>{'AddressTriggerHandler','ContactTriggerHandler'}) {
                TriggerHandler.clearBypass(strHandlerToBypass);
            }
            /* AccountTeamMember atm2 = TestDataUtility.createAccountTeamMember('Edit', 'Edit', 
'Edit', 'Edit', 
new List<Account>{acc}, 
new List<User>{u2}, new List<String>{'PRT - Sales Rep'})[0]; */
        }
        
        
        //TestDataUtility.CustomSettingData();
        //List<Account> accList = TestDataUtility.createAccounts('Test data account team', 'Prospect', null, null, false, 1);
    }
    
    static testmethod void accountTeamTriggerHandler_TestMethodInsert(){
        
        
        List<User> userList = new List<User>();
        List<String> roleList = new List<String>();
        
        User u1 = [Select Id, Name, Region__c, Email,profile.Name   from User Where Name = 'User1'];
        User u2 = [Select Id, Name, Region__c, Email, profile.Name  from User Where Name = 'User2'];
        User u3 = [Select Id, Name, Region__c, Email, profile.Name  from User Where Name = 'User3'];
        Account acc = [Select Id, Name from Account Where Name = 'Test Account Team53254**&&'];
        try{
            System.runAs(u2){
                Test.startTest();
                
                AccountTeamMember atm = TestDataUtility.createAccountTeamMember('Edit', 'Edit', 
                                                                                'Edit', 'Edit', 
                                                                                new List<Account>{acc}, 
                                                                                new List<User>{u1,u2}, new List<String>{'Contracts','PRT - Sales Rep'})[0];
                Test.stopTest();
                
                
                //Test.startTest();
                
                //AccountTeamMember atm3 = TestDataUtility.createAccountTeamMember('Edit', 'Edit', 
                //                                                                 'Edit', 'Edit', 
                //                                                                 new List<Account>{accChild}, 
                //                                                                 new List<User>{u3}, new List<String>{'TRK - Sales Rep'})[0];  
            }
            
            
        }
        catch(Exception e){
            
            System.debug('Exception in Account Test Class'+e.getMessage());
        }
        
    } 
    
    static testmethod void accountTeamTriggerHandler_TestMethodUpdate(){
        
        User u1 = [Select Id, Name, Region__c, Email,profile.Name   from User Where Name = 'User1'];
        User u2 = [Select Id, Name, Region__c, Email, profile.Name  from User Where Name = 'User2'];
        User u3 = [Select Id, Name, Region__c, Email, profile.Name  from User Where Name = 'User3'];
        
        AccountTeamMember atm = [Select Id, TeamMemberRole from AccountTeamMember where Account.Name = 'Test Account Team53254**&&' LIMIT 1];
        //AccountTeamMember atmChild = [Select Id, TeamMemberRole from AccountTeamMember where Account.Name = 'Account Team Child324' LIMIT 1];
        
        try{
            System.runAs(u3){
                
                atm.TeamMemberRole = 'USA - Sales Rep';
                
                update atm;
                //delete atmChild;
            }
        }
        catch(Exception e){
            
            System.debug('Exception message'+e.getMessage());
        }
    }    
}