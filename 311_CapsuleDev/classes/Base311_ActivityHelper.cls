/**
* @author Sean Murphy
* @date 3/28/2017   
* @group helper
* @group-content
* @description Class containing all helper methods for Activity object
*/
global without sharing class Base311_ActivityHelper {
    
    /**
    * @description Ensures that the activity does not have an activity code identical to any other activities
    * @param activities is list of activities
    * @return void
    * @example
    */
    
    public static void verifyUniqueActivityCode(List<Activity__c> activities) {
    	// get all activities
		List<Activity__c> existingActs = [SELECT Id, Activity_Code__c FROM Activity__c];

    	// loop through new activities (outer loop) and compare to all other activities (inner loop)
		for (Activity__c newAct : activities) {
            for (Activity__c chkAct : existingActs) {
            	if ((newAct.Id == null) || ((newAct.Id != null) && (newAct.Id != chkAct.Id))) {
                	if ((String.isNotBlank(newAct.Activity_Code__c)) && (newAct.Activity_Code__c == chkAct.Activity_Code__c)) {
                    	newAct.addError('You cannot create/update the Activity using the entered Activity Code because it must be unique.  Please apply a unique Activity Code');
                    	continue;
                	}
            	}
            }
		}
    }
}