/*
* Name: AccountOwnerChangeHelper_V2
* Purpose: Helper class for Account Owner Change Process. It is called from AccountTriggerHandler class.
* Author: Nagarro
*
*/

public without sharing class AccountOwnerChangeHelper_V2 {
    
    public static Boolean preventPreviousOwnerUpdate = false;
    public static Boolean boolOwnerChangeRan = false;
    public static Map<Id,List<AccountTeamMember>> insertedAccMemberMap = new Map<Id,List<AccountTeamMember>>();
    
    public static Map<Id,List<AccountTeamMember>> updatedAccMemberMap = new Map<Id,List<AccountTeamMember>>();
    
    public static Map<Id,List<AccountTeamMember>> deletedAccMemberMap = new Map<Id,List<AccountTeamMember>>();
    
    public static Map<Id, Id> mapAccountToOldOwnerId = new Map<Id, Id>();
    
    /*
* Method Name : handleOwnerUpdateBeforeUpdate
* Description: This method is called before update and it will change the account owner if record is approved.
*/
    public static void handleOwnerUpdateBeforeUpdate(List<Account> lstNewAccount, Map<Id, Account> mapOldAccount) {
        for(Account objAccount : lstNewAccount) {
            if(objAccount.Approval_Process_Action__c == ConstantClass.APPROVAL_PROCESS_ACTION_APPROVED) {
                if(objAccount.Proposed_Account_Owner__c != null && objAccount.OwnerId != objAccount.Proposed_Account_Owner__c && String.isNotBlank(objAccount.Proposed_Account_Owner__c)) {
                    objAccount.OwnerId = objAccount.Proposed_Account_Owner__c;
                    if(mapOldAccount.containsKey(objAccount.Id)) {
                        mapAccountToOldOwnerId.put(objAccount.Id, mapOldAccount.get(objAccount.Id).OwnerId);
                    }
                }
            } else if(objAccount.Approval_Process_Action__c == ConstantClass.APPROVAL_PROCESS_ACTION_REJECTED) {
                    objAccount.Approval_Process_Action__c = NULL;
                	objAccount.ProposedAccountOwnerCopy__c = objAccount.Proposed_Account_Owner__c;
                    objAccount.Proposed_Account_Owner__c = NULL;
                    objAccount.Transfer_Closed_Opportunities__c = FALSE;
                    objAccount.Transfer_Not_Owned_Opportunities__c = FALSE;
                    objAccount.Transfer_Open_Cases__c = FALSE;
                    objAccount.Transfer_Closed_Cases__c = FALSE;
                    objAccount.Keep_Account_Team__c =  FALSE;
                    objAccount.Keep_Opportunity_Team__c = FALSE;
                    objAccount.TimeofStep1Approval__c = NULL;
                    objAccount.TimeofStep2Approval__c = NULL;
                    objAccount.TimeofStep3Approval__c = NULL;
                    objAccount.Requester_Notes__c = Null;
                    objAccount.ApprovalProcessInitiatedOn__c = NULL;
                    objAccount.userWhoProposedNewOwner__c = NULL;
                    objAccount.PreviousOwnersManagerCopy__c = objAccount.PreviousOwnersManager__c;
                    objAccount.PreviousOwnersManager__c = NULL;
                    objAccount.Proposed_Owners_Manager__c = NULL;
            }
        }
    }
    
    /*
* Method Name: transferOwners
* Purpose: This method is called from afterUpdate method of AccountTriggerHandler. It include methods which are called when the owner change request is either approved or declined.
* Created By:  Nagarro
*/
    public static void transferOwners(Map<Id, Account> newAccountMap, Map<Id, Account> oldAccountMap)
    { 
        Set<Id> accIdSetTransferClosedOpps = new Set<Id>();
        Set<Id> accIdSetTransferNotOwnedOpps = new Set<Id>();
        Set<Id> accIdSetTransferAccountOwnerOpenCases = new Set<Id>();
        Set<Id> accIdSetTransferAccountOwnerCases = new Set<Id>();
        Set<Id> accIdSetKeepAccountTeam = new Set<Id>();
        Set<Id> accIdSetKeepOppTeam = new Set<Id>();
        Set<Id> accIdSet = new Set<Id>();
        Set<Id> childAccIdSet = new Set<Id>(); //for id's of child Accounts
        Set<Id> allAccountsIdSet = new Set<Id>(); //for id's of parent and their child accounts
        Map<Id,Account> childToParent = new Map<Id,Account>(); //child To parent Map
        Boolean isAccRecordApproved = FALSE;
        
        List<Account> accListToUpdate = new List<Account>();
        List<Account> listForEmailUpdate = new List<Account>();
        List<Account> listForReset = new List<Account>();
        List<Account> rejectedAccListToUpdate = new List<Account>();
        List<Id> accountIdList = new List<Id>();
        
        Map<Id, String> mapUserIdProfileName = new Map<Id, String>();
        Map<Id,List<Account>> accId_childAcc_Map = new Map<Id,List<Account>>();
        mapUserIdProfileName = fetchMapUserIdProfileName();
        Map<String, ProfilesHavingCheckboxAccess__c> mapProfileHavingChkbxAccessObj = ProfilesHavingCheckboxAccess__c.getAll();
        if(newAccountMap!= NULL && !newAccountMap.isEmpty())
        {
            //accId_childAcc_Map = getMapAccIdChildAccList(newAccountMap);
            
            for(Account acc: newAccountMap.values())
            {
                if(oldAccountMap.containsKey(acc.Id)) {
                    mapAccountToOldOwnerId.put(acc.Id, oldAccountMap.get(acc.Id).OwnerId);
                }
                accountIdList.add(acc.Id);
                //When the record is locked and user tries to change the owner on visualforce page
                if(Approval.isLocked(acc.Id) && newAccountMap.get(acc.Id).Proposed_Account_Owner__c != oldAccountMap.get(acc.Id).Proposed_Account_Owner__c){
                }
                
                if(acc.Approval_Process_Action__c == ConstantClass.APPROVAL_PROCESS_ACTION_APPROVED || (oldAccountMap != null && oldAccountMap.containsKey(acc.Id) && acc.OwnerId != oldAccountMap.get(acc.Id).OwnerId)) 
                {
                    isAccRecordApproved = TRUE;
                    accIdSet.add(acc.Id);
                    
                    allAccountsIdSet.add(acc.Id);
                    
                    /*if(accId_childAcc_Map.containsKey(acc.Id))
                    {
                        List<Account> childAccList = new List<Account>();
                        childAccList = accId_childAcc_Map.get(acc.Id);
                        for(Account childacc: childAccList)
                        {
                            childAccIdSet.add(childacc.Id);
                            allAccountsIdSet.add(childacc.Id);
                            
                        }
                    } */
                    String profileName;
                    if(mapUserIdProfileName.containskey(acc.userWhoProposedNewOwner__c))
                        profileName = mapUserIdProfileName.get(acc.userWhoProposedNewOwner__c);
                    
                    if(mapProfileHavingChkbxAccessObj.containsKey(profileName))
                    {
                        if(acc.Keep_Account_Team__c == TRUE) {// If the checkbox is unchecked, Account Team Members will be deleted from the account
                            accIdSetKeepAccountTeam.add(acc.Id);
                            accIdSetKeepAccountTeam.addall(childAccIdSet);
                        } else if(acc.Keep_Account_Team__c == FALSE && (acc.Approval_Process_Action__c != ConstantClass.APPROVAL_PROCESS_ACTION_APPROVED && (oldAccountMap != null && oldAccountMap.containsKey(acc.Id) && acc.OwnerId != oldAccountMap.get(acc.Id).OwnerId))) {
                            
                            
                            accIdSetKeepAccountTeam.add(acc.Id);
                            accIdSetKeepAccountTeam.addall(childAccIdSet);
                        } else if(acc.Keep_Account_Team__c == FALSE && (String.isBlank(acc.Approval_Process_Action__c)  && (oldAccountMap != null && oldAccountMap.containsKey(acc.Id) && acc.OwnerId != oldAccountMap.get(acc.Id).OwnerId))) {
                            
                            System.debug('Test entry in if *&%%$%*&');
                            accIdSetKeepAccountTeam.add(acc.Id);
                            accIdSetKeepAccountTeam.addall(childAccIdSet);
                        }
                        if(acc.Keep_Opportunity_Team__c == TRUE){
                            accIdSetKeepOppTeam.add(acc.Id);
                            accIdSetKeepOppTeam.addall(childAccIdSet);
                        }
                    }
                    else
                    {
                        accIdSetKeepAccountTeam.add(acc.Id);
                        accIdSetKeepAccountTeam.addall(childAccIdSet);
                        accIdSetKeepOppTeam.add(acc.Id);
                        accIdSetKeepOppTeam.addall(childAccIdSet);
                    }
                }
                
                // In case the account is REJECTED/ APPROVED, certain fields will be reset
                if(acc.Approval_Process_Action__c == ConstantClass.APPROVAL_PROCESS_ACTION_REJECTED || acc.Approval_Process_Action__c == ConstantClass.APPROVAL_PROCESS_ACTION_APPROVED) {
                    //IN CASE OF APPROVED - To set the Approval Process Action to NULL after all the methods are processed.
                    //IN CASE OF APPROVED - Process builder is setting the field value to APPROVED.
                    //IN CASE OF APPROVED - In case the value is already APPROVED, and the owner is changed again then this trigger will fire(owner will be changed) without the approval process.
                    
                    if(acc.TimeofStep3Approval__c != Null){
                        
                        //sendEmailToNewAndOldAccountOwner(acc);
                    } 
                }
                
                Account a = resetAccountFields(acc);
                accListToUpdate.add(a);
                
            }
        }
        
        
        Map<Id, Id> mapAccIdCurrentOwnerId = new Map<Id, Id>();
        Map<Id, Id> mapAccIdNewOwnerId = new Map<Id, Id>();
        
        
        List<Opportunity> opportunityList = new List<Opportunity>();
        List<Contact> contactList = new List<Contact>();
        List<Case> caseList = new List<Case>();
        List<Account> childAccountsList = new List<Account>();
        List<Address__c> businessLocationList = new List<Address__c>();
        
        //Used as future method parameters
        String mapAccIdCurrentOwnerIdJsonString='';
        String mapAccIdNewOwnerIdJsonString='';
        
        if(newAccountMap != NULL && !newAccountMap.isEmpty()) {
            
         //   childToParent = getchildToParentMap(newAccountMap, accId_childAcc_Map);
            for(Account acc: newAccountMap.values()) {
                //Map of account id and the current owner
                if(oldAccountMap != null && oldAccountMap.containsKey(acc.Id)) {
                    mapAccIdCurrentOwnerId.put(acc.Id, oldAccountMap.get(acc.Id).OwnerId);
                    mapAccIdCurrentOwnerIdJsonString = mapAccIdCurrentOwnerIdJsonString + acc.Id +' '+ oldAccountMap.get(acc.Id).OwnerId +' ';
                }
                //Map of account id and the changed owner
                if(!String.isBlank(acc.OwnerId)){
                    mapAccIdNewOwnerId.put(acc.Id, acc.OwnerId);
                    mapAccIdNewOwnerIdJsonString = mapAccIdNewOwnerIdJsonString + acc.Id + ' '+acc.OwnerId +' ';
                }
                
              /*  if(accId_childAcc_Map.containsKey(acc.id)){
                    
                    List<Account> childAccList = new List<Account>();
                    childAccList = accId_childAcc_Map.get(acc.Id);
                    for(Account childacc: childAccList){
                        
                        if(!mapAccIdCurrentOwnerId.containsKey(childacc.Id)){
                            
                            mapAccIdCurrentOwnerId.put(childacc.Id,childacc.OwnerId);
                            mapAccIdCurrentOwnerIdJsonString = mapAccIdCurrentOwnerIdJsonString + childacc.Id +' '+ childacc.OwnerId +' ';
                        }
                        
                        Account target =  childToParent.get(childacc.Id);
                        Id proposedOwner  = mapAccIdNewOwnerId.get(target.Id);
                        mapAccIdNewOwnerId.put(childacc.Id, proposedOwner);
                        mapAccIdNewOwnerIdJsonString = mapAccIdNewOwnerIdJsonString + childacc.Id + ' '+proposedOwner +' ';
                    }
                    
                } */
                
            }
            
            
            //Get opportunity list related to Accounts
            //opportunityList = getOpportunityList(allAccountsIdSet);
            
            
            //Get contact list related to Accounts
            //contactList = getContactList(allAccountsIdSet);
            
            
            //Get case list related to Accounts
            //caseList = getCaseList(allAccountsIdSet);
            
            
            //Get Business Locations Related To Accounts
            //businessLocationList = getBusinessLocationList(allAccountsIdSet);
            
            //Get child accounts list related to Accounts
            //childAccountsList = getchildAccountList(newAccountMap);
            
        }
        
        if(mapAccIdCurrentOwnerId != NULL && !mapAccIdCurrentOwnerId.isEmpty() && mapAccIdNewOwnerId != NULL && !mapAccIdNewOwnerId.isEmpty() && isAccRecordApproved == TRUE) {
            //performDefaultActions(mapAccIdCurrentOwnerIdJsonString, mapAccIdNewOwnerIdJsonString, accountIdList, accIdSetKeepOppTeam, newAccountMap, mapAccIdCurrentOwnerId, mapAccIdNewOwnerId, opportunityList, contactList, allAccountsIdSet);
            
            //   if(accIdSetTransferNotOwnedOpps!= NULL && !accIdSetTransferNotOwnedOpps.isEmpty())
            //       transferOpenOppsOwnedByOthers(accIdSetTransferNotOwnedOpps, mapAccIdCurrentOwnerId, mapAccIdNewOwnerId, opportunityList);
            //   if(accIdSetTransferClosedOpps!= NULL && !accIdSetTransferClosedOpps.isEmpty())
            //       transferAccountOwnersClosedOpps(accIdSetTransferClosedOpps, mapAccIdCurrentOwnerId, mapAccIdNewOwnerId, opportunityList);
            //  if(accIdSetTransferAccountOwnerCases!= NULL && !accIdSetTransferAccountOwnerCases.isEmpty())
            //      transferAllCases(accIdSetTransferAccountOwnerCases, mapAccIdCurrentOwnerId, mapAccIdNewOwnerId, caseList);
            //  if(accIdSetTransferAccountOwnerOpenCases!= NULL && !accIdSetTransferAccountOwnerOpenCases.isEmpty())
            //       transferAllOpenCases(accIdSetTransferAccountOwnerOpenCases, mapAccIdCurrentOwnerId, mapAccIdNewOwnerId, caseList);
            if(accIdSetKeepAccountTeam != NULL && !accIdSetKeepAccountTeam.isEmpty()) {
                TriggerHandler.bypass('AccountTeamTriggerHandler');
                keepAccountTeams(accIdSetKeepAccountTeam, mapAccIdCurrentOwnerId, mapAccIdNewOwnerId, accIdSet);
                TriggerHandler.clearBypass('AccountTeamTriggerHandler');
            }
            //updateStandardOwnerOnAccount(newAccountMap);
            //changeChildAccountOwner(mapAccIdCurrentOwnerId, mapAccIdNewOwnerId, childAccountsList);
            //transferBusinessLocationOwner(mapAccIdCurrentOwnerId,mapAccIdNewOwnerId,businessLocationList);
        }
        if(accListToUpdate != NULL && !accListToUpdate.isEmpty()){
            boolOwnerChangeRan = true;
            Database.DMLOptions objDml = new Database.DMLOptions();
            objDml.DuplicateRuleHeader.AllowSave = true;
            Database.update(accListToUpdate,objDml);
        }
        BulkEmailAccountTransfer obj = new BulkEmailAccountTransfer();
        obj.sendEmail(newAccountMap, oldAccountMap);
        
        //Create parent account success log
        List<Owner_Change_Logger__c> lstOwnerChangeLogger = new List<Owner_Change_Logger__c>();
        if(newAccountMap != null && newAccountMap.size() > 0) {
            for(Id objAccountId : newAccountMap.keySet()) {
                if(newAccountMap.containsKey(objAccountId) && oldAccountMap != null && oldAccountMap.containsKey(objAccountId)) {
                    lstOwnerChangeLogger.add(OwnerChangeLoggerUtility.createLogger(System.now(), objAccountId, UserInfo.getUserId(), 'Success', objAccountId, null, null, null, oldAccountMap.get(objAccountId).OwnerId, newAccountMap.get(objAccountId).OwnerId, 'Account', null));
                }
            }
            Database.insert(lstOwnerChangeLogger, false);
            //Seaction of code - Not allow neww owner change batch if any of the batch from chanin is running. 
            Integer intChildAccountsOwnerChangeBatchSize = 0;
            List<String> lstOwnerChangeApexBatchClasses = new List<String>();
            for(Mass_Account_Transfer__mdt objMeta : [Select DeveloperName, Label, Batch_Size__c FROM Mass_Account_Transfer__mdt]) {
                lstOwnerChangeApexBatchClasses.add(objMeta.DeveloperName);
                if(objMeta.DeveloperName == 'ChildAccountsOwnerChangeBatch') {
                    intChildAccountsOwnerChangeBatchSize = Integer.valueOf(objMeta.Batch_Size__c);
                }
            }
            String strOwnerChnageBatchError = Label.OWNER_CHANGE_BATCH_JOB_ERROR;
            List<AsyncApexJob> lstAsyncApexJob = new List<AsyncApexJob>();
            List<String> lstCompletedBatchStatus = new List<String>{'Aborted', 'Completed', 'Failed'};
            lstAsyncApexJob = [SELECT Id FROM AsyncApexJob WHERE ApexClass.Name IN :lstOwnerChangeApexBatchClasses AND JobType = 'BatchApex' AND Status NOT IN :lstCompletedBatchStatus];
            if(newAccountMap != null && newAccountMap.size() > 0 && lstAsyncApexJob != null && lstAsyncApexJob.size() > 0) {
                for(Account objAccount : newAccountMap.values()) {
                    objAccount.addError(strOwnerChnageBatchError);
                }
            }

			Database.executeBatch(new ChildAccountsOwnerChangeBatch(mapAccountToOldOwnerId, insertedAccMemberMap, updatedAccMemberMap, deletedAccMemberMap, System.now()), intChildAccountsOwnerChangeBatchSize);
        }
    }
    
    
    /*
* Method Name: fetchMapUserIdProfileName
* Purpose: Used to populate map of user id and profile name
* Created By:  Nagarro
*/
    private static Map<Id, String> fetchMapUserIdProfileName()
    {
        List<User> userList = new List<User>();
        userList = [Select Id, Profile.Name from User];
        Map<Id, String> mapUserIdProfileName = new Map<Id, String>();
        if(userList != NULL && !userList.isEmpty())
        {
            for(User u: userList)
            {
                mapUserIdProfileName.put(u.Id, u.Profile.Name);
            }
        }
        return mapUserIdProfileName;
    }
    
    /*
* Method Name: sendEmailToNewAndOldAccountOwner
* Input Parameters: Account
* Purpose: Used to send the mail to Old and New Account Owner After The owner change has been fully Approved.
* Created By:  Nagarro
*/
  /*  @TestVisible
    private static void sendEmailToNewAndOldAccountOwner(Account acc){
        
        Account acc1 = [SELECT Proposed_Account_Owner__c, Proposed_Account_Owner__r.email, PreviousOwner__c, PreviousOwner__r.email from Account where Id=: acc.id];
        
        List<Messaging.SingleEmailMessage> list_singleEmails = new List<Messaging.SingleEmailMessage>();
        List<String> sendTo = new List<String>();
        if(acc1.Proposed_Account_Owner__r.email != Null && acc1.PreviousOwner__r.email != Null){
            
            sendTo.add(acc1.Proposed_Account_Owner__r.email);
            sendTo.add(acc1.PreviousOwner__r.email);
            
            if(Label.MARKETING_TEAM_EMAIL != Null){
                sendTo.add(Label.MARKETING_TEAM_EMAIL);
            }
            EmailTemplate emailTemplate=[Select id from EmailTemplate where name =: 'Notification of Owner Change To New and Old Account Owner' limit 1];
            
            Contact conRecord = [SELECT Id FROM Contact LIMIT 1]; //for setting the target Object Id, as User Id can only be used with Visualforce Templates and not with regular Templates
            if(conRecord != null){
                if(emailTemplate!=NULL){
                    Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
                    singleEmail.setWhatId(acc1.Id);
                    singleEmail.setTemplateID(emailTemplate.Id);
                    singleEmail.setToAddresses(sendTo);
                    singleEmail.setTargetObjectId(conRecord.Id);
                    singleEmail.setTreatTargetObjectAsRecipient(false); //for preventing the email being sent to a random contact
                    singleEmail.saveAsActivity = False;
                    if(singleEmail != Null)
                    {
                        list_singleEmails.add(singleEmail);
                    }
                }
            }
            
            if(!list_singleEmails.isEmpty())
            {
                
                Messaging.sendEmail(list_singleEmails);
            }
        }
    } */
    
    /*
* Method Name: resetAccountFields
* Input Parameters: Account
* Purpose: Used to reset the account field back to blank fields once the record comes out of approval process
* Created By:  Nagarro
*/
    public static Account resetAccountFields(Account acc)
    {
        AccountOwnerChangeHelper.preventPreviousOwnerUpdate = true;
        Account objAcc = new Account();
        objAcc.Id = acc.Id;
        objAcc.Approval_Process_Action__c = NULL;
        objAcc.Proposed_Account_Owner__c = NULL;
        objAcc.Transfer_Closed_Opportunities__c = FALSE;
        objAcc.Transfer_Not_Owned_Opportunities__c = FALSE;
        objAcc.Transfer_Open_Cases__c = FALSE;
        objAcc.Transfer_Closed_Cases__c = FALSE;
        objAcc.Keep_Account_Team__c =  FALSE;
        objAcc.Keep_Opportunity_Team__c = FALSE;
        objAcc.TimeofStep1Approval__c = NULL;
        objAcc.TimeofStep2Approval__c = NULL;
        objAcc.TimeofStep3Approval__c = NULL;
        objAcc.Requester_Notes__c = Null;
        objAcc.ApprovalProcessInitiatedOn__c = NULL;
        objAcc.userWhoProposedNewOwner__c = NULL;
        objAcc.PreviousOwnersManager__c = NULL;
        objAcc.Proposed_Owners_Manager__c = NULL;
        
        return objAcc;
    }
    
    /*
* Method Name: getOpportunityList
* Input Parameters: Map<Id, Account>
* Purpose: Used to get opportunities related to account
* Created By:  Nagarro
*/
   /* public static List<Opportunity> getOpportunityList(Set<Id> accID_Set)
    {
        List<Opportunity> opportunityList = new List<Opportunity>();
        if(accID_Set!=NULL && !accID_Set.isEmpty())
            opportunityList = [Select Id, AccountId, OwnerId, isClosed, StageName from Opportunity where AccountId in: accID_Set];
        
        return opportunityList;
    }
    
    /*
* Method Name: getContactList
* Input Parameters: Map<Id, Account>
* Purpose: Used to get contacts related to account
* Created By:  Nagarro
*/
   /* public static List<Contact> getContactList(Set<Id> accID_Set)
    {
        List<Contact> contactList = new List<Contact>();
        if(accID_Set!=NULL && !accID_Set.isEmpty())
            contactList = [Select Id, AccountId, OwnerId from Contact where AccountId in: accID_Set];
        return contactList;
    }
    
    /*
* Method Name: getBusinessLocationList
* Input Parameters: Map<Id, Account>
* Purpose: Used to get business locations related to account and its child
* Created By:  Nagarro
*/
   /* public static List<Address__c> getBusinessLocationList(Set<Id> accID_Set)
    {
        List<Address__c> businessLocationList = new List<Address__c>();
        if(accID_Set!=NULL && !accID_Set.isEmpty())
            businessLocationList = [Select Id, Account__r.Id, OwnerId from Address__c where Account__r.Id in: accID_Set];
        return businessLocationList;
    }
    
    /*
* Method Name: getCaseList
* Input Parameters: Map<Id, Account>
* Purpose: Used to get cases related to account
* Created By:  Nagarro
*/
   /* private static List<Case> getCaseList(Set<Id> accID_Set)
    {
        List<Case> caseList = new List<Case>();
        if(accID_Set!=NULL && !accID_Set.isEmpty())
            caseList = [Select Id, AccountId, OwnerId, isClosed from Case where AccountId in: accID_Set];
        return caseList;  
    }
    /*
* Method Name: getchildAccountList
* Input Parameters: Map<Id, Account>
* Purpose: Used to get Child Accounts related to account
* Created By:  Nagarro
*/
    /*private static List<Account> getchildAccountList(Map<Id,Account> newAccountMap){
        
        List<Account> childAccountList = new List<Account>();
        if(newAccountMap!= Null && !newAccountMap.isEmpty())
            childAccountList = [Select Id,ParentId, OwnerId from Account where ParentId in: newAccountMap.keySet()];
        return childAccountList;
        
    }
    
    /*
* Method Name: getChildAccList
* Input Parameters: Map<Id, Account>
* Purpose: Used to get map of child accounts related to account
* Created By:  Nagarro
*/  
    /*@TestVisible
    private static Map<Id,List<Account>> getMapAccIdChildAccList(Map<Id,Account>newAccountMap){
        
        Set<Id> accIdSet =new Set<Id>();
        List<Account> childAccList = new List<Account>();
        for(Account acc: newAccountMap.values()){
            accIdSet.add(acc.Id);
        }
        
        if(newAccountMap!=Null && !newAccountMap.isEmpty())
            childAccList = [Select Id, ParentId, OwnerId from Account where ParentId in: accIdSet];
        
        Map<Id,List<Account>> mapAccIdChildAccList = new Map<Id,List<Account>>();
        
        for(Account acc: childAccList){
            if(mapAccIdChildAccList.containsKey(acc.ParentId)){
                List<Account> childAcc = mapAccIdChildAccList.get(acc.ParentId);
                childAcc.add(acc);
            }
            else{
                List<Account> childAcc = new List<Account>();
                childAcc.add(acc);
                mapAccIdChildAccList.put(acc.ParentId, childAcc);
            }
        }
        
        return mapAccIdChildAccList;
    }
    
    /*
* Method Name: getchildToParentMap
* Input Parameters: Map<Id, Account>, Map<Id,List<Account>>
* Purpose: Used to get map of child to parent
* Created By:  Nagarro
*/     
    /*private static Map<Id,Account> getchildToParentMap(Map<Id,Account> newAccountMap, Map<Id,List<Account>> mapAccIdChldAccList){
        
        Map<Id,Account> childToparentMap = new Map<Id,Account>();
        for(Account acc: newAccountMap.values()){
            
            if(mapAccIdChldAccList.containsKey(acc.id)){
                
                List<Account> childAccountList = mapAccIdChldAccList.get(acc.Id);
                for(Account childAcc: childAccountList){                    
                    childToparentMap.put(childAcc.Id, acc);  
                }
            }
        }
        return childToparentMap;
    }
    /*
* Method Name: performDefaultActions
* Input Parameters: String, String, List<Id>, Set<Id>, Map<Id, Account>, Map<Id, Id>, Map<Id, Id>, List<Opportunity>, List<Contact>,Set<Id>
* Purpose: Used to call other methods that are executed automatically when Account Owner(Standard Field) is changed
* Created By:  Nagarro
*/
  /*  private static void performDefaultActions(String mapAccIdCurrentOwnerIdJsonString, String jsonStringMapAccIdNewOwnerId, List<Id>accountIdList, Set<Id> accIdSetKeepOppTeam, Map<Id, Account> newAccountMap, Map<Id, Id> mapAccIdCurrentOwnerId, Map<Id, Id> mapAccIdNewOwnerId, List<Opportunity> opportunityList, List<Contact> contactList,Set<Id> allAccountsIdSet, Map<Id, Account> oldAccountMap)
    {
        //Open opportunities
        transferOpenOppsOwnedByAccountOwner(accIdSetKeepOppTeam, newAccountMap, mapAccIdCurrentOwnerId, mapAccIdNewOwnerId, opportunityList);
        //Contracts in Draft and In Approval status
        //    transferContracts(allAccountsIdSet, mapAccIdNewOwnerId, mapAccIdCurrentOwnerId);
        //Open activities
        transferActivityOwner(allAccountsIdSet, opportunityList, contactList, mapAccIdNewOwnerId, oldAccountMap);
        //Contacts
        transferContactOwner(newAccountMap, mapAccIdCurrentOwnerId, mapAccIdNewOwnerId, contactList);
        //Notes
        //    transferNotes(mapAccIdCurrentOwnerIdJsonString, jsonStringMapAccIdNewOwnerId, allAccountsIdSet);
        //Update the standard owner field with the custom field
        //updateStandardOwnerOnAccount(newAccountMap);
    }
    
    /*
* Method Name: updateStandardOwnerOnAccount
* Input Parameters: Map<Id, Account>
* Purpose: Used to update the new owner value(Account_Owner__c) on the Standard Owner Field(OwnerId)
* Created By:  Nagarro
*/
   /* private static void updateStandardOwnerOnAccount(Map<Id, Account> newAccountMap)
    {
        List<Account> accList = new List<Account>();
        if(newAccountMap != NULL && !newAccountMap.isEmpty())
            accList = [Select Id, OwnerId, Proposed_Account_Owner__c from Account where Id in: newAccountMap.keySet()];
        List<Account> accListToUpdate = new List<Account>();
        if(accList != NULL && !accList.isEmpty()) {
            for(Account acc: accList) {
                if(!String.isBlank(acc.Proposed_Account_Owner__c))
                {
                    acc.OwnerId = acc.Proposed_Account_Owner__c;
                    accListToUpdate.add(acc);
                }
            }
        }
        Database.SaveResult[] srList;
        if(accListToUpdate != NULL && !accListToUpdate.isEmpty())
            srList = Database.update(accListToUpdate, FALSE);
        
        handleInsertionUpdationResult(srList);
    }
    
    /*
* Method Name: transferOpenOppsOwnedByAccountOwner
* Input Parameters: Set<Id>, Map<Id, Account>, Map<Id, Id>, Map<Id, Id>, List<Opportunity>
* Purpose: Used to transfer opportunities owned by current account owner 
* Created By:  Nagarro
*/
   /* public static void transferOpenOppsOwnedByAccountOwner(Set<Id> accIdSetKeepOppTeam, Map<Id, Account> newAccountMap, Map<Id, Id> mapAccIdCurrentOwnerId, Map<Id, Id> mapAccIdNewOwnerId, List<Opportunity> opportunityList)
    {        
        List<Opportunity> openOpportunityList = new List<Opportunity>();
        if(opportunityList != NULL && !opportunityList.isEmpty()) {
            for(Opportunity opp: opportunityList) {
                if(!opp.IsClosed)
                    openOpportunityList.add(opp);  
                
            }
        }
        List<Opportunity> opportunityListToUpdate = new List<Opportunity>();
        opportunityListToUpdate = transferOpp(openOpportunityList, mapAccIdCurrentOwnerId, mapAccIdNewOwnerId);
        
        System.debug('opportunityListToUpdate--> '+opportunityListToUpdate.size());
        
        if(opportunityListToUpdate != NULL && !opportunityListToUpdate.isEmpty())
            updateOpportunities(opportunityListToUpdate);
        
        //--------------------------------------KEEP OPPORTUNITY TEAMS WITH TRANSFERRED OPPORTUNITIES--------------------------------------
        //To keep opportunity team members with an opportunity when the account owner is changed, select Keep opportunity teams with transferred opportunities.
        // To delete the team, deselect this option.
        
        //As open opportunities having the same owner as account owner will be transferred automatically.
        //In case the Checkbox "Keep opportunity teams with transferred opportunities" is UNCHECKED, then the Opportunity Team Members related to these Opportunities will be deleted.
        List<Opportunity> opportunityListForOppTeam = new List<Opportunity>();
        if((accIdSetKeepOppTeam != NULL && !accIdSetKeepOppTeam.isEmpty()) || (opportunityListToUpdate != NULL && !opportunityListToUpdate.isEmpty())) {
            opportunityListForOppTeam = [Select Id, AccountId, OwnerId from Opportunity where AccountId in: accIdSetKeepOppTeam AND Id in: opportunityListToUpdate];
        }
        if(opportunityListForOppTeam != NULL && !opportunityListForOppTeam.isEmpty())
            keepOpportunityTeam(mapAccIdCurrentOwnerId, mapAccIdNewOwnerId, opportunityListForOppTeam);
    }
    
    /*
* Method Name: keepOpportunityTeam
* Input Parameters: Map<Id, Account>, Map<Id, Id>, Map<Id, Id>, List<Opportunity>
* Purpose: If the account owner is present in the Account Team, then he will be replaced with the new owner
* Created By:  Nagarro
*/
    /*public static void keepOpportunityTeam(Map<Id, Id> mapAccIdCurrentOwnerId, Map<Id, Id> mapAccIdNewOwnerId, List<Opportunity> opportunityList)
    {
        Map<Id, Id> mapOppIdAccId = new Map<Id, Id>();
        for(Opportunity opp: opportunityList)
        {
            if(opp.AccountId != NULL)
                mapOppIdAccId.put(opp.Id, opp.AccountId);
        }
        List<OpportunityTeamMember> oppTeamMemList = new List<OpportunityTeamMember>();
        Map<Id,List<OpportunityTeamMember>> oppIdToMemberMap = new Map<Id,List<OpportunityTeamMember>>();
        Map<String,User_Region_to_Opp_Role__c> regionToRoleMap = new Map<String,User_Region_to_Opp_Role__c>();
        User userdetail = new User();
        Id proposedOwner;
        Map<Id,String> userToRegionMap = new Map<Id,String>();
        
        regionToRoleMap = User_Region_to_Opp_Role__c.getAll();
        
        if(opportunityList != NULL && !opportunityList.isEmpty())
            oppTeamMemList = [Select Id, OpportunityId, UserId, User.Region__c, TeamMemberRole from OpportunityTeamMember where OpportunityId in: opportunityList];
        
        // if(oppTeamMemList != NULL && !oppTeamMemList.isEmpty()){
        
        for(Opportunity oppMem: opportunityList){
            
            proposedOwner = mapAccIdNewOwnerId.get(mapOppIdAccId.get(oppMem.Id));
            
        }
        userdetail = [Select Id, Region__c from User where Id =: proposedOwner];
        userToRegionMap.put(userdetail.Id, userdetail.Region__c);
        
        //   }
        
        for(OpportunityTeamMember oppTeam: oppTeamMemList){
            
            if(!oppIdToMemberMap.containsKey(oppTeam.OpportunityId)){
                oppIdToMemberMap.put(oppTeam.OpportunityId, new List<OpportunityTeamMember>());
            }
            
            oppIdToMemberMap.get(oppTeam.OpportunityId).add(oppTeam);
        }
        
        List<OpportunityTeamMember> oppTeamMemberListToUpdate = new List<OpportunityTeamMember>();
        List<OpportunityTeamMember> oppTeamMemberListToInsert = new List<OpportunityTeamMember>();
        
        for(Opportunity opp: opportunityList){
            
            //   if(oppTeamMemList != NULL && !oppTeamMemList.isEmpty())
            //   {
            
            if(oppIdToMemberMap.containsKey(opp.Id) && !oppIdToMemberMap.get(opp.Id).isEmpty()){
                
                for(OpportunityTeamMember oppTeamMember: oppIdToMemberMap.get(opp.Id))
                {
                    Id accId = mapOppIdAccId.get(oppTeamMember.OpportunityId);
                    String currentOwnerId = mapAccIdCurrentOwnerId.get(accId);
                    String proposedOwnerId = mapAccIdNewOwnerId.get(accId);
                    if(currentOwnerId != proposedOwnerId){
                        if(proposedOwnerId.contains(oppTeamMember.UserId) )
                        {
                            if(userToRegionMap.get(oppTeamMember.UserId) != Null && oppTeamMember.TeamMemberRole != regionToRoleMap.get(userToRegionMap.get(oppTeamMember.UserId)).Opp_Role__c && oppTeamMember.TeamMemberRole != ConstantClass.TEAM_MEMBER_ROLE_AS_OPP_CREATOR){
                                oppTeamMember.TeamMemberRole = regionToRoleMap.get(userToRegionMap.get(oppTeamMember.UserId)).Opp_Role__c;
                            }
                            else if(userToRegionMap.get(oppTeamMember.UserId) == Null && oppTeamMember.TeamMemberRole != ConstantClass.TEAM_MEMBER_ROLE_AS_ADMIN && oppTeamMember.TeamMemberRole != ConstantClass.TEAM_MEMBER_ROLE_AS_OPP_CREATOR){
                                
                                oppTeamMember.TeamMemberRole = ConstantClass.TEAM_MEMBER_ROLE_AS_ADMIN;
                            }
                            oppTeamMemberListToUpdate.add(oppTeamMember);
                        }
                        if(!proposedOwnerId.contains(oppTeamMember.UserId))
                        {
                            OpportunityTeamMember oppTeamMem= new OpportunityTeamMember();
                            if(userToRegionMap.get(proposedOwnerId) != Null && regionToRoleMap.containsKey(userToRegionMap.get(proposedOwnerId))){
                                
                                oppTeamMem.TeamMemberRole = regionToRoleMap.get(userToRegionMap.get(proposedOwnerId)).Opp_Role__c;
                            }
                            else{
                                
                                oppTeamMem.TeamMemberRole = ConstantClass.TEAM_MEMBER_ROLE_AS_ADMIN;
                            }
                            //    oppTeamMem.TeamMemberRole = ConstantClass.TEAM_MEMBER_ROLE_AS_ACCOUNT_MANAGER;
                            oppTeamMem.OpportunityAccessLevel = ConstantClass.EDIT_PERMISSION;
                            oppTeamMem.UserId = proposedOwnerId;
                            oppTeamMem.OpportunityId = oppTeamMember.OpportunityId;
                            oppTeamMemberListToInsert.add(oppTeamMem);
                        }
                        //}
                    }
                }
            }
            else{
                
                //for(Opportunity opp: opportunityList){
                
                Id accId = mapOppIdAccId.get(opp.Id);
                String currentOwnerId = mapAccIdCurrentOwnerId.get(accId);
                String proposedOwnerId = mapAccIdNewOwnerId.get(accId);
                if(currentOwnerId != proposedOwnerId){
                    
                    OpportunityTeamMember oppMem = new OpportunityTeamMember();
                    if(userToRegionMap.get(proposedOwnerId) != Null){
                        
                        oppMem.TeamMemberRole = regionToRoleMap.get(userToRegionMap.get(proposedOwnerId)).Opp_Role__c;
                    }
                    else{
                        
                        oppMem.TeamMemberRole = ConstantClass.TEAM_MEMBER_ROLE_AS_ADMIN;
                    }
                    
                    oppMem.OpportunityAccessLevel = ConstantClass.EDIT_PERMISSION;
                    oppMem.UserId = proposedOwnerId;
                    oppMem.OpportunityId = opp.Id;
                    oppTeamMemberListToInsert.add(oppMem);
                }
            }
        }
        
        Database.SaveResult[] srListToInsert;
        if(oppTeamMemberListToInsert != NULL && !oppTeamMemberListToInsert.isEmpty())
            srListToInsert = Database.insert(oppTeamMemberListToInsert, FALSE);
        handleInsertionUpdationResult(srListToInsert);
        
        Database.SaveResult[] srListToUpdate;
        if(oppTeamMemberListToUpdate != NULL && !oppTeamMemberListToUpdate.isEmpty())
            srListToUpdate = Database.update(oppTeamMemberListToUpdate, FALSE);
        handleInsertionUpdationResult(srListToUpdate);
    }
    
    /*
* Method Name: transferContracts
* Input Parameters: Set<Id>, Map<Id, Id>, Map<Id, Id>
* Purpose: User to transfer the contracts in Draft stage owned by the current account owner
* Created By:  Nagarro
*/
    /*
private static void transferContracts(Set<Id> accIdSet, Map<Id, Id> mapAccIdNewOwnerId, Map<Id, Id> mapAccIdCurrentOwnerId)
{
List<Contract> contractList = new List<Contract>();
if(accIdSet != NULL && !accIdSet.isEmpty())
contractList = [Select Id, AccountId, Status, OwnerId from Contract where Status=: 'Draft' AND AccountId in: accIdSet];

List<Contract> contractListToUpdate = new List<Contract>();
//Map of account id and list of related open opportunities
Map<Id, List<Contract>> mapAccIdContractList = new Map<Id, List<Contract>>();
if(contractList!=NULL && !contractList.isEmpty()) {
for(Contract con: contractList) {
List<Contract> tempContractList = mapAccIdContractList.get(con.AccountId);
if(tempContractList == NULL)
tempContractList = new List<Contract>();
if(mapAccIdCurrentOwnerId.containsKey(con.AccountId)) {
//If the account owner and the contract owner are same. (To fetch contracts owned by the account owner)
if(con.OwnerId == mapAccIdCurrentOwnerId.get(con.AccountId)) {
if(mapAccIdNewOwnerId != NULL && !mapAccIdNewOwnerId.isEmpty()) {
con.OwnerId = mapAccIdNewOwnerId.get(con.AccountId); //Update owner of the contracts. Now the account owner becomes the opportunity owner.
contractListToUpdate.add(con);
}
}
}
}
}

Database.SaveResult[] srList;
if(contractListToUpdate != NULL && !contractListToUpdate.isEmpty())
srList = Database.update(contractListToUpdate, FALSE);

handleInsertionUpdationResult(srList);
}

/*
* Method Name: transferNotes
* Input Parameters: String, String, Set<Id>
* Purpose: User to transfer the notes owned by the current account owner
* Created By:  Nagarro
*/
    /*
@future
public static void transferNotes(String mapAccIdCurrentOwnerIdJsonString, String mapAccIdNewOwnerIdJsonString, Set<Id> accIdList)
{
Map<Id, Id> mapAccIdCurrentOwnerId = new Map<Id, Id>();
Map<Id, Id> mapAccIdNewOwnerId = new Map<Id, Id>();

String[] mapAccIdCurrentOwnerIdString = mapAccIdCurrentOwnerIdJsonString.split(' ');
for(Integer i=0;i< mapAccIdCurrentOwnerIdString.size(); i+=2){
mapAccIdCurrentOwnerId.put(mapAccIdCurrentOwnerIdString[i], mapAccIdCurrentOwnerIdString[i+1]);
}
System.debug('@@@!!!mapAccIdCurrentOwnerId'+mapAccIdCurrentOwnerId);

String[] mapAccIdNewOwnerIdString = mapAccIdNewOwnerIdJsonString.split(' ');
for(Integer i=0;i< mapAccIdNewOwnerIdString.size(); i+=2){
mapAccIdNewOwnerId.put(mapAccIdNewOwnerIdString[i], mapAccIdNewOwnerIdString[i+1]);
System.debug('======mapAccIdNewOwnerId======'+mapAccIdNewOwnerId.values());
}
System.debug('@@@!!!mapAccIdNewOwnerId'+mapAccIdNewOwnerId);

List<Account> accRelatedContentDocLinksList = [Select Id,(Select Id, ContentDocumentID, LinkedEntityid, LinkedEntity.Name, ShareType, Visibility From ContentDocumentLinks) FROM Account where id in: accIdList];
List<Id> contentDocumentIdList = new List<Id>(); // Fetch Ids of the notes related to account. Will be used to fetch the notes details from ContentNote object
Map<Id, Id> mapContentDocumentIdAccId = new Map<Id, Id>();
Map<Id, ContentDocumentLink> mapContentDocumentIdContentDocumentLink = new Map<Id, ContentDocumentLink>();

System.debug('@@@!!!accRelatedContentDocLinksList'+accRelatedContentDocLinksList);
if(accRelatedContentDocLinksList != NULL && !accRelatedContentDocLinksList.isEmpty()) {
for(Account acc: accRelatedContentDocLinksList) {
if(acc.ContentDocumentLinks != NULL && !acc.ContentDocumentLinks.isEmpty()) {
for(ContentDocumentLink c: acc.ContentDocumentLinks) {
contentDocumentIdList.add(c.ContentDocumentId); //ContentDocumentId is the Note Id
mapContentDocumentIdAccId.put(c.ContentDocumentId, c.LinkedEntityId);
mapContentDocumentIdContentDocumentLink.put(c.ContentDocumentId, c);
}
}
}
}

//Fetch content notes related to the content document links
List<ContentNote> contentNoteList = new List<ContentNote>();
contentNoteList = [SELECT Content, Title, CreatedDate, CreatedBy.Name, OwnerId FROM ContentNote where Id in: contentDocumentIdList];

//Firstly, ContentNote record will be inserted 
List<ContentNote> contentNoteListToInsert = new List<ContentNote>();
Map<String, ContentNote> mapOldTitleContentOwnerAndOldContentNote = new Map<String, ContentNote>();
List<ContentNote> contentNoteListToDelete = new List<ContentNote>();
if(contentNoteList != NULL && !contentNoteList.isEmpty()) {
for(ContentNote cn: contentNoteList) {
ContentNote createCNObj = new ContentNote();
createCNObj.Content = cn.Content;
createCNObj.Title = cn.Title;

//Get AccountId (LinkedEntityId) related to ContentDocumentId (ContentNoteId) from ContentDocumentLink record
//LinkedEntityId is present in ContentDocumentLink record
Id accId;
if(mapContentDocumentIdAccId.containsKey(cn.Id)) {
accId = mapContentDocumentIdAccId.get(cn.Id);
//If ContentNote owner is same as the Account owner, then only owner id will be changed
if(mapAccIdCurrentOwnerId.containsKey(accId)) {
if(cn.OwnerId == mapAccIdCurrentOwnerId.get(accId)) {
createCNObj.OwnerId = mapAccIdNewOwnerId.get(accId);
mapOldTitleContentOwnerAndOldContentNote.put(cn.Title+cn.Content, cn); //This map is further used for creating ContentDocumentLink record
contentNoteListToInsert.add(createCNObj);
contentNoteListToDelete.add(cn);
}
}
}
}
}

Database.SaveResult[] srList1;// = new Database.SaveResult[]();
if(contentNoteListToInsert != NULL && !contentNoteListToInsert.isEmpty())
srList1 = Database.insert(contentNoteListToInsert, FALSE);

handleInsertionUpdationResult(srList1);

//After ContentNote is created, ContentDocumentLink has to be created
List<ContentDocumentLink> contentDocumentLinkListToInsert = new List<ContentDocumentLink>();
Map<Id, Id> mapContentDocumentIdContentNoteId = new Map<Id, Id>();
List<ContentDocumentLink> contentDocumentLinkListToDelete = new List<ContentDocumentLink>();
if(contentNoteListToInsert != NULL && !contentNoteListToInsert.isEmpty()) {
for(ContentNote cn: contentNoteListToInsert) {
ContentDocumentLink createCDLObj = new ContentDocumentLink();
createCDLObj.ContentDocumentId = cn.Id;

ContentNote oldContentNote; // Get the old ContentNote record. This old ContentNote Id is used to fetch the AccountId (LinkedEntityId) from mapContentDocumentIdAccId
if(mapOldTitleContentOwnerAndOldContentNote.containsKey(cn.Title+cn.Content))
oldContentNote = mapOldTitleContentOwnerAndOldContentNote.get(cn.Title+cn.Content);
Id accId;
if(mapContentDocumentIdAccId.containsKey(oldContentNote.Id))
accId = mapContentDocumentIdAccId.get(oldContentNote.Id);
//Get the related/same old ContentDocumentLink record, which is used to populate other fields such as ShareType and Visibility
ContentDocumentLink oldCDL;
if(mapContentDocumentIdContentDocumentLink.containsKey(oldContentNote.Id))
oldCDL = mapContentDocumentIdContentDocumentLink.get(oldContentNote.Id);
createCDLObj.ShareType = oldCDL.ShareType;
createCDLObj.Visibility = oldCDL.Visibility;

if(!String.isBlank(accId)) {
createCDLObj.LinkedEntityId = accId;
}
//Create ContentDocumentLink record only if it has LinkedEntityId and ShareType.
//ContentDocumentLink record must be associated with an account; as a new copy is being created of the existing notes.
if(!String.isBlank(createCDLObj.LinkedEntityId) && !String.isBlank(createCDLObj.ShareType)) {
contentDocumentLinkListToInsert.add(createCDLObj);
contentDocumentLinkListToDelete.add(oldCDL);
}
}
}
Database.SaveResult[] srList2;
if(contentDocumentLinkListToInsert != NULL && !contentDocumentLinkListToInsert.isEmpty())
srList2 = Database.insert(contentDocumentLinkListToInsert, FALSE);

handleInsertionUpdationResult(srList2);

Database.DeleteResult[] srList3;// = new Database.DeleteResult[]();
if(contentNoteListToDelete != NULL && !contentNoteListToDelete.isEmpty())
srList3 = Database.delete(contentNoteListToDelete, FALSE);

handleDeletionResult(srList3);

Database.DeleteResult[] srList4;// = new Database.DeleteResult[]();
if(contentDocumentLinkListToDelete != NULL && !contentDocumentLinkListToDelete.isEmpty())
srList4 = Database.delete(contentDocumentLinkListToDelete, FALSE);

handleDeletionResult(srList4);
}

/*
* Method Name: transferActivityOwner
* Input Parameters: Map<Id, Account>, List<Opportunity>, List<Contact>
* Purpose: This method calls methods that are used to transfer the activities owned by current account owner
* Created By:  Nagarro
*/
    
    public static void transferActivityOwner(Set<Id> allAccountsIdSet, List<Opportunity> opportunityList, List<Contact> contactList, Map<Id, Id> mapAccIdNewOwnerId, Map<Id, Account> oldAccountMap)
    {
        transferTasksOwner(allAccountsIdSet, opportunityList, contactList, mapAccIdNewOwnerId, oldAccountMap);
        transferEventsOwner(allAccountsIdSet, opportunityList, contactList, mapAccIdNewOwnerId, oldAccountMap);
    }
    
    /*
* Method Name: transferTasksOwner
* Input Parameters: Set<Id>, List<Opportunity>, List<Contact>, Map<Id, Account>
* Purpose: This method is used to transfer the tasks owned by current account owner
* Created By:  Nagarro
*/
    private static void transferTasksOwner(Set<Id> allAccountsIdSet, List<Opportunity> opportunityList, List<Contact> contactList, Map<Id,Id> mapAccIdNewOwnerId, Map<Id, Account> oldAccountMap)
    {        
        //Get all open tasks related to account and opportunity
        List<Task> openTaskList = new List<Task>();
        openTaskList = [Select Id, Status, WhoId, WhatId, OwnerId from Task where (WhatId in: allAccountsIdSet OR WhatId in: opportunityList OR WhoId in: contactList) AND Status!='Completed'];
        
        Map<Id, Id> mapOppIdAccId = new Map<Id, Id>();
        if(opportunityList != NULL && !opportunityList.isEmpty()) {
            for(Opportunity opp: opportunityList) {
                if(!String.isBlank(opp.AccountId))
                    mapOppIdAccId.put(opp.Id, opp.AccountId);
            }
        }
        
        Map<Id, Id> mapConIdAccId = new Map<Id, Id>();
        if(contactList != NULL && !contactList.isEmpty()) {
            for(Contact con: contactList) {
                if(!String.isBlank(con.AccountId))
                    mapConIdAccId.put(con.Id, con.AccountId);
            }
        }
        
        //Create map with key as the account and value as list of open tasks
        //If task is associated with account's opportunity(WhatId is Opportunity), key would be opportunity's account and value as the task list
        //If task is associated with account's contact(WhoId is Contact), key would be contact's account and value as the task list
        Map<Id, List<Task>> mapAccIdTaskList = new Map<Id, List<Task>>();
        if(openTaskList != NULL && !openTaskList.isEmpty())
        {
            for(Task t: openTaskList)
            {
                String accId;
                
                if(t.WhatId != NULL){
                    accId = t.WhatId;
                    if(mapOppIdAccId.containsKey(t.WhatId)) {
                        accId=mapOppIdAccId.get(t.WhatId);
                    }
                    List<Task> tempTaskList = mapAccIdTaskList.get(accId);
                    if(tempTaskList == NULL)
                        tempTaskList = new List<Task>();
                    tempTaskList.add(t);
                    if(accId.startsWith('001')) //The key of the map must be account
                        mapAccIdTaskList.put(accId, tempTaskList);
                }
                else if(t.WhoId != NULL && t.WhatId == NULL)
                {
                    accId = t.WhoId;
                    if(mapConIdAccId.containsKey(t.WhoId)) {
                        accId=mapConIdAccId.get(t.WhoId);
                    }
                    List<Task> tempTaskList = mapAccIdTaskList.get(accId);
                    if(tempTaskList == NULL)
                        tempTaskList = new List<Task>();
                    tempTaskList.add(t);
                    if(accId.startsWith('001')) //The key of the map must be account
                        mapAccIdTaskList.put(accId, tempTaskList);
                }
            }
        }
        
        List<Task> taskListToUpdate = new List<Task>();
        if(allAccountsIdSet != NULL && !allAccountsIdSet.isEmpty())
        {
            for(Id accId: allAccountsIdSet) {
                List<Task> taskListRelatedToAcc = new List<Task>();
                if(mapAccIdTaskList.containsKey(accId))
                    taskListRelatedToAcc = mapAccIdTaskList.get(accId);
                if(taskListRelatedToAcc != NULL && !taskListRelatedToAcc.isEmpty()) {
                    for(Task t: taskListRelatedToAcc) {
                        if(mapAccIdNewOwnerId.containsKey(accId) && oldAccountMap.containsKey(accId) && t.OwnerId == oldAccountMap.get(accId).OwnerId){
                            t.OwnerId = mapAccIdNewOwnerId.get(accId);
                            taskListToUpdate.add(t);
                        }
                    }
                }
            }
        }
        Database.SaveResult[] srList;
        if(taskListToUpdate != NULL && !taskListToUpdate.isEmpty())
            srList = Database.update(taskListToUpdate, FALSE);
        
        handleInsertionUpdationResult(srList);
    }
    
    /*
* Method Name: transferEventsOwner
* Input Parameters: Map<Id, Account>, List<Opportunity>, List<Contact>
* Purpose: This method is used to transfer the events owned by the current account owner
* Created By:  Set<Id>
*/
    private static void transferEventsOwner(Set<Id> allAccountsIdSet, List<Opportunity> opportunityList, List<Contact> contactList, Map<Id,Id> mapAccIdNewOwnerId, Map<Id, Account> oldAccountMap)    {
        //Get all open Events related to account and opportunity
        List<Event> openEventList = new List<Event>();
        openEventList = [Select Id, WhoId, WhatId, OwnerId from Event where (WhatId in: allAccountsIdSet OR WhatId in: opportunityList OR WhoId in: contactList) AND StartDateTime >= :System.now()];
        
        Map<Id, Id> mapOppIdAccId = new Map<Id, Id>();
        if(opportunityList != NULL && !opportunityList.isEmpty())
        {
            for(Opportunity opp: opportunityList) {
   	             if(!String.isBlank(opp.AccountId))
                    mapOppIdAccId.put(opp.Id, opp.AccountId);
            }
        }
        
        Map<Id, Id> mapConIdAccId = new Map<Id, Id>();
        if(contactList != NULL && !contactList.isEmpty())
        {
            for(Contact con: contactList) {
                if(!String.isBlank(con.AccountId))
                    mapConIdAccId.put(con.Id, con.AccountId);
            }
        }
        
        //Create map with key as the account and value as list of open Events
        //If Event is associated with account's opportunity(WhatId is Opportunity), key would be opportunity's account and value as the Event list
        //If Event is associated with account's contact(WhoId is Contact), key would be contact's account and value as the Event list
        Map<Id, List<Event>> mapAccIdEventList = new Map<Id, List<Event>>();
        if(openEventList != NULL && !openEventList.isEmpty())
        {
            for(Event e: openEventList)
            {
                String accId;
                
                if(e.WhatId != NULL){
                    accId = e.WhatId;
                    if(mapOppIdAccId.containsKey(e.WhatId)) {
                        accId=mapOppIdAccId.get(e.WhatId);
                    }
                    List<Event> tempEventList = mapAccIdEventList.get(accId);
                    if(tempEventList == NULL)
                        tempEventList = new List<Event>();
                    tempEventList.add(e);
                    if(accId.startsWith('001')) //The key of the map must be account
                        mapAccIdEventList.put(accId, tempEventList);
                }
                else if(e.WhoId != NULL && e.WhatId == NULL)
                {
                    accId = e.WhoId;
                    if(mapConIdAccId.containsKey(e.WhoId)) {
                        accId=mapConIdAccId.get(e.WhoId);
                    }
                    List<Event> tempEventList = mapAccIdEventList.get(accId);
                    if(tempEventList == NULL)
                        tempEventList = new List<Event>();
                    tempEventList.add(e);
                    if(accId.startsWith('001')) //The key of the map must be account
                        mapAccIdEventList.put(accId, tempEventList);
                }
            }
        }
        
        List<Event> eventListToUpdate = new List<Event>();
        if(allAccountsIdSet != NULL && !allAccountsIdSet.isEmpty()) {
            for(Id accId: allAccountsIdSet) {
                List<Event> eventListRelatedToAcc = new List<Event>();
                if(mapAccIdEventList.containsKey(accId))
                    eventListRelatedToAcc = mapAccIdEventList.get(accId);
                if(eventListRelatedToAcc != NULL && !eventListRelatedToAcc.isEmpty()) {
                    for(Event e: eventListRelatedToAcc) {
                        if(mapAccIdNewOwnerId.containsKey(accId) && oldAccountMap.containsKey(accId) && e.OwnerId == oldAccountMap.get(accId).OwnerId){
                            e.OwnerId = mapAccIdNewOwnerId.get(accId);
                            eventListToUpdate.add(e);
                        }
                    }
                }
            }
        }
        Database.SaveResult[] srList;// = new Database.SaveResult[]();
        if(eventListToUpdate != NULL && !eventListToUpdate.isEmpty())
            srList = Database.update(eventListToUpdate, FALSE);
        
        handleInsertionUpdationResult(srList);
    }    
    
    /*
* Method Name: transferContactOwner
* Input Parameters: Map<Id, Account>, Map<Id, Id>, Map<Id, Id>, List<Contact>
* Purpose: This method is used to transfer the contacts having the same owner(as that of account) are transferred
* Created By:  Nagarro
*/
  /*  public static void transferContactOwner(Map<Id, Account> newAccountMap, Map<Id, Id> mapAccIdCurrentOwnerId, Map<Id, Id> mapAccIdNewOwnerId, List<Contact> contactList)
    {
        List<Contact> contactListToUpdate = new List<Contact>();
        
        //Map of account id and list of related contacts
        Map<Id, List<Contact>> mapAccIdConList = new Map<Id, List<Contact>>();
        if(contactList!=NULL && !contactList.isEmpty()) {
            for(Contact con: contactList) {
                List<Contact> tempConList = mapAccIdConList.get(con.AccountId);
                if(tempConList == NULL)
                    tempConList = new List<Contact>();
                if(mapAccIdCurrentOwnerId.containsKey(con.AccountId)) {
                    //If the account owner and the contact owner are same. (To fetch open contacts owned by the account owner)
                    if(con.OwnerId == mapAccIdCurrentOwnerId.get(con.AccountId)) {
                        if(mapAccIdNewOwnerId != NULL && !mapAccIdNewOwnerId.isEmpty()) {
                            con.OwnerId = mapAccIdNewOwnerId.get(con.AccountId);//Update owner of the open contacts. Now the account owner becomes the Contact owner.
                            contactListToUpdate.add(con);
                        }
                    }
                }
            }
        }
        Database.SaveResult[] srList;
        if(contactListToUpdate != NULL && !contactListToUpdate.isEmpty())
            srList = Database.update(contactListToUpdate,FALSE);
        
        handleInsertionUpdationResult(srList);
    }
    
    /*
* Method Name: transferBusinessLocationOwner
* Input Parameters: Map<Id, Account>, Map<Id, Id>, Map<Id, Id>, List<Address>
* Purpose: This method is used to transfer the business location having the same owner(as that of account) are transferred
* Created By:  Nagarro
*/
  /*  public static void transferBusinessLocationOwner(Map<Id, Id> mapAccIdCurrentOwnerId, Map<Id, Id> mapAccIdNewOwnerId, List<Address__c> businessLocationList)
    {
        List<Address__c> businessLocationListToUpdate = new List<Address__c>();
        
        //Map of account id and list of related business location
        Map<Id, List<Address__c>> mapAccIdAddressList = new Map<Id, List<Address__c>>();
        if(businessLocationList!=NULL && !businessLocationList.isEmpty()) {
            for(Address__c address: businessLocationList) {
                //                List<Address__c> tempAddressList = mapAccIdAddressList.get(add.Account__r.Id);
                //                if(tempAddressList == NULL)
                //                    tempAddressList = new List<Address__c>();
                if(mapAccIdCurrentOwnerId.containsKey(address.Account__r.Id)) {
                    //If the account owner and the business location owner are same. 
                    if(address.OwnerId == mapAccIdCurrentOwnerId.get(address.Account__r.Id)) {
                        if(mapAccIdNewOwnerId != NULL && !mapAccIdNewOwnerId.isEmpty()) {
                            address.OwnerId = mapAccIdNewOwnerId.get(address.Account__r.Id);//Update owner of the open contacts. Now the account owner becomes the Contact owner.
                            businessLocationListToUpdate.add(address);
                        }
                    }
                }
            }
        }
        Database.SaveResult[] srList;
        if(businessLocationListToUpdate != NULL && !businessLocationListToUpdate.isEmpty())
            srList = Database.update(businessLocationListToUpdate,FALSE);
        
        handleInsertionUpdationResult(srList);
    }    
    /*
* Method Name: changeChildAccountOwner
* Input Parameters:  Map<Id, Id>, Map<Id, Id>, List<Account>
* Purpose: This method is used to change the owner of all the child account records related to the Account
* Created By:  Nagarro
*/
  /*  private static void changeChildAccountOwner(Map<Id, Id> mapAccIdCurrentOwnerId, Map<Id, Id> mapAccIdNewOwnerId, List<Account> childAccList){
        
        List<Account> childAccListToUpdate = new List<Account>();
        Map<Id,List<Account>> accIdchildAccMap = new Map<Id,List<Account>>();
        
        if(childAccList!=Null && !childAccList.isEmpty()){
            for(Account acc: childAccList){
                
                List<Account> tempAccList = accIdchildAccMap.get(acc.ParentId);
                if(tempAccList == Null)
                    tempAccList = new List<Account>();
                if(mapAccIdCurrentOwnerId.containsKey(acc.ParentId)){
                    //         if(acc.OwnerId == mapAccIdCurrentOwnerId.get(acc.ParentId)){
                    if(mapAccIdNewOwnerId !=Null && !mapAccIdNewOwnerId.isEmpty()){
                        acc.OwnerId = mapAccIdNewOwnerId.get(acc.ParentId);
                        childAccListToUpdate.add(acc);
                    }
                    //      }
                }
            }
        }
        Database.SaveResult[] srList;
        if(childAccListToUpdate != NULL && !childAccListToUpdate.isEmpty())
            srList = Database.update(childAccListToUpdate,FALSE);
        
        handleInsertionUpdationResult(srList);
        
    }  
    
    
    
    /*
* Method Name: transferOpenOppsOwnedByOthers
* Input Parameters: Set<Id>, Map<Id, Id>, Map<Id, Id>, List<Opportunity>
* Purpose: This method is used to transfer open opportunities owned by others
* Created By:  Nagarro
*/ 
    /*
private static void transferOpenOppsOwnedByOthers(Set<Id> accIdSetTransferNotOwnedOpps, Map<Id, Id> mapAccIdCurrentOwnerId, Map<Id, Id> mapAccIdNewOwnerId, List<Opportunity> opportunityList)
{

// Open opportunity list related to the account
List<Opportunity> openOpportunityList = new List<Opportunity>();
if(opportunityList != NULL && !opportunityList.isEmpty()) {
for(Opportunity opp: opportunityList) {
if(opp.IsClosed == FALSE && accIdSetTransferNotOwnedOpps.contains(opp.AccountId))
openOpportunityList.add(opp);
}
}

List<Opportunity> opportunityListToUpdate = new List<Opportunity>();
//Map of account id and list of related open opportunities
Map<Id, List<Opportunity>> mapAccIdOpenOppList = new Map<Id, List<Opportunity>>();
if(openOpportunityList!=NULL && !openOpportunityList.isEmpty())
{
for(Opportunity opp: openOpportunityList) {
List<Opportunity> tempOpenOppList = mapAccIdOpenOppList.get(opp.AccountId);
if(tempOpenOppList == NULL)
tempOpenOppList = new List<Opportunity>();
if(mapAccIdCurrentOwnerId.containsKey(opp.AccountId)) { 
//If the account owner and the opportunity owner are different. (To fetch open opportunities owned by others (not owned by the account owner))
if(opp.OwnerId != mapAccIdCurrentOwnerId.get(opp.AccountId)) {
if(mapAccIdNewOwnerId != NULL && !mapAccIdNewOwnerId.isEmpty()) {
opp.OwnerId = mapAccIdNewOwnerId.get(opp.AccountId);//Update owner of the open opportunities. Now the account owner becomes the opportunity owner.
opportunityListToUpdate.add(opp);
}
}
}
}
}
if(opportunityListToUpdate != NULL && !opportunityListToUpdate.isEmpty())
updateOpportunities(opportunityListToUpdate);
}

/*
* Method Name: transferAccountOwnersClosedOpps
* Input Parameters: Set<Id>, Map<Id, Id>, Map<Id, Id>, List<Opportunity>
* Purpose: This method is used to transfer the closed opportunities owned by the current account owner to the new account owner
* Created By:  Nagarro
*/ 
    /*
private static void transferAccountOwnersClosedOpps(Set<Id> accIdSetTransferClosedOpps, Map<Id, Id> mapAccIdCurrentOwnerId, Map<Id, Id> mapAccIdNewOwnerId, List<Opportunity> opportunityList)
{
// Closed opportunity list related to the account
List<Opportunity> closedOpportunityList = new List<Opportunity>();
if(opportunityList != NULL && !opportunityList.isEmpty()) {
for(Opportunity opp: opportunityList) {
if(opp.IsClosed == TRUE && accIdSetTransferClosedOpps.contains(opp.AccountId))
closedOpportunityList.add(opp);
}
}
List<Opportunity> opportunityListToUpdate = new List<Opportunity>();
opportunityListToUpdate = transferOpp(closedOpportunityList, mapAccIdCurrentOwnerId, mapAccIdNewOwnerId);
System.debug('opportunityListToUpdate--> @@ '+opportunityListToUpdate);
if(opportunityListToUpdate != NULL && !opportunityListToUpdate.isEmpty())
updateOpportunities(opportunityListToUpdate);       
}

/*
* Method Name: transferOpp
* Input Parameters: List<Opportunity>, Map<Id, Id>, Map<Id, Id>
* Purpose: This is a generic method to transfer opportunities
* Created By:  Nagarro
*/
 /*   private static List<Opportunity> transferOpp(List<Opportunity> opportunityList, Map<Id, Id> mapAccIdCurrentOwnerId, Map<Id, Id> mapAccIdNewOwnerId)
    {
        List<Opportunity> opportunityListToUpdate = new List<Opportunity>();
        //Map of account id and list of related open opportunities
        Map<Id, List<Opportunity>> mapAccIdOppList = new Map<Id, List<Opportunity>>();
        if(opportunityList!=NULL && !opportunityList.isEmpty()) {
            System.debug('@@@-->Check1'+opportunityList);
            for(Opportunity opp: opportunityList) {
                List<Opportunity> tempOpenOppList = mapAccIdOppList.get(opp.AccountId);
                if(tempOpenOppList == NULL)
                    tempOpenOppList = new List<Opportunity>();
                System.debug('@@@--->Check3'+opp.AccountId);
                if(mapAccIdCurrentOwnerId.containsKey(opp.AccountId)) {
                    System.debug('@@@--->Check2'+opp.AccountId);
                    //If the account owner and the opportunity owner are same. (To fetch open opportunities owned by the account owner)
                    //     if(opp.OwnerId == mapAccIdCurrentOwnerId.get(opp.AccountId)) {
                    if(mapAccIdNewOwnerId != NULL && !mapAccIdNewOwnerId.isEmpty()) {
                        opp.OwnerId = mapAccIdNewOwnerId.get(opp.AccountId);//Update owner of the open opportunities. Now the account owner becomes the opportunity owner.
                        opportunityListToUpdate.add(opp);
                    }
                    //   }
                }
            }
        }
        return opportunityListToUpdate;
    }
    
    
    /*
* Method Name: updateOpportunities
* Input Parameters: List<Opportunity>
* Purpose: This is a generic method to update opportunities
* Created By:  Nagarro
*/
  /*  private static void updateOpportunities(List<Opportunity> opportunityListToUpdate)
    {
        Set<Opportunity> oppSetTemp = new Set<Opportunity>();
        oppSetTemp.addAll(opportunityListToUpdate);
        
        List<Opportunity> oppListToUpdate = new List<Opportunity>();
        oppListToUpdate.addAll(oppSetTemp);
        
        Database.SaveResult[] srList;
        if(oppListToUpdate != NULL && !oppListToUpdate.isEmpty())
            srList = Database.update(oppListToUpdate, FALSE);
        System.debug('srList--> '+srList);
        handleInsertionUpdationResult(srList);
    }
    
    /*
* Method Name: transferAllCases
* Input Parameters: Set<Id>, Map<Id, Id>, Map<Id, Id>, List<Case>
* Purpose: This method is used to transfer all the cases
* Created By:  Nagarro
*/
    /*
private static void transferAllCases(Set<Id> accIdSetTransferAccountOwnerCases, Map<Id, Id> mapAccIdCurrentOwnerId, Map<Id, Id> mapAccIdNewOwnerId, List<Case> caseList)
{
List<Case> allCaseList = new List<Case>();
if(caseList != NULL && !caseList.isEmpty()) {
for(Case c: caseList) {
if(accIdSetTransferAccountOwnerCases.contains(c.AccountId))
allCaseList.add(c); 
}
}
transferCases(caseList, mapAccIdCurrentOwnerId, mapAccIdNewOwnerId);
}

/*
* Method Name: transferAllOpenCases
* Input Parameters: Set<Id>, Map<Id, Id>, Map<Id, Id>, List<Case>
* Purpose: This method is used to transfer the open cases associated with account
* Created By:  Nagarro
*/
    /*
private static void transferAllOpenCases(Set<Id> accIdSetTransferAccountOwnerOpenCases, Map<Id, Id> mapAccIdCurrentOwnerId, Map<Id, Id> mapAccIdNewOwnerId, List<Case> caseList)
{
List<Case> openCaseList = new List<Case>();
if(caseList != NULL && !caseList.isEmpty()) {
for(Case c: caseList) {
if(accIdSetTransferAccountOwnerOpenCases.contains(c.AccountId) && !c.isClosed)
openCaseList.add(c); 
}
}
transferCases(openCaseList, mapAccIdCurrentOwnerId, mapAccIdNewOwnerId);       
}

/*
* Method Name: transferCases
* Input Parameters: List<Case>, Map<Id, Id>, Map<Id, Id>
* Purpose: This is a generic method to transfer the cases
* Created By:  Nagarro
*/
    /*
private static void transferCases(List<Case> caseList, Map<Id, Id> mapAccIdCurrentOwnerId, Map<Id, Id> mapAccIdNewOwnerId)
{
List<Case> caseListToUpdate = new List<Case>();
//Map of account id and list of related open cases
Map<Id, List<Case>> mapAccIdOpenCaseList = new Map<Id, List<Case>>();
if(caseList!=NULL && !caseList.isEmpty()) {
for(Case c: caseList) {
if(mapAccIdNewOwnerId != NULL && !mapAccIdNewOwnerId.isEmpty()) {
if(mapAccIdNewOwnerId.containsKey(c.AccountId)){
c.ownerId = mapAccIdNewOwnerId.get(c.AccountId);
caseListToUpdate.add(c);
}
}
}
}

if(caseListToUpdate != NULL && !caseListToUpdate.isEmpty())
updateCases(caseListToUpdate);
}

/*
* Method Name: updateCases
* Input Parameters: List<Case>
* Purpose: This is a generic method to update cases
* Created By:  Nagarro
*/
    /*
private static void updateCases(List<Case> caseListToUpdate)
{
Set<Case> caseSetTemp = new Set<Case>();
caseSetTemp.addAll(caseListToUpdate);

List<Case> cListToUpdate = new List<Case>();
cListToUpdate.addAll(caseSetTemp);

Database.SaveResult[] srList;
if(cListToUpdate != NULL && !cListToUpdate.isEmpty())
srList = Database.update(cListToUpdate, FALSE);

handleInsertionUpdationResult(srList);
}

/*
* Method Name: keepAccountTeams
* Input Parameters: Set<Id>, Map<Id, Id>, Map<Id, Id>, Set<Id>
* Purpose: If the account owner is present in the Account Team, then he will be replaced with the new owner
* Created By:  Nagarro
*/
    public static void keepAccountTeams(Set<Id> accIdSetKeepAccountTeam, Map<Id, Id> mapAccIdCurrentOwnerId, Map<Id, Id> mapAccIdNewOwnerId, Set<Id> accIdSet)
    {
        
        List<AccountTeamMember> accTeamMemList = new List<AccountTeamMember>();
        Map<String,User_Region_to_Opp_Role__c> regionToRoleMap = new Map<String,User_Region_to_Opp_Role__c>();
        List<User> userdetail = new List<User>();
        //Id proposedOwner;
        List<Id> proposedOwnerIdList = new List<Id>();
        Map<Id,String> userToRegionMap = new Map<Id,String>();
        Map<Id,List<AccountTeamMember>> accIdToMemberMap = new Map<Id,List<AccountTeamMember>>();
        Map<String, AccountTeamMember> memberRoleToAccMem = new Map<String, AccountTeamMember>();
        Map<String, AccountTeamMember> memberIdToAccMem = new Map<String, AccountTeamMember>();
        Set<String> roleSet = new Set<String>();
        Set<String> saleProfiles = new Set<String>();
        Set<String> adminProfiles = new Set<String>();
        Set<Id> parentAccountIdSet = new Set<Id>();
        Map<Id,String> userToProfileMap = new Map<Id, String>();
        Map<Id, String> userToNameMap = new Map<Id, String>();
        List<AccountTeamMember> accTeamMemberListToUpdate = new List<AccountTeamMember>();
        List<AccountTeamMember> accTeamMemberListToInsert = new List<AccountTeamMember>();
        List<AccountTeamMember> accTeamMemberListToDelete = new List<AccountTeamMember>();
        
        regionToRoleMap = User_Region_to_Opp_Role__c.getAll();
        saleProfiles.addAll(Label.Sales_Profiles.split(','));
        adminProfiles.addAll(Label.System_Admin_User.split(','));
        System.debug('Sale profile '+saleProfiles);
        List<Account> accList = [Select Id, ParentId from Account where Id In: accIdSetKeepAccountTeam];
        
        if(accList != null){
            for(Account acc: accList){
                
                if(acc.ParentId == Null)
                    parentAccountIdSet.add(acc.Id);
            }
        }
        
        System.debug('Parnt Account set '+parentAccountIdSet);
        if(parentAccountIdSet != NULL && !parentAccountIdSet.isEmpty())
            accTeamMemList = [Select Id, AccountId, UserId, User.Region__c, User.Profile.Name, TeamMemberRole from AccountTeamMember where AccountId in: parentAccountIdSet];
        
        System.debug('Account team list '+accTeamMemList);
        if(accTeamMemList != NULL && !accTeamMemList.isEmpty()){
            
            for(AccountTeamMember accMemR: accTeamMemList){
                
                //roleSet.add(accMemR.TeamMemberRole);
                
                memberRoleToAccMem.put(accMemR.TeamMemberRole, accMemR);
                System.debug('Account memeber and account Id '+accMemR.User.Profile.Name);
                if(saleProfiles.contains(accMemR.User.Profile.Name)){
                    memberIdToAccMem.put(accMemR.TeamMemberRole + accMemR.AccountId, accMemR);
                }
                if(!accIdToMemberMap.containsKey(accMemR.AccountId)){
                    
                    accIdToMemberMap.put(accMemR.AccountId, new List<AccountTeamMember>());
                }
                accIdToMemberMap.get(accMemR.AccountId).add(accMemR);
            }
        }
        System.debug('Account id to list member '+accIdToMemberMap);
        System.debug('Role to meber '+memberIdToAccMem);
        for(Id accId1: parentAccountIdSet){
            
            if(mapAccIdNewOwnerId.containsKey(accId1) && mapAccIdNewOwnerId.get(accId1) != Null){
                
                // proposedOwner = mapAccIdNewOwnerId.get(accId1);
                proposedOwnerIdList.add(mapAccIdNewOwnerId.get(accId1));                
            }
        }  
        userdetail = [Select Id, Region__c, Profile.Name, Name from User where Id IN: proposedOwnerIdList];
        
        System.debug('User details '+userdetail);
        for(User u: userdetail){
            
            userToRegionMap.put(u.Id, u.Region__c);
            userToProfileMap.put(u.Id, u.Profile.Name);
            userToNameMap.put(u.Id, u.Name);
            
        }
        System.debug('@^&@^ '+userToProfileMap);
        // }
        for(Id accId: parentAccountIdSet){
            
            if(accIdToMemberMap.containsKey(accId) && !accIdToMemberMap.get(accId).isEmpty())
            {
                for(AccountTeamMember accTeamMember: accIdToMemberMap.get(accId))
                {
                    String currentOwnerId = mapAccIdCurrentOwnerId.get(accTeamMember.AccountId);
                    String proposedOwnerId = mapAccIdNewOwnerId.get(accTeamMember.AccountId);
                    
                    if(currentOwnerId != proposedOwnerId){                     //for reparenting case
                        if(proposedOwnerId.contains(accTeamMember.UserId))
                        {
                            if(userToRegionMap.get(accTeamMember.UserId) != Null && accTeamMember.TeamMemberRole != regionToRoleMap.get(userToRegionMap.get(accTeamMember.UserId)).Opp_Role__c && saleProfiles.contains(userToProfileMap.get(proposedOwnerId))){
                                
                                if(memberIdToAccMem.containsKey(regionToRoleMap.get(userToRegionMap.get(accTeamMember.UserId)).Opp_Role__c + accTeamMember.AccountId)){
                                    
                                    accTeamMemberListToDelete.add(memberIdToAccMem.get(regionToRoleMap.get(userToRegionMap.get(accTeamMember.UserId)).Opp_Role__c + accTeamMember.AccountId));
                                    
                                    if(!deletedAccMemberMap.containsKey(accTeamMember.AccountId)){
                                        
                                        deletedAccMemberMap.put(accTeamMember.AccountId, new List<AccountTeamMember>());
                                    }
                                    deletedAccMemberMap.get(accTeamMember.AccountId).add(memberIdToAccMem.get(regionToRoleMap.get(userToRegionMap.get(accTeamMember.UserId)).Opp_Role__c + accTeamMember.AccountId));
                                    
                                }
                                
                                accTeamMember.TeamMemberRole = regionToRoleMap.get(userToRegionMap.get(accTeamMember.UserId)).Opp_Role__c;
                                
                            }
                            else if(userToRegionMap.get(accTeamMember.UserId) == Null && accTeamMember.TeamMemberRole != ConstantClass.TEAM_MEMBER_ROLE_AS_ADMIN && saleProfiles.contains(userToProfileMap.get(proposedOwnerId))){
                                
                                if(memberIdToAccMem.containsKey(ConstantClass.TEAM_MEMBER_ROLE_AS_ADMIN + accTeamMember.AccountId)){
                                    
                                    accTeamMemberListToDelete.add(memberIdToAccMem.get(ConstantClass.TEAM_MEMBER_ROLE_AS_ADMIN + accTeamMember.AccountId));
                                    if(!deletedAccMemberMap.containsKey(accTeamMember.AccountId)){
                                        
                                        deletedAccMemberMap.put(accTeamMember.AccountId, new List<AccountTeamMember>());
                                    }
                                    deletedAccMemberMap.get(accTeamMember.AccountId).add(memberIdToAccMem.get(ConstantClass.TEAM_MEMBER_ROLE_AS_ADMIN + accTeamMember.AccountId));
                                }
                                accTeamMember.TeamMemberRole = ConstantClass.TEAM_MEMBER_ROLE_AS_ADMIN;
                                
                            }
                            accTeamMemberListToUpdate.add(accTeamMember);
                            if(!updatedAccMemberMap.containsKey(accTeamMember.AccountId)){
                                
                                updatedAccMemberMap.put(accTeamMember.AccountId, new List<AccountTeamMember>());
                            }
                            updatedAccMemberMap.get(accTeamMember.AccountId).add(accTeamMember);
                            
                        }
                        
                        //The below code is kept inside the above if because the proposed owner will only be added in the AccountTeamMember if current owner is present.
                        //If current owner is not present, it will not be replaced by the proposed owner.
                        //  String proposedOwnerId = mapAccIdNewOwnerId.get(accTeamMember.AccountId);
                        if(!proposedOwnerId.contains(accTeamMember.UserId) && !adminProfiles.contains(userToNameMap.get(proposedOwnerId)) && saleProfiles.contains(userToProfileMap.get(proposedOwnerId)))
                        {
                            System.debug('Check the entry 1 $$%$$#$W$@');
                            AccountTeamMember accTeamMem= new AccountTeamMember();
                            //     if(regionToRoleMap.containsKey(accTeamMember.User.Region__c) && userToRegionMap.get(proposedOwnerId) != Null){
                            if(userToRegionMap.get(proposedOwnerId) != Null && regionToRoleMap.containsKey(userToRegionMap.get(proposedOwnerId))){
                                
                                accTeamMem.TeamMemberRole = regionToRoleMap.get(userToRegionMap.get(proposedOwnerId)).Opp_Role__c;
                                
                                if(accTeamMember.TeamMemberRole == regionToRoleMap.get(userToRegionMap.get(proposedOwnerId)).Opp_Role__c){
                                    
                                    accTeamMemberListToDelete.add(accTeamMember);
                                    if(!deletedAccMemberMap.containsKey(accTeamMember.AccountId)){
                                        
                                        deletedAccMemberMap.put(accTeamMember.AccountId, new List<AccountTeamMember>());
                                    }
                                    deletedAccMemberMap.get(accTeamMember.AccountId).add(accTeamMember);
                                }
                            }
                            else{
                                if(accTeamMember.TeamMemberRole == ConstantClass.TEAM_MEMBER_ROLE_AS_ADMIN){
                                    
                                    accTeamMemberListToDelete.add(accTeamMember);
                                    if(!deletedAccMemberMap.containsKey(accTeamMember.AccountId)){
                                        
                                        deletedAccMemberMap.put(accTeamMember.AccountId, new List<AccountTeamMember>());
                                    }
                                    deletedAccMemberMap.get(accTeamMember.AccountId).add(accTeamMember);
                                }
                                
                                accTeamMem.TeamMemberRole = ConstantClass.TEAM_MEMBER_ROLE_AS_ADMIN;
                            }
                            accTeamMem.AccountAccessLevel = ConstantClass.EDIT_PERMISSION;
                            accTeamMem.OpportunityAccessLevel = ConstantClass.EDIT_PERMISSION;
                            accTeamMem.CaseAccessLevel = ConstantClass.EDIT_PERMISSION;
                            accTeamMem.ContactAccessLevel = ConstantClass.EDIT_PERMISSION;
                            accTeamMem.UserId = proposedOwnerId;
                            accTeamMem.AccountId = accTeamMember.AccountId;
                            accTeamMemberListToInsert.add(accTeamMem);
                            
                            if(!insertedAccMemberMap.containsKey(accTeamMem.AccountId)){
                                
                                insertedAccMemberMap.put(accTeamMem.AccountId, new List<AccountTeamMember>());
                            }
                            insertedAccMemberMap.get(accTeamMem.AccountId).add(accTeamMem);
                        }
                        else if(!proposedOwnerId.contains(accTeamMember.UserId) && adminProfiles.contains(userToNameMap.get(proposedOwnerId)) && currentOwnerId.contains(accTeamMember.UserId)){
                            
                            accTeamMemberListToDelete.add(accTeamMember);
                            if(!deletedAccMemberMap.containsKey(accTeamMember.AccountId)){
                                
                                deletedAccMemberMap.put(accTeamMember.AccountId, new List<AccountTeamMember>());
                            }
                            deletedAccMemberMap.get(accTeamMember.AccountId).add(accTeamMember);
                        }
                        //}
                    }
                }
            }
            
            else{
                
                
                //for(Id accId: accIdSetKeepAccountTeam){
                
                
                String currentOwnerId = mapAccIdCurrentOwnerId.get(accId);
                String proposedOwnerId = mapAccIdNewOwnerId.get(accId);
                
                if(currentOwnerId != proposedOwnerId && !adminProfiles.contains(userToNameMap.get(proposedOwnerId)) && saleProfiles.contains(userToProfileMap.get(proposedOwnerId))){
                    
                    AccountTeamMember accMem = new AccountTeamMember();
                    if(userToRegionMap.get(proposedOwnerId) != Null){
                        
                        accMem.TeamMemberRole = regionToRoleMap.get(userToRegionMap.get(proposedOwnerId)).Opp_Role__c;
                    }
                    else{
                        
                        accMem.TeamMemberRole = ConstantClass.TEAM_MEMBER_ROLE_AS_ADMIN;
                    }
                    
                    accMem.AccountAccessLevel = ConstantClass.EDIT_PERMISSION;
                    accMem.OpportunityAccessLevel = ConstantClass.EDIT_PERMISSION;
                    accMem.CaseAccessLevel = ConstantClass.EDIT_PERMISSION;
                    accMem.ContactAccessLevel = ConstantClass.EDIT_PERMISSION;
                    accMem.UserId = proposedOwnerId;
                    accMem.AccountId = accId;
                    accTeamMemberListToInsert.add(accMem);
                    if(!insertedAccMemberMap.containsKey(accMem.AccountId)){
                        
                        insertedAccMemberMap.put(accMem.AccountId, new List<AccountTeamMember>());
                    }
                    insertedAccMemberMap.get(accMem.AccountId).add(accMem);
                }
                //}
            }
        }
        Set<AccountTeamMember> accTeamMemSet = new Set<AccountTeamMember>();
        accTeamMemSet.addAll(accTeamMemberListToDelete);
        accTeamMemberListToDelete.clear();
        accTeamMemberListToDelete.addAll(accTeamMemSet);
        if(accTeamMemberListToDelete != Null){
            
            AccountTeamTriggerHandler.validationCheck = FALSE;
            WithoutSharingUtility.deleteAccountTeamMembers(accTeamMemberListToDelete);  
        }
        Database.SaveResult[] srListToInsert;
        if(accTeamMemberListToInsert != NULL && !accTeamMemberListToInsert.isEmpty()){
            
            AccountTeamTriggerHandler.roleCheck = FALSE;
            srListToInsert = Database.insert(accTeamMemberListToInsert, FALSE);
            
        }
        handleInsertionUpdationResult(srListToInsert);
        
        Database.SaveResult[] srListToUpdate;
        if (Schema.sObjectType.Account.isUpdateable() == true){    //Best Practice - Check if Updateable
            if(accTeamMemberListToUpdate != NULL && !accTeamMemberListToUpdate.isEmpty()){
                
                AccountTeamTriggerHandler.roleCheck = FALSE;
                srListToUpdate = Database.update(accTeamMemberListToUpdate, FALSE);
            }
            handleInsertionUpdationResult(srListToUpdate);
        }
        
    }
    
    /*
* Method Name: handleDeletionResult
* Input Parameters: Database.DeleteResult[] srList
* Purpose: This method is used to handle deletion result
* Created By:  Nagarro
*/
    public static void handleDeletionResult(Database.DeleteResult[] srList)
    {
        // Iterate through each returned result
        if(srList != NULL && !srList.isEmpty()) {
            for (Database.DeleteResult sr : srList) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully deleted records. ' + sr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    }
                }
            }
        }
    }
    
    /*
* Method Name: handleInsertionUpdationResult
* Input Parameters: Database.SaveResult[] srList
* Purpose: This method is used to handle insertion and updation result
* Created By:  Nagarro
*/
    public static void handleInsertionUpdationResult(Database.SaveResult[] srList)
    {
        // Iterate through each returned result
        if(srList != NULL && !srList.isEmpty()) {
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully inserted record. Record Id: ' + sr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    }
                }
            }
        }
    }     
}