/*********
* @author 
* @date 
* @group 
* @group-content
* @description 
*/
public with sharing class Base311_TriggerDispatcher {
	
	public static Map<String,Base311_Handler> activeHandlers = new Map<String,Base311_Handler>();
    public static Base311_Handler activeHandler;
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    public static void callHandler(String triggerObject,
        Boolean isBefore, Boolean isAfter, Boolean isInsert, Boolean isUpdate,
        Boolean isDelete, Boolean isUndelete, Boolean isExecuting, list<SObject> newList,
        map<Id,SObject> newMap, list<SObject> oldList, map<Id,SObject> oldMap)
    {
        Base311_Handler tempHandler;
        System.debug(triggerObject+' == triggerObject');
		if ((Base311_Helper.getTriggerEnabled(triggerObject)) || (Test.isRunningTest())) {
			
			if (activeHandlers.containsKey(triggerObject)) {
	            activeHandlers.get(triggerObject).inProgressEntry(triggerObject, 
	            	isBefore, isAfter, isInsert, isUpdate, isDelete, isUndelete, 
	            	isExecuting, newList, newMap, oldList, oldMap);
	        }
	        else {
	        	if (triggerObject == 'Case') {
	            	tempHandler = new Base311_Handler_Case(); 
	           	}
	           	else if (triggerObject == 'Service_Type_Version__c') {
	            	tempHandler = new Base311_Handler_ServiceTypeVersion();
	           	}
	           	else if (triggerObject == 'Activity__c') {
	            	tempHandler = new Base311_Handler_Activity();
	           	}
	           	else if (triggerObject == 'Outcome__c') {
	            	tempHandler = new Base311_Handler_Outcome();
	           	}
	           	else if (triggerObject == 'Question__c') {
	            	tempHandler = new Base311_Handler_FlexQuestion();
	           	}
	           	else if (triggerObject == 'Service_Type_Version_Activity__c') {
	            	tempHandler = new Base311_Handler_SvcTypeVersionActivity();
	           	}
	           	else if (triggerObject == 'Service_Type_Version_Question__c') {
	            	tempHandler = new Base311_Handler_SvcTypeVersionQuestion();
	           	}
	           	else if (triggerObject == 'Outcome_Question__c') {
	            	tempHandler = new Base311_Handler_OutcomeQuestion();
	           	}
	           	else if (triggerObject == 'Service_Queue__c') {
	            	tempHandler = new Base311_Handler_SvcQueue();
	           	}
	           	else if (triggerObject == 'Service_Queue_Member__c') {
	            	tempHandler = new Base311_Handler_SvcQueueMember();
	           	}
	           	else if (triggerObject == 'Service_Activity__c') {
	            	tempHandler = new Base311_Handler_ServiceActivity();
	           	}
	           	else if (triggerObject == 'Service_Question__c') {
	            	tempHandler = new Base311_Handler_ServiceQuestion();
	           	}
                else if (triggerObject == 'Activity_Outcome__c') {
	            	tempHandler = new Base311_Handler_ActivityOutcome();
	           	}else if (triggerObject == 'Correspondence__c') {
                     System.debug('Dispatching Base311_Handler_Correspondence');
	            	tempHandler = new Base311_Handler_Correspondence();
	           	}
                activeHandlers.put(triggerObject,tempHandler);
                tempHandler.mainEntry(triggerObject, 
	                	isBefore, isAfter, isInsert, isUpdate, isDelete, isUndelete, 
	                	isExecuting, newList, newMap, oldList, oldMap);
	        }
		}
    }
}