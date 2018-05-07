/**
* @author John Benson
* @date  12/22/2016  
* @group 
* @group-content
* @description 
*/
global class Base311_Dependencies {

    private static Base311_Service_ServiceType sst = new Base311_Service_ServiceType();

    public static Boolean questionIsActive(SObject obj, Map<String, Object> values) {
        if(obj instanceof Service_Type_Version_Question__c) {
            return questionIsActive((Service_Type_Version_Question__c) obj, values);
        }
        if(obj instanceof Outcome_Question__c) {
            return questionIsActive((Outcome_Question__c) obj, values);
        }
        
        
        return true;
    }
    
    /**
    * @description Return true if the provided question is valid for the provided values.Return false if not.
    * @param 
    * @param 
    * @return 
    * @example
    */
    /*
        
    */
    global static Boolean questionIsActive(Service_Type_Version_Question__c stvq, Map<String, Object> values) {
        return questionIsActive(stvq.Dependencies__c, new Map<String, Map<String, Object>>{ 'ServiceQuestionCode' => values });
    }
    
    /**
    * @description Return true if the provided question is valid for the provided values.Return false if not.
    * @param 
    * @param 
    * @return 
    * @example
    */
    /*
        
    */
    global static Boolean questionIsActive(Outcome_Question__c oQ, Map<String, Object> values) {
        return questionIsActive(oQ.Dependencies__c, new Map<String, Map<String, Object>>{ 'OutcomeQuestionCode' => values });
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */ 
    @Deprecated
    global static Boolean questionIsActive(String dependenciesJSOn, Map<String, Object> values) {
        throw new Base311_Exceptions.UnsupportedException('Please use questionIsActive(String, Map<String, Map<String, Object>>');
    }
    
    /**
    * @description Return true if the provided question is valid for the provided values.Return false if not.
    * @param 
    * @param 
    * @return 
    * @example
    */
    /*
        
    */
    global static Boolean questionIsActive(String dependenciesJSOn, Map<String, Map<String, Object>> values) {
        Base311_Dependency dep = Base311_Dependency.fromJSON(dependenciesJSOn);
        return dep == null ? true : dep.evaluate(values);
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global static List<Service_Type_Version_Question__c> getCurrentQuestions(Service_Type_Version__c stv, Map<String, Object> currentValues) {
        List<Service_Type_Version_Question__c> allQuestions = new List<Service_Type_Version_Question__c>();
 
        for(Service_Type_Version_Question__c stvq : stv.Service_Type_Version_Questions__r) { 
            if(questionIsActive(stvq, currentValues)) {
                System.debug('I JUST ACCEPTED ' + stvq.Id);
                
                allQuestions.add(stvq);
            }
        }
        
        System.debug(allQuestions);

        return allQuestions;
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global static List<Outcome_Question__c> getCurrentQuestions(Activity_Outcome__c activityOutcome, Map<String, Object> currentValues) {
        List<Outcome_Question__c> allQuestions = new  List<Outcome_Question__c>();
         
        for(Outcome_Question__c outcomeQuestion :  [select id, Question__r.Data_Type__c, Question__r.Hint_Text__c, Question__r.Question__c, Question__r.Answer_Values__c, 
                                                    Order__c, Order2__c, Override_Order__c, Question__c, Is_Read_Only__c, Name, Override_Answer_Values__c,  Is_Required_Question__c,
                                                     Question__r.Flex_Question_Code__c, Dependencies__c, Validations__c, Is_Controlling__c, Is_Dependent__c 
                                                    from Outcome_Question__c where Activity_Outcome__c = :activityOutcome.Outcome__c]) {
            if(questionIsActive(outcomeQuestion, currentValues)) {
                allQuestions.add(outcomeQuestion);
            }
        }

        return allQuestions;
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global static List<Outcome_Question__c> getCurrentQuestionsV2(Activity_Outcome__c activityOutcome, Map<String, Object> currentValues) {
        List<Outcome_Question__c> allQuestions = new  List<Outcome_Question__c>();
         
        for(Outcome_Question__c outcomeQuestion :  [select id, Question__r.Data_Type__c, Question__r.Hint_Text__c, Question__r.Question__c, Question__r.Answer_Values__c, 
                                                    Order__c, Order2__c, Override_Order__c, Question__c, Is_Read_Only__c, Name, Override_Answer_Values__c,  Is_Required_Question__c,
                                                     Question__r.Flex_Question_Code__c, Dependencies__c, Validations__c, Is_Controlling__c, Is_Dependent__c 
                                                    from Outcome_Question__c where Incap311__Service_Type_Version_Activity_Outcome__c = :activityOutcome.Id]) {
            if(questionIsActive(outcomeQuestion, currentValues)) {
                allQuestions.add(outcomeQuestion);
            }
        }

        return allQuestions;
    }

    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    /*
        For a service type version, return all questions based on the values provided
    */
    global List<Service_Type_Version_Question__c> getActiveQuestions(Service_Type_Version__c stv, Map<String, Object> currentValues) {
        return getCurrentQuestions(stv, currentValues);
    }
    
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    /*
        For a Activity Outcom, return all questions based on the values provided
    */
    global List<Outcome_Question__c> getActiveQuestions(Activity_Outcome__c activityOutcome, Map<String, Object> currentValues) {
        return getCurrentQuestions(activityOutcome, currentValues);
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    /*
        For a Activity Outcom, return all questions based on the values provided used while making changed to activity outcome to service type activity outcome
    */
    global List<Outcome_Question__c> getActiveQuestionsV2(Activity_Outcome__c activityOutcome, Map<String, Object> currentValues) {
        return getCurrentQuestionsV2(activityOutcome, currentValues);
    }
    
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
     /*
        For a service type version, return a map of question codes to dependent question codes
    */
    global static Map<String, Set<String>> getQuestionsDependencyMap(Service_Type_Version__c stv) {
        Map<String, Set<String>> questionsDependencyMap = new Map<String, Set<String>>();

        for(Service_Type_Version_Question__c stvq : stv.Service_Type_Version_Questions__r) {
            questionsDependencyMap.put(stvq.Flex_Question_Code__c, Base311_Dependency.fromJSON(stvq.Dependencies__c).getDependencySet());
        }

        return questionsDependencyMap;
    }

    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    /*
        For a question, return the picklist values that are currently enabled based on the values
    */
    global static List<Base311_QuestionAnswer> getActivePicklist(Service_Type_Version_Question__c q, Map<String, Object> currentValues) {
        return getSobjectActivePicklist(q, currentValues);    
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    /*
        For a question, return the picklist values that are currently enabled based on the values
    */
    global static List<Base311_QuestionAnswer> getActivePicklist(Outcome_Question__c q, Map<String, Object> currentValues) {
        return getSobjectActivePicklist(q, currentValues);    
    }

    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global static List<Base311_QuestionAnswer> getSobjectActivePicklist(sObject question, Map<String, Object> currentValues) {
    
        String groupKey = (question instanceof Service_Type_Version_Question__c) ? 'ServiceQuestionCode' : 'OutcomeQuestionCode';
    
        Base311_Condition_Evaluator ce = new Base311_Condition_Evaluator(new Map<String, Map<String, Object>>{ groupKey => currentValues });
        
        String jsonExp = question.get('Override_Answer_Values__c') == null ? 
            (String) question.getSobject('Question__r').get('Answer_Values__c') : 
            (String) question.get('Override_Answer_Values__c');
        
        try {            
            return Base311_QuestionAnswer.fromJSON(
                JSON.serialize(ce.values(Base311_DependentValue.fromJSON(jsonExp)))
           	);
        } catch (Exception e) {
        } 
        
        try {
            return Base311_QuestionAnswer.fromJSON(jsonExp); 
        } catch (Exception e) {
        }
        
        return new List<Base311_QuestionAnswer>();
    }

    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global static List<Service_Type_Version__c> getServiceTypeSuggestions(Service_Type_Version__c stv, Map<String, Object> currentValues) {
        Base311_Condition_Evaluator ce = new Base311_Condition_Evaluator(currentValues);
        
        String jsonExp = stv.Recommended_Types__c;
        
        Object result = ce.values(Base311_DependentValue.fromJSON(jsonExp));
        
        if(result == null) {
            return new List<Service_Type_Version__c>();
        }
        
        List<String> suggestionCodes = new List<String>();
        
        for(Object o : (List<Object>) result) {
            suggestionCodes.add(String.valueOf(o));
        }
        
        List<Service_Type_Version__c> suggestions = sst.getActiveServiceTypes(true);
         
        List<Service_Type_Version__c> finalSuggestions = new List<Service_Type_Version__c>();
        
        for(String code : suggestionCodes) {
            for(Service_Type_Version__c curStv : suggestions) {
                if(curStv.Service_Type_Code__c == code) {
                    finalSuggestions.add(curStv);
                    break;
                }
            }
        } 
         
        return finalSuggestions;
    }

    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    /*
        For a question, Check if the current values are valid, if not throw an exception
    */
    global static void validateQuestion(Service_Type_Version_Question__c question, Map<String, Object> currentValues) {
         Base311_Condition_Evaluator ce = new Base311_Condition_Evaluator(new Map<String, Map<String, Object>>{ 'ServiceQuestionCode' => currentValues });
        
        String jsonExp = question.Validations__c;

        String message = String.valueOf(ce.message(Base311_DependentValue.fromJSON(jsonExp)));
        
        if(message != null) { 
            throw new Base311_Exceptions.ValidationException(message);
        }
        
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    /*
        For a question, Check if the current values are valid, if not throw an exception
    */
    global static void validateQuestion(Outcome_Question__c question, Map<String, Object> currentValues) {
        Base311_Condition_Evaluator ce = new Base311_Condition_Evaluator(new Map<String, Map<String, Object>>{ 'OutcomeQuestionCode' => currentValues });
        
        String jsonExp = question.Validations__c;

        String message = String.valueOf(ce.message(Base311_DependentValue.fromJSON(jsonExp)));
        
        if(message != null) { 
            throw new Base311_Exceptions.ValidationException(message);
        }
        
    }
}