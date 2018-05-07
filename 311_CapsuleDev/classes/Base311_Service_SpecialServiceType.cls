/**
* @author 
* @date 
* @group 
* @group-content
* @description 
*/
global without sharing class Base311_Service_SpecialServiceType {

  private Base311_Service_ServiceType rsst;

  global Base311_Service_SpecialServiceType() {
    rsst = new Base311_Service_ServiceType();
  }

  /**
  * @description 
  * @param 
  * @param 
  * @return 
  * @example
  */
  global List<Special_Service_Type__mdt> getSpecialServiceTypes() {
    return [
      SELECT
        MasterLabel, Incap311__Color__c, Incap311__Related_Service_Type_Code__c
      FROM 
        Special_Service_Type__mdt
    ];
  }

  /**
  * @description 
  * @param 
  * @param 
  * @return 
  * @example
  */
  global Special_Service_Type__mdt getSpecialServiceType(String typeLabel) {
    return [
      SELECT
        MasterLabel, Incap311__Color__c, Incap311__Related_Service_Type_Code__c
      FROM 
        Special_Service_Type__mdt
      WHERE 
        MasterLabel = :typeLabel
    ]; 
  }
  
  /**
  * @description 
  * @param 
  * @param 
  * @return 
  * @example
  */
  global Service_Type_Version__c getSpecialServiceTypeRelatedTypeVersion(String serviceCode) {
    String decodedServiceName = EncodingUtil.urlDecode(serviceCode, 'UTF-8');

    List<Service_Type_Version__c> stvList = [
      SELECT
        Name
      FROM
        Service_Type_Version__c
      WHERE
        Service_Type__r.Service_Type_Code__c = :decodedServiceName AND
        Is_Current_Version__c = true
    ];
    Service_Type_Version__c stv = (stvList.size() > 0 ? stvList[0] : null);
    return rsst.getServiceType(stv.Name, true);
  }
}