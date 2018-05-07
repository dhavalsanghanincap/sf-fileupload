/**
* @author 
* @date 
* @group 
* @group-content
* @description This class handles both the Scheduling and Batching for updating the Active Version on a Service Type.
* It does NOT handle updating the Activities to Open Cases for Service Types that have had their
* active version changed.
*/

global class Base311_UpdateActiveServiceTypeVersion implements Schedulable, Database.Batchable<Service_Type__c> {
   	private Base311_Service_ServiceType sst = new Base311_Service_ServiceType();
    private static final String SCHEDULING_TIME = '0 0 1 * * ?';
    private Integer maxBatchSize = 30;
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    private static String buildSchedulingName() {
        return 'UPDATE ACTIVE SERVICE TYPE VERSIONS';
    }
    
   	Map<Id, Service_Type__c> types; 
    
    public Base311_UpdateActiveServiceTypeVersion(Integer maxBatchSize) {
        this.maxBatchSize = maxBatchSize;
    }
    
    public Base311_UpdateActiveServiceTypeVersion() {
    }
    
    public Base311_UpdateActiveServiceTypeVersion(List<Service_Type__c> types) {
        this();
        this.types = new Map<Id, Service_Type__c>(types);
    }
 	
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global void execute(SchedulableContext sc) {
        Map<Id, Service_Type__c> objects = new Map<Id, Service_Type__c>(sst.getBaseServiceTypes());
                 
        List<List<Service_Type__c>> groups = new List<List<Service_Type__c>>();
        
        for(Integer i = 0; i < objects.values().size(); i++) {
            Integer currentGroupIndex = Integer.valueOf(Math.floor(i / maxBatchSize));
            
            if(groups.size() < currentGroupIndex + 1) {
                groups.add(new List<SObject>());
            }
            
            groups[currentGroupIndex].add(objects.values()[i]);
        }
        
        for(List<SObject> grouped : groups) {
            Id jobId = Database.executeBatch(new Base311_UpdateActiveServiceTypeVersion(grouped));
        }
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global Iterable<Service_Type__c> start(Database.BatchableContext bc){
        return this.types.values();
    }
    
    private Id getFirstActiveId(List<Service_Type_Version__c> versions) {
        for(Service_Type_Version__c stv : versions) {
            // we should only activate those versions through this cron that have 
            // a start and end date. it is possible to have a manually activatable version
            // that we want to only activate manually
            if(stv.Is_Activatable__c && (stv.Start_Date__c != NULL || stv.Stop_Date__c != NULL)) {
            	return stv.Id;  
            }
        }
        
        return null;
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global void execute(Database.BatchableContext bc, List<Service_Type__c> scope){
        List<Service_Type__c> serviceTypesChanged = new List<Service_Type__c>();
        
        for(Service_Type__c st : scope) {
            
            // record the initial version id for later
            // comparison to schedule other jobs
            Id originalId = st.Active_Service_Type_Version__c;
            
            // if the current version is no longer usable, set our
            // active version to null
            if(!st.Active_Service_Type_Version__r.Is_Activatable__c) {
                st.Active_Service_Type_Version__c = null;
            }
            
            // since the list of versions SHOULD already be sorted, we can just 
            // get the first record where Is_Activatable__c is true
            st.Active_Service_Type_Version__c = getFirstActiveId(st.Service_Type_Versions__r);
            
            // if the id has changed; record the change
            if(originalId != st.Active_Service_Type_Version__c) {
                serviceTypesChanged.add(st);
            }
        }
        
        if(serviceTypesChanged.size() > 0) {
            Base311_UpdateOpenCaseActivities.schedule(serviceTypesChanged, true);
        }
        
        update scope;
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global void finish(Database.BatchableContext bc){
        // do nothing for now?
    }
}