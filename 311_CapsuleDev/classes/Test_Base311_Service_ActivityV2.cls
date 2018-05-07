@isTest
public class Test_Base311_Service_ActivityV2 {

    @isTest
    static void testFetchSTVAOutcomes(){
        Base311_Service_ActivityV2 bas = new Base311_Service_ActivityV2();
        Service_Type_Version__c stv = Test_RestTestHelper.sericeTypeVersionAndVersion();
        Activity__c a = Test_RestTestHelper.activity();
        Service_Type_Version_Activity__c stva = Test_RestTestHelper.serviceTypeVersionActivity(a.Id, stv.Id);
        Outcome__c o = Test_RestTestHelper.outcome();
        Activity_Outcome__c ao = Test_RestTestHelper.stvaActivityOutcome(stva.Id, o.Id);
        
        Map<Id, List<Activity_Outcome__c>> items = bas.fetchSTVAOutcomes(new List<Service_Type_Version_Activity__c>{ stva });
        
        System.assert(items.containsKey(stva.Id));
        System.assertEquals(items.get(stva.Id).size(), 1);
        System.assertEquals(items.get(stva.Id).get(0).Id, ao.Id);
    }
    @isTest
    static void testUpdateServiceActivityInvalidCode() {
        Base311_Service_Request bsr = new Base311_Service_Request();
        Base311_Service_ActivityV2 bas = new Base311_Service_ActivityV2();
        Service_Type_Version__c stv = Test_RestTestHelper.sericeTypeVersionAndVersion();
        Activity__c a = Test_RestTestHelper.activity();
        Service_Type_Version_Activity__c stva = Test_RestTestHelper.serviceTypeVersionActivity(a.Id, stv.Id);
        Outcome__c o = Test_RestTestHelper.outcome();
        Activity_Outcome__c ao = Test_RestTestHelper.stvaActivityOutcome(stva.Id, o.Id);
        Response__c r = Test_RestTestHelper.response();
        Question__c q = Test_RestTestHelper.question();
        Outcome_Question__c oq = Test_RestTestHelper.oq(ao.Id, q.Id);
        Activity_Outcome_Response__c aor = Test_RestTestHelper.aor(r.Id, ao.Id);
            
        Case c = Test_RestTestHelper.serviceRequest(stv.Id);    
        Service_Activity__c sa = Test_RestTestHelper.serviceActivity(stva.Id, c.Id);
        c = bsr.getServiceRequest(c.Service_Request_Number__c);
        System.debug(q.Flex_Question_Code__c);
        
        stva = [SELECT Activity_Code__c FROM Service_Type_Version_Activity__c WHERE Id = :stva.Id];
        ao = [SELECT Outcome_Code__c FROM Activity_Outcome__c WHERE Id = :ao.Id];
        aor = [SELECT Response_Code__c FROM Activity_Outcome_Response__c WHERE Id = :aor.Id];
        
        try {
            Base311_ActivityV2 actUpdates = new Base311_ActivityV2(
                'FakeCode', ao.Outcome_Code__c, aor.Response_Code__c, 'Some additional comments',
                new Map<String, Object>{ q.Flex_Question_Code__c => 'ABC 123' }, '2017-06-12T17:09:48', null
            );
            bas.updateServiceActivity(c, actUpdates);
        } catch(Base311_Exceptions.UnsupportedException e) {
            return;
        }
        
        System.assert(false);
    }
    
