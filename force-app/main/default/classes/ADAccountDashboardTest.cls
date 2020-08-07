/*
* Name: ADAccountDashboardTest
* Purpose: Test class for account dashbaord classes
* Author: Nagarro
* Created Date: 23-Jan-2019
* Modification History
*  Modification #   Story/Defect#      Modified By     Date   Description
*/
@isTest(seeAllData=false)
public class ADAccountDashboardTest {
    //Test method for GetCurrentYear.
    //Class : ADAccountDashboardController
    public static testMethod void testGetCurrentYear() {
        System.assert(ADAccountDashboardController.getCurrentYear() == String.valueOf(Date.today().year()));
    }
    
    //Test method for GetOpportunityChartData
    //Class : ADOpportunityPipelineChartController
    public static testMethod void testGetOpportunityChartData() {
        createOpportunityLineItem();
        
        ADMasterFilterWrapper objMasterFilterWrapper = new ADMasterFilterWrapper();
        objMasterFilterWrapper.strSelectedYear = String.valueOf(Date.today().year());
        ADOpportunityPipelineChartDataWrapper objOpportunityPipelineChartDataWrapper = ADOpportunityPipelineChartController.getOpportunityChartData([SELECT Id FROM Account WHERE NAME = 'Test Account'][0].Id, objMasterFilterWrapper);
        System.assert(objOpportunityPipelineChartDataWrapper.lstOpportunityStage.contains('Prospecting'));
        System.assert(objOpportunityPipelineChartDataWrapper.lstOpportunityPipelineAmountByStageActual.contains(2.00));
    }
    
    //Test method for GetOpportunityChartData by applying size filter.
    //Class : ADOpportunityPipelineChartController
    public static testMethod void testGetOpportunityChartDataSizeFilter() {
        createOpportunityLineItem();
        Test.startTest();
        ADMasterFilterWrapper objMasterFilterWrapper = new ADMasterFilterWrapper();
        objMasterFilterWrapper.strSelectedYear = String.valueOf(Date.today().year());
        
        objMasterFilterWrapper.strSelectedOppSizeFilterOperator = '>=';
        objMasterFilterWrapper.strOppSizeVal = String.valueOf((2.00/(Integer.valueOf(Label.AD_AMOUNT_CONVERTER))));
        ADOpportunityPipelineChartDataWrapper objOpportunityPipelineChartDataWrapper = ADOpportunityPipelineChartController.getOpportunityChartData([SELECT Id FROM Account WHERE NAME = 'Test Account'][0].Id, objMasterFilterWrapper);
        System.assert(objOpportunityPipelineChartDataWrapper.lstOpportunityPipelineAmountByStageActual.contains(2.00));
        
        system.assertEquals(objOpportunityPipelineChartDataWrapper.intMaxCount,null);
        system.assertEquals(objOpportunityPipelineChartDataWrapper.intChartInterval,null);
        
        objMasterFilterWrapper.strSelectedOppSizeFilterOperator = '>';
        objMasterFilterWrapper.strOppSizeVal = String.valueOf((1.00/(Integer.valueOf(Label.AD_AMOUNT_CONVERTER))));
        objOpportunityPipelineChartDataWrapper = ADOpportunityPipelineChartController.getOpportunityChartData([SELECT Id FROM Account WHERE NAME = 'Test Account'][0].Id, objMasterFilterWrapper);
        System.assert(objOpportunityPipelineChartDataWrapper.lstOpportunityPipelineAmountByStageActual.contains(2.00));
        
        objMasterFilterWrapper.strSelectedOppSizeFilterOperator = '<';
        objMasterFilterWrapper.strOppSizeVal = String.valueOf((3.00/Integer.valueOf(Label.AD_AMOUNT_CONVERTER)));
        objOpportunityPipelineChartDataWrapper = ADOpportunityPipelineChartController.getOpportunityChartData([SELECT Id FROM Account WHERE NAME = 'Test Account'][0].Id, objMasterFilterWrapper);
        System.assert(objOpportunityPipelineChartDataWrapper.lstOpportunityPipelineAmountByStageActual.contains(2.00));
        
        objMasterFilterWrapper.strSelectedOppSizeFilterOperator = '<=';
        objMasterFilterWrapper.strOppSizeVal = String.valueOf((2.00/(Integer.valueOf(Label.AD_AMOUNT_CONVERTER))));
        objOpportunityPipelineChartDataWrapper = ADOpportunityPipelineChartController.getOpportunityChartData([SELECT Id FROM Account WHERE NAME = 'Test Account'][0].Id, objMasterFilterWrapper);
        System.assert(objOpportunityPipelineChartDataWrapper.lstOpportunityPipelineAmountByStageActual.contains(2.00));
        
        objMasterFilterWrapper.strSelectedOppSizeFilterOperator = '=';
        objMasterFilterWrapper.strOppSizeVal = String.valueOf((2.00/(Integer.valueOf(Label.AD_AMOUNT_CONVERTER))));
        objOpportunityPipelineChartDataWrapper = ADOpportunityPipelineChartController.getOpportunityChartData([SELECT Id FROM Account WHERE NAME = 'Test Account'][0].Id, objMasterFilterWrapper);
        System.assert(objOpportunityPipelineChartDataWrapper.lstOpportunityPipelineAmountByStageActual.contains(2.00));
        
        Test.stopTest();
    }
    
