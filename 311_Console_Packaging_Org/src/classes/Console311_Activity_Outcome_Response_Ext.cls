/*
 * Block comments with details of changes
 */
public class Console311_Activity_Outcome_Response_Ext
{
    public String outcomeAction {get;set;}
    public Console311_Activity_Outcome_Response_Ext(ApexPages.StandardController stdController)
    {
        Incap311__Activity_Outcome_Response__c response = (Incap311__Activity_Outcome_Response__c) stdController.getRecord();
        System.debug('dafdasf   '+response.Incap311__Activity_Outcome__c);

        Incap311__Activity_Outcome__c ao =[select Incap311__Outcome__r.Incap311__Outcome_Action__c from Incap311__Activity_Outcome__c where id = :response.Incap311__Activity_Outcome__c];
        outcomeAction = ao.Incap311__Outcome__r.Incap311__Outcome_Action__c;

    }

    public List<SelectOption> getReasons()
    {
        List<SelectOption> options = new List<SelectOption>();

        Schema.DescribeFieldResult fieldResult =
            Case.Reason.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }
}