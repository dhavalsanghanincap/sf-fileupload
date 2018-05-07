public class Base311_Correspondence_Validation_UOW extends Base311_Unit_Of_Work
{
    public Base311_Correspondence_Validation_UOW(){
        name = 'Base311_Correspondence_Validation_UOW';
        if(!mutexIdMap.containsKey(name)){
            Map<String, Set<Id>> mutexContextMap = new Map<String, Set<Id>>();
            Base311_Unit_Of_Work.mutexIdMap.put(name, mutexContextMap);

            //if(triggerSetting.isBefore){
            mutexContextMap.put('isBefore',new Set<Id>());
            // }
            // if(triggerSetting.isAfter){
            mutexContextMap.put('isAfter',new Set<Id>());
            //
        }
    }
    public override void run(Maps maps){
        for(Sobject so : maps.newSobject.values()){
            System.debug('Validate Fields');
            Base311_Correspondence corr = new Base311_Correspondence((Incap311__Correspondence__c) so);
            corr.validateMergeFields();
        }
    }
}