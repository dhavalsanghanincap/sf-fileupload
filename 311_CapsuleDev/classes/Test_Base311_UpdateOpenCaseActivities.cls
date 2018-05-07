@isTest
public class Test_Base311_UpdateOpenCaseActivities {

    /**
        Scheduling uses a fixed time for tests.
        Therefor we can gurantee the test will have 
        the values below
    **/

    @isTest
    static void testScheduleSingle() {
        Test.startTest();
        Service_Type__c st = Test_RestTestHelper.serviceType();
        Base311_UpdateOpenCaseActivities.schedule(st);
        
        List<CronTrigger> job =  [SELECT Id, CronExpression FROM CronTrigger];
        
        System.assertEquals(job.size(), 1);
        System.assertEquals(job[0].CronExpression, '0 0 1 * * ?');
        Test.stopTest();
    }

    @isTest
    static void testScheduleMultiple() {
        Test.startTest();
        Service_Type__c st = Test_RestTestHelper.serviceType();
        Base311_UpdateOpenCaseActivities.schedule(new List<Service_Type__c>{ st }, true);
        
        List<CronTrigger> job =  [SELECT Id, CronExpression FROM CronTrigger];
        
        System.assertEquals(job.size(), 1);
        System.assertEquals(job[0].CronExpression, '1 6 1 * * ?');
        Test.stopTest();
    }
    
    @isTest
    static void testRunSchedule() {
        Service_Type__c st1 = Test_RestTestHelper.serviceType();
        Service_Type__c st2 = Test_RestTestHelper.serviceType();
        Service_Type_Version__c stv1 = Test_RestTestHelper.serviceTypeVersion(st1.Id);
        Service_Type_Version__c stv2 = Test_RestTestHelper.serviceTypeVersion(st1.Id);
        Service_Type_Version__c stv3 = Test_RestTestHelper.serviceTypeVersion(st2.Id);
        Service_Type_Version__c stv4 = Test_RestTestHelper.serviceTypeVersion(st2.Id);
        
        stv1.Version_Number__c = 10;
        stv2.Version_Number__c = 20;
        stv3.Version_Number__c = 10;
        stv4.Version_Number__c = 20;
        update new List<Service_Type_Version__c>{ stv1, stv2, stv3, stv4 };
        
        Case c1 = Test_RestTestHelper.serviceRequest(stv1.Id, System.now(), 'Not Started');
        Case c2 = Test_RestTestHelper.serviceRequest(stv3.Id, System.now(), 'Not Started');
        
        Base311_UpdateOpenCaseActivities uoca = new Base311_UpdateOpenCaseActivities(new List<Service_Type__c>{ st1, st2 }, 1);
        uoca.execute(null);
        
        
        List<AsyncApexJob> jobs = [SELECT Id FROM AsyncApexJob];
        
       // System.assertEquals(jobs.size(), 2);
    }
    
    @isTest
    static void testRunBatch() {
        Base311_Service_Request sr = new Base311_Service_Request();
        
        Service_Type__c st1 = Test_RestTestHelper.serviceType();
        Service_Type__c st2 = Test_RestTestHelper.serviceType();
        
        Activity__c a = Test_RestTestHelper.activity();
        
        Service_Type_Version__c stv1 = Test_RestTestHelper.serviceTypeVersion(st1.Id);
        Service_Type_Version__c stv2 = Test_RestTestHelper.serviceTypeVersion(st1.Id);
        Service_Type_Version__c stv3 = Test_RestTestHelper.serviceTypeVersion(st2.Id);
        Service_Type_Version__c stv4 = Test_RestTestHelper.serviceTypeVersion(st2.Id);
        
        System.assertNotEquals(st1.Id, st2.Id);
        
        Service_Type_Version_Activity__c stva1 = Test_restTestHelper.serviceTypeVersionActivity(a.Id, stv1.Id);
        Service_Type_Version_Activity__c stva2 = Test_restTestHelper.serviceTypeVersionActivity(a.Id, stv2.Id);
        Service_Type_Version_Activity__c stva3 = Test_restTestHelper.serviceTypeVersionActivity(a.Id, stv3.Id);
        Service_Type_Version_Activity__c stva4 = Test_restTestHelper.serviceTypeVersionActivity(a.Id, stv4.Id);
        
        stv1.Version_Number__c = 10;
        stv1.Is_Draft__c = false;
        stv2.Version_Number__c = 20;
        stv2.Is_Draft__c = false;
        stv3.Version_Number__c = 10;
        stv3.Is_Draft__c = false;
        stv4.Version_Number__c = 20;
        stv4.Is_Draft__c = false;
        update new List<Service_Type_Version__c>{ stv1, stv2, stv3, stv4 };

        st1.Active_Service_Type_Version__c = stv2.Id;
        st2.Active_Service_Type_Version__c = stv4.Id;
        update new List<Service_Type__c>{ st1, st2 };
        
        Case c1 = Test_RestTestHelper.serviceRequest(stv1.Id, System.now(), 'New');
        Case c2 = Test_RestTestHelper.serviceRequest(stv3.Id, System.now(), 'New');
        
        Service_Activity__c sa1 = Test_RestTestHelper.serviceActivity(stva1.Id, c1.Id);
        Service_Activity__c sa2 = Test_RestTestHelper.serviceActivity(stva3.Id, c2.Id);
        
        Base311_UpdateOpenCaseActivities uoca = new Base311_UpdateOpenCaseActivities(sr.getOpenCasesByServiceType(new Set<Id>{ st1.Id, st2.Id }));
        uoca.execute(null, sr.getOpenCasesByServiceType(new Set<Id>{ st1.Id, st2.Id }));
        
        c1 = [SELECT Id, Service_Type_Version__c, (SELECT Id, Status__c FROM Service_Activities__r) FROM Case WHERE Id = :c1.Id];
        c2 = [SELECT Id, Service_Type_Version__c, (SELECT Id, Status__c FROM Service_Activities__r) FROM Case WHERE Id = :c2.Id];
          
        List<Service_Activity__c> retiredSAs = [
            SELECT Id 
            FROM Service_Activity__c 
            WHERE Status__c = 'Retired'
        ];
        
        System.assertEquals(retiredSAs.size(), 2);
        
        System.assertEquals(c1.Service_Type_Version__c, stv2.Id);
        System.assertEquals(c2.Service_Type_Version__c, stv4.Id);
        
        System.assertEquals(c1.Service_Activities__r.size(), 2);
        System.assertEquals(c2.Service_Activities__r.size(), 2);
    }
}