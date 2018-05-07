@isTest
public class Test_Base311_Transfer_Case {
    @isTest
    static void testTransferCase() {
        Base311_Service_Request ssr = new Base311_Service_Request();
        Activity__c a = Test_RestTestHelper.activity();
        Question__c q = Test_RestTestHelper.question();
        Service_Type__c st = Test_RestTestHelper.serviceType();
        Service_Type_Version__c stv = Test_RestTestHelper.serviceTypeVersion(st.Id, '1', true, true);
        stv.Service_Name__c = 'tes123';
        update stv;
        Service_Type_Version_Activity__c stva = Test_RestTestHelper.serviceTypeVersionActivity(a.Id, stv.Id);
        Service_Type_Version_Question__c stvq = Test_RestTestHelper.serviceTypeVersionQuestion(q.Id, stv.Id);
        Case sr = Test_RestTestHelper.serviceRequest(stv.Id);
        Service_Question__c sq = Test_RestTestHelper.serviceQuestion(sr.Id, stvq.Id);
        Service_Activity__c sa = Test_RestTestHelper.serviceActivity(stva.Id, sr.Id);
        
        sr.Address_ID__c = '10';
        sr.Service_Type_Version__c = stv.Id;
        update sr;
        
        sr = ssr.getServiceRequest(sr.Service_Request_Number__c);
        
        System.debug(sr.Service_Type_Version__c);
        
        Case oldSR = sr.clone(true, true);
        
        Case updated = Base311_Transfer_Case.transferCase(sr, oldSR, new Map<String, Object>{ q.Flex_Question_Code__c => 'ABC' });
        
        System.assertEquals(updated.Service_Questions__r.size(), 1);
        System.assert(updated.Service_Questions__r.get(0).id != stvq.Id);
        System.assertEquals(updated.Service_Activities__r.size(), 1);
        System.assert(updated.Service_Activities__r.get(0).id != stva.Id);
        System.assertEquals(updated.Subject, 'tes123');
    }
    
    @isTest
    static void testGetActiveServiceTypes() {
        Service_Type__c st1 = Test_RestTestHelper.serviceType();
        Service_Type_Version__c stv1 = Test_RestTestHelper.serviceTypeVersion(st1.Id, '1', true, true);
        st1.Active_Service_Type_Version__c = stv1.Id;
        update st1;
        
        Service_Type__c st2 = Test_RestTestHelper.serviceType();
        Service_Type_Version__c stv2 = Test_RestTestHelper.serviceTypeVersion(st2.Id, '2', true, true);
        st2.Active_Service_Type_Version__c = stv2.Id;
        update st2;
        
        Service_Type__c st3 = Test_RestTestHelper.serviceType();
        
        Test_RestTestHelper.tsrt(st1.Id, st2.Id);
        Test_RestTestHelper.tsrt(st1.Id, st3.Id);
        
        List<Service_Type_Version__c> versions = Base311_Transfer_Case.getActiveServiceTypes(stv1.Service_Type__c);
        System.assertEquals(versions.size(), 1);
    }
    
}