/**
* @author John Benson
* @date 11/30/2016
* @group 
* @group-content
* @description 
*/

global class Base311_Activity extends Base311_Object{
    private static List<String> ACTIVITY_STATUSES = new List<String>{ 'In Progress', 'Not Started', 'Complete' };
    
    global String code;
    global String status;
    global String completion_date;
    global String comment;
    private Service_Activity__c sa;
    
    /**
    * @description validation method 
    * @param 
    * @param 
    * @return 
    * @example
    */
    protected override void validation() {
        Set<String> statusSet = new Set<String>();
        statusSet.addAll(ACTIVITY_STATUSES);
        
        if(sa == null) {
            this.addError('Unknown service ' + code + '. Please verify that your code is correct. If you are certain the code is correct, please contact support.');
        }   
        
        if(status != null && !statusSet.contains(status)) {
            this.addError('Activity status must be one of : ' + String.join(ACTIVITY_STATUSES, ', '));
        }
    }
    
    
    global Base311_Activity () {
        
    }
    
    
    global Base311_Activity (String code, String status, String completionDate, String comment) {
        this.code = code;
        this.status = status;
        this.completion_date = completionDate;
        this.comment = comment;
    }

    /**
    * @description Method to set activity from service activity as param
    * @param sa is Service_Activity__c
    * @return Activity record
    * @example
    */
    global Base311_Activity setSA(Service_Activity__c sa) {
        if(sa != null && sa.Name != code) {
            throw new Base311_Exceptions.ServerException('Tried to associate service ' + sa.Name + ' with ' + code);
        }
        
        this.sa = sa;
        return this;    
    }
    
    /**
    * @description method to get activity from list of object
    * @param items is list of object
    * @return list of Base311_Activity
    * @example
    */
    global static List<Base311_Activity> fromList(List<Object> items) {
        List<Base311_Activity> result = new List<Base311_Activity>();
        
        for(Object o : items) {
            result.add(Base311_Activity.fromMap((Map<String, Object>) o));
        }
        
        return result;
    }
    
    /**
    * @description method to get new activity record from map
    * @param maped is map of string and object
    * @return Base311_Activity record
    * @example
    */
    global static Base311_Activity fromMap(Map<String, Object> maped) {
        Base311_Activity a = new Base311_Activity();
        a.code = maped.containsKey('code') ? String.valueOf(maped.get('code')) : null;
        a.status = maped.containsKey('status') ? String.valueOf(maped.get('status')) : null;
        a.completion_date = maped.containsKey('completion_date') ? String.valueOf(maped.get('completion_date')) : null;
        a.comment = maped.containsKey('comment') ? String.valueOf(maped.get('comment')) : null;
        return a;
    }
}