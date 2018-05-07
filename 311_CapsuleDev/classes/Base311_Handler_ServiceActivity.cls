/**
* @author 
* @date 
* @group 
* @group-content
* @description 
*/
public with sharing class Base311_Handler_ServiceActivity extends Base311_Handler {

    private static Base311_Service_Activity act = new Base311_Service_Activity();

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
		System.debug('Excuting Main');
        Base311_Unit_Of_Work_Interface uow = (Base311_Unit_Of_Work_Interface)Type.forName('Base311_Activity_Correspondence_UOW').newInstance();
        uow.execute();
        
        if (isBefore) {
            if (isInsert || isUpdate) {
                if (Base311_Helper.getFeatureEnabled('Lock_Duplicate_Cases')) {
                    Base311_DuplicateRequestsUtil.doNotEditServiceActivityChildCases(newList, oldMap, isInsert);
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
        System.debug('Excuting In progress ');
        Base311_Unit_Of_Work_Interface uow = (Base311_Unit_Of_Work_Interface)Type.forName('Base311_Activity_Correspondence_UOW').newInstance();
        uow.execute();

        if (isAfter) {
            if(isUpdate) {
                act.trackOutcomes(newMap, oldMap);
            }
        } 
        //Base311_TriggerDispatcher.activeHandler = null;
    }
}