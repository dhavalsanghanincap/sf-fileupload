/**
* @author 
* @date 
* @group 
* @group-content
* @description 
*/
global class Base311_UpdateOpenCaseActivities implements Schedulable, Database.Batchable<Case> {
     
    private Base311_Service_Request sr = new Base311_Service_Request();
    private Base311_Service_Activity sa = new Base311_Service_Activity();
    private Base311_Service_ServiceType sst = new Base311_Service_ServiceType();
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    public static Datetime now {
        get {
            if(Test.isRunningTest()) {
                return Datetime.newInstance(2016, 01, 01, 01, 01, 01);
            }
        
            return Datetime.now();
        }
        
    }
    
    Map<Id, Service_Type__c> types; 
    Map<Id, Service_Type_Version__c> typeVersions;
    Map<Id, Case> cases;
    global static String SCHEDULE_NAME = 'Replace open case activities';
    global static Integer SCHEDULING_TIME_GAP_MINUTES = 5;
    private Integer MAX_BATCH_SIZE = 20;
     
    // Constructor for Scheduled
    public Base311_UpdateOpenCaseActivities(List<Service_Type__c> types) {
        this.types = new Map<Id, Service_Type__c>(types);
    }
    
    public Base311_UpdateOpenCaseActivities(List<Service_Type__c> types, Integer maxBatchSize) {
        this.types = new Map<Id, Service_Type__c>(types);
        this.MAX_BATCH_SIZE = maxBatchSize;
    }
    
    // Constructor of Batchable
    public Base311_UpdateOpenCaseActivities(List<Case> cases) {
        this.cases = new Map<Id, Case>(cases);
        this.typeVersions = new Map<Id, Service_Type_Version__c>(sst.getActiveServiceTypes(true));
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    public static Id schedule(Service_Type__c st) {
        return schedule(new List<Service_Type__c>{ st }, false);
    }

    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    private static Integer boundValue(Integer v, Integer min, Integer max) {
        if(v < min) {
            return min; 
        }
        
        if(v > max) {
            return max; 
        }
        return v;
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    public static String buildCRONTime(Boolean useNow) {
        if(useNow) {
            Datetime n = now;

            Integer hours = boundValue(n.hour(), 0, 23);
            Integer minutes = boundValue(n.minute() + SCHEDULING_TIME_GAP_MINUTES, 0, 59);
            Integer seconds = boundValue(n.second(), 0, 59);

            return String.valueOf(seconds) + ' ' + String.valueOf(minutes) + ' ' + String.valueOf(hours) + ' * * ?'; 
        }
        
        return '0 0 1 * * ?';
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    public static Id schedule(List<Service_Type__c> types, Boolean runNow) {
        
        
        String jobName = SCHEDULE_NAME;
        
        if(types.size() == 1) {
            jobName += ' for ' + types[0].Name;
        } else {
            jobName += ' at ' + String.valueOf(Datetime.now()) + ' for ' + types.size() + ' types';
        }
        
        List<CronTrigger> job =  [
            SELECT 
                Id, CronJobDetail.Id, CronJobDetail.Name, CronJobDetail.JobType 
            FROM 
                CronTrigger 
            where 
                CronJobDetail.Name = :jobName
        ];
        
        if(job.size() > 0) {
            System.abortJob(job[0].Id);
        }
        
        return System.schedule(
            jobName, 
            buildCRONTime(runNow), 
            new Base311_UpdateOpenCaseActivities(types)
        );
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global void execute(SchedulableContext sc) {
        Map<Id, Case> objects = new Map<Id, Case>(sr.getOpenCasesByServiceType(types.keySet()));
                 
        List<List<Case>> groups = new List<List<Case>>();
        
        for(Integer i = 0; i < objects.values().size(); i++) {
            Integer currentGroupIndex = Integer.valueOf(Math.floor(i / MAX_BATCH_SIZE));
            
            if(groups.size() < currentGroupIndex + 1) {
                groups.add(new List<SObject>());
            }
            
            groups[currentGroupIndex].add(objects.values()[i]);
        }
        
        for(List<Case> grouped : groups) {
            Id jobId = Database.executeBatch(new Base311_UpdateOpenCaseActivities(grouped));
        }
        
        if(sc != null) {
            System.abortJob(sc.getTriggerId());
        }
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global Iterable<Case> start(Database.BatchableContext bc) {
        return this.cases.values();
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global void execute(Database.BatchableContext bc, List<Case> scope) {
        List<Service_Activity__c> activities = new List<Service_Activity__c>();
        List<Case> updatedCases = new List<Case>();
        
        for(Case c : scope) {
            // Get the Case's current version; check it's Type's active version
            Id newVersion = c.Service_Type_Version__r.Service_Type__r.Active_Service_Type_Version__c;
 
            if(newVersion != NULL && newVersion != c.Service_Type_Version__c) {
                c.Service_Type_Version__c = newVersion;
                
                System.debug('Version changed');
                System.debug('Activities : ' + c.Service_Activities__r);
                for(Service_Activity__c sa : c.Service_Activities__r) {
                    sa.Status__c = 'Retired';
                    System.debug('marked as retired');
                    activities.add(sa);
                }
                
                sa.upsertServiceActivities(c, this.typeVersions.get(c.Service_Type_Version__c));
                
                updatedCases.add(c);
                
            }
        }
        
        upsert activities;
        upsert updatedCases;
    }    
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global void finish(Database.BatchableContext bc){
    }
}