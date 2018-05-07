/*********
* @author 
* @date 
* @group 
* @group-content
* @description 
*/
Global with sharing class Base311_ServiceRequestScheduleUtil {
    
    //Get field of given object
    //@param : sObject
    //@return : list of field
    /*private static list<string> getfieldnameforObject(String objectName){
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if(fd.isAccessible()){
                	selectFields.add(fd.getName());
                }
               }
        }
        return selectFields;
    }
    
    //Method to create dynamic SOQL
    //@param : sobjectAPIName, extrafield list, where clause
    //@return : soql query
    private static String createQueryString(String sObjectAPIName, list<String> extrafieldName, String whereClause){
    	list<String> fieldlist = new list<String>();
    	String queryString= '';
    	if(sObjectAPIName != null && sObjectAPIName != ''){
    		fieldlist = getfieldnameforObject(sObjectAPIName);
	    	
	    	if(extrafieldName != null){
	    		fieldlist.addall(extrafieldName);
	    	}
	    	
	    	//Create query string
	    	queryString = 'select ' + String.join(fieldlist, ', ') + ' from ' + sObjectAPIName;
	    	//Add where clause
	    	if(whereClause != null){
	    		queryString = queryString + ' where '+ whereClause;
	    	}
    	} 
    	system.debug('queryString'+queryString);
    	return queryString;
    }
    
    Global static boolean removeServiceRequestschedule(String caseNumber, Date scheduleDate){
    	
    		list<Incap311__Service_Request_Schedule__c> scheduleList = new list<Incap311__Service_Request_Schedule__c>();
    		if(caseNumber != null && scheduleDate != null){
    				String whereClause = 'Incap311__Service_Request__r.CaseNumber = :caseNumber AND Incap311__Schedule__r.Incap311__Schedule_Date__c= :scheduleDate';
    				scheduleList = Database.query(createQueryString('Incap311__Service_Request_Schedule__c',null,whereClause));
    			if(scheduleList.size()>0){
    				if(Schema.sObjectType.Incap311__Service_Request_Schedule__c.isDeletable()) {
    					Database.delete(scheduleList,true);
    				}else{
    					throw new Base311_Exceptions.ServerException('No delete access to record');
    				}
    			}else{
    				throw new Base311_Exceptions.ServerException('No record to delete');
    			}
    			return true;
    		}else{
    			throw new Base311_Exceptions.ServerException('Either caseNumber or ScheduleDate is invalid');
    		}
    	
    }*/
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    Global static boolean cancelServiceRequestSchedule(String cancelReason, Incap311__Service_Request_Schedule__c serviceRequestSchedule){
    	if(serviceRequestSchedule.Incap311__Is_Cancelled__c){
    		throw new Base311_Exceptions.ServerException('The schedule is already cancelled');
    		return false;
    	}
    	else if(serviceRequestSchedule != null){
    		
    		if(cancelReason != null){
    			if(Schema.sObjectType.Incap311__Service_Request_Schedule__c.fields.Incap311__Cancel_Reason__c.isUpdateable()){serviceRequestSchedule.Incap311__Cancel_Reason__c = cancelReason;}
    		}else{
    			if(Schema.sObjectType.Incap311__Service_Request_Schedule__c.fields.Incap311__Cancel_Reason__c.isUpdateable()){serviceRequestSchedule.Incap311__Cancel_Reason__c = '';}
    		}
    		if(Schema.sObjectType.Incap311__Service_Request_Schedule__c.fields.Incap311__Is_Cancelled__c.isUpdateable()){serviceRequestSchedule.Incap311__Is_Cancelled__c = true;}
    		update serviceRequestSchedule;
    		Incap311__Schedule__c scheduleRecord = new Incap311__Schedule__c(id = serviceRequestSchedule.Incap311__Schedule__c,Incap311__Item_Count__c = serviceRequestSchedule.Incap311__Schedule__r.Incap311__Item_Count__c);
    		scheduleRecord = reduceCountOnSchedule(scheduleRecord,serviceRequestSchedule.Incap311__Number_Of_Items__c);
    		update scheduleRecord;
    		return true;
    	}else{
    		throw new Base311_Exceptions.ServerException('Either service request schedule is invalid');
    		return false;
    	}
    	
    }
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    //Method to reduce the count on schedule record
    //@param : schedule record
    //@return : updated schedule record
    private static Incap311__Schedule__c reduceCountOnSchedule(Incap311__Schedule__c scheduleRecord,Decimal numberofItems ){
    	if(numberofItems == null){
            numberofItems = 0;
        }

        if(scheduleRecord.Incap311__Item_Count__c != null && scheduleRecord.Incap311__Item_Count__c>0){
    		if(scheduleRecord.Incap311__Item_Count__c >= numberofItems){
                scheduleRecord.Incap311__Item_Count__c = scheduleRecord.Incap311__Item_Count__c - numberofItems;  
            }else{
                throw new Base311_Exceptions.ServerException('Number of Item on Service Request Schedule is higher then Schedule record');
            }
            
    	}else{
    		scheduleRecord.Incap311__Item_Count__c = 0;
    	}
    	return scheduleRecord;
    }
}