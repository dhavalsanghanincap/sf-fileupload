trigger Trigger_Incap_Activity on Incap311__Activity__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    
    Base311_TriggerDispatcher.callHandler('Activity__c', trigger.isBefore, trigger.isAfter, trigger.isInsert, trigger.isUpdate,
                                    trigger.isDelete, trigger.isUndelete, trigger.isExecuting, trigger.new, trigger.newMap, trigger.old,
                                    trigger.oldMap);
}