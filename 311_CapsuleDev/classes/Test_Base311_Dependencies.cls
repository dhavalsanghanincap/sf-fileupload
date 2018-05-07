@isTest
public class Test_Base311_Dependencies
{

    @isTest
    static void testGetActiveQuestionsOutcomes() {
    	Outcome__c o = Test_RestTestHelper.outcome();
        Activity__c a = Test_RestTestHelper.activity();
        Service_Type_Version__c stv = Test_RestTestHelper.sericeTypeVersionAndVersion();
        Service_Type_Version_Activity__c stva = Test_RestTestHelper.serviceTypeVersionActivity(a.Id, stv.Id);
        Activity_Outcome__c ao = new Activity_Outcome__c(Outcome__c = o.Id, Activity__c = a.Id, Service_Type_Version_Activity__c = stva.Id); 
        insert ao;
        Question__c q = Test_RestTestHelper.question();
         
        Outcome_Question__c oq = new Outcome_Question__c(Activity_Outcome__c = o.Id, Question__c = q.Id, Service_Type_Version_Activity_Outcome__c = ao.Id);
        Outcome_Question__c oq2 = new Outcome_Question__c(Activity_Outcome__c = o.Id, Question__c = q.Id, Service_Type_Version_Activity_Outcome__c = ao.Id);        
        oq.Dependencies__c = '{ "clause": "OR", "conditions":[{"left":"OutcomeQuestionCode[ABC].Incap311__Answer__c","op":"eq","right":1}]}';
        oq2.Dependencies__c = '{ "clause": "OR", "conditions":[{"left":"OutcomeQuestionCode[ABC].Incap311__Answer__c","op":"eq","right":2}]}';
        insert oq;
        insert oq2;         
        List<Outcome_Question__c> questions = Base311_Dependencies.getCurrentQuestions(ao, new Map<String, Object>{ 'ABC' => 1 });
        System.assertEquals(questions.size(), 1);
        System.assertEquals(questions.get(0).Id, oq.Id);
    }
    
    @isTest
    static void testGetActiveQuestionsSTV() {
        Service_Type_Version__c stv = Test_RestTestHelper.sericeTypeVersionAndVersion();
        Question__c q = new Question__c(
            Question__c = null, 
            Data_Type__c = 'Number', 
            Hint_Text__c = null,
            Flex_Question_Code__c = '1deff'
        );
        insert q;
        
        Service_Type_Version_Question__c stvq = Test_RestTestHelper.serviceTypeVersionQuestion(q.Id, stv.Id);
        stvq = [ SELECT Id, Flex_Question_Code__c FROM Service_Type_Version_Question__c WHERE Id = :stvq.Id ]; 
        stvq.Dependencies__c = '{ "clause": "OR", "conditions":[{"left":"ServiceQuestionCode[ABC].Incap311__Answer__c","op":"eq","right":1}]}';
		update stvq;
        
        Service_Type_Version_Question__c stvq2 = Test_RestTestHelper.serviceTypeVersionQuestion(q.Id, stv.Id);        
        stvq2 = [ SELECT Id, Flex_Question_Code__c FROM Service_Type_Version_Question__c WHERE Id = :stvq2.Id ]; 
        stvq2.Dependencies__c = '{ "clause": "OR", "conditions":[{"left":"ServiceQuestionCode[ABC].Incap311__Answer__c","op":"eq","right":2}]}';
		update stvq2;
        
        Base311_Service_ServiceType sst = new Base311_Service_ServiceType();
        stv = sst.getServiceType(stv.Name, true);
        
        System.debug(stv.Service_Type_Version_Questions__r);
        
        List<Service_Type_Version_Question__c> questions = Base311_Dependencies.getCurrentQuestions(stv, new Map<String, Object>{ 'ABC' => 1 });
        System.assertEquals(questions.size(), 1);
        System.assertEquals(questions.get(0).Id, stvq.Id);
    }
    
