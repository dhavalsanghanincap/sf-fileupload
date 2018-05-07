/**
* @author 
* @date 
* @group 
* @group-content
* @description 
*/
global class Base311_Helper {

    private static String JSON_POSTFIX = '.json';
    private static String JSON_MEDIATYPE = 'application/json';
    private static String ACCEPTS_HEADER = 'Accept';
    private static String JSON_PREFIX = 'Incap311';
    private static String ISO_8601_DATE_TIME_FORMAT = 'yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'';
    private static String HUMAN_DATE_TIME_FORMAT = 'MM/dd/yyyy HH:mm:ss';
    private static String HUMAN_DATE_FORMAT = 'MM/dd/yyyy';

    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    public static List<String> getRelatedFields(List<String> fields, String prefix) {
     	List<String> finalFields = new List<String>();
        
        for(String field : fields) {
            if(field.startsWith(prefix + '.')) {
                finalFields.add(field.replace(prefix + '.', ''));
            }
        }
        
        return finalFields;
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global static List<String> csvToList(String val) {
        List<String> valList = val.split(',');
        
        for(String item : valList) {
            item = item.trim();
        }
        
        return valList;
    } 
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global static String currentDayOfWeek() {
        return System.now().format('EEEE');
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global static String friendlyFormat(Object val) {
        return String.valueOf(val);
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global static String formatHumanDate(Datetime d) {
        return d.format(HUMAN_DATE_FORMAT);
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global static String formatHumanDatetime(Datetime d) {
        return d.format(HUMAN_DATE_TIME_FORMAT);
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global static String formatDate(Datetime d) {
        return d.formatGMT(ISO_8601_DATE_TIME_FORMAT);
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global static Boolean listContains(List<Object> objs, Object val) {
        for(Object obj : objs) {
            if(obj == val) {
                return true;
            }
        }
        
        return false;
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global static Object deepGet(String param, SObject sobj) {
        List<String> pieces = param.split('\\.');
        
        if(pieces.size() == 1) {
            return sobj.get(pieces[0]);
        }
        
        String nestedName = pieces[0];
        
        pieces.remove(0);
        
        return deepGet(String.join(pieces, '.'), sobj.getSObject(nestedName));
    }
	
    
    /**
    * @description Gets all field values for a give Map<String, Object> based on a list
    * of comma seperated JSON paths. Values are returned mapped from field => value (the
    * entire passed in field, commas and all)
    * @param Map<String, Object> the map to search
    * @param List<String> the list of comma seperated search paths
    * @return Map<String, Object> the matching value; null if no matches.
    */
    public static Map<String, Object> getFields(Map<String, Object> entity, List<String> possibleFields) {
        Map<String, Object> mappedValues = new Map<String, Object>();
        
        for(String field : possibleFields) {
            mappedValues.put(field, getField(entity, field));
        }
        
        return mappedValues;
    }
    
    /**
    * @description Gets the value of a Map<String, Object> based on a comma seperated
    * JSON path (ie; attributes.some_thing, attributes.other_thing). The first matching
    * path's value is returned.
    * @param Map<String, Object> the map to search
    * @param String the comma sepeated list of search fields
    * @return Object the matching value; null if no matches.
    */
    public static Object getField(Map<String, Object> entity, String possibleFields) {
        List<String> individualFields = possibleFields.split(',');
        
        Object result = null;
    
        for(String possibleField : individualFields ) {
            result = getSingleField(entity, possibleField);
            
            if(result != null) {
                return result;
            }
            
        }
        
        return result;    
    }    
    
    public static Object getSingleField(Map<String, Object> entity, String field) {
        
        if(entity == null) {
            return null;
        }
        
        List<String> fieldPieces = field.split('\\.');
            
        if(fieldPieces.size() > 1) {
            String nextField = fieldPieces[0];
        
            fieldPieces.remove(0);
            
            String newPath = String.join(fieldPieces, '.'); 
            
            return getField((Map<String, Object>) entity.get(nextField), newPath);
        }
        
        return entity != null && entity.containsKey(field) ? entity.get(field) : null;
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global static Boolean listContains(List<SObject> objs, String param, String value) {
        for(SObject obj : objs) {
            if(deepGet(param, obj) == value) {
                return true;
            }
        }
        
        return false;
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global static Map<String, Object> keyBy(String key, List<SObject> objs) {
        Map<String, SObject> mapped = new Map<String, SObject>();
        
        for(SObject obj : objs) {
            mapped.put(String.valueOf(obj.get(key)), obj);
        }
        
        return mapped;
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global static Double getDoubleBodyParam(String param) {
        Map<String, Object> params = getRequestBody();
        return params.containsKey(param) ? Double.valueOf(params.get(param)) : null;
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global static String getStringBodyParam(String param) {
        Map<String, Object> params = getRequestBody();
        return params.containsKey(param) ? String.valueOf(params.get(param)) : null;
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global static Map<String, Object> getMapBodyParam(String paramName) {
        Map<String, Object> params = getRequestBody();
        return params.containsKey(paramName) ? (Map<String, Object>) params.get(paramName) : new Map<String, Object>();
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global static List<Object> getListBodyParam(String paramName) {
        Map<String, Object> params = getRequestBody();
        return params.containsKey(paramName) ? (List<Object>) params.get(paramName) : new List<Object>();
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global static Map<String, Object> getRequestBody() {
        String body = RestContext.request.requestBody == null ? '{}' : RestContext.request.requestBody.toString();
        
        if(String.isBlank(body)) {
            body = '{}';
        }
        
        return (Map<String, Object>) JSON.deserializeUntyped(body);
    }
  
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    // NOTE: Assumption that date will always be in USA format of MM/DD/YYYY.
    // TODO: Small unit test.
    global static String convert12HourTo24Hour(String sDate) {
      if (sDate == null) {
        return null;
      }

      List<String> parts = sDate.split(' ');
      List<String> dateParts = parts[0].split('/');
      List<String> timeParts = parts.size() >= 2 ? parts[1].split(':') : null;
      String meridiem = parts.size() == 3 ? parts[2] : '';
    
      Integer month = Integer.valueOf(dateParts[0]);
      Integer day = Integer.valueOf(dateParts[1]);
      Integer year = Integer.valueOf(dateParts[2]);
      
      Integer hour = Integer.valueOf(timeParts[0]);
      Integer minutes = Integer.valueOf(timeParts[1]);

      if (String.isNotBlank(meridiem) && meridiem.equalsIgnoreCase('pm')) {
        hour = hour + 12;
      }
      // Grab the users timezone information.
      TimeZone tz = UserInfo.getTimeZone();
      System.debug('User Timezone: ' + tz.getDisplayName());
      Integer offset = tz.getOffset(DateTime.now());
      String offsetStr = '';
      System.debug('----> Offset: ' + offset);
      offset = offset / (60 * 60 * 1000);
      System.debug('----> Offset in Hours: ' + offset);

      if (offset < 10 && offset >= 0) {
        offsetStr = '+0' + String.valueOf(offset) + ':00';
      } else if (offset < 0) { 
        offsetStr = '-0' + String.valueOf(offset).remove('-') + ':00';
      }

      // Example return: 2017-01-02T00:00:00-05:00
      String finalDatetimeStr = 
        year + '-' + 
        (month > 10 ? String.valueOf(month) : ('0' + String.valueOf(month))) + '-' + 
        (day > 10 ? String.valueOf(day) : ('0' + String.valueOf(day))) + 
        'T' + 
        hour + ':' + 
        minutes + ':00' +
        offsetStr;
      return finalDatetimeStr;
    }      
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global static Datetime parseDate(String sDate) {
        if(sDate == null) {
            return null;
        }
        
        // try to parse the date as JSON first; if we can't, try to parse it as a
        // "simple" datetime
        try {
            System.debug('----> Attempting to parse sDate as JSON...');
            return (Datetime) JSON.deserialize('"' + sDate + '"', Datetime.class);
        } catch (JSONException e) {
            // eat it
        }
        
        try {
            System.debug('----> Attempting Datetime.valueOf()...');
            return Datetime.valueOf(sDate);
        } catch (TypeException e) {
            // eat it
        }
        
        List<String> parts = sDate.split(' ');
        List<String> dateParts = parts[0].split('/');
        List<String> timeParts = parts.size() == 2 ? parts[1].split(':') : null;
        
        Integer year = Integer.valueOf(dateParts[2]);
        Integer month = Integer.valueOf(dateParts[0]);
        Integer day = Integer.valueOf(dateParts[1]);
        
        return timeParts != null ? 
            Datetime.newInstance(year, month, day, Integer.valueOf(timeParts[0]), Integer.valueOf(timeParts[1]), Integer.valueOf(timeParts[2])) : 
            Datetime.newInstance(year, month, day);
    }
  
  /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global static List<String> getCSLParam(String paramName) {
        String value = Base311_Helper.getParam(paramName);
        
        if(value == null) {
            return new List<String>();
        }
        
        return value.split(',');
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global static Datetime getDatetimeParam(String paramName) {
        return parseDate(Base311_Helper.getParam(paramName));
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global static Boolean getBooleanParam(String paramName) {
        String val = Base311_Helper.getParam(paramName);
        return val != null ? Boolean.valueOf(val) : false;
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global static String getParam(String paramName, String defaultValue) {
        Map<String, String> params = RestContext.request.params == null ? new Map<String, String>() : RestContext.request.params;
        
        return params.containsKey(paramName) ? params.get(paramName) : defaultValue;
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global static String getParam(String paramName) {
        Map<String, String> params = RestContext.request.params == null ? new Map<String, String>() : RestContext.request.params;
        return params.containsKey(paramName) ? params.get(paramName) : getStringBodyParam(paramName);
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global static Map<String, String> urlParams(String requestUri, String requestMapping) {
        Map<String, String> params = new Map<String, String>();
        
        requestUri = requestUri.replaceFirst('/' + JSON_PREFIX, '');
        
        List<String> targetPieces = requestMapping.split('/');
        List<String> urlPieces = requestUri.split('/');
         
         for(Integer i = 0; i < urlPieces.size() && i < targetPieces.size(); i++) {
            String targetPiece = targetPieces[i];
            String urlPiece = urlPieces[i];
             
            if(targetPiece.startsWith(':')) {
                params.put(targetPiece.replaceFirst(':', ''), urlPiece.split('\\.')[0]);
            }
            else if(!targetPiece.equalsIgnoreCase(urlPiece)) {
                return null;
            }
        }
         
        return params;
    }

    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global static Boolean isRequestXML() {
        RestRequest req = RestContext.request; 
        String requestUri = req.requestUri;
        String acceptsHeader = req.headers.get(ACCEPTS_HEADER);
        
        // Open 311 should always assume XML unless a JSON header or extension is provided
        if(requestUri.endsWith(JSON_POSTFIX) || (acceptsHeader != null && acceptsHeader.equals(JSON_MEDIATYPE))) {
            return false;
        }
        
        return true;
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global static String getContentType() {
        return isRequestXML() ? 'text/xml' : 'application/json';
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global static void setResponse(String body) {
        setResponse(body, 200);
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global static void setResponse(String body, Integer statusCode) {
        RestResponse resp = RestContext.response;
        resp.responseBody = Blob.valueOf(body);
        resp.statusCode = statusCode;
        resp.headers.put('Content-Type', getContentType());
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
   /*
    * returns a case with all field values as well as related service activities and service questions 
    */ 
    global static Case getCompleteCase(Case c) { 
        Schema.DescribeSObjectResult caseDescribe = Case.sObjectType.getDescribe();
        Schema.DescribeSObjectResult sqDescribe = Incap311__Service_Question__c.sObjectType.getDescribe();
        Schema.DescribeSObjectResult saDescribe = Incap311__Service_Activity__c.sObjectType.getDescribe();
        
        Set<String> caseFields = new Set<String>();
        Set<String> sqFields = new Set<String>();
        Set<String> saFields = new Set<String>();
        
        for(String apiName : caseDescribe.fields.getMap().keySet()){
           caseFields.add(apiName);
        }
        
        for(String apiName : sqDescribe.fields.getMap().keySet()){
           sqFields.add(apiName);
        }
        
        for(String apiName : saDescribe.fields.getMap().keySet()){
           saFields.add(apiName);
        }
        
        String soql = 'SELECT ' + String.join(new List<String>(caseFields), ',') + ', ' + 
        ' ( SELECT ' + String.join(new List<String>(sqFields), ',') + ' FROM Incap311__Service_Questions__r ), ' +
        ' ( SELECT ' + String.join(new List<String>(saFields), ',') + ' FROM Incap311__Service_Activities__r ) ' +
        ' FROM Case WHERE Id = \'' + String.escapeSingleQuotes(c.Id) + '\'';
        
        return Database.query(soql);
    }
    
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    /*
    * returns a service type version with all field values as well as related activities (via service type version activities) and flex questions (via service type version question) 
    */ 
    global static Incap311__Service_Type_Version__c getCompleteServiceTypeVersion(String stvId) { 
        Schema.DescribeSObjectResult versionDescribe = Incap311__Service_Type_Version__c.sObjectType.getDescribe();
        Schema.DescribeSObjectResult stvqDescribe = Incap311__Service_Type_Version_Question__c.sObjectType.getDescribe();
        Schema.DescribeSObjectResult stvaDescribe = Incap311__Service_Type_Version_Activity__c.sObjectType.getDescribe();
        
        Set<String> versionFields = new Set<String>();
        Set<String> stvqFields = new Set<String>();
        Set<String> stvaFields = new Set<String>();
        
        for(String apiName : versionDescribe.fields.getMap().keySet()){
           versionFields.add(apiName);
        }
        
        for(String apiName : stvqDescribe.fields.getMap().keySet()){
           stvqFields.add(apiName);
        }
        
        for(String apiName : stvaDescribe.fields.getMap().keySet()){
           stvaFields.add(apiName);
        }
        
        String soql = 'SELECT ' + String.join(new List<String>(versionFields), ',') + ', ' + 
        ' ( SELECT ' + String.join(new List<String>(stvqFields), ',') + ' FROM Incap311__Service_Type_Version_Questions__r ), ' +
        ' ( SELECT ' + String.join(new List<String>(stvaFields), ',') + ' FROM Incap311__Service_Type_Version_Activities__r ) ' +
        ' FROM Incap311__Service_Type_Version__c WHERE Id = \'' + String.escapeSingleQuotes(stvId) + '\'';
        
        return Database.query(soql);
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global static void handleException(Exception e) {
        RestResponse resp = RestContext.response;
        
        
        if(getBooleanParam('verbose_errors')) {
            throw e;
        }
    
        if(e instanceof Base311_Exceptions.SecurityException) {
            setResponse(new ExceptionMessage(1, e.getMessage()).serialize(), 401);
            return;
        }
    
        if(e instanceof Base311_Exceptions.NotFoundException) {
            setResponse(new ExceptionMessage(2, e.getMessage()).serialize(), 404);
            return;
        }
        
        if(e instanceof Base311_Exceptions.UnsupportedException) {
            ExceptionMessage em;
            
            Base311_Exceptions.UnsupportedException ue = (Base311_Exceptions.UnsupportedException) e;
            
            if(ue.errors != null) {
                em = new ExceptionMessage(3, ue.errors);
            } else {
                em = new ExceptionMessage(3, ue.getMessage());
            }
        
            setResponse(em.serialize(), 400);
            return;
        }
        
        if(e instanceof Base311_Exceptions.ServerException) {
            setResponse(new ExceptionMessage(4, e.getMessage()).serialize(), 500);
            return;
        }
         
        setResponse(new ExceptionMessage(0, 'Unexpected error - this could be caused by configuration - please contact support if the error persists.').serialize(), 500);
    }
    
    global class RestResult {
        Integer statusCode;
        String body;
        
        public RestResult(Integer statusCode, String body){ 
            this.statusCode = statusCode;
            this.body = body;
        }
    }
    
    public class ExceptionMessage {
        private Integer code;
        private String description;
        private List<String> errors; 
    
        public ExceptionMessage(Integer errorCode, String message) {
            this.code = errorCode;
            this.description = message;
            this.errors = null;
        }
    
        public ExceptionMessage(Integer errorCode, List<String> errors) {
            this.code = errorCode;
            this.description = null;
            this.errors = errors;
        }
        
        public String serialize() {
            if(Base311_Helper.isRequestXML()) {
                if(description != null) {
                    return '<errors><error><code>' + code + '</code><description>' + description + '</description></error></errors>';
                }
                
                String result = '<errors>';
                
                for(String err : errors) {
                    result += '<error>';
                    result += '<code>' + code + '</code>';
                    result += '<description>' + err + '</description>';
                    result += '</error>';
                }    
                
                result += '</errors>';
                
                return result;
            }
            
            List<ExceptionMessage> msgs = new List<ExceptionMessage>();
            
            if(errors != null) {
                for(String err : errors) {
                    msgs.add(new ExceptionMessage(code, err));
                }
            } else {
                msgs.add(this);
            }
            
            return JSON.serialize(msgs, true);
        }
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global static List<Service_Type_Version__c> filterTypesByBusinessHours(List<Service_Type_Version__c> stVersions) {
        List<Service_Type_Version__c> filtered = new List<Service_Type_Version__c>();
        
        String currDay = Base311_Helper.currentDayOfWeek();
        
        List<BusinessHours> busHrs = [SELECT Id, Name, SundayStartTime, SundayEndTime, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime,
                                            WednesdayStartTime, WednesdayEndTime, ThursdayStartTime, ThursdayEndTime, FridayStartTime, FridayEndTime,
                                            SaturdayStartTime, SaturdayEndTime
                                        FROM BusinessHours WHERE isActive = true];
                                        
        Map<String, BusinessHours> busHrsMap = new Map<String, BusinessHours>();
        for (BusinessHours bh : busHrs) {
            busHrsMap.put(bh.Name, bh);
        }
        
        // loop through the versions and see if a corresponding entry exists in the business hours, if so check the hours and if not inside the hours, remove from list
        BusinessHours checkBH;
        Time startTime;
        Time endTime;
        for (Service_Type_Version__c stv : stVersions) {
            if (stv.Enable_Business_Hours__c && busHrsMap.containsKey(stv.Version_Code__c)) {
                checkBH = busHrsMap.get(stv.Version_Code__c);

                if (currDay.equalsIgnoreCase('Sunday')) {
                    startTime = checkBH.SundayStartTime;
                    endTime = checkBH.SundayEndTime;
                }
                else if (currDay.equalsIgnoreCase('Monday')) {
                    startTime = checkBH.MondayStartTime;
                    endTime = checkBH.MondayEndTime;
                }
                else if (currDay.equalsIgnoreCase('Tuesday')) {
                    startTime = checkBH.TuesdayStartTime;
                    endTime = checkBH.TuesdayEndTime;
                }
                else if (currDay.equalsIgnoreCase('Wednesday')) {
                    startTime = checkBH.WednesdayStartTime;
                    endTime = checkBH.WednesdayEndTime;
                }
                else if (currDay.equalsIgnoreCase('Thursday')) {
                    startTime = checkBH.ThursdayStartTime;
                    endTime = checkBH.ThursdayEndTime;
                }
                else if (currDay.equalsIgnoreCase('Friday')) {
                    startTime = checkBH.FridayStartTime;
                    endTime = checkBH.FridayEndTime;
                }
                else if (currDay.equalsIgnoreCase('Saturday')) {
                    startTime = checkBH.SaturdayStartTime;
                    endTime = checkBH.SaturdayEndTime;
                }
                
                Time currTime = DateTime.now().time();
                if ((currTime >= startTime) && (currTime <= endTime)) {
                    filtered.add(stv);
                }
            }
            else {
                filtered.add(stv);
            }
        }
        
        return filtered;
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global static Boolean getTriggerEnabled(String triggerObject) {
		triggerObject = triggerObject.replace('__c', '');
    	List<X311_Trigger__mdt> triggers = [SELECT Id, DeveloperName, Enabled__c FROM X311_Trigger__mdt WHERE DeveloperName = :triggerObject];
    	if ((triggers != null) && (triggers.size() == 1)) {
    		return triggers[0].Enabled__c;
    	}
    	
    	return false;
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global static Boolean getFeatureEnabled(String featureName) {
    	List<X311_Trigger__mdt> features = [SELECT Id, DeveloperName, Enabled__c FROM X311_Trigger__mdt WHERE DeveloperName = :featureName];
    	if ((features != null) && (features.size() == 1)) {
    		return features[0].Enabled__c;
    	}
    	
    	return false;
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global static Integer getNextUnusedVersionNumber(Id svcTypeVersionId) {
    	
    	Service_Type_Version__c stv = [SELECT Id, Service_Type__c, Version_Number__c FROM Service_Type_Version__c WHERE Id = :svcTypeVersionId];
    	List<Service_Type_Version__c> vers = [SELECT Id, Service_Type__c, Version_Number__c FROM Service_Type_Version__c WHERE Service_Type__c = :stv.Service_Type__c];
    	if (vers != null) {
    		List<Integer> verList = new List<Integer>();
    		for (Service_Type_Version__c ver : vers) {
    			verList.add(Integer.valueOf(ver.Version_Number__c));
    		}
    		verList.sort();
    		Set<Integer> verSet = new Set<Integer>(); 
    		verSet.addAll(verList);
    		
    		Boolean found = false;
    		Integer num = 0;
    		do {
    			num++;
    			if (!verSet.contains(num)) {
    				found = true;
    			}
    		} while (!found);
    		return num;
    	}
    	
    	return 1;
    }
   
}