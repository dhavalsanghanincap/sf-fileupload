/**
* @author Sean Murphy
* @date 4/20/2017  
* @group helper
* @group-content
* @description 
*/
public without sharing class Base311_CaseHelper {

    /**
    * @description create case events that capture the creation of a case
    * @param Map<Id,Case> cases
    * @return void
    * @example
    */
    public static void caseCreationCaseEvents(Map<Id,Case> cases) {
        createCaseEvents(cases, true, 'Create');
    }


    /**
    * @description create case events that capture the closure of a case
    * @param Map<Id, SObject> newCases
    * @param Map<Id, SObject> oldCases
    * @return void
    * @example
    */
    public static void caseClosureCaseEvents(Map<Id, SObject> newCases, Map<Id, SObject> oldCases) {
        List<Case> caseIds = new List<Case>();
        System.debug('Closing Case');
        for(Id caseId : newCases.keySet()) {
            if (((Case)newCases.get(caseId)).Status == 'Closed' && ((Case)oldCases.get(caseId)).Status != 'Closed') {
                caseIds.add((Case)newCases.get(caseId));
            }
        }

        if(caseIds.size() > 0) {
            createCaseEvents(new Map<Id,Case>(caseIds), false,'Close');
        }
    }

    /**
    * @description create case events that capture the closure of a case
    * @param Map<Id, SObject> newCases
    * @param Map<Id, SObject> oldCases
    * @return void
    * @example
    */
    public static void caseTransferCaseEvents(Map<Id, SObject> newCases,Map<Id, SObject> oldCases) {
        List<Case> caseIds = new List<Case>();
        for(Id caseId : newCases.keySet()) {
            if(newCases.get(caseId).get('Incap311__Service_Type_Version__c') != oldCases.get(caseId).get('Incap311__Service_Type_Version__c')){
                caseIds.add((Case)newCases.get(caseId));
            }
        }
		System.debug('Transfer Events '+caseIds);
        if(caseIds.size() > 0) {
            createCaseEvents(new Map<Id,Case>(caseIds), true, 'Transfer');
        }
    }

    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    private static Boolean shouldTrack(Case c, boolean isCreate) {
        return isCreate ? 
            (c.Service_Type_Version__r.Send_Email_On_SR_Creation__c && c.Service_Type_Version__r.Track_SR_Creation_Email__c && c.Transfer_Parent__c == null) : 
        (c.Service_Type_Version__r.Send_Email_On_SR_Closed__c  && c.Service_Type_Version__r.Track_SR_Closure_Email__c);
    }
    

    /**
    * @description create case events that capture the closure of a case
    * @param Map<Id,Case> cases
    * @param Boolean isCreate
    * @param String EventType
    * @return void
    * @example
    */
    private static void createCaseEvents(Map<Id,Case> cases, Boolean isCreate, String EventType) {
        System.debug('Creating case events');
        List<Case_Event__c> ces = new List<Case_Event__c>();
        Base311_Service_Request sr = new Base311_Service_Request();
        Map<Id,Case> casesMap = new Map<Id,Case>([select Service_Type_Version__r.Send_Email_On_SR_Creation__c,Service_Type_Version__r.Track_SR_Creation_Email__c,
                                                  Service_Type_Version__r.Send_Email_On_SR_Closed__c,Service_Type_Version__r.Track_SR_Closure_Email__c, Contact.Email,
                                                  Service_Type_Version__r.Rich_Email_Intro_Create__c, Service_Type_Version__r.Rich_Email_Intro_Close__c,
                                                  Service_Type_Version__r.Rich_Email_Body_Create__c, Service_Type_Version__r.Rich_Email_Body_Close__c,
                                                  Service_Type_Version__r.Rich_Email_Closing_Create__c ,Service_Type_Version__r.Rich_Email_Closing_Close__c,Transfer_Parent__c
                                                  from Case where Id in :cases.keySet()]);

        Set<String> allFieldsToMerge = new Set<String>();
        allFieldsToMerge.add('Id');
        for(Case c : cases.values()) {
            system.debug(Base311_MailMerge.caseNotifyEmail(c, isCreate));
            if(casesMap.get(c.id).Service_Type_Version__r != null && shouldTrack(casesMap.get(c.id),isCreate)) {
                try{
                    allFieldsToMerge.addAll(Base311_MailMerge.caseNotifyEmailFields(casesMap.get(c.id),isCreate));
                }catch(Exception e){
                    //System.debug(e+ 'Failed Case Event');
                }
            }
        }
        
        for(String field : allFieldsToMerge){
            if(!Base311_Schema.doesFieldExist('Case',field)){
                allFieldsToMerge.remove(field);
            }
        }

        List<String> allFieldsToMergel=new List<String>();
        allFieldsToMergel.addAll(allFieldsToMerge);
        Set<Id> caseIds = cases.keySet();
        
        


        String query = 'SELECT ' + String.join(allFieldsToMergel, ',');
        query += ' FROM Case where Id in :caseIds';
        System.debug(query);
        Map<Id,Case> casesMapFields = new Map<Id,Case>(); //= new Map<Id,Case>((list<case>)Database.query(String.escapeSingleQuotes(query)));
        //need to add a method to validate fields here

        try{
            casesMapFields = new Map<Id,Case>((list<case>)Database.query(String.escapeSingleQuotes(query)));
        }catch(Exception e){
        }


        for(Case c : cases.values()) {
            system.debug(Base311_MailMerge.caseNotifyEmail(c, isCreate));
            if(casesMap.get(c.id).Service_Type_Version__r != null && shouldTrack(casesMap.get(c.id),isCreate)) {
                try{
                    ces.add(new Case_Event__c(
                        Event_Type__c =  EventType,
                        Notification_Recipient__c = casesMap.get(c.id).Contact.Email,
                        Service_Request__c = c.Id,
                        Rich_Email_Body__c = Base311_MailMerge.caseNotifyEmail(casesMapFields.get(c.id),casesMap.get(c.id), isCreate)
                    )); 
                }catch(Exception e){
                    //System.debug(e+ 'Failed Case Event');
                }
                System.debug(ces);
            }
        }

        insert ces;
    }
}