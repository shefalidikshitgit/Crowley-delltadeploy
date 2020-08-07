/*
* Name: TestDataUtility
* Purpose: Utility class to create test data
* Author: Nagarro
* Created Date: 15-May-2019
* Modification History
*  Modification #   Story/Defect#      Modified By     Date   Description
*/
@isTest(seeAllData=false)
public class TestDataUtility {
    
    @testSetup public static void CustomSettingData(){
        List<User_Region_to_Opp_Role__c> UserRegionRole = New List<User_Region_to_Opp_Role__c>();
        
        User_Region_to_Opp_Role__c urr1 = new User_Region_to_Opp_Role__c();
        urr1.Name = 'CAM - Central America';
        urr1.Opp_Role__c = 'CAM - Sales Rep';        
        UserRegionRole.add(urr1);
        //insert UserRegionRole;
        
        User_Region_to_Opp_Role__c urr2 = new User_Region_to_Opp_Role__c();
        urr2.Name = 'PRT - Puerto Rico';
        urr2.Opp_Role__c = 'PRT - Sales Rep';        
        UserRegionRole.add(urr2);
        //insert UserRegionRole;
        
        User_Region_to_Opp_Role__c urr3 = new User_Region_to_Opp_Role__c();
        urr3.Name = 'CAR - Caribbean';
        urr3.Opp_Role__c = 'CAR - Sales Rep';        
        UserRegionRole.add(urr3);
        //insert UserRegionRole;
        
        User_Region_to_Opp_Role__c urr4 = new User_Region_to_Opp_Role__c();
        urr4.Name = 'TRK - Trucking Team';
        urr4.Opp_Role__c = 'TRK – Sales Rep';        
        UserRegionRole.add(urr4);
        // insert UserRegionRole;
        
        User_Region_to_Opp_Role__c urr5 = new User_Region_to_Opp_Role__c();
        urr5.Name = 'USA - United States';
        urr5.Opp_Role__c = 'USA - Sales Rep';        
        UserRegionRole.add(urr5);
        
        insert UserRegionRole;
        
        
       /* Access_Level_MM_SA__c accessLevels = new Access_Level_MM_SA__c();
        accessLevels.MM_Account_Level__c ='Edit';
        accessLevels.MM_Opp_Level__c ='Edit';
        accessLevels.MM_Case_Level__c='None';
        accessLevels.SA_Account_Level__c='Read';
        accessLevels.SA_Opp_Level__c='None';
        accessLevels.SA_Case_Level__c='None';        
        insert accessLevels;*/
    }
    /*
* Method Name: createAccount
* Input Parameters: 
* String strAccountName: This holds account name.
* String strIndustry : This holds industry name.
* Id idParent : This holds parent account id.
* Boolean boolCreatedFromLeadConversion : Specifies whether account has been created by lead conversion.
* Integer intNumberOfAccounts : This holds number of accounts to be created.
* Return value: List<Account>
* Purpose: This method creates accounts as per parameters provided and returns the created accounts list.
*/
    public static List<Account> createAccount(String strAccountName, String strIndustry, Id idParent, Boolean boolCreatedFromLeadConversion, Integer intNumberOfAccounts) {
        
        
        List<Account> listTestAccount = new List<Account>();
        CustomSettingData();
        Account objAccount = new Account();
        for(Integer intIndex = 0; intIndex < intNumberOfAccounts; intIndex++) {
            
            objAccount.name = (intIndex == 0 ? strAccountName : strAccountName + intIndex);
            objAccount.Industry = strIndustry;
            objAccount.ParentId = idParent;
            objAccount.Phone = '-123456789(01)';  
            objAccount.Address_Line_1__c = 'Address_Line 1';  
            objAccount.City__c = 'City';  
            objAccount.Country__c = 'AF';  
            //objAccount.State__c = 'AL';  
            objAccount.Created_From_Lead_Conversion__c = boolCreatedFromLeadConversion;
            listTestAccount.add(objAccount);
            
        }
        
        DescribeFieldResult describeState = Address__c.State_Picklist__c.getDescribe();
        List<PicklistEntry> stateAvailableValues = describeState.getPicklistValues();
        insert listTestAccount;

        Address__c businessLocationObj = TestDataUtility.createBusinessLocation(new List<Account>{objAccount}, 'BL1', 'City1', stateAvailableValues[0].getValue(), '1111111', '88888888888', 'US', 1)[0];
        
        
        return listTestAccount;
    }
    
