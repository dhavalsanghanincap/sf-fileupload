@isTest
public class Test_Base311_TriggerHandler_Case {
    @isTest
    static void testExecute() {
        /*Service_Type_Version__c stv1 = Test_RestTestHelper.sericeTypeVersionAndVersion();
        Service_Type_Version__c stv2 = Test_RestTestHelper.sericeTypeVersionAndVersion();
        Base311_Service_Request bsr = new Base311_Service_Request();
        
        stv1.Send_Email_On_SR_Creation__c = true;
        stv1.Track_SR_Creation_Email__c = true;
        stv1.Incap311__Rich_Email_Intro_Create__c = '{!  CaseNumber  } is the case number; {!Service_Type_Version__r.Send_Email_On_SR_Creation__c}';
        stv2.Send_Email_On_SR_Creation__c = false;
        
        update stv1;
        update stv2;
        
        Case c1 = Test_RestTestHelper.serviceRequest(stv1.Id);
        Case c2 = Test_RestTestHelper.serviceRequest(stv1.Id);
        Case c3 = Test_RestTestHelper.serviceRequest(stv2.Id);
        
        List<Case> cases = bsr.getServiceRequests(new Set<Id>{ c1.Id, c2.Id, c3.Id });
        
        Base311_TriggerHandler_Case thc = new Base311_TriggerHandler_Case();
        thc.execute(null, cases);
        
        Case_Event__c ces1 = [ SELECT Id, Rich_Email_Body__c FROM Case_Event__c WHERE Service_Request__c = :c1.Id ];
        Case_Event__c ces2 = [ SELECT Id, Rich_Email_Body__c FROM Case_Event__c WHERE Service_Request__c = :c2.Id ];
          
        System.assertEquals(ces1.Rich_Email_Body__c, c1.Service_Request_Number__c + ' is the case number; true<br><br><br><br>');
        System.assertEquals(ces2.Rich_Email_Body__c, c2.Service_Request_Number__c + ' is the case number; true<br><br><br><br>');*/
    }
    
}