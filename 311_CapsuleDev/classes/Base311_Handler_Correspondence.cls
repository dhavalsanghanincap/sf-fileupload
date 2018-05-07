/**
* @author 
* @date 
* @group 
* @group-content
* @description 
*/
public with sharing class Base311_Handler_Correspondence extends Base311_Handler {
    
    
    public override void mainEntry(String triggerObject,
        Boolean isBefore, Boolean isAfter, Boolean isInsert, Boolean isUpdate,
        Boolean isDelete, Boolean isUndelete, Boolean isExecuting, list<SObject> newList,
        map<Id,SObject> newMap, list<SObject> oldList, map<Id,SObject> oldMap) {
        
         System.debug('Base311_Handler_Correspondence');
        
           Base311_Unit_Of_Work_Interface uow = (Base311_Unit_Of_Work_Interface)Type.forName('Base311_Correspondence_Validation_UOW').newInstance();
        	uow.execute();
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
        Base311_Unit_Of_Work_Interface uow = (Base311_Unit_Of_Work_Interface)Type.forName('Base311_Correspondence_Validation_UOW').newInstance();
        uow.execute();

    }
}