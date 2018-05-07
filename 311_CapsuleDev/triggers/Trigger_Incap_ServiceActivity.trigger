trigger Trigger_Incap_ServiceActivity on Incap311__Service_Activity__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    
    System.debug('Service Activity Trigger started');
    System.debug('Is After ? ' + Trigger.iSafter);
    Base311_TriggerDispatcher.callHandler('Service_Activity__c', 
                                          trigger.isBefore, 
                                          trigger.isAfter, 
                                          trigger.isInsert, 
                                          trigger.isUpdate,
                                		  trigger.isDelete, 
                                          trigger.isUndelete, 
                                          trigger.isExecuting, 
                                          trigger.new, 
                                          trigger.newMap, 
                                          trigger.old,
                                	      trigger.oldMap);
}