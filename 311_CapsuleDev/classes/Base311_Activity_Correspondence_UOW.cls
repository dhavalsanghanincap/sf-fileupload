public class Base311_Activity_Correspondence_UOW extends Base311_Unit_Of_Work
{
    public Base311_Activity_Correspondence_UOW(){
        name = 'Base311_Activity_Correspondence_UOW';
        if(!mutexIdMap.containsKey('Base311_Activity_Correspondence_UOW')){
            Map<String, Set<Id>> mutexContextMap = new Map<String, Set<Id>>();
            Base311_Unit_Of_Work.mutexIdMap.put('Base311_Activity_Correspondence_UOW', mutexContextMap);

            //if(triggerSetting.isBefore){
            mutexContextMap.put('isBefore',new Set<Id>());
            // }
            // if(triggerSetting.isAfter){
            mutexContextMap.put('isAfter',new Set<Id>());
            //
        }
    }
    public override void run(Maps maps){
        System.debug('Base311_Activity_Correspondence_UOW running');
        list<id> stvasids = new list<id>();
        Map<String,list<id>> stvas = new Map<String,list<id>>();
        list<id> activityIds = new list<id>();
        list<Service_Activity__c> sas = (list<Service_Activity__c>)maps.newSobject.values();
        
        for(Service_Activity__c sa : sas){
            System.debug('1111 service activities '+sa);
            stvasids .add(sa.Incap311__Service_Type_Version_Activity__c);
            if(!stvas.containsKey(sa.Incap311__Service_Type_Version_Activity__c)){
                stvas.put(sa.Incap311__Service_Type_Version_Activity__c,new list<id>());
            }
            stvas.get(sa.Incap311__Service_Type_Version_Activity__c).add(sa.id);
            activityIds.add(sa.id);
        }
        
        
        list<Incap311__Activity_Correspondence__c> activityCorrespondences = [select Service_Type_Version_Activity__c,type__c, 
                                                                              Activity_Outcome__c, 
                                                                             Correspondence__r.Intro__C,Correspondence__r.Body__c,
                                                                             Correspondence__r.closing__c ,Correspondence__r.id
                                                                             from Activity_Correspondence__c where Service_Type_Version_Activity__c in :stvas.keySet() and Active__c = true];
        
        Set<String> mergeFields = new Set<String>();
        list<Base311_Correspondence_Activity> correspondences = new list<Base311_Correspondence_Activity>();
        for(Incap311__Activity_Correspondence__c activityCorrespondence : activityCorrespondences){
            Base311_Correspondence_Activity correspondence = new Base311_Correspondence_Activity(activityCorrespondence);
            correspondences.add(correspondence);
            mergeFields.addAll(correspondence.getMergeFields());
        }
         mergeFields.add('Activity_Outcome__r.Outcome_Code__c');
        
        Map<id,Service_Activity__c> stvasAllfields = new Map<id,Service_Activity__c>(getActivities(mergeFields, activityIds));
        
        
        
        list<case_event__c> caseEvents = new list<case_event__c>();
        for(Incap311__Activity_Correspondence__c activityCorrespondence : activityCorrespondences){
            Base311_Correspondence_Activity correspondence = new Base311_Correspondence_Activity(activityCorrespondence);
            list<Service_Activity__c> validSA = new list<Service_Activity__c>();
            for(id saId : stvas.get(activityCorrespondence.Service_Type_Version_Activity__c)){
                Service_Activity__c sa = stvasAllfields.get(saId);
                if(determineType(sa) == activityCorrespondence.type__c){
                    if('Complete'== activityCorrespondence.type__c ){
                        if(sa.Activity_Outcome__r.Outcome_Code__c != null && activityCorrespondence.Activity_Outcome__c.contains(sa.Activity_Outcome__r.Outcome_Code__c)){
                        validSA.add(sa);
                        }
                    }else{
                   validSA.add(sa);
                    }
                }
            }
            caseEvents.addAll(correspondence.CreateCaseEvents(validSA));
        }
        System.debug('1111  '+caseEvents);
       insert caseEvents;
    }
    
    private string determineType(Service_Activity__c sa){
        String type = '';
        if(Trigger.isUpdate && Trigger.oldMap.containsKey(sa.Id) && Trigger.oldMap.get(sa.Id).get('Status__c') != 'Complete' && sa.status__c == 'Complete'){
            type = 'Complete';
        }else if(Trigger.isUpdate){
            type= 'Update';
        }
        return type;
    }
                                   
    private list<Service_Activity__c> getActivities(Set<String> allFieldsToMerge, list<Id> activityIds){
        List<String> allFieldsToMergel=new List<String>();
        allFieldsToMergel.addAll(allFieldsToMerge);
        
        


        String query = 'SELECT ' + String.join(allFieldsToMergel, ',');
        query += ' FROM Service_Activity__c where Id in :activityIds';
        System.debug(query);
        Map<Id,Case> casesMapFields = new Map<Id,Case>(); //= new Map<Id,Case>((list<case>)Database.query(String.escapeSingleQuotes(query)));
        //need to add a method to validate fields here

        try{
            return (list<Service_Activity__c>)Database.query(String.escapeSingleQuotes(query));
        }catch(Exception e){
        }
        return null;

    }
}