/**
* @author 
* @date 
* @group 
* @group-content
* @description 
*/
global without sharing class Base311_ServiceTypeVersionHelper {


    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    /*
     *  Ensures that the service type version does not have a version identical to another for the same service type
     */
    public static void verifyUniqueVersionNumber(List<Service_Type_Version__c> stVersions) {
        Set<Id> svcTypeIds = new Set<Id>();
        for (Service_Type_Version__c newVer : stVersions) {
            svcTypeIds.add(newVer.Service_Type__c);
        }

        List<Service_Type_Version__c> existingVers = [SELECT Id, Version_Number__c, Service_Type__c FROM Service_Type_Version__c WHERE Service_Type__c = :svcTypeIds];

        // map versions by service type
        Map<String, List<Service_Type_Version__c>> versionMap = new Map<String, List<Service_Type_Version__c>>();
        for (Service_Type_Version__c stv : existingVers) {
            if (!versionMap.containsKey(stv.Service_Type__c)) {
                List<Service_Type_Version__c> newList = new List<Service_Type_Version__c>();
                newList.add(stv);
                versionMap.put(stv.Service_Type__c, newList);
            }
            else {
                versionMap.get(stv.Service_Type__c).add(stv);
            }
        }

        // loop through and if a version is found with an identical number, add error to record and continue loop
        for (Service_Type_Version__c newVer : stVersions) {
            if ((newVer.Service_Type__c != null) && (versionMap.containsKey(newVer.Service_Type__c))) {
                // get the version list for this service type
                List<Service_Type_Version__c> chkVers = versionMap.get(newVer.Service_Type__c);
                for (Service_Type_Version__c chkVer : chkVers) {
                    if ((newVer.Id == null) || ((newVer.Id != null) && (newVer.Id != chkVer.Id))) {
                        if ((String.isNotBlank(String.valueOf(newVer.Version_Number__c))) && (newVer.Version_Number__c == chkVer.Version_Number__c)) {
                            newVer.addError('You cannot create/update the Service Type Version for this service type with an identical Version Number.  Please apply a unique Version Number.');
                            continue;
                        }
                    }
                }
            }
        }
    }

    /*
     *  Ensures that the service type version does not have a service name identical to an active version for a differing service type (can have identical for same service type)
     */
    public static void verifyUniqueServiceName(List<Service_Type_Version__c> stVersions) {
        // get all active versions
        List<Service_Type_Version__c> existingVers = [
            SELECT 
            Id, Service_Name__c, Service_Type__c
            FROM 
            Service_Type_Version__c 
            WHERE 
            Is_Current_Version__c = true
        ];

        // loop through new versions (outer loop) and compare to all active versions (inner loop)
        for (Service_Type_Version__c newVer : stVersions) {
            for (Service_Type_Version__c chkVer : existingVers) {
                if ((newVer.Id == null) || ((newVer.Id != null) && (newVer.Id != chkVer.Id))) {
                    // check that he name isn't empty, and that it matches the current version where comparing against
                    // BUT ONLY if its not a sibling service type version
                    if ((newVer.Service_Name__c != null) && (newVer.Service_Name__c == chkVer.Service_Name__c) && (newVer.Service_Type__c != chkVer.Service_Type__c)) {
                        newVer.addError('You cannot create/update the Service Type Version for this service type because it has a service name identical to an active version of another Service Type.  Please apply a unique Service Name.');
                        continue;
                    }
                }
            }
        }
    }


    public static void checkMailMergeFields(List<Service_Type_Version__c> stVersions){
        for(Service_Type_Version__c stv : stVersions) {
            String Error = checkMailMergeFields(stv,Base311_MailMerge.getFieldNames(stv.Rich_Email_Intro_Create__c));
            if(Error != null){
                stv.Rich_Email_Intro_Create__c.addError(Error);
            }
            Error = checkMailMergeFields(stv,Base311_MailMerge.getFieldNames(stv.Rich_Email_Intro_Close__c));
            if(Error != null){
                 stv.Rich_Email_Intro_Close__c.addError(error);
            }
            Error = checkMailMergeFields(stv,Base311_MailMerge.getFieldNames(stV.Rich_Email_Body_Create__c));
            if(Error != null){
                stv.Rich_Email_Body_Create__c.addError(Error);
            }
            Error =  checkMailMergeFields(stv,Base311_MailMerge.getFieldNames(stv.Rich_Email_Body_Close__c));
            if(Error != null){
                stv.Rich_Email_Body_Close__c.addError(Error);
            }
            Error =  checkMailMergeFields(stv,Base311_MailMerge.getFieldNames(stv.Rich_Email_Closing_Create__c));
            if(Error != null){
                stv.Rich_Email_Closing_Create__c.addError(Error);
            }
            Error =  checkMailMergeFields(stv,Base311_MailMerge.getFieldNames(stv.Rich_Email_Closing_Close__c));
            if(Error != null){
                stv.Rich_Email_Closing_Close__c.addError(Error);
            }
        }
    }


    public static String checkMailMergeFields(Service_Type_Version__c stv, List<String> fields){
        for(String field : fields) {
            System.debug('Does '+field+' exist '+Base311_Schema.doesFieldExist('Case',field));
            try{
                if(!Base311_Schema.doesFieldExist('Case',field)){
                    return 'Merge field '+Field+' cannot be found on the Case object';
                }
            }catch(Exception e){
                return 'Merge field '+Field+' cannot be found on the Case object';
            }
        }
        return null;
    }
}