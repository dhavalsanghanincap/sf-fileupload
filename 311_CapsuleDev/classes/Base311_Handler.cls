/*********
* @author Sean Murphy    
* @date  10/31/2016 
* @group 
* @group-content
* @description 
*/
public abstract class Base311_Handler {
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    public abstract void mainEntry(String triggerObject,
        Boolean isBefore, Boolean isAfter, Boolean isInsert, Boolean isUpdate,
        Boolean isDelete, Boolean isUndelete, Boolean isExecuting, list<SObject> newList,
        map<Id,SObject> newMap, list<SObject> oldList, map<Id,SObject> oldMap);
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    public abstract void inProgressEntry(String triggerObject,
        Boolean isBefore, Boolean isAfter, Boolean isInsert, Boolean isUpdate,
        Boolean isDelete, Boolean isUndelete, Boolean isExecuting, list<SObject> newList,
        map<Id,SObject> newMap, list<SObject> oldList, map<Id,SObject> oldMap);

}