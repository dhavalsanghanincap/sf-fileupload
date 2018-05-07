/**
* @author David Evans
* @date 06/14/2017
* @group Case Events
* @description Class for the creation and business logic of Correspondence
*/
public virtual class Base311_Correspondence
{
    /**
 * @description Correspondence__c t0 use
 */
    Correspondence__c correspondence{get;set;}
    public String Sobjecttype;
    /**
   * @description Constructor
   * @param correspondence Correspondence__c data object to use
   */
    public Base311_Correspondence()
    {
        correspondence = new Correspondence__c();
    }
    /**
   * @description Constructor
   * @param correspondence Correspondence__c data object to use
   */
    public Base311_Correspondence(Correspondence__c correspondence)
    {
        this.correspondence = correspondence;
    }
    
    private virtual String getSobjecttype(){
        String recordTypeId = correspondence.recordTypeId;
        System.debug('Record type id '+correspondence.recordTypeId);
        if(correspondence.recordTypeId == null){
            recordTypeId = [select recordTypeId from Correspondence__c where id = :correspondence.id][0].recordTypeId;
        }
        String recordTypeName  = Schema.SObjectType.Correspondence__c.getRecordTypeInfosById().get(recordTypeId).getname();
        System.debug('Record type Name '+recordTypeName);
        
        if(recordTypeName == 'Service Request'){
            return 'Case';
        }else if(recordTypeName == 'Service Activity'){
            return 'Incap311__Service_Activity__c';
        }
        return Sobjecttype;
    }
    /**
   * @description return if the condition is true or not
   * @param so an sobject to evalutate the condition on
   * @return true or false based on the condition and sobject
   * @example
   * Account a = new Account();
   * condition.evaluate((sobject)a);
   */
    public void validateMergeFields(){
        if(correspondenceTriggerRunning()){
            String Error = checkMailMergeFields(Base311_MailMerge.getFieldNames(correspondence.intro__c));
            if(Error != null){
                correspondence.intro__c.addError(Error);
            }
            Error = checkMailMergeFields(Base311_MailMerge.getFieldNames(correspondence.body__c));
            if(Error != null){
                 correspondence.body__c.addError(error);
            }
            Error = checkMailMergeFields(Base311_MailMerge.getFieldNames(correspondence.Closing__c));
            if(Error != null){
                correspondence.Closing__c.addError(Error);
            }
        }else {
            String ErrorOut;
            String Error = checkMailMergeFields(Base311_MailMerge.getFieldNames(correspondence.intro__c));
            if(Error != null){
            ErrorOut = Error;
            }
            Error = checkMailMergeFields(Base311_MailMerge.getFieldNames(correspondence.body__c));
            if(Error != null){
            ErrorOut += Error;
            }
            Error = checkMailMergeFields(Base311_MailMerge.getFieldNames(correspondence.Closing__c));
            if(Error != null){
            ErrorOut += Error;
            }
            if(ErrorOut != null){
            throw new MailMergeException(Error);
            }
        }
    }
    
    private String checkMailMergeFields(List<String> fields){
        for(String field : fields) {
            System.debug('Does '+field+' exist '+Base311_Schema.doesFieldExist(getSobjecttype(),field));
            try{
                if(!Base311_Schema.doesFieldExist(getSobjecttype(),field)){
                    return 'Merge field '+Field+' cannot be found on the '+getSobjecttype()+' object';
                }
            }catch(Exception e){
                return 'Merge field '+Field+' cannot be found on the '+getSobjecttype()+' object';
            }
        }
        return null;
    }
    
    private boolean correspondenceTriggerRunning(){
        if(!trigger.isExecuting){
            return false;
        }
        sobject c = trigger.new[0];
        Schema.sObjectType expected = Schema.Correspondence__c.getSObjectType();
        try{
            System.assertEquals(expected, c.getSobjectType());
        }catch(Exception e ){
            return false;
        }
        return true;
    }
   /**
   * @description creates a case event for a given sobject
   * @param so sobject to merge fields with
   * @return case events
   * @example
   * Case_event__C newEvent =  correspondence.CreateCaseEvent(case);
   */
    public case_event__C CreateCaseEvent(sobject so){
    case_event__C caseEvent =  new Case_Event__c(
                        Event_Type__c =  getEventType(),
                        Notification_Recipient__c = getNotificationRecipient(so),
                        Service_Request__c =  getServiceRequestId(so),
                        Rich_Email_Body__c = getEmailBody(so));
    return caseEvent;
    }
            
    public string getEmailBody(sobject so){
        String emailBody = correspondence.intro__c + '<br/><br/>';
        emailBody += correspondence.body__c + '<br/><br/>';
        emailBody += correspondence.Closing__c;
        emailBody = Base311_MailMerge.replace(so, emailBody);
        return emailBody;
    }
        
    public virtual Id getServiceRequestId(sobject so){
        return '';
    }
    
    public virtual string getNotificationRecipient(sobject so){
        return '';
    }
    
    public virtual string getEventType(){
        return '';
    }
    
    public virtual set<string> getAdditionalFields(){
        return new set<string>();
    }
    
    /**
   * @description creates case events given a list of objects
   * @param sos list of sobject to create new case events for
   * @returns a list of case events
   * @example
   * Case_event__C newEvent =  correspondence.CreateCaseEvent(Trigger.new);
   */
    public list<case_event__C> CreateCaseEvents(list<sobject> sos){
        list<case_event__C> caseEvents = new list<case_event__C>();
        for(sobject so : sos){
            caseEvents.add(CreateCaseEvent(so));
        }
        return caseEvents;
    }
    
    
    public set<string > getMergeFields(){
       Set<String> fields = new set<String>();
       fields.addAll(Base311_MailMerge.getFieldNames(correspondence.intro__c));
       fields.addAll(Base311_MailMerge.getFieldNames(correspondence.body__c));
       fields.addAll(Base311_MailMerge.getFieldNames(correspondence.Closing__c));
       fields.addAll(getAdditionalFields());
       return fields;
    }
    
    public class MailMergeException extends Exception {}
}