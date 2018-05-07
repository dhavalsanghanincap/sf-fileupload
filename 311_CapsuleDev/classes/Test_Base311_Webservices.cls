@isTest
public class Test_Base311_Webservices {

    @isTest
    static void testMarkSTVAsActiveDraft() {
        Service_Type_Version__c stv = Test_RestTestHelper.sericeTypeVersionAndVersion();
        String resp = Base311_Webservices.markSTVAsActive(stv.Id);
        System.assertEquals(resp, 'Only Service Type Versions that are not marked as draft, and have valid Start / Stop date ranges can be activated.');
    }

    @isTest
    static void testMarkSTVAsActiveCurrent() {
        Service_Type_Version__c stv = Test_RestTestHelper.sericeTypeVersionAndVersion();
        stv.Is_Draft__c = false;
        update stv;
        stv.Service_Type__r.Active_Service_Type_Version__c = stv.Id;
        update stv.Service_Type__r;
        String resp = Base311_Webservices.markSTVAsActive(stv.Id);
        System.assertEquals(resp, 'Cannot make the current active version active');
    }

    @isTest
    static void testMarkSTVAsActive() {
        Test.startTest();
        Service_Type_Version__c stv = Test_RestTestHelper.sericeTypeVersionAndVersion();
        stv.Is_Draft__c = false;
        update stv;
        String resp = Base311_Webservices.markSTVAsActive(stv.Id);
        System.assertEquals(resp, 'Version has been marked as active. Associated Service Activties are scheduled for updates');
        List<CronTrigger> job =  [SELECT Id, CronExpression FROM CronTrigger];
        System.assertEquals(job.size(), 1);
        Test.stopTest();
    }
    
    @isTest
    static void testCloneServiceTypeVersion() {
        Service_Type_Version__c stv = Test_RestTestHelper.sericeTypeVersionAndVersion();
        Activity__c a = Test_RestTestHelper.activity();
        Question__c q = Test_RestTestHelper.question();
        Service_Type_Version_Question__c stvq1 = Test_RestTestHelper.serviceTypeVersionQuestion(q.Id, stv.id);
        Service_Type_Version_Question__c stvq2 = Test_RestTestHelper.serviceTypeVersionQuestion(q.Id, stv.id);
        Service_Type_Version_Activity__c stva1 = Test_RestTestHelper.serviceTypeVersionActivity(a.Id, stv.id);
        String res = Base311_Webservices.cloneServiceTypeVersion(stv.Id);
        List<Service_Type_Version__c> stvs = [
            SELECT Id,
                ( SELECT Id FROM Service_Type_Version_Questions__r ), 
                ( SELECT Id FROM Service_Type_Version_Activities__r ) 
            FROM 
            	Service_Type_Version__c 
            WHERE 
            	Id != :stv.Id
        ];
        
        System.assertEquals('/' + stvs[0].Id, res);
        System.assertEquals(2, stvs[0].Service_Type_Version_Questions__r.size());
        System.assertEquals(1, stvs[0].Service_Type_Version_Activities__r.size());
    }
    
}