/*********
* @author 
* @date 
* @group 
* @group-content
* @description 
*/
global without sharing class Base311_Service_Request {
    private static Integer MAX_SR_RETURNED = 50;
    private static String NOT_FOUND = 'Not Found';
    private static Integer MAX_DAYS_DIFF = 90; 
   
    private Base311_Service_ServiceType rsst;
    private Base311_Service_Question rsq;
    private Base311_Service_Activity rsa;
    private Base311_Service_Contact rsc;
    //private Base311_Service_CaseEvents sce;
    
    global Base311_Service_Request() {
       rsst = new Base311_Service_ServiceType();
       rsq = new Base311_Service_Question();
       rsa = new Base311_Service_Activity();
       rsc = new Base311_Service_Contact();
       //sce = new Base311_Service_CaseEvents();
    }
    
    private static final List<String> BASE_CASE_FIELDS = new List<String>{
        'Status', 'Incap311__Service_Type_Version__r.Incap311__Service_Name__c', 'Incap311__Service_Type_Version__r.Name', 
        'Incap311__Service_Type_Version__r.Incap311__Service_Location_Required__c', 'Description', 'Incap311__Requested_Date_Time__c', 
        'Incap311__Expected_Date_Time__c', 'Incap311__Expected_Start_Date__c', 'Incap311__Location__Latitude__s', 'Incap311__Location__Longitude__s', 'Incap311__Zipcode__c', 
        'Incap311__Address__c', 'Incap311__Location__c', 'Incap311__Media_URL__c', 'Incap311__XCoordinate__c', 'Incap311__Neighborhood__c', 'IsClosed', 
        'Incap311__YCoordinate__c', 'Incap311__Updated_Date_Time__c', 'Contact.FirstName', 'Contact.LastName', 'Contact.Email', 
        'Contact.Phone', 'Incap311__Address_Id__c', 'Incap311__Status_Notes__c', 'Incap311__Service_Request_Number__c', 'LastModifiedDate', 
        'ContactId', 'Incap311__Service_Type_Version__r.Incap311__Service_Type__r.Incap311__Service_Type_Code__c', 'Incap311__Service_Request_Source__c', 
        'Origin', 'ParentId', 'Parent.Incap311__Service_Request_Number__c', 'Incap311__Service_Type_Version__r.Incap311__Allow_Citizen_Web_Intake__c', 
        'Incap311__Service_Type_Version__r.Incap311__Service_Type_Code__c', 'Incap311__Service_Type_Version__r.Incap311__Service_Type_Name__c', 
        'Incap311__Service_Type_Version__r.Incap311__Rich_Email_Intro_Create__c', 'Incap311__Service_Type_Version__r.Incap311__Rich_Email_Body_Create__c', 
        'Incap311__Service_Type_Version__r.Incap311__Rich_Email_Closing_Create__c', 'Incap311__Service_Type_Version__r.Incap311__Rich_Email_Intro_Close__c', 
        'Incap311__Service_Type_Version__r.Incap311__Rich_Email_Body_Close__c', 'Incap311__Service_Type_Version__r.Incap311__Rich_Email_Closing_Close__c', 
        'Incap311__Service_Type_Version__r.Incap311__Send_Email_On_SR_Creation__c', 'Incap311__Service_Type_Version__r.Incap311__Send_Email_On_SR_Closed__c', 
        'Incap311__Service_Type_Version__r.Incap311__Track_SR_Creation_Email__c', 'Incap311__Service_Type_Version__r.Incap311__Track_SR_Closure_Email__c', 
        'Incap311__Service_Type_Version__r.Incap311__Enable_Business_Hours__c', 'CaseNumber', 'Reason', 'Subject', 
        'Incap311__Service_Type_Version__r.Incap311__Contact_Status__c', 'Incap311__Service_Type_Version__r.Incap311__Days_Of_Week__c',
        'Incap311__Service_Type_Version__r.Incap311__External_Name__c', 'Incap311__Service_Type_Version__r.Incap311__Keywords__c', 
        'Incap311__Service_Type_Version_Code__c', 'INcap311__Ward__c', 'Incap311__Service_Type_Version__r.Incap311__Generate_All_Questions__c', 
        'Incap311__Service_Type_Version__r.Incap311__Service_Type__r.Incap311__Active_Service_Type_Version__c',
        'Incap311__Case_Comments__c', 'Incap311__Sub_Address_Id__c', 'AccountId', 'Incap311__Service_Type_Version__r.Incap311__Validations__c', 
        'Incap311__Service_Type_Version__r.Incap311__Alert_Validations__c'
    };
        
    private static final List<String> BASE_REQUEST_ACTIVITIES_FIELDS = new List<String>{
        'Id', 'Incap311__Service_Type_Version_Activity__r.Incap311__Service_Type_Version__c', 'Name',
        'Incap311__Status__c', 'Incap311__Finish_Date__c', 'Incap311__Service_Type_Version_Activity__c',
        'Incap311__Expected_Date_Time__c', 'Incap311__Service_Type_Version_Activity__r.Name',
        'Incap311__Service_Type_Version_Activity__r.Incap311__Service_Type_Version__r.Incap311__Service_Type__c',
        'Incap311__Description__c', 'Incap311__Service_Type_Version_Activity__r.Incap311__Activity_Code__c',
        'Incap311__Activity_Outcome__r.Id', 'Incap311__Activity_Outcome__r.Incap311__Outcome_Code__c',
        'Incap311__Additional_Comments__c', 'Incap311__Activity_Outcome_Response__c'
    };
        
    private static final List<String> BASE_REQUEST_QUESTIONS_FIELDS = new List<String>{
        'Incap311__Order__c', 'Incap311__Question_Code__c', 'Incap311__Answer__c',
        'Incap311__Answer_Date_Time__c', 'Incap311__Service_Type_Version_Question__r.Name',
        'Incap311__Service_Type_Version_Question__r.Incap311__Question__r.Incap311__Data_Type__c',
        'Incap311__Service_Type_Version_Question__r.Incap311__Override_Answer_Values__c',
        'Incap311__Service_Type_Version_Question__r.Incap311__Question__r.Incap311__Answer_Values__c',
        'Incap311__Service_Type_Version_Question__r.Incap311__Question__r.Incap311__Question__c',
        'Incap311__Service_Type_Version_Question__r.Incap311__Question__r.Incap311__Flex_Question_Code__c',
        'Incap311__Service_Type_Version_Question__r.Incap311__Is_Required_Question__c',
        'Incap311__Question__c', 'Incap311__Service_Type_Version_Question__r.Incap311__Is_Read_Only__c',
        'Incap311__Service_Type_Version_Question__r.Incap311__Data_Type__c',
        'Incap311__Service_Type_Version_Question__r.Incap311__Validations__c',
        'Incap311__Service_Type_Version_Question__r.Incap311__Dependencies__c'
    };
        
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */    
    private String buildQuery(String clause, String saClause, String sqClause) {
        if(!Base311_Security.areAccessible(Case.SObjectType, BASE_CASE_FIELDS)) {
            throw new Base311_Exceptions.SecurityException('User does not have access to Cases');
        }  
        
        List<String> STV_FIELDS = Base311_Helper.getRelatedFields(BASE_CASE_FIELDS, 'Incap311__Service_Type_Version__r');
        
        if(!Base311_Security.areAccessible(Incap311__Service_Type_Version__c.SObjectType, STV_FIELDS)) {
            throw new Base311_Exceptions.SecurityException('User does not have access to Service Type Versions');
        }

        if(!Base311_Security.areAccessible(Incap311__Service_Type__c.SObjectType, Base311_Helper.getRelatedFields(STV_FIELDS, 'Incap311__Service_Type__r'))) {
            throw new Base311_Exceptions.SecurityException('User does not have access to Service Type');
        }

        if(saClause != null) {
            if(!Base311_Security.areAccessible(Incap311__Service_Activity__c.SObjectType, BASE_REQUEST_ACTIVITIES_FIELDS)) {
                throw new Base311_Exceptions.SecurityException('User does not have access to Service Activities');
            }
            
            List<String> STVA_FIELDS = Base311_Helper.getRelatedFields(BASE_REQUEST_ACTIVITIES_FIELDS, 'Incap311__Service_Type_Version_Activity__r');
            
            if(!Base311_Security.areAccessible(Incap311__Service_Type_Version_Activity__c.SObjectType, STVA_FIELDS)) {
                throw new Base311_Exceptions.SecurityException('User does not have access to Service Type Version Activities');
            }
        }
        
        if(sqClause != null) {
            if(!Base311_Security.areAccessible(Incap311__Service_Question__c.SObjectType, BASE_REQUEST_QUESTIONS_FIELDS)) {
                throw new Base311_Exceptions.SecurityException('User does not have access to Service Questions');
            }
            
            List<String> STVQ_FIELDS = Base311_Helper.getRelatedFields(BASE_REQUEST_QUESTIONS_FIELDS, 'Incap311__Service_Type_Version_Question__r');
            
            if(!Base311_Security.areAccessible(Incap311__Service_Type_Version_Question__c.SObjectType, STVQ_FIELDS)) {
                throw new Base311_Exceptions.SecurityException('User does not have access to Service Type Version Questions');
            }
        }
        
        String query = 'SELECT ' + String.join(BASE_CASE_FIELDS, ',');
        
        if(sqClause != null) {
            query += ',(SELECT ' + String.join(BASE_REQUEST_QUESTIONS_FIELDS, ',') + ' FROM Service_Questions__r ' + sqClause + ')';
        }
        
        if(saClause != null) {
            query += ',(SELECT ' + String.join(BASE_REQUEST_ACTIVITIES_FIELDS, ',') + ' FROM Service_Activities__r ' + saClause + ')';
        }
        
        query += ' FROM Case ' + clause;
        
        return query;
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global List<Case> getSimilarCases(String serviceTypeName) {
        DateTime limitDate = Datetime.Now().addDays(-7);
    
        String clause = 'WHERE Service_Type_Version__r.Name = :serviceTypeName AND CreatedDate >= :limitDate';
        
        return Database.query(String.escapeSingleQuotes(buildQuery(clause, null, null)));
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global List<Case> getServiceRequests(Set<Id> srIds) {
        return Database.query(String.escapeSingleQuotes(buildQuery('WHERE Id IN :srIds', null, null)));
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global List<Case> getContactRequests(Id contactId) {        
        String closedTrasnferState = '%Closed%';
    
        String clause = 'WHERE ContactId = :contactId AND (NOT Status LIKE :closedTrasnferState) ORDER BY CreatedDate DESC LIMIT 5';
        
        String query = buildQuery(clause, null, null);
        
        return Database.query(String.escapeSingleQuotes(query));
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global List<Case> getOpenCasesByServiceType(Set<Id> serviceTypeIds) {
        String newStatus = 'New';
        
        String clause = 'WHERE Service_Type_Version__r.Service_Type__c IN :serviceTypeIds AND Status = :newStatus';
        
        String query = buildQuery(clause, '', null);
        
        return Database.query(String.escapeSingleQuotes(query));
    }
    
    global Case patchServiceRequest(
        String serviceRequestId, Base311_PatchValue status, Base311_PatchValue mediaUrl, Base311_PatchValue description,
        Base311_PatchValue address, Base311_PatchValue addressId, Base311_PatchValue lat, Base311_PatchValue lng, 
        Base311_PatchValue contact, Base311_PatchValue attributes, Base311_PatchValue activities
    ) {
        return patchServiceRequest(
            serviceRequestId, status, mediaUrl, description, address, addressId, lat, lng, contact,
            attributes, activities, new Base311_PatchValue(false, null)
        );
    }
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global Case patchServiceRequest(
        String serviceRequestId, Base311_PatchValue status, Base311_PatchValue mediaUrl, Base311_PatchValue description,
        Base311_PatchValue address, Base311_PatchValue addressId, Base311_PatchValue lat, Base311_PatchValue lng, 
        Base311_PatchValue contact, Base311_PatchValue attributes, Base311_PatchValue activities, Base311_PatchValue parentRequestNumber
    ) {
        
        Base311_Location loc;
        
        if(address.isSet || addressId.isSet || (lat.isSet && lng.isSet)) {
            loc = Base311_Location.findMatch(
                lat.isSet ? Double.valueOf(lat.value) : null,
                lng.isSet ? Double.valueOf(lng.value) : null,
                addressId.isSet ? String.valueOf(addressId.value) : null,
                address.isSet ? String.valueOf(address.value) : null,
                false
            );
        }
        
        Savepoint sp = Database.setSavepoint();
        
        try { 
            Case c = patchServiceRequest(serviceRequestId, status, mediaUrl, description, loc, parentRequestNumber);
            
            if(contact.isSet) {
                Contact con = rsc.patchContact(c.ContactId, contact);
                
                // update the Case again since we
                // may have created a new contact in patchContact
                c.ContactId = con.Id;
                update c; 
            }
            
            if(attributes.isSet) {
                List<Service_Question__c> patchAttributes = rsq.patchQuestionResponses(c, attributes);
            }
            
            if(activities.isSet) {
                List<Service_Activity__c> patchActivities = rsa.patchActivities(c, activities);
            }
            
            //sce.details(c, 'Update', 'Service Request ' + c.Service_Request_Number__c + ' has been updated.');
            
            return getServiceRequest(serviceRequestId);
        } catch(Exception e) {
            Database.rollback(sp);
            throw e;
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
    private Case patchServiceRequest(
        String serviceRequestId, Base311_PatchValue status, Base311_PatchValue mediaUrl, Base311_PatchValue description,
        Base311_Location loc,  Base311_PatchValue parentRequestNumber
    ) {
        
        Case c = getServiceRequest(serviceRequestId);
        
        if(c == null) {
            throw new Base311_Exceptions.NotFoundException('Could not find service_request_id ' + serviceRequestId);
        }
        
        Base311_Case rc = new Base311_Case();
        
        List<String> fields = new List<String>{
            'Status', 'Incap311__Media_Url__c', 'Description', 'Incap311__Address__c',
            'Incap311__Address_Id__c', 'Incap311__Location__Latitude__s', 'Incap311__Location__Longitude__s'
        };
        
        // while we would like to check update; Site users cannot update
        // cases according to FLS
        if(!Base311_Security.areCreateable(Case.SObjectType, fields)) {
            throw new Base311_Exceptions.SecurityException('User does not have access to update Service Requests');
        }
        
        if(loc != null) {
            c.Address_Id__c = loc.addressId;
            c.Location__Latitude__s = loc.lat;
            c.Location__Longitude__s = loc.lng;
            c.Address__c = loc.address;
            c.ZipCode__c = loc.zipCode;
            c.XCoordinate__c = loc.xCoord;
            c.YCoordinate__c = loc.yCoord;
        }
        
        if(parentRequestNumber.isSet) {
            Case parentCase = getServiceRequest(String.valueOf(parentRequestNumber.value));
            c.ParentId = parentCase == null ? null : parentCase.Id;
        }
        
        if(status.isSet) {
            rc.status = String.valueOf(status.value);
            rc.validateStatus().throwErrors();
            c.Status = (String) status.value;
        }
        
        if(mediaUrl.isSet) {
            c.Media_Url__c = (String) mediaUrl.value;
        }
    
        if(description.isSet) {
            c.Description = (String) description.value;
        }
        
        update c;
        
        return c;
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global List<Case> getServiceRequests(List<String> serviceRequestIds, DateTime startDate, Datetime endDate, Datetime updatedStartDate, Datetime updatedEndDate, List<String> statuses, List<String> serviceCodes) {

        String additionalClauses = '';
       
        if(serviceRequestIds.size() == 0) {
            // do date validation IFF we dont have SR ids
            if(startDate != null && endDate == null) {
                endDate = startDate.addDays(MAX_DAYS_DIFF);
            }
            
            if(endDate != null && startDate == null) {
                startDate = endDate.addDays(-MAX_DAYS_DIFF);
            }
            
            if(startDate != null && endDate != null && startDate.date().daysBetween(endDate.date()) > MAX_DAYS_DIFF) {
                throw new Base311_Exceptions.UnsupportedException('Number of days between start_date and end_date must not exceed 90 days');                
            }
            
            if(updatedStartDate != null && updatedEndDate != null && updatedStartDate.date().daysBetween(updatedEndDate.date()) > MAX_DAYS_DIFF) {
                throw new Base311_Exceptions.UnsupportedException('Number of days between updated_start_date and updated_end_date must not exceed 90 days');                
            }
            
            if(startDate > endDate) {
                throw new Base311_Exceptions.UnsupportedException('Start date must be before end date');  
            }
            
            // check all conditions
            if(endDate != null) {
                additionalClauses += ' AND Requested_Date_Time__c <= :endDate ';
            }
            
            if(startDate != null) {
                additionalClauses += ' AND Requested_Date_Time__c >= :startDate ';
            }
            
            if(updatedEndDate != null) {
                additionalClauses += ' AND Updated_Date_Time__c <= :updatedEndDate ';
            }
            
            if(updatedStartDate != null) {
                additionalClauses += ' AND Updated_Date_Time__c >= :updatedStartDate ';
            }
            
            if(statuses.size() > 0) {
                additionalClauses += ' AND Status IN :statuses ';
            }
            
            if(serviceCodes.size() > 0) {
               additionalClauses += ' AND (Service_Type_Version__r.Name IN :serviceCodes OR Service_Type_Version__r.Service_Type_Code__c IN :serviceCodes) ';
            }
            
        }
        
        String clause = 'WHERE Id != null ' + additionalClauses + 
            (serviceRequestIds.size() > 0 ? ' AND Service_Request_Number__c IN :serviceRequestIds ' : '') +
            'AND Service_Type_Version__r.Service_Type__r.System_Generated__c = false ' +
            'ORDER BY CreatedDate DESC ' +
            'LIMIT :MAX_SR_RETURNED'; 
        
        List<Case> cases = Database.query(buildQuery(clause, null, null));
        
        Map<String, Case> casesByServiceNumber = new Map<String, Case>();
        
        for(Case c : cases) {
            casesByServiceNumber.put(c.Service_Request_Number__c, c);
        }
        
        for(String srId : serviceRequestIds) {
            if(!casesByServiceNumber.containsKey(srId)) {
                // this is to get the Service_Request_Number__c formula to recognize our Id
                // this is a not nice hack to a sad problem
                Case tmpCase = new Case(Status = NOT_FOUND, OldCaseNumber__c = srId, LegacyId__c = srId);
                tmpCase.recalculateFormulas();
                cases.add(tmpCase);
            }
        }
        
        return cases;
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global List<Case> getServiceRequests(List<String> serviceRequestIds, DateTime startDate, DateTime endDate, List<String> statuses, List<String> serviceCodes) {
        return this.getServiceRequests(serviceRequestIds, startDate, endDate, null, null, statuses, serviceCodes);
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global List<Case> getServiceRequests(List<String> serviceRequestIds, Datetime startDate, Datetime endDate, List<String> statuses) {
        return getServiceRequests(serviceRequestIds, startDate, endDate, statuses, new List<String>());        
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global List<Case> getServiceRequests(List<String> serviceRequestIds, Datetime startDate, Datetime endDate) {
        return getServiceRequests(serviceRequestIds, startDate, endDate, new List<String>());        
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global List<Case> getServiceRequests(List<String> serviceRequestIds) {
        return getServiceRequests(serviceRequestIds, null, null);        
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global Case getServiceRequest(String serviceRequestId) {
        String retiredStatus = 'Retired';
        String clause = 'WHERE Service_Request_Number__c = :serviceRequestId';
        String saClause = 'WHERE Status__c != :retiredStatus';
        
        List<Case> cases = Database.query(String.escapeSingleQuotes(buildQuery(clause, saClause, '')));
        
        return cases.size() > 0 ? cases[0] : null;
    } 
    
    global Case updateServiceRequest(
        String serviceRequestId, Double latitude, Double longitude, String mediaUrl,
        String addressId, String addressString, String description, String status,
        Map<String, Base311_Attribute> attributes, Base311_Contact contact, List<Base311_Activity> activities
    ) {
        return updateServiceRequest(
            serviceRequestId, latitude, longitude, mediaUrl, addressId, addressString, description,
            status, attributes, contact, activities, null
        );
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */ 
    global Case updateServiceRequest(
        String serviceRequestId, Double latitude, Double longitude, String mediaUrl,
        String addressId, String addressString, String description, String status,
        Map<String, Base311_Attribute> attributes, Base311_Contact contact, List<Base311_Activity> activities,
        String parentRequestNumber
    ) {
        Case sr = getServiceRequest(serviceRequestId);
        
        if(sr == null) {
            throw new Base311_Exceptions.NotFoundException('Could not find service_request_id ' + serviceRequestId);
        }
        
        Base311_Case rc = new Base311_Case(sr.Id, description, status, mediaUrl, sr.Service_Type_Version__r, sr.Service_Request_Source__c, sr.Service_Request_Source__c);
        rc.parentRequestNumber = parentRequestNumber;
            
        // if the SR has a contact, assume were updating
        if(sr.ContactId != null) {
            contact.id = sr.ContactId;
        }
        
        contact.setRequired(sr.Service_Type_Version__r);
        Base311_Location rl = Base311_Location.findMatch(
            latitude, longitude, addressId, addressString, sr.Service_Type_Version__r.Service_Location_Required__c
        ).refineAddress().addLayerInformation();        

        rc.validate().throwErrors();
        contact.validate().throwErrors();
        rl.validate().throwErrors();
        
        return updateServiceRequest(rc, rl, attributes, contact, activities);
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global Case updateServiceRequest(
        Base311_Case rc, Base311_Location rl, Map<String, Base311_Attribute> attributes, 
        Base311_Contact contact, List<Base311_Activity> activities
    ) { 
        
        return updateServiceRequest(rc, rl, attributes, contact, null, activities);
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global Case updateServiceRequest(
        Base311_Case rc, Base311_Location rl, Map<String, Base311_Attribute> attributes, 
        Base311_Contact contact, Account account, List<Base311_Activity> activities
    ) { 
        
        Savepoint sp = Database.setSavepoint();
        try { 
            if(contact != null && contact.canCreate()) {
                Contact updatedContact = rsc.upsertContact(contact);
                contact.id = updatedContact.id;
            }
            
            Case updatedSR = upsertServiceRequest(rc, rl, contact, account);
            
            // we have to re-fetch the SR since we need the question and 
            // attributes
            updatedSR = getServiceRequest(updatedSR.Service_Request_Number__c);
            
            // update questions based on user input
            if(attributes != null){
                List<Service_Question__c> questions = rsq.upsertQuestionResponses(updatedSR, attributes);
            }
            
            // update activities based on user input
            List<Service_Activity__c> services = rsa.upsertServiceActivities(updatedSR, rc.serviceType, activities);
            
            //sce.details(updatedSR, 'Update', 'Service Request ' + updatedSR.Service_Request_Number__c + ' has been updated.');
            
            // and finall fetch it again since we need any updates
            return getServiceRequest(updatedSR.Service_Request_Number__c);
        } catch (Exception e) {
            Database.rollback(sp);
            throw e;
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
    global Case createServiceRequest(
        Double latitude, Double longitude, String mediaUrl, String addressId, 
        String addressString, String serviceCode, String description, Map<String, Base311_Attribute> attributes, 
        String firstName, String lastName, String email, String phone, String source, String origin,
        String parentRequestNumber
    ) {
        Service_Type_Version__c stv = rsst.getServiceType(serviceCode, true);
        
        if(stv == null) {
            throw new Base311_Exceptions.UnsupportedException('Unknown service code ' + serviceCode);
        }
        
        Base311_Location rl = Base311_Location.findMatch(
            latitude, longitude, addressId, addressString, stv.Service_Location_Required__c
        ).refineAddress().addLayerInformation();  
        Base311_Contact rc = new Base311_Contact(firstName, lastName, phone, email).setRequired(stv);
        
        Base311_Case rca = new Base311_Case(description, null, mediaUrl, serviceCode, source, origin);
        rca.parentRequestNumber = parentRequestNumber;
        
        rc.validate().throwErrors();
        rca.validate().throwErrors();
        rl.validate().throwErrors();
        
        return createServiceRequest(rca, rl, rc, attributes);
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global Case createServiceRequest(
        Double latitude, Double longitude, String mediaUrl, String addressId, 
        String addressString, String serviceCode, String description, Map<String, Base311_Attribute> attributes, 
        String firstName, String lastName, String email, String phone, String source, String origin
    ) {
        return createServiceRequest(
            latitude, longitude, mediaUrl, addressId, addressString, serviceCode, description,
            attributes, firstName, lastName, email, phone, source, origin, null
        );
    }
    
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global Case createServiceRequest(
        Base311_Case c, Base311_Location loc, Base311_Contact contact, Map<String, Base311_Attribute> attributes
    ) {
        return createServiceRequest(c, loc, contact, null, attributes);
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global Case createServiceRequest(
        Base311_Case c, Base311_Location loc, Base311_Contact contact, Account account, Map<String, Base311_Attribute> attributes
    ) {
        Savepoint sp = Database.setSavepoint();

        try {
            // contact is optional
            if(contact != null && contact.canCreate()) {
                Contact finalContact = rsc.upsertContact(contact);
                contact.id = finalContact.Id;
            }
            
            // first create th sr
            Case serviceRequest = upsertServiceRequest(c, loc, contact, account);

            serviceRequest = getServiceRequest(serviceRequest.Service_Request_Number__c);

            // a question is created for each attribute.
            List<Service_Question__c> questions = rsq.upsertQuestionResponses(serviceRequest, attributes);
            
            // activities are created based on the service type; no user input
            List<Service_Activity__c> services = rsa.upsertServiceActivities(serviceRequest, c.serviceType);
            
            //sce.details(serviceRequest, 'Create', 'Service Request ' + serviceRequest.Service_Request_Number__c + ' has been created.');
            
            return getServiceRequest(serviceRequest.Service_Request_Number__c);
            
        } catch (Exception e) {
            Database.rollback(sp);
            throw e;
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
    private Case addLayerInformation(Case c, Base311_Location loc) {
        List<X311_ESRI_Layer_Mapping__mdt> mappings = Base311_LocationSearch.getActiveLayerMappings();
        
        for(X311_ESRI_Layer_Mapping__mdt mapping : mappings) {
            
            
            List<String> res = loc.getLayerValue(mapping.Layer_ID__c, mapping.Layer_Value__c);
            
            c.put(mapping.Field_Name__c, String.join(res, ','));
            
        }
        
        return c;
    }
    
    global Case addLocationInformation(Case c, Base311_Location rl) {
        if(rl != null) {
            c.Address_Id__c = rl.addressId;
            c.Location__Latitude__s = rl.lat;
            c.Location__Longitude__s = rl.lng;
            c.Address__c = rl.address;
            c.ZipCode__c = rl.zipCode;
            c.XCoordinate__c = rl.xCoord;
            c.YCoordinate__c = rl.yCoord;
            c.Neighborhood__c = rl.neighbourhood; 
            c.Parcel__c = rl.parcel;
            c.Precinct__c = rl.precinctWard; 
            c.Street_ID__c = rl.streetId;
            c.Unit__c = rl.unit;
            c.Ward__c = rl.ward;
            c.Layer_Information__c = rl.layers == null ? null : JSON.serialize(rl.layers);
            c.Sub_Address_Id__c = rl.subAddressId;
            
            c = addLayerInformation(c, rl);
            
        } else {
            c.Address_Id__c = null;
            c.Location__Latitude__s = null;
            c.Location__Longitude__s = null;
            c.Address__c = null;
            c.ZipCode__c = null;
            c.XCoordinate__c = null;
            c.YCoordinate__c = null;
            c.Neighborhood__c = null; 
            c.Parcel__c = null;
            c.Precinct__c = null; 
            c.Street_ID__c = null;
            c.Unit__c = null;
            c.Ward__c = null;
            c.Layer_Information__c = null;
            c.Sub_Address_Id__c = null;
        }
        
        return c;
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    private Case upsertServiceRequest(Base311_Case rc, Base311_Location rl, Base311_Contact contact, Account account){
        System.debug('>>>-----> upserting case...');
        List<String> fields = new List<String>{ 
            'Incap311__Location__Latitude__s', 'Incap311__Media_URL__c', 'Incap311__Location__Longitude__s', 
            'Incap311__Address_Id__c', 'Incap311__Service_Type_Version__c', 'Incap311__Requested_Date_Time__c',
            'Description', 'Incap311__Address__c', 'Status', 'Incap311__Neighborhood__c', 'Incap311__Parcel__c', 
            'Incap311__Precinct__c', 'Incap311__Street_ID__c', 'Incap311__Unit__c', 'Incap311__Ward__c', 
            'Incap311__Auto_Close__c', 'Incap311__Auto_Close_Date__c'
        };
        
        // opting out of update checks; anon users cannot be given FLS update on Case
        if(!Base311_Security.areCreateable(Case.SObjectType, fields)) {
            throw new Base311_Exceptions.SecurityException('User does not have access to create Service Requests');
        }
         
        // on every call
        Case c = new Case();
        
        c.Id = rc.id;
        c.Media_URL__c = rc.mediaUrl;
        c.Description = rc.description;
        
        if(String.isNotEmpty(rc.parentRequestNumber)) {
            Case parentCase = getServiceRequest(rc.parentRequestNumber);
            c.ParentId = parentCase == null ? null : parentCase.Id;
        }
        

        c.Status = rc.status;

        // If there is an ID present and the origin isn't null then set the origin in case of edit/transfer.
        if (rc.Id != null && rc.origin != null) {
          c.Origin = rc.origin;
        }
        
        if (account != null) {
            c.AccountId = account.id;
        }
        
        // if a user wants to set this to blank; they should pass
        // a blank string
        
        if(rc.duplicateParentId != null) {
            c.Duplicate_Parent__c = rc.duplicateParentId;
        }
        
        if(contact != null) {
            c.ContactId = contact.id;
        }
        
        addLocationInformation(c, rl);
        
        // only on creates
        if(rc.id == null) {
            c.Service_Type_Version__c = rc.serviceType.Id;
            c.Requested_Date_time__c = System.now();
            c.Status = rc.serviceType.Default_Status__c;
            c.Priority = rc.serviceType.Default_Priority__c;
            c.Origin = rc.origin != null ? rc.origin : rc.serviceType.Default_Method__c;
            c.Subject = rc.serviceType.Service_Name__c;
            c.Service_Request_Source__c = rc.source;
            
            if(rc.serviceType.SLA_Type__c != NULL && rc.serviceType.SLA__c != NULL) {
                c.Expected_Date_Time__c = Base311_DateTime_Util.getEndDate(System.now(), rc.serviceType.SLA_Type__c, rc.serviceType.SLA__c, false);
            }

            if (rc.serviceType.Service_Type__r.Auto_Close__c != NULL && rc.serviceType.Service_Type__r.Auto_Close_Days__c >= 0) {
              try {
                if (rc.serviceType.Service_Type__r.Auto_Close__c) {
                  c.Auto_Close__c = true;
                  c.Auto_Close_Date__c = Date.today().addDays(Integer.valueOf(rc.serviceType.Service_Type__r.Auto_Close_Days__c));
                }
              } catch (Exception e) {
                System.debug('----> Error: Unable to set auto closure date.');
              }
            }
        }
         
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule = true;
        
        c.setOptions(dmo);
        
        upsert c;
        
        c.recalculateFormulas();
        
        return c;    
    }

    global List<Case> searchServiceRequests(String terms) {
        String findTerms = String.join(Base311_Helper.csvToList(terms), ' OR ');
        
        List<List<Sobject>> items = [
            FIND :findTerms
            IN ALL FIELDS
            RETURNING Case (Id, CaseNumber, Subject, CreatedDate, Address__c, Description)
        ];
        
        if(items.size() > 0) {
            return (List<Case>) items.get(0);
        }
        
        return new List<Case>();
    }
}