@isTest
public class Test_Base311_CaseReallocate {
	
    /*@isTest
    static void testGetQueues() {
     	QueueSObject q = Test_RestTestHelper.queue('Case');
        User u = Test_RestTestHelper.user();
        
        q = [ SELECT Queue.Id FROM QueueSObject WHERE Id = :q.Id];
        System.runAs (u) {
            Service_Type__c st = Test_RestTestHelper.serviceType();
            Service_Type_Version__c stv = Test_RestTestHelper.serviceTypeVersion(st.Id);
            Case c = Test_RestTestHelper.serviceRequest(stv.Id);
            Test_RestTestHelper.reallocateServiceType(q.Queue.Id, st.Id);
            
            c = [ SELECT Service_Type_Version__r.Service_Type__c FROM Case WHERE Id = :c.Id ];
            
            ApexPages.StandardController sc = new ApexPages.StandardController(c);
            
            Base311_CaseReallocate ctrl = new Base311_CaseReallocate(sc);
            
        }
    }
    */
    @isTest
    static void testSave() {
        QueueSObject q = Test_RestTestHelper.queue('Case');
        User u = Test_RestTestHelper.user();
        
        q = [ SELECT Queue.Id FROM QueueSObject WHERE Id = :q.Id];
        System.runAs (u) {
            Service_Type__c st = Test_RestTestHelper.serviceType();
            Service_Type_Version__c stv = Test_RestTestHelper.serviceTypeVersion(st.Id);
            Case c = Test_RestTestHelper.serviceRequest(stv.Id);
            Test_RestTestHelper.reallocateServiceType(q.Queue.Id, st.Id);
            c = [ SELECT Service_Type_Version__r.Service_Type__c,Incap311__Case_Comments__c,OwnerID FROM Case WHERE Id = :c.Id ];
            
            PageReference pageRef = Page.Base311_CaseReallocate;
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.StandardController(c);
            Base311_CaseReallocate ctrl = new Base311_CaseReallocate(sc);
            Base311_ReallocateComponentBase compbase = ctrl.getreallocateComponentCtrl();
            ctrl.setComponentController(compbase);
            
            Base311_ReallocateController Reallocatectrl = new Base311_ReallocateController();
            ctrl.Reallocatectrl = Reallocatectrl;
            ctrl.Reallocatectrl.queueID = q.Queue.Id;
            ctrl.Reallocatectrl.comment = 'test comment';
            //ctrl.c.OwnerId = ctrl.Reallocatectrl.queueID;
            
            ctrl.save();
                         
            c = [SELECT OwnerId, Case_Comments__c FROM Case WHERE Id = :c.Id];
              
            System.assert(c.Case_Comments__c.contains('test comment'));
            //System.assert(c.Ownerid,q.Queue.Id);
        }
    }
}