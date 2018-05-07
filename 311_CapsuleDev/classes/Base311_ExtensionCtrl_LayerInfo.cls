/*********
* @author John Benson   
* @date  4/21/2017
* @group 
* @group-content
* @description 
*/
global with sharing class Base311_ExtensionCtrl_LayerInfo {

     
    private Service_Type_Version__c serviceTypeVersion { get; set; }
    
    public String serviceTypeVersionId { get; set; }
    
    public String jsonLayerInformation { get; set; }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    private Service_Type_Version__c getServiceTypeVersion() {
        if(serviceTypeVersionId != null) {
            List<Service_Type_Version__c> versions = [SELECT Visible_Layers__c FROM Service_Type_Version__c WHERE Id = :serviceTypeVersionId];
            
            if(versions.size() > 0) {
                return versions[0];
            }
        }
        
        return null;
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    public List<Base311_ESRI_Layer> layerInformation { get; set; }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    public List<Base311_ESRI_Layer> getConfiguredLayers() {
        if(layerInformation != NULL) {
            return layerInformation;
        }
        
        if(jsonLayerInformation != NULL) {
            return (List<Base311_ESRI_Layer>) JSON.deserialize(this.jsonLayerInformation, List<Base311_ESRI_Layer>.class);  
        }
        
        return null;
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    public List<Base311_ESRI_Layer> convertedLayers {
        get {
        
            List<Base311_ESRI_Layer> configuredLayers = getConfiguredLayers();
        
            if(configuredLayers == null) {
                return new List<Base311_ESRI_Layer>();
            }
        
            
            Service_Type_Version__c serviceTypeVersion = getServiceTypeVersion();
            
            // if we arent comparing against a service type version, or if we dont have any configuration
            // show everything
            if(serviceTypeVersion == null || String.isEmpty(serviceTypeVersion.Visible_Layers__c)) {
                return configuredLayers ;
            }
            
            List<String> configuredVisibleLayers = serviceTypeVersion.Visible_Layers__c.split(',');
            
            // other wise do the stuff
            List<Base311_ESRI_Layer> finalLayers = new List<Base311_ESRI_Layer>();
            
            for(Base311_ESRI_Layer layer : configuredLayers) {
                if(Base311_Helper.listContains(configuredVisibleLayers, String.valueOf(layer.layerId))) {
                    finalLayers.add(layer);
                }
            }
            
            return finalLayers;
        }
    }

}