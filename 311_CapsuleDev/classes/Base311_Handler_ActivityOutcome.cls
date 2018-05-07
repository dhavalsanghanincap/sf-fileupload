/**
* @author 
* @date 
* @group 
* @group-content
* @description 
*/
public with sharing class Base311_Handler_ActivityOutcome extends Base311_Handler {
    
    
    public override void mainEntry(String triggerObject,
        Boolean isBefore, Boolean isAfter, Boolean isInsert, Boolean isUpdate,
        Boolean isDelete, Boolean isUndelete, Boolean isExecuting, list<SObject> newList,
        map<Id,SObject> newMap, list<SObject> oldList, map<Id,SObject> oldMap) {
        
            if (isBefore) {
                if (isInsert || isUpdate) {
                     if(Base311_Helper.getFeatureEnabled('X311_STV_Mail_Merge_Check')){
                		//Base311_ActivityOutcomeHelper.checkMailMergeFields(newList);
                	}
                    
                }
            }
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

    }
}