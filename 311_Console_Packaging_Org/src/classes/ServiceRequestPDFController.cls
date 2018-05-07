public class ServiceRequestPDFController {
    public String myRecordId {get;set;}
    public final Case curCase;
    public final List<CaseHistory> caseHis;
    public final List<Incap311__Service_Question__c> curNotes;
    public final List<Incap311__Activity_Question__c> actQues;
    
    public String getServiceRequestPDF(){
        System.debug('myRecordId: ' +myRecordId);
        return (new PageReference('/apex/ServiceRequestPDF?Id=' + myRecordId 
                                 ).getContent().toString());
    }
    
    public ServiceRequestPDFController(){
        String pageCaseId = ApexPages.currentPage().getParameters().get('Id');
        try{
            if(pageCaseId != null){
                curCase = [Select  Id,
                           Origin,
                           Description,
                           Incap311__Service_Request_Number__c,
                           Incap311__Service_Type_Version__r.Incap311__Service_Name__c,
                           Incap311__Service_Type_Version__r.Incap311__Version_Code__c,
                           Status,
                           CreatedDate,
                           CreatedBy.Name,
                           CreatedBy.Email,
                           Incap311__Location_Details__c,
                           Incap311__X_Coordinate__c,
                           Incap311__Y_Coordinate__c,
                           Contact.FirstName,
                           Contact.LastName,
                           Contact.Email,
                           Contact.Phone,
                           Incap311__Address__c,
                           Incap311__Neighborhood__c,
                           Priority,
                           Incap311__Expected_Date_Time__c From Case Where Id = :pageCaseId];
                
                caseHis = [Select OldValue, NewValue, Field, CreatedDate, CreatedBy.Name,
                           CreatedBy.FirstName, CreatedBy.LastName
                           From CaseHistory Where CaseId =:curCase.Id ORDER BY CreatedDate DESC];
                
                curNotes = [Select Id, Name, Incap311__Service_Request__c, 
                            Incap311__Answer__c, Incap311__Question__c 
                            From Incap311__Service_Question__c Where Incap311__Service_Request__c =:curCase.Id];
                
                actQues = [Select Id, Incap311__Answer__c,Incap311__Service_Request__r.Id, 
                           Incap311__Order__c , Incap311__Service_Activity__r.Activity__c, 
                           Incap311__Outcome_Question__r.Incap311__Question__r.Incap311__Question__c
                           From Incap311__Activity_Question__c
                           Where Incap311__Service_Request__r.Id =:curCase.Id
                           ORDER By Incap311__Order__c ASC NULLS LAST];
               
            } 
        }catch (QueryException e){
            
        }
    }
    public Case getCase(){
        return curCase;
    }
    
    public List<CaseHistory> getCaseHistory(){
        return caseHis;
    }
    
    public List<Incap311__Service_Question__c> getNotes(){
        return curNotes;
    }
    
    public List<Incap311__Activity_Question__c> getActQues(){
        return actQues;
    }
}