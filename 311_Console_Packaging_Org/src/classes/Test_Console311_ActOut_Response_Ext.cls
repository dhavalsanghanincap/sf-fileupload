/*
 * Block comments with details of changes
 */
@isTest public class Test_Console311_ActOut_Response_Ext
{
    @isTest public static void Test_Console311_ActOut_Response_Ext()
    {
        Incap311__Activity__c a = new Incap311__Activity__c(Incap311__Activity_Code__c = '123');
        insert a;  
        
        // OUTCOME
        Incap311__Outcome__c outcome = new Incap311__Outcome__c(
            Incap311__Outcome_Code__c = 'OUT1234', Incap311__Outcome_Detail__c = 'BestOutcomeDetail', Incap311__Outcome_Action__c = 'Close'
        );
        insert outcome;

        // ACTIVITY OUTCOME
        Incap311__Activity_Outcome__c actOut = new Incap311__Activity_Outcome__c (
            Incap311__Activity__c = a.Id, Incap311__Outcome__c = outcome.Id
        );
        insert actOut;

        Incap311__Response__c response = new Incap311__Response__c(name='Test', Incap311__Long_Response_Text__c='test',Incap311__Response_Code__c='test');
        insert response;

        Incap311__Activity_Outcome_Response__c outcomeResponse = new Incap311__Activity_Outcome_Response__c(Incap311__Activity_Outcome__c = actOut.id, Incap311__Canned_Response__c = response.Id);
        insert outcomeResponse;

        PageReference pageRef = Page.Console311_Activity_Outcome_Response;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(outcomeResponse.Id));

        ApexPages.StandardController sc = new ApexPages.StandardController(outcomeResponse);
        Console311_Activity_Outcome_Response_Ext srActEditExt = new Console311_Activity_Outcome_Response_Ext(sc);
        srActEditExt.getReasons();
    }
}