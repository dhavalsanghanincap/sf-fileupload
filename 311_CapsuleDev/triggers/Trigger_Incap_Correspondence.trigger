/*
 * Block comments with details of changes
 */
trigger Trigger_Incap_Correspondence on Incap311__Correspondence__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    System.debug(' Trigger_Incap_Correspondence on Incap311__Correspondence__c');
	Base311_TriggerDispatcher.callHandler('Correspondence__c', trigger.isBefore, trigger.isAfter, trigger.isInsert, trigger.isUpdate,
                        	trigger.isDelete, trigger.isUndelete, trigger.isExecuting, trigger.new, trigger.newMap, trigger.old,
                        	trigger.oldMap);
}