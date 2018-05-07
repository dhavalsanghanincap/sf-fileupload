@isTest
public class Ext311_ServiceTypeTransferConfig_Test {

    @isTest
    static void testGetSelectedTypes() {
        Incap311__Service_Type__c st1 = new Incap311__Service_Type__c(Incap311__Service_Name__c = 'abc', Incap311__Service_Type_Code__c = '123');
        Incap311__Service_Type__c st2 = new Incap311__Service_Type__c(Incap311__Service_Name__c = 'def', Incap311__Service_Type_Code__c = '456');
        insert st1;
        insert st2;
        
        Incap311__Service_Type_Version__c stv1 = new Incap311__Service_Type_Version__c(
            Incap311__Is_Draft__c = false, Incap311__Service_Type__c = st1.Id, 
            Incap311__Version_Code__c = '123', Incap311__Version_Name__c = 'abc', Incap311__Service_Name__c = 'test name 123'
        );
        Incap311__Service_Type_Version__c stv2 = new Incap311__Service_Type_Version__c(
            Incap311__Is_Draft__c = false, Incap311__Service_Type__c = st2.Id, 
            Incap311__Version_Code__c = '456', Incap311__Version_Name__c = 'edf', Incap311__Service_Name__c = 'test name 456'
        );
        insert stv1;
        insert stv2;

        
        Transfer_Service_Request_Type__c tsrt = new Transfer_Service_Request_Type__c(To_Service_Type__c = st1.Id, From_Service_Type__c = st2.Id);
        insert tsrt;
        
        tsrt = [ SELECT To_Service_Type__c, To_Service_Type__r.Service_Name__c FROM Transfer_Service_Request_Type__c WHERE Id = :tsrt.Id ];
        
        st1.Incap311__Active_Service_Type_Version__c = stv1.Id;
        st2.Incap311__Active_Service_Type_Version__c = stv2.Id;
        update st1;
        update st2;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(st2); 
        Base311_ServiceTypeTransferConfig ct = new Base311_ServiceTypeTransferConfig(sc);
        
        List<SelectOption> opts = ct.getSelectedTypes(new List<Transfer_Service_Request_Type__c>{ tsrt });
        
        System.assertEquals(opts.size(), 1);
    }

    @isTest
    static void testGetPossibleTypes() {
        Incap311__Service_Type__c st1 = new Incap311__Service_Type__c(Incap311__Service_Name__c = 'abc', Incap311__Service_Type_Code__c = '123');
        Incap311__Service_Type__c st2 = new Incap311__Service_Type__c(Incap311__Service_Name__c = 'def', Incap311__Service_Type_Code__c = '456');
        insert st1;
        insert st2;
        
        Incap311__Service_Type_Version__c stv1 = new Incap311__Service_Type_Version__c(
            Incap311__Is_Draft__c = false, Incap311__Service_Type__c = st1.Id, 
            Incap311__Version_Code__c = '123', Incap311__Version_Name__c = 'abc', Incap311__Service_Name__c = 'test name 123'
        );
        Incap311__Service_Type_Version__c stv2 = new Incap311__Service_Type_Version__c(
            Incap311__Is_Draft__c = false, Incap311__Service_Type__c = st2.Id, 
            Incap311__Version_Code__c = '456', Incap311__Version_Name__c = 'edf', Incap311__Service_Name__c = 'test name 456'
        );
        insert stv1;
        insert stv2;
                 
        st1.Incap311__Active_Service_Type_Version__c = stv1.Id;
        st2.Incap311__Active_Service_Type_Version__c = stv2.Id;
        update st1;
        update st2;
         
        ApexPages.StandardController sc = new ApexPages.StandardController(st2); 
        
        Base311_ServiceTypeTransferConfig ct = new Base311_ServiceTypeTransferConfig(sc);
        
        List<SelectOption> opts = ct.getPossibleTypes();
        
        System.assertEquals(opts.size(), 1);
    }
    
}