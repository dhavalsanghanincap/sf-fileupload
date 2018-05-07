@isTest
private class Test_Base311_ActivityHelper {

    static testMethod void testActivityCodeUniqueInsert() {
        // create test data (2 activities)
        Activity__c act1 = new Activity__c(Activity_Name__c='act1', Activity_Code__c='ACT1');
        insert act1;
        
        Activity__c act2 = new Activity__c(Activity_Name__c='act2', Activity_Code__c='ACT2');
        insert act2;
        
        Test.startTest();
        
        try {
        	Activity__c test1 = new Activity__c(Activity_Name__c='test1', Activity_Code__c='ACT1');
        	insert test1;
        }
        catch (Exception e) {
        	System.assert(e.getMessage().contains('Please apply a unique Activity Code'));
        }
        
        System.debug('@@@@ test activity inserted.');
        
        Test.stopTest();
    }
    
    static testMethod void testActivityCodeUniqueUpdate() {
        // create test data (2 activities)
        Activity__c act1 = new Activity__c(Activity_Name__c='act1', Activity_Code__c='ACT1');
        insert act1;
        
        Activity__c act2 = new Activity__c(Activity_Name__c='act2', Activity_Code__c='ACT2');
        insert act2;
        
        Test.startTest();
        try {
	        Activity__c test1 = [SELECT Id, Activity_Code__c FROM Activity__c WHERE Id = :act1.Id];
	        test1.Activity_Code__c = 'ACT2';
	        update test1;
        }
        catch (Exception e) {
        	System.assert(e.getMessage().contains('Please apply a unique Activity Code'));
        }
        
        System.debug('@@@@ test activity updated.');
        
        Test.stopTest();
    }
}