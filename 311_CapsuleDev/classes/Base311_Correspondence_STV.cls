public class Base311_Correspondence_STV extends Base311_Correspondence
{
    Service_Type_Version_Correspondence__c stvCorrespondence;
    public Base311_Correspondence_STV(Service_Type_Version_Correspondence__c stvCorrespondence){
        super(new Correspondence__c(
        intro__c = stvCorrespondence.Correspondence__r.Intro__C,
       	Body__c = stvCorrespondence.Correspondence__r.Body__c,
        closing__c = stvCorrespondence.Correspondence__r.closing__c,
        id = stvCorrespondence.Correspondence__r.id)
        );
        this.stvCorrespondence = stvCorrespondence;
    }
    
     public Base311_Correspondence_STV(){
        super();
        this.stvCorrespondence = new Service_Type_Version_Correspondence__c();
    }
    
    /**
    * @description Method to get service request ID
    * @param sobject so
    * @return ID
    * @example
    */
    public override Id getServiceRequestId(sobject so){
        return ((case)so).Id;
    }
    
    /**
    * @description Method to get notificatonrecipient
    * @param sobject so
    * @return String
    * @example
    */
    public override string getNotificationRecipient(sobject so){
        return ((case)so).Contact.Email;
    }
    /**
    * @description Method to get EventType
    * @param none
    * @return String
    * @example
    */
    public override string getEventType(){
        return stvCorrespondence.type__c;
    }
    
    /**
    * @description Method to get sObjectType
    * @param none
    * @return String
    * @example
    */
    private String getSobjecttype(){
        return 'Case';
    }

    /**
    * @description Method to get AdditionalFields
    * @param none
    * @return set<String>
    * @example
    */
     public override set<string> getAdditionalFields(){
         set<string> extraFields = new set<string>();
         extraFields.add('Contact.Email');
         extraFields.add('Id');
         //extraFields.add('Service_Request__c');
        return extraFields;
    }
}