    //Test method for GetOpportunityChartData by applying all year filter.
    //Class : ADOpportunityPipelineChartController
    public static testMethod void testGetOpportunityForAllYear() {
        createOpportunityLineItem();
        
        ADMasterFilterWrapper objMasterFilterWrapper = new ADMasterFilterWrapper();
        objMasterFilterWrapper.strSelectedYear = Label.AD_PICKLIST_VAL_ALL_YEAR;
        ADOpportunityPipelineChartDataWrapper objOpportunityPipelineChartDataWrapper = ADOpportunityPipelineChartController.getOpportunityChartData([SELECT Id FROM Account WHERE NAME = 'Test Account'][0].Id, objMasterFilterWrapper);
        System.assert(objOpportunityPipelineChartDataWrapper.lstOpportunityPipelineAmountByStageActual.contains(2.00));
    }
    
    //Test method for GetOpportunityChartData for default year.
    //Class : ADOpportunityPipelineChartController
    public static testMethod void testGetOpportunityForDefaultYear() {
        createOpportunityLineItem();
        
        ADMasterFilterWrapper objMasterFilterWrapper = new ADMasterFilterWrapper();
        objMasterFilterWrapper.strSelectedYear = null;
        ADOpportunityPipelineChartDataWrapper objOpportunityPipelineChartDataWrapper = ADOpportunityPipelineChartController.getOpportunityChartData([SELECT Id FROM Account WHERE NAME = 'Test Account'][0].Id, objMasterFilterWrapper);
        System.assert(objOpportunityPipelineChartDataWrapper.lstOpportunityPipelineAmountByStageActual.contains(2.00));
    }
    
    //Test method for GetAllChildAccounts.
    //Class : ADAccountDashboardUtil
    public static testMethod void testGetAllChildAccounts() {
        System.assert(ADAccountDashboardUtil.getAllChildAccounts([SELECT Id FROM Account WHERE NAME = 'Test Account'][0].Id).size() == 1);
    }
    
    //Test method for GetAllActiveUsers
    //Class : ADAccountDashboardUtil
    public static testMethod void testGetAllActiveUsers() {
        System.assert(ADAccountDashboardUtil.getAllActiveUsers() != null);
    }
    
    //Test method for GetPicklistYear
    //Class : ADAccountDashboardUtil
    public static testMethod void testGetPicklistYear() {
        System.assert(ADAccountDashboardUtil.getPicklistYear().contains(String.valueOf(Date.today().year())));
    }
    
