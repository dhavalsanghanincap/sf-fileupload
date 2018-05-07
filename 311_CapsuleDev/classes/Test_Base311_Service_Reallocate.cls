@isTest
public class Test_Base311_Service_Reallocate {

    private static Base311_Service_Reallocate sre = new Base311_Service_Reallocate();

    @isTest
    static void testGetReallocateConfig() {
        QueueSObject q = Test_RestTestHelper.queue('Case');
        User u = Test_RestTestHelper.user();
        
        q = [ SELECT Queue.Id FROM QueueSObject WHERE Id = :q.Id];
        System.runAs (u) {
            Service_Type__c st = Test_RestTestHelper.serviceType();
            Reallocate_Service_Request_Type__c config = Test_RestTestHelper.reallocateServiceType(q.Queue.Id, st.Id);
            
            List<Reallocate_Service_Request_Type__c> results = sre.getReallocateConfig(st.Id, false);
            System.assertEquals(results.size(), 1);
            System.assertEquals(results[0].Id, config.Id);
        }
    }


    @isTest
    static void testGetAvailableQueues() {
		User u = Test_RestTestHelper.user();
        List<QueueSobject> objs1;
        List<QueueSobject> objs2;
        System.runAs (u) {
            objs1 = sre.getAvailableQueues();
        }

        QueueSobject q = Test_RestTestHelper.queue('Case');
        
        System.runAs (u) {
            objs2 = sre.getAvailableQueues();
              
        }
        System.assertEquals(objs1.size() + 1, objs2.size());
    }


    @isTest
    static void testGetActiveReallocateQueues() {
        QueueSObject q = Test_RestTestHelper.queue('Case');
        User u = Test_RestTestHelper.user();
        
        q = [ SELECT Queue.Id FROM QueueSObject WHERE Id = :q.Id];
        System.runAs (u) {
            Service_Type__c st = Test_RestTestHelper.serviceType();
            Test_RestTestHelper.reallocateServiceType(q.Queue.Id, st.Id);
            
            List<QueueSObject> queues = sre.getActiveReallocateQueues(st.Id);
            System.assertEquals(queues.size(), 1);
            System.assertEquals(queues[0].Queue.Id, q.Queue.Id);
        }
    }

}