    /*
* Method Name: createAccount
* Input Parameters: 
* String strAccountName: This holds account name.
* Id idOwner : This holds owner id.
* Id idProposedOwner : This holds proposed owner id.
* String strApprovalProccessAction : This holds approval process action.
* Integer intNumberOfAccounts : This holds number of accounts to be created.
* Return value: List<Account>
* Purpose: This overloaded method creates accounts as per parameters provided and returns the created accounts list.
*/
    public static List<Account> createAccount(String strAccountName, Id idOwner, Id idProposedOwner, String strApprovalProccessAction, Integer intNumberOfAccounts) {
        CustomSettingData();
        List<Account> listTestAccount = new List<Account>();
        for(Integer intIndex = 0; intIndex < intNumberOfAccounts; intIndex++) {
            Account objAccount = new Account();
            objAccount.name = (intIndex == 0 ? strAccountName : strAccountName + intIndex);
            objAccount.OwnerId = (idOwner != null ? idOwner : UserInfo.getUserId()) ;            
            objAccount.Phone = '-123456789(0)';
            objAccount.Address_Line_1__c = 'Address_Line 1';  
            objAccount.City__c = 'City';  
            objAccount.Country__c = 'AF';  
            //objAccount.State__c = 'AL';            
            objAccount.userWhoProposedNewOwner__c = idOwner;
            objAccount.Proposed_Account_Owner__c = idProposedOwner;
            objAccount.Transfer_Closed_Opportunities__c = TRUE;
            objAccount.Transfer_Not_Owned_Opportunities__c = TRUE;
            objAccount.Transfer_Open_Cases__c = TRUE;
            objAccount.Transfer_Closed_Cases__c = TRUE;
            objAccount.Keep_Account_Team__c = TRUE;
            objAccount.Keep_Opportunity_Team__c = TRUE;            
            objAccount.Approval_Process_Action__c = strApprovalProccessAction;
            objAccount.TimeofStep1Approval__c = System.now();
            objAccount.TimeofStep2Approval__c = System.now()+1;
            objAccount.TimeofStep3Approval__c = null;
            listTestAccount.add(objAccount);
        }
        insert listTestAccount;
        return listTestAccount;
    }
    
    /*
    * Method Name: createAccounts
    * Input Parameters: 
    * String strAccountName: This holds account name.
    * String strType : this holds Account type.
    * String strIndustry : This holds industry name.
    * Id idParent : This holds parent account id.
    * Boolean boolCreatedFromLeadConversion : Specifies whether account has been created by lead conversion.
    * Integer intNumberOfAccounts : This holds number of accounts to be created.
    * Return value: List<Account>
    * Purpose: This method creates accounts as per parameters provided and returns the created accounts list.
    */
    public static List<Account> createAccounts(String strAccountName, String strType, String strIndustry, Id idParent, Boolean boolCreatedFromLeadConversion, Integer intNumberOfAccounts) {
        
        CustomSettingData();
        List<Account> listTestAccount = new List<Account>();
        for(Integer intIndex = 0; intIndex < intNumberOfAccounts; intIndex++) {
            Account objAccount = new Account();
            objAccount.name = (intIndex == 0 ? strAccountName : strAccountName + intIndex);
            objAccount.Industry = strIndustry;
            objAccount.ParentId = idParent;
            objAccount.Created_From_Lead_Conversion__c = boolCreatedFromLeadConversion;
            objAccount.Type = strType;
            objAccount.Address_Line_1__c = 'Address_Line 1';  
            objAccount.City__c = 'City';  
            objAccount.Country__c = 'AF';
            listTestAccount.add(objAccount);
        }
        insert listTestAccount;
        return listTestAccount;
    }
    
     /*
    * Method Name: createAccounts
    * Input Parameters: 
    * String strAccountName: This holds account name.
    * String strIndustry : This holds industry name.
    * Id idParent : This holds parent account id.
    * Boolean boolCreatedFromLeadConversion : Specifies whether account has been created by lead conversion.
    * Integer intNumberOfAccounts : This holds number of accounts to be created.
    * Return value: List<Account>
    * Purpose: This method creates accounts as per parameters provided and returns the created accounts list.
    */
    public static List<Account> createAccounts(String strAccountName, String strIndustry, Id idParent, Boolean boolCreatedFromLeadConversion, Integer intNumberOfAccounts) {
        CustomSettingData();
        List<Account> listTestAccount = new List<Account>();
        for(Integer intIndex = 0; intIndex < intNumberOfAccounts; intIndex++) {
            Account objAccount = new Account();
            objAccount.name = (intIndex == 0 ? strAccountName : strAccountName + intIndex);
            objAccount.Industry = strIndustry;
            objAccount.ParentId = idParent;
            objAccount.Phone = '-123456789(0)';
            objAccount.Address_Line_1__c = 'Address_Line 1';  
            objAccount.City__c = 'City';  
            objAccount.Country__c = 'AF';
            objAccount.Created_From_Lead_Conversion__c = boolCreatedFromLeadConversion;
            listTestAccount.add(objAccount);
        }
        insert listTestAccount;
        return listTestAccount;
    }
    
    /*
* Method Name: createBusinessLocation
* Input Parameters: 
* List<Account> listAccounts: This holds accounts.
* String strBlName : This holds business location name.
* String strCity : This holds business location city.
* String strState : This holds business location state.
* String strPostalCode : This holds business location postal code.
* String strPhone : This holds phone number.
* String strCountry : This holds business location country.
* Integer intNumberOfAccounts : This holds number of BL to be created.
* Return value: List<Address__c>
* Purpose: This method creates Business location as per parameters provided and returns the created BL list.
*/
    public static List<Address__c> createBusinessLocation(List<Account> listAccounts, String strBlName, String strCity, String strState, String strPostalCode, String strPhone, String strCountry, Integer intNumberOfBusinessLocations) {
        List<Address__c> listTestAddress = new List<Address__c>();
        for(Account objAccount : listAccounts) {
            System.debug('TestDataUtility = ');
            System.debug('objAccount = ' + objAccount);
            System.debug('objAccount.Id = ' + objAccount.Id);
            System.debug('objAccount.Name = ' + objAccount.Name);
            for(Integer intIndex = 0; intIndex < intNumberOfBusinessLocations; intIndex++) {
                Address__c objAddress = new Address__c();
                objAddress.Account__c = objAccount.Id;
                //objAddress.Account_Name__c = objAccount.Name;
                objAddress.Name = (intIndex == 0 ? strBlName : strBlName + intIndex);
                objAddress.City__c = strCity;
                objAddress.State_Picklist__c = strState;
                objAddress.Postal_Code__c = strPostalCode;
                objAddress.Country__c = strCountry;
                objAddress.Phone__c = strPhone;
                listTestAddress.add(objAddress);
            } 
        }   
        insert listTestAddress;
        return listTestAddress;
    }
    
