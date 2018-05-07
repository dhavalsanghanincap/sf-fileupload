@isTest
public class Test_Base311_Service_CaseEvents {

    private static Base311_Service_CaseEvents sce = new Base311_Service_CaseEvents();
    private static Base311_Service_Request sr = new Base311_Service_Request();

    @isTest
    static void testDetails() {
        Service_Type_Version__c stv = Test_RestTestHelper.sericeTypeVersionAndVersion();
        stv.Incap311__Rich_Email_Intro_Create__c = 'Hello World';
        
        update stv;
        
        Case c = Test_RestTestHelper.serviceRequest(stv.Id);
        Contact con = Test_RestTestHelper.contact();
        
        c.ContactId = con.Id;
        update c;
        
        c = sr.getServiceRequest(c.Service_Request_Number__c);
        
        Case_Event__c ce = sce.details(c, 'Update', 'We performed some update');
        
        System.assert(ce.Id != null);
        System.assertEquals(ce.Event_Type__c, 'Update');
        System.assertEquals(ce.Details__c, 'We performed some update');
        System.assertEquals(ce.Service_Request__c, c.Id);
        System.assertEquals(ce.RecordTypeId, Base311_Service_CaseEvents.NOTFICATION_RECORD_ID);
        System.assertEquals(ce.Rich_Email_Body__c, 'Hello World<br/><br/><br/><br/>');
        System.assertEquals(ce.Notification_Recipient__c.toLowerCase(), con.Email.toLowerCase());
    }


    @isTest
    static void testNotify() {
        Case c = Test_RestTestHelper.serviceRequest();
        
        Case_Event__c ce = sce.notify(c, 'Update', 'This is my DL', 'This is my email body');
        
        System.assert(ce.Id != null);
        System.assertEquals(ce.Event_Type__c, 'Update');
        System.assertEquals(ce.Distribution_List__c, 'This is my DL');
        System.assertEquals(ce.Rich_Email_Body__c, 'This is my email body');
        System.assertEquals(ce.Service_Request__c, c.Id);
        System.assertEquals(ce.RecordTypeId, Base311_Service_CaseEvents.DISTRIBUTION_RECORD_ID);
        System.assertEquals(ce.Notification_Recipient__c, null);
    }

}