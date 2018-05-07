/**
* @author 
* @date 
* @group 
* @group-content
* @description 
*/
public class Base311_TriggerHandler_Case implements Database.Batchable<Case>{
    
    //public static Integer MAX_BATCH_SIZE = 10;
    //private Set<Id> caseIds;
    //private Boolean isCreate;
        
   
    
    //private static Base311_Service_Request sr = new Base311_Service_Request();

    public Base311_TriggerHandler_Case() {
        //isCreate = true;
    }
    
    private Base311_TriggerHandler_Case(Set<Id> cases, Boolean isCreate) {
        //this.caseIds = cases;
        //this.isCreate = isCreate;
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    public static void closeCaseEvents(Set<Id> allCaseIds) {
        //triggerBatches(allCaseIds, false);
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    public static void createCaseEvents(Set<Id> allCaseIds) {
        //triggerBatches(allCaseIds, true);
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    private static void triggerBatches(Set<Id> allCaseIds, Boolean isCreate) {
        /*List<Set<Id>> idGroups = new List<Set<Id>>();
        List<Id> listAllCaseIds = new List<Id>(allCaseIds);
        
        for(Integer i = 0; i < allCaseIds.size(); i++) {
            Integer currentGroupIndex = Integer.valueOf(Math.floor(i / MAX_BATCH_SIZE));
            
            if(idGroups.size() < (currentGroupIndex + 1)) {
                idGroups.add(new Set<Id>());
            }
 
            idGroups[currentGroupIndex].add(listAllCaseIds.get(i));
        }
        
        for(Set<Id> idGroup : idGroups) {
            Database.executeBatch(new Base311_TriggerHandler_Case(idGroup, isCreate));
        }*/
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    public Iterable<Case> start(Database.BatchableContext bc) {
        //return sr.getServiceRequests(caseIds);
        return null;
    }
    
    /*private Boolean shouldTrack(Case c) {
        return isCreate ? 
            ( c.Service_Type_Version__r.Send_Email_On_SR_Creation__c && c.Service_Type_Version__r.Track_SR_Creation_Email__c ) : 
            ( c.Service_Type_Version__r.Send_Email_On_SR_Closed__c  && c.Service_Type_Version__r.Track_SR_Closure_Email__c );
    }*/
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    public void execute(Database.BatchableContext bc, List<Case> cases) {
        /*List<Case_Event__c> ces = new List<Case_Event__c>();
        
        for(Case c : cases) {
            if(c.Service_Type_Version__r != null && shouldTrack(c)) {
                ces.add(new Case_Event__c(
                    Event_Type__c = isCreate ? 'Create' : 'Close',
                    Notification_Recipient__c = c.Contact.Email,
                    Service_Request__c = c.Id,
                    Rich_Email_Body__c = Base311_MailMerge.caseNotifyEmail(c, isCreate)
                )); 
            }
        }
        
        insert ces;*/
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    public void finish(Database.BatchableContext bc) {
    }
}