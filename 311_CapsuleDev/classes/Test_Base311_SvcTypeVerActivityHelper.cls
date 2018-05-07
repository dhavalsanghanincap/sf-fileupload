@isTest
public with sharing class Test_Base311_SvcTypeVerActivityHelper {
    
    static testMethod void testOrderUniqueInsert() {
        // create test data (1 service type version, 3 activities, 2 service type version activities)
        Service_Type__c st = Test_RestTestHelper.serviceType();
        
        Service_Type_Version__c stv = Test_RestTestHelper.serviceTypeVersion(st.Id);
        stv.Version_Number__c = 1;
        update stv;
        
        Activity__c act1 = new Activity__c(Activity_Code__c='ACT1');
        insert act1;
        
        Service_Type_Version_Activity__c stva1 = new Service_Type_Version_Activity__c(Service_Type_Version__c=stv.Id, Activity__c=act1.Id, Order__c=1);
        insert stva1;
        
        Activity__c act2 = new Activity__c(Activity_Code__c='ACT2');
        insert act2;
        
        Service_Type_Version_Activity__c stva2 = new Service_Type_Version_Activity__c(Service_Type_Version__c=stv.Id, Activity__c=act2.Id, Order__c=2);
        insert stva2;
        
        Activity__c act3 = new Activity__c(Activity_Code__c='ACT3');
        insert act3;
        
        Test.startTest();
        
        try {
        	Service_Type_Version_Activity__c test1 = new Service_Type_Version_Activity__c(Service_Type_Version__c=stv.Id, Activity__c=act3.Id, Order__c=1);
        	insert test1;
        }
        catch (Exception e) {
        	System.assert(e.getMessage().contains('Please apply a unique Order'));
        }
        
        System.debug('@@@@ test service type version activity inserted.');
        
        Test.stopTest();
    }
    
    static testMethod void testOrderUniqueUpdate() {
        // create test data (1 service type version, 3 activities, 2 service type version activities)
        Service_Type__c st = Test_RestTestHelper.serviceType();
        
        Service_Type_Version__c stv = Test_RestTestHelper.serviceTypeVersion(st.Id);
        stv.Version_Number__c = 1;
        update stv;
        
        Activity__c act1 = new Activity__c(Activity_Code__c='ACT1');
        insert act1;
        
        Service_Type_Version_Activity__c stva1 = new Service_Type_Version_Activity__c(Service_Type_Version__c=stv.Id, Activity__c=act1.Id, Order__c=1);
        insert stva1;
        
        Activity__c act2 = new Activity__c(Activity_Code__c='ACT2');
        insert act2;
        
        Service_Type_Version_Activity__c stva2 = new Service_Type_Version_Activity__c(Service_Type_Version__c=stv.Id, Activity__c=act2.Id, Order__c=2);
        insert stva2;
        
        Test.startTest();
        
        try {
        	Service_Type_Version_Activity__c test1 = [SELECT Id, Order__c FROM Service_Type_Version_Activity__c WHERE Id = :stva2.Id];
        	test1.Order__c = 1;
        	update test1;
        }
        catch (Exception e) {
        	System.assert(e.getMessage().contains('Please apply a unique Order'));
        }
        
        System.debug('@@@@ test service type version activity updated.');
        
        Test.stopTest();
    }
}