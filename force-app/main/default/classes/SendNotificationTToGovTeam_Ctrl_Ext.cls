public with sharing class SendNotificationTToGovTeam_Ctrl_Ext{
    public sendNotificationTToGovTeam_Ctrl_Ext(){

    }

    public static void sendEmailtoGovernance(Id relatedToId, String templateName){
        List<String> toAddresses = new List<String>();
        toAddresses.addAll(GovernanceTeamEmail__c.getAll().keySet());
        String whoId;
        if(String.valueOf(relatedToId).substring(0,3)=='001' || String.valueOf(relatedToId).substring(0,3) == 'a00'){
            Contact conObj = [Select Id from Contact LIMIT 1];
            whoId = conObj.Id;
        }else{
            whoId = UserInfo.getUserId();
        }    
        EmailTemplate et=[Select id from EmailTemplate where name = :templateName limit 1]; // pass name here

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddresses);
        mail.setTargetObjectId(whoId);
        mail.setTreatTargetObjectAsRecipient(false);
        mail.setTemplateId(et.id);
        mail.setWhatId(relatedToId);
        mail.saveAsActivity = False;
        List<Messaging.SendEmailResult> results = 
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        if (!results.get(0).isSuccess()) {
            System.StatusCode statusCode = results.get(0).getErrors()[0].getStatusCode();
            String errorMessage = results.get(0).getErrors()[0].getMessage();
            System.debug('error message-----'+errorMessage); 
        } 
    }
}