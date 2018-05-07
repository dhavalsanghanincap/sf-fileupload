/**
* @author 
* @date 
* @group 
* @group-content
* @description 
*/
global class Base311_Service_Activity {

    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    private Map<Id, Service_Activity__c> getServiceActivities(Set<Id> ids) {
        return new Map<Id, Service_Activity__c>([
            SELECT 
                Id, Activity_Outcome__r.Track_Use__c, Service_Request__c, 
                Service_Type_Version_Activity__r.Activity_Name__c, Activity_Outcome__r.Outcome_Name__c, 
                Service_Request__r.ContactEmail, Service_Request__r.Service_Request_Number__c,
                Activity_Outcome__r.Outcome_Detail__c
            FROM 
                Service_Activity__c
            WHERE 
                Id IN :ids
        ]);
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global List<Case_Event__c> trackOutcomes(Map<Id, SObject> serviceActivities, Map<Id, SObject> oldState) {
        List<Case_Event__c> ces = new List<Case_Event__c>();
 
        Map<Id, Service_Activity__c> withFields = getServiceActivities(serviceActivities.keySet());
        
        for(Service_Activity__c act : (List<Service_Activity__c>) withFields.values()) {
            Service_Activity__c oldActivity = oldState.containsKey(act.Id) ? (Service_Activity__c) oldState.get(act.Id) : null;
           
            if(act.Activity_Outcome__c != null && 
                act.Activity_Outcome__r.Track_Use__c && 
                oldActivity.Activity_Outcome__c != act.Activity_Outcome__c
              ) { 
                  
                Case_Event__c ce = new Case_Event__c(); 
                
                ce.Service_Request__c = act.Service_Request__c;
                
                ce.Event_Type__c = 'Update';
                
                ce.Details__c = 'Activity ' + 
                    act.Service_Type_Version_Activity__r.Activity_Name__c + 
                    ' on request ' + 
                    act.Service_Request__r.Service_Request_Number__c + 
                    ' has had its outcome set to ' + 
                    act.Activity_Outcome__r.Outcome_Detail__c;
                
                ce.Notification_Recipient__c = act.Service_Request__r.ContactEmail;
                 
                ces.add(ce);
            }
        }
        
        insert ces;
        
        return ces;
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global List<Service_Activity__c> upsertServiceActivities(Case c, Service_Type_Version__c version) {
        return upsertServiceActivities(c, version, new List<Base311_Activity>());        
    }

    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global List<Service_Activity__c> patchActivities(Case c, Base311_PatchValue updates) { 
        Object obj = updates.value;

        if(!updates.isSet || !(obj instanceof List<Object>)) {
            return new List<Service_Activity__c>();
        }

        List<Base311_PatchValue> pvs = Base311_PatchValue.fromPatchValue(updates);

        Map<String, Service_Activity__c> mappedSA = new Map<String, Service_Activity__c>();

        for(Service_Activity__c sa : c.Service_Activities__r) {
            mappedSA.put(sa.Name, sa);
        }

        List<Service_Activity__c> updatedSA = new List<Service_Activity__c>();

        List<String> fields = new List<String>{
            'Incap311__Status__c', 'Incap311__Expected_Date_Time__c', 'Incap311__Description__c'
        };

        if(!Base311_Security.areUpdateable(Service_Activity__c.SObjectType, fields)) {
            throw new Base311_Exceptions.SecurityException('User does not have access to update Service Activities');
        }

        for(Base311_PatchValue pv : pvs) {
            Base311_PatchValue code = Base311_PatchValue.fromPatchValue(pv, 'code');
            Base311_PatchValue status = Base311_PatchValue.fromPatchValue(pv, 'status');
            Base311_PatchValue completionDate = Base311_PatchValue.fromPatchValue(pv, 'completion_date');
            Base311_PatchValue comment = Base311_PatchValue.fromPatchValue(pv, 'comment');

            Base311_Activity ra = new Base311_Activity(
                String.valueOf(code.value), String.valueOf(status.value), 
                String.valueOf(completionDate.value), String.valueOf(comment.value)
            );

            Service_Activity__c sa = mappedSA.get(String.valueOf(code.value));

            ra.setSA(sa).validate().throwErrors();

            if(status.isSet) {
                sa.Status__c = String.valueOf(status.value);
            }

            if(completionDate.isSet) {
                sa.Expected_Date_Time__c = Base311_Helper.parseDate(String.valueOf(completionDate.value));
            }

            if(comment.isSet) {
                sa.Description__c = String.valueOf(comment.value);
            }

            updatedSA.add(sa);
        }

        update updatedSA;

        return updatedSA;
    }

    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global List<Service_Activity__c> upsertServiceActivities(Case c, Service_Type_Version__c version, List<Base311_Activity> updates) {
        List<String> createFields = new List<String>{
            'Incap311__Service_Request__c', 'Incap311__Service_Type_Version_Activity__c',/* JOHN BENSON 'Incap311__Due_Date__c',*/
            'Incap311__Status__c', 'Incap311__Expected_Date_Time__c'
        };

        List<String> updateFields = new List<String>{
            'Incap311__Status__c', 'Incap311__Expected_Date_Time__c'
        };

        if(!Base311_Security.areUpdateable(Service_Activity__c.SObjectType, updateFields) || !Base311_Security.areCreateable(Service_Activity__c.SObjectType, createFields)) {
            throw new Base311_Exceptions.SecurityException('User does not have access to update Service Activities');
        }

        List<Service_Activity__c> services = c.Service_Activities__r != null ? c.Service_Activities__r : new List<Service_Activity__c>();
        Map<String, Service_Activity__c> codeMapped = new Map<String, Service_Activity__c>();
        Map<String, Service_Activity__c> activityMapped = new Map<String, Service_Activity__c>();
        Map<String, Base311_Activity> mappedUpdates = new Map<String, Base311_Activity>();
        Map<String, Service_Activity__c> mapped = new Map<String, Service_Activity__c>();

        // map existing services to their codes (to be matched against updates)
        // and their type activity (to determine if they've already been created)
        for(Service_Activity__c service : services) {
            codeMapped.put(service.Name, service);
            activityMapped.put(service.Service_Type_Version_Activity__c, service);
        }

        // for each update; start by checking if its for known service.
        // if not; throw an error.
        // otherwise, map it against the versioned activity so we can 
        // retrieve it later
        for(Base311_Activity restActivityUpdate : updates) {
            Service_Activity__c serv = codeMapped.get(restActivityUpdate.code);
            restActivityUpdate.setSA(serv).validate().throwErrors();   
            mappedUpdates.put(serv.Service_Type_Version_Activity__c, restActivityUpdate);
        }

        List<Service_Activity__c> finalServices = new List<Service_Activity__c>();

        if(version == null || version.Service_Type_Version_Activities__r == null) {
            return finalServices;
        }
 
        for(Service_Type_Version_Activity__c svta : version.Service_Type_Version_Activities__r) {

            // if we have a previously created Service; use it; otherwise make a new one
            // if we have updates ot make, grab them; other wise grab an empty update
            Service_Activity__c serv = activityMapped.containsKey(svta.Id) ? activityMapped.get(svta.Id) : new Service_Activity__c();
            Base311_Activity activityUpdate = mappedUpdates.containsKey(serv.Service_Type_Version_Activity__c) ? mappedUpdates.get(serv.Service_Type_Version_Activity__c) : new Base311_Activity();

            // only on create
            if(serv.Id == null && !svta.optional__c) 
            {
                serv.Service_Request__c = c.Id;
                serv.Service_Type_Version_Activity__c = svta.Id;
                // JOHN BENSON serv.Due_Date__c = Base311_DateTime_Util.getEndDate(System.now(), svta.SLA_Type__c, svta.SLA__c, false);
                serv.Status__c = 'Not Started';
                finalServices.add(serv);
            }

            // only on update
            if(serv.Id != null) {
                serv.Status__c = activityUpdate.status;
                serv.Expected_Date_Time__c = Base311_Helper.parseDate(activityUpdate.completion_date);
                finalServices.add(serv);
            }
        }

        System.debug('final activities ' + finalServices);

        upsert finalServices;


        return finalServices;
    }

    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    @InvocableMethod(label='Set Next Activity' description='This sets the next activity to active')
    Global static List<ID> setNextActivity(List<Id> saIds) {

        Map<Id, Incap311__Service_Activity__c> serviceActivities =  new Map<Id, Incap311__Service_Activity__c>([select id, Incap311__Service_Request__c,Incap311__Allowable_Outcome__c,
                                                                                                                Incap311__Service_Type_Version_Activity__r.Incap311__Activity__c,Incap311__Service_Type_Version_Activity__r.Incap311__Next_Activity__c 
                                                                                                                from Incap311__Service_Activity__c 
                                                                                                                where id in :saIds ]);
        // get all the service activities related to the SA's SR
        List<Id> srIds = new List<Id>();
        List<Id> outcomeIds = new List<Id>();
        List<Id> ActivityIds = new List<Id>();
        list<String> nextActivityCodes = new list<String>();
        
        System.debug('serviceActivities    '+serviceActivities);
        
        for (Incap311__Service_Activity__c sa : serviceActivities.values()) {
            srIds.add(sa.Incap311__Service_Request__c);
            outcomeIds.add(sa.Incap311__Allowable_Outcome__c);
            ActivityIds.add(sa.Incap311__Service_Type_Version_Activity__r.Incap311__Activity__c);
            nextActivityCodes.add(sa.Incap311__Service_Type_Version_Activity__r.Incap311__Next_Activity__c);
        }

        list<Incap311__Activity_Outcome__c> activityOutcomes= [select Incap311__Next_Activity__c,Incap311__Activity__c,Incap311__outcome__c  from Incap311__Activity_Outcome__c where Incap311__Activity__c in :ActivityIds and Incap311__outcome__c in :outcomeIds and Incap311__Next_Activity__c != ''];
        Map<String,Map<String,String>> activityOutcomeNextActOverride = new  Map<String,Map<String,String>>();
        for(Incap311__Activity_Outcome__c activityOutcome: activityOutcomes){
            if(!activityOutcomeNextActOverride.containsKey(activityOutcome.Incap311__Activity__c)){
                activityOutcomeNextActOverride.put(activityOutcome.Incap311__Activity__c, new Map<String,String>());
            }
            activityOutcomeNextActOverride.get(activityOutcome.Incap311__Activity__c).put((String)activityOutcome.Incap311__outcome__c,activityOutcome.Incap311__Next_Activity__c);
            nextActivityCodes.add(activityOutcome.Incap311__Next_Activity__c);
        }

        list<Incap311__Service_Activity__c> nextActivities = [SELECT Id, 
                                                              Incap311__Status__c,
                                                              Incap311__Service_Request__c, 
                                                              Incap311__Service_Type_Version_Activity__r.Incap311__Next_Activity__c,
                                                              Incap311__Service_Type_Version_Activity__r.Incap311__Activity_Code__c
                                                              FROM Incap311__Service_Activity__c
                                                              WHERE Incap311__Service_Request__c IN :srIds 
                                                              and Incap311__Service_Type_Version_Activity__r.Incap311__Activity_Code__c in :nextActivityCodes];

        Map<String,Map<String,Incap311__Service_Activity__c>> nextActivitiesMap = new  Map<String,Map<String,Incap311__Service_Activity__c>>();//key1 service request key2 Activity Code
        for(Incap311__Service_Activity__c activity: nextActivities){
            if(!nextActivitiesMap.containsKey(activity.Incap311__Service_Request__c)){
                nextActivitiesMap.put(activity.Incap311__Service_Request__c, new Map<String,Incap311__Service_Activity__c>());
            }
            nextActivitiesMap.get(activity.Incap311__Service_Request__c).put(activity.Incap311__Service_Type_Version_Activity__r.Incap311__Activity_Code__c,activity);
        }
        
         System.debug('activityOutcomes    '+activityOutcomes);
         System.debug('serviceActivities.values()    '+serviceActivities.values());

        // loop through the SA's being updated
        List<Incap311__Service_Activity__c> updateSAs = new List<Incap311__Service_Activity__c>();
        for (Incap311__Service_Activity__c sa : serviceActivities.values()) {
            String nextActivityCode;
            if(activityOutcomeNextActOverride.containsKey((String)sa.Incap311__Service_Type_Version_Activity__r.Incap311__Activity__c) 
               && ActivityOutcomeNextActOverride.get((String)sa.Incap311__Service_Type_Version_Activity__r.Incap311__Activity__c).containsKey((String)sa.Incap311__Allowable_Outcome__c)){
                nextActivityCode = ActivityOutcomeNextActOverride.get((String)sa.Incap311__Service_Type_Version_Activity__r.Incap311__Activity__c).get((String)sa.Incap311__Allowable_Outcome__c);
            }else{
                nextActivityCode =  sa.Incap311__Service_Type_Version_Activity__r.Incap311__Next_Activity__c;
            }
            System.debug('nextActivityCode    '+nextActivityCode);
            if(nextActivitiesMap.containsKey((String)sa.Incap311__Service_Request__c) && nextActivitiesMap.get((String)sa.Incap311__Service_Request__c).containsKey((String)nextActivityCode)){
                Incap311__Service_Activity__c chkSA = nextActivitiesMap.get((String)sa.Incap311__Service_Request__c).get((String)nextActivityCode);
                if (chkSa.ID != sa.Id){
                    chkSA.Incap311__Status__c = 'In Progress';
                    updateSAs.add(chkSA);
                }
            }
        }

        // update the SAs
        if (updateSAs.size() > 0) {
            update updateSAs;
        }

        return null;
    }

}