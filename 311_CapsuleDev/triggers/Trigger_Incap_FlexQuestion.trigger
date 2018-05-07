trigger Trigger_Incap_FlexQuestion on Incap311__Question__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    
    Base311_TriggerDispatcher.callHandler('Question__c', trigger.isBefore, trigger.isAfter, trigger.isInsert, trigger.isUpdate,
                                	trigger.isDelete, trigger.isUndelete, trigger.isExecuting, trigger.new, trigger.newMap, trigger.old,
                                	trigger.oldMap);
}