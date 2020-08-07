/*
* Name: ADTaskExportToExcelControllerTest
* Purpose: Test class for ADTaskExportToExcelController
* Author: Nagarro
* Created Date: 28-Nov-2019
* Modification History
* Modification #   Story/Defect#      Modified By     Date   Description
*/

@isTest(seeAllData=false)
public class ADTaskExportToExcelControllerTest {
    
    public static testMethod void ADTaskExportToExcelTest(){
        
        String jsonTestObject	=	'[{"Id":"00Tq000000YoaUbEAJ","Status":"Open","Description":"dsdsadasdadasdasd","OwnerId":"005f4000004cALgAAM","Subject":"Call","WhatId":"001q000001AFFhoAAH","ActivityDate":"2019-11-28","CreatedDate":"2019-11-25T11:11:33.000Z","TaskSubtype":"Task","WhoId":"003q0000011yWwNAAU","IsClosed":false,"Owner":{"Name":"Om Singh","Id":"005f4000004cALgAAM"},"What":{"Type":"Account","Name":"TEST ACCOUNT 24","Id":"001q000001AFFhoAAH"}},{"Id":"00Tq000000YoaUbEAJ","Status":"Open","Description":"dsdsadasdadasdasd","OwnerId":"005f4000004cALgAAM","Subject":"Call","WhatId":"001q000001AFFhoAAH","ActivityDate":"2019-11-28","CreatedDate":"2019-11-25T11:11:33.000Z","TaskSubtype":"Task","WhoId":"003q0000011yWwNAAU","IsClosed":false,"Owner":{"Name":"Om Singh","Id":"005f4000004cALgAAM"},"What":{"Type":"Account","Name":"TEST ACCOUNT 24","Id":"001q000001AFFhoAAH"}}]';
        List<Account> lstTestAccounts = TestDataUtility.createAccount('Test Account', 'Apparel', null, false, 1);
        Attachment objAttachment = new Attachment();
        objAttachment.Body = Blob.valueOf(jsonTestObject);
        objAttachment.Name = 'TaskList.txt';
        objAttachment.ParentId = lstTestAccounts[0].Id;
        insert objAttachment;
        
        PageReference vfPage	=	Page.ADTaskExportToExcel;
        
        Test.startTest();
		Test.setCurrentPage(vfPage);
        ApexPages.currentPage().getParameters().put('taskAttachmentId',objAttachment.Id);
        
        String param	=	ApexPages.currentPage().getParameters().get('taskAttachmentId');
        System.assert(param != null);
        ADTaskExportToExcelController controller	=	new ADTaskExportToExcelController();
        Test.stopTest();
    }

}