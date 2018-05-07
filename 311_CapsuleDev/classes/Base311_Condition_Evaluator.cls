/**
* @author John Benson
* @date 4/28/2017   
* @group 
* @group-content
* @description Utility class with all condition evaluator logic methods
*/
global class Base311_Condition_Evaluator {

    public static final String SERVICE_QUESTION_CODE = 'ServiceQuestionCode';
    
    private static final String CLAUSE_AND = 'AND';
    private static final String CLAUSE_OR = 'OR';
    
    private static final String OP_EQ = 'eq';
    private static final String OP_NEQ = 'neq';
    private static final String OP_IN = 'in';
    private static final String OP_GT = 'gt';
    private static final String OP_LT = 'lt';
    private static final String OP_GTE = 'gte';
    private static final String OP_LTE = 'lte';
    
    private Map<String, Map<String, Object>> currentValues = new Map<String, Map<String, Object>>();
    
    private static final Map<String, List<Pattern>> STATEMENTS = new Map<String, List<Pattern>>{
        'ServiceQuestionCode' => new List<Pattern>{
            Pattern.compile('ServiceQuestionCode\\[(.*)\\]\\.Incap311__Answer__c'), Pattern.compile('(FQ-.*)')
        },
        'OutcomeQuestionCode' => new List<Pattern>{
            Pattern.compile('OutcomeQuestionCode\\[(.*)\\]\\.Incap311__Answer__c'), Pattern.compile('(FQ-.*)')
        }
    };
    global Base311_Condition_Evaluator() {
         this.currentValues = null;   
    }
    
    global Base311_Condition_Evaluator(Map<String, Map<String, Object>> currentValues) {
       this.currentValues = currentValues; 
    }  
    
    global Base311_Condition_Evaluator(Map<String, Object> serviceQuestionCodeValues) {
        this.currentValues = new Map<String, Map<String, Object>>{
            'ServiceQuestionCode' => serviceQuestionCodeValues
        };
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    public static Set<String> statementKeys(String statementKey, Base311_Dependency dep) {
        Set<String> keys = new Set<String>();
        
        if(dep.conditions != null) {
            for(Base311_Dependency conDep : dep.conditions) {
                keys.addAll(statementKeys(statementKey, conDep));
            }
            
            return keys;
        }
        
        List<Pattern> patterns = STATEMENTS.get(statementKey);
        String leftKey = dep.left instanceof String ? getStatementKey(patterns, String.valueOf(dep.left)) : null;
        String rightKey = dep.right instanceof String ? getStatementKey(patterns, String.valueOf(dep.right)) : null;
        
        if(leftKey != null) {
            keys.add(leftKey);
        }
        
        if(rightKey != null) {
            keys.add(rightKey);
        }
        
        
        return keys;
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    public static Map<String, Set<String>> getStatementKeys(Base311_Dependency dep) {
        Set<String> keys = STATEMENTS.keySet();
        
        Map<String, Set<String>> items = new Map<String, Set<String>>();
        
        for(String key : keys) {
            if(!items.containsKey(key)) {
                items.put(key, new Set<String>());
            }
            
            items.get(key).addAll(statementKeys(key, dep));
        }
        
        return items;
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global Object message(List<Base311_DependentValue> dep) {
        Base311_DependentValue dp = resolve(dep);
        return dp != null ? dp.message : null;
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global Object values(List<Base311_DependentValue> dep) {
        Base311_DependentValue dp = resolve(dep);
         
        return dp != null ? dp.values : null;
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global Base311_DependentValue resolve(List<Base311_DependentValue> dep) {
        if(dep == null) {
            return null;
        }
        
        for(Base311_DependentValue dp : dep) {
            if(this.conditionGroup(dp.dependentOn)) {
                return dp;
            }
        }
        
        return null;
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    public static Boolean isStatement(String value) { 
        
        for(List<Pattern> ps : STATEMENTS.values()) {
            for(Pattern p : ps) {
                if(p.matcher(value).matches()) {
                    return true;
                }
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
    private static String getStatementKey(List<Pattern> patterns, String value) {
        for(Pattern p : patterns) {
            Matcher m = p.matcher(value);
            
            if(m.matches()) {
                return m.group(1);
            }

        }        
        
        return null;
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    public Object statement(String value) {
        for(String statementKey : STATEMENTS.keySet()) {
            String statementKeyIndex = getStatementKey(STATEMENTS.get(statementKey), value);
            
            if(statementKeyIndex != null && this.currentValues.containsKey(statementKey) && this.currentValues.get(statementKey).containsKey(statementKeyIndex)) {
                return this.currentValues.get(statementKey).get(statementKeyIndex);
            }
        }
        
        return null;
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    public Object side(Object value) {
        if(value instanceof String && isStatement((String) value)) {
            return this.statement((String) value);
        }
        
        return value;
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    public Boolean equal(Object val1, Object val2) { 
        if(val1 instanceof List<Object> || val2 instanceof List<Object>) {
            // if one is a list but the other isn't, can't be equal
            if(!(val1 instanceof List<Object>) || !(val2 instanceof List<Object>)) {
                return false;
            }
            
            return ((List<Object>) val1).size() == ((List<Object>) val2).size() && containsAll((List<Object>) val1, (List<Object>) val2);
        }
         
        // even if the values are numbers, this will be true
        return String.valueOf(val1) == String.valueOf(val2);
    }

    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    private Boolean listContains(Object val, List<Object> l) {
        for(Object i : l) {
            if(String.valueOf(val) == String.valueOf(i)) {
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
    private Boolean containsAll(List<Object> val1, List<Object> val2) {
        for(Object v1 : val1) {
            if(!listContains(v1, val2)) {
                return false;
            }
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
    public Boolean contains(Object val1, Object val2) {
        if(val1 instanceof String && val2 instanceof String) {
            return String.valueOf(val2).contains(String.valueOf(val1));
        }
        
        if(!(val1 instanceof List<Object>) && val2 instanceof List<Object>) {
            return listContains(val1, (List<Object>) val2);
        }
        
        if(val1 instanceof List<Object> && val2 instanceof List<Object>) {
            return containsAll((List<Object>) val1, (List<Object>) val2);
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
    public Boolean condition(Base311_Dependency dep) {
        Object left = this.side(dep.left);
        Object right = this.side(dep.right);
         
        // no op or no dep = true
        if(dep == null || dep.op == null) {
            throw new Base311_Exceptions.ServerException('Improper configuration on question; no operation specified');
        }
        
        String op = dep.op.toLowerCase();
         
        // we convert values to strings since they compare the way we want
        // we also only expect GT, LT, GTE and LTE will only every have basic
        // values
        if(op == OP_EQ) {
            return equal(left, right);
        }
        else if (op == OP_IN) {
            return contains(left, right);
        } 
        else if (op == OP_NEQ) {
            return !equal(left, right);
        }
        else if (op == OP_GT) {
            return String.valueOf(left) > String.valueOf(right);
        }
        else if (op == OP_LT) {
            return String.valueOf(left) < String.valueOf(right);
        }
        else if (op == OP_GTE) {
            return String.valueOf(left) >= String.valueOf(right);            
        }
        else if (op == OP_LTE) {
            return String.valueOf(left) <= String.valueOf(right);  
        }
        
        // if we don't understand the op; assume its false
        return false;
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    public Boolean conditionGroup(Base311_Dependency dep) {
        if(dep == null || dep.clause == null) {
            throw new Base311_Exceptions.ServerException('Improperly configured question; condition group without a clause');
        }
        
        Boolean isAnd = dep.clause.equalsIgnoreCase(CLAUSE_AND);
        
        List<Base311_Dependency> conditions = dep.conditions;
        
        for(Base311_Dependency condition : conditions) {
            Boolean result = this.condition(condition);
            
            // if the clause is OR and ANY condition is true
            // return true
            if(!isAnd && result) {
                return true;
            }
            
            // if the clause is AND and ANY condition is false
            // return false
            if(isAnd && !result) {
                return false;
            }
        }
        
        // if we get to the end and its an AND clause; return true
        // otherwise return false
        return isAnd;
    }
}