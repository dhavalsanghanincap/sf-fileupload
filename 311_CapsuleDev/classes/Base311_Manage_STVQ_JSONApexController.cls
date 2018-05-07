/**
* @author 
* @date 
* @group 
* @group-content
* @description 
*/
public class Base311_Manage_STVQ_JSONApexController {

    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    @AuraEnabled
    public static Service_Type_Version_Question__c getSTVQ(Id id) {
        return [
          SELECT
            Id, Service_Type_Version__c
          FROM
            Service_Type_Version_Question__c
          WHERE
            Id = : id
        ];
    }
    
}