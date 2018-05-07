/**
* @author John Benson
* @date  12/22/2016  
* @group 
* @group-content
* @description 
*/

Global class Base311_Dependency {
    public String clause;
    public List<Base311_Dependency> conditions;
    public Object left;
    public Object right;
    public String op;
    
    public Base311_Dependency() {
        
    }
    
    public Base311_Dependency(String clause, List<Base311_Dependency> conditions) {
        this.clause = clause;
        this.conditions = conditions;
    }
    
    public Base311_Dependency(Object left, Object right, String op) {
        this.left = left;
        this.op = op;
        this.right = right;
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    public static Base311_Dependency fromJSON(String jsonDep) { 
        if(jsonDep == null) {
            return null;
        }
        
        return fromMap((Map<String, Object>) JSON.deserializeUntyped(jsonDep));
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    public static Base311_Dependency fromMap(Map<String, Object> item) {
        if(item == null) {
            return null;
        }
        
        Base311_Dependency d = new Base311_Dependency();
        
        if(item.containsKey('clause')) {
            d.clause = String.valueOf(item.get('clause'));
            
            List<Base311_Dependency> finalConditions = new List<Base311_Dependency>();
            List<Object> objectConditions = (List<Object>) item.get('conditions');
            
            for(Object objectCondition : objectConditions) {
                finalConditions.add(Base311_Dependency.fromMap((Map<String, Object>) objectCondition));
            }
            
            d.conditions = finalConditions;
        } 
        
        if(item.containsKey('op')) {
            d.left = item.get('left');
            d.right = item.get('right');
            d.op = String.valueOf(item.get('op'));
        }
        
        return d;
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */  
    global Boolean evaluate(Map<String, Map<String, Object>> currentValues){
        Base311_Condition_Evaluator ce = new Base311_Condition_Evaluator(currentValues);
        
        return ce.conditionGroup(this);
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    @Deprecated
    global Boolean evaluate(Map<String, Object> currentValues){
        throw new Base311_Exceptions.UnsupportedException('Please use evaluate(Map<String, Map<String, Object>>)');
    }
 
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global Set<String> getDependencySet(){
        Set<String> items = new Set<String>();
        
        Map<String, Set<String>> keyMap = Base311_Condition_Evaluator.getStatementKeys(this);
        
        for(Set<String> itemSet : keyMap.values()) {
            items.addAll(itemSet);
        }
        
        return items;
    }
     
}