    @isTest
    static void testPatchServiceActivity() {
        Base311_Service_Request bsr = new Base311_Service_Request();
        Base311_Service_ActivityV2 bas = new Base311_Service_ActivityV2();
        Service_Type_Version__c stv = Test_RestTestHelper.sericeTypeVersionAndVersion();
        Activity__c a = Test_RestTestHelper.activity();
        Service_Type_Version_Activity__c stva = Test_RestTestHelper.serviceTypeVersionActivity(a.Id, stv.Id);
        Outcome__c o = Test_RestTestHelper.outcome();
        Activity_Outcome__c ao = Test_RestTestHelper.stvaActivityOutcome(stva.Id, o.Id);
        Response__c r = Test_RestTestHelper.response();
        Question__c q = Test_RestTestHelper.question();
        Question__c q1 = Test_RestTestHelper.question();
        Outcome_Question__c oq = Test_RestTestHelper.oq(ao.Id, q.Id);
        Outcome_Question__c oq1 = Test_RestTestHelper.oq(ao.Id, q1.Id);
        Activity_Outcome_Response__c aor = Test_RestTestHelper.aor(r.Id, ao.Id);

        Case c = Test_RestTestHelper.serviceRequest(stv.Id);    
        Service_Activity__c sa = Test_RestTestHelper.serviceActivity(stva.Id, c.Id);
        
        sa.Activity_Outcome__c = ao.Id;
        update sa;

        Activity_Question__c aq1 = Test_RestTestHelper.activityQuestion(c.Id, sa.Id, oq1.Id, 'Hi');
        c = bsr.getServiceRequest(c.Service_Request_Number__c); 
        
        stva = [SELECT Activity_Code__c FROM Service_Type_Version_Activity__c WHERE Id = :stva.Id];
        ao = [SELECT Outcome_Code__c FROM Activity_Outcome__c WHERE Id = :ao.Id];
        aor = [SELECT Response_Code__c, Canned_Response__r.Long_Response_Text__c FROM Activity_Outcome_Response__c WHERE Id = :aor.Id];
         
        Service_Activity__c updatedSA = bas.patchServiceActivity(
            c, 
            stva.Activity_Code__c, 
            new Base311_PatchValue(
                true,
                new Map<String, Object>{
                    'outcome_code' => ao.Outcome_Code__c,
                    'additional_comments' => 'Some additional comments',
                    'response_code' => aor.Response_Code__c,
                    'attribute' => new Map<String, Object>{ q.Flex_Question_Code__c => 'ABC 123' },
                    'finish_date' => '2017-06-12T09:09:48+00:00'
                }
            )
        );
        
        System.assertEquals(updatedSA.Additional_Comments__c, 'Some additional comments');
        System.assertEquals(updatedSA.Activity_Outcome__c, ao.Id);
        System.assertEquals(updatedSA.External_Comments__c, aor.Canned_Response__r.Long_Response_Text__c);
        System.assertEquals(updatedSA.Status__c, 'Complete');
        
        Activity_Question__c aq = [SELECT Answer__c FROM Activity_Question__c WHERE Outcome_Question__c = :oq.Id];        
        aq1 = [SELECT Answer__c FROM Activity_Question__c WHERE Outcome_QUestion__c = :oq1.Id];
        
        System.assertEquals(aq.Answer__c, 'ABC 123');
        System.assertEquals(aq1.Answer__c, 'Hi');
    }
    
    @isTest
    static void testUpdateServiceActivity() {
        Base311_Service_Request bsr = new Base311_Service_Request();
        Base311_Service_ActivityV2 bas = new Base311_Service_ActivityV2();
        Service_Type_Version__c stv = Test_RestTestHelper.sericeTypeVersionAndVersion();
        Activity__c a = Test_RestTestHelper.activity();
        Service_Type_Version_Activity__c stva = Test_RestTestHelper.serviceTypeVersionActivity(a.Id, stv.Id);
        Outcome__c o = Test_RestTestHelper.outcome();
        Activity_Outcome__c ao = Test_RestTestHelper.stvaActivityOutcome(stva.Id, o.Id);
        Response__c r = Test_RestTestHelper.response();
        Question__c q = Test_RestTestHelper.question();
        Question__c q1 = Test_RestTestHelper.question();
        Outcome_Question__c oq = Test_RestTestHelper.oq(ao.Id, q.Id);
        Outcome_Question__c oq1 = Test_RestTestHelper.oq(ao.Id, q1.Id);
        Activity_Outcome_Response__c aor = Test_RestTestHelper.aor(r.Id, ao.Id);
        

        Case c = Test_RestTestHelper.serviceRequest(stv.Id);    
        Service_Activity__c sa = Test_RestTestHelper.serviceActivity(stva.Id, c.Id);
        c = bsr.getServiceRequest(c.Service_Request_Number__c);
        System.debug(q.Flex_Question_Code__c);
        
        stva = [SELECT Activity_Code__c FROM Service_Type_Version_Activity__c WHERE Id = :stva.Id];
        ao = [SELECT Outcome_Code__c FROM Activity_Outcome__c WHERE Id = :ao.Id];
        aor = [SELECT Response_Code__c, Canned_Response__r.Long_Response_Text__c FROM Activity_Outcome_Response__c WHERE Id = :aor.Id];
        
        Base311_ActivityV2 actUpdates = new Base311_ActivityV2(
            stva.Activity_Code__c, ao.Outcome_Code__c, aor.Response_Code__c, 'Some additional comments',
            new Map<String, Object>{ q.Flex_Question_Code__c => 'ABC 123' }, '2017-06-12T09:09:48+00:00', null
        );
        
        Service_Activity__c updatedSA = bas.updateServiceActivity(c, actUpdates);
        
        System.assertEquals(updatedSA.Additional_Comments__c, 'Some additional comments');
        System.assertEquals(updatedSA.Activity_Outcome__c, ao.Id);
        System.assertEquals(updatedSA.External_Comments__c, aor.Canned_Response__r.Long_Response_Text__c);
        System.assertEquals(updatedSA.Status__c, 'Complete');
        
        Activity_Question__c aq = [SELECT Answer__c FROM Activity_Question__c WHERE Outcome_Question__c = :oq.Id];        
        Activity_Question__c aq1 = [SELECT Answer__c FROM Activity_Question__c WHERE Outcome_QUestion__c = :oq1.Id];
        
        System.assertEquals(aq.Answer__c, 'ABC 123');
        System.assertEquals(aq1.Answer__c, null);
    }
    
}