    /*
* Method Name: createContact
* Input Parameters:
* Id idRecordType : This holds record type id. 
* Id idAccount : This holds account id.
* List<Address__c> listBusinessLocations: This holds business locations.
* String strFirstName : This holds contact first name.
* String strLastName : This holds contact last name.
* String strEmail : This holds contact email.
* String strPhone : This holds phone number.
* Boolean boolContactCreatedFromLead : Specifies whether contact has been created by lead conversion.
* Id IdOwner : This holds contact owner id.
* Integer intNumberOfContacts : This holds number of contacts to be created.
* Return value: List<Contact>
* Purpose: This method creates Contact as per parameters provided and returns the created Contact list.
*/
    public static List<Contact> createContact(Id idRecordType, Id idAccount, List<Address__c> listBusinessLocations, String strFirstName, String strLastName, String strEmail, String strPhone, Boolean boolContactCreatedFromLead, Id IdOwner, Integer intNumberOfContacts) {
        List<Contact> listTestContact = new List<Contact>();
        for(Address__c objAddress : listBusinessLocations) {
            for(Integer intIndex = 0; intIndex < intNumberOfContacts; intIndex++) {
                Contact objContact = new Contact();
                objContact.Address__c = objAddress.Id;
                objContact.FirstName =  strFirstName + intIndex;
                objContact.LastName = strLastName;
                objContact.Email = strEmail;
                objContact.Phone = '-123456789(01)';
                objContact.MobilePhone = '-123456789(01)';
                objContact.Locations_Served__c = 'UNITED STATES';
                objContact.Contact_Created_From_Lead__c = boolContactCreatedFromLead;
                if(idRecordType != null) {
                    objContact.RecordTypeId = idRecordType;   
                }
                if(IdOwner != null) {
                    objContact.OwnerId = IdOwner;
                }
                objContact.AccountId = idAccount;
                listTestContact.add(objContact);
            } 
        }   
        insert listTestContact;
        return listTestContact;
    }
    
    /*
* Method Name: createOpportunity
* Input Parameters: 
* Id idRecordType: This holds Opportunity recordType.
* String strOppName : This holds Opportunity name.
* Contact objContact : This holds contact to be associated with opportunity.
* Account objAccount : This holds account to be associated with opportunity.
* String strStageName : This holds opportunity stage name.
* String strRegion : This holds opportunity region.
* Date dateClose : This holds opportunity close date.
* String strServiceType : This holds opportunity service types.
* String strPricingTeamEmailPicklist : This holds pricing team email picklist.
* Boolean boolCreatedFromLeadConversion : This specifies whether opportunity is created from lead conversion or not.
* Integer intNumberOfOpportunities : This holds number of opportunities to be created.
* Return value: List<Opportunity>
* Purpose: This method creates Opportunities as per parameters provided and returns the created Opportunities list.
*/
    public static List<Opportunity> createOpportunity(Id idRecordType, Id idOwner, String strOppName, Contact objContact, Account objAccount, String strStageName, String strRegion, Date dateClose, Date dateProposalSubmission, String strServiceType, String strPricingTeamEmailPicklist, Boolean boolCreatedFromLeadConversion, Integer intNumberOfOpportunities) {
        List<Opportunity> listTestOpportunity = new List<Opportunity>();
        //Instantiate the Pricebook2 record with StandardPricebookId
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        
        for(Integer intIndex = 0; intIndex < intNumberOfOpportunities; intIndex++) {
            Opportunity objOpportunity = new Opportunity();
            if(idRecordType != null) {
                objOpportunity.RecordTypeId = idRecordType;   
            }
            if(objContact != null) {
                objOpportunity.Contact__c = objContact.Id;   
            }
            objOpportunity.AccountId = objAccount.Id;
            objOpportunity.StageName = strStageName;
            objOpportunity.Region_Picklist__c = strRegion;
            objOpportunity.Name = (intIndex == 0 ? strOppName : strOppName + intIndex);
            objOpportunity.CloseDate = dateClose;
            objOpportunity.Proposal_Submission_Due_Date__c = dateProposalSubmission;
            objOpportunity.Service_Type__c = strServiceType;
            objOpportunity.OwnerId = (idOwner != null ? idOwner : UserInfo.getUserId()) ;
            objOpportunity.PricingTeamEmailPicklist__c = strPricingTeamEmailPicklist;
            objOpportunity.Opportunity_Created_from_Lead__c = boolCreatedFromLeadConversion;
            listTestOpportunity.add(objOpportunity);
        }   
        insert listTestOpportunity;
        return listTestOpportunity;
    }
    
    /*
* Method Name: createProduct
* Input Parameters: 
* List<String> listProductName: This holds products name.
* Return value: List<Product2>
* Purpose: This method creates Products and related PricebookEntry.
*/
    public static List<Product2> createProduct(List<String> listProductName) {
        List<Product2> listTestProducts = new List<Product2>();
        List<PricebookEntry> listStandardPrice = new List<PricebookEntry>();
        Id pricebookId;
        
        for(String strProductName : listProductName) {
            Product2 objProduct = new Product2();
            objProduct.Name = strProductName;
            objProduct.ProductCode = strProductName;
            objProduct.IsActive = true;
            listTestProducts.add(objProduct);
        }   
        insert listTestProducts;
        
        //Instantiate the Pricebook2 record with StandardPricebookId
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        Update standardPricebook;
        
        pricebookId = Test.getStandardPricebookId();
        for(Product2 objProduct : listTestProducts) {
            PricebookEntry standardPrice = new PricebookEntry(
                Pricebook2Id = pricebookId, Product2Id = objProduct.Id,
                UnitPrice = 10000, IsActive = true); 
            listStandardPrice.add(standardPrice);
        }
        insert listStandardPrice;
        return listTestProducts;
    }
    
