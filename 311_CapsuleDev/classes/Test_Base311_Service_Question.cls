@isTest
public class Test_Base311_Service_Question {

    @isTest
    static void testPatchQuestionsDec() {
        Base311_Service_Question rsq = new Base311_Service_Question();
        Base311_Service_Request rsr = new Base311_Service_Request();

        Question__c q = Test_RestTestHelper.question('', 'Number', '');
        Service_Type_Version__c stv = Test_RestTestHelper.sericeTypeVersionAndVersion();
        Service_Type_Version_Question__c stvq = Test_RestTestHelper.serviceTypeVersionQuestion(q.Id, stv.Id);
        stvq = [SELECT Question__r.Flex_Question_Code__c,Dependencies__c FROM Service_Type_Version_Question__c WHERE Id = :stvq.Id];
        Case c = Test_RestTestHelper.serviceRequest(stv.Id);
        Service_Question__c sq = Test_RestTestHelper.serviceQuestion(c.Id, stvq.Id);
        c = rsr.getServiceRequest(c.Service_Request_Number__c);

        Base311_PatchValue respsones = new Base311_PatchValue(true, new Map<String, Object>{
            stvq.Question__r.Flex_Question_Code__c => 10.2 
        });


        List<Service_Question__c> result = rsq.patchQuestionResponses(c, respsones);

        System.assertEquals(result[0].Answer__c, '10.2');
    }
    
    @isTest
    static void testPatchQuestionsInt() {
        Base311_Service_Question rsq = new Base311_Service_Question();
        Base311_Service_Request rsr = new Base311_Service_Request();

        Question__c q = Test_RestTestHelper.question('', 'Number', '');
        Service_Type_Version__c stv = Test_RestTestHelper.sericeTypeVersionAndVersion();
        Service_Type_Version_Question__c stvq = Test_RestTestHelper.serviceTypeVersionQuestion(q.Id, stv.Id);
        stvq = [SELECT Question__r.Flex_Question_Code__c,Dependencies__c FROM Service_Type_Version_Question__c WHERE Id = :stvq.Id];
        Case c = Test_RestTestHelper.serviceRequest(stv.Id);
        Service_Question__c sq = Test_RestTestHelper.serviceQuestion(c.Id, stvq.Id);
        c = rsr.getServiceRequest(c.Service_Request_Number__c);

        Base311_PatchValue respsones = new Base311_PatchValue(true, new Map<String, Object>{
            stvq.Question__r.Flex_Question_Code__c => 11.0 
        });


        List<Service_Question__c> result = rsq.patchQuestionResponses(c, respsones);

        System.assertEquals(result[0].Answer__c, '11');
    }

    @isTest
    static void testCreateQuestionResponses() {
        Base311_Service_Question rsq = new Base311_Service_Question();
        Base311_Service_Request rsr = new Base311_Service_Request();

        Service_Type_Version__c stv = Test_RestTestHelper.sericeTypeVersionAndVersion();

        Case c = Test_RestTestHelper.serviceRequest(stv.Id);

        Question__c q = Test_RestTestHelper.question();
        Question__c q2 = Test_RestTestHelper.question();

        Service_Type_Version_Question__c stvq = Test_RestTestHelper.serviceTypeVersionQuestion(q.Id, stv.Id);
        Service_Type_Version_Question__c stvq2 = Test_RestTestHelper.serviceTypeVersionQuestion(q2.Id, stv.Id);

        stvq = [SELECT Name, Question__r.Flex_Question_Code__c,Validations__c,Dependencies__c FROM Service_Type_Version_Question__c WHERE Id = :stvq.Id];
        stvq2 = [SELECT Name, Question__r.Flex_Question_Code__c,Dependencies__c FROM Service_Type_Version_Question__c WHERE Id = :stvq2.Id];

        Map<String, Base311_Attribute> attributes = new Map<String, Base311_Attribute>{
            stvq.Question__r.Flex_Question_Code__c => new Base311_Attribute(stvq.Question__r.Flex_Question_Code__c, 'test1'),
            stvq2.Question__r.Flex_Question_Code__c => new Base311_Attribute(stvq2.Question__r.Flex_Question_Code__c, 'test2')
        }; 

        List<Service_Question__c> sqs = rsq.upsertQuestionResponses(c, attributes);

        System.assertEquals(sqs.size(), 2);
        System.assertEquals(sqs[0].Service_Type_Version_Question__c, stvq.Id);
        System.assertEquals(sqs[0].Answer__c, 'test1');
        System.assertEquals(sqs[1].Service_Type_Version_Question__c, stvq2.Id);
        System.assertEquals(sqs[1].Answer__c, 'test2');
    }

