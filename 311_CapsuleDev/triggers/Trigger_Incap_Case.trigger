trigger Trigger_Incap_Case on Case (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    
	Base311_TriggerDispatcher.callHandler('Case', trigger.isBefore, trigger.isAfter, trigger.isInsert, trigger.isUpdate,
                        	trigger.isDelete, trigger.isUndelete, trigger.isExecuting, trigger.new, trigger.newMap, trigger.old,
                        	trigger.oldMap);
}