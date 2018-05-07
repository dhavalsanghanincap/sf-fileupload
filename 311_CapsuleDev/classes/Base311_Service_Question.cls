/*********
* @author 
* @date 
* @group 
* @group-content
* @description 
*/
global class Base311_Service_Question {

    /**
    * @description 
    * @return 
    * @param 
    * @param 
    * @example
    */
    private static void verifyAttributesProvided(Map<String, Base311_Attribute> attributes, List<Service_Type_Version_Question__c> questions) {
        
        // for each attribute the user has given us, check it against the
        // existing questions. if it does not exist; then the user has
        // provided an invalid question code; so we have a problem  
        for(String key : attributes.keySet()) {
            if(!Base311_Helper.listContains(questions, 'Question__r.Flex_Question_Code__c', key)) {
                throw new Base311_Exceptions.UnsupportedException('Unknown question code ' + key);
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
    global List<Service_Question__c> patchQuestionResponses(Case c, Base311_PatchValue attributes) {
        Map<String, Service_Question__c> mappedSQS = new Map<String, Service_Question__c>();
        List<Service_Question__c> updates = new List<Service_Question__c>();
        
        for(Service_Question__c sq : c.Service_Questions__r) {
            mappedSQS.put(sq.Question_Code__c, sq);
        }
        
        
        if(!attributes.isSet || !(attributes.value instanceof Map<String, Object>)) {
            return updates;
        }
        
        Map<String, Object> context = (Map<String, Object>) attributes.value;
        
        List<Service_Type_Version_Question__c> questions = getQuestionsByVersionCode(c.Service_Type_Version__c);
        Map<String, Base311_Attribute> attrs = Base311_Attribute.fromMap(context);
        
        // check that each attribute is valid
        verifyAttributesProvided(attrs, questions);
        
        
        List<String> sqFields = new List<String>{ 'Incap311__Answer__c' };
    
        if(!Base311_Security.areAccessible(Service_Question__c.SObjectType, sqFields)) {
            throw new Base311_Exceptions.SecurityException('User does not have access to Service Questions');
        }
        
        for(String code : attrs.keySet()) {
            Base311_Attribute attr = attrs.get(code);
            Service_Question__c sq = mappedSQS.containsKey(code) ? mappedSQS.get(code) : null;
            
            if(sq == null) {
                throw new Base311_Exceptions.UnsupportedException('Tried to PATCH service question ' + code + '; but it was not found');
            }

            attr.setContext(sq.Service_Type_Version_Question__r, context).validate().throwErrors();
            sq.Answer__c = attr.stringifyValue();
            updates.add(sq);
        }
        
        update updates;
        
        return updates;
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global List<Service_Type_Version_Question__c> getQuestionsByVersionCode(Id serviceTypeVersionId) {
        List<String> fields = new List<String>{ 'Incap311__Question__c' };
    
        if(!Base311_Security.areAccessible(Service_Type_Version_Question__c.SObjectType, fields)) {
            throw new Base311_Exceptions.SecurityException('User does not have access to Service Type Version Questions');
        }
        List<String> questionFields = new List<String>{ 'Id' };
    
        if(!Base311_Security.areAccessible(Question__c.SObjectType, questionFields)) {
            throw new Base311_Exceptions.SecurityException('User does not have access to Questions');
        }
        
        return [
            SELECT 
                Id, Name, Is_Required_Question__c, Question__r.Data_Type__c, Override_Answer_Values__c, Question__r.Answer_Values__c,
                Question__r.Question__c, Question__r.Flex_Question_Code__c, Is_Read_Only__c, Data_Type__c, Validations__c, Dependencies__c
            FROM 
                Service_Type_Version_Question__c 
            WHERE 
                Service_Type_Version__c = :serviceTypeVersionId
        ];
    }
   
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global List<Service_Question__c> upsertQuestionResponses(Case c, Map<String, Base311_Attribute> attributes) { 
        
        // setup our data; create maps of the attributes (data we've received)
        // and the existing answers (may or may not be empty)
        // additionally, fetch all of the questions for the type
        Map<String, Service_Question__c> mappedSQS = new Map<String, Service_Question__c>();
        Map<String, Object> context = new Map<String, Object>();
        
        for(Base311_Attribute attr : attributes.values()) {
            context.put(attr.code, attr.value);
        }
        
        
        for(Service_Question__c sq : (c.Service_Questions__r != null ? c.Service_Questions__r : new List<Service_Question__c>())) {
            mappedSQS.put(sq.Question_Code__c, sq);
        }
         
        List<Service_Type_Version_Question__c> questions = getQuestionsByVersionCode(c.Service_Type_Version__c);
        
        List<String> fields = new List<String>{
          'Incap311__Answer__c', 'Incap311__Service_Type_Version_Question__c', 'Incap311__Service_Request__c',
          'Incap311__Question__c'
        };
            
        List<String> updateFields = new List<String>{
          'Incap311__Answer__c', 'Incap311__Service_Type_Version_Question__c', 'Incap311__Question__c'
        };
            
        if(!Base311_Security.areCreateable(Service_Question__c.SObjectType, fields) || !Base311_Security.areUpdateable(Service_Question__c.SObjectType, updateFields)) {
            throw new Base311_Exceptions.SecurityException('User does not have access to create Service Questions');
        }
        
        // check that each attribute is valid
        verifyAttributesProvided(attributes, questions);
        
        // for each question associated with the service type, either:
        // 1. update the existing answer
        // 2. create a new answer
        // if a question is required, but no data is provided, then we have a problem.
        
        List<Service_Question__c> updates = new List<Service_Question__c>();
        
        for(Service_Type_Version_Question__c question : questions) {
            
            
            // only create or update questions that aren't read only, or aren't "Informational" type.
            if(!question.Is_Read_Only__c && question.Data_Type__c != 'Informational') {
            
                // if we don't have an atttribute defined, assume its a null value
                Base311_Attribute ra = attributes.containsKey(question.Question__r.Flex_Question_Code__c) ? 
                    attributes.get(question.Question__r.Flex_Question_Code__c) :
                    new Base311_Attribute(question.Question__r.Flex_Question_Code__c, null, question);
                
                ra.setContext(question, context);
                
                // check that the question is actually active OR if we want to generate all
                // questions regardless of its state.
                

                if(ra.isActive() || c.Service_Type_Version__r.Generate_All_Questions__c) {
                    
                    // if its valid, check for errors and throw them
                    ra.validate().throwErrors();
                    
                    // find any previously defined Service Question before creating a new one
                    Service_Question__c sq = mappedSQS.containsKey(question.Question__r.Flex_Question_Code__c) ? 
                        mappedSQS.get(question.Question__r.Flex_Question_Code__c) : 
                        new Service_Question__c();
                    
                    if(sq.Id == null) {
                        sq.Service_Type_Version_Question__c = question.Id;
                        sq.Question__c = question.Question__r.Question__c;  
                        sq.Service_Request__c = c.Id;
                    }
                    
                    sq.Answer__c = ra.stringifyValue();
                    
                    updates.add(sq); 
                }
                
            }
        }
        
        upsert updates; 
        
        return updates;
    } 
}