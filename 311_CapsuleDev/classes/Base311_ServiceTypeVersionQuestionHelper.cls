/**
* @author 
* @date 
* @group 
* @group-content
* @description 
*/
global without sharing class Base311_ServiceTypeVersionQuestionHelper {
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    /*
     *  Ensures that the service type version question does not have an order value identical to another for the same service type version
     */
    public static void verifyUniqueOrder(List<Service_Type_Version_Question__c> stvQuestions) {
    	Set<Id> svcTypVerIds = new Set<Id>();
    	for (Service_Type_Version_Question__c newQuest : stvQuestions) {
    		svcTypVerIds.add(newQuest.Service_Type_Version__c);
    	}
    	
		List<Service_Type_Version_Question__c> existingQuests = [SELECT Id, Service_Type_Version__c, Override_Order__c FROM Service_Type_Version_Question__c WHERE Service_Type_Version__c = :svcTypVerIds];
		
		// map questions by service type version
		Map<String, List<Service_Type_Version_Question__c>> questionMap = new Map<String, List<Service_Type_Version_Question__c>>();
		for (Service_Type_Version_Question__c stvq : existingQuests) {
			if (!questionMap.containsKey(stvq.Service_Type_Version__c)) {
				List<Service_Type_Version_Question__c> newList = new List<Service_Type_Version_Question__c>();
				newList.add(stvq);
				questionMap.put(stvq.Service_Type_Version__c, newList);
			}
			else {
				questionMap.get(stvq.Service_Type_Version__c).add(stvq);
			}
		}
    	
		// loop through and if a service type version question is found with an identical order, add error to record and continue loop
		for (Service_Type_Version_Question__c newQuest : stvQuestions) {
			if ((newQuest.Service_Type_Version__c != null) && (questionMap.containsKey(newQuest.Service_Type_Version__c))) {
				// get the version question list for this service type version
                List<Service_Type_Version_Question__c> chkQuests = questionMap.get(newQuest.Service_Type_Version__c);
                for (Service_Type_Version_Question__c chkQuest : chkQuests) {
                	if ((newQuest.Id == null) || ((newQuest.Id != null) && (newQuest.Id != chkQuest.Id))) {
                    	if ((String.isNotBlank(String.valueOf(newQuest.Override_Order__c))) && (chkQuest.Override_Order__c != null) && (newQuest.Override_Order__c == chkQuest.Override_Order__c)) {
                        	newQuest.addError('You cannot create/update the Service Type Version Question for this service type version with an identical Override Order.  Please apply a unique Override Order');
                        	continue;
                    	}
                	}
                }
			}
		}
    }
}