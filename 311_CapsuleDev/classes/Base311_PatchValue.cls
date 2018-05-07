/**
* @author John Benson  
* @date 10/26/2016
* @group 
* @group-content
* @description 
*/
global class Base311_PatchValue {
    global Boolean isSet;
    global Object value;
    
    global Base311_PatchValue(Boolean isSet, Object value) {
        this.isSet = isSet;
        this.value = value;
    }
    
    /**
    * @description method to get value for request body for given param(body)
    * @param paramName string value of Parameter 
    * @return Base311_PatchValue instance 
    * @example 
    */
    global static Base311_PatchValue fromBody(String paramName) {
        Boolean isSet = Base311_Helper.getRequestBody().containsKey(paramName);
        return new Base311_PatchValue(isSet, isSet ? Base311_Helper.getRequestBody().get(paramName) : null);
    }
    
    /**
    * @description method to get list of patchvalue from given patchvalue
    * @param pv  Base311_PatchValue instance
    * @return list of Base311_PatchValue
    * @example
    */
    global static List<Base311_PatchValue> fromPatchValue(Base311_PatchValue pv) {
        Object val = pv.value;
        List<Base311_PatchValue> pvs = new List<Base311_PatchValue>();
        
        if(pv == null || !pv.isSet || !(val instanceof List<Object>)) {
            return pvs;
        }
        
        List<Object> values = (List<Object>) pv.value;
        
        for(Object obj : values) {
            pvs.add(new Base311_PatchValue(true, obj));
        }
        
        return pvs;
    }
    
    /**
    * @description method to get list of patchvalue from given patchvalue and param(body)
    * @param pv  Base311_PatchValue instance
    * @param paramName string value of Parameter
    * @return Base311_PatchValue instance 
    * @example
    */
    global static Base311_PatchValue fromPatchValue(Base311_PatchValue pv, String paramName) {
        if(pv == null || pv.isSet == false || !(pv.value instanceof Map<String, Object>)) {
            return new Base311_PatchValue(false, null);
        }
        
        Map<String, Object> vals = (Map<String, Object>) pv.value;
        
        return vals.containsKey(paramName) ? new Base311_PatchValue(true, vals.get(paramName)) : new Base311_PatchValue(false, null);
    }
    
    /**
    * @description method to get list of patchvalue from given body
    * @param rootParamName string value of paramname
    * @param attributeName string value of attribute name
    * @return Base311_PatchValue instance
    * @example
    */
    global static Base311_PatchValue fromBody(String rootParamName, String attributeName) {
        if(!Base311_Helper.getRequestBody().containsKey(rootParamName)) {
            return new Base311_PatchValue(false, null);
        }
        
        Map<String, Object> root = (Map<String, Object>) Base311_Helper.getRequestBody().get(rootParamName);
        
        Boolean isSet = root.containsKey(attributeName);
        return new Base311_PatchValue(isSet, isSet ? root.get(attributeName) : null);
    }
}