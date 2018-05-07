/**
* @author 
* @date 
* @group 
* @group-content
* @description 
*/
global without sharing class Base311_ServiceTypeVersionActivityHelper {
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    /*
     *  Ensures that the service type version activity does not have an order value identical to another for the same service type version
     */
    public static void verifyUniqueOrder(List<Service_Type_Version_Activity__c> stvActivities) {
    	Set<Id> svcTypVerIds = new Set<Id>();
    	for (Service_Type_Version_Activity__c newAct : stvActivities) {
    		svcTypVerIds.add(newAct.Service_Type_Version__c);
    	}
    	
		List<Service_Type_Version_Activity__c> existingActs = [SELECT Id, Service_Type_Version__c, Order__c FROM Service_Type_Version_Activity__c WHERE Service_Type_Version__c = :svcTypVerIds];
		
		// map activities by service type version
		Map<String, List<Service_Type_Version_Activity__c>> activityMap = new Map<String, List<Service_Type_Version_Activity__c>>();
		for (Service_Type_Version_Activity__c stva : existingActs) {
			if (!activityMap.containsKey(stva.Service_Type_Version__c)) {
				List<Service_Type_Version_Activity__c> newList = new List<Service_Type_Version_Activity__c>();
				newList.add(stva);
				activityMap.put(stva.Service_Type_Version__c, newList);
			}
			else {
				activityMap.get(stva.Service_Type_Version__c).add(stva);
			}
		}
    	
		// loop through and if a version activity is found with an identical order, add error to record and continue loop
		for (Service_Type_Version_Activity__c newAct : stvActivities) {
			if ((newAct.Service_Type_Version__c != null) && (activityMap.containsKey(newAct.Service_Type_Version__c))) {
				// get the version activity list for this service type version
                List<Service_Type_Version_Activity__c> chkActs = activityMap.get(newAct.Service_Type_Version__c);
                for (Service_Type_Version_Activity__c chkAct : chkActs) {
                	if ((newAct.Id == null) || ((newAct.Id != null) && (newAct.Id != chkAct.Id))) {
                    	if ((String.isNotBlank(String.valueOf(newAct.Order__c))) && (newAct.Order__c == chkAct.Order__c)) {
                        	newAct.addError('You cannot create/update the Service Type Version Activity for this service type version with an identical Order.  Please apply a unique Order');
                        	continue;
                    	}
                	}
                }
			}
		}
    }
    
    
     /* public static void checkMailMergeFields(List<Service_Type_Version_Activity__c> stVersions){
        for(Service_Type_Version_Activity__c stv : stVersions) {
            String Error = checkMailMergeFields(stv,Base311_MailMerge.getFieldNames(stv.Rich_Email_Intro_Close__c));
            if(Error != null){
                 stv.Rich_Email_Intro_Close__c.addError(error);
            }
            Error =  checkMailMergeFields(stv,Base311_MailMerge.getFieldNames(stv.Rich_Email_Body_Close__c));
            if(Error != null){
                stv.Rich_Email_Body_Close__c.addError(Error);
            }
            Error =  checkMailMergeFields(stv,Base311_MailMerge.getFieldNames(stv.Rich_Email_Closing_Close__c));
            if(Error != null){
                stv.Rich_Email_Closing_Close__c.addError(Error);
            }
        }
    }


    public static String checkMailMergeFields(Service_Type_Version_Activity__c stv, List<String> fields){
        for(String field : fields) {
            System.debug('Does '+field+' exist '+Base311_Schema.doesFieldExist('Service_Activity__c',field));
            try{
                if(!Base311_Schema.doesFieldExist('Case',field)){
                    return 'Merge field '+Field+' cannot be found on the Activity object';
                }
            }catch(Exception e){
                return 'Merge field '+Field+' cannot be found on the Activity object';
            }
        }
        return null;
    }*/
}