    @isTest
    static void testValidateOutcomeQuestionSuccess() {
        Outcome_Question__c oq = Test_RestTestHelper.outcomeQuestion();
        oq.Validations__c= '[{"dependentOn": {"clause": "OR", "conditions":[{"left":"OutcomeQuestionCode[ABC].Incap311__Answer__c", "op": "eq", "right": 2}]}, "message":"You said no" }]';
        
        try {
        	Base311_Dependencies.validateQuestion(oq, new Map<String, Object>{ 'ABC' => 1 });
        } catch (Base311_Exceptions.ValidationException e) {
        	System.assert(false);
            return;
        }
        
        System.assert(true);
    }
    
    
    @isTest
    static void testValidateOutcomeQuestion() {
        Outcome_Question__c oq = Test_RestTestHelper.outcomeQuestion();
        oq.Validations__c= '[{"dependentOn": {"clause": "OR", "conditions":[{"left":"OutcomeQuestionCode[ABC].Incap311__Answer__c", "op": "eq", "right": 1}]}, "message":"You said no" }]';
        
        try {
        Base311_Dependencies.validateQuestion(oq, new Map<String, Object>{ 'ABC' => 1 });
        } catch (Base311_Exceptions.ValidationException e) {
            System.assertEquals(e.getMessage(), 'You said no');
            return;
        }
        
        System.assert(false);
    }
    
    @isTest
    static void testPicklistSTVQuesiton() {
        Service_Type_Version__c stv = Test_RestTestHelper.sericeTypeVersionAndVersion();
        Question__c q = new Question__c(
            Question__c = null, 
            Data_Type__c = 'Number', 
            Hint_Text__c = null,
            Flex_Question_Code__c = '1deff'
        );
        insert q;
        
        Service_Type_Version_Question__c stvq = Test_RestTestHelper.serviceTypeVersionQuestion(q.Id, stv.Id);
        
        stvq = [ SELECT Flex_Question_Code__c FROM Service_Type_Version_Question__c WHERE Id = :stvq.Id ]; 
        stvq.Override_Answer_Values__c = '[{"key":"a", "value":"a"}]';
        
        List<Base311_QuestionAnswer> answers = Base311_Dependencies.getSobjectActivePicklist(stvq, new Map<String, Object>{ 'ABC' => 1 });
        
        System.debug(answers);
        
        System.assertEquals(answers.size(), 1);
        System.assertEquals(answers.get(0).key, 'a');
        System.assertEquals(answers.get(0).value, 'a');
    }
    
    @isTest
    static void testDependentPicklistSTVQuesitonEmpty() {
        Service_Type_Version__c stv = Test_RestTestHelper.sericeTypeVersionAndVersion();
        Question__c q = new Question__c(
            Question__c = null, 
            Data_Type__c = 'Number', 
            Hint_Text__c = null,
            Flex_Question_Code__c = '1deff'
        );
        insert q;
        
        Service_Type_Version_Question__c stvq = Test_RestTestHelper.serviceTypeVersionQuestion(q.Id, stv.Id);
        
        stvq = [ SELECT Flex_Question_Code__c FROM Service_Type_Version_Question__c WHERE Id = :stvq.Id ]; 
        stvq.Override_Answer_Values__c = '[{"dependentOn":{ "clause": "OR", "conditions":[{"left":"ServiceQuestionCode[ABC].Incap311__Answer__c","op":"eq","right":2}]}, "values":[{"key":"a", "value":"a"}] }]';
        
        List<Base311_QuestionAnswer> answers = Base311_Dependencies.getSobjectActivePicklist(stvq, new Map<String, Object>{ 'ABC' => 1 });
        
        System.debug(answers);
        
        System.assertEquals(answers.size(), 0);
    }
    
    @isTest
    static void testDependentPicklistSTVQuesiton() {
        Service_Type_Version__c stv = Test_RestTestHelper.sericeTypeVersionAndVersion();
        Question__c q = new Question__c(
            Question__c = null, 
            Data_Type__c = 'Number', 
            Hint_Text__c = null,
            Flex_Question_Code__c = '1deff'
        );
        insert q;
        
        Service_Type_Version_Question__c stvq = Test_RestTestHelper.serviceTypeVersionQuestion(q.Id, stv.Id);
        
        stvq = [ SELECT Flex_Question_Code__c FROM Service_Type_Version_Question__c WHERE Id = :stvq.Id ]; 
        stvq.Override_Answer_Values__c = '[{"dependentOn":{ "clause": "OR", "conditions":[{"left":"ServiceQuestionCode[ABC].Incap311__Answer__c","op":"eq","right":1}]}, "values":[{"key":"a", "value":"a"}] }]';
        
        List<Base311_QuestionAnswer> answers = Base311_Dependencies.getSobjectActivePicklist(stvq, new Map<String, Object>{ 'ABC' => 1 });
        System.assertEquals(answers.size(), 1);
        System.assertEquals(answers.get(0).key, 'a');
        System.assertEquals(answers.get(0).value, 'a');
    }
    
