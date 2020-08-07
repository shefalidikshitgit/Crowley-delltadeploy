@isTest(seeAllData=false)
private class CustomAccountLookupController_Test {    
    static testMethod void CustomAccountLookupController_testmethod(){
        for(String strHandlerToBypass : new List<String>{'AccountTriggerHandler'}) {
                TriggerHandler.bypass(strHandlerToBypass);
        }
        Account accObj2 = TestDataUtility.createAccount('Account1234', null, null, false, 1)[0];
        ApexPages.StandardController sc = new ApexPages.StandardController(accObj2);
        CustomAccountLookupController custom = new CustomAccountLookupController(sc);
        pagereference pg = custom.search();
        system.assertEquals(pg,null);
        string str = custom.getFormTag();
        system.assertEquals(str,null);
        str = custom.getTextBox();
        system.assertEquals(str,null);
        for(String strHandlerToBypass : new List<String>{'AccountTriggerHandler'}) {
            TriggerHandler.clearbypass(strHandlerToBypass);
        }
    }
}