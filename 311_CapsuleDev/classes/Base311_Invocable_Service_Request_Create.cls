/**
* @author 
* @date 
* @group 
* @group-content
* @description 
*/
global  class Base311_Invocable_Service_Request_Create
{   
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    @InvocableMethod(label='Create Service Request' description='Creates a Service Request. Returns the list of IDs for the created Service Request')
    global static list<Id>  CreateServiceRequest(list<Input> inputs){
        list<Id> output = new list<Id>();
        QueueableCreateSR qCSR = new QueueableCreateSR(JSON.serialize(inputs));
        System.enqueueJob(qCSR);
        return output;
    }

    public class QueueableCreateSR implements System.Queueable, Database.AllowsCallouts {

        private final string inputsJSON;

        public QueueableCreateSR(String inputsJSON) {
            this.inputsJSON = inputsJSON;
        }

        public void execute(System.QueueableContext ctx) {
            list<Input> inputs = (list<Base311_Invocable_Service_Request_Create.Input>)JSON.deserializeStrict(
                inputsJSON,
                list<Input>.class);
            list<Case> caseList = new list<Case>();
            for(Input input : inputs){
                caseList.add(createCase( input.latitude,  
                           input.longitude,  
                           input.mediaUrl,  
                           input.addressId, 
                           input.addressString,  
                           input.serviceCode,  
                           input.description, 
                           input.firstName,  
                           input.lastName,  
                           input.email,  
                           input.phone,  
                           input.source,  
                           input.origin,
                           input.ParentCase,
                           input.overrideSLADate));
            }
            update caseList;
        }

        /**
        * @description 
        * @param 
        * @param 
        * @return 
        * @example
        */
        private case createCase(Double latitude, Double longitude, String mediaUrl, String addressId, 
                                String addressString, String serviceCode, String description, 
                                String firstName, String lastName, String email, String phone, String source, String origin, String ParentCase, String overrideSLADate) {
            Incap311.Base311_Service_Request rsq = new Incap311.Base311_Service_Request();
            Case c;
            if(firstName != null && lastName != null && email != null){
                 c = rsq.createServiceRequest(
                    latitude,  
                    longitude,  
                    mediaUrl,  
                    addressId, 
                    addressString,  
                    serviceCode,  
                    description, 
                    new Map<String, Base311_Attribute>(), 
                    firstName,  
                    lastName,  
                    email,  
                    phone,  
                    source,  
                    origin
                );
            }else{
                 c = rsq.createServiceRequest(
                    latitude,  
                    longitude,  
                    mediaUrl,  
                    addressId, 
                    addressString,  
                    serviceCode,  
                    description, 
                    new Map<String, Base311_Attribute>(), 
                    null,  
                    null,  
                    null,  
                    phone,  
                    source,  
                    origin
                );
            }
            if (parentCase != null) {
                c.ParentId = parentCase;
            }
            
            if (overrideSLADate != null) {
                c.Incap311__Expected_Start_Date__c = DateTime.valueOf(Base311_DateTime_Util.transformDateTimeString(overrideSLADate));
                c.Override_SLA_Calc__c = true;
                c.Status = 'Hold';
            }
             return c;
        }
       

    }

    global class Input{
        @InvocableVariable
        global Double latitude;
        @InvocableVariable
        global Double longitude;
        @InvocableVariable
        global String mediaUrl;
        @InvocableVariable
        global String addressId;
        @InvocableVariable
        global String addressString;
        @InvocableVariable(required=true)
        global String serviceCode;
        @InvocableVariable
        global String description;
        @InvocableVariable
        global String firstName;
        @InvocableVariable
        global String lastName;
        @InvocableVariable
        global String email;
        @InvocableVariable
        global String phone;
        @InvocableVariable
        global String source;
        @InvocableVariable
        global String origin;
        @InvocableVariable
        global Id ParentCase;
        @InvocableVariable
        global String overrideSLADate;
    }
}