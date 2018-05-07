/**
* @author 
* @date 
* @group 
* @group-content
* @description 
*/
global without sharing class Base311_FlexQuestionHelper {
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
     /*
     *  Ensures that the flex questions do not have a question code identical to any other flex questions
     */
    public static void verifyUniqueQuestionCode(List<Question__c> questions) {
    	// get all questoins
		List<Question__c> existingQuests = [SELECT Id, Flex_Question_Code__c FROM Question__c];

    	// loop through new questions (outer loop) and compare to all other questions (inner loop)
		for (Question__c newQuest : questions) {
            for (Question__c chkQuest : existingQuests) {
            	if ((newQuest.Id == null) || ((newQuest.Id != null) && (newQuest.Id != chkQuest.Id))) {
                	if ((String.isNotBlank(newQuest.Flex_Question_Code__c)) && (newQuest.Flex_Question_Code__c == chkQuest.Flex_Question_Code__c)) {
                    	newQuest.addError('You cannot create/update a Question using the entered Question Code because it must be unique.  Please apply a unique Question Code');
                    	continue;
                	}
            	}
            }
		}
    }
}