@isTest
public class Test_Base311_SchedOperationalSLABatch {
    
    static testMethod void testMethod1(){
    	// setup service type and service type version
    	Service_Type__c st = Test_RestTestHelper.serviceType();
    	Service_Type_Version__c stv = Test_RestTestHelper.serviceTypeVersion(st.Id);
    	stv.SLA__c = 7;
    	stv.SLA_Type__c = 'Calendar Days';
    	stv.Start_Date__c = Date.today().addDays(-30);
    	stv.Stop_Date__c = Date.today().addDays(150);
    	update stv;
    	
    	Case testCase = new Case();
    	testCase.Service_Type_Version__c = stv.Id;
    	testCase.Expected_Start_Date__c = DateTime.now().addDays(-2);
    	testCase.Requested_Date_Time__c = DateTime.now().addDays(-2);
    	testCase.Expected_Date_Time__c = DateTime.now();
    	testCase.Subject = 'testing';
    	insert testCase;
    	
    	Case qc = [SELECT Id, Status FROM Case WHERE Id = :testCase.Id];
    	qc.Status = 'Hold';
    	update qc;
    	
    	Test.startTest();
    	
        Base311_Sched_OperationalSLABatch sched = new Base311_Sched_OperationalSLABatch();      
	    String cron = '0 0 23 * * ?';
	    system.schedule('Test check', cron, sched);
    	
    	Test.stopTest();
    }
}