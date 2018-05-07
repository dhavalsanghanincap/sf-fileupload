/**
 * test class for Base311_ReallocateController
 * Developer Name : Vrajesh Sheth
 * Date : 05/03/2017
 */
@isTest
private class Test_Base311_ReallocateController {

    @isTest
    static void testGetQueues(){
    	QueueSObject q = Test_RestTestHelper.queue('Case');
    	User u = Test_RestTestHelper.user(); 
    	
    	//Query queue record
    	q = [ SELECT Queue.Id FROM QueueSObject WHERE Id = :q.Id];
    	
    	System.runAs (u) {
    		//Create Service type
    		Service_Type__c st = Test_RestTestHelper.serviceType();
    		//Create Service Type version
    		Service_Type_Version__c stv = Test_RestTestHelper.serviceTypeVersion(st.Id);
    		//Create reallocation queue data
    		Test_RestTestHelper.reallocateServiceType(q.Queue.Id, st.Id);
    		
    		//Controller
    		Base311_ReallocateController contrl = new Base311_ReallocateController();
    		//Setting the attributes
    		contrl.objectname = 'Case';
    		contrl.serviceType = st.id;
    		List<SelectOption> opts = contrl.getQueues();
    		System.assertEquals(opts.size(), 1);
    		System.assertEquals(opts[0].getValue(), q.Queue.Id);
    	}
    }
    
    @isTest
    static void testcaptureselectedInformation(){
    	QueueSObject q = Test_RestTestHelper.queue('Case');
    	User u = Test_RestTestHelper.user(); 
    	
    	//Query queue record
    	q = [ SELECT Queue.Id FROM QueueSObject WHERE Id = :q.Id];
    	
    	System.runAs (u) {
    		//Create Service type
    		Service_Type__c st = Test_RestTestHelper.serviceType();
    		//Create Service Type version
    		Service_Type_Version__c stv = Test_RestTestHelper.serviceTypeVersion(st.Id);
    		//Create reallocation queue data
    		Test_RestTestHelper.reallocateServiceType(q.Queue.Id, st.Id);
    		
    		//Controller
    		Base311_ReallocateController contrl = new Base311_ReallocateController();
    		//Setting the attributes
    		contrl.objectname = 'Case';
    		contrl.serviceType = st.id;
    		List<SelectOption> opts = contrl.getQueues();
    		contrl.queueID = q.Queue.Id;
    		contrl.captureselectedInformation();
    		System.assertEquals(contrl.queueID, q.Queue.Id);
    	}
    }
    
}