    /*
* Method Name: createOpportunityLineItem
* Input Parameters: 
* Opportunity objOpportunity : This holds Opportunity.
* List<Product2> listProducts : This holds Product list.
* Integer intQuantity : This holds product quantity.
* Integer intUnitPrice : This holds product unit price.
* Return value: List<OpportunityLineItem>
* Purpose: This method creates OpportunityLineItem as per parameters provided and returns the created OpportunityLineItems list.
*/
    public static List<OpportunityLineItem> createOpportunityLineItem(Opportunity objOpportunity, List<Product2> listProducts, Integer intQuantity, Integer intUnitPrice) {
        CreateServiceSubServiceCustomSetting();
        List<OpportunityLineItem> listOpportunityLineItem = new List<OpportunityLineItem>();
        Map<Id, PricebookEntry> mapProductPricebookEntry = new Map<Id, PricebookEntry>();
        
        //Create map of product and PricebookEntry
        for(PricebookEntry objPricebookEntry : [SELECT Id, Product2Id FROM PricebookEntry]) {
            mapProductPricebookEntry.put(objPricebookEntry.Product2Id, objPricebookEntry);
        }
        
        //Create Opportunity LineItems
        for(Product2 objProduct2 : listProducts) {
            OpportunityLineItem objOpportunityLineItem = new OpportunityLineItem();
            objOpportunityLineItem.OpportunityId = objOpportunity.Id;
            objOpportunityLineItem.Product2Id = objProduct2.Id;
            objOpportunityLineItem.Quantity = intQuantity;
            objOpportunityLineItem.UnitPrice = intUnitPrice;
            objOpportunityLineItem.Sub_Services__c = 'Air';
            objOpportunityLineItem.PricebookEntryId = mapProductPricebookEntry.get(objProduct2.Id).Id;
            listOpportunityLineItem.add(objOpportunityLineItem);
        }
        
        insert listOpportunityLineItem;
        return listOpportunityLineItem;
    }
    
    /*
* Method Name: createTask
* Input Parameters: 
* String strType : This holds task type.
* String strSubtype : This holds task subtype.
* String strDescription : This holds task description.
* String strPriority : This holds task priority.
* String strStatus : This holds task status.
* Id IdWhatId : This holds tasks what id.
* String strSubject : This holds tasks subject.
* Date dateActivityDate : This holds tasks date.
* Id idWhoId : This holds whod id.
* Id idOwnerId : This holds owner id.
* Integer intNumberOfTasks : This holds number of tasks to be created.
* Return value: List<Task>
* Purpose: This method creates Task as per parameters provided and returns the created Tasks list.
*/
    public static List<Task> createTask(String strType, String strSubtype, String strDescription, String strPriority, String strStatus, Id IdWhatId, String strSubject, Date dateActivityDate, Id idWhoId, Id idOwnerId, Integer intNumberOfTasks) {
        List<Task> listTasks = new List<Task>();
        
        for(Integer intIndex = 0; intIndex < intNumberOfTasks; intIndex++) {
            Task objTask = new Task();
            objTask.Type = strType;
            objTask.TaskSubtype = strSubtype;
            objTask.Description = strDescription;
            objTask.Priority = strPriority;
            objTask.Status = strStatus;
            objTask.WhatId = IdWhatId;
            objTask.WhoId = idWhoId;
            if(idOwnerId != null) {
                objTask.OwnerId = idOwnerId;   
            }
            objTask.Subject = (intIndex == 0 ? strSubject : strSubject + intIndex);
            objTask.ActivityDate = dateActivityDate;
            listTasks.add(objTask);
        }
        insert listTasks;
        return listTasks;
    }
    
    
    /*
* Method Name: createContentNote
* Input Parameters: 
* String strTitle : This holds note title.
* String strContent : This holds note content.
* Integer intNumberOfTasks : This holds number of content notes to be created.
* Return value: List<ContentNote>
* Purpose: This method creates content notes as per parameters provided and returns the created note list.
*/
    public static List<ContentNote> createContentNote(String strTitle, String strContent, Integer intNumberOfContentNotes) {
        List<ContentNote> listContentNote = new List<ContentNote>();
        
        for(Integer intIndex = 0; intIndex < intNumberOfContentNotes; intIndex++) {
            ContentNote objNote = new ContentNote();
            objNote.Title = (intIndex == 0 ? strTitle : strTitle + intIndex);
            objNote.Content = Blob.valueOf(strContent);
            listContentNote.add(objNote);
        }
        insert listContentNote;
        return listContentNote;
    }
    
