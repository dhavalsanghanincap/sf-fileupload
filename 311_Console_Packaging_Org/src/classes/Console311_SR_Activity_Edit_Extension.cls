public with sharing class Console311_SR_Activity_Edit_Extension extends Incap311.Base311_ReallocatePageCtrlBase{
    
    
    public Incap311__Service_Activity__c mSRActivity { get; set; }
    public Case sr { get; set; }
    public List<SelectOption> outcomeValues { get; set; }
    public ApexPages.StandardController ctrl { get; set; }
    public String activeOutcome { get; set; }
    public String previousOutcome { get; set; }
    public List<Console311_Wrap_ActivityQuestionAnswer> ooawList { get; set; }
    public List<Incap311__Activity_Question__c> existingOutcomeAnswers { get; set; }
    public Incap311__Outcome__c outcome { get; set; }
    public Map<String,List<SelectOption>> cannedResponses { get; set; }
    public String cannedResponseCode { get; set; }
    public String selectedCannedResponseID { get; set; }
    public String QuestionsJson { get; set; }
    public Console311_Page_Layout pageLayout { get; set; }
    public List<Exception> exceptions { get; set; }
    public String transferSRTypeCode {get;set;}
    
    public Map<String,String> outcomeActions { get; set; }
    public  Map<String,Map<String,Incap311__Activity_Outcome_Response__c>> outcomeResponse { get; set; }
    public boolean saveNoErrors { get; set; }
    public Map<String,String> AllLabels{get;set;} 
    
    /*Reallocate Component Implementation*/
    public Incap311.Base311_ReallocateController reallocateCtrl { get; set; }
    private final Incap311.Base311_Dependencies restDependancies = new Incap311.Base311_Dependencies();
    
    public override void setComponentController(Incap311.Base311_ReallocateComponentBase compController) {
        reallocateCtrl = (Incap311.Base311_ReallocateController)compController;
    }
    
    public override Incap311.Base311_ReallocateComponentBase getreallocateComponentCtrl() {
        return reallocateCtrl;
    }
    /*End of Reallocate Component related methods*/
    
    
    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public Console311_SR_Activity_Edit_Extension(ApexPages.StandardController stdController) {
        
        System.debug('Contructing Console311_SR_Activity_Edit_Extension');
        
        initVariables(stdController);
        // Fetch the outcomes
        System.debug('!!!!!!!!!! STVA '+this.mSRActivity.Incap311__Service_Type_Version_Activity__c);
        setupOutcomes(getActivityOutcomeList(this.mSRActivity.Incap311__Service_Type_Version_Activity__c));
        ooawList = getOutcomeQuestions();
    }
    
    public void initVariables(ApexPages.StandardController stdController){
         String[] fields = new String[]{ 'Incap311__Internal_Comments__c','Incap311__Assigned_To__c','Incap311__Contact_Name__c','Incap311__Make_Public__c','Incap311__Activity_Outcome__r.Incap311__Outcome__c','Incap311__Additional_Comments__c',
                'Incap311__External_Comments__c','Incap311__Service_Request__r.Incap311__Service_Type_Version__r.Incap311__Service_Type__c','Incap311__Service_Request__r.Incap311__Service_Type_Version__r.Name','Incap311__Service_Request__r.Subject','Incap311__Service_Request__r.Incap311__Service_Request_Number__c','Incap311__Service_Request__r.Incap311__Address__c','Incap311__Service_Request__r.Incap311__Location__longitude__s','Incap311__Service_Request__r.Incap311__Location__latitude__s',                'Incap311__Service_Request__c','Incap311__Service_Request__r.OwnerID','Incap311__Service_Type_Version_Activity__r.Incap311__Service_Type_Version__r.Incap311__Service_Type__c',
                'Incap311__Service_Type_Version_Activity__r.Incap311__Activity__r.Incap311__Activity_Name__c','Incap311__Activity_Outcome__r.Incap311__Outcome__c',
                'Incap311__Service_Type_Version_Activity__r.Incap311__Activity_Code__c','Incap311__Service_Request__r.CaseNumber'};
        if(!test.isRunningTest()){
           
                    
                    stdController.addFields(fields);
        }
        this.ctrl = stdController;
        this.mSRActivity = (Incap311__Service_Activity__c) stdController.getRecord();
        this.outcomeValues = new List<SelectOption>();
        this.ooawList = new List<Console311_Wrap_ActivityQuestionAnswer>();
        this.previousOutcome = '';
        selectedCannedResponseID = null;
        pageLayout = new Console311_Page_Layout('311 Worker Console');
        cannedResponses = new  Map<String,List<SelectOption>>();
        outcomeResponse =  new Map<String,Map<String,Incap311__Activity_Outcome_Response__c>>();
        outcomeActions = new Map<String,String>();
        outcomeActions.put(null,'');
        setupLabels();
        
        if(mSRActivity.Incap311__Assigned_To__c != null){
            mContactToPass = (sobject)[select firstname, lastname, email, phone from user where id = :mSRActivity.Incap311__Assigned_To__c];
        }
        if(mSRActivity.Incap311__Contact_Name__c != null){
            mContactToPass = (sobject)[select firstname, lastname, email, phone from contact where id = :mSRActivity.Incap311__Contact_Name__c];
        }
        
        if(mSRActivity.Incap311__Finish_Date__c == null){
            mSRActivity.Incap311__Finish_Date__c = System.now();
        }

        if(mSRActivity.Incap311__Service_Request__c != null)
        {
            //this.sr = mSRActivity.Incap311__Service_Request__c;
        }
    }
    
    public void setupLabels(){
        String type='Incap311__Service_Activity__c';
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(type);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        AllLabels = new Map<String,String>();
        
        for (String fieldName: fieldMap.keySet()) {
            System.debug(fieldName);
            AllLabels.put(fieldName,fieldMap.get(fieldName).getDescribe().getLabel());
        }
    }

    public Map<String, String> mapLayers {
        get {
            List<String> layers = Incap311.Base311_LocationSearch.getArcGISLayers();

            if(layers.size() > 0) {
                return new Map<String, String>{
                    'Dynamic Layers' => layers[0]
                };
            }

            return new Map<String, String>{ };
        }
    }

    public Double mapCenterLongitude {
        get {
            return mSRActivity.Incap311__Service_Request__r.Incap311__Location__longitude__s != null? mSRActivity.Incap311__Service_Request__r.Incap311__Location__longitude__s : Incap311.Base311_LocationSearch.getMapCenterCoordinates().longitude;
        }
    }

    public Double mapCenterLatitude {
        get {
            return mSRActivity.Incap311__Service_Request__r.Incap311__Location__latitude__s != null ? mSRActivity.Incap311__Service_Request__r.Incap311__Location__latitude__s : Incap311.Base311_LocationSearch.getMapCenterCoordinates().latitude;
        }
    }
    
    public List<Incap311__Activity_Outcome__c> getActivityOutcomeList(String activityId){
        return [
            Select 
            Id,
            Name,
            Incap311__Activity__c,
            Incap311__Activity_Code__c,
            Incap311__Activity_Name__c,
            Incap311__Outcome__c,
            Incap311__Outcome__r.Incap311__Outcome_Action__c,
            Incap311__Outcome_Code__c,
            Incap311__Outcome_Detail__c,
            Incap311__Outcome_Name__c,
            Incap311__Activity__r.Incap311__Activity_Name__c ,
            Incap311__Additional_Comments_Required__c ,
            Incap311__Internal_Comments_Required__c,
            
            (select 
             Id,
             Incap311__Case_Closure_Reason__c,
             Incap311__Canned_Response__r.name,
             Incap311__Canned_Response__r.Incap311__Response_Code__c,
             Incap311__Canned_Response__r.Incap311__Long_Response_Text__c,
             Incap311__Additional_Comments_Required__c,
             Incap311__Internal_Comments_Required__c
             
             from Incap311__Activity_Outcome_Responses__r
            	ORDER BY Incap311__Order__c nulls last)
            From 
            Incap311__Activity_Outcome__c
            WHERE
            Incap311__Service_Type_Version_Activity__c = :activityId
            and Incap311__Service_Type_Version_Activity__c != null
            ORDER BY Incap311__Order__c nulls last
        ];
    }
    
    public void setupOutcomes(List<Incap311__Activity_Outcome__c> srActivityOutcomesList){
        
        for (Incap311__Activity_Outcome__c actOutcome : srActivityOutcomesList) {
            outcomeValues.add(new SelectOption(actOutcome.id, actOutcome.Name));
            setupOutcomeResponse(actOutcome);
        }
        
        outcomeResponse.put(null,new Map<String,Incap311__Activity_Outcome_Response__c>{null => new Incap311__Activity_Outcome_Response__c(Incap311__Additional_Comments_Required__c = true)});
        cannedResponses.put(null,new List<SelectOption>());
        
        if(mSRActivity.Incap311__Activity_Outcome__c != null){
            activeOutcome = mSRActivity.Incap311__Activity_Outcome__c;
        }
        
    }
    
    
    public void setupOutcomeResponse(Incap311__Activity_Outcome__c actOutcome){
        
        list<SelectOption> responses = new list<SelectOption>();
        Map<String,Incap311__Activity_Outcome_Response__c> tempResponses=  new Map<String,Incap311__Activity_Outcome_Response__c>();
        
        for(Incap311__Activity_Outcome_Response__c response : actOutcome.Incap311__Activity_Outcome_Responses__r){
            responses.add(new SelectOption(response.Incap311__Canned_Response__r.Id,response.Incap311__Canned_Response__r.name ));
            tempResponses.put(response.Incap311__Canned_Response__r.Id,response);
            if(mSRActivity.Incap311__External_Comments__c == response.Incap311__Canned_Response__r.Incap311__Long_Response_Text__c){
                selectedCannedResponseID = response.Incap311__Canned_Response__r.Id;
            }
        }
        
        if(actOutcome.Incap311__Outcome__r.Incap311__Outcome_Action__c == null){
            outcomeActions.put(actOutcome.id,'none');
        }else{
            outcomeActions.put(actOutcome.id,actOutcome.Incap311__Outcome__r.Incap311__Outcome_Action__c);
        }
        
        cannedResponses.put(actOutcome.id,responses);
        outcomeResponse.put(actOutcome.id,tempResponses);
    }
    
    public boolean getAdditionalComments(){
        System.debug('getAdditionalComments');
        Map<ID, Incap311__Activity_Outcome__c> aoMap = new  Map<ID, Incap311__Activity_Outcome__c>(getActivityOutcomeList(this.mSRActivity.Incap311__Service_Type_Version_Activity__c));
        
        if(mSRActivity.Incap311__Activity_Outcome__c == null){
            return false;
        }
        if(!aoMap.containskey(mSRActivity.Incap311__Activity_Outcome__c)){
            return false;
        }
        boolean outcomeAdditional = aoMap.get(mSRActivity.Incap311__Activity_Outcome__c).Incap311__Additional_Comments_Required__c;
        if(mSRActivity.Incap311__Activity_Outcome__c != null && 
           selectedCannedResponseID != null &&
           outcomeResponse.containskey(mSRActivity.Incap311__Activity_Outcome__c) &&
           outcomeResponse.get(mSRActivity.Incap311__Activity_Outcome__c).containskey(selectedCannedResponseID)
          ){
              System.debug('getAdditionalComments short ciruit');
              return outcomeAdditional || outcomeResponse.get(mSRActivity.Incap311__Activity_Outcome__c).get(selectedCannedResponseID).Incap311__Additional_Comments_Required__c;
          }
        return outcomeAdditional;
    }
    
    
    public boolean getInternalCommentsRequired(){
        System.debug('getAdditionalComments');
        Map<ID, Incap311__Activity_Outcome__c> aoMap = new  Map<ID, Incap311__Activity_Outcome__c>(getActivityOutcomeList(this.mSRActivity.Incap311__Service_Type_Version_Activity__c));
        
        if(mSRActivity.Incap311__Activity_Outcome__c == null){
            return false;
        }
        if(!aoMap.containskey(mSRActivity.Incap311__Activity_Outcome__c)){
            return false;
        }
        boolean outcomeAdditional = aoMap.get(mSRActivity.Incap311__Activity_Outcome__c).Incap311__Internal_Comments_Required__c;
        if(mSRActivity.Incap311__Activity_Outcome__c != null && 
           selectedCannedResponseID != null &&
           outcomeResponse.containskey(mSRActivity.Incap311__Activity_Outcome__c) &&
           outcomeResponse.get(mSRActivity.Incap311__Activity_Outcome__c).containskey(selectedCannedResponseID)
          ){
              System.debug('getAdditionalComments short ciruit');
              return outcomeAdditional|| outcomeResponse.get(mSRActivity.Incap311__Activity_Outcome__c).get(selectedCannedResponseID).Incap311__Internal_Comments_Required__c;
          }
        return outcomeAdditional;
    }
    
    public void refresh() {getOutcomeQuestions();}
    
    list<Incap311__Activity_Question__c> activityQuestions = new list<Incap311__Activity_Question__c>();
    
    
    public List<Console311_Wrap_ActivityQuestionAnswer> getOutcomeQuestions() {
        
        //if (String.isBlank(this.previousOutcome) || !this.previousOutcome.equalsIgnoreCase(this.activeOutcome) || true) {
        
        //List<Incap311__Outcome_Question__c> outQuestions = new List<Incap311__Outcome_Question__c>();
        Map<String,object> answerMap2 =  getQuestionAnswerMap();
        list<Incap311__Activity_Outcome__c> actOutcomeDeps = new  list<Incap311__Activity_Outcome__c>();
        if(activeOutcome != null){
            actOutcomeDeps = [select id,Incap311__Outcome__c from Incap311__Activity_Outcome__c where
                              Incap311__Service_Type_Version_Activity__c =:this.mSRActivity.Incap311__Service_Type_Version_Activity__c 
                              and id =:activeOutcome];
        }else if(mSRActivity.Incap311__Activity_Outcome__c != null){
            actOutcomeDeps =[select id,Incap311__Outcome__c from Incap311__Activity_Outcome__c where
                             Incap311__Service_Type_Version_Activity__c =:this.mSRActivity.Incap311__Service_Type_Version_Activity__c 
                             and id =:this.mSRActivity.Incap311__Activity_Outcome__c];
        }
        
        if(actOutcomeDeps.size() > 0){
            List<Incap311__Outcome_Question__c> outQuestions = restDependancies.getActiveQuestionsV2(actOutcomeDeps[0],answerMap2);
            System.debug(outQuestions);
            System.debug('Getting Outcome Questions');
            list<id> outQIds = new list<id>();
            for(Incap311__Outcome_Question__c outQuestion : outQuestions){
                outQIds.add(outQuestion.Id);
            }
            
            outQuestions = [
                Select 
                Name,
                Incap311__Question_Text__c,
                Incap311__Question_Code__c,
                Incap311__Outcome_Code__c,
                Incap311__Override_Order__c,
                Incap311__Question__r.Incap311__Question__c,
                Incap311__Question__r.Incap311__Required__c, 
                Incap311__Question__r.Incap311__Data_Type__c,
                Incap311__Question__r.Incap311__Answer_Values__c, 
                Incap311__Question__r.Incap311__Hint_Text__c,
                Incap311__Is_Controlling__c,
                Incap311__Order__c,
                Incap311__Is_Required_Question__c, 
                Incap311__Is_Read_Only__c,
                Incap311__Display_Sort_Order__c,
                Incap311__Activity_Outcome__c,
                Incap311__Override_Answer_Values__c ,
                Incap311__Question__r.Incap311__Flex_Question_Code__c
                From 
                Incap311__Outcome_Question__c
                Where 
                id in :outQIds
                order by Incap311__Display_Sort_Order__c Asc
            ];
            
            Map<String,Incap311__Activity_Question__c> answerMap = new Map<String,Incap311__Activity_Question__c>();
            
            for(Incap311__Activity_Question__c actQuestion: actQuestions){
                answerMap.put(actQuestion.Incap311__Outcome_Question__r.Incap311__Question__r.Incap311__Flex_Question_Code__c ,actQuestion);
            }
            
            
            ooawList.clear();
            for (Incap311__Outcome_Question__c oq : outQuestions) {
                Incap311__Activity_Question__c activityQuestion;
                Console311_Wrap_ActivityQuestionAnswer cwAQA = new Console311_Wrap_ActivityQuestionAnswer(oq,answerMap2);
                if(answerMap.get(oq.Incap311__Question__r.Incap311__Flex_Question_Code__c) != null){
                    cwAQA.sq = answerMap.get(oq.Incap311__Question__r.Incap311__Flex_Question_Code__c);
                }
                cwAQA.sq.Incap311__Answer__c = (String)answerMap2.get(oq.Incap311__Question__r.Incap311__Flex_Question_Code__c);
                cwAQA.sq.Incap311__question__c = oq.Incap311__Question__r.Incap311__Question__c;
                ooawList.add(cwAQA);
            }
            this.previousOutcome = this.activeOutcome;      
            // }}
        }
        return ooawList;
    }
    
    public PageReference saveActivity() {
        return save();
    }
    
    list<Incap311__Activity_Question__c> actQuestions;
    
    public Map<String,object> getQuestionAnswerMap(){
        Map<String,object> questionAnswerMap = new Map<String,object>();
        
        //get answers from currect activity question
        actQuestions = [select id, Incap311__Answer__c, Incap311__Outcome_Question__r.Incap311__Question__r.Incap311__Flex_Question_Code__c  
                        from Incap311__Activity_Question__c where Incap311__Service_Activity__c = :mSRActivity.Id and Incap311__Outcome_Question__r.Incap311__Outcome_Code__c= :getOutcomeCode()];
        
        for(Incap311__Activity_Question__c actQuestion: actQuestions){
            if(actQuestion.Incap311__Answer__c != null)
                questionAnswerMap.put(actQuestion.Incap311__Outcome_Question__r.Incap311__Question__r.Incap311__Flex_Question_Code__c ,(object)actQuestion.Incap311__Answer__c);
        }
        
        //override answers with currrent page 
        ActivityWrapper aWrapper;
        if (String.isNotBlank(QuestionsJson)) {
            try {
                System.debug('----> Json Str: ' + QuestionsJson);
                aWrapper = (ActivityWrapper) JSON.deserialize(QuestionsJson, ActivityWrapper.class);
                System.debug('----> aWrapper: ' + aWrapper);
                
                
                for(ActivityQuestionWrapper serviceQuestion :  aWrapper.serviceQuestions){
                    if(serviceQuestion.mSRTypeVQuestionName != null && serviceQuestion.question.Incap311__Answer__c != null){
                        questionAnswerMap.put(serviceQuestion.mSRTypeVQuestionName, (object)serviceQuestion.question.Incap311__Answer__c);
                    }
                }
                
                return questionAnswerMap;
            } catch (Exception e) {
                System.debug('----> Error occured while parsing sent JSON: ' + e.getMessage());
                //mErrorMsg = 'Unable to Save the given request data. Please try agaain.';
                throw e;
                return questionAnswerMap;
            }
        }
        return questionAnswerMap;
        
    }
    
    public PageReference save() {        
        
        System.debug('----> Save: Begining Process...');
        Map<String,Object> questionAnswerMap = getQuestionAnswerMap();
        System.debug(questionAnswerMap);
        saveNoErrors = true;
        
        
        
        
        Savepoint sp = Database.setSavepoint();
        System.debug('----> Saving');
        // Save the new changes.
        try {
            
            
            if(getAdditionalComments() && mSRActivity.Incap311__Additional_Comments__c == null){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Additional Comments required with selected response or outcome'));
                saveNoErrors = false;
                return null;
            }
            
            if(getInternalCommentsRequired() && mSRActivity.Incap311__Internal_Comments__c == null){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Internal Comments required with selected response or outcome'));
                saveNoErrors = false;
                return null;
            }
            
            
            String ResponseCode = getResponseCode();
            String outcomeCode = getOutcomeCode();
            Incap311.Base311_ActivityV2 activityUpdate = new Incap311.Base311_ActivityV2(mSRActivity.Incap311__Service_Type_Version_Activity__r.Incap311__Activity_Code__c, 
                                                                                         outcomeCode, ResponseCode, mSRActivity.Incap311__Additional_Comments__c, questionAnswerMap, 
                                                                                         String.valueOf(mSRActivity.incap311__finish_date__c), 'Complete',mContactToPass);
            activityUpdate.Make_Public = mSRActivity.incap311__Make_Public__c;
            activityUpdate.Internal_Comments = mSRActivity.Incap311__Internal_Comments__c;
            Incap311.Base311_Service_Request bsr = new Incap311.Base311_Service_Request();
            Incap311.Base311_Service_ActivityV2 bsa = new Incap311.Base311_Service_ActivityV2();
            bsa.updateServiceActivity(bsr.getServiceRequest(mSRActivity.Incap311__Service_Request__r.CaseNumber), activityUpdate);
            if(outcomeActions.get(mSRActivity.Incap311__Activity_Outcome__c) == 'Reallocate'){
                reallocateCase();
            }
            
            
            
            
        } catch (Exception ex) {
            Database.rollback(sp);
            exceptions = new list<Exception>();
            //throw ex;
            exceptions.add((Exception)ex);
            ApexPages.addMessages(ex);
            //throw ex;
            saveNoErrors = false;
            
        }
        System.debug('----> End Saving');     
        
        return null;
    }
    
    
    public String getResponseCode(){
        String out = '';
        if(mSRActivity.Incap311__Activity_Outcome__c != null &&
           selectedCannedResponseID != null &&
           outcomeResponse.containskey(mSRActivity.Incap311__Activity_Outcome__c) && 
           outcomeResponse.get(mSRActivity.Incap311__Activity_Outcome__c).containskey(selectedCannedResponseID)){
               out = (String)outcomeResponse.get(mSRActivity.Incap311__Activity_Outcome__c).get(selectedCannedResponseID).Incap311__Canned_Response__r.Incap311__Response_Code__c;
           }
        return out;
    }
    
    public String getOutcomeCode(){
        String out;
        if(mSRActivity.Incap311__Activity_Outcome__c != null){
            list<Incap311__Activity_Outcome__c> activityOutcomes = [select id,Incap311__Outcome__c,Incap311__Outcome_Code__c from Incap311__Activity_Outcome__c WHERE  id = :mSRActivity.Incap311__Activity_Outcome__c];
            out =   activityOutcomes.size() > 0 ? activityOutcomes[0].Incap311__Outcome_Code__c : '';
            //outcome = mSRActivity.incap311__Allowable_outcome__c;
        }
        return out;
    }
    
    public void caseClose(){
        
        Case updateCase = new Case(id = mSRActivity.Incap311__Service_Request__c);
        if(mSRActivity.Incap311__Activity_Outcome__c != null &&
           selectedCannedResponseID != null &&
           outcomeResponse.containskey(mSRActivity.Incap311__Activity_Outcome__c) && 
           outcomeResponse.get(mSRActivity.Incap311__Activity_Outcome__c).containskey(selectedCannedResponseID)){
               updateCase.Reason = outcomeResponse.get(mSRActivity.Incap311__Activity_Outcome__c).get(selectedCannedResponseID).Incap311__Case_Closure_Reason__c;
               updateCase.Incap311__Closing_Respopnse__c = outcomeResponse.get(mSRActivity.Incap311__Activity_Outcome__c).get(selectedCannedResponseID).Incap311__Canned_Response__r.name;
               
           }
        
        updateCase.Incap311__Additional_Comments__c = mSRActivity.Incap311__Additional_Comments__c;
        if(mSRActivity.Incap311__Activity_Outcome__c != null && outcomeResponse.containsKey(mSRActivity.Incap311__Activity_Outcome__c) && selectedCannedResponseID != null && outcomeResponse.get(mSRActivity.Incap311__Activity_Outcome__c).containsKey(selectedCannedResponseID) ){
            updateCase.Incap311__External_Comments__c = (String)outcomeResponse.get(mSRActivity.Incap311__Activity_Outcome__c).get(selectedCannedResponseID).Incap311__Canned_Response__r.Incap311__Long_Response_Text__c;
        }
        updateCase.Incap311__Closing_Activity__c = mSRActivity.id;
        
        update updateCase;
        
        CaseComment caseComment = new CaseComment();
        caseComment.CommentBody = mSRActivity.Incap311__Internal_Comments__c;
        caseComment.parentId = updateCase.Id;
        caseComment.IsPublished = mSRActivity.incap311__Make_Public__c;
        insert caseComment;
    }
    
    public void reallocateCase(){
        if(reallocateCtrl != null && reallocateCtrl.queueid != null){
            Case updateCase = [select id,Ownerid,Incap311__Case_Comments__c from case where id = :mSRActivity.Incap311__Service_Request__c];
            if(reallocateCtrl.queueid != null){
                updateCase.OwnerID = reallocateCtrl.queueid;
            }
            if(reallocateCtrl.comment != null && reallocateCtrl.comment != ''){
                updateCase.Incap311__Case_Comments__c = (updateCase.Incap311__Case_Comments__c != null ? updateCase.Incap311__Case_Comments__c : '') + 
                    '\n\n' + 
                    'Manually Reallocated Case - ' + 
                    UserInfo.getUserName() + 
                    ' - ' + 
                    Incap311.Base311_Helper.formatDate(System.today()) + ' - ' + 
                    reallocateCtrl.comment;
            }else{
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Response is required when reallocating'));
                saveNoErrors = false;
            }
            if(saveNoErrors){
                update updateCase;
            }
        }
    }
    
    public string parseMultipicklist(String finalAnswer){
        finalAnswer = finalAnswer.replace('[', '').replace('"', '').replace(']', '').replace(',', ', ');
        return finalAnswer;
    }
    
    /* public List<Console311_Wrap_FlexnoteQuestionAnswer> refreshFlexnotesWithUpdates() {
return Console311_Util_Flexnote.fetchWithUpdates(
this.mSRActivity.Incap311__Service_Type_Version_Activity__r.Incap311__Service_Type_Version__r.Name, 
new Map<String, Object>(), 
new List<Console311_Wrap_FlexnoteQuestionAnswer>()
);
}*/
    
    public PageReference refreshFlexnotesWithAnswers(){
        return null;
    }
    
    public Sobject mContactToPass { get; set; }     
    public void feedAssignToInformationToPage() {
        try {
            System.debug('----> assignToJson: ' + ApexPages.currentPage().getParameters().get('assignToJson'));
            Sobject tempCon = (Sobject) JSON.deserialize(ApexPages.currentPage().getParameters().get('assignToJson'), Sobject.class);
            System.debug('----> TempCon: ' + tempCon);
            String contactId = (tempCon != null ? tempCon.Id : '');
            mContactToPass = tempCon;
            //this.mContactToPass = conCtrl.feedContactInformationToPage(contactId);
        } catch (Exception e) {
            System.debug('----> Error: ' + e.getMessage());
            this.mContactToPass = null;
        }
    }
    
    /*public Console311_Section_ContactCtrl conCtrl { set; get {
if (getComponentControllerMap() != null) {
Console311_Section_ContactCtrl conCtrl = (Console311_Section_ContactCtrl) getComponentControllerMap().get('contact');

if (conCtrl != null) {
return conCtrl;
}
}
return new Console311_Section_ContactCtrl();
}}*/
    
    
    public class ActivityWrapper {
        
        public List<ActivityQuestionWrapper> serviceQuestions { get; set; }
        
        
        public ActivityWrapper() {}
    }
    
    
    public class ActivityQuestionWrapper {
        public String mSRTypeVQuestionName { get; set; }
        public String mDataType { get; set; }
        public Incap311__Activity_Question__c question { get; set; }
        
        public ActivityQuestionWrapper() {}
    }
    
    
    
    
}