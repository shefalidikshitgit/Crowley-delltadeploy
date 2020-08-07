public with sharing class EmailMessageCounterDecreased {
    private EmailMessage currentRecord;
	public EmailMessageCounterDecreased(ApexPages.StandardController stdController) {
        this.currentRecord = (EmailMessage)stdController.getRecord();
        currentRecord = [Select Id,Status,Counter_Decreased__c,ParentId from EmailMessage where Id =: currentRecord.Id];
    }
    public void updateparentcase(){
        system.debug(currentRecord);
        if(String.isNotBlank(currentRecord.ParentId)){
            case c = [select Id,Status,Unread_Emails__c from case where Id =: currentRecord.ParentId limit 1];
            if(!currentRecord.Counter_Decreased__c && (currentRecord.Status=='1' || currentRecord.Status=='2')){
                c.Unread_Emails__c-=1;
                //c.Status = 'Ready for Review';
                currentRecord.Counter_Decreased__c = true;
            }
            system.debug(c);
            system.debug(currentRecord);
            update c;
            update currentRecord;
        }
    }
}