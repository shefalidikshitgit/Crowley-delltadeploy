@isTest
public class AccountOwnerAndMktSegmentUpdateBatchTest {
    static testMethod void startMethod() {
        List<Account> accList = TestDataUtility.createAccounts('Test Account', 'Customer', null, null, false, 2);
        System.debug('list' + accList);
        test.startTest();
        AccountOwnerAndMktSegmentUpdateBatch objAccountOwnerAndMktSegmentUpdateBatch = new AccountOwnerAndMktSegmentUpdateBatch();
        Database.QueryLocator objQuery = objAccountOwnerAndMktSegmentUpdateBatch.start(null);
        objAccountOwnerAndMktSegmentUpdateBatch.execute(null, accList);
        DataBase.executeBatch(objAccountOwnerAndMktSegmentUpdateBatch);
        test.stopTest();
    }

}