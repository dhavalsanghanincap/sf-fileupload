/**
* @author Matt Darkis
* @date  10/27/2016 
* @group 
* @group-content
* @description 
*/
global with sharing class Base311_DuplicateRequestsUtil {
    
    global static Boolean overrideStopDupeEdits = false;
    
    private static final Double MILE_FOOT_CONVERSION = 0.000189394;
    private static final String MI_UNIT = 'mi';
    
    private static Base311_Service_ServiceType sst = new Base311_Service_ServiceType();

    global Base311_DuplicateRequestsUtil() {
        
    }
  
    private static final String BASE_QUERY = 
        'SELECT ' +
            'Status, Service_Request_Number__c, CaseNumber, Address__c, Service_Type_Version__r.Duplicate_Threshold_Period_days__c, ' +
            'Service_Type_Version__r.Duplicate_Radius_feet__c, Service_Type_Version__r.Service_Name__c, Service_Type_Version__r.Duplicate_Detection_Method__c, ' +
            'Service_Type_Version__r.Service_Type__c, Service_Type_Version__c, Location__Latitude__s, Location__Longitude__s, Subject, ' +
            'Expected_Start_Date__c, Expected_Date_Time__c, ' +
            'IsClosed, Location__c, CreatedDate, Duplicate_Parent__c, Contact.Id, Contact.FirstName, Contact.LastName, Contact.Email, Contact.Phone ' +
        'FROM Case ';
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    private static String standardStrategy(Base311_Location location, Service_Type_Version__c stv) {
        if(location.lat == null || location.lng == null || stv.Duplicate_Radius_feet__c == null) {
            return null;
        }
        
        List<Duplicate_Service_Type_Mapping__c> duplicates = sst.getDuplicateMappings(stv.Id);
        Decimal radiusLimit = stv.Duplicate_Radius_feet__c * MILE_FOOT_CONVERSION;
        Datetime earliestDate = stv.Duplicate_Threshold_Period_days__c == null ? null : Datetime.now().addDays(Integer.valueOf(stv.Duplicate_Threshold_Period_days__c * -1));
        String formattedDate = earliestDate == null ? null : earliestDate.formatGMT('yyyy-MM-dd') + 'T' + earliestDate.formatGMT('HH:mm:ss.SSS') + 'Z';
        List<String> validSTVs = new List<String>{ stv.Id };

        System.debug(duplicates);
            
        for(Duplicate_Service_Type_Mapping__c dstm : duplicates) {
            validSTVs.add(dstm.To_Service_Type__r.Active_Service_Type_Version__c);
        }
        
        System.debug(validSTVs);
        
        return 'WHERE DISTANCE(Location__c, GEOLOCATION('+ String.valueOf(location.lat) +', '+ String.valueOf(location.lng) +'), \''+MI_UNIT+'\') < '+ radiusLimit +' ' + 
            'AND Service_Type_Version__c IN (\'' + String.join(validSTVs, '\',\'') + '\') ' +
            (earliestDate != null ? 'AND CreatedDate >= ' + formattedDate + ' ' : '') + 
            (stv.Duplicate_Statuses__c != null ? 'AND Status IN (\'' + String.join(stv.Duplicate_Statuses__c.split(';'), '\',\'') + '\') ' : '' ) +
            (location.addressId != null && stv.Duplicate_Match_Street__c ? 'AND Street_Id__c = \'' + location.addressId + '\' ' : '');
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    private static String determineStrategy(Base311_Location location, Service_Type_Version__c stv) {
        if(stv == null) {
            return null;
        }
        
        if(stv.Duplicate_Detection_Method__c == 'Standard') {
            return standardStrategy(location, stv);
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
    global static List<Case> getDuplicates(Base311_Location location, Service_Type_Version__c stv, Boolean excludeClosed) {
        List<Case> ret = new List<Case>();
        
        String strategyClause = determineStrategy(location, stv);
        
        if(strategyClause == null) {
            return new List<Case>();
        }
        
        String currentQuery = BASE_QUERY + strategyClause + (excludeClosed ? ' AND Status != \'Closed\' ' : '') + ' ORDER BY CreatedDate DESC LIMIT 50';
        
        System.debug('currentQUery ---> ' + currentQuery);
        
        return Database.query(currentQuery);
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global static List<Case> getDuplicateServiceRequestsBase(String srAddress, Service_Type_Version__c serviceType, String sRLongitude, String sRLatitude, Boolean excludeClosedCases) {
        List<Case> ret = new List<Case>();
        Base311_Location loc = new Base311_Location();
        
        loc.address = srAddress;
        
        if(sRLatitude == null || sRLongitude == null) {
            return new List<Case>();
        }
        
                
        loc.lat = Double.valueOf(sRLatitude);
        loc.lng = Double.valueOf(sRLongitude);
        
        return getDuplicates(loc, serviceType, excludeClosedCases);
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    // fetching potential duplicate service request based on mar details and service type 
    global static list<Case> getDuplicateServiceRequests(String srAddress, String ServiceTypeName, String sRLongitude, String sRLatitude) {
        return getDuplicateServiceRequestsBase(srAddress, sst.getServiceType(ServiceTypeName, true), sRLongitude, sRLatitude, true);
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    // fetching potential duplicate service request based on mar details and service code
    global static list<Case> getDuplicateServiceRequestsByServiceCode(String srAddress, String ServiceTypeCode, String sRLongitude, String sRLatitude) {
        return getDuplicateServiceRequestsBase(srAddress, sst.getActiveServiceType(ServiceTypeCode, true), sRLongitude, sRLatitude, true);
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global static List<Case> getDuplicateServiceRequests(String srAddress, String ServiceTypeName, String sRLongitude, String sRLatitude, Boolean excludeClosedCases) {
        return getDuplicateServiceRequestsBase(srAddress, sst.getServiceType(ServiceTypeName, true), sRLongitude, sRLatitude, excludeClosedCases);
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global static List<Case> getDuplicateServiceRequests(String srAddress, Service_Type_Version__c serviceType, String sRLongitude, String sRLatitude) {
        return getDuplicateServiceRequestsBase(srAddress, serviceType, sRLongitude, sRLatitude, true);
    }

    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    public static void updateDuplicateStatuses(Map<Id, Sobject> newCaseMap, Map<Id, SObject> oldCaseMap) {
        
        // collect ids of cases whose status has changed
        Set<Id> chngCaseIds = new Set<Id>();
        for (Id cid : newCaseMap.keySet()) {
            Case newC = (Case)newCaseMap.get(cid);
            Case oldC = (Case)oldCaseMap.get(cid);
            
            if ((newC.Status != oldC.Status) && (newC.Duplicate_Parent__c == null)) {       // if the status has changed on a non-duplicate (no dupe parent)
                chngCaseIds.add(cid);
            }
            
        }
        
        Map<Id, Case> caseTypeMap = new Map<Id, Case>([SELECT Id, Service_Type_Version__r.Service_Type__c FROM Case WHERE Id IN :chngCaseIds]);
        
        // collect and map children to parent cases
        List<Case> childCases = new List<Case>([SELECT Id, Status, Duplicate_Parent__c, Service_Type_Version__r.Service_Type__c FROM Case WHERE Duplicate_Parent__c IN :chngCaseIds]);
        
        Map<String, List<Case>> childCaseMap = new Map<String, List<Case>>();
        List<Case> updateCases = new List<Case>();
        for (Case c : childCases) {
            // if the service type is the same, change the status of the child
            if (c.Service_Type_Version__r.Service_Type__c == caseTypeMap.get(c.Duplicate_Parent__c).Service_Type_Version__r.Service_Type__c) {
                c.Status = 'Duplicate (' + ((Case)newCaseMap.get(c.Duplicate_Parent__c)).Status + ')';
                updateCases.add(c);
            }
        }
        
        if (updateCases.size() > 0) {
            update updateCases;
        }
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    public static void createCaseEvents(List<sObject> newCases, Map<Id, sObject> oldCasesMap, map<Id, sObject> newCasesMap) {
        Id CSERecordTypeId = Schema.SObjectType.Incap311__Case_Event__c.getRecordTypeInfosByName().get('Notification').getRecordTypeId();
        Map<Id, List<Case>> dupCases = new Map<Id, List<Case>>();
        Map<Id, Case> newCaseMap = new Map<Id, Case>();
        List<Case_Event__c> csEvent = new List<Case_Event__c>();
        Set<Id> csids = new Set<Id>();
        List<Case> duplicateCases = [SELECT Id, Duplicate_Parent__c, ContactId FROM Case WHERE Duplicate_Parent__c IN :newCasesMap.keySet()];
        
        if (duplicateCases.size() > 0) {
            Set<Id> conids = new Set<Id>();
            for (Case c : duplicateCases) {
                conids.add(c.contactid);
            }
            
            Map<Id, Contact> contacts = new Map<Id, Contact>([SELECT Id, Email FROM Contact WHERE Id IN :conids]);
            for (Case c : duplicateCases) {
                if (dupCases.containsKey(c.Duplicate_Parent__c)) {
                    List<Case> dcs = dupCases.get(c.Duplicate_Parent__c);
                    dcs.add(c);
                    dupCases.put(c.Duplicate_Parent__c, dcs);
                }
                else {
                    List<Case> dc = new List<Case>();
                    dc.add(c);
                    dupCases.put(c.Duplicate_Parent__c,dc);
                }
            }
            
            for (Id id : dupCases.keySet()){
                List<Case> cases = dupCases.get(id);
                Case ncs = (Case)(newCasesMap.get(id));
                Case ocs = (Case)(oldCasesMap.get(id));
                if ((ncs.isClosed && ncs.Isclosed != ocs.IsClosed) || !ncs.IsClosed){
                    for (Case cs : cases){
                        if ((cs.contactId != null) && (contacts.get(cs.contactId).email != null)) {
                            Case_Event__c cse = new Case_Event__c();
                            cse.Service_Request__c = cs.id;
                            cse.Notification_Recipient__c = contacts.get(cs.contactId).email;
                            cse.RecordTypeid = CSERecordTypeId;
                            if ((ncs.IsClosed) && (ncs.Isclosed != ocs.IsClosed)) {
                                cse.Event_Type__c = 'Close';
                                cse.Details__c = 'Service Request' + ncs.CaseNumber + ' has been Closed.';
                            }
                            else {
                                cse.Event_Type__c = 'Update';
                                cse.Details__c = 'Service Request' + ncs.CaseNumber + ' has been Updated.';
                            }
                            csevent.add(cse);
                        }
                    }
                }
                    
            }
            
            if (csevent.size() > 0) {
                insert csevent;
            }
        }
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    public static void doNotEditChildCases(List<sObject> newCases, Map<Id, sObject> oldCasesMap) {
        List<Case> newCaseList = newCases;
        List<Case> cs = new List<Case>();
        Set<String> modifiedFields = new Set<String>();
        /*for(Case c:newCaseMap.values()){
            if(c.Incap311__Duplicate_Parent__c!=null){
                cs.add(c);
            }
        }*/
        for (Case c : newCaseList){
            Case oc = (Case)(oldCasesMap.get(c.id));
            if (c.Duplicate_Parent__c != null) {
                if ((c.Status == 'New') && (oc.Status != 'New')) {          // this is dicey with the values hard coded
                    c.Duplicate_Parent__c = null;
                }
                else {
                    if ((c.Duplicate_Parent__c != null) && (oc.Duplicate_Parent__c != null) && (c.Duplicate_Parent__c == oc.Duplicate_Parent__c))  {
                        modifiedFields = findModifiedFieldsCase(c, oc);
                        if (modifiedFields.size() > 0) {
                            String modFields = '';
                            for (String s : modifiedFields) {
                                modFields += (s + ', ');
                            }
                            modFields = modFields.substringBeforeLast(',');
                            //System.debug('>>>-----> adding the error (case update).');
                            if (!test.isRunningTest()) {
                                c.addError('The following fields were edited which is not permitted on Service Questions on duplicate Service Requests: ' + modFields);
                            }
                        }
                    }
                }
            }
        }
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    public static void doNotEditServiceActivityChildCases(List<sObject> newSAs, Map<Id, sObject> oldSAsMap, Boolean isINS) {
        
        List<Service_Activity__c> newSAList = newSAs;
        Set<String> modifiedFields = new Set<String>();
        Set<Id> csid = new Set<Id>();
        for (Service_Activity__c sa : newSAList) {
            csid.add(sa.Service_Request__c);
        }
        
        Map<Id, Case> cs = new Map<Id,Case>([SELECT Id, Status, Duplicate_Parent__c FROM Case WHERE Id IN :csid]);
        
        for (Service_Activity__c sa : newSAList) {
            Case c = cs.get(sa.Service_Request__c);
            if (c.Duplicate_Parent__c != null) {
                if (!Base311_DuplicateRequestsUtil.overrideStopDupeEdits) {
                    if (isINS) {
                        //System.debug('>>>-----> adding the error (SA insert).');
                        if (!test.isRunningTest()) {
                            sa.addError('Cannot create Service Activites on duplicate Service Requests.');
                        }
                    }
                    else {
                        modifiedFields = findModifiedFieldsSRActivity(sa, (Service_Activity__c)(oldSAsMap.get(sa.id)));
                        if (modifiedFields.size() > 0) {
                            String modFields = '';
                            for (String s : modifiedFields) {
                                modFields += (s + ', ');
                            }
                            modFields = modFields.substringBeforeLast(',');
                            //System.debug('>>>-----> adding the error (SA update).');
                            if (!test.isRunningTest()) {
                                sa.addError('The following fields were edited which is not permitted on Service Questions on duplicate Service Requests: ' + modFields);
                            }
                        }
                    }
                }
            }
        }
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    public static void doNotEditServiceQuestionChildCases(List<sObject> newSQs, Map<Id, sObject> oldSQsMap, Boolean isINS) {
        List<Service_Question__c> newSQList = newSQs;
        Set<String> modifiedFields = new Set<String>();
        Set<Id> csid = new Set<Id>();
        for (Service_Question__c sq : newSQList){
            csid.add(sq.Service_Request__c);
        }
        
        Map<Id, Case> cs = new Map<Id, Case>([SELECT Id, Status, Duplicate_Parent__c FROM Case WHERE Id IN :csid]);
        
        for (Service_Question__c sq : newSQList) {
            Case c = cs.get(sq.Service_Request__c);
            if (c.Duplicate_Parent__c != null) {
                if (!Base311_DuplicateRequestsUtil.overrideStopDupeEdits) {
                    if (isINS) {
                        //System.debug('>>>-----> adding the error (SQ insert).');
                        if (!test.isRunningTest()) {
                            sq.addError('Cannot create Service Questions on Child Service Requests');
                        }
                    }
                    else {
                        modifiedFields = findModifiedFieldsSRQuestions(sq, (Service_Question__c)(oldSQsMap.get(sq.id)));
                        if (modifiedFields.size() > 0) {
                            String modFields = '';
                            for (String s : modifiedFields) {
                                modFields += (s + ', ');
                            }
                            modFields = modFields.substringBeforeLast(',');
                            //System.debug('>>>-----> adding the error (SQ update).');
                            if (!test.isRunningTest()) {
                                sq.addError('The following fields were edited which is not permitted on Service Questions on duplicate Service Requests: ' + modFields);
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    
    public static Set<String> findModifiedFieldsCase(Case newRecord, Case oldRecord) {
        Set<String> skipTheseItems = new Set<String>{'id', 'isdeleted', 'name', 'createdby', 'lastmodifiedby',
                                                        'recordtype','createddate', 'lastmodifieddate', 'createdbyid', 'lastmodifiedbyid',
                                                        'systemmodstamp', 'lastactivitydate', 'lastvieweddate', 'lastreferenceddate','incap311__duplicate_parent__c','status'} ;
        Set<String> modified = new Set<String>();
        // Get the field describe result for the Name field on the Account object
        Map<String, Schema.SObjectField> fieldMap = Schema.sObjectType.Case.fields.getmap();
        for (String fieldName : fieldMap.keySet())
        {
            if (!skipTheseItems.contains(fieldName.toLowerCase()))
            {
                Schema.DescribeFieldResult dfr = fieldMap.get(fieldName).getDescribe();
                //system.debug('FindModifiedFields: ' + FieldName + ' = ' + dfr.isUpdateable());
                if (dfr.isUpdateable() && (newRecord.get(FieldName) != oldRecord.get(FieldName)))
                {
                    //system.debug('findModifiedFields: ' + fieldName + ' New: ' + newRecord.get(fieldName) + ' Old: ' + oldRecord.get(fieldName));
                    modified.Add(dfr.getLabel());
                }
            }
        }
        return modified;
    }
    
    
    public static Set<String> findModifiedFieldsSRActivity(Service_Activity__c newRecord, Service_Activity__c oldRecord) {
        Set<String> skipTheseItems = new Set<String>{'id', 'isdeleted', 'name', 'createdby', 'lastmodifiedby',
                                                        'recordtype','createddate', 'lastmodifieddate', 'createdbyid', 'lastmodifiedbyid',
                                                        'systemmodstamp', 'lastactivitydate', 'lastvieweddate', 'lastreferenceddate','incap311__duplicate_parent__c'} ;
        Set<String> modified = new Set<String>();
        // Get the field describe result for the Name field on the Account object
        Map<String, Schema.SObjectField> fieldMap = Schema.sObjectType.Service_Activity__c.fields.getmap();
        for (String fieldName : fieldMap.keySet()) {
            if (!skipTheseItems.contains(FieldName.toLowerCase())) {
                Schema.DescribeFieldResult dfr = fieldMap.get(fieldName).getDescribe();
                //system.debug('FindModifiedFields: ' + FieldName + ' = ' + dfr.isUpdateable());
                if (dfr.isUpdateable() && (newRecord.get(fieldName) != oldRecord.get(fieldName))) {
                    //system.debug('findModifiedFields: ' + fieldName + ' New: ' + newRecord.get(fieldName) + ' Old: ' + oldRecord.get(fieldName));
                    modified.Add(dfr.getLabel());
                }
            }
        }
        return modified;
    }
    
    
    
    public static set<String> FindModifiedFieldsSRQuestions(Service_Question__c newRecord, Service_Question__c oldRecord) {
        Set<String> skipTheseItems = new Set<String>{'id', 'isdeleted', 'name', 'createdby', 'lastmodifiedby',
                                                        'recordtype','createddate', 'lastmodifieddate', 'createdbyid', 'lastmodifiedbyid',
                                                        'systemmodstamp', 'lastactivitydate', 'lastvieweddate', 'lastreferenceddate','incap311__duplicate_parent__c'} ;
        Set<String> modified = new Set<String>();
        // Get the field describe result for the Name field on the Account object
        Map<String, Schema.SObjectField> fieldMap = Schema.sObjectType.Service_Question__c.fields.getmap();
        for (String fieldName : fieldMap.keySet()) {
            if (!skipTheseItems.contains(fieldName.toLowerCase())) {
                Schema.DescribeFieldResult dfr = fieldMap.get(fieldName).getDescribe();
                //system.debug('FindModifiedFields: ' + FieldName + ' = ' + dfr.isUpdateable());
                if ((dfr.isUpdateable()) && (newRecord.get(fieldName) != oldRecord.get(fieldName))) {
                    //system.debug('findModifiedFields: ' + fieldName + ' New: ' + newRecord.get(fieldName) + ' Old: ' + oldRecord.get(fieldName));
                    modified.add(dfr.getLabel());
                }
            }
        }
        return modified;
    }
}