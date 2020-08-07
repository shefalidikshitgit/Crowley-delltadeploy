public with sharing class EmailMessageTriggerHandler extends TriggerHandler{
    
    List<EmailMessage> newEmailMessageList;
    public static List<EmailMessage> msgList;
    public static Map<Id, EmailMessage> msgListMap;
    
    public EmailMessageTriggerHandler(){
        this.newEmailMessageList = (List<EmailMessage>) Trigger.new; 
        msgListMap = (Map<Id, EmailMessage>)Trigger.newMap;
    }
    public override void afterInsert(){
        
        //updateOpportunityStage(newEmailMessageList);
        EmailMessageTriggerHandler.UpdateCaseStatus(newEmailMessageList);
        
    }   
    
    public override void beforeInsert(){
        setCaseMessageCreatedDate(Trigger.new);
    }    
    private void setCaseMessageCreatedDate(List<EmailMessage> newMessages){
        Integer val = String.isNotBlank(System.Label.Created_Date_N_Minutes) && System.Label.Created_Date_N_Minutes.isNumeric() ? Integer.valueOf(System.Label.Created_Date_N_Minutes) : 55;
        for(EmailMessage msg: newMessages){
            if(msg.ParentId !=null && msg.ParentId.getSobjectType().getDescribe().getName()=='Case'){
                msg.CreatedDate__c = System.now().addMinutes(-1*val);
            }
        }
    }
    //Update opportunity’s stage to ‘Negotiation/Review’ when ‘Send Quote to Customer From Opportunity’ email template is sent in ‘Price Proposal/Quote’ stage
    private void updateOpportunityStage (List<EmailMessage> newEmailMessageList){
        Set<Id> oppIdSet = new Set<Id>();
        if(newEmailMessageList != NULL && !newEmailMessageList.isEmpty()){
            for(EmailMessage email: newEmailMessageList){
                if(email.RelatedToId != NULL && email.RelatedToId.getSobjectType().getDescribe().getName()=='Opportunity')
                    oppIdSet.add(email.RelatedToId);
            }
        }
        System.debug('EmailMessage: oppIdSet -> '+oppIdSet);
        List<Opportunity> oppList = new List<Opportunity>();
        if(oppIdSet != NULL && !oppIdSet.isEmpty())
            oppList = [Select Id, StageName,Proposal_Submission_Due_Date__c  from Opportunity where Id in: oppIdSet];
        
        System.debug('EmailMessage: oppList -> '+oppList);
        Map<Id, Opportunity> map_Id_Opportunity = new Map<Id, Opportunity>();
        if(oppList != NULL && !oppList.isEmpty()){
            for(Opportunity opp: oppList){
                if(opp.StageName == ConstantClass.PROPOSAL_PRICE_QUOTE_OPP_STAGE)
                    map_Id_Opportunity.put(opp.Id, opp);
            }
        }
        
        List<Opportunity> oppToUpdateList = new List<Opportunity>();
        if(newEmailMessageList != NULL && !newEmailMessageList.isEmpty())
        {
            for(EmailMessage email: newEmailMessageList){
                String oppId ='';
                if(email.RelatedToId != NULL)
                    oppId = email.RelatedToId;
                if(String.isNotBlank(oppId)){
                    if(email.TextBody.contains('Send Quote '+oppId.substring(0, 15))){
                        if(map_Id_Opportunity.containsKey(email.RelatedToId)){
                            Opportunity opp = map_Id_Opportunity.get(email.RelatedToId);
                            opp.Proposal_Submission_Due_Date__c = System.TODAY();
                            oppToUpdateList.add(opp);
                        }
                    }
                }
            }
        }
        if(oppToUpdateList != NULL && !oppToUpdateList.isEmpty())
            update oppToUpdateList;
    }
    /*
     * @ Description: This method update a case status
    * @ Args       : List<EmailMessage> 
    * @ Return     : None
    */ 
    public static void UpdateCaseStatus(List<EmailMessage> emails){
        List<Id> ids=new List<Id>();
        List<Case> cases=new List<Case>();
        map<string,list<EmailMessage>> emailstatusmap = new map<string,list<EmailMessage>>(); 
        for(EmailMessage e : emails){
            if(e.ParentId!=null && string.valueOf(e.ParentId).substring(0,3)=='500'){
                list<EmailMessage> li = emailstatusmap.get(e.ParentId);
                if(li==null){
                    li = new list<EmailMessage>();
                }
                ids.add(e.ParentId);
                li.add(e);
                emailstatusmap.put(e.ParentId,li);
            }  
            
        }
        if(!ids.isEmpty()){
            cases=[Select Id,Status,Case_Auto_Close__c,Ha__c,Unread_Emails__c,Destination_Approval__c,RecordTypeId from Case where Id=:ids];
            
            for(Case cs:cases){
                list<EmailMessage> em = emailstatusmap.get(cs.Id);
                
                for(EmailMessage e: em){
                    integer unreademailcount = integer.valueOf(cs.Unread_Emails__c);
                    if(e.status=='0'){
                        unreademailcount++;
                    }
                    cs.Unread_Emails__c= unreademailcount;
                    if(((cs.Ha__c || cs.Destination_Approval__c) && e.Incoming && cs.Status !='Closed Resolved')|| (e.Incoming && cs.Status =='Awaiting More Information')){
                        cs.Status='Ready for Review';
                    }
                    System.debug('templateId -> '+System.Label.BL_Revision_Final_Resolution_template_id);
                    if(e.EmailTemplateId == System.Label.BL_Revision_Final_Resolution_template_id && cs.RecordTypeId == System.Label.B_L_Revision_record_type){
                        cs.Status='Resolving Case';
                    }
                }
                
                system.debug(cs);
            }
            if(cases.size()>0){
                try{
                    update cases;
                }catch(Exception e){
                    System.debug(e);
                }           
            }
        }
        
    }
    
    /*Public static void UpdateFromAddressonCase(List<EmailMessage> emails){
        List<Id> ids=new List<Id>();
        List<Case> cases=new List<Case>();
        for(EmailMessage e : emails){
            if(e.ParentId!=null && string.valueOf(e.ParentId).substring(0,3)=='500' && e.Incoming==False){
                 ids.add(e.ParentId);
            }
        }
        cases=[Select Id,Status,RecordTypeId from Case where Id=:ids];
        for(Case cs:cases){
            for(EmailMessage e : emails){
                if(e.ParentId==cs.Id && e.Incoming==False){
                    if(cs.RecordTypeId==System.Label.B_L_Revision_record_type){
                        e.FromAddress=System.Label.BL_Revision_From_Address;
                    }
                }
            }
        }
    } */   
}