    @isTest
    static void testDependentPicklistOutcomeQuesitonEmpty() {
        Outcome_Question__c oq = Test_RestTestHelper.outcomeQuestion();
        
        oq.Override_Answer_Values__c = '[{"dependentOn":{ "clause": "OR", "conditions": [{"left":"OutcomeQuestionCode[ABC].Incap311__Answer__c","op":"eq","right":1}]}, "values":[{"key":"a", "value":"a"}] }]';
        List<Base311_QuestionAnswer> answers = Base311_Dependencies.getSobjectActivePicklist(oq, new Map<String, Object>{ 'ABC' => 2 });
        System.assertEquals(answers.size(), 0);
    }
    
    @isTest
    static void testPicklistOutcomeQuesiton() {
        Outcome_Question__c oq = Test_RestTestHelper.outcomeQuestion();
        
        oq.Override_Answer_Values__c = '[{"key":"a", "value":"a"}]';
        List<Base311_QuestionAnswer> answers = Base311_Dependencies.getSobjectActivePicklist(oq, new Map<String, Object>{ });
        System.assertEquals(answers.size(), 1);
        System.assertEquals(answers.get(0).key, 'a');
        System.assertEquals(answers.get(0).value, 'a');
    }
    
    @isTest
    static void testDependentPicklistOutcomeQuesiton() {
        Outcome_Question__c oq = Test_RestTestHelper.outcomeQuestion();
        
        oq.Override_Answer_Values__c = '[{"dependentOn":{ "clause": "OR", "conditions": [{"left":"OutcomeQuestionCode[ABC].Incap311__Answer__c","op":"eq","right":1}]}, "values":[{"key":"a", "value":"a"}] }]';
        List<Base311_QuestionAnswer> answers = Base311_Dependencies.getSobjectActivePicklist(oq, new Map<String, Object>{ 'ABC' => 1 });
        System.assertEquals(answers.size(), 1);
        System.assertEquals(answers.get(0).key, 'a');
        System.assertEquals(answers.get(0).value, 'a');
    }
    
    @isTest
    static void testActivePicklistOutcomeQuestion() {
        Outcome_Question__c oq = Test_RestTestHelper.outcomeQuestion();
        oq.Override_Answer_Values__c = '[{"dependentOn":{ "clause": "OR", "conditions":[{"left":1,"op":"eq","right":1}] }, "values":[{"key":"a", "value":"a"}] }]';
        List<Base311_QuestionAnswer> answers = Base311_Dependencies.getSobjectActivePicklist(oq, new Map<String, Object>());
        System.assertEquals(answers.size(), 1);
    }
    
    @isTest
    static void testSuggestions() {
        Base311_Service_ServiceType sst = new Base311_Service_ServiceType();
        
        Service_Type_Version__c stv1 = Test_RestTestHelper.sericeTypeVersionAndVersion();
        Service_Type_Version__c stv2 = Test_RestTestHelper.sericeTypeVersionAndVersion();
        stv2 = sst.getServiceType(stv2.Name, true);
        stv2.Is_Draft__c = false;
        stv2.Incap311__Service_Type__r.Active_Service_Type_Version__c = stv2.Id;
        update stv2;
        update stv2.Incap311__Service_Type__r; 
        stv1.Recommended_Types__c = '[{"dependentOn":{ "clause": "OR", "conditions":[{"left":1,"op":"eq","right":1}] }, "values":["' + stv2.Service_Type_Code__c + '"] }]';
        update stv1;
        
        List<Service_Type_Version__c> stvs = Base311_Dependencies.getServiceTypeSuggestions(sst.getServiceType(stv1.Name, true), new Map<String, Object>());
        
        System.assertEquals(stvs.size(), 1);
        System.assertEquals(stvs[0].Id, stv2.Id);
    }
    
