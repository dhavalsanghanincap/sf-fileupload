@isTest
public class Test_Console311_SR_Activity_Edit_Ext {

    /*public static void testSetup() {
        TestHelper.createData();
    }*/

    @isTest static void testDefault() {
        TestHelper.createData();
        //Test_Console311_SR_Activity_Edit_Ext.testSetup();

        Incap311__Activity__c a = new Incap311__Activity__c(Incap311__Activity_Code__c = '123');
        insert a;  
		
        Case c = [Select Id From Case Limit 1];

        // SERVICE TYPE VERSION
        Incap311__Service_Type_Version__c stv = [Select Id, Name From Incap311__Service_Type_Version__c Limit 1];

        // SERVICE TYPE VERSION ACTIVITY
        Incap311__Service_Type_Version_Activity__c stva = new Incap311__Service_Type_Version_Activity__c(
            Incap311__Service_Type_Version__c = stv.Id, Incap311__Order__c = 1, Incap311__Activity__c = a.Id
        );    
        insert stva;

        // QUESTION
        Incap311__Question__c q = new Incap311__Question__c(
            Incap311__Question__c = 'This is a question', 
            Incap311__Data_Type__c = 'MultiPicklist', 
            Incap311__Hint_Text__c = null,
            Incap311__Answer_Values__c = '[{"key":"test1", "value":"a1"}, {"key":"test2", "value": "a2"}]',
            Incap311__Flex_Question_Code__c = 'q1234'
        );
        insert q;

        // OUTCOME
        Incap311__Outcome__c outcome = new Incap311__Outcome__c(
            Incap311__Outcome_Code__c = 'OUT1234', Incap311__Outcome_Detail__c = 'BestOutcomeDetail', Incap311__Outcome_Action__c = 'Close'
        );
        insert outcome;

        // ACTIVITY OUTCOME
        Incap311__Activity_Outcome__c actOut = new Incap311__Activity_Outcome__c (
            Incap311__Activity__c = a.Id, Incap311__Outcome__c = outcome.Id, Incap311__Service_Type_Version_Activity__c = stva.id
        );
        insert actOut;

        // ACTIVITY OUTCOME
        Incap311__Activity_Outcome__c actOut2 = new Incap311__Activity_Outcome__c (
            Incap311__Activity__c = a.Id, Incap311__Outcome__c = outcome.Id, Incap311__Service_Type_Version_Activity__c = stva.id
        );
        insert actOut2;

        // SERVICE ACTIVITY
        Incap311__Service_Activity__c service = new Incap311__Service_Activity__c(
            Incap311__Service_Request__c = c.Id, Incap311__Service_Type_Version_Activity__c = stva.Id,
            Incap311__Status__c = 'Not Started', Incap311__Activity_Outcome__c = actOut.Id,
            Incap311__Allowable_Outcome__c = outcome.Id
        );    
        insert service;
        
        // OUTCOME QUESTIONS
        Incap311__Outcome_Question__c oq = new Incap311__Outcome_Question__c(
            Incap311__Activity_Outcome__c = outcome.Id,Incap311__Service_Type_Version_Activity_Outcome__c = actOut.Id, Incap311__Question__c = q.Id, Incap311__Override_Answer_Values__c = '[{"key":"test1", "value":"a1"}, {"key":"test2", "value": "a2"}]'
        );
        insert oq;

        Incap311__Response__c response = new Incap311__Response__c(name='Test', Incap311__Long_Response_Text__c='test',Incap311__Response_Code__c='test');
        insert response;

        Incap311__Activity_Outcome_Response__c outcomeResponse = new Incap311__Activity_Outcome_Response__c(Incap311__Activity_Outcome__c = actOut.id, Incap311__Canned_Response__c = response.Id);
        insert outcomeResponse;

        Test.startTest();  
        PageReference pageRef = Page.Console311_SR_Activity_Edit;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(service.Id));

        ApexPages.StandardController sc = new ApexPages.StandardController(service);
        Console311_SR_Activity_Edit_Extension srActEditExt = new Console311_SR_Activity_Edit_Extension(sc);

        Console311_SR_Activity_Edit_Extension.ActivityWrapper aW = new Console311_SR_Activity_Edit_Extension.ActivityWrapper();
        aw.serviceQuestions = new List<Console311_SR_Activity_Edit_Extension.ActivityQuestionWrapper>();
        Console311_SR_Activity_Edit_Extension.ActivityQuestionWrapper aqw = new Console311_SR_Activity_Edit_Extension.ActivityQuestionWrapper();
        aqw.mSRTypeVQuestionName = 'q1234';
        aqw.mDataType = 'Text';
        aqw.question =new Incap311__Activity_Question__c();
        aw.serviceQuestions.add(aqw);
        srActEditExt.getOutcomeQuestions();
        srActEditExt.QuestionsJson = JSON.serialize(aw);
        srActEditExt.cannedResponseCode = 'test';
        srActEditExt.selectedCannedResponseID = response.Id;
        srActEditExt.refresh();
        srActEditExt.existingOutcomeAnswers = new List<Incap311__Activity_Question__c>();
        srActEditExt.activeOutcome = outcome.Id;
        srActEditExt.getOutcomeQuestions();
        srActEditExt.mSRActivity.Incap311__Allowable_Outcome__c = outcome.Id;
        srActEditExt.QuestionsJson = JSON.serialize(aw);
        srActEditExt.saveActivity();

        srActEditExt.caseClose();
        srActEditExt.refreshFlexnotesWithAnswers();
        srActEditExt.getOutcomeQuestions();
        srActEditExt.mSRActivity.Incap311__Service_Type_Version_Activity__c =stva.Id;
        srActEditExt.setupOutcomes(srActEditExt.getActivityOutcomeList(a.Id));
        //srActEditExt.reallocateCtrl = new Incap311.Base311_ReallocateController();
        //Group testGroup = new Group(Name='test group', Type='Queue');
		//insert testGroup;
        //srActEditExt.reallocateCtrl.queueid = testGroup.id;
        srActEditExt.reallocateCase();
        srActEditExt.saveActivity();
        srActEditExt.feedAssignToInformationToPage();
        srActEditExt.parseMultipicklist('asdf,;asdf');
        Map<String, String> mapLayers = srActEditExt.mapLayers;
        double testLong = srActEditExt.mapCenterLongitude;
        double testLat =srActEditExt.mapCenterLatitude;

        System.assertEquals('test', srActEditExt.parseMultipicklist('[test]'));

        Console311_Wrap_ActivityQuestionAnswer ooaw = new Console311_Wrap_ActivityQuestionAnswer(oq);
        System.assertEquals(99, ooaw.getQuestionOrderRank());
        ooaw.getPicklistOptions();
        ooaw = new Console311_Wrap_ActivityQuestionAnswer(oq, new Map<String,Object>());
        ooaw = new Console311_Wrap_ActivityQuestionAnswer(oq, new Incap311__Activity_Question__c());
		ooaw.getQuestion();
		ooaw.getQuestionCode();
        ooaw.setAnswer('Test');
        ooaw.getAnswer();
        ooaw.validateValueType();
        
        Test.stopTest();
    }
}