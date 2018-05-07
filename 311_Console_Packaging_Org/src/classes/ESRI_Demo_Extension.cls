public class ESRI_Demo_Extension {
    Case currentCase;

    public ESRI_Demo_Extension(ApexPages.StandardController ctrl) {
        this.currentCase = [
            SELECT Id, Incap311__Service_Type_Version__c, Incap311__Service_Type_Version__r.Name,
            Incap311__Location__Latitude__s, Incap311__Location__Longitude__s
            FROM Case 
            WHERE Id = :ctrl.getId() 
        ];
    }
    
    public String getSimilarServiceRequests() {
        return JSON.serialize([
            SELECT 
                Incap311__Location__Latitude__s, Incap311__Location__Longitude__s, Description, Subject,
                CaseNumber
            FROM 
                Case 
            WHERE 
                Incap311__Service_Type_Version__c = :currentCase.Incap311__Service_Type_Version__c AND
                Incap311__Location__Latitude__s != NULL AND 
                CreatedDate = LAST_N_DAYS:60 AND
                Id != :currentCase.Id
            LIMIT 10
        ]);
    }
    
    public String  getDuplicateServiceRequests() {
        List<Case> dupes = Incap311.Base311_DuplicateRequestsUtil.getDuplicateServiceRequests(
            null, currentCase.Incap311__Service_Type_Version__r.Name, 
            String.valueOf(currentCase.Incap311__Location__Longitude__s),
            String.valueOf(currentCase.Incap311__Location__Latitude__s)
        );
        
        List<Id> ids = new List<Id>();
        
        for(Case c : dupes) {
            ids.add(c.Id);
        }
        
        return JSON.serialize([SELECT 
                Incap311__Location__Latitude__s, Incap311__Location__Longitude__s, Description, Subject,
                CaseNumber
            FROM 
                Case 
            WHERE 
                Id IN :ids AND
                Id != :currentCase.Id  
        ]);
    } 
}