    static testMethod void testValidateQuestion()
    {
        Base311_Service_Question rsq = new Base311_Service_Question();
        Base311_Service_Request rsr = new Base311_Service_Request();
        
        Service_Type_Version__c stv = Test_RestTestHelper.sericeTypeVersionAndVersion();
        
        Case c = Test_RestTestHelper.serviceRequest(stv.Id);
        
        Question__c q = Test_RestTestHelper.question();
        Question__c q2 = Test_RestTestHelper.question();
        
        Service_Type_Version_Question__c stvq = Test_RestTestHelper.serviceTypeVersionQuestion(q.Id, stv.Id);
        stvq = [select Validations__c,Incap311__Flex_Question_Code__c from Service_Type_Version_Question__c where id = :stvq.Id][0];
        Service_Type_Version_Question__c stvq2 = Test_RestTestHelper.serviceTypeVersionQuestion(q2.Id, stv.Id);
        stvq2 = [select Validations__c,Incap311__Flex_Question_Code__c from Service_Type_Version_Question__c where id = :stvq2.Id][0];
        
        
        Base311_Dependencies.validateQuestion(stvq,new Map<String, Object>());
        
        stvq.Validations__c = '[{"dependentOn":{"clause":"OR","conditions":[{"left":1,"op":"eq","right":1}]},"message":"There is a problem"}]';
        stvq2.Validations__c = '[{"dependentOn":{"clause":"OR","conditions":[{"left":"ServiceQuestionCode['+stvq.Incap311__Flex_Question_Code__c+'].Incap311__Answer__c","op":"gt","right":5}]},"message":"There is a problem"}]';
        
        boolean exceptionCaught = false;
        try{
             Base311_Dependencies.validateQuestion(stvq,new Map<String, Object>());
        }catch(Exception e){
            System.assertEquals('There is a problem',e.getMessage());
            exceptionCaught = true;
        }
        System.assert(exceptionCaught);
        
        exceptionCaught = false;
        Map<String, Object> values = new Map<String, Object>();
        values.put(stvq.Incap311__Flex_Question_Code__c,'6');
        
        try{
             Base311_Dependencies.validateQuestion(stvq2, values);
        }catch(Exception e){
           System.assertEquals('There is a problem',e.getMessage());
            exceptionCaught = true;
        }
        
        System.assert(exceptionCaught);
    }

    static testMethod void testGetSobjectActiveQuestions() {
        Base311_Service_Question rsq = new Base311_Service_Question();
        Base311_Service_Request rsr = new Base311_Service_Request();

        Service_Type_Version__c stv = Test_RestTestHelper.sericeTypeVersionAndVersion();

        Question__c q = new Question__c(
            Question__c = null, 
            Data_Type__c = 'Picklist', 
            Hint_Text__c = null,
            Flex_Question_Code__c = '1deff',
            Answer_Values__c = '[{"key":"Small","value":"Small"},{"key":"Medium","value":"Medium"},{"key":"Large","value":"Large"}]'
        );
        insert q;

        Service_Type_Version_Question__c stvq = Test_RestTestHelper.serviceTypeVersionQuestion(q.Id, stv.Id);

        List<Incap311.Base311_QuestionAnswer> qaList =  Incap311.Base311_Dependencies.getActivePicklist(stvq, new Map<String,Object>());
        System.assertEquals(3, qaList.size());
    }
    
    @isTest
    static void testOutcomeQuestionsActive() {
        Base311_Service_Question rsq = new Base311_Service_Question();
        Base311_Service_Request rsr = new Base311_Service_Request();

        Outcome__c o = Test_RestTestHelper.outcome();

        Question__c q = new Question__c(
            Question__c = null, 
            Data_Type__c = 'Picklist', 
            Hint_Text__c = null,
            Flex_Question_Code__c = '1deff',
            Answer_Values__c = '[{"key":"Small","value":"Small"},{"key":"Medium","value":"Medium"},{"key":"Large","value":"Large"}]'
        );
        insert q;

        Outcome_Question__c oq= Test_RestTestHelper.outcomeQuestion(q.Id, o.Id);

        List<Incap311.Base311_QuestionAnswer> qaList =  Incap311.Base311_Dependencies.getActivePicklist(oq, new Map<String,Object>());
        System.assertEquals(3, qaList.size());
    }
     
}