/**
* @author John Benson
* @date  4/29/2017  
* @group 
* @group-content
* @description 
*/
global class Base311_DependentValue {
    public Base311_Dependency dependentOn = null;
    public Object values;
    public Object message;
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global static List<Base311_DependentValue> fromJSON(String jsonDV) {
        if(jsonDV == null) {
            return null;
        }
        
        List<Base311_DependentValue> items = new List<Base311_DependentValue>();
        
        Object res = JSON.deserializeUntyped(jsonDV);
        List<Object> untypedItems = (List<Object>) res;
        
        for(Object item : untypedItems) {
            Base311_DependentValue dv = new Base311_DependentValue();
            Map<String, Object> mappedItem = (Map<String, Object>) item;
            dv.dependentOn = Base311_Dependency.fromMap((Map<String, Object>) mappedItem.get('dependentOn'));
            
            if(mappedItem.containsKey('values')) {
                dv.values = mappedItem.get('values');
            }
            
            if(mappedItem.containsKey('message')) {
                dv.message = mappedItem.get('message');
            }
            
            items.add(dv);
        }
        
        
        return items;
    }
}