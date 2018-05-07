public virtual class Base311_Unit_Of_Work implements Base311_Unit_Of_Work_Interface{
    public static Map<String, Map<String, Set<Id>>> mutexIdMap = new Map<String, Map<String, Set<Id>>>();//Map<triggername, Map<contextName, Set<sobejctId>>>
    Base311_Unit_Of_Work_Config config;
    public String name= 'Base311_Unit_Of_Work';
    public boolean isafter = true;
    public boolean isbefore = false;

    public void setTriggerSetting(Base311_Unit_Of_Work_Config config){
       /* this.triggerSetting = triggerSetting;

        if(!mutexIdMap.containsKey(triggerSetting.MasterLabel)){
            Map<String, Set<Id>> mutexContextMap = new Map<String, Set<Id>>();
            mutexIdMap.put(triggerSetting.MasterLabel, mutexContextMap);

            //if(triggerSetting.isBefore){
            mutexContextMap.put('isBefore',new Set<Id>());
            // }
            // if(triggerSetting.isAfter){
            mutexContextMap.put('isAfter',new Set<Id>());
            //  }
        }*/
    }

    public Base311_Unit_Of_Work(){

    }



    public void execute(){
        //if(Trigger.isInsert && triggerSetting.isInsert){
        run();
        // }else if(Trigger.isDelete && triggerSetting.isDelete){
        //   run();
        //}else if(Trigger.isUndelete && triggerSetting.isUndelete){
        //   run();
        // }else if(Trigger.isUpdate && triggerSetting.isUpdate){
        //   run();
        //}
    }

    private void run(){
        System.debug('Base311_Unit_Of_Work running');
        if(Trigger.isBefore && isBefore){//triggerSetting.isBefore){
            run(getMaps());
        }
        if(Trigger.isAfter && isAfter){//triggerSetting.isAfter){
            System.debug('Base311_Unit_Of_Work isafter running');
            run(getMaps());
        }
    }

    public virtual void run(Maps maps){
        // code to do stuff goes here
    }


    public Maps getMaps(){
        Maps maps = new Maps();
        Map<Id, SObject> old = Trigger.OldMap;
        String context = Trigger.isBefore ? 'isBefore' : 'isAfter';
        Set<id> mutexId = mutexIdMap.get(name).get(context);
        if(Trigger.isUpdate || Trigger.isInsert){
        for(sobject so : Trigger.new){
            if(!mutexId.contains(so.Id)){
                Maps.newSobject.put(so.Id,so);
                if(Trigger.IsAfter && trigger.IsUpdate){
                    Maps.oldSobject.put(so.Id,old.get(so.Id));
                }
                mutexId.add(so.Id);
            }
        }
        }
        return maps;
    }

    public class Maps{
        public Map<Id, SObject> newSobject = new Map<Id, SObject>();
        public Map<Id, SObject> oldSobject = new Map<Id, SObject>();
    }

}