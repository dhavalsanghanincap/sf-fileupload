@isTest
private class Test_Base311_OutcomeHelper {

    static testMethod void testOutcomeCodeUniqueInsert() {
        // create test data (2 outcomes)
        Outcome__c out1 = new Outcome__c(Outcome_Detail__c='out1', Outcome_Code__c='OUT1');
        insert out1;
        
        Outcome__c out2 = new Outcome__c(Outcome_Detail__c='out2', Outcome_Code__c='OUT2');
        insert out2;
        
        Test.startTest();
        
        try {
        	Outcome__c test1 = new Outcome__c(Outcome_Detail__c='test1', Outcome_Code__c='OUT1');
        	insert test1;
        }
        catch (Exception e) {
        	System.assert(e.getMessage().contains('Please apply a unique Outcome Code'));
        }
        
        System.debug('@@@@ test outcome inserted.');
        
        Test.stopTest();
    }
    
    static testMethod void testOutcomeCodeUniqueUpdate() {
        // create test data (2 outcomes)
        Outcome__c out1 = new Outcome__c(Outcome_Detail__c='out1', Outcome_Code__c='OUT1');
        insert out1;
        
        Outcome__c out2 = new Outcome__c(Outcome_Detail__c='out2', Outcome_Code__c='OUT2');
        insert out2;
        
        Test.startTest();
        try {
	        Outcome__c test1 = [SELECT Id, Outcome_Code__c FROM Outcome__c WHERE Id = :out1.Id];
	        test1.Outcome_Code__c = 'OUT2';
	        update test1;
        }
        catch (Exception e) {
        	System.assert(e.getMessage().contains('Please apply a unique Outcome Code'));
        }
        
        System.debug('@@@@ test outcome updated.');
        
        Test.stopTest();
    }
}