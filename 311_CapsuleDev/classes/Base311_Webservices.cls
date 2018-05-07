/**
* @author 
* @date 
* @group 
* @group-content
* @description 
*/
global class Base311_Webservices {
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    @AuraEnabled
    webservice static String markSTVAsActive(String stvId) {
        
        try {
            Service_Type_Version__c stv = [
                SELECT 
                    Version_Number__c, Is_Old_Version__c, Is_Current_Version__c, Service_Type__r.Name, Is_Activatable__c
                FROM
                    Service_Type_Version__c
                WHERE
                	Id = :stvId
            ];
            
            if(stv.Is_Current_Version__c) {
                return 'Cannot make the current active version active';
            }
            
            if(!stv.Is_Activatable__c) {
                return 'Only Service Type Versions that are not marked as draft, and have valid Start / Stop date ranges can be activated.';
            }
            
            stv.Service_Type__r.Active_Service_Type_Version__c = stv.Id;
            update stv.Service_Type__r;
            
            Base311_UpdateOpenCaseActivities.schedule(stv.Service_Type__r);
            
            return 'Version has been marked as active. Associated Service Activties are scheduled for updates';
            
        } catch (Exception e) { }
        
        return null;
    } 
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    webservice static String cloneServiceTypeVersion(String stvId) {
        try {
            Service_Type_Version__c stv = Base311_Helper.getCompleteServiceTypeVersion(stvId);
            Service_Type_Version__c clonedSTV = stv.clone();
            //clonedSTV.Version_Number__c = stv.Version_Number__c == null ? 1 : (stv.Version_Number__c + 1);
            clonedSTV.Version_Number__c = Base311_Helper.getNextUnusedVersionNumber(stvId);
            clonedSTV.Is_Draft__c = true;
            insert clonedSTV;
            
            List<Service_Type_Version_Question__c> clonedQuestions = new List<Service_Type_Version_Question__c>();
            
            for(Service_Type_Version_Question__c stvq : clonedSTV.Service_Type_Version_Questions__r) {
                Service_Type_Version_Question__c cloned = stvq.clone();
                cloned.Service_Type_Version__c = clonedSTV.Id;
                clonedQuestions.add(cloned);
            }
            
            insert clonedQuestions;
            
            List<Service_Type_Version_Activity__c> clonedActivities = new List<Service_Type_Version_Activity__c>();
            
            for(Service_Type_Version_Activity__c stva : clonedSTV.Service_Type_Version_Activities__r) {
                Service_Type_Version_Activity__c cloned = stva.clone();
                cloned.Service_Type_Version__c = clonedSTV.Id;
                clonedActivities.add(cloned);
            }
            
            insert clonedActivities;
            
            return new PageReference('/' + clonedSTV.Id).getUrl();   
        }
        catch (Exception e) {
            return null;
        }
    }
    
}