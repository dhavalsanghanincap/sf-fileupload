/**
* @author John Benson
* @date 10/28/2016  
* @group util
* @group-content
* @description Class to store all the utility and logic methods related to Case (Service reuqest) object
*/
global class Base311_Case extends Base311_Object {
    private static List<String> VALID_PATCH_STATUSES = new List<String>{ 'In Progress', 'Open', 'Closed' };
    
    private Base311_Service_ServiceType rsst = new Base311_Service_ServiceType();
        
    global Id id;
    global String description;
    global String status;
    global String mediaUrl;
    global Service_Type_Version__c serviceType;
    global String serviceCode;
    global String duplicateParentId;
    global String source = 'Agent';
    global String origin = 'Phone';
    global String parentRequestNumber;
    global Map<String, Object> context;
    
    public Base311_Case() {
    
    }
    

    global Base311_Case(String description, String status, String mediaUrl, String serviceCode, String source, String origin) {
        this(null, description, status, mediaUrl, serviceCode, source, origin);
    }
    
    global Base311_Case(Id caseId, String description, String status, String mediaUrl, String serviceCode, String origin, String source) {
        this.id = caseId;
        this.description = description;
        this.status = status;
        this.mediaUrl = mediaUrl;
        this.serviceCode = serviceCode;
        this.source = source;
        this.origin = origin;
        this.serviceType = rsst.getServiceType(serviceCode, true);
    }
 
    /**
    * @description This method is used by Base311_Service_Wrapper to augment the data it receives from the client
    * @param 
    * @param 
    * @return 
    * @example
    */ 
    public Base311_Case fetchServiceType() {
         rsst = new Base311_Service_ServiceType();
        
        this.serviceType = rsst.getVersionById(this.serviceType.Id);
        
        return this;
    }
    
    global Base311_Case(Id caseId, String description, String status, String mediaUrl, Service_Type_Version__c serviceType, String origin, String source) {
        this.id = caseId;
        this.description = description;
        this.status = status;
        this.mediaUrl = mediaUrl;
        this.serviceCode = serviceType != null ? serviceType.Name : null;
        this.serviceType = serviceType;
        this.source = source;
        this.origin = origin;
    }
    
    /**
    * @description method to validate status
    * @return Base311_Case
    * @example
    */
    global Base311_Case validateStatus() {
        for(String VALID_STATUS : VALID_PATCH_STATUSES) {
            if(VALID_STATUS == status) {
                return this;   
            }
        }
        
        this.addError('Service request status must be one of : ' + String.join(VALID_PATCH_STATUSES, ', '));
        
        return this;
    }
    
    /**
    * @description Method to validate days of week
    * @return true or false
    * @example
    */
    private Boolean dowsValid() {
        if(!String.isEmpty(serviceType.Days_Of_Week__c)) {
            List<String> dows = serviceType.Days_Of_Week__c.split(';');
            
            for(String dow : dows) {
                if(dow == Base311_Helper.currentDayOfWeek()) {
                    return true;
                }
            }
            
            return false;
        }
        
        return true;
    }
    
    /**
    * @description method to validate business hours
    * @return true or false
    * @example
    */
    private Boolean businessHoursValid() {
        List<BusinessHours> bhs = [ 
            SELECT Id 
            FROM BusinessHours 
            WHERE Name = :serviceType.Service_Type_Code__c AND IsActive = true
        ];
        
        // assuming if Business Hours isn't configured,
        // even though its enabled, that it should be allowed
        if(bhs.size() != 0) {
            BusinessHours bh = bhs[0];
            
            if(!BusinessHours.isWithin(bh.Id, DateTime.now())) {
                return false;
            }
        }
        
        return true;
    }
    
    /**
    * @description Validatest the context with the current Service Type Version. 
    * If either alert validations or inline validations fail; an error will be added to the internal
    * state of the Case and thrown late
    */
    private void contextValid() {  
        Incap311.Base311_Condition_Evaluator evaluator = new Incap311.Base311_Condition_Evaluator(context);
        Object inlineMessage = evaluator.message(Incap311.Base311_DependentValue.fromJSON(serviceType.Incap311__Validations__c));
        Object alertMessage = evaluator.message(Incap311.Base311_DependentValue.fromJSON(serviceType.Incap311__Alert_Validations__c));
        
        if(inlineMessage != null) {
            this.addError(String.valueOf(inlineMessage));
        } 
        
        if(alertMessage != null) {
            this.addError(String.valueOf(alertMessage));            
        }
    }
    
    /**
    * @description method for service request validation
    * @return void
    * @example
    */
    protected override void validation() {
        if(this.id != null) {
            validateStatus();
        }
        
        if(id == null && serviceCode == null && serviceType == null) {
            this.addError('Service code is required');
        }
        
        if(serviceType == null) {
            this.addError('Service type could not be found for service_code ' + this.serviceCode);
        }
     
        if(serviceType != null) {
            if(!this.dowsValid()) {
                this.addError('This service type for this service request is only available on one of ' + serviceType.Days_Of_Week__c);
            }
            
            if(serviceType.Enable_Business_Hours__c && !this.businessHoursValid()) {
                this.addError(this.serviceCode + ' is not currently enabled as it is outside of its normal business hours.');
            }
            
            contextValid();
        }
    }
    
    /**
    * @description method to validate
    * @param throwExceptions true or false
    * @return true
    * @example
    */
    global Boolean validate(Boolean throwExceptions) {
        return true;  
    }
     
}