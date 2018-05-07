@isTest
public class Test_Base311_Helper {
    @isTest
    static void testExceptionMessage() {
        RestRequest req = new RestRequest();
        RestContext.request = req;
       	req.requestURI = 'test.xml';
        
        Base311_Helper.ExceptionMessage em = new Base311_Helper.ExceptionMessage(5, new List<String>{ 'hello' });
        
        String res = em.serialize();
        System.assertEquals(res, '<errors><error><code>5</code><description>hello</description></error></errors>');
    }
    
    @isTest
    static void testGetParamDefault() {
        RestRequest req = new RestRequest();
        RestContext.request = req;
        
        String res = Base311_Helper.getParam('abc', '1');
        System.assertEquals('1', res);
    }
    @isTest
    static void testGetDatetimeParam() {
        RestRequest req = new RestRequest();
        
        RestContext.request = req;
        req.addParameter('abc', Base311_Helper.formatDate(Datetime.newInstance(2015, 1, 1)));
        
        Datetime dt = Base311_Helper.getDatetimeParam('abc');
        System.assertEquals(2015, dt.year());
        System.assertEquals(1, dt.month());
        System.assertEquals(1, dt.day());
    }
    
    @isTest
    static void testGetCSLParam() {
        RestRequest req = new RestRequest();
        
        RestContext.request = req;
        req.addParameter('abc', '1,2,3');
        
        List<String> items = Base311_Helper.getCSLParam('abc');
        System.assertEquals('1', items.get(0));
        System.assertEquals('2', items.get(1));
        System.assertEquals('3', items.get(2));
    }
    
    @isTest
    static void testParseDate() {
        Datetime dt = Datetime.newInstanceGmt(2000, 1, 1, 1, 1, 1);
        Datetime res = Base311_Helper.parseDate('2000-01-01T01:01:01.000Z');
        System.assertEquals(dt, res);
    }
    
    @isTest
    static void testGetDoubleBodyParam() {
        RestRequest req = new RestRequest();
        RestContext.request = req;
        
        RestContext.request.requestBody = Blob.valueOf('{' +
            '"a": 1' +
        '}');
        
        System.assertEquals(1, Base311_Helper.getDoubleBodyParam('a'));
    }
    @isTest
    static void testGetStringBodyParam() {
        RestRequest req = new RestRequest();
        RestContext.request = req;
        
        RestContext.request.requestBody = Blob.valueOf('{' +
            '"a": "banana"' +
        '}');
        
        System.assertEquals('banana', Base311_Helper.getStringBodyParam('a'));
    }
    
    @isTest
    static void testGetMapBodyParam() {
        RestRequest req = new RestRequest();
        RestContext.request = req;
        
        RestContext.request.requestBody = Blob.valueOf('{' +
        	'"a": { "a" : 1 }' +
        '}');
        
        System.assertEquals(1, Base311_Helper.getMapBodyParam('a').get('a'));
    }
    @isTest
    static void testGetListBodyParam() {
        RestRequest req = new RestRequest();
        RestContext.request = req;
        
        RestContext.request.requestBody = Blob.valueOf('{' +
            '"a": ["a", "b"]' +
        '}');
        
        System.assertEquals(2, Base311_Helper.getListBodyParam('a').size());
    }
    
    @isTest
    static void testObjListContainsFalse() {
        List<Case> items = new List<Case>{ new Case(Status='New'), new Case(Status='Old') };
        Boolean res = !Base311_Helper.listContains(items, 'Status', 'a');
        System.assert(res);
    }
    
    @isTest
    static void testObjListContainsTrue() {
        List<Case> items = new List<Case>{ new Case(Status='New'), new Case(Status='Old') };
        Boolean res = Base311_Helper.listContains(items, 'Status', 'New');
        System.assert(res);
    }
    
    @isTest
    static void testListContainsFalse() {
        List<String> items = new List<String>{ 'a', 'b' };
        Boolean res = !Base311_Helper.listContains(items, 'c');
        System.assert(res);
    }
    
    @isTest
    static void testListContainsTrue() {
        List<String> items = new List<String>{ 'a', 'b' };
        Boolean res = Base311_Helper.listContains(items, 'a');
        System.assert(res);
    }
    
    @isTest
    static void testFormatDate() {
        Datetime dt = Datetime.newInstanceGmt(2000, 1, 1, 1, 1, 1);
        String res = Base311_Helper.formatDate(dt);
        System.assertEquals('2000-01-01T01:01:01.000Z', res);
    }
    
    @isTest
    static void testGetParam() {
        RestRequest req = new RestRequest();
        RestContext.request = req;
        System.assertEquals(null, Base311_Helper.getParam('abc'));
    }
    
    @isTest
    static void testKeyBy() {
        List<Case> cases = new List<Case>{ new Case(Status = 'New') };
            
        Map<String, Object> result = Base311_Helper.keyBy('Status', cases);
        
        System.assert(result.containsKey('New'));
    }
    
    @isTest
    static void testUrlParams(){
        String testUrl = '/case/:caseId/test/:testId/empty/:emptyId/extra';
        
        Map<String, String> result = Base311_Helper.urlParams('/case/123/test/456/empty', testUrl);
        
        System.assertEquals(result.get('caseId'), '123');
        System.assertEquals(result.get('testId'), '456');
        System.assert(!result.containsKey('emptyId'));
    }
    
    @isTest
    static void testIsRequestXMLFalseUrl() {
        // it should take the URL as precedence
        RestRequest req = new RestRequest();
        req.requestUri = '/case.json';
        req.addHeader('Accept', 'text/xml');
        RestContext.request = req;
        System.assert(!Base311_Helper.isRequestXML());
    }
    
