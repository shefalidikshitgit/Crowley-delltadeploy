@isTest
public class AllExternalReportClassTest {
     @isTest
    static void getReportsTest(){
        External_Report_References__c err = new External_Report_References__c();
        err.Name = 'Testing';
        err.External_URL__c = 'https://test.salesforce.com/';
        insert err;
        AllExternalReportClass.getReports();
         List<External_Report_References__c> errList =[select id from External_Report_References__c where id=: err.id];
         System.assertEquals(1,errList.size());
        
   
    
   
        List<External_Report_References__c> ListView = new List<External_Report_References__c>();
        for(Integer i=0;i<7;i++) {
            ListView.add(new External_Report_References__c(Name ='ListView'+i));
        }
        insert ListView;
        
        test.startTest();
        update ListView;
        AllExternalReportClass.getListViews();
        test.stopTest();
       
   }

}