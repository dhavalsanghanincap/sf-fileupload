@isTest
public with sharing class Test_Base311_OutcomeQuestionHelper {
    
    static testMethod void testOrderUniqueInsert() {
        // create test data (1 outcome, 3 questions, 2 outcome questions)
        
        Activity__c a = new Activity__c(Activity_Code__c = 'AC123');
        insert a;
        
        Outcome__c oc = new Outcome__c(Outcome_Code__c = 'OC123');
        insert oc;
        
        Service_Type_Version__c stv = Test_RestTestHelper.sericeTypeVersionAndVersion();
        Service_Type_Version_Activity__c stva = Test_RestTestHelper.serviceTypeVersionActivity(a.Id, stv.Id);
        
        Activity_Outcome__c ao = new ACtivity_Outcome__c(Activity__c = a.Id, Outcome__c = oc.Id, Service_Type_Version_Activity__c = stva.Id);
        insert ao;
        
        Question__c q1 = new Question__c(Flex_Question_Code__c='QUEST1', Data_Type__c='Text');
        insert q1;
        
        Outcome_Question__c ocq1 = new Outcome_Question__c(Activity_Outcome__c=oc.Id, Question__c=q1.Id, Override_Order__c=1, Service_Type_Version_Activity_Outcome__c = ao.Id);
        insert ocq1;
        
        System.debug('>>>-----> created outcome question 1 with id: ' + ocq1.Id);
        
        Question__c q2 = new Question__c(Flex_Question_Code__c='QUEST2', Data_Type__c='Text');
        insert q2;
        
        Outcome_Question__c ocq2 = new Outcome_Question__c(Activity_Outcome__c=oc.Id, Question__c=q2.Id, Override_Order__c=2, Service_Type_Version_Activity_Outcome__c = ao.Id);
        insert ocq2;
        
        System.debug('>>>-----> created outcome question 2 with id: ' + ocq2.Id);
        
        Question__c q3 = new Question__c(Flex_Question_Code__c='QUEST3', Data_Type__c='Text');
        insert q3;
        
        Test.startTest();
        
        try {
        	Outcome_Question__c test1 = new Outcome_Question__c(Activity_Outcome__c=oc.Id, Question__c=q3.Id, Override_Order__c=1,Service_Type_Version_Activity_Outcome__c=ao.Id);
        	insert test1;
        	
        	System.debug('>>>-----> created test outcome question 1 with id: ' + test1.Id);
        }
        catch (Exception e) {
        	System.assert(e.getMessage().contains('Please apply a unique Override Order'));
        }
        
        System.debug('@@@@ test outcome question inserted.');
        
        Test.stopTest();
    }
    
    static testMethod void testOrderUniqueUpdate() {
        // create test data (1 outcome, 2 questions, 2 outcome questions)
        Outcome__c oc = new Outcome__c(Outcome_Code__c = 'OC123');
        insert oc;
        
        Activity__c a = new Activity__c(Activity_Code__c = 'AC123');
        insert a;
        
        Service_Type_Version__c stv = Test_RestTestHelper.sericeTypeVersionAndVersion();
        Service_Type_Version_Activity__c stva = Test_RestTestHelper.serviceTypeVersionActivity(a.Id, stv.Id);
        
        Activity_Outcome__c ao = new ACtivity_Outcome__c(Activity__c = a.Id, Outcome__c = oc.Id, Service_Type_Version_Activity__c = stva.Id);
        insert ao;
        
        Question__c q1 = new Question__c(Flex_Question_Code__c='QUEST1', Data_Type__c='Text');
        insert q1;
        
        Outcome_Question__c ocq1 = new Outcome_Question__c(Activity_Outcome__c=oc.Id, Question__c=q1.Id, Override_Order__c=1, Service_Type_Version_Activity_Outcome__c = ao.Id);
        insert ocq1;
        
        Question__c q2 = new Question__c(Flex_Question_Code__c='QUEST2', Data_Type__c='Text');
        insert q2;
        
        Outcome_Question__c ocq2 = new Outcome_Question__c(Activity_Outcome__c=oc.Id, Question__c=q2.Id, Override_Order__c=2, Service_Type_Version_Activity_Outcome__c = ao.Id);
        insert ocq2;
        
        Test.startTest();
        
        try {
        	Outcome_Question__c test1 = [SELECT Id, Order__c, Order2__c, Override_Order__c FROM Outcome_Question__c WHERE Id = :ocq2.Id];
        	test1.Override_Order__c = 1;
        	update test1;
        }
        catch (Exception e) {
        	System.assert(e.getMessage().contains('Please apply a unique Override Order'));
        }
        
        System.debug('@@@@ test outcome question updated.');
        
        Test.stopTest();
    }
}