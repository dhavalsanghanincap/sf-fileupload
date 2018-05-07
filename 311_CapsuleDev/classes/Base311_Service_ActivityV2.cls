/**
* @author John Benson
* @date 6/12/2017
* @group Incapsulate
* @group-content
* @description Methods to handle retrieval, and saving, of items related to Activities.
* This class reflects the new model for Activities as updated in 6/1/2017
*/
global with sharing class Base311_Service_ActivityV2 {
	
    private static final List<String> ACTIVITY_OUTCOME_FIELDS = new List<String> {
            'Id', 'Incap311__Service_Type_Version_Activity__c', 
            'Incap311__Outcome__r.Incap311__Outcome_Code__c',
            'Incap311__Outcome__r.Incap311__Outcome_Detail__c',
            'Incap311__Outcome__r.Incap311__Outcome_Action__c',
            'Incap311__Outcome__r.Incap311__Can_Close_SR__c'    
    };
        
    private static final List<String> OUTCOME_QUESTION_FIELDS = new List<String> {
        	'Id',
        	'Incap311__Question__r.Incap311__Flex_Question_Code__c',
        	'Incap311__Question__r.Incap311__Question__c',
        	'Incap311__Question__r.Incap311__Data_Type__c',
            'Incap311__Display_Sort_Order__c',
            'Incap311__Question__r.Incap311__Answer_Values__c',
            'Incap311__Is_Required_Question__c',
            'Incap311__Dependencies__c',
            'Incap311__Override_Answer_Values__c',
            'Incap311__Validations__c',
            'Incap311__Question_Code__c'
    };
        
    private static final List<String> ACTIVITY_OUTCOME_RESPONSE_FIELDS = new List<String> {
            'Id',
            'Incap311__Canned_Response__r.Incap311__Response_Code__c',
            'Incap311__Canned_Response__r.Name',
            'Incap311__Canned_Response__r.Incap311__Long_Response_Text__c', 
        	'Incap311__Additional_Comments_Required__c'
    };
    
    /**
    * @description Builds a query based on Activity Outcomes, allowing for the search on Respones and Outcome Questions
    * @param String the clause to use when filtering Activity Outcomes
    * @param String the clause to use when filtering Activity Outcome Responses
    * @param String the clause to use when filtering Outcome Questions
    * @return String a query, based on the clauses provided
    * @example buildQuery('WHERE Id = :someId', '', '')
    */
    private String buildQuery(String aoClause, String aorClause, String oqClause) {
         
        if(!Base311_Security.areAccessible(Activity_Outcome__c.SObjectType, ACTIVITY_OUTCOME_FIELDS)) {
            throw new Base311_Exceptions.SecurityException('User does not have access to Service Type Version Activities');
        }
        
        if(!Base311_Security.areAccessible(Activity_Outcome_Response__c.SObjectType, ACTIVITY_OUTCOME_RESPONSE_FIELDS)) {
            throw new Base311_Exceptions.SecurityException('User does not have access to Service Type Version Activities');
        }
        
        if(!Base311_Security.areAccessible(Outcome_Question__c.SObjectType, OUTCOME_QUESTION_FIELDS)) {
            throw new Base311_Exceptions.SecurityException('User does not have access to Service Type Version Activities');
        }
        
        String query = 'SELECT ' + String.join(ACTIVITY_OUTCOME_FIELDS, ',');
         
        if(aorClause != null) {
            query += ',(SELECT ' + String.join(ACTIVITY_OUTCOME_RESPONSE_FIELDS, ',') + ' FROM Activity_Outcome_Responses__r ' + aorClause + ')';
        }
                 
        if(oqClause != null) {
            query += ',(SELECT ' + String.join(OUTCOME_QUESTION_FIELDS, ',') + ' FROM Outcome_Questions__r ' + oqClause + ')';
        }
        
        query += ' FROM Activity_Outcome__c ' + aoClause;
        
        return query;
    }
    
    /**
    * @description  Fetch a list of Service Type Version Activity Outcomes (object name = Activity_Outcome__c) 
    * 				for a given set of Service Type Version Activities
    * @param List<Service_Type_Version_Activity__c> The set of service type version activities to use
    * @return Map<Id, List<Activity_Outcome__c>> A map from Service Type Version Activity Id = > List<Activity_Outcome>
	* @example fetchSTVAOutcomes(new List<Service_Type_Version_Activity__c>{ })
    */
    global Map<Id, List<Activity_Outcome__c>> fetchSTVAOutcomes(List<Service_Type_Version_Activity__c> activities) {
    	Map<Id, List<Activity_Outcome__c>> itemMap = new Map<Id, List<Activity_Outcome__c>>();
        Set<String> ids = new Set<String>();
        
        for(Service_Type_Version_Activity__c stva : activities) {
            ids.add(stva.Id);
        }
        
        String query = buildQuery('WHERE Service_Type_Version_Activity__c IN :ids', '', 'ORDER BY Display_Sort_Order__c ASC');
         
        List<Activity_Outcome__c> items = Database.query(query);
        
        for(Activity_Outcome__c item : items) {
            if(!itemMap.containsKey(item.Service_Type_Version_Activity__c)) {
                itemMap.put(item.Service_Type_Version_Activity__c, new List<Activity_Outcome__c>());
            }
            
            itemMap.get(item.Service_Type_Version_Activity__c).add(item);
        }
        
        return itemMap;
    }
    
    /**
    * @description Gets all activity questions, mapped by question code, for a given service activity
    * @param Service_Activity__c the service activity to search on
    * @return Map<String, Activity_Question__c> a map from Question Code => Activity Question
    * @example getActivityQuestions(new Service_Activity__c(Id = 'Some-Id'))
    */ 
    private Map<String, Activity_Question__c> getActivityQuestions(Service_Activity__c c) {
        Map<String, Activity_Question__c> result = new Map<String, Activity_Question__c>();
        
        List<Activity_Question__c> questions = [
        	SELECT Id, Question_Code__c, Answer__c
            FROM Activity_Question__c
            WHERE Service_Activity__c = :c.Id
        ];
        
        for(Activity_Question__c aq : questions) {
            result.put(aq.Question_Code__c, aq);
        }
        
        return result;
    }
    
    /**
    * @description Gets the service activity from a given case based on some activity update. The
    * Activity_Code__c of the servivce activity is comapred against the code in the activity update.
    * @param Case the service request to search; assumes Service_Activities__r is preset and that
    * Service_Type_Version_Activity__r.Activity_Code__c has already been queries
    * @param Base311_ActivityV2 an update document; assumes that code has been set
    * @return Service_Activity__c the matching service activity if present; null otherwise
    */
    private Service_Activity__c getServiceActivity(Case c, String activityCode) {
        for(Service_Activity__c ac : c.Service_Activities__r) {
            if(ac.Service_Type_Version_Activity__r.Activity_Code__c == activityCode) {
            	return ac;
            }
        }
        
        return null;
    }
    
    /**
    * @description Gets the activity outcome based on its outcome code
    * @param String the outcome code to search on
    * @return Activity_Outcome__c the activity outcome if the code is valid; null otherwise
    * @example getActivityOutcome('123')
    */
    public Activity_Outcome__c getActivityOutcome(String stvaCode, String aoCode) {
        List<Activity_Outcome__c> aos = [
            SELECT Id,
            (
            	SELECT Id, Question_Code__c, Override_Answer_Values__c,
                Question__r.Flex_Question_Code__c, Question__r.Data_Type__c,
                Question__r.Answer_Values__c, Dependencies__c, Question__r.Question__c,
                Is_Required_Question__c, Validations__c
                FROM Outcome_Questions__r
            )
            FROM Activity_Outcome__c
            WHERE Outcome_Code__c = :aoCode AND Service_Type_Version_Activity__r.Activity_Code__c = :stvaCode
        ];
        
        return aos.size() > 0 ? aos[0] : null;
    }
    
    /**
    * @description Gets the activity outcome response based on it's response code.
    * @param String the code of the response to pull
    * @return Activity_Outcome_Response__c the response if the code is valid; null otherwise
    * @example getActivityOutcomeResponse('ABC')
    */
    public Activity_Outcome_Response__c getActivityOutcomeResponse(String aoCode, String respCode) {
        List<Activity_Outcome_Response__c> aors = [
            SELECT Id, Canned_Response__r.Long_Response_Text__c, Additional_Comments_Required__c
            FROM Activity_Outcome_Response__c
            WHERE Response_Code__c = :respCode AND Activity_Outcome__r.Outcome_Code__c = :aoCode
        ];
        
        return aors.size() > 0 ? aors[0] : null;
    }
    
    private Map<String, Outcome_Question__c> getOutcomeQuestions(Activity_Outcome__c ao) {
        Map<String, Outcome_Question__c> result = new Map<String, Outcome_Question__c>();
        
        List<Outcome_Question__c> questions = ao.Outcome_Questions__r;
        
        System.debug(questions);
          
        for(Outcome_Question__c aq : questions) {
            result.put(aq.Question_Code__c, aq);
        }
        
        return result;
    }
    
    /**
    * @description Update a given service activity (specifyed by the activityCode code) for a given
    * service request. Fields are set if the relevant Base311_PatchValue has been set. If a field
    * is not set; the current value is used. NOTE: The one exception to this is attributes; if the outcome_code
    * changes; attributes are not copied forward as they are deleted when outcome_code changes.
    * @param Case The service request that the activity update should be applied to.
    * @param String the activity code you wish to partially update
    * @param Base311_PatchValue A patch value with keys for outcome_code, response_code, additional_comments,
    * finish_date, state and attribute
    * @return Service_Activity__c the updated Service Activity; containing all new data passed
    */
    global Service_Activity__c patchServiceActivity(Case c, String activityCode, Base311_PatchValue au) {
        Base311_PatchValue outcomeCode = Base311_PatchValue.fromPatchValue(au, 'outcome_code');
        Base311_PatchValue responseCode = Base311_PatchValue.fromPatchValue(au, 'response_code');
        Base311_PatchValue addComments = Base311_PatchValue.fromPatchValue(au, 'additional_comments');
        Base311_PatchValue finishDate = Base311_PatchValue.fromPatchValue(au, 'finish_date');
        Base311_PatchValue status = Base311_PatchValue.fromPatchValue(au, 'status');
        Base311_PatchValue attributes = Base311_PatchValue.fromPatchValue(au, 'attribute');
        
        Service_Activity__c act = getServiceActivity(c, activityCode);
        
        if(act == null) {
            throw new Base311_Exceptions.UnsupportedException('Invalid activity code ' + activityCode + ' for service request ' + c.Service_Request_Number__c);
        }
        
        String outcomeCodeString = outcomeCode.isSet ? String.valueOf(outcomeCode.value) : act.Activity_Outcome__r.Outcome_Code__c;
         
        Map<String, Object> attributeChanges = new Map<String, Object>();
        
        System.debug(act.Activity_Outcome__r);
        
        // collect our old answers first if our outcomeCode has not changed
        if(outcomeCodeString == act.Activity_Outcome__r.Outcome_Code__c) {
        	Map<String, Activity_Question__c> questionMap = getActivityQuestions(act);
            for(Activity_Question__c aq : questionMap.values()) {
                attributeChanges.put(aq.Question_Code__c, aq.Answer__c);
            }
        }
        
        System.debug(attributeChanges);
        
        if(attributes.isSet) {
            Map<String, Object> newAnswers = (Map<String, Object>) attributes.value;
            
            // replace or add new answers
            for(String key : newAnswers.keySet()) {
                attributeChanges.put(key, newAnswers.get(key));
            }
        } 
        
        Base311_ActivityV2 activityUpdate = new Base311_ActivityV2(
        	activityCode,
            outcomeCode.isSet ? (String) outcomeCode.value : act.Activity_Outcome__r.Outcome_Code__c,
            
        	// @TODO: Remove this magic value setting and replace with the old response code once
        	// we are storing it.
            responseCode.isSet ? (String) responseCode.value : act.Activity_Outcome_Response__c,
            addComments.isSet ? (String) addComments.value : act.Additional_Comments__c,
            attributeChanges,
            finishDate.isSet ? (String) finishDate.value : Base311_Helper.formatDate(act.Finish_Date__c),
            status.isSet ? (String) status.value : act.Status__c
        );
        
        return updateServiceActivity(c, activityUpdate);
    }
    
    /**
    * @description Update a given service activity (specifyed by the Base311_ActivityV2 code) for a given
    * service request. All fields; regardless if they are set or not, are set. If a question is omitted from 
    * the activity attribute; a null is used.
    * @param Case The service request that the activity update should be applied to.
    * @param Base311_ActivityV2 The information regarding which service activity should be updated. The code
    * field is used to determine which service activity to update.
    * @return Service_Activity__c the updated Service Activity; containing all new data passed
    */
    global Service_Activity__c updateServiceActivity(Case c, Base311_ActivityV2 activityUpdate) {
        Service_Activity__c ac = getServiceActivity(c, activityUpdate.code);
        
        if(ac == null) {
            throw new Base311_Exceptions.UnsupportedException('Invalid activity code ' + activityUpdate.code + ' for service request ' + c.Service_Request_Number__c);
        }
        
        Activity_Outcome__c ao = activityUpdate.getActivityOutcome();
        
        if(ao == null) {
            throw new Base311_Exceptions.UnsupportedException('Unknown outcome ' + activityUpdate.outcome_code);
        }

        Activity_Outcome_Response__c resp = activityUpdate.getActivityOutcomeResponse();
        
        if(resp == null && String.isNotEmpty(activityUpdate.response_code)) {
            throw new Base311_Exceptions.UnsupportedException('Unknown canned response ' + activityUpdate.response_code);
        }
        
        // update the comments to either null (if they've picked nothing) or the canned response
        ac.External_Comments__c = resp == null ? null : resp.Canned_Response__r.Long_Response_Text__c; 
        ac.Activity_Outcome_Response__c = resp == null ? null : resp.Id;
        
        Map<String, Activity_Question__c> questionMap = getActivityQuestions(ac);
        
        // if we are changing outcomes; we should remove our existing question answers
        if(ao.Id != ac.Activity_Outcome__r.Id) { 
            delete questionMap.values();
			questionMap = new Map<String, Activity_Question__c>();
        }
        
        // set the activity outcome
        ac.Activity_Outcome__c = ao.Id;
 
        // status is always completed when updating an activity
        // this will need to change later
        ac.Status__c = 'Complete';
        
        ac.Finish_Date__c = Base311_Helper.parseDate(activityUpdate.finish_date);
        
        ac.Additional_Comments__c = activityUpdate.additional_comments;
        
        update ac;
        
        Map<String, Outcome_Question__c> mappedOQs = getOutcomeQuestions(ao);
         
        for(String key : mappedOQs.keySet()) { 
            if(!activityUpdate.attribute.containsKey(key)) {  
                activityUpdate.attribute.put(key, null);
            }
        }
         
        for(String attributeCode : activityUpdate.attribute.keySet()) {
            Outcome_Question__c oq = mappedOQs.get(attributeCode);
            
            if(oq == null) {
                throw new Base311_Exceptions.UnsupportedException('Unknown outcome question code '  + attributeCode);
            }
            
            if(!questionMap.containsKey(attributeCode)) {
                questionMap.put(attributeCode, new Activity_Question__c(
                	Service_Request__c = c.Id,
                    Service_Activity__c = ac.Id,
                    Outcome_Question__c = oq.Id
                ));
            }
            
            Base311_Attribute attr = new Base311_Attribute(attributeCode, activityUpdate.attribute.get(attributeCode), oq);
            
            attr.setContext(activityUpdate.attribute).validate().throwErrors();
            
            // based on type; convert value using logic 
            // in the Base311_Attribute (needs to be extracted)
            questionMap.get(attributeCode).Answer__c = attr.stringifyValue();
        }
        
        System.debug(questionMap);
        
        upsert questionMap.values();
        
        return ac;
    }
}