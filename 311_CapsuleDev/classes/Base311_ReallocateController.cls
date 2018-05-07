/**
* @author 
* @date 
* @group 
* @group-content
* @description 
*/
/*Class to contain logic for Reallocate Component
* You can pass sObjectAPIName,Controller of the base and sevice type as attribute of the page
* Access the queueID and comment of the component in the page to perform logic
* Developer Name : Vrajesh Sheth
* Date : 05/01/2017
*/

Global with sharing class Base311_ReallocateController extends Base311_ReallocateComponentBase{ 
    //Variables
    Global String comment { get; set; }
    private Boolean forActivities;
    public String serviceType {get;set;}
    public String objectname{get;set;}
    Global String queueID {get;set;}
    private String commentText='';
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    Global void captureselectedInformation(){
        system.debug('=====>'+queueID);
        system.debug('=====>'+comment);
    }
    
    private Base311_Service_Reallocate sre = new Base311_Service_Reallocate();
    //Constructor
    public Base311_ReallocateController(){
        
        if(objectname!= null && objectname.containsIgnoreCase('Service_Activity__c')){
            forActivities = true;
        }
        getQueues();
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    public List<SelectOption> getQueues() {
        List<SelectOption> options = new List<SelectOption>();
        if(objectname!= null && objectname.containsIgnoreCase('Service_Activity__c')){
            forActivities = true;
        } 
        for (QueueSobject  q : sre.getActiveReallocateQueues(serviceType , forActivities)){
            options.add(new SelectOption(q.Queue.Id, q.Queue.Name)); 
        }
        
        return options;
    } 
    
}