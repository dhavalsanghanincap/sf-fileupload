public class Base311_SR_Correspondence_UOW extends Base311_Unit_Of_Work
{
    public Base311_SR_Correspondence_UOW(){
        name = 'Base311_SR_Correspondence_UOW';
        if(!mutexIdMap.containsKey('Base311_SR_Correspondence_UOW')){
            Map<String, Set<Id>> mutexContextMap = new Map<String, Set<Id>>();
            Base311_Unit_Of_Work.mutexIdMap.put('Base311_SR_Correspondence_UOW', mutexContextMap);

            //if(triggerSetting.isBefore){
            mutexContextMap.put('isBefore',new Set<Id>());
            // }
            // if(triggerSetting.isAfter){
            mutexContextMap.put('isAfter',new Set<Id>());
            //
        }
    }
      public override void run(Maps maps){
      System.debug('Base311_SR_Correspondence_UOW running');
        list<id> stvsids = new list<id>();
        Map<String,list<id>> stvs = new Map<String,list<id>>();
        list<id> caseIds = new list<id>();
        list<Case> cases = (list<Case>)maps.newSobject.values();
        
        for(Case c : cases){
            stvsids .add(c.Incap311__Service_Type_Version__c);
            if(!stvs.containsKey(c.Incap311__Service_Type_Version__c)){
                stvs.put(c.Incap311__Service_Type_Version__c,new list<id>());
            }
            stvs.get(c.Incap311__Service_Type_Version__c).add(c.id);
            caseIds.add(c.id);
        }
        
        
        list<Service_Type_Version_Correspondence__c> STVCorrespondences = [select Service_Type_Version__c,type__c, 
                                                                             Correspondence__r.Intro__C,Correspondence__r.Body__c,
                                                                             Correspondence__r.closing__c ,Correspondence__r.id
                                                                             from Service_Type_Version_Correspondence__c where Service_Type_Version__c in :stvs.keySet() and Active__c = true];
        
        Set<String> mergeFields = new Set<String>();
        list<Base311_Correspondence_STV> correspondences = new list<Base311_Correspondence_STV>();
        for(Service_Type_Version_Correspondence__c STVCorrespondence : STVCorrespondences){
            Base311_Correspondence_STV correspondence = new Base311_Correspondence_STV(STVCorrespondence);
            correspondences.add(correspondence);
            mergeFields.addAll(correspondence.getMergeFields());
        }
        
        Map<id,Case> stvsAllfields = new Map<id,Case>(getCases(mergeFields, caseIds));
        
        
        
        list<case_event__c> caseEvents = new list<case_event__c>();
        for(Service_Type_Version_Correspondence__c stvCorrespondence : STVCorrespondences){
            Base311_Correspondence_STV correspondence = new Base311_Correspondence_STV(stvCorrespondence);
            list<Case> validCases = new list<Case>();
            for(id caseId : stvs.get(stvCorrespondence.Service_Type_Version__c)){
                Case c = stvsAllfields.get(caseId);
                if(determineType(c,maps) == stvCorrespondence.type__c){
                   validCases.add(c);
                }
            }
            caseEvents.addAll(correspondence.CreateCaseEvents(validCases));
        }
        System.debug('1111  '+caseEvents);
       insert caseEvents;
    }
    
    private string determineType(case c, Base311_Unit_Of_Work.Maps maps){
        String type = '';
        if (((Case)maps.newSobject.get(c.id)).Status == 'Closed' && ((Case)maps.oldSobject.get(c.id)).Status != 'Closed') {
                type = 'close';
            }else if(Trigger.isInsert){
             type = 'create';
        }else if(maps.newSobject.get(c.id).get('Incap311__Service_Type_Version__c') != maps.oldSobject.get(c.id).get('Incap311__Service_Type_Version__c')){
             type = 'transfer';
        }
        return type;
    }
                                   
    private list<case> getCases(Set<String> allFieldsToMerge, list<Id> Ids){
        List<String> allFieldsToMergel=new List<String>();
        allFieldsToMergel.addAll(allFieldsToMerge);
        
        


        String query = 'SELECT ' + String.join(allFieldsToMergel, ',');
        query += ' FROM case where Id in :Ids';
        System.debug(query);
        Map<Id,Case> casesMapFields = new Map<Id,Case>(); //= new Map<Id,Case>((list<case>)Database.query(String.escapeSingleQuotes(query)));
        //need to add a method to validate fields here

        try{
            return (list<case>)Database.query(String.escapeSingleQuotes(query));
        }catch(Exception e){
        }
        return null;

    }
}