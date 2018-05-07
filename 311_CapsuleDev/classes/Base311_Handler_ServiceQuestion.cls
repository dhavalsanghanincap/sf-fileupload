/**
* @author 
* @date 
* @group 
* @group-content
* @description 
*/
public with sharing class Base311_Handler_ServiceQuestion extends Base311_Handler {
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    public override void mainEntry(String triggerObject,
        Boolean isBefore, Boolean isAfter, Boolean isInsert, Boolean isUpdate,
        Boolean isDelete, Boolean isUndelete, Boolean isExecuting, list<SObject> newList,
        map<Id,SObject> newMap, list<SObject> oldList, map<Id,SObject> oldMap) {
        
        if (isBefore) {
        	if (isInsert) {
            	if (Base311_Helper.getFeatureEnabled('Lock_Duplicate_Cases')) {
            		Base311_DuplicateRequestsUtil.doNotEditServiceQuestionChildCases(newList, oldMap, isInsert);
            	}
            }
            else if (isUpdate) {
            	if (Base311_Helper.getFeatureEnabled('Lock_Duplicate_Cases')) {
            		Base311_DuplicateRequestsUtil.doNotEditServiceQuestionChildCases(newList, oldMap, isInsert);
            	}
            }
        }
        //else if (isAfter) {
        //}
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    public override void  inProgressEntry(String triggerObject,
        Boolean isBefore, Boolean isAfter, Boolean isInsert, Boolean isUpdate,
        Boolean isDelete, Boolean isUndelete, Boolean isExecuting, list<SObject> newList,
        map<Id,SObject> newMap, list<SObject> oldList, map<Id,SObject> oldMap) {
            
        // in process handling goes here
        
        //Base311_TriggerDispatcher.activeHandler = null;
    }
}