@isTest
public class Test_ContentDocumentLinkTriggerHandler {
    public static testMethod void test_creatingChildCaseOnParentWithAttachment(){
        Group q = [Select Id, Name, Type From Group Where Type='Queue' and Name like '%BL Revision%' Limit 1];
        List<Account> accs = TestDataUtility.createAccount('ABC Company', 'IT', null, false, 1); 
		List<Address__c> addresses = [Select Id, Account__c From Address__c Where Account__c=:accs[0].Id];
        List<RecordType> contactRTs = [Select Id, Name, SobjectType From RecordType Where SobjectType='Contact' Limit 1];
        List<Contact> cts = TestDataUtility.createContact(contactRTs[0].Id, accs[0].Id, addresses, 'test', 'contact', 'test@yopmail.com', '9999888877', false, UserInfo.getUserId(), 1);
        
        Case cs = TestDataUtility.createBLRevisionCase(accs[0].Id, cts[0].Id, null, 'Subject1', 'Desc1', 'Web', q.Id, 'Open', 1)[0];
        Test.startTest();
        List<Messaging.SingleEmailMessage> msgs = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        msg.setWhatId(cs.Id);
        msg.setTargetObjectId(cts[0].Id);
        msg.setSubject('TestEmail1');
        msg.setPlainTextBody('Testing');
        msgs.add(msg);
        List<Messaging.SendEmailResult> results = Messaging.sendEmail(msgs);
        
        //Create Document
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        
        //Get Content Documents
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        
        EmailMessage emsg = [Select Id, Subject From EmailMessage Where Subject Like '%TestEmail1%' Limit 1];
        
        //Create ContentDocumentLink 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = emsg.Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        Insert cdl;
        
        CaseTriggerHandler.reset();
        //Creating a child case. Parent case already have an attachment which should get copied to child case.
        Case childcs = TestDataUtility.createPricingRateIssueCase(accs[0].Id, cts[0].Id, cs.Id, 'Subject2', 'Desc1', 'Web', q.Id, 'Open', 1)[0];

        Test.stopTest();
        
        System.debug('child case -> '+childcs.ParentId);
        List<Related_Case_Attachment__c> relatedAtts = [Select Id, Case__c From Related_Case_Attachment__c Where Case__c=:childcs.Id Limit 1];
        System.assert(relatedAtts.size()>0);
    }
    
    public static testMethod void test_addingAttachmentOnParentCase(){
        Group q = [Select Id, Name, Type From Group Where Type='Queue' and Name like '%BL Revision%' Limit 1];
        List<Account> accs = TestDataUtility.createAccount('ABC Company', 'IT', null, false, 1); 
		List<Address__c> addresses = [Select Id, Account__c From Address__c Where Account__c=:accs[0].Id];
        List<RecordType> contactRTs = [Select Id, Name, SobjectType From RecordType Where SobjectType='Contact' Limit 1];
        List<Contact> cts = TestDataUtility.createContact(contactRTs[0].Id, accs[0].Id, addresses, 'test', 'contact', 'test@yopmail.com', '9999888877', false, UserInfo.getUserId(), 1);
        
        Case cs = TestDataUtility.createBLRevisionCase(accs[0].Id, cts[0].Id, null, 'Subject1', 'Desc1', 'Web', q.Id, 'Open', 1)[0];
        CaseTriggerHandler.reset();
        
        //Creating a child case.
        Case childcs = TestDataUtility.createPricingRateIssueCase(accs[0].Id, cts[0].Id, cs.Id, 'Subject2', 'Desc1', 'Web', q.Id, 'Open', 1)[0];
        
        Test.startTest();
        
        //Create Document
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        
        //Get Content Documents
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        
        //Create ContentDocumentLink 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = cs.Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        Insert cdl;

        Test.stopTest();
        
        System.debug('child case -> '+childcs.ParentId);
        List<Related_Case_Attachment__c> relatedAtts = [Select Id, Case__c From Related_Case_Attachment__c Where Case__c=:childcs.Id Limit 1];
        System.assert(relatedAtts.size()>0);
    }
    
