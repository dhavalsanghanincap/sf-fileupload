@isTest
public class Test_Base311_Service_ServiceType {

    @isTest
    static void testgetActiveServiceType() {
     Service_Type__c st = Test_RestTestHelper.serviceType();
     st = [SELECT Service_Type_Code__c FROM Service_Type__c WHERE Id = :st.Id];
        
    
     Service_Type_Version__c stv1 = Test_RestTestHelper.serviceTypeVersion(st.Id, 'test1', true, true);
     Service_Type_Version__c stv3 = Test_RestTestHelper.serviceTypeVersion(st.Id, 'test3', true, true);
    
     st.Active_Service_Type_Version__c = stv3.Id;
     update st;
    
     Base311_Service_ServiceType rsst = new Base311_Service_ServiceType();
    
     Service_Type_Version__c result = rsst.getActiveServiceType(st.Service_Type_Code__c, true);
    
     System.assert(result != null); 
     System.assertEquals(result.Id, stv3.Id);
    }

    @isTest
    static void testGetQuestionByVersionCodeDNE() { 
        Base311_Service_ServiceType rsst = new Base311_Service_ServiceType();
        Service_Type_Version__c result = rsst.getServiceType('TEST1');
        System.assertEquals(result, null);
    }
    
    @isTest
    static void testGetQuestionByVersionCode() {
        Base311_Service_ServiceType rsst = new Base311_Service_ServiceType();
        
        Service_Type_Version__c stv = Test_RestTestHelper.sericeTypeVersionAndVersion('TEST1');
        
        Question__c q = Test_RestTestHelper.question();
        Service_Type_Version_Question__c stvq = Test_RestTestHelper.serviceTypeVersionQuestion(q.Id, stv.Id);

        Service_Type_Version__c result = rsst.getServiceType(stv.Name, true);
    
        System.assertEquals(result.Name, stv.Name);
    }
    
    @isTest 
    static void testGetActiveServiceTypeNone(){
        Service_Type__c st = Test_RestTestHelper.serviceType();
        
        Service_Type_Version__c stv1 = Test_RestTestHelper.serviceTypeVersion(st.Id, 'test1', true);
        Service_Type_Version__c stv2 = Test_RestTestHelper.serviceTypeVersion(st.Id, 'test2', true);
        Service_Type_Version__c stv3 = Test_RestTestHelper.serviceTypeVersion(st.Id, 'test3', false);
    
        Question__c q = Test_RestTestHelper.question('Hello', 'Text', 'My hint');
        
        Service_Type_Version_Question__c stvq = Test_RestTestHelper.serviceTypeVersionQuestion(q.Id, stv1.Id, 1);
        Service_Type_Version_Question__c stvq2 = Test_RestTestHelper.serviceTypeVersionQuestion(q.Id, stv1.Id, 2);
        
        Base311_Service_ServiceType rsst = new Base311_Service_ServiceType();
        Service_Type_Version__c result = rsst.getServiceType('test4');
        
        System.assertEquals(result, null);
        
    }
    
    @isTest 
    static void testGetPrivateActiveServiceType(){
        Service_Type__c st = Test_RestTestHelper.serviceType();
        
        Service_Type_Version__c stv1 = Test_RestTestHelper.serviceTypeVersion(st.Id, 'test1', null, true);
        Service_Type_Version__c stv2 = Test_RestTestHelper.serviceTypeVersion(st.Id, 'test2', null, true);
        Service_Type_Version__c stv3 = Test_RestTestHelper.serviceTypeVersion(st.Id, 'test3', null, false);
    
        Question__c q = Test_RestTestHelper.question('Hello', 'Text', 'My hint');
        
        Service_Type_Version_Question__c stvq = Test_RestTestHelper.serviceTypeVersionQuestion(q.Id, stv1.Id, 1);
        Service_Type_Version_Question__c stvq2 = Test_RestTestHelper.serviceTypeVersionQuestion(q.Id, stv1.Id, 2);
          
        Base311_Service_ServiceType rsst = new Base311_Service_ServiceType();
        Service_Type_Version__c result = rsst.getServiceType(stv1.Name, true);
         
        System.assertEquals(result.Name, stv1.Name);
        System.assertEquals(result.Service_Type_Version_Questions__r.size(), 2);
        System.assertEquals(result.Service_Type_Version_Questions__r[0].Order__c, 1);
        System.assertEquals(result.Service_Type_Version_Questions__r[1].Order__c, 2);
    }
    
    @isTest 
    static void testGetServiceType(){
        Service_Type__c st = Test_RestTestHelper.serviceType();
        
        Service_Type_Version__c stv1 = Test_RestTestHelper.serviceTypeVersion(st.Id, 'test1', true, true);
        Service_Type_Version__c stv2 = Test_RestTestHelper.serviceTypeVersion(st.Id, 'test2', null, true);
        Service_Type_Version__c stv3 = Test_RestTestHelper.serviceTypeVersion(st.Id, 'test3', null, false);
        
        Question__c q = Test_RestTestHelper.question('Hello', 'Text', 'My hint');
        
        Service_Type_Version_Question__c stvq = Test_RestTestHelper.serviceTypeVersionQuestion(q.Id, stv1.Id, 1, true);
        Service_Type_Version_Question__c stvq2 = Test_RestTestHelper.serviceTypeVersionQuestion(q.Id, stv1.Id, 2, true);
        
        System.debug(stvq);
        System.debug(stvq2);
        
        Base311_Service_ServiceType rsst = new Base311_Service_ServiceType();
        Service_Type_Version__c result = rsst.getServiceType(stv1.Name);
         
        System.debug(result);
        
        System.assertEquals(result.Name, stv1.Name);
        System.assertEquals(result.Service_Type_Version_Questions__r.size(), 2);
        System.assertEquals(result.Service_Type_Version_Questions__r[0].Order__c, 1);
        System.assertEquals(result.Service_Type_Version_Questions__r[1].Order__c, 2);
    }
    
    @isTest
    static void testGetActiveServiceTypes() {
        Service_Type__c st = Test_RestTestHelper.serviceType();
        Service_Type__c st2 = Test_RestTestHelper.serviceType();
        
        Service_Type_Version__c stv1 = Test_RestTestHelper.serviceTypeVersion(st.Id, 'test1', true, true);
        Service_Type_Version__c stv2 = Test_RestTestHelper.serviceTypeVersion(st2.Id, 'test2', true, true);
        Service_Type_Version__c stv3 = Test_RestTestHelper.serviceTypeVersion(st.Id, 'test3', null, false);
        
        st.Active_Service_Type_Version__c = stv1.Id;
        update st;
        st2.Active_Service_Type_Version__c = stv2.Id;
        update st2;
        
        Base311_Service_ServiceType rsst = new Base311_Service_ServiceType();
        
        List<Service_Type_Version__c> result = rsst.getActiveServiceTypes();
        
        System.debug(result);

        Map<String, Service_Type_Version__c> mappedRes = new Map<String, Service_Type_Version__c>();
        
        for(Service_Type_Version__c res : result) {
            mappedRes.put(res.Id, res);
        }
        
        System.assertEquals(result.size(), 2);
        System.assert(mappedRes.containsKey(stv1.Id));
        System.assert(mappedRes.containsKey(stv2.Id));
    }
    
}