    //Test method for account filter by account.
    //Class : ADAccountDashboardUtil
    public static testMethod void testAccountFilterAccNameWise() {
        Map<Id, Account> mapAccount = new Map<Id, Account>();
        mapAccount = new Map<Id, Account>([SELECT Id From Account]);
        ADMasterFilterWrapper objMasterFilterWrapper = new ADMasterFilterWrapper();
        objMasterFilterWrapper.strSelectedTopFilter = Label.AD_PICKLIST_VAL_FILTER_BY_ACCOUNT_NAME;
        objMasterFilterWrapper.lstSelectedAccounts = new List<Id>{[SELECT Id FROM Account WHERE NAME = 'Child Test Account'][0].Id};
            List<Id> lstFilteredAccounts = ADAccountDashboardUtil.applyAccountFilter(mapAccount, objMasterFilterWrapper);
        System.assert(new Set<Id>(lstFilteredAccounts).contains([SELECT Id From Account WHERE Name = 'Child Test Account'][0].Id));
    }
    
    //Test method for account filter by owner.
    //Class : ADAccountDashboardUtil
    public static testMethod void testAccountFilterAccOwnerWise() {
        Map<Id, Account> mapAccount = new Map<Id, Account>();
        mapAccount = new Map<Id, Account>([SELECT Id, OwnerId From Account]);
        ADMasterFilterWrapper objMasterFilterWrapper = new ADMasterFilterWrapper();
        objMasterFilterWrapper.strSelectedTopFilter = Label.AD_PICKLIST_VAL_FILTER_BY_ACCOUNT_OWNER;
        objMasterFilterWrapper.lstSelectedOwners = new List<Id>{[SELECT Id, OwnerId FROM Account WHERE NAME = 'Child Test Account'][0].OwnerId};
            List<Id> lstFilteredAccounts = ADAccountDashboardUtil.applyAccountFilter(mapAccount, objMasterFilterWrapper);
        System.assert(new Set<Id>(lstFilteredAccounts).contains([SELECT Id From Account WHERE Name = 'Child Test Account'][0].Id));
    }
    
    //Test method for GetAllChildAccountsWithParent
    //Class : ADAccountDashboardUtil
    public static testMethod void testGetAllChildAccountsWithParent() {
        Account objAccount = [SELECT Id From Account WHERE Name = 'Test Account'][0];
        List<Account> lstAccounts = ADAccountDashboardUtil.getAllChildAccountsWithParent(objAccount.Id);
        System.assert(lstAccounts[0].Id == objAccount.Id);
    }
    
    //Test data setup for test class execution.
    @testSetup
    public static void testDataSetup() {
        //Create Account
        List<Account> lstTestAccounts = TestDataUtility.createAccount('Test Account', 'Apparel', null, false, 1);
        
        //Create Child Account
        TestDataUtility.createAccount('Child Test Account', 'Apparel', lstTestAccounts[0].Id, false, 1);
        
        DescribeFieldResult describe = Address__c.State_Picklist__c.getDescribe();
        List<PicklistEntry> availableValues = describe.getPicklistValues();
        
        //Create business location
        List<Address__c> lstAddress = TestDataUtility.createBusinessLocation(lstTestAccounts, 'Test Address line 1', 'Test City', availableValues[0].getValue(), '123456', null, 'US', 1);
        
        //Create Contact
        List<Contact> lstTestContact =  TestDataUtility.createContact(null, lstTestAccounts[0].Id, lstAddress, null, 'Test LastName', 'test@testExample.com', null, false, null, 1);
        
        //Create Opportunity
        Id idOpportunityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Record').getRecordTypeId();
        List<Opportunity> lstTestOpportunity = TestDataUtility.createOpportunity(idOpportunityRecordTypeId, null, 'Test Opportunity', lstTestContact[0], lstTestAccounts[0], 'Prospecting', 'USA - United States', Date.today(), null,'Air', null, false, 1);
        
        //Create product
        List<Product2> lstProducts = TestDataUtility.createProduct(new List<String>{'Air'}); 
    }
    
    private static void createOpportunityLineItem() {
        //Create Opportunity LineItem
        TestDataUtility.createOpportunityLineItem([SELECT Id FROM Opportunity][0], [SELECT Id FROM Product2], 1, 2);
    }
    
