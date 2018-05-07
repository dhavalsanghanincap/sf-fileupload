/**
* @author 
* @date 
* @group 
* @group-content
* @description 
*/

/*
 * Block comments with details of changes
 */
global  class Base311_Invocable_ServiceActivity_Upsert
{   
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    @InvocableMethod(label='Upsert Service Activity' description='Upsert a Service Activity')
    global static list<Id>  UpsertServiceActivity(list<Input> inputs){
        List<Service_Activity__c> finalServices = new List<Service_Activity__c>();
        System.debug('Upserting Activity');
        list<String> caseIDs = new list<String>();
        Map<String,list<Base311_Activity>> casesActivities = new  Map<String,list<Base311_Activity>>();
        Incap311.Base311_Service_Request rsq = new Incap311.Base311_Service_Request();

        for(Input input : inputs){
            caseIDs.add(input.CaseId);
            list<Base311_Activity> activities;
            if(!casesActivities.containsKey(input.caseId)){
                activities= new list<Base311_Activity>();
            }else{
                activities = casesActivities.get(input.caseId);
            }
            activities.add(new Base311_Activity(input.ActivityCode, 'Not Started', input.completionDate, input.comment));
            casesActivities.put(input.CaseId,activities);
        }

        for(Input input : inputs){
            Case originalCase = rsq.getServiceRequest(input.CaseID);

            //if(originalCase == null) {
            //  throw new Incap311.Base311_Exceptions.NotFoundException('Unknown service_request_id ' + input.CaseID);
            // }


            /*Case c = rsq.updateServiceRequest(
                input.caseId, 
                null, 
                null, 
                null, 
                null, 
                null, 
                null, 
                'Open', 
                null,
                new Base311_Contact(),
                casesActivities.get(input.CaseId)
            );*/
            System.debug(originalCase);
            // if we have a previously created Service; use it; otherwise make a new one
            // if we have updates ot make, grab them; other wise grab an empty update
            Service_Activity__c serv =  new Service_Activity__c();
            Base311_Activity activityUpdate =  casesActivities.get(input.CaseId)[0];
            serv.Service_Request__c = originalCase.Id;
            System.debug(input.ActivityCode);
            System.debug(originalCase.Incap311__Service_Type_Version_Code__c);
            Service_Type_Version_Activity__c svta = [select id from Service_Type_Version_Activity__c where Incap311__Activity_Code__c = :input.ActivityCode and Incap311__Service_Type_Code__c = :originalCase.Incap311__Service_Type_Version_Code__c];

            serv.Service_Type_Version_Activity__c = svta.Id;
            // JOHN BENSON serv.Due_Date__c = Base311_DateTime_Util.getEndDate(System.now(), svta.SLA_Type__c, svta.SLA__c, false);
            serv.Status__c = 'Not Started';
            //activityUpdate.setSA(serv);

            finalServices.add(serv);
        }

        insert finalServices;






        return null;



    }

    
    global class Input{
        @InvocableVariable
        global String CaseID;
        @InvocableVariable
        global String Status = 'Not Started';
        @InvocableVariable
        global String ActivityCode;
        @InvocableVariable
        global String CompletionDate;
        @InvocableVariable
        global String Comment;
    }

}