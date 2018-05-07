@isTest
public class Test_Base311_QuestionAnswer {

    @isTest
    static void testConvertValueToNumber() {
        Base311_QuestionAnswer rqa = new Base311_QuestionAnswer('a', '1');
        Object val = rqa.convertValueTo('Number');
        System.assertEquals(val, 1);
    }
    
    @isTest
    static void testConvertValueToBoolean() {
        Base311_QuestionAnswer rqa = new Base311_QuestionAnswer('a', 'true');
        Object val = rqa.convertValueTo('Boolean (checkbox)');
        System.assertEquals(val, true);
    }
    
    @isTest
    static void testConvertValueToDatetime() {
        Datetime testdt = System.now();
        Base311_QuestionAnswer rqa = new Base311_QuestionAnswer('a', Base311_Helper.formatDate(testdt));
        Object val = rqa.convertValueTo('Date/Time');
        System.assertEquals(val, testdt);
    }
    
    @isTest
    static void testGeneral() {
        Base311_QuestionAnswer qa = new Base311_QuestionAnswer('key', 'value', true);
        qa.img = 'https://www.google.com';

        Case c = Test_RestTestHelper.serviceRequest();
        Service_Type_Version__c stv = Test_RestTestHelper.sericeTypeVersionAndVersion();
        Question__c q = Test_RestTestHelper.question();

        Service_Type_Version_Question__c stvq = Test_RestTestHelper.serviceTypeVersionQuestion(q.Id, stv.Id);

        Service_Question__c sq1 = Test_RestTestHelper.serviceQuestion(c.Id, stvq.Id);
        Service_Question__c sq2 = Test_RestTestHelper.serviceQuestion(c.Id, stvq.Id);
        Service_Question__c sq3 = Test_RestTestHelper.serviceQuestion(c.Id, stvq.Id);
        Service_Question__c sq4 = Test_RestTestHelper.serviceQuestion(c.Id, stvq.Id);

        sq1 = [Select Id, Service_Request__c, Answer__c, Service_Type_Version_Question__c, Service_Type_Version_Question__r.Name, Service_Type_Version_Question__r.Question__c, Service_Type_Version_Question__r.Override_Answer_Values__c From Service_Question__c Where Id = :sq1.Id];

        Base311_QuestionAnswer.fromSTVQ(stvq);
        Base311_QuestionAnswer.fromSTVQ(stvq, new List<Service_Question__c>{sq1});

        Base311_QuestionAnswer.fromJSON('[{"key": "Test", "value": "123", "isSelected": false, "img": ""}, {"key": "Yo", "value": "321", "isSelected": false, "img": ""}]');
    }
}