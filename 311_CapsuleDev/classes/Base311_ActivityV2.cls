/**
* @author John Benson
* @deprecated
* @date 3/28/2017   
* @group 
* @group-content
* @description DEP
*/
global class Base311_ActivityV2 extends Base311_Object {
    
    private static Base311_Service_ActivityV2 sa = new Base311_Service_ActivityV2();
     
    global Map<String, Object> attribute;
    global String code;
    global String outcome_code;
    global String response_code;
    global String additional_comments;
    global String finish_date;
    global String status;
    
    global Base311_ActivityV2(String code, String outcome_code, String response_code, String additional_comments, Map<String, Object> attribute, String finish_date, String status) {
        this.code = code;
        this.outcome_code = outcome_code;
        this.response_code = response_code;
        this.additional_comments = additional_comments;
        this.attribute = attribute;
        this.finish_date = finish_date;
        this.status = status;
    }
    
    private Activity_Outcome__c ao;
    private Activity_Outcome_Response__c aor;

    /**
    * @description getter method get activityOutcome response
    * @param none 
    * @return Activity_Outcome_Response__c
    * @example
    */
    global Activity_Outcome_Response__c getActivityOutcomeResponse() {
        if(aor == null || aor.Response_Code__c != response_code) {
            aor = sa.getActivityOutcomeResponse(outcome_code, response_code);
        }
        
        return aor;
    }
    
    /**
    * @description getter method get activityOutcome 
    * @param none
    * @return Activity_Outcome__c
    * @example
    */
    global Activity_Outcome__c getActivityOutcome() {
        // only update our ref if we dont have one or the code changed
        if(ao == null || ao.Activity_Outcome_Code__c != outcome_code) {
            ao = sa.getActivityOutcome(code, outcome_code);
        }
        
        return ao;
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    protected override void validation() {
        
    }
}