@isTest
public class Test_Base311_UpdateASTV {

    @isTest
    static void testSchedule() {
        
        Service_Type__c st1 = Test_RestTestHelper.serviceType();
        Service_Type__c st2 = Test_RestTestHelper.serviceType();
        
        Service_Type_Version__c stv1 = Test_RestTestHelper.serviceTypeVersion(st1.Id, '1', true, true);
        Service_Type_Version__c stv2 = Test_RestTestHelper.serviceTypeVersion(st1.Id, '2', true, true);
        Service_Type_Version__c stv3 = Test_RestTestHelper.serviceTypeVersion(st2.Id, '3', true, true);
        Service_Type_Version__c stv4 = Test_RestTestHelper.serviceTypeVersion(st2.Id, '4', true, true);
        
        Base311_UpdateActiveServiceTypeVersion uastv = new Base311_UpdateActiveServiceTypeVersion(1);        
        uastv.execute(null);
        
        
        List<AsyncApexJob> jobs = [SELECT Id FROM AsyncApexJob];
        
        System.assertEquals(jobs.size(), 2);
    }

    @isTest
    static void testBatch() {
        Base311_Service_ServiceType sst = new Base311_Service_ServiceType();
        
        Service_Type__c st1 = Test_RestTestHelper.serviceType();
        Service_Type__c st2 = Test_RestTestHelper.serviceType();
        
        Service_Type_Version__c stv1 = Test_RestTestHelper.serviceTypeVersion(st1.Id, '1', true, true);
        Service_Type_Version__c stv2 = Test_RestTestHelper.serviceTypeVersion(st1.Id, '2', true, true);
        Service_Type_Version__c stv3 = Test_RestTestHelper.serviceTypeVersion(st2.Id, '3', true, true);
        Service_Type_Version__c stv4 = Test_RestTestHelper.serviceTypeVersion(st2.Id, '4', true, true);
        
        stv1.Start_Date__c = System.today().addDays(-1);
        stv2.Start_Date__c = System.today().addDays(-1);
        stv3.Start_Date__c = System.today().addDays(-1);
        stv4.Start_Date__c = System.today().addDays(-1);
        update new List<Service_Type_Version__c>{ stv1, stv2, stv3, stv4 };
        
        Base311_UpdateActiveServiceTypeVersion uastv = new Base311_UpdateActiveServiceTypeVersion(sst.getBaseServiceTypes());        
        uastv.execute(null, sst.getBaseServiceTypes());
        
        st1 = [SELECT Active_Service_Type_Version__c FROM Service_Type__c WHERE Id = :st1.Id];
        st2 = [SELECT Active_Service_Type_Version__c FROM Service_Type__c WHERE Id = :st2.Id];
        
        System.assertEquals(st1.Active_Service_Type_Version__c, stv2.Id);
        System.assertEquals(st2.Active_Service_Type_Version__c, stv4.Id);
    }
    
}