@isTest
private class Test_Base311_ServiceTypeVersionHelper {
    
    static testMethod void testUniqueVersionNumberInsert() {
        // create test data (1 service type, 1 version)
        Service_Type__c st = Test_RestTestHelper.serviceType();
        
        Service_Type_Version__c stv = Test_RestTestHelper.serviceTypeVersion(st.Id);
        stv.Version_Number__c = 1;
        update stv;
        
        Test.startTest();
        
        try {
        	Service_Type_Version__c test1 = new Service_Type_Version__c(Service_Type__c=st.Id, Version_Name__c='ver1', Version_Code__c='ver1', Version_Number__c=1);
        	insert test1;
        }
        catch (Exception e) {
        	System.assert(e.getMessage().contains('Please apply a unique Version Number'));
        }
        
        System.debug('@@@@ test service type version inserted.');
        
        Test.stopTest();
    }
    
    static testMethod void testUniqueVersionNumberUpdate() {
        // create test data (1 service type, 1 version)
        Service_Type__c st = Test_RestTestHelper.serviceType();
        
        Service_Type_Version__c stv = Test_RestTestHelper.serviceTypeVersion(st.Id);
        stv.Version_Number__c = 1;
        update stv;
        
        Test.startTest();
        try {
	        Service_Type_Version__c test1 = [SELECT Id, Version_Number__c FROM Service_Type_Version__c WHERE Id = :stv.Id];
	        test1.Version_Number__c = 1;
	        update test1;
        }
        catch (Exception e) {
        	System.assert(e.getMessage().contains('Please apply a unique Version Number'));
        }
        
        System.debug('@@@@ test service type version updated.');
        
        Test.stopTest();
    }
    
    
    static testMethod void testUniqueServiceNameInsert() {
        // create test data (1 service type, 1 version)
        Service_Type__c st1 = Test_RestTestHelper.serviceType();
        
        Service_Type_Version__c stv1 = Test_RestTestHelper.serviceTypeVersion(st1.Id);
        stv1.Service_Name__c = 'TEST';
        stv1.Is_Draft__c = false;
        update stv1;
        
        Service_Type__c qSvcType = [SELECT Id, Active_Service_Type_Version__c FROM Service_Type__c WHERE Id = :st1.Id];
        qSvcType.Active_Service_Type_Version__c = stv1.Id;
        update qSvcType;
        
        Service_Type__c st2 = Test_RestTestHelper.serviceType();
        
        Service_Type_Version__c stv2 = Test_RestTestHelper.serviceTypeVersion(st2.Id);
        
        Test.startTest();
        
        try {
        	Service_Type_Version__c test1 = new Service_Type_Version__c(Service_Type__c=st2.Id, Version_Name__c='ver2', Version_Code__c='ver2', Version_Number__c=2, Service_Name__c='TEST');
        	insert test1;
        }
        catch (Exception e) {
        	System.assert(e.getMessage().contains('Please apply a unique Service Name'));
        }
        
        System.debug('@@@@ test service type version inserted.');
        
        Test.stopTest();
    }
    
    static testMethod void testUniqueServiceNameUpdate() {
        // create test data (1 service type, 1 version)
        Service_Type__c st1 = Test_RestTestHelper.serviceType();
        
        Service_Type_Version__c stv1 = Test_RestTestHelper.serviceTypeVersion(st1.Id);
        stv1.Service_Name__c = 'TEST1';
        update stv1;
        
        Service_Type__c st2 = Test_RestTestHelper.serviceType();
        
        Service_Type_Version__c stv2 = Test_RestTestHelper.serviceTypeVersion(st2.Id);
        stv2.Service_Name__c = 'TEST2';
        update stv2;
        
        Test.startTest();
        try {
	        Service_Type_Version__c test1 = [SELECT Id, Version_Number__c FROM Service_Type_Version__c WHERE Id = :stv2.Id];
	        test1.Service_Name__c = 'TEST1';
	        update test1;
        }
        catch (Exception e) {
        	System.assert(e.getMessage().contains('Please apply a unique Service Name'));
        }
        
        System.debug('@@@@ test service type version updated.');
        
        Test.stopTest();
    }
}