    //Create Task data for class: ADTasksController
    private static List<Task> createTask() {
        List<Task> taskList = TestDataUtility.createTask('Test Type', null, 'Task description 1', 'High', 'Open', [SELECT Id From Account WHERE Name = 'Test Account'][0].Id, 'Task subject 1', System.today(), [SELECT Id From Contact WHERE LastName = 'Test LastName'][0].Id, null, 1);
        List<Task> taskList2 = TestDataUtility.createTask('Test Type1', null, 'Task description 1', 'High', 'Completed', [SELECT Id From Account WHERE Name = 'Test Account'][0].Id, 'Task subject 1', System.today(), [SELECT Id From Contact WHERE LastName = 'Test LastName'][0].Id, null, 1);
        List<Task> taskList3 = TestDataUtility.createTask('Test Type1', null, 'Task description 1', 'High', 'Open', [SELECT Id From Account WHERE Name = 'Test Account'][0].Id, 'Task subject 1', System.today()-2, [SELECT Id From Contact WHERE LastName = 'Test LastName'][0].Id, null, 1);
        taskList.addAll(taskList2);
        taskList.addAll(taskList3);
        return taskList;
    }
    
    //Test method 
    //Class: ADTasksController
    //Method: fetchTasks
    public static testMethod void testFetchTask() {
        ADMasterFilterWrapper objMasterFilterWrapper = new ADMasterFilterWrapper();
        objMasterFilterWrapper.strSelectedTopFilter = Label.AD_PICKLIST_VAL_FILTER_BY_ACCOUNT_NAME;
        objMasterFilterWrapper.lstSelectedAccounts = new List<Id>{[SELECT Id FROM Account WHERE Name = 'Test Account'][0].Id};
            objMasterFilterWrapper.strSelectedYear = String.valueOf(Date.today().year());   
        
        Map<Id, Account> mapAccount = new Map<Id, Account>();
        mapAccount = new Map<Id, Account>([SELECT Id From Account]);
        List<Id> lstFilteredAccounts = ADAccountDashboardUtil.applyAccountFilter(mapAccount, objMasterFilterWrapper);
        
        ADTasksController.fetchTasks(lstFilteredAccounts[0], objMasterFilterWrapper);
        System.assert(new Set<Id>(lstFilteredAccounts).contains([SELECT Id From Account WHERE Name = 'Test Account'][0].Id));
    }
    
