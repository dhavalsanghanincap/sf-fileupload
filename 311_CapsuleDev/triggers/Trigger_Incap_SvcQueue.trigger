trigger Trigger_Incap_SvcQueue on Incap311__Service_Queue__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    
	Base311_TriggerDispatcher.callHandler('Service_Queue__c', trigger.isBefore, trigger.isAfter, trigger.isInsert, trigger.isUpdate,
                        	trigger.isDelete, trigger.isUndelete, trigger.isExecuting, trigger.new, trigger.newMap, trigger.old,
                        	trigger.oldMap);
}