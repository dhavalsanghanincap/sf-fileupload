/**
* @author 
* @date 
* @group 
* @group-content
* @description 
*/
global without sharing class Base311_OutcomeHelper {
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    /*
     *  Ensures that the outcome does not have an outcome code identical to any other outcomes
     */
    public static void verifyUniqueOutcomeCode(List<Outcome__c> outcomes) {
    	// get all activities
		List<Outcome__c> existingOuts = [SELECT Id, Outcome_Code__c FROM Outcome__c];

    	// loop through new outcomes (outer loop) and compare to all other outcomes (inner loop)
		for (Outcome__c newOut : outcomes) {
            for (Outcome__c chkOut : existingOuts) {
            	if ((newOut.Id == null) || ((newOut.Id != null) && (newOut.Id != chkOut.Id))) {
                	if ((String.isNotBlank(newOut.Outcome_Code__c)) && (newOut.Outcome_Code__c == chkOut.Outcome_Code__c)) {
                    	newOut.addError('You cannot create/update an Outcome using the entered Outcome Code because it must be unique.  Please apply a unique Outcome Code');
                    	continue;
                	}
            	}
            }
		}
    }
}