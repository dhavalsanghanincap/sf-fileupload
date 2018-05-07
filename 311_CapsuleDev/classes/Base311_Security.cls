/**
* @author 
* @date 
* @group 
* @group-content
* @description Class with the logic related to Object and Field level security
*/
global class Base311_Security {
    
    /**
    * @description method to check if the fields are updatable for given user or not
    * @param soType Sobject
    * @param fields list of fields
    * @return TRUE or FALSE
    * @example
    */
    global static Boolean areUpdateable(SObjectType soType, List<String> fields) {
        Map<String, SObjectField> m = soType.getDescribe().fields.getMap();
        
        for (String name : fields) {
            
            SObjectField soField = m.get(name.toLowerCase());
            
            if(soField == null) {
                throw new Base311_Exceptions.ServerException('Unknown field ' + name + ' on Object ' + soType.getDescribe().getLabel());
            }
            
            if(!soField.getDescribe().isUpdateable()) {
                return false;
            }
        }
        
        return true;
    }
    
    /**
    * @description Method to check creatable security for given fields
    * @param soType Sobject
    * @param fields list of fields
    * @return TRUE or FALSE
    * @example
    */
    global static Boolean areCreateable(SObjectType soType, List<String> fields) {
        Map<String, SObjectField> m = soType.getDescribe().fields.getMap();
        
        for (String name : fields) {
            
            SObjectField soField = m.get(name.toLowerCase());
            
            if(soField == null) {
                throw new Base311_Exceptions.ServerException('Unknown field ' + name + ' on Object ' + soType.getDescribe().getLabel());
            }
            
            if(!soField.getDescribe().isCreateable()) {
                return false;
            }
        }
        
        return true;
    }
    
    /**
    * @description Method to check accessible security for given fields
    * @param soType Sobject
    * @param fields list of fields
    * @return TRUE or FALSE
    * @example
    */
    global static Boolean areAccessible(SObjectType soType, List<String> fields) {
        Map<String, SObjectField> m = soType.getDescribe().fields.getMap();
        
        for (String name : fields) { 
            // ignore related fields
            if(name.contains('__r')) {
                return true;
            }
            
            SObjectField soField = m.get(name.toLowerCase());
            
            if(soField == null) {
                throw new Base311_Exceptions.ServerException('Unknown field ' + name + ' on Object ' + soType.getDescribe().getLabel());
            }
            
            if(!soField.getDescribe().isAccessible()) {
                throw new Base311_Exceptions.ServerException('No access to ' + soField.getDescribe().name);
                return false;
            }
        }
        
        return true;
    }

}