    /*
* Method Name: createContentDocumentLink
* Input Parameters: 
* List<Id> listContentDocumentId : This holds content document id list.
* Id idParent : This holds parent id.
* Return value: List<ContentDocumentLink>
* Purpose: This method creates content document link as per parameters provided and returns the created list.
*/
    public static List<ContentDocumentLink> createContentDocumentLink(List<Id> listContentDocumentId, Id idParent) {
        List<ContentDocumentLink> listContentDocumentLink = new List<ContentDocumentLink>();
        for(Id idItr : listContentDocumentId) {
            ContentDocumentLink contentDocumentLinkObj = new ContentDocumentLink();
            contentDocumentLinkObj.contentdocumentid = idItr;
            contentDocumentLinkObj.LinkedEntityId = idParent;
            contentDocumentLinkObj.ShareType= 'V';
            listContentDocumentLink.add(contentDocumentLinkObj);
        }
        insert listContentDocumentLink;
        return listContentDocumentLink;
    }
    
    /*
* Method Name: createUser
* Input Parameters: 
* Id idRoleId : This holds user role id.
* Id idProfId : This holds user profile id.
* String strFirstName : This holds user first name.
* String strLastName : This holds user last name.
* String strEmail : This holds user email.
* String strLocaleSidKey : This holds user locale sid key.
* String strLanguageLocale : This holds user language locale.
* String strEmailEncoding : This holds email encoding key.
* String strTimeZone : This holds user time zone.
* Id IdManager : This holds user manager Id.
* Return value: User
* Purpose: This method creates User as per parameters provided and returns the created User.
*/
    public static User createUser(Id idRoleId, Id idProfId, String strFirstName, String strLastName, String strEmail, 
                                  String strLocaleSidKey, String strLanguageLocale, String strEmailEncoding, String strTimeZone, Id IdManager) {
                                      User objUser = new User();
                                      String orgId = UserInfo.getOrganizationId();
                                      String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
                                      Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
                                      String uniqueName = orgId + dateString + randomInt;
                                      
                                      objUser.FirstName = strFirstName;                             
                                      objUser.LastName = strLastName;
                                      objUser.Email = strEmail;
                                      objUser.Username = uniqueName + '@test' + orgId + '.org';
                                      objUser.CompanyName = 'TEST';
                                      objUser.Title = 'title';
                                      objUser.Alias = uniqueName.substring(18, 23);
                                      objUser.TimeZoneSidKey = strTimeZone;
                                      objUser.EmailEncodingKey = strEmailEncoding;
                                      objUser.LanguageLocaleKey = strLanguageLocale;
                                      objUser.LocaleSidKey = strLocaleSidKey;
                                      objUser.ProfileId = idProfId;
                                      objUser.UserRoleId  = idRoleId;
                                      objUser.ManagerId = IdManager;
                                      
                                      insert objUser;
                                      return objUser;
                                  }
    
    /*
* Method Name: createAccountTeamMember
* Input Parameters: 
* String strAccountAccessLevel : This holds account access level.
* String strCaseAccessLevel : This holds case access level.
* String strContactAccessLevel : This holds contact access level.
* String strOpportunityAccessLevel : This holds Opportunity access level.
* List<Account> listAccount : This holds account list.
* List<User> listUser : This holds user list.
* List<String> listTeamMemberRole : This holds team member role list.
* Return value: AccountTeamMember
* Purpose: This method creates Account team member as per parameters provided and returns the created Account team member.
*/
    public static List<AccountTeamMember> createAccountTeamMember(String strAccountAccessLevel, String strCaseAccessLevel, String strContactAccessLevel, String strOpportunityAccessLevel, List<Account> listAccount, List<User> listUser, List<String> listTeamMemberRole) {
        List<AccountTeamMember> listAccountTeamMember = new List<AccountTeamMember>();
        
        for(Account objAccount : listAccount) {
            for(User objUser : listUser) {
                for(String strTeamMemberRole : listTeamMemberRole) {
                    AccountTeamMember objAccountTeamMember = new AccountTeamMember();
                    objAccountTeamMember.AccountAccessLevel = strAccountAccessLevel;
                    objAccountTeamMember.CaseAccessLevel = strCaseAccessLevel;
                    objAccountTeamMember.ContactAccessLevel = strContactAccessLevel;
                    objAccountTeamMember.OpportunityAccessLevel = strOpportunityAccessLevel;
                    objAccountTeamMember.AccountId = objAccount.Id;
                    objAccountTeamMember.UserId = objUser.Id;
                    objAccountTeamMember.TeamMemberRole = strTeamMemberRole;
                    listAccountTeamMember.add(objAccountTeamMember);
                }
            }  
        }
        
        insert listAccountTeamMember;
        return listAccountTeamMember;
    }
    
    /*
* Method Name: createCase
* Input Parameters: 
* Id IdAccount : This holds account Id.
* String strOrigin : This holds case origin.
* Id idOwner : This holds owner id.
* String strStatus : This holds case status.
* Integer intNumberOfCases : This holds number of case to be created.
* Return value: List<Case>
* Purpose: This method creates cases as per parameters provided and returns the created cases list.
*/
    public static List<Case> createCase(Id IdAccount, String strOrigin, Id idOwner, String strStatus, Integer intNumberOfCases) {
        List<Case> listCase = new List<Case>();
        
        for(Integer intIndex = 0; intIndex < intNumberOfCases; intIndex++) {
            Case objCase = new Case();
            objCase.AccountId = IdAccount;
            objCase.Origin = strOrigin;
            objCase.OwnerId = idOwner;
            objCase.Status = strStatus;
            listCase.add(objCase);
        }
        
        insert listCase;
        return listCase;
    }
    
