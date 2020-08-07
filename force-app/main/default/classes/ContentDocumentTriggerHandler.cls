public class ContentDocumentTriggerHandler extends TriggerHandler{
    public static Map<Id, ContentDocument> contentDocMap;
    List<ContentDocument> oldContentDocumentList;
    public ContentDocumentTriggerHandler(){
        this.oldContentDocumentList = (List<ContentDocument>) Trigger.old; 
        
    }
    public override void beforeDelete(){
        System.debug('ContentDocumentTriggerHandler: Limits.getQueries()/Limits.getLimitQueries -> '+Limits.getQueries()+'/'+Limits.getLimitQueries());
        deleterelatedAttachments(oldContentDocumentList);
    	System.debug('ContentDocumentTriggerHandler: Limits.getQueries()/Limits.getLimitQueries -> '+Limits.getQueries()+'/'+Limits.getLimitQueries());
    }
    private static void deleterelatedAttachments(List<ContentDocument> content){
        list<string> sObjectIds = new list<string>();
        for(ContentDocument c: content){
            sObjectIds.add(c.id);
        }
        list<Related_Case_Attachment__c> li = [Select Id,Content_Document_Id__c from Related_Case_Attachment__c where Content_Document_Id__c in : sObjectIds];
        delete li;
    }
}