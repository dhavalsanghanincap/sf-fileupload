@isTest
public with sharing class Test_Base311_SvcTypeVerQuestionHelper {
    
    static testMethod void testOrderUniqueInsert() {
        // create test data (1 service type version, 3 questions, 2 service type version questions)
        Service_Type__c st = Test_RestTestHelper.serviceType();
        
        Service_Type_Version__c stv = Test_RestTestHelper.serviceTypeVersion(st.Id);
        stv.Version_Number__c = 1;
        update stv;
        
        Question__c q1 = new Question__c(Flex_Question_Code__c='QUEST1', Data_Type__c='Text');
        insert q1;
        
        Service_Type_Version_Question__c stvq1 = new Service_Type_Version_Question__c(Service_Type_Version__c=stv.Id, Question__c=q1.Id, Override_Order__c=1);
        insert stvq1;
        
        Question__c q2 = new Question__c(Flex_Question_Code__c='QUEST2', Data_Type__c='Text');
        insert q2;
        
        Service_Type_Version_Question__c stvq2 = new Service_Type_Version_Question__c(Service_Type_Version__c=stv.Id, Question__c=q2.Id, Override_Order__c=2);
        insert stvq2;
        
        Question__c q3 = new Question__c(Flex_Question_Code__c='QUEST3', Data_Type__c='Text');
        insert q3;
        
        Test.startTest();
        
        try {
        	Service_Type_Version_Question__c test1 = new Service_Type_Version_Question__c(Service_Type_Version__c=stv.Id, Question__c=q3.Id, Override_Order__c=1);
        	insert test1;
        }
        catch (Exception e) {
        	System.assert(e.getMessage().contains('Please apply a unique Override Order'));
        }
        
        System.debug('@@@@ test service type version question inserted.');
        
        Test.stopTest();
    }
    
    static testMethod void testOrderUniqueUpdate() {
        // create test data (1 service type version, 3 activities, 2 service type version activities)
        Service_Type__c st = Test_RestTestHelper.serviceType();
        
        Service_Type_Version__c stv = Test_RestTestHelper.serviceTypeVersion(st.Id);
        stv.Version_Number__c = 1;
        update stv;
        
        Question__c q1 = new Question__c(Flex_Question_Code__c='QUEST1', Data_Type__c='Text');
        insert q1;
        
        Service_Type_Version_Question__c stvq1 = new Service_Type_Version_Question__c(Service_Type_Version__c=stv.Id, Question__c=q1.Id, Override_Order__c=1);
        insert stvq1;
        
        Question__c q2 = new Question__c(Flex_Question_Code__c='QUEST2', Data_Type__c='Text');
        insert q2;
        
        Service_Type_Version_Question__c stvq2 = new Service_Type_Version_Question__c(Service_Type_Version__c=stv.Id, Question__c=q2.Id, Override_Order__c=2);
        insert stvq2;
        
        Test.startTest();
        
        try {
        	Service_Type_Version_Question__c test1 = [SELECT Id, Order__c, Override_Order__c FROM Service_Type_Version_Question__c WHERE Id = :stvq2.Id];
        	test1.Override_Order__c = 1;
        	update test1;
        }
        catch (Exception e) {
        	System.assert(e.getMessage().contains('Please apply a unique Override Order'));
        }
        
        System.debug('@@@@ test service type version question updated.');
        
        Test.stopTest();
    }
}