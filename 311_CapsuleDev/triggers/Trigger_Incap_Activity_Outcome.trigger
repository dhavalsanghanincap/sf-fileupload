/*
 * Block comments with details of changes
 */
trigger Trigger_Incap_Activity_Outcome on Incap311__Activity_Outcome__c (before insert)
{
     Base311_TriggerDispatcher.callHandler('Activity_Outcome__c', trigger.isBefore, trigger.isAfter, trigger.isInsert, trigger.isUpdate,
                                	trigger.isDelete, trigger.isUndelete, trigger.isExecuting, trigger.new, trigger.newMap, trigger.old,
                                	trigger.oldMap);
}