    @isTest
    static void testNegativeCreateQuestionResponsesRequiredDependency() {
        Base311_Service_Question rsq = new Base311_Service_Question();
        Base311_Service_Request rsr = new Base311_Service_Request();

        Service_Type_Version__c stv = Test_RestTestHelper.sericeTypeVersionAndVersion();

        Case c = Test_RestTestHelper.serviceRequest(stv.Id);

        Question__c q = Test_RestTestHelper.question();
        Question__c q2 = Test_RestTestHelper.question();
        q2.Flex_Question_Code__c = 'TEST123';
        update q2;

        Service_Type_Version_Question__c stvq = Test_RestTestHelper.serviceTypeVersionQuestion(q.Id, stv.Id);
        Service_Type_Version_Question__c stvq2 = Test_RestTestHelper.serviceTypeVersionQuestion(q2.Id, stv.Id);

        stvq = [SELECT Name, Question__r.Flex_Question_Code__c,Validations__c,Dependencies__c FROM Service_Type_Version_Question__c WHERE Id = :stvq.Id];
        stvq2 = [SELECT Name, Question__r.Flex_Question_Code__c,Dependencies__c FROM Service_Type_Version_Question__c WHERE Id = :stvq2.Id];
        stvq2.Dependencies__c = '{"clause":"AND","conditions":[{"left":"ServiceQuestionCode['+stvq.Question__r.Flex_Question_Code__c+'].Incap311_Answer__c","op":"eq","right":"Test"}]}';
        stvq2.Is_Required__c = true;
        update stvq2;

        Map<String, Base311_Attribute> attributes = new Map<String, Base311_Attribute>{
            stvq.Question__r.Flex_Question_Code__c => new Base311_Attribute(stvq.Question__r.Flex_Question_Code__c, 'Test')
        }; 

        try{     

            List<Service_Question__c> sqs = rsq.upsertQuestionResponses(c, attributes);
        }catch(Exception e){
            System.assertEquals('TEST123 is required',e.getMessage());
        }




    }

    @isTest
    static void testPostiveCreateQuestionResponsesRequiredDependency() {
        Base311_Service_Question rsq = new Base311_Service_Question();
        Base311_Service_Request rsr = new Base311_Service_Request();

        Service_Type_Version__c stv = Test_RestTestHelper.sericeTypeVersionAndVersion();

        Case c = Test_RestTestHelper.serviceRequest(stv.Id);

        Question__c q = Test_RestTestHelper.question();
        q.Flex_Question_Code__c = 'q1';
        update q;
        Question__c q2 = Test_RestTestHelper.question();
        q2.Flex_Question_Code__c = 'q2';
        update q2;

        Service_Type_Version_Question__c stvq = Test_RestTestHelper.serviceTypeVersionQuestion(q.Id, stv.Id);
        Service_Type_Version_Question__c stvq2 = Test_RestTestHelper.serviceTypeVersionQuestion(q2.Id, stv.Id);

        stvq = [SELECT Name, Question__r.Flex_Question_Code__c,Validations__c,Dependencies__c FROM Service_Type_Version_Question__c WHERE Id = :stvq.Id];
        stvq2 = [SELECT Name, Question__r.Flex_Question_Code__c,Dependencies__c FROM Service_Type_Version_Question__c WHERE Id = :stvq2.Id];
        stvq2.Dependencies__c = '{"clause":"AND","conditions":[{"left":"ServiceQuestionCode[q1].Incap311_Answer__c","op":"eq","right":"Test"}]}';
        stvq2.Is_Required__c = true;
        update stvq2;


        Map<String, Base311_Attribute> attributes = new Map<String, Base311_Attribute>{
            'q1' => new Base311_Attribute('q1', 'test1')
        }; 

        List<Service_Question__c> sqs = rsq.upsertQuestionResponses(c, attributes);
    }


}