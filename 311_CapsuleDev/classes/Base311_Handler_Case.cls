/**
* @author 
* @date 
* @group 
* @group-content
* @description 
*/
public with sharing class Base311_Handler_Case extends Base311_Handler {
    static boolean triggerIsRunningAfter = false;

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

        if (isBefore) {
        	System.debug('>>>-----> BEFORE BEGIN');
            if (isInsert) {
            	System.debug('>>>-----> BEFORE INSERT START');
                // calculate the SLA (which really overrides the initial SLA calculation if necessary)
                if (Base311_Helper.getFeatureEnabled('Dynamic_SLA')) {
                    	System.debug('>>>-----> verifying SLA...');
                		Base311_DateTime_Util.verifySLAonInsert(newList);
                }
                System.debug('>>>-----> BEFORE INSERT END');
            }
            else if (isUpdate) {
            	System.debug('>>>-----> BEFORE UPDATE START');
    			if (Base311_Helper.getFeatureEnabled('Dynamic_SLA')) {
					if ((Test.isRunningTest()) && (UserInfo.getUserId().startsWithIgnoreCase('00541000000EVqE'))) {   // REMOVE !!!
        				System.debug('>>>-----> recalcing SLA...');
        				//Base311_DateTime_Util.recalcSLA(newList, oldMap);
        			}
        		}
                
                if (Base311_Helper.getFeatureEnabled('Lock_Duplicate_Cases')) {
                    Base311_DuplicateRequestsUtil.doNotEditChildCases(newList, oldMap);
                }
                System.debug('>>>-----> BEFORE UPDATE END');
            }
            System.debug('>>>-----> BEFORE COMPLETE');
        }
        else if (isAfter) {
			System.debug('>>>-----> AFTER BEGIN');
            if (isInsert) {
                System.debug('>>>-----> AFTER INSERT START');
                Base311_CaseHelper.caseCreationCaseEvents((Map<Id,Case>)newMap);
                System.debug('>>>-----> AFTER INSERT END');
            }
            else if (isUpdate) {
                System.debug('>>>-----> AFTER UPDATE START');
                System.debug('>>>-----> creating case events...');
                if(!triggerIsRunningAfter){
                    triggerIsRunningAfter = true;
                    Base311_CaseHelper.caseClosureCaseEvents(newMap, oldMap);
                    Base311_CaseHelper.caseTransferCaseEvents(newMap, oldMap);
                }

                if (Base311_Helper.getFeatureEnabled('Duplicate_Case_Notifications')) {
                	System.debug('>>>-----> creating duplicate case events...');
                    Base311_DuplicateRequestsUtil.createCaseEvents(newList, oldMap, newMap);
                }

                if (Base311_Helper.getFeatureEnabled('Update_Dupe_Statuses')) {
                    System.debug('@@@@ in case handler calling update dupe statuses...');
                    Base311_DuplicateRequestsUtil.updateDuplicateStatuses(newMap, oldMap);
                }
                
                System.debug('>>>-----> AFTER UPDATE END');  
            }
            
            System.debug('>>>-----> AFTER COMPLETE');
        }

        Base311_TriggerDispatcher.activeHandlers.remove('Case');
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
        // in process handling goes here

        Base311_TriggerDispatcher.activeHandlers.remove('Case');
    }
}