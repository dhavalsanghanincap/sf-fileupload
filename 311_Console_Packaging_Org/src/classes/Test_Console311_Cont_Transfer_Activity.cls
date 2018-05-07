@isTest
public class Test_Console311_Cont_Transfer_Activity
{
    static testMethod void Test_Console311_Cont_Transfer_Activity()
    {
        Console311_Controller_Transfer_Activity controller = new Console311_Controller_Transfer_Activity();
        incap311__Service_Type__c st1 = incap311.Test_RestTestHelper.serviceType();
        incap311__Service_Type_Version__c stv1 = incap311.Test_RestTestHelper.serviceTypeVersion(st1.Id, '1', true, true);
        st1.incap311__Active_Service_Type_Version__c = stv1.Id;
        update st1;
        
        incap311__Service_Type__c st2 = incap311.Test_RestTestHelper.serviceType();
        incap311__Service_Type_Version__c stv2 = incap311.Test_RestTestHelper.serviceTypeVersion(st2.Id, '2', true, true);
        st2.incap311__Active_Service_Type_Version__c = stv2.Id;
        update st2;
        
        incap311__Service_Type__c st3 = incap311.Test_RestTestHelper.serviceType();
        
        incap311.Test_RestTestHelper.tsrt(st1.Id, st2.Id);
        incap311.Test_RestTestHelper.tsrt(st1.Id, st3.Id);
        
        incap311__Transfer_Service_Request_Type__c tsrt = new incap311__Transfer_Service_Request_Type__c (incap311__From_Service_Type__c = stv1.incap311__Service_Type__c, 
                                                                                                          incap311__For_Activity_Transfer__c = true, 
                                                                                                          incap311__To_Service_Type__c = stv1.incap311__Service_Type__c);
        insert tsrt;
        
         tsrt = new incap311__Transfer_Service_Request_Type__c (incap311__From_Service_Type__c = st1.Id, 
                                                                                                          incap311__For_Activity_Transfer__c = true, 
                                                                                                          incap311__To_Service_Type__c = st3.Id);
        insert tsrt;
    
    
        controller.serviceTypeId = stv1.incap311__Service_Type__c;
        List<SelectOption> options = controller.getSRTypes();
        System.assertEquals(1, options.size());
    }
}