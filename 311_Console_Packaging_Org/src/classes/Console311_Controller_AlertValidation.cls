/**
* @author John Benson
* @date 4/28/2017   
* @group 
* @group-content
* @description Component controller for validations (both inline and alert,
* despite the name)
*/
public with sharing class Console311_Controller_AlertValidation {

    public Incap311__Service_Type_Version__c mServiceTypeVersion { get; set; }
    public Object mContext { get; set; }
    public Object mAddress { get; set; }
    public List<Object> mAddressLayers { get; set; }
      
  /**
   * getAlertValidationMessage
   *
   * Gets the current validations message based on the service type and context; 
   * if this function returns null; no validation messages are active.
   * @author John Benson
   * @return List<Incap311.Base311_DependentValue> the validations that should be shown
   */
    public List<Incap311.Base311_DependentValue> getGeoValidationMessage() { 
        if(mServiceTypeVersion == null) {
            return new List<Incap311.Base311_DependentValue>();
        }
        
        mAddress = mAddress == null ? new Map<String, Object>() : mAddress;
        mAddressLayers = mAddressLayers == null ? new List<Object>() : mAddressLayers;
        
        Incap311.Base311_Condition_Evaluator evaluator = Incap311.Base311_Condition_Evaluator.factory(
            new Map<String, Object>{
                'Address' => mAddress,
                'AddressLayer' => mAddressLayers
            }
        );
         
        List<Incap311.Base311_DependentValue> result = evaluator.resolveAll(Incap311.Base311_DependentValue.fromJSON(mServiceTypeVersion.Incap311__Geo_Validations__c));
  
        return result == null ? new List<Incap311.Base311_DependentValue>() : result;
    }
    
  /**
   * getAlertValidationMessage
   *
   * Gets the current validations message based on the service type and context; 
   * if this function returns null; no validation messages are active.
   * @author John Benson
   * @return List<Incap311.Base311_DependentValue> the validations that should be shown
   */
    public List<Incap311.Base311_DependentValue> getInlineValidationMessage() {
        if(mContext == null || mServiceTypeVersion == null || !(mContext instanceof Map<String, Object>)) {
            return new List<Incap311.Base311_DependentValue>();
        }
        
        Incap311.Base311_Condition_Evaluator evaluator = new Incap311.Base311_Condition_Evaluator((Map<String, Object>) mContext);
        
        List<Incap311.Base311_DependentValue> result = evaluator.resolveAll(Incap311.Base311_DependentValue.fromJSON(mServiceTypeVersion.Incap311__Validations__c));
        
        return result == null ? new List<Incap311.Base311_DependentValue>() : result;
    }
    
  /**
   * getAlertValidationMessage
   *
   * Gets the current validations message based on the service type and context; 
   * if this function returns null; no validation messages are active.
   * @author John Benson
   * @return List<Incap311.Base311_DependentValue> list of validation messages to show
   */
    public List<Incap311.Base311_DependentValue> getAlertValidationMessage() {
        if(mContext == null || mServiceTypeVersion == null || !(mContext instanceof Map<String, Object>)) {
            return null;
        }
        
        Incap311.Base311_Condition_Evaluator evaluator = new Incap311.Base311_Condition_Evaluator((Map<String, Object>) mContext); 
        
        List<Incap311.Base311_DependentValue> result = evaluator.resolveAll(Incap311.Base311_DependentValue.fromJSON(mServiceTypeVersion.Incap311__Alert_Validations__c));
        
        return result == null ? new List<Incap311.Base311_DependentValue>() : result;
    }
}