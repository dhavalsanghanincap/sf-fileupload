/**
* @author 
* @date 
* @group 
* @group-content
* @description 
*/
public with sharing class Base311_Handler_SvcTypeVersionActivity extends Base311_Handler {
    
    public class Base311_SvcTypeVersionActivityHandlerException extends Exception { }
    
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
        		Base311_ServiceTypeVersionActivityHelper.verifyUniqueOrder(newList);
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