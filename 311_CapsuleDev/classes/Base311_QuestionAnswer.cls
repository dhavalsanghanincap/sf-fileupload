/**
* @author John Benson
* @date  10/26/2016
* @group 
* @group-content
* @description Object to represent the possible answers for a given Service_Type_Version_Question__c (when Datatype is MultiPicklist or Picklist)
*/
global class Base311_QuestionAnswer {
    
    
    global String key { get; set; }
    global String value { get; set; }
    global String img { get; set; }
    global Boolean isSelected { get; set; }
    
    global Base311_QuestionAnswer(String key, String value, Boolean isSelected) {
        this.key = key;
        this.value = value;
        this.isSelected = isSelected;
    }
    
    global Base311_QuestionAnswer(String key, String value) {
        this.key = key;
        this.value = value;
        this.isSelected = false;
    }
    
    /**
    * @description method to convert string to Boolean,Double,Date/TIme, Date
    * @param dataType string 
    * @return Object
    * @example 
    */
    global Object convertValueTo(String dataType) {
        if(this.value == null) {
            return null;
        }
    
        if(dataType == 'Number') {
            return Double.valueOf(this.value);
        }
        
        if(dataType == 'Boolean (checkbox)') {
            return Boolean.valueOf(this.value);
        }
        
        if(dataType == 'Date/Time' || dataType == 'Date') {
            return Base311_Helper.parseDate((String) this.value);
        }
        
        // presume something that wants a string by default
        return this.value;
    }
    
    /**
    * @description Method to mark Base311_QuestionAnswer if the answers are selected or not from Answer__c field of Service Question record
    * @param sq Service_Question__c record
    * @param rqas list of Base311_QuestionAnswer
    * @return updated list of Base311_QuestionAnswer 
    * @example
    */
    global static List<Base311_QuestionAnswer> fromSQ(Service_Question__c sq, List<Service_Question__c> sqs) {
        List<Base311_QuestionAnswer> rqas = fromSTVQ(sq.Service_Type_Version_Question__r, sqs);
        
        return markActiveFromAnswers(sq, rqas);
    }
    
    /**
    * @description Method to mark Base311_QuestionAnswer if the answers are selected or not from Answer__c field of Service Question record
    * @param sq Service_Question__c record 
    * @return updated list of Base311_QuestionAnswer
    * @example
    */
    global static List<Base311_QuestionAnswer> fromSQ(Service_Question__c sq) {
        List<Base311_QuestionAnswer> rqas = fromSTVQ(sq.Service_Type_Version_Question__r);
        
        return markActiveFromAnswers(sq, rqas);
    }
    
    /**
    * @description Method to mark Base311_QuestionAnswer if the answers are selected or not from Answer__c field of Service Question record
    * @param sq Service_Question__c record
    * @param rqas list of Base311_QuestionAnswer
    * @return updated list of Base311_QuestionAnswer 
    * @example 
    */
    private static List<Base311_QuestionAnswer> markActiveFromAnswers(Service_Question__c sq, List<Base311_QuestionAnswer> rqas) {
        List<String> answers = sq.Answer__c != null ? sq.Answer__c.split(Base311_Attribute.MULTI_PICKLIST_SEPERATOR) : new List<String>();
        
        if(rqas == null) {
            rqas = new List<Incap311.Base311_QuestionAnswer>();
        }
        
        if(rqas.size() > 0) {
            for(Base311_QuestionAnswer rqa : rqas) {
                for(String answer : answers) {
                    if(rqa.key == answer) {
                        rqa.isSelected = true;
                    }
                }
            }
        } else {
            rqas.add(new Base311_QuestionAnswer(null, sq.Answer__c, true));
        }
        
        return rqas;
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global static List<Base311_QuestionAnswer> fromSTVQ(Service_Type_Version_Question__c stvq) {
        
        if(stvq.Question__r == null && stvq.Override_Answer_Values__c == null) {
            return new List<Base311_QuestionAnswer>();
        }
        
        return Base311_Dependencies.getActivePicklist(
            stvq,
            new Map<String, Object>()
        );
    }
    
    /**
    * @description Method to get list of Base311_QuestionAnswer from Service Type Version Question
    * @param stvq is Service_Type_Version_Question__c
    * @param sqs List<Service_Question__c>
    * @return list of Base311_QuestionAnswer
    * @example
    */
    global static List<Base311_QuestionAnswer> fromSTVQ(Service_Type_Version_Question__c stvq, List<Service_Question__c> sqs) {
        if(stvq.Question__r == null && stvq.Override_Answer_Values__c == null) {
            return new List<Base311_QuestionAnswer>();
        }
        
        Map<String, Object> values = new Map<String, Object>();
        
        for(Service_Question__c sq : sqs) {
            values.put(sq.Incap311__Service_Type_Version_Question__r.Name, sq.Answer__c);
        }
        
        return Base311_Dependencies.getActivePicklist(
            stvq,
            values
        );
    }
    
    /**
    * @description Method to get List<Base311_QuestionAnswer> from jsonString
    * @param jsonString is string
    * @return list of Base311_QuestionAnswer
    * @example 
    */
    global static List<Base311_QuestionAnswer> fromJSON(String jsonString) {
        if(jsonString == null) {
            jsonString = '[]';
        }
        
        List<Base311_QuestionAnswer> items = (List<Base311_QuestionAnswer>) JSON.deserialize(jsonString, List<Base311_QuestionAnswer>.class);
        
        if(items.size() == 1 && items.get(0).key == null && items.get(0).value == null) {
            return new List<Base311_QuestionAnswer>();
        }
        
        for(Base311_QuestionAnswer qa : items) {
            if(qa.isSelected == null) {
                qa.isSelected = false;
            }
        }
        
        return items;
    } 
}