    /*

    public static List<Case> createCase(Id IdAccount, String recordTypeId, String strOrigin, Id idOwner, String strStatus, Integer intNumberOfCases) {
        List<Case> listCase = new List<Case>();
        
        for(Integer intIndex = 0; intIndex < intNumberOfCases; intIndex++) {
            Case objCase = new Case();
            objCase.AccountId = IdAccount;
            objCase.Origin = strOrigin;
            objCase.OwnerId = idOwner;
            objCase.Status = strStatus;
            objCase.RecordTypeId = recordTypeId;
            listCase.add(objCase);
        }
        
        insert listCase;
        return listCase;
    }  
    */  
    /*
* Method Name: createContract
* Input Parameters: 
* Id IdAccount : This holds account Id.
* Id idOwner : This holds owner id.
* Integer intContractTerm : This holds Contract term.
* Date dateStart : This holds contract start date.
* List<Opportunity> listOpportunity : This holds opportunity list.
* String strStatus : This holds contract status.
* Id idPricebook2 : This holds pricebook id.
* Integer intNumberOfContract : This holds number of Contract to be created.
* Return value: List<Contract>
* Purpose: This method creates Contracts as per parameters provided and returns the created cases list.
*/
    public static List<Contract> createContract(Id IdAccount, Id idOwner, Integer intContractTerm, Date dateStart, List<Opportunity> listOpportunity, String strStatus, Id idPricebook2, Integer intNumberOfContract) {
        List<Contract> listContract = new List<Contract>();
        
        for(Opportunity objOpportunity : listOpportunity) {
            for(Integer intIndex = 0; intIndex < intNumberOfContract; intIndex++) {
                Contract objContract = new Contract();
                objContract.AccountId = IdAccount;
                if(idOwner != null) {
                    objContract.OwnerId = idOwner;   
                }
                objContract.ContractTerm = intContractTerm;
                objContract.Opportunity__c = objOpportunity.id;
                objContract.StartDate = dateStart;
                objContract.Status = strStatus;
                objContract.Pricebook2Id = idPricebook2;
                
                listContract.add(objContract);
            }
        }
        insert listContract;
        return listContract;
    }
    
    
    /*
* Method Name: createOpportunityTeamMember
* Input Parameters: 
* String strOpportunityAccessLevel : This holds opportunity access level.
* List<Opportunity> listOpportunity : This holds Opportunities list.
* List<User> listUser : This holds user list.
* List<String> listTeamMemberRole : This holds team member role list.
* Return value: List<OpportunityTeamMember>
* Purpose: This method creates Opportunity team member as per parameters provided and returns the created Opportunity team member.
*/
    public static List<OpportunityTeamMember> createOpportunityTeamMember(String strOpportunityAccessLevel, List<Opportunity> listOpportunity, List<User> listUser, List<String> listTeamMemberRole) {
        List<OpportunityTeamMember> listOpportunityTeamMember = new List<OpportunityTeamMember>();
        
        for(Opportunity objOpportunity : listOpportunity) {
            for(User objUser : listUser) {
                for(String strTeamMemberRole : listTeamMemberRole) {
                    OpportunityTeamMember objOpportunityTeamMember = new OpportunityTeamMember();
                    objOpportunityTeamMember.OpportunityAccessLevel = strOpportunityAccessLevel;
                    objOpportunityTeamMember.OpportunityId = objOpportunity.Id;
                    objOpportunityTeamMember.UserId = objUser.Id;
                    objOpportunityTeamMember.TeamMemberRole = strTeamMemberRole;
                    listOpportunityTeamMember.add(objOpportunityTeamMember);
                }
            }  
        }
        
        insert listOpportunityTeamMember;
        return listOpportunityTeamMember;
    }
    
    
    /*
* Method Name: createEmailMessage
* Input Parameters: 
* String strFromaddress : This holds from email id.  
* String strToAddress :  This holds to email id. 
* String strSubject : This holds subject.
* String strTextBody : This holds email body.
* Id idRelatedTo : This holds related to body.
* Return value: createEmailMessage
* Purpose: This method creates email message as per parameters provided and returns the created email message.
*/
    public static EmailMessage createEmailMessage(String strFromaddress, String strToAddress, String strSubject, String strTextBody, Id idRelatedTo) {
        
        EmailMessage objOutGoingMail= new EmailMessage();
        objOutGoingMail.fromaddress = strFromaddress;
        objOutGoingMail.toAddress = strToAddress;
        objOutGoingMail.subject = strSubject;
        objOutGoingMail.TextBody= strTextBody;
        objOutGoingMail.RelatedToId = idRelatedTo;
        
        insert objOutGoingMail;
        return objOutGoingMail;
    }
    