    //Test method 
    //Class: ADTasksController
    //Method: applyFilter
    public static testMethod void testTaskFilter() {
        ADMasterFilterWrapper objMasterFilterWrapper = new ADMasterFilterWrapper();
        objMasterFilterWrapper.strSelectedTopFilter = Label.AD_PICKLIST_VAL_FILTER_BY_ACCOUNT_NAME;
        objMasterFilterWrapper.lstSelectedAccounts = new List<Id>{[SELECT Id FROM Account WHERE Name = 'Test Account'][0].Id};
            objMasterFilterWrapper.strSelectedYear = String.valueOf(Date.today().year());   
        
        Map<Id, Account> mapAccount = new Map<Id, Account>();
        mapAccount = new Map<Id, Account>([SELECT Id From Account]);
        List<Id> lstFilteredAccounts = ADAccountDashboardUtil.applyAccountFilter(mapAccount, objMasterFilterWrapper);
        
        System.assert(new Set<Id>(lstFilteredAccounts).contains([SELECT Id From Account WHERE Name = 'Test Account'][0].Id));
        
        List<Task> taskList = new List<Task>();
        taskList = createTask();
        
        System.assertEquals(!taskList.isEmpty(), taskList.size()>0);
        
        List<sObject> lstSelectedOwners = new List<sObject>{[SELECT Id, OwnerId FROM Account WHERE NAME = 'Test Account'][0]};
            Date startDate = System.today()-2;
        Date endDate = System.today()+2;
        String dateFilter = ConstantClass.DATE_FILTER_CREATED_DATE;
        ADTasksController.applyFilter(lstFilteredAccounts[0], startDate, endDate, dateFilter, lstSelectedOwners, taskList, Label.AD_TASK_STATUS_ALL, null);
        
        dateFilter = ConstantClass.DATE_FILTER_CREATED_DATE;
        ADTasksController.applyFilter(lstFilteredAccounts[0], startDate, endDate, dateFilter, null, taskList, Label.AD_TASK_STATUS_ALL, 'Test');
        
        dateFilter = ConstantClass.DATE_FILTER_DUE_DATE;
        ADTasksController.applyFilter(lstFilteredAccounts[0], startDate, endDate, dateFilter, lstSelectedOwners, taskList, Label.AD_TASK_STATUS_OPEN, null);
        
        dateFilter = ConstantClass.DATE_FILTER_DUE_DATE;
        ADTasksController.applyFilter(lstFilteredAccounts[0], startDate, endDate, dateFilter, null, taskList, Label.AD_TASK_STATUS_OPEN, '');
        
        ADTasksController.applyFilter(lstFilteredAccounts[0], startDate, endDate, dateFilter, null, taskList, Label.AD_TASK_STATUS_OPEN, 'Test');
        
        dateFilter ='';
        ADTasksController.applyFilter(lstFilteredAccounts[0], startDate, endDate, dateFilter, null, taskList, Label.AD_TASK_STATUS_OVERDUE, null);
        
        dateFilter ='';
        ADTasksController.applyFilter(lstFilteredAccounts[0], startDate, endDate, dateFilter, null, taskList, Label.AD_TASK_STATUS_OVERDUE, 'Test');
        
        dateFilter ='';
        lstSelectedOwners = NULL;
        ADTasksController.applyFilter(lstFilteredAccounts[0], startDate, endDate, dateFilter, lstSelectedOwners, taskList, Label.AD_TASK_STATUS_COMPLETED, null);
        
        ADTasksController.applyFilter(lstFilteredAccounts[0], startDate, endDate, dateFilter, null, taskList, Label.AD_TASK_STATUS_COMPLETED, 'Test');
    }
    
    //Test method 
    //Class: ADTasksController
    //Method: applySorting
    public static testMethod void testTaskSorting() {
        List<Task> taskList = new List<Task>();
        taskList = createTask();
        System.assertEquals(!taskList.isEmpty(), taskList.size()>0);
        
        String sortingDateOption = ConstantClass.SORTING_DUE_DATE_ASC;
        ADTasksController.applySorting(sortingDateOption, taskList);
        
        sortingDateOption = ConstantClass.SORTING_CREATED_DATE_ASC;
        ADTasksController.applySorting(sortingDateOption, taskList);
        
        sortingDateOption = ConstantClass.SORTING_DUE_DATE_DESC;
        ADTasksController.applySorting(sortingDateOption, taskList);
        
        sortingDateOption = ConstantClass.SORTING_CREATED_DATE_DESC;
        ADTasksController.applySorting(sortingDateOption, taskList);
    }
    
    //Create ContentNote data for class: ADNotesController
    public static ContentNote createContentNote(){
        return TestDataUtility.createContentNote('Test', 'Hello', 1)[0];
    }
    
    //Test method 
    //Class: ADNotesController
    //Method: fetchNotes
    public static testMethod void testFetchNotes() {
        ADMasterFilterWrapper objMasterFilterWrapper = new ADMasterFilterWrapper();
        objMasterFilterWrapper.strSelectedTopFilter = Label.AD_PICKLIST_VAL_FILTER_BY_ACCOUNT_NAME;
        objMasterFilterWrapper.lstSelectedAccounts = new List<Id>{[SELECT Id FROM Account WHERE Name = 'Test Account'][0].Id};
            objMasterFilterWrapper.strSelectedYear = String.valueOf(Date.today().year());   
        
        Map<Id, Account> mapAccount = new Map<Id, Account>();
        mapAccount = new Map<Id, Account>([SELECT Id From Account]);
        List<Id> lstFilteredAccounts = ADAccountDashboardUtil.applyAccountFilter(mapAccount, objMasterFilterWrapper);
        System.assert(new Set<Id>(lstFilteredAccounts).contains([SELECT Id From Account WHERE Name = 'Test Account'][0].Id));
        
        ContentNote note = createContentNote();
        
        //Insert ContentDocumentLink
        ContentDocumentLink contentDocumentLinkObj = new ContentDocumentLink();
        contentDocumentLinkObj.contentdocumentid = note.id;
        contentDocumentLinkObj.LinkedEntityId = [SELECT Id From Account WHERE Id =: lstFilteredAccounts[0]][0].Id;
        contentDocumentLinkObj.ShareType= 'V';
        insert contentDocumentLinkObj;
        
        ADNotesController.fetchNotes(lstFilteredAccounts[0], objMasterFilterWrapper);
    }
    
