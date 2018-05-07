public with sharing class Console311_Controller_Recommendations {
    public Incap311__Service_Type_Version__c mVersion { get; set; }
    public Object mContext { get; set; }
    public static Incap311.Base311_Service_ServiceType sst = new Incap311.Base311_Service_ServiceType();
    public static final List<Incap311__Service_Type_Version__c> existingVersions = sst.getActiveServiceTypesWithoutActivities(true);
    
    public Incap311__Service_Type_Version__c findVersion (String code) {
        for(Incap311__Service_Type_Version__c version : existingVersions) {
            if(version.Incap311__Service_Type_Code__c == code) {
                return version;
            }
        }
        
        return null;
    }
    
    
    public List<Incap311__Service_Type_Version__c> getRecommendations() {
        if(mVersion == null || mContext == null || !(mContext instanceof Map<String, Object>)) {
            return new List<Incap311__Service_Type_Version__c>();
        }
    
        Incap311.Base311_Condition_Evaluator evaluator = new Incap311.Base311_Condition_Evaluator((Map<String, Object>) mContext);
        
        List<Incap311.Base311_DependentValue> values = evaluator.resolveAll(Incap311.Base311_DependentValue.fromJSON(mVersion.Incap311__Recommended_Types__c));
        
        Set<Incap311__Service_Type_Version__c> result = new Set<Incap311__Service_Type_Version__c>();
        
        for(Incap311.Base311_DependentValue value : values) {
            List<Object> stvValues = (List<Object>) value.values;
            
            for(Object code : stvValues) {
                Incap311__Service_Type_Version__c ver = findVersion((String) code);
                
                if(ver != null) {
                    result.add(ver);
                }
            }
        }
        
        
        return new List<Incap311__Service_Type_Version__c>(result);
    }
    
    
}