    /*
* Method Name: createLead
* Input Parameters: 
* String strFirstName : This holds lead first name.
* String strLastName : This holds loead last name.
* String strEmail : This holds lead email id.
* String strCompany : This holds lead compony.
* String strLeadSource : This holds lead source.
* String strIndustry : This holds lead industry.
* String strServices : This holds lead service.
* String strTitle : This holds lead title.
* Boolean boolFollowup : This specifies whether followup to be taken care for lead or not.
* Id idOwner : This holds lead owner id.
* String strCountry : This holds lead country.
* String strCity : This holds lead city.
* String strState : This holds lead state.
* String strPostalCode : This holds lead postal code.
* String strAddressLine1 : This holds lead address line 1.
* Integer intNumberOfLead : This holds number of lead to be created.
* Return value: List<Lead>
* Purpose: This method creates lead as per parameters provided and returns the created leads list.
*/
    public static List<Lead> createLead(String strFirstName, String strLastName, String strEmail, String strCompany, String strLeadSource, String strIndustry, String strServices, String strTitle, Boolean boolFollowup, Id idOwner, String strCountry, String strCity, String strState, String strPostalCode, String strAddressLine1, Integer intNumberOfLead) {
        List<Lead> listLeads = new List<Lead>();
        
        for(Integer intIndex = 0; intIndex < intNumberOfLead; intIndex++) {
            Lead objLead = new Lead();
            objLead.FirstName = strFirstName;
            objLead.LastName = (intIndex == 0 ? strLastName : strLastName + intIndex);
            objLead.Email = strEmail;
            objLead.Company = strCompany;
            objLead.LeadSource = strLeadSource;
            objLead.Industry = strIndustry;
            objLead.Service__c = strServices;
            objLead.Title = strTitle;
            objLead.Followup__c = boolFollowup;
            objLead.OwnerId = idOwner;
            objLead.Country__c = strCountry;
            objLead.City__c = strCity;
            objLead.State__c = strState;
            objLead.Postal_Code__c = strPostalCode;
            objLead.Address_Line_1__c = strAddressLine1;
            objLead.Phone = '(23456789';
            objLead.MobilePhone = '(23456789';
            listLeads.add(objLead);
        }
        
        insert listLeads;
        return listLeads;
    }
    
    /*
    * Method Name: createInitiative
    * Input Parameters: 
    * String strInitiativeName : This holds initiative name.  
    * Integer intNumberOfRecords :  This holds number of records to be created. 
    * Return value: List<Initiative__c>
    * Purpose: This method creates initiatives and returns records.
    */
    public static List<Initiative__c> createInitiative(String strInitiativeName, Integer intNumberOfRecords) {
        List<Initiative__c> lstInitiative = new List<Initiative__c>();
        for(Integer intIndex = 0; intIndex < intNumberOfRecords; intIndex++) {
            lstInitiative.add(New Initiative__c(
                Name = strInitiativeName + intIndex
            ));    
        }
        
        insert lstInitiative;
        return lstInitiative;
    }
    
    /*
    * Method Name: createInitiativeRelationship
    * Input Parameters: 
    * Id idInitiative : This holds initiative id.  
    * Id idAccount :  This holds account id. 
    * Return value: Goal_Initiative__c
    * Purpose: This method creates initiatives relationship and returns record.
    */
    public static Goal_Initiative__c createInitiativeRelationship(Id idInitiative, Id idAccount) {
        Goal_Initiative__c objGoalInitiative = new Goal_Initiative__c(Name = 'Test', Initiative__c = idInitiative, Account__c = idAccount);
        insert objGoalInitiative;
        return objGoalInitiative;
    }
    
    public static void CreateServiceSubServiceCustomSetting(){
        List<Services_Subservices__c> serviceSubserviceList = new List<Services_Subservices__c>();
        
        Services_Subservices__c subServiceobj = new Services_Subservices__c();
        subServiceobj.Port_Required__c = True;
        subServiceobj.Sub_service_present__c = True;
        subServiceobj.Name = 'Air';
        serviceSubserviceList.add(subServiceobj);
        subServiceobj = new Services_Subservices__c();
        subServiceobj.Port_Required__c = True;
        subServiceobj.Sub_service_present__c = True;
        subServiceobj.Name = 'LCL';
        serviceSubserviceList.add(subServiceobj);
        subServiceobj = new Services_Subservices__c();
        subServiceobj.Port_Required__c = True;
        subServiceobj.Sub_service_present__c = True;
        subServiceobj.Name = 'FCL';
        serviceSubserviceList.add(subServiceobj);
        insert serviceSubserviceList;
    }
    
    public static List<Entitlement> createEntitlement(String strEntitlementName, Id idAccount, Integer intNumOfEntitlements){
        List<Entitlement> entitlements = new List<Entitlement>();
        for(Integer intIndex = 0; intIndex < intNumOfEntitlements; intIndex++) {
            Entitlement entObj = new Entitlement();
            entObj.AccountId = idAccount;
            entObj.Name = strEntitlementName;
            entitlements.add(entObj);
        }       
        insert entitlements;
        return entitlements;
    }
    
    public static List<Case> createCase(Id idRecordType, Id idAccount, Id idContact, Id idParentCase, string strSubject, string strDescription, String strOrigin, Id idOwner, String strStatus, Integer intNumberOfCases) {
        List<Case> listCase = new List<Case>();
        
        for(Integer intIndex = 0; intIndex < intNumberOfCases; intIndex++) {
            Case objCase = new Case();
            objCase.AccountId = IdAccount;
            objCase.Origin = strOrigin;
            objCase.OwnerId = idOwner;
            objCase.Status = strStatus;
            objCase.RecordTypeId = idRecordType;
            objCase.ParentId = idParentCase;
            objCase.ContactId = idContact;
            objCase.Subject = strSubject;
            objCase.Description = strDescription;
            listCase.add(objCase);
        }
        
        insert listCase;
        return listCase;
    }
    
    public static List<Case> createCustomerInquiryCase(Id idAccount, Id idContact, Id idParentCase, string strSubject, string strDescription, String strOrigin, Id idOwner, String strStatus, Integer intNumberOfCases){
        List<Case> cases = new List<Case>();
        for(integer i=0; i<intNumberOfcases; i++){
            
            List<RecordType> recTypes = [Select Id, Name From RecordType Where Name = 'Create Customer Inquiry' Limit 1];
            
            Case cs = new Case();
            cs.RecordTypeId = recTypes[0].Id;
            cs.AccountId = idAccount;
            cs.Subject = strSubject;
            cs.Description = strDescription;
            cs.Origin = strOrigin;
            cs.Request_Type__c = 'NBK';
            cs.SuppliedEmail = 'test@yopmail.com';
            cs.ContactId = idContact;
            cs.Status = 'Open';
            cs.ParentId = idParentCase;
            cs.Resolution__c = 'Information Provided';
            if(string.isNotBlank(idOwner))
                cs.OwnerId = idOwner;
            cases.add(cs);
        }
        insert cases;
        return cases;        
    }
    
