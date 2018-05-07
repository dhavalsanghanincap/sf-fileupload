/**
* @author 
* @date 
* @group 
* @group-content
* @description 
*/
global without sharing class Base311_OutcomeQuestionHelper {
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    /*
     *  Ensures that the outcome question does not have an order value identical to another for the same activity outcome
     */
    public static void verifyUniqueOrder(List<Outcome_Question__c> outQuestions) {
    	Set<Id> activityOutcomeIds = new Set<Id>();
    	for (Outcome_Question__c newOutQ : outQuestions) {
    		activityOutcomeIds.add(newOutQ.Incap311__Service_Type_Version_Activity_Outcome__c);
    	}
    	
    	System.debug('>>>-----> activity outcome ids: ' + activityOutcomeIds);
    	
		List<Outcome_Question__c> existingQuests = [SELECT Id, Incap311__Service_Type_Version_Activity_Outcome__c, Override_Order__c FROM Outcome_Question__c WHERE Incap311__Service_Type_Version_Activity_Outcome__c = :activityOutcomeIds];
		
		System.debug('>>>-----> existing questions: ' + existingQuests);
		
		// map questions by outcome
		Map<String, List<Outcome_Question__c>> outQuestMap = new Map<String, List<Outcome_Question__c>>();
		for (Outcome_Question__c outq : existingQuests) {
			if (!outQuestMap.containsKey(outq.Incap311__Service_Type_Version_Activity_Outcome__c)) {
				List<Outcome_Question__c> newList = new List<Outcome_Question__c>();
				newList.add(outq);
				outQuestMap.put(outq.Incap311__Service_Type_Version_Activity_Outcome__c, newList);
			}
			else {
				outQuestMap.get(outq.Incap311__Service_Type_Version_Activity_Outcome__c).add(outq);
			}
		}
    	
		// loop through and if an outcome question is found with an identical order, add error to record and continue loop
		for (Outcome_Question__c newOutQ : outQuestions) {
			if ((newOutQ.Incap311__Service_Type_Version_Activity_Outcome__c != null) && (outQuestMap.containsKey(newOutQ.Incap311__Service_Type_Version_Activity_Outcome__c))) {
				// get the version list for this service type
                List<Outcome_Question__c> chkQuests = outQuestMap.get(newOutQ.Incap311__Service_Type_Version_Activity_Outcome__c);
                for (Outcome_Question__c chkOutQ : chkQuests) {
                	if ((newOutQ.Id == null) || ((newOutQ.Id != null) && (newOutQ.Id != chkOutQ.Id))) {
                    	if ((String.isNotBlank(String.valueOf(newOutQ.Override_Order__c))) && (newOutQ.Override_Order__c == chkOutQ.Override_Order__c)) {
                        	newOutQ.addError('You cannot create/update the Outcome Question for this Activity Outcome with an identical Override Order.  Please apply a unique Override Order');
                        	continue;
                    	}
                	}
                }
			}
		}
    }
}