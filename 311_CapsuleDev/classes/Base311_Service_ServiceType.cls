/**
* @author 
* @date 
* @group 
* @group-content
* @description 
*/
global without sharing class Base311_Service_ServiceType { 
    

    private static List<String> BASE_ST_FIELDS = new List<String>{ 
    
    };
    
    private static final List<String> BASE_STV_FIELDS = new List<String> {
        'Name', 'Incap311__SLA__c', 'Incap311__Layer_Information__c', 'Incap311__SLA_Type__c', 'Incap311__Keywords__c', 'Incap311__SLA_Detail__c', 'Incap311__Service_Location_Required__c',
        'Incap311__Default_Priority__c', 'Incap311__Default_Method__c', 'Incap311__Default_Status__c', 'Incap311__Duplicate_Threshold_Period_days__c',
        'Incap311__Service_Name__c', 'Incap311__Duplicate_Detection_Method__c', 'Incap311__Duplicate_Radius_feet__c', 'Incap311__Enable_Operational_SLA__c',
        'Incap311__Service_Type__r.Incap311__External_Description__c', 'Incap311__Service_Type__r.Incap311__Contact_Status__c', 'Incap311__Service_Type__r.Incap311__Schedule_Matching__c',
        'Incap311__Service_Type__r.Incap311__Service_Location_Required__c', 'Incap311__Service_Type__r.Incap311__Service_Type_Code__c', 'Incap311__Contact_Status__c',
        'Incap311__Service_Type__r.Incap311__Auto_Close__c', 'Incap311__Service_Type__r.Incap311__Auto_Close_Days__c','Incap311__Allow_Citizen_Web_Intake__c',
        'Incap311__Service_Type__r.Incap311__Is_Bulk_Type__c', 'Incap311__Service_Type__r.Incap311__Service_Description__c', 'Incap311__Service_Type_Code__c', 'Incap311__Days_Of_Week__c', 'Incap311__Enable_Business_Hours__c',
        'Incap311__Service_Type__r.Incap311__Schedulable_Requests_Limit_Month__c', 'Incap311__Service_Type__r.Incap311__Schedulable_Requests_Limit_Year__c', 'Incap311__Service_Type__r.Incap311__Schedule_Duplicate_Detection__c',
        'Incap311__External_Name__c', 'Incap311__Service_Type__r.Incap311__Schedule_After_Days__c', 'Incap311__Service_Type__r.Incap311__Schedule_Type__c',
        'Incap311__Map_Marker_Icon__c', 'Incap311__Hide_Contact__c', 'Incap311__Hide_Location__c', 'Incap311__Service_Icon__c', 'Incap311__Recommended_Types__c',
        'Incap311__Service_Type__r.Incap311__Enable_Scheduling_Hours__c', 'Incap311__Duplicate_Statuses__c', 'Incap311__Duplicate_Match_Street__c',
        'Incap311__Version_Code__c', 'Incap311__Group__c', 'Incap311__Has_Metadata__c', 'Incap311__Resolution_Type__c', 'Incap311__Generate_All_Questions__c',
        'Incap311__Enable_Sub_Units__c', 'Incap311__Validations__c', 'Incap311__Alert_Validations__c'
    };
    
    private static final List<String> BASE_STVQ_FIELDS = new List<String>{    
        'Incap311__Question__r.Incap311__Data_Type__c', 'Incap311__Question__r.Incap311__Hint_Text__c', 'Incap311__Question__r.Incap311__Question__c',
        'Incap311__Order__c', 'Incap311__Override_Order__c', 'Incap311__Question__c', 'Incap311__Is_Read_Only__c', 'Name', 'Incap311__Override_Answer_Values__c',
        'Incap311__Question__r.Incap311__Flex_Question_Code__c', 'Incap311__Dependencies__c', 'Incap311__Validations__c', 'Incap311__Is_Controlling__c',
        'Incap311__Data_Type__c', 'Incap311__Question_Text__c', 'Incap311__Question__r.Incap311__Answer_Values__c', 'Incap311__Is_Dependent__c',
        'Incap311__Is_Required_Question__c'
    };
        
    private static final List<String> BASE_STVA_FIELDS = new List<String>{
        'Incap311__SLA_Type__c', 'Incap311__SLA__c', 'Incap311__Activity__r.Incap311__Activity_Code__c',
        'Incap311__Order__c', 'Incap311__Is_Required__c', 'Incap311__Task_Description__c', 'Incap311__Optional__c',
        'Incap311__Activity__r.Incap311__Activity_Name__c', 'Incap311__Next_Activity__c'
    };
    
    /**
  * @description 
  * @param 
  * @param 
  * @return 
  * @example
  */    
    private String buildQuery(String stvClause, String stvqClause, String stvaClause) {
        if(!Base311_Security.areAccessible(Service_Type_Version__c.SObjectType, BASE_STV_FIELDS)) {
            throw new Base311_Exceptions.SecurityException('User does not have access to Service Type Versions');
        }      
        
        if(!Base311_Security.areAccessible(Service_Type__c.SObjectType, Base311_Helper.getRelatedFields(BASE_STV_FIELDS, 'Incap311__Service_Type__r'))) {
            throw new Base311_Exceptions.SecurityException('User does not have access to Service Types');
        }
        
        if(stvqClause != null && !Base311_Security.areAccessible(Service_Type_Version_Question__c.SObjectType, BASE_STVQ_FIELDS)) {
            throw new Base311_Exceptions.SecurityException('User does not have access to Service Type Version Questions');
        }     
        
        if(stvqClause != null && !Base311_Security.areAccessible(Service_Type__c.SObjectType, Base311_Helper.getRelatedFields(BASE_STV_FIELDS, 'Incap311__Question__r'))) {
            throw new Base311_Exceptions.SecurityException('User does not have access to Flex Questions');
        }
          
        if(stvaClause != null && !Base311_Security.areAccessible(Service_Type_Version_Activity__c.SObjectType, BASE_STVA_FIELDS)) {
            throw new Base311_Exceptions.SecurityException('User does not have access to Service Type Version Activities');
        }

        if(stvaClause != null && !Base311_Security.areAccessible(Activity__c.SObjectType, Base311_Helper.getRelatedFields(BASE_STVA_FIELDS, 'Incap311__Activity__r'))) {
            throw new Base311_Exceptions.SecurityException('User does not have access to Activities');
        }        
        
        String query = 'SELECT ' + String.join(BASE_STV_FIELDS, ',');
        
        if(stvqClause != null) {
            query += ',(SELECT ' + String.join(BASE_STVQ_FIELDS, ',') + ' FROM Incap311__Service_Type_Version_Questions__r  ' + stvqClause + ')';
        }
        
        if(stvaClause != null) {
            query += ',(SELECT ' + String.join(BASE_STVA_FIELDS, ',') + ' FROM Incap311__Service_Type_Version_Activities__r  '  + stvaClause + ')';
        }
        
        query += ' FROM Incap311__Service_Type_Version__c ' + stvClause;
        
        return query;
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global Service_Type_Version__c getActiveServiceType(String serviceTypeCode, Boolean showAll) {
         
        String decodedServiceName = EncodingUtil.urlDecode(serviceTypeCode, 'UTF-8');
        
        String currentDOW = Base311_Helper.currentDayOfWeek();
        
        Boolean notShowAll = !showAll;
        
        String stvClause = 'WHERE ' +
            'Service_Type_Code__c = :decodedServiceName AND ' +
            '(Allow_Citizen_Web_Intake__c = :notShowAll OR Allow_Citizen_Web_Intake__c = true) AND ' +
            'Is_Current_Version__c = true AND ' +
            '(Days_Of_Week__c = NULL OR Days_Of_Week__c INCLUDES (:currentDOW)) ' +
            'ORDER BY CreatedDate';
        
        String stvqClause = 'WHERE Citizen_Web_Intake__c = :notShowAll OR Citizen_Web_Intake__c = true ORDER BY Order__c ASC';
        
        String stvaClause = ''; 
        
        String query = buildQuery(stvClause, stvqClause, stvaClause);
        System.debug(query);
        
        List<Service_Type_Version__c> stvs = Database.query(String.escapeSingleQuotes(query));
        
        Service_Type_Version__c stv = (stvs.size() > 0 ? stvs[0] : null);
        
        return stv;
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global List<Duplicate_Service_Type_Mapping__c> getDuplicateMappings(Id fromId) {
        return [
            SELECT
                From_Service_Type_Version__c, To_Service_Type__c, To_Service_Type__r.Service_Type_Code__c,
                To_Service_Type__r.Active_Service_Type_Version__c
            FROM
                Duplicate_Service_Type_Mapping__c
            WHERE
                From_Service_Type_Version__c = :fromId
        ];
    }
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global Service_Type_Version__c getServiceType(String serviceCode) {
        return getServiceType(serviceCode, false);
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global Service_Type_Version__c getServiceType(String serviceCode, Boolean showAll) {
        
        Boolean notShowAll = !showAll;
        
        String decodedServiceName = EncodingUtil.urlDecode(serviceCode, 'UTF-8');
        
        String stvClause = 'WHERE ' +
            'Name = :decodedServiceName AND ' +
            '(Allow_Citizen_Web_Intake__c = :notShowAll OR Allow_Citizen_Web_Intake__c = true)';
        
        String stvqClause = 'WHERE Citizen_Web_Intake__c = :notShowAll OR Citizen_Web_Intake__c = true ORDER BY Order__c ASC';
        
        String stvaClause = ''; 
        
        String query = buildQuery(stvClause, stvqClause, stvaClause);
        
        List<Service_Type_Version__c> stvs = Database.query(String.escapeSingleQuotes(query));
        
        Service_Type_Version__c stv = (stvs.size() > 0 ? stvs[0] : null);
        
        return stv;
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global Service_Type_Version__c getVersionById(Id versionId) {
        
        String query = buildQuery('WHERE Id = :versionId', '', '');
        List<Service_Type_Version__c> versions = Database.query(String.escapeSingleQuotes(query));
        
        if(versions.size() == 1) {
            return versions[0];
        }
        
        throw new Base311_Exceptions.ServerException('Got none or multiple service types for a single ID');
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global List<Service_Type_Version__c> getActiveServiceTypes() {
        return getActiveServiceTypes(false);
    }

    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global List<Service_Type__c> getBaseServiceTypes() {
        return [
            SELECT
                Id, Active_Service_Type_Version__c, Active_Service_Type_Version__r.Is_Activatable__c, Service_Type_Code__c,
                (
                    SELECT 
                        Id, Is_Activatable__c, Start_Date__c, Stop_Date__c, Service_Type__r.Active_Service_Type_Version__c
                    FROM 
                        Service_Type_Versions__r
                    ORDER BY
                        Version_Number__c DESC
                )
            FROM
                Service_Type__c
        ];
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global List<Service_Type_Version__c> getActiveServiceTypes(Boolean showAll) {
        Boolean notShowAll = !showAll;
        
        String currentDOW = Base311_Helper.currentDayOfWeek();
        
        String stvClause = 'WHERE ' +
            'Is_Current_Version__c = true AND ' +
            '(Allow_Citizen_Web_Intake__c = :notShowAll OR Allow_Citizen_Web_Intake__c = true) AND ' +
            'Service_Type__r.System_Generated__c = false AND ' + 
            '(Days_Of_Week__c = NULL OR Days_Of_Week__c INCLUDES (:currentDOW)) ' +
            'ORDER BY Service_Name__c ASC NULLS LAST';
        
                
        String query = buildQuery(stvClause, null, '');
        
        List<Service_Type_Version__c> versions = Database.query(String.escapeSingleQuotes(query));
         
        // filter for business hours
        versions = Base311_Helper.filterTypesByBusinessHours(versions);
        
        return versions;
    }
}