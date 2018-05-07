@isTest
public class Test_Base311_DependentPicklist
{
    static testMethod void Test_Base311_DependentPicklist()
    {
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

        List<Base311_DependentPicklist> answers2 = Base311_DependentPicklist.fromJSON(JSON.serialize(answers));

        //System.assert(answers2.values.size() == 0);
    }
}