    @isTest
    static void testIsRequestXMLTrueUrl() {
        // it should take the URL as precedence
        RestRequest req = new RestRequest();
        req.requestUri = '/case.xml';
        req.addHeader('Accepts', '');
        RestContext.request = req;
        System.assert(Base311_Helper.isRequestXML());
    }
    
    @isTest
    static void testIsRequestXMLFalseHeader() {
        // it should take the URL as precedence
        RestRequest req = new RestRequest();
        req.requestUri = '/case';
        req.addHeader('Accept', 'application/json');
        RestContext.request = req;
        System.assert(!Base311_Helper.isRequestXML());
    }
    
    @isTest
    static void testIsRequestXMLTrueHeader() {
        // it should take the URL as precedence
        RestRequest req = new RestRequest();
        req.requestUri = '/case';
        req.addHeader('Accept', 'text/xml');
        RestContext.request = req;
        System.assert(Base311_Helper.isRequestXML());
    }
    
    @isTest
    static void testIsRequestXMLTrueDefault() {
        // it should take the URL as precedence
        RestRequest req = new RestRequest();
        req.requestUri = '/case';
        req.addHeader('Accept', '');
        RestContext.request = req;
        System.assert(Base311_Helper.isRequestXML());
    }
    
    @isTest
    static void testGetContentTypeXML() {
        RestRequest req = new RestRequest();
        req.requestUri = '/case.xml';
        RestContext.request = req;
        String res = Base311_Helper.getContentType();
        System.assertEquals(res, 'text/xml');
    }
    
    @isTest
    static void testGetContentTypeJSON() {
        RestRequest req = new RestRequest();
        req.requestUri = '/case.json';
        RestContext.request = req;
        String res = Base311_Helper.getContentType();
        System.assertEquals(res, 'application/json');
    }
    
    @isTest
    static void testSetResponseBody() {
        RestResponse resp = new RestResponse();
        RestRequest req = new RestRequest();
        req.requestURI = 'case.xml';
        RestContext.response = resp;
        RestContext.request = req;
        Base311_Helper.setResponse('test');
        System.assertEquals(resp.responseBody.toString(), 'test');
        System.assertEquals(resp.statusCode, 200);
    }
    
    @isTest
    static void testSetResponseBodyStatusCode() {
        RestResponse resp = new RestResponse();
        RestRequest req = new RestRequest();
        req.requestURI = 'case.xml';
        RestContext.response = resp;
        RestContext.request = req;
        Base311_Helper.setResponse('test', 500);
        System.assertEquals(resp.responseBody.toString(), 'test');
        System.assertEquals(resp.statusCode, 500);
    }
    
    // test getCompleteCase
    @isTest
    static void testGetCompleteCase() {
    	//Base311_Service_Request ssr = new Base311_Service_Request();
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
        
        sr.Service_Type_Version__c = stv.Id;
        update sr;
        
        Case csr = Base311_Helper.getCompleteCase(sr);
        System.Assert(csr != null);
    }
    
    // test getCompleteServiceTypeVersion
    @isTest
    static void testGetCompleteServiceTypeVersion() {
        Activity__c a = Test_RestTestHelper.activity();
        Question__c q = Test_RestTestHelper.question();
        Service_Type__c st = Test_RestTestHelper.serviceType();
        Service_Type_Version__c stv = Test_RestTestHelper.serviceTypeVersion(st.Id, '1', true, true);
        stv.Service_Name__c = 'tes123';
        update stv;
        
        Service_Type_Version_Activity__c stva = Test_RestTestHelper.serviceTypeVersionActivity(a.Id, stv.Id);
        Service_Type_Version_Question__c stvq = Test_RestTestHelper.serviceTypeVersionQuestion(q.Id, stv.Id);
        
        Service_Type_Version__c cstv = Base311_Helper.getCompleteServiceTypeVersion(stv.Id);
        System.Assert(cstv != null);
        if (cstv != null) {
        	List<Service_Type_Version_Question__c> qs = cstv.Service_Type_Version_Questions__r;
        	List<Service_Type_Version_Activity__c> acts = cstv.Service_Type_Version_Activities__r;
        	
        	System.Assert(qs.size() > 0);
        	System.Assert(acts.size() > 0);
        }
    }
    
    @isTest
    static void testHandleException() {
        Base311_Exceptions.SecurityException e = new Base311_Exceptions.SecurityException('123');
        RestResponse resp = new RestResponse();
        RestRequest req = new RestRequest();
        req.requestURI = 'case.json';
        RestContext.response = resp;
        RestContext.request = req;
        Base311_Helper.handleException(e);
        System.assertEquals(resp.responseBody.toString(), '[{"description":"123","code":1}]');
        System.assertEquals(resp.statusCode, 401);
    }
    
    @isTest
    static void testHandleException3() {
        Base311_Exceptions.UnsupportedException e = new Base311_Exceptions.UnsupportedException('123');
        RestResponse resp = new RestResponse();
        RestRequest req = new RestRequest();
        req.requestURI = 'case.json';
        RestContext.response = resp;
        RestContext.request = req;
        Base311_Helper.handleException(e);
        System.assertEquals(resp.responseBody.toString(), '[{"description":"123","code":3}]');
        System.assertEquals(resp.statusCode, 400);
    }
    
    @isTest
    static void testHandleException4() {
        Base311_Exceptions.ServerException e = new Base311_Exceptions.ServerException('123');
        RestResponse resp = new RestResponse();
        RestRequest req = new RestRequest();
        req.requestURI = 'case.json';
        RestContext.response = resp;
        RestContext.request = req;
        Base311_Helper.handleException(e);
        System.assertEquals(resp.responseBody.toString(), '[{"description":"123","code":4}]');
        System.assertEquals(resp.statusCode, 500);
    }
}