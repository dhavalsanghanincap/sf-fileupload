/**
* @author John Benson
* @date 6/7/2017   
* @group 
* @group-content
* @description 
*/

//TODO:This class should be broken out using a Factory pattern for each data type
global class Base311_Attribute extends Base311_Object {

    global static String MULTI_PICKLIST_SEPERATOR = ', ';

    global String code;
    global Object value;
    private List<Base311_QuestionAnswer> validAnswers = new List<Base311_QuestionAnswer>();
    // context is the list of question answers to consider when evaluating if the attribute is valid
    Map<String, Object> context = null; 
    
    private Service_Type_Version_Question__c stvq;
    private Outcome_Question__c oq;
 
    global Base311_Attribute(String code, Object value, Outcome_Question__c oq) {
        this(code, value);
        this.setQuestion(oq);
    }
    
    global Base311_Attribute(String code, Object value, Service_Type_Version_Question__c stvq) {
        this(code, value);
        this.setQuestion(stvq);
    }

    global Base311_Attribute(String code, Object value) {
        this.code = code;
        this.value = value;
    }

    private String getQuestionLabel() {
        SObject question = getActiveQuestion();
        
        if(question == null) {
            return 'Unknown';
        }
        
        SObject questionObj = question.getSObject('Incap311__Question__r');
        
        return '"' + String.valueOf(questionObj.get('Incap311__Question__c')) + '" ' + '(' + this.code + ')';
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    @TestVisible
    protected override void validation() {
        if(getActiveQuestion() == null) {
            this.addError('Unknown question ' + code);
            return;
        }

        String dataType = getDatatype();
        
        if(Base311_Dependencies.questionIsActive(getActiveQuestion(), this.context) && getIsRequired() && value == null) {
            this.addError(getQuestionLabel() + ' is required');
        }

        if(!Base311_Dependencies.questionIsActive(getActiveQuestion(), this.context) && value != null) {
            this.addError('Did not expect a response for ' + getQuestionLabel() + '. Please ensure it\'s dependencies are met');
        }

        if(!validateValueType()) {
            if(dataType == 'MultiPicklist' || dataType == 'Picklist') {
                List<String> validKeys = new List<String>();

                for(Base311_QuestionAnswer rqa : validAnswers) {
                    validKeys.add(rqa.key);
                }

                this.addError(getQuestionLabel() + ' is limited to' + (dataType == 'Picklist' ? ' one of ' : ' ') + String.join(validKeys, ', '));
            } else {
                this.addError(getQuestionLabel() + ' must be of type ' + dataType);
            }
        }
		
        String configuredValidations = getValidations();
        
        if(configuredValidations != null){

            List<Base311_Validation> validations = Base311_Validation.fromJSON(configuredValidations);
            
            for(Base311_Validation validation : validations) {
                if(validation.dependentOn.evaluate(context)) {
                    this.addError(validation.message);
                }
            }

        }
    }

    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    public Boolean isActive() {
        if(context == null || (getActiveQuestion() == null)) {
            return true;
        }
        
        return Base311_Dependencies.questionIsActive(getActiveQuestion(), context);
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    private String getValidations() {
        Sobject question = getActiveQuestion();
        
        if(question == null){ 
        	return null;
        }
        
        return String.valueOf(question.get('Validations__c'));
	}
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    private SObject getActiveQuestion() {
        if(stvq != null) {
            return stvq;
        }
        
        if(oq != null) {
            return oq;
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
    private String getDataType() {
        Sobject question = getActiveQuestion();
        
        if(question == null){ 
        	return null;
        }
        
        return String.valueOf(question.getSobject('Incap311__Question__r').get('Incap311__Data_Type__c'));
         
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    private Boolean getIsRequired() {
        Sobject question = getActiveQuestion();
        
        if(question == null){ 
        	return false;
        }
        
        return Boolean.valueOf(question.get('Is_Required_Question__c'));
         
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global Base311_Attribute setQuestion(SObject obj) {
        if(obj == null) {
            return this;
        }
        
        if(obj instanceof Service_Type_Version_Question__c) {
            return this.setSTVQ((Service_Type_Version_Question__c) obj);
        }
        
        if(obj instanceof Outcome_Question__c) {
            this.oq = (Outcome_Question__c) obj;
            return this.setContext(new Map<String, Object>());
        }
        
        throw new Base311_Exceptions.UnsupportedException('Tried to set the question of an attribute to some unsupported value');
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global Base311_Attribute setSTVQ(Service_Type_Version_Question__c stvq) {
        return setContext(stvq, new Map<String, Object>());
    }
  
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global Base311_Attribute setContext(Map<String, Object> context) {
        this.context = context;
        
        this.validAnswers = null;
        
        if(stvq != null) {
        	this.validAnswers = Base311_Dependencies.getActivePicklist(this.stvq, context); 
        } 
        else if(oq != null) {
        	this.validAnswers = Base311_Dependencies.getActivePicklist(this.oq, context); 
        }
        

        return this;
    }
  
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global Base311_Attribute setContext(Service_Type_Version_Question__c obj, Map<String, Object> context) {
        this.stvq = obj;
    
		return setContext(context); 
    }

    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global Boolean isValidAnswer(String answer) {
        for(Base311_QuestionAnswer rqa : this.validAnswers) {
            if(rqa.key == answer) {
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
    global Boolean areValidAnswers(List<Object> answers) {
        for(Object answer : answers) {
            if(!isValidAnswer(String.valueOf(answer))) {
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
    private Boolean validateValueType() {
        String datatype = getDataType();

        // try to convert the value to its Version Question datatype. If it fails,
        // return false; if it works, return true;
        try {
            if(value == null) {
                return true;
            }

            if(dataType == 'Number') {
                Double val = Double.valueOf(value);
                return true;
            }

            if(dataType == 'Boolean (checkbox)') { 
                if(!(value instanceof Boolean) && value != 'true' && value != 'false') {
                    return false;
                }

                return true;
            }

            if(dataType == 'Date/Time' || dataType == 'Date') {
                Datetime dt = Base311_Helper.parseDate((String) value);
                return true;
            }

            if(dataType == 'MultiPicklist' && value instanceof List<Object>) {
                return areValidAnswers((List<Object>) value);
            }

            if(dataType == 'MultiPicklist' || dataType == 'Picklist') {
                return isValidAnswer((String) value);
            }

            return value instanceof String;
        } 
        catch(Exception e) { }


        return false;
    }

    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global String stringifyValue() {
        String dataType = getDataType();

        if(value == null) {
            return null;
        }

        if(dataType == 'Number') {
        	String num = String.valueOf(value);
            return String.valueOf(Decimal.valueOf(num).stripTrailingZeros());
        }

        if(dataType == 'Boolean (checkbox)') { 
            if(!(value instanceof Boolean) && value != 'true' && value != 'false') {
                throw new Base311_Exceptions.UnsupportedException('Question ' + getQuestionLabel() + ' was provided an invalid data type. Expected a boolean');
            }

            return String.valueOf(Boolean.valueOf(value));
        }

        if(dataType == 'Date/Time') {
            return Base311_Helper.formatHumanDatetime(Base311_Helper.parseDate((String) value));
        }
        
        if(dataType == 'Date') {
            return Base311_Helper.formatHumanDate(Base311_Helper.parseDate((String) value));
        }

        if(dataType == 'MultiPicklist' && value instanceof List<Object>) {
            List<Object> attrValues = (List<Object>) value;

            if(!areValidAnswers(attrValues)) {
                throw new Base311_Exceptions.UnsupportedException('Question ' + getQuestionLabel() + ' was provided an invalid value. Values must be ' + String.join(validAnswers, ', '));
            }

            return String.join(attrValues, MULTI_PICKLIST_SEPERATOR);
        }

        if(dataType == 'MultiPicklist' || dataType == 'Picklist') {
            String answer = (String) value;

            if(!isValidAnswer(answer)) {
                throw new Base311_Exceptions.UnsupportedException('Question ' + getQuestionLabel() + ' was provided an invalid value. Values must be ' + String.join(validAnswers, ', '));
            }

            return answer;
        }

        return String.valueOf(value);
    }

    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global static Map<String, Base311_Attribute> fromMap(Map<String, Object> items) {
        Map<String, Base311_Attribute> attributes = new Map<String, Base311_Attribute>();

        for(String code : items.keySet()) {
            attributes.put(code, new Base311_Attribute(code, items.get(code)));
        }

        return attributes;
    } 
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */   
    private static Object objectifyValue(String value, String dataType) {
        if(value == null) {
            return null;
        }

        if(dataType == 'Number') {
            return Double.valueOf(value);
        }

        if(dataType == 'Boolean (checkbox)') { 
            return Boolean.valueOf(value);
        }

        if(dataType == 'Date/Time') {
            return Base311_Helper.parseDate(value);
        }
        
        if(dataType == 'Date') {
            return Base311_Helper.parseDate(value);
        }

        if(dataType == 'MultiPicklist' && value.indexOf(MULTI_PICKLIST_SEPERATOR) > 0) { 
            return value.split(MULTI_PICKLIST_SEPERATOR);
        }

        if(dataType == 'MultiPicklist' || dataType == 'Picklist') {
            return value;
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
    global static Base311_Attribute fromSQ(Service_Question__c sq) {
        String dataType = sq.Service_Type_Version_Question__r.Question__r.Data_Type__c;
        
        
        return new Base311_Attribute(
            sq.Question_Code__c, 
            objectifyValue(sq.Answer__c, dataType), 
            sq.Service_Type_Version_Question__r
        );
    }
}