@istest
public class Test_Console311_Wrap_ActivityQuestionA {
    @istest
    public static void testThis(){
        Console311_Wrap_ActivityQuestionAnswer aqa = new Console311_Wrap_ActivityQuestionAnswer();
        System.assertequals(aqa.getCurrentAnswer(),null);
        System.assertequals(aqa.getQuestionOrderRank(),99);
    }
    
    @istest
    public static void testWithData(){
        incap311__Outcome__c o = incap311.Test_RestTestHelper.outcome();
        incap311__Activity__c a = incap311.Test_RestTestHelper.activity();
        incap311__Service_Type_Version__c stv = incap311.Test_RestTestHelper.sericeTypeVersionAndVersion();
        incap311__Service_Type_Version_Activity__c stva = incap311.Test_RestTestHelper.serviceTypeVersionActivity(a.Id, stv.Id);
        incap311__Activity_Outcome__c ao = new incap311__Activity_Outcome__c(incap311__Outcome__c = o.Id, incap311__Activity__c = a.Id, incap311__Service_Type_Version_Activity__c = stva.Id); 
        insert ao;
        incap311__Question__c q = incap311.Test_RestTestHelper.question();
         
        incap311__Outcome_Question__c oq = new incap311__Outcome_Question__c(incap311__Activity_Outcome__c = o.Id, incap311__Question__c = q.Id, incap311__Service_Type_Version_Activity_Outcome__c = ao.Id,Incap311__Override_Order__c = 1);
        incap311__Outcome_Question__c oq2 = new incap311__Outcome_Question__c(incap311__Activity_Outcome__c = o.Id, incap311__Question__c = q.Id, incap311__Service_Type_Version_Activity_Outcome__c = ao.Id);        
        oq.incap311__Dependencies__c = '{ "clause": "OR", "conditions":[{"left":"OutcomeQuestionCode[ABC].Incap311__Answer__c","op":"eq","right":1}]}';
        oq2.incap311__Dependencies__c = '{ "clause": "OR", "conditions":[{"left":"OutcomeQuestionCode[ABC].Incap311__Answer__c","op":"eq","right":2}]}';
        insert oq;
        insert oq2;
        Map<String,Object> qAMap = new Map<String,Object>();
        qAMap.put(oq.Incap311__Question_Code__c, 'Test');
        Console311_Wrap_ActivityQuestionAnswer aqa = new Console311_Wrap_ActivityQuestionAnswer(oq,qAMap);
       System.assertequals(aqa.getCurrentAnswer(),'Test');
       System.assertequals(aqa.getQuestionOrderRank(),1);
        System.assertequals(aqa.getQuestion().id,oq.id);
        aqa.setAnswer('Test2');
        System.assertequals(aqa.getCurrentAnswer(),'Test');
        System.assertequals(aqa.getAnswer(),'Test2');
        System.assert(aqa.validateValueType());
        aqa.setAnswer(null);
		System.assert(aqa.validateValueType());
        
        try{aqa.validateValueType('Number');}
        catch(Exception e){
            
        }

        try{aqa.validateValueType('Boolean (checkbox)');}
        catch(Exception e){
            
        }
        try{aqa.validateValueType('MultiPicklist');}
        catch(Exception e){
            
        }
         try{aqa.validateValueType('Date');}
        catch(Exception e){
            
        }
        
    }
}