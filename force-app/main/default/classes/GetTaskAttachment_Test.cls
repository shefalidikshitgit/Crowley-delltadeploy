@isTest
public class GetTaskAttachment_Test {
    
    /**
     * Create a testing attachment for a case
     */
    private static List<Attachment> addAttachmentToParent(Id idParent, String strData, string strName, integer intNumOfAttach) {
    	List<Attachment> atts = new List<Attachment>();
        for(integer i=0; i<intNumOfAttach; i++){
            Attachment attachment = new Attachment();
            attachment.ParentId = idParent;
            attachment.Name = strName + i;
            attachment.Body = Blob.valueOf(strData);
    		atts.add(attachment);
        }
    	insert atts;
        return atts;
    }
    
    public static List<ContentDocumentLink> addAttachmentDocToParent(string caseId, string strTitle, string strPathOnClient, string strVersionData, integer intNumOfDocs){
        List<ContentVersion> versions = new List<ContentVersion>();
        for(integer i=0; i<intNumOfDocs; i++){
            ContentVersion contentVersion_1 = new ContentVersion(
                Title = strTitle,
                PathOnClient = strPathOnClient,
                VersionData = Blob.valueOf(strVersionData),
                IsMajorVersion = true
            );
            versions.add(contentVersion_1);     
        }
        insert versions;
        
        Set<Id> versionIds = (new Map<Id, ContentVersion>(versions)).keyset();
        versions = [Select Id, ContentDocumentId From ContentVersion Where Id IN :versionIds];
        
        List<ContentDocumentLink> docLinks = new List<ContentDocumentLink>();
        for(ContentVersion version: versions){
            ContentDocumentLink doc = new ContentDocumentLink();
            doc.LinkedEntityId = caseId;
            doc.ContentDocumentId = version.ContentDocumentId;
            docLinks.add(doc);
        }
        insert docLinks;
        return docLinks;
    }
    
    private static List<Destination_Team_Email__c> createDestinationEmailList(string country, string region, integer intNumOfEmails){
        List<Destination_Team_Email__c> destEmails = new List<Destination_Team_Email__c>();
        for(integer i=0; i<intNumOfEmails; i++){
            destEmails.add(new Destination_Team_Email__c(Name=i+'', Country__c=country, Is_Hacienda_Destination__c = true, Email__c='test'+i+'@abc.com', Region__c=region));
        }
        insert destEmails;
        return destEmails;
    }
    
    public static testMethod void testSendDocuments(){
        List<Account> accs = TestDataUtility.createAccount('TestAccount', 'Crowley', null, false, 1);
        Case cs = TestDataUtility.createCase(accs[0].Id, 'Web', Userinfo.getUserId(), 'Open', 1)[0];
        cs.Ha__c = true;
        update cs;
        createDestinationEmailList('Honduras - Import','Central America', 2);
        
        Test.startTest();
        cs = GetTaskAttachemnt.getHaciendaChecked(cs.Id);
        
        addAttachmentDocToParent(cs.Id, 'Penguins', 'Penguins.txt', 'Test Data', 1);
        addAttachmentToParent(cs.Id, 'Test Data', 'Attachment', 2);
        
        String jsonAtts = GetTaskAttachemnt.getTaskAttachmentList(cs.Id);
        List<GetTaskAttachemnt.AttachmentList> attList = (List<GetTaskAttachemnt.AttachmentList>)JSON.deserialize(jsonAtts, List<GetTaskAttachemnt.AttachmentList>.class);
        List<string> attIds = new List<string>();
        for(GetTaskAttachemnt.AttachmentList att: attList){
            attIds.add(att.attachId);
        }
        string jsonTemplates = GetTaskAttachemnt.getTemplates('Resolution', cs);
        string jsonDestinationEmailList = GetTaskAttachemnt.destinationEmailList();
         
        String result = GetTaskAttachemnt.sendAttachments(attIds, new List<string>{'vikash@nagarro.com'}, cs, 'vikash@yopmail.com', 'vikash@yopmail.com','Test 1','Test Data');
        System.debug('send task att status -> '+result);
        System.assert(result == 'success');
        Test.stopTest();
    }

}