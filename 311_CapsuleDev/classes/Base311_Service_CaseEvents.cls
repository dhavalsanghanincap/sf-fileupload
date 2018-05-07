/**
* @author 
* @date 
* @group 
* @group-content
* @description 
*/
global class Base311_Service_CaseEvents {
    
    public static Id DISTRIBUTION_RECORD_ID = Schema.SObjectType.Case_Event__c.getRecordTypeInfosByName().get('Distribution').getRecordTypeId();
    public static Id NOTFICATION_RECORD_ID = Schema.SObjectType.Case_Event__c.getRecordTypeInfosByName().get('Notification').getRecordTypeId();
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global Case_Event__c details(Case c, String type, String details) {
       	// this may be dynamic in the future based on the notification type
        Boolean isCreate = true;
        String emailBody = Base311_MailMerge.caseNotifyEmail(c, isCreate);
        
        return trackEvent(c, type, details, null, determineNotificationRecepient(NOTFICATION_RECORD_ID, c), emailBody, NOTFICATION_RECORD_ID);
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global Case_Event__c notify(Case c, String type, String distributionList, String emailBody) {
        return trackEvent(c, type, null, distributionList, null, emailBody, DISTRIBUTION_RECORD_ID);
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    private String determineNotificationRecepient(Id rtId, Case c) {
        if(rtId == NOTFICATION_RECORD_ID && c.Contact.Email != NULL) {
            return c.Contact.Email;
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
    private Case_Event__c trackEvent(Case c, String type, String details, String distributionList, String notificationRecpeient, String emailBody, Id recordTypeId) {
        List<String> sqFields = new List<String>{ 
            'Incap311__Service_Request__c', 'Incap311__Details__c', 'Incap311__Distribution_List__c', 
            'Incap311__Rich_Email_Body__c', 'Incap311__Notification_Recipient__c'   
        };
    
        System.debug(emailBody);
    
        if(!Base311_Security.areCreateable(Case_Event__c.SObjectType, sqFields)) {
            throw new Base311_Exceptions.SecurityException('User does not have access to Case Events');
        }
    
        Case_Event__c ce = new Case_Event__c(
            Service_Request__c = c.Id,
            Details__c = details,
            Event_Type__c = type,
            Distribution_List__c = distributionList,
            Rich_Email_Body__c = emailBody,
            RecordTypeId = recordTypeId,
            Notification_Recipient__c = notificationRecpeient
        );
        
        System.debug(ce);
        
        insert ce;
                
        return ce;
    }
}