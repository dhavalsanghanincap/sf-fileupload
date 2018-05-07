@isTest
private class Test_Base311_FlexQuestionHelper {

    static testMethod void testQuestionCodeUniqueInsert() {
        // create test data (2 flex questions)
        Question__c q1 = new Question__c(Flex_Question_Code__c='QUEST1', Data_Type__c='Text');
        insert q1;
        
        Question__c q2 = new Question__c(Flex_Question_Code__c='QUEST2', Data_Type__c='Text');
        insert q2;
        
        Test.startTest();
        
        try {
        	Question__c test1 = new Question__c(Flex_Question_Code__c='QUEST1', Data_Type__c='Text');
        	insert test1;
        }
        catch (Exception e) {
        	System.assert(e.getMessage().contains('Please apply a unique Question Code'));
        }
        
        System.debug('@@@@ test question inserted.');
        
        Test.stopTest();
    }
    
    static testMethod void testQuestionCodeUniqueUpdate() {
        // create test data (2 questions)
        Question__c q1 = new Question__c(Flex_Question_Code__c='QUEST1', Data_Type__c='Text');
        insert q1;
        
        Question__c q2 = new Question__c(Flex_Question_Code__c='QUEST2', Data_Type__c='Text');
        insert q2;
        
        Test.startTest();
        try {
	        Question__c test1 = [SELECT Id, Flex_Question_Code__c FROM Question__c WHERE Id = :q1.Id];
	        test1.Flex_Question_Code__c = 'QUEST2';
	        update test1;
        }
        catch (Exception e) {
        	System.assert(e.getMessage().contains('Please apply a unique Question Code'));
        }
        
        System.debug('@@@@ test question updated.');
        
        Test.stopTest();
    }
}