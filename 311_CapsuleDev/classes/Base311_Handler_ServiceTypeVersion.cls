/**
* @author 
* @date 
* @group 
* @group-content
* @description 
*/
public with sharing class Base311_Handler_ServiceTypeVersion extends Base311_Handler {
    
    public class Base311_ServiceTypeVersionHandlerException extends Exception { }
    
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
            if ((isInsert) || (isUpdate)) {
        		Base311_ServiceTypeVersionHelper.verifyUniqueVersionNumber(newList);
        		Base311_ServiceTypeVersionHelper.verifyUniqueServiceName(newList);
                if(Base311_Helper.getFeatureEnabled('X311_STV_Mail_Merge_Check')){
                	Base311_ServiceTypeVersionHelper.checkMailMergeFields(newList);
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
        Base311_ServiceTypeVersionHelper.verifyUniqueVersionNumber(newList);
        Base311_ServiceTypeVersionHelper.verifyUniqueServiceName(newList);
        //Base311_TriggerDispatcher.activeHandler = null;
    }
}