    //Test method 
    //Class: ADNotesController
    //Method: applyFilter
    public static testMethod void testNotesFilter() {
        ADMasterFilterWrapper objMasterFilterWrapper = new ADMasterFilterWrapper();
        objMasterFilterWrapper.strSelectedTopFilter = Label.AD_PICKLIST_VAL_FILTER_BY_ACCOUNT_NAME;
        objMasterFilterWrapper.lstSelectedAccounts = new List<Id>{[SELECT Id FROM Account WHERE Name = 'Test Account'][0].Id};
            objMasterFilterWrapper.strSelectedYear = String.valueOf(Date.today().year());   
        
        Map<Id, Account> mapAccount = new Map<Id, Account>();
        mapAccount = new Map<Id, Account>([SELECT Id From Account]);
        List<Id> lstFilteredAccounts = ADAccountDashboardUtil.applyAccountFilter(mapAccount, objMasterFilterWrapper);
        System.assert(new Set<Id>(lstFilteredAccounts).contains([SELECT Id From Account WHERE Name = 'Test Account'][0].Id));
        
        ContentNote note = createContentNote();
        List<ContentNote> contentNotesList = new List<ContentNote>();
        contentNotesList.add(note);
        System.assertEquals(!contentNotesList.isEmpty(), contentNotesList.size()>0);
        
        List<sObject> lstSelectedOwners = new List<sObject>{[SELECT Id, OwnerId FROM Account WHERE NAME = 'Test Account'][0]};
            Date startDate = System.today()-2;
        Date endDate = System.today()+2;
        String dateFilter = ConstantClass.DATE_FILTER_CREATED_DATE;
        ADNotesController.applyFilter(lstFilteredAccounts[0], startDate, endDate, lstSelectedOwners, contentNotesList);
    }
    
    //Test method 
    //Class: ADNotesController
    //Method: applySorting
    public static testMethod void testNotesSorting() {
        ContentNote note = createContentNote();
        List<ContentNote> contentNotesList = new List<ContentNote>();
        contentNotesList.add(note);
        System.assertEquals(!contentNotesList.isEmpty(), contentNotesList.size()>0);
        
        String sortingDateOption = ConstantClass.SORTING_CREATED_DATE_ASC;
        ADNotesController.applySorting(contentNotesList, sortingDateOption);
        
        sortingDateOption = ConstantClass.SORTING_CREATED_DATE_DESC;
        ADNotesController.applySorting(contentNotesList, sortingDateOption);
    }
    
    //Test method 
    //Class: ADActualVsNormalisedRevenueController
    //Method: getActualAndNormalisedRevenue
    public static testMethod void testActualAndNormalisedRevenue() {
        
        Id accountId = [SELECT Id From Account WHERE Name = 'Test Account'][0].Id;
        ADMasterFilterWrapper objMasterFilterWrapper = new ADMasterFilterWrapper();
        objMasterFilterWrapper.strSelectedTopFilter = Label.AD_PICKLIST_VAL_FILTER_BY_ACCOUNT_NAME;
        objMasterFilterWrapper.lstSelectedAccounts = new List<Id>{[SELECT Id FROM Account WHERE Id=:accountId].Id};
            objMasterFilterWrapper.strSelectedYear = String.valueOf(Date.today().year());   
        
        Map<Id, Account> mapAccount = new Map<Id, Account>();
        mapAccount = new Map<Id, Account>([SELECT Id, OwnerId From Account where Id=:accountId]);
        List<Id> lstFilteredAccounts = ADAccountDashboardUtil.applyAccountFilter(mapAccount, objMasterFilterWrapper);
        System.assert(new Set<Id>(lstFilteredAccounts).contains([SELECT Id From Account WHERE Name = 'Test Account'][0].Id));
        
        ADActualVsNormalisedRevenueController.getActualAndNormalisedRevenue(lstFilteredAccounts[0], objMasterFilterWrapper);
    }
    