    public static testMethod void test_scheduleHandle(){
        
        Group q = [Select Id, Name, Type From Group Where Type='Queue' and Name like '%BL Revision%' Limit 1];
        List<Account> accs = TestDataUtility.createAccount('ABC Company', 'IT', null, false, 1); 
		List<Address__c> addresses = [Select Id, Account__c From Address__c Where Account__c=:accs[0].Id];
        List<RecordType> contactRTs = [Select Id, Name, SobjectType From RecordType Where SobjectType='Contact' Limit 1];
        List<Contact> cts = TestDataUtility.createContact(contactRTs[0].Id, accs[0].Id, addresses, 'test', 'contact', 'test@yopmail.com', '9999888877', false, UserInfo.getUserId(), 1);
        
        Case cs = TestDataUtility.createBLRevisionCase(accs[0].Id, cts[0].Id, null, 'Subject1', 'Desc1', 'Web', q.Id, 'Open', 1)[0];
        
        CaseTriggerHandler.reset();
        
        //Creating a child case.
        Case childcs = TestDataUtility.createPricingRateIssueCase(accs[0].Id, cts[0].Id, cs.Id, 'Subject2', 'Desc1', 'Web', q.Id, 'Open', 1)[0];
        
        // if EnhancedEmail Perm is enabled, create an EmailMessage object
        EmailMessage emailMessage = new EmailMessage();
        emailMessage.status = '3'; // email was sent
        emailMessage.parentId = cs.Id; // related to record e.g. an opportunity
        emailMessage.relatedToId = cs.Id; // related to record e.g. an opportunity
        emailMessage.fromName = 'Dan Perkins'; // from name
        emailMessage.subject = 'This is the Subject!'; // email subject
        emailMessage.htmlBody = '<html><body><b>Hello</b></body></html>'; // email body
        // Contact, Lead or User Ids of recipients
        String[] toIds = new String[]{cts[0].Id}; 
            emailMessage.toIds = toIds;
        // additional recipients who don’t have a corresponding contact, lead or user id in the Salesforce org (optional)
        emailMessage.toAddress = 'emailnotinsalesforce@toexample.com, anotherone@toexample.com';
        insert emailMessage; // insert
        
        // Add Email Message Relation for id of the sender
        EmailMessageRelation emr = new EmailMessageRelation();
        emr.emailMessageId = emailMessage.id;
        emr.relationId = UserInfo.getUserId(); // user id of the sender
        emr.relationType = 'FromAddress';
        insert emr;
        
        Test.startTest();
        
        //Create Document
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        
        //Get Content Documents
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        
        //Create ContentDocumentLink 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = emailMessage.Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        Insert cdl;
		
        List<Id> emsgIds = new List<Id>();
        emsgIds.add(emailMessage.Id);
        ContentDocumentLinkTriggerHandler.handleEmailAttachmentsInvocable(emsgIds);
        
        CleanAttachmentScheduler sch = new CleanAttachmentScheduler();
        System.schedule('TestSchedule', '0 0 10 ? * *', sch);
        Test.stopTest();
        
        List<Related_Case_Attachment__c> relatedAtts = [Select Id, Case__c From Related_Case_Attachment__c Limit 1];
        System.assert(relatedAtts.size()>0);
    }
    
    static testMethod void test_handleEmailAttachmentsInvocable(){
        Group q = [Select Id, Name, Type From Group Where Type='Queue' and Name like '%BL Revision%' Limit 1];
        List<Account> accs = TestDataUtility.createAccount('ABC Company', 'IT', null, false, 1); 
		List<Address__c> addresses = [Select Id, Account__c From Address__c Where Account__c=:accs[0].Id];
        List<RecordType> contactRTs = [Select Id, Name, SobjectType From RecordType Where SobjectType='Contact' Limit 1];
        List<Contact> cts = TestDataUtility.createContact(contactRTs[0].Id, accs[0].Id, addresses, 'test', 'contact', 'test@yopmail.com', '9999888877', false, UserInfo.getUserId(), 1);
        
        Case cs = TestDataUtility.createBLRevisionCase(accs[0].Id, cts[0].Id, null, 'Subject1', 'Desc1', 'Web', q.Id, 'Open', 1)[0];
        
        Test.startTest();
        List<Messaging.SingleEmailMessage> msgs = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        msg.setWhatId(cs.Id);
        msg.setTargetObjectId(cts[0].Id);
        msg.setSubject('TestEmail1');
        msg.setPlainTextBody('Testing');
        msgs.add(msg);
        List<Messaging.SendEmailResult> results = Messaging.sendEmail(msgs);
        
        //Create Document
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        
        //Get Content Documents
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        Test.stopTest();
        EmailMessage emsg = [Select Id, Subject From EmailMessage Where Subject Like '%TestEmail1%' Limit 1];
        
        //Create ContentDocumentLink 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = emsg.Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        Insert cdl;
        System.debug('emsg -> '+emsg);
        System.debug('cdl -> '+cdl);
        
        List<Id> emsgIds = new List<Id>();
        emsgIds.add(emsg.Id);
        ContentDocumentLinkTriggerHandler.handleEmailAttachmentsInvocable(emsgIds);
        List<Case_Attachment__c> csAttachments = [Select Id From Case_Attachment__c Limit 1];
        System.assert(csAttachments.size()>0);
        
    }
}