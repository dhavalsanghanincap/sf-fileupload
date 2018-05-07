public with sharing class Base311_Activity_Correspondence_Ext
{
    final private Activity_Correspondence__c actCorr;
    public List<SelectOption> AllOutcomes{get;set;}
    public List<SelectOption> SelectedOutcomes{get;set;}
    private ApexPages.StandardController ctrl { get; set; }

    public Base311_Activity_Correspondence_Ext(ApexPages.StandardController stdController)
    {
        
        list<String> addFields = new list<String>();
        addFields.add('Activity_Outcome__c');
        if(!Test.isRunningTest()){
        	stdcontroller.addFields(addFields);
        }
        this.actCorr = (Activity_Correspondence__c)stdController.getRecord();
        ctrl = stdController;
        AllOutcomes = new  List<SelectOption>();
        SelectedOutcomes = new  List<SelectOption>();    
        for(Activity_Outcome__c ao : [select Outcome_Code__c,Outcome_Detail__c from Activity_Outcome__c where Service_Type_Version_Activity__c = :actCorr.Service_Type_Version_Activity__c ]){
            if(ao.Outcome_Code__c != null && ao.Outcome_Detail__c != null){
                if(actCorr.Activity_Outcome__c != null && actCorr.Activity_Outcome__c.contains(ao.Outcome_Code__c)){
                    SelectedOutcomes.add(new SelectOption(ao.Outcome_Code__c,ao.Outcome_Detail__c));
                }else{
                    AllOutcomes.add(new SelectOption(ao.Outcome_Code__c,ao.Outcome_Detail__c));
                }
            }

        }

    }

    public PageReference refresh(){
        return null;
    }

    public PageReference save() {
        actCorr.Activity_Outcome__c = '';
        if(actCorr.Incap311__Type__c == 'Complete'){
            for(SelectOption so: SelectedOutcomes){
                actCorr.Activity_Outcome__c += so.getValue()+';';
            }
        }
        upsert actCorr;


        return ctrl.save();
    }

}