    //Test method 
    //Class: ADMasterFilterController
    public static testMethod void testMasterFilterComponent() {
        Id accountId = [SELECT Id From Account WHERE Name = 'Test Account'][0].Id;
        ADMasterFilterWrapper objMasterFilterWrapper = new ADMasterFilterWrapper();
        objMasterFilterWrapper.strSelectedTopFilter = Label.AD_PICKLIST_VAL_FILTER_BY_ACCOUNT_NAME;
        objMasterFilterWrapper.lstSelectedAccounts = new List<Id>{[SELECT Id FROM Account WHERE Id=:accountId].Id};
            objMasterFilterWrapper.strSelectedYear = String.valueOf(Date.today().year());   
        
        Map<Id, Account> mapAccount = new Map<Id, Account>();
        mapAccount = new Map<Id, Account>([SELECT Id, OwnerId From Account where Id=:accountId]);
        List<Id> lstFilteredAccounts = ADAccountDashboardUtil.applyAccountFilter(mapAccount, objMasterFilterWrapper);
        System.assert(new Set<Id>(lstFilteredAccounts).contains([SELECT Id From Account WHERE Name = 'Test Account'][0].Id));
        
        ADMasterFilterController.getAllChildAccount(lstFilteredAccounts[0]);
        ADMasterFilterController.getAllChildAndParent(lstFilteredAccounts[0]);
        ADMasterFilterController.getAllActiveUsers();
        ADMasterFilterController.getAllActiveUsersRelatedToAccount(lstFilteredAccounts[0]);
        ADMasterFilterController.getPicklistYear();
    }
    
    //Test method 
    //Class: ADAccountDashboardUtil
    //Method: fetchLookUpValues
    public static testMethod void testfetchLookUpValues() {
        String searchKeyWord = 'user1';
        List<Id> ownerIdList = new  List<Id>();
        List<Account> accList = [SELECT Id, OwnerId FROM Account WHERE NAME = 'Test Account'];
        for(Account acc: accList)
        {
            ownerIdList.add(acc.ownerId);
        }
        
        List<sObject> excludeitemsList = new List<sObject>{[SELECT Id, OwnerId FROM Account WHERE NAME = 'Test Account'][0]};
            ADAccountDashboardUtil.fetchLookUpValues(searchKeyWord, excludeitemsList, ownerIdList);
    }
    
    //Test method 
    //Class: ADOpportunityConversionRateController
    //Method: getOpportunityConversionRate
    public static testMethod void testOpportunityConversionRate() {
        Id accountId = [SELECT Id From Account WHERE Name = 'Test Account'][0].Id;
        ADMasterFilterWrapper objMasterFilterWrapper = new ADMasterFilterWrapper();
        objMasterFilterWrapper.strSelectedTopFilter = Label.AD_PICKLIST_VAL_FILTER_BY_ACCOUNT_NAME;
        objMasterFilterWrapper.lstSelectedAccounts = new List<Id>{[SELECT Id FROM Account WHERE Id=:accountId].Id};
            objMasterFilterWrapper.strSelectedYear = String.valueOf(Date.today().year());   
        
        Map<String, String> oppChartMap = ADOpportunityConversionRateController.getOpportunityConversionRate(accountId, objMasterFilterWrapper);
        System.assert(oppChartMap.get('Filtered Year') == String.valueOf(Date.today().year()));
    }
}