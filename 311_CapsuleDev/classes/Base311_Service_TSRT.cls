/**
* @author 
* @date 
* @group 
* @group-content
* @description 
*/
public with sharing class Base311_Service_TSRT {

    public List<Incap311__Service_Type__c> getServiceTypes() {
        return [
            SELECT
                Id, Incap311__Service_Name__c
            FROM
                Incap311__Service_Type__c
            ORDER BY
                Incap311__Service_Name__c ASC
        ];
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    public List<Service_Type_Version__c> getActiveTransferVersions(String fromServiceTypeId) {
        return this.getActiveTransferVersions(fromServiceTypeId, false);
    }

    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    public List<Service_Type_Version__c> getActiveTransferVersions(String fromServiceTypeId, Boolean forActivities) {
    
        return [
            SELECT 
                Name, SLA__c, SLA_Type__c, SLA_Detail__c, Service_Location_Required__c, Default_Priority__c, Default_Method__c, Default_Status__c,
                Service_Name__c, Duplicate_Detection_Method__c, Duplicate_Radius_feet__c, Duplicate_Threshold_Period_days__c, 
                Service_Type__r.External_Description__c, Service_Type__r.Contact_Status__c, Incap311__Service_Type__r.Incap311__Service_Description__c, Service_Type__r.Service_Location_Required__c,
                Service_Type__r.Service_Type_Code__c, Contact_Status__c, Service_Type__r.Auto_Close__c, Service_Type__r.Auto_Close_Days__c, 
                Service_Type__r.Is_Bulk_Type__c, Service_Type_Code__c, Keywords__c, Service_Type__r.Incap311__Schedulable_Requests_Limit_Month__c, 
            	Service_Type__r.Schedulable_Requests_Limit_Year__c, Service_Type__r.Schedule_Duplicate_Detection__c, External_Name__c, Group__c,
            	Has_Metadata__c, Resolution_Type__c,
                (
                    SELECT
                        Question__r.Data_Type__c, Question__r.Hint_Text__c, Question__r.Question__c, Question__r.Answer_Values__c, 
                        Order__c, Override_Order__c, Question__c, Is_Read_Only__c, Name, Override_Answer_Values__c,  Is_Required_Question__c,
                        Question__r.Flex_Question_Code__c, Dependencies__c, Validations__c, Is_Controlling__c, Is_Dependent__c
                    FROM
                        Service_Type_Version_Questions__r
                    WHERE
                        (Start_Date__c <= :Date.today() OR Start_Date__c = null) AND
                        (Stop_Date__c >= :Date.today() OR Stop_Date__c = null)
                    ORDER BY
                        Order__c
                ),
                (
                    SELECT
                        SLA_Type__c, SLA__c, Activity__r.Activity_Code__c, 
                        Order__c, Is_Required__c, Task_Description__c
                    FROM
                        Service_Type_Version_Activities__r
                )
            FROM 
                Service_Type_Version__c
            WHERE 
                Service_Type__c IN (SELECT To_Service_Type__c FROM Transfer_Service_Request_Type__c WHERE From_Service_Type__c = :fromServiceTypeId AND For_Activity_Transfer__c = :forActivities) AND
                Is_Current_Version__c = true
            ORDER BY 
                Service_Name__c ASC
        ];
    
    
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    public List<Transfer_Service_Request_Type__c> getTransferTypesForServiceType(String serviceTypeId, Boolean forActivities) {
    return [
            SELECT
                Incap311__To_Service_Type__c, 
                Incap311__To_Service_Type__r.Incap311__Service_Name__c, 
                Incap311__To_Service_Type__r.Incap311__Active_Service_Type_Version__r.Id, 
                Incap311__To_Service_Type__r.Incap311__Active_Service_Type_Version__r.Name, 
                Incap311__To_Service_Type__r.Incap311__Active_Service_Type_Version__r.Incap311__Service_Name__c,
                
                Incap311__From_Service_Type__c, 
                Incap311__From_Service_Type__r.Incap311__Service_Name__c, 
                Incap311__From_Service_Type__r.Incap311__Active_Service_Type_Version__r.Id, 
                Incap311__From_Service_Type__r.Incap311__Active_Service_Type_Version__r.Name, 
                Incap311__From_Service_Type__r.Incap311__Active_Service_Type_Version__r.Incap311__Service_Name__c 
            FROM 
                Transfer_Service_Request_Type__c
            WHERE 
                From_Service_Type__c = :serviceTypeId AND For_Activity_Transfer__c = :forActivities
            ORDER BY
                To_Service_Type__r.Incap311__Service_Name__c ASC
        ];
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    public List<Transfer_Service_Request_Type__c> getTransferTypesForServiceType(String serviceTypeId) {
        return getTransferTypesForServiceType(serviceTypeId, false);
    }
    
}