    public static List<Case> createBLRevisionCase(Id idAccount, Id idContact, Id idParentCase, string strSubject, string strDescription, String strOrigin, Id idOwner, String strStatus, Integer intNumberOfCases){
        List<Case> cases = new List<Case>();
        for(integer i=0; i<intNumberOfcases; i++){
            
            List<RecordType> recTypes = [Select Id, Name From RecordType Where Name = 'Create BL Revision' Limit 1];
            
            Case cs = new Case();
            cs.RecordTypeId = recTypes[0].Id;
            cs.AccountId = idAccount;
            cs.Subject = strSubject;
            cs.Description = strDescription;
            cs.Origin = strOrigin;
            cs.BOL_Number__c = 'ABCD1234EFGH';
            cs.Destination_Country__c = 'AF';
            cs.ContactId = idContact;
            cs.Status = 'Open';
            cs.ParentId = idParentCase;
            cs.Origin_Country__c = 'AF';
            cs.Shipper_Name__c = idAccount;
            cs.Consignee_Name__c = idAccount;
            cs.Bill_to_Party__c = idAccount;
            cs.Voyage__c = '12345678';
            cs.Assignee_Pricing_Location__c = 'US /Canada To/From Central America';
            cs.Equipment_Type_Size__c = '20\' Dry';
            cs.BL_Resolution_Category__c = 'Parties';
            if(string.isNotBlank(idOwner))
                cs.OwnerId = idOwner;
            cases.add(cs);
        }
        insert cases;
        return cases;        
    }
    
    public static List<Case> createPricingRateIssueCase(Id idAccount, Id idContact, Id idParentCase, string strSubject, string strDescription, String strOrigin, Id idOwner, String strStatus, Integer intNumberOfCases){
        List<Case> cases = new List<Case>();
        for(integer i=0; i<intNumberOfcases; i++){
            
            List<RecordType> recordTypes = [Select Id, Name From RecordType Where Name = 'Create Pricing Rate Issue' Limit 1];
            
            Case cs = new Case();
            cs.RecordTypeId = recordTypes[0].Id;
            cs.AccountId = idAccount;
            cs.Subject = strSubject;
            cs.Description = strDescription;
            cs.Origin = strOrigin;
            cs.BOL_Number__c = 'ABCD1234EFGH';
            cs.ContactId = idContact;
            cs.Status = 'Open';
            cs.ParentId = idParentCase;
            cs.Assignee_Pricing_Location__c = 'US /Canada To/From Central America';
            cs.Equipment_Type_Size__c = '20\' Dry';
            cs.Freight_Type__c = 'BBULK';
            cs.Non_Containerized_Comments__c = '1234567890 1234567890 1234567890 1234567890 1234567890';
            if(string.isNotBlank(idOwner))
                cs.OwnerId = idOwner;
            cs.Issue_Type__c = 'Pricing Issue';
            cs.Resolution_Category__c = 'Contract Renewed';
            cases.add(cs);
        }
        insert cases;
        return cases;        
    }
    
     /*
* Method Name: createEvent
* Input Parameters: 
* String strType : This holds event type.
* String strSubtype : This holds event subtype.
* String strDescription : This holds task description.
* Id IdWhatId : This holds event's what id.
* String strSubject : This holds tasks subject.
* Date dateActivityDate : This holds tasks date.
* Id idWhoId : This holds whod id.
* Id idOwnerId : This holds owner id.
* Integer intNumberOfTasks : This holds number of tasks to be created.
* Return value: List<Task>
* Purpose: This method creates Task as per parameters provided and returns the created Tasks list.
*/
    public static List<Event> createEvent(String strType, String strSubtype, String strDescription, Id IdWhatId, String strSubject, Date dateActivityDate, Datetime activityDateTime, Id idWhoId, Id idOwnerId, Integer minutes, Integer intNumberOfEvents) {
        List<Event> listEvents = new List<Event>();
        
        for(Integer intIndex = 0; intIndex < intNumberOfEvents; intIndex++) {
            Event objEvent = new Event();
            objEvent.Type = strType;
            objEvent.EventSubtype = strSubtype;
            objEvent.Description = strDescription;
            objEvent.DurationInMinutes = minutes;
            objEvent.WhatId = IdWhatId;
            objEvent.WhoId = idWhoId;
            
            if(idOwnerId != null) {
                objEvent.OwnerId = idOwnerId;   
            }
            objEvent.Subject = (intIndex == 0 ? strSubject : strSubject + intIndex);
            objEvent.ActivityDate = dateActivityDate;
            objEvent.ActivityDateTime = activityDateTime;
            listEvents.add(objEvent);
        }
        insert listEvents;
        return listEvents;
    }
    
    //Assign Market Manager Permission Set
    public static boolean assignPermissionSet(User singleUser){
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Permission_Set_For_Marketing_Managers' Limit 1];
        try{
        	insert new PermissionSetAssignment(AssigneeId = singleUser.id, PermissionSetId = ps.Id);
            return true;
        }catch(Exception e){
            return false;
        }
    }
}