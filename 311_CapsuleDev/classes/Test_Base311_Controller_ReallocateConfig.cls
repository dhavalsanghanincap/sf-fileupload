@isTest
public class Test_Base311_Controller_ReallocateConfig {

    private static Base311_Service_Reallocate sre = new Base311_Service_Reallocate();
    
    @isTest
    static void testInitialAvailableQueues() {
        User u = Test_RestTestHelper.user();
        Integer countBefore;
        Integer countAfter;
        System.runAs (u) {
            Service_Type__c st = Test_RestTestHelper.serviceType();
            ApexPages.StandardController sc = new ApexPages.StandardController(st);
            
            Base311_Controller_ReallocateConfig ctrl = new Base311_Controller_ReallocateConfig(sc);
            countBefore = ctrl.initialAvailableQueues(false).size();
        }
        
        QueueSobject q = Test_RestTestHelper.queue('Case');
        
        System.runAs (u) {
            Service_Type__c st = Test_RestTestHelper.serviceType();
            ApexPages.StandardController sc = new ApexPages.StandardController(st);
            
            Base311_Controller_ReallocateConfig ctrl = new Base311_Controller_ReallocateConfig(sc);
            countAfter = ctrl.initialAvailableQueues(false).size();
        }
        
        System.assertEquals(countBefore + 1, countAfter);
    }
    
    @isTest
    static void testInitialSelectedQueues() {
        QueueSObject q = Test_RestTestHelper.queue('Case');
        User u = Test_RestTestHelper.user();
        
        q = [ SELECT Queue.Id FROM QueueSObject WHERE Id = :q.Id];
        
        System.runAs (u) {
            Service_Type__c st = Test_RestTestHelper.serviceType();
            ApexPages.StandardController sc = new ApexPages.StandardController(st);
            
            Reallocate_Service_Request_Type__c config = Test_RestTestHelper.reallocateServiceType(q.Queue.Id, st.Id);
            
            Base311_Controller_ReallocateConfig ctrl = new Base311_Controller_ReallocateConfig(sc);
            
            List<SelectOption> results = ctrl.initialSelectedQueues(false);
            System.assertEquals(results.size(), 1);
            System.assertEquals(results[0].getValue(), q.Queue.Id);
        }
    }
    
    @isTest
    static void testSave() {
        QueueSObject q = Test_RestTestHelper.queue('Case');
        QueueSobject q2 = Test_RestTestHelper.queue('Case');
        User u = Test_RestTestHelper.user();
        
        q = [ SELECT Queue.Id FROM QueueSObject WHERE Id = :q.Id];
        q2 = [ SELECT Queue.Id FROM QueueSObject WHERE Id = :q.Id];
        
        System.runAs (u) {
            Service_Type__c st = Test_RestTestHelper.serviceType();
            ApexPages.StandardController sc = new ApexPages.StandardController(st);
            
            Reallocate_Service_Request_Type__c config = Test_RestTestHelper.reallocateServiceType(q.Queue.Id, st.Id);
            
            Base311_Controller_ReallocateConfig ctrl = new Base311_Controller_ReallocateConfig(sc);
            
            ctrl.selectedQueues.remove(0);
            ctrl.selectedQueues.add(new SelectOption(q2.Queue.Id, q2.Queue.Id));
            
            ctrl.save();
            
            List<Reallocate_Service_Request_Type__c> resultingConfigs = sre.getReallocateConfig(st.Id, false);
            System.assertEquals(resultingConfigs.size(), 1);
            System.assertEquals(resultingConfigs[0].Queue_Id__c, q2.Queue.Id);
        }
    }

}