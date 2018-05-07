public class Base311_Correspondence_Activity extends Base311_Correspondence
{
    Activity_Correspondence__c activityCorrespondence;
    public Base311_Correspondence_Activity(Activity_Correspondence__c activityCorrespondence){
        super(new Correspondence__c(
        intro__c = activityCorrespondence.Correspondence__r.Intro__C,
       	Body__c = activityCorrespondence.Correspondence__r.Body__c,
        closing__c = activityCorrespondence.Correspondence__r.closing__c,
        id = activityCorrespondence.Correspondence__r.id)
        );
        this.activityCorrespondence = activityCorrespondence;
    }
    
     public Base311_Correspondence_Activity(){
        super();
        this.activityCorrespondence = new Activity_Correspondence__c();
    }
    
    /**
    * @description Method to get service request ID
    * @param sobject so
    * @return ID
    * @example
    */
    public override Id getServiceRequestId(sobject so){
        return ((service_activity__c)so).Service_Request__c;
    }
    
    /**
    * @description Method to get notificatonrecipient
    * @param sobject so
    * @return String
    * @example
    */
    public override string getNotificationRecipient(sobject so){
        return ((service_activity__c)so).Service_Request__r.Contact.Email;
    }
    /**
    * @description Method to get EventType
    * @param none
    * @return String
    * @example
    */
    public override string getEventType(){
        return activityCorrespondence.type__c;
    }
    
    /**
    * @description Method to get sObjectType
    * @param none
    * @return String
    * @example
    */
    private String getSobjecttype(){
        return 'Incap311__Service_Activity__c';
    }

    /**
    * @description Method to get AdditionalFields
    * @param none
    * @return set<String>
    * @example
    */
     public override set<string> getAdditionalFields(){
         set<string> extraFields = new set<string>();
         extraFields.add('Service_Request__r.Contact.Email');
         extraFields.add('Status__c');
         extraFields.add('Service_Request__c');
         //extraFields.add('Service_Request__c');
        return extraFields;
    }
}