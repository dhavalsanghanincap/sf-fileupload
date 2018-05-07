public with sharing class Dev_Console311_Activity_Edit_Ext extends Incap311.Base311_ReallocatePageCtrlBase{


    public Incap311__Service_Activity__c mSRActivity { get; set; }
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
    public Dev_Console311_Activity_Edit_Ext(ApexPages.StandardController stdController) {

        System.debug('Contructing Console311_SR_Activity_Edit_Extension');

        initVariables(stdController);
        // Fetch the outcomes
        System.debug('!!!!!!!!!! STVA '+this.mSRActivity.Incap311__Service_Type_Version_Activity__c);
        setupOutcomes(getActivityOutcomeList(this.mSRActivity.Incap311__Service_Type_Version_Activity__c));
        ooawList = getOutcomeQuestions();
    }

    public void initVariables(ApexPages.StandardController stdController){
        if(!test.isRunningTest()){
            String[] fields = new String[]{ 'Incap311__Internal_Comments__c','Incap311__Additional_Comments__c','Incap311__External_Comments__c','Incap311__Service_Request__r.Incap311__Address__c','Incap311__Service_Request__c','Incap311__Service_Request__r.OwnerID','Incap311__Service_Type_Version_Activity__r.Incap311__Service_Type_Version__r.Incap311__Service_Type__c','Incap311__Service_Type_Version_Activity__r.Incap311__Activity__r.Incap311__Activity_Name__c','Incap311__Activity_Outcome__r.Incap311__Outcome__c'};

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
        setupLabels();
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

            (select 
             Id,
             Incap311__Case_Closure_Reason__c,
             Incap311__Canned_Response__r.name,
             Incap311__Canned_Response__r.Incap311__Response_Code__c,
             Incap311__Canned_Response__r.Incap311__Long_Response_Text__c,
             Incap311__Additional_Comments_Required__c

             from Incap311__Activity_Outcome_Responses__r)
            From 
            Incap311__Activity_Outcome__c
            WHERE
            Incap311__Service_Type_Version_Activity__c = :activityId
            and Incap311__Service_Type_Version_Activity__c != null
            ORDER BY Incap311__Order__c
        ];
    }

    public void setupOutcomes(List<Incap311__Activity_Outcome__c> srActivityOutcomesList){

        for (Incap311__Activity_Outcome__c actOutcome : srActivityOutcomesList) {
            outcomeValues.add(new SelectOption(actOutcome.Incap311__Outcome__c, actOutcome.Name));
            setupOutcomeResponse(actOutcome);
        }

        outcomeResponse.put(null,new Map<String,Incap311__Activity_Outcome_Response__c>{null => new Incap311__Activity_Outcome_Response__c(Incap311__Additional_Comments_Required__c = true)});
        cannedResponses.put(null,new List<SelectOption>());

        if(mSRActivity.Incap311__Allowable_Outcome__c != null){
            activeOutcome = mSRActivity.Incap311__Allowable_Outcome__c;
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
            outcomeActions.put(actOutcome.Incap311__Outcome__c,'none');
        }else{
            outcomeActions.put(actOutcome.Incap311__Outcome__c,actOutcome.Incap311__Outcome__r.Incap311__Outcome_Action__c);
        }

        cannedResponses.put(actOutcome.Incap311__Outcome__c,responses);
        outcomeResponse.put(actOutcome.Incap311__Outcome__c,tempResponses);
    }

    public boolean getAdditionalComments(){
        System.debug('getAdditionalComments');
        Map<ID, Incap311__Activity_Outcome__c> aoMap = new  Map<ID, Incap311__Activity_Outcome__c>(getActivityOutcomeList(this.mSRActivity.Incap311__Service_Type_Version_Activity__c));
        
        if(mSRActivity.Incap311__Activity_Outcome__c == null){
            return false;
        }
        
        boolean outcomeAdditional = aoMap.get(mSRActivity.Incap311__Activity_Outcome__c).Incap311__Additional_Comments_Required__c;
        if(mSRActivity.Incap311__Allowable_Outcome__c == null || 
           selectedCannedResponseID == null || 
           !outcomeResponse.containskey(mSRActivity.Incap311__Allowable_Outcome__c) || 
           !outcomeResponse.get(mSRActivity.Incap311__Allowable_Outcome__c).containskey(selectedCannedResponseID)
          ){
            System.debug('getAdditionalComments short ciruit');
            return outcomeAdditional;
        }else{
            System.debug('getAdditionalComments get some '+ outcomeResponse.get(mSRActivity.Incap311__Allowable_Outcome__c).get(selectedCannedResponseID));
            return outcomeAdditional || outcomeResponse.get(mSRActivity.Incap311__Allowable_Outcome__c).get(selectedCannedResponseID).Incap311__Additional_Comments_Required__c;

        }
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
                              and Incap311__Outcome__c =:activeOutcome];
        }else if(mSRActivity.Incap311__Allowable_Outcome__c != null){
            actOutcomeDeps =[select id,Incap311__Outcome__c from Incap311__Activity_Outcome__c where
                             Incap311__Service_Type_Version_Activity__c =:this.mSRActivity.Incap311__Service_Type_Version_Activity__c 
                             and Incap311__Outcome__c =:this.mSRActivity.Incap311__Allowable_Outcome__c];
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
                        from Incap311__Activity_Question__c where Incap311__Service_Activity__c = :mSRActivity.Id];

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
            System.debug('----> this.mSRActivity: ' + this.mSRActivity);
            System.debug(ooawList);
            if(outcomeActions.get(mSRActivity.Incap311__Allowable_Outcome__c) == 'Close'){
                caseClose();
            }

            if(getAdditionalComments() && mSRActivity.Incap311__Additional_Comments__c == null){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Additional Comments Requred with selected Response'));

                return null;
            }

            if(mSRActivity.Incap311__Allowable_Outcome__c != null &&
               selectedCannedResponseID != null &&
               outcomeResponse.containskey(mSRActivity.Incap311__Allowable_Outcome__c) && 
               outcomeResponse.get(mSRActivity.Incap311__Allowable_Outcome__c).containskey(selectedCannedResponseID)){
                mSRActivity.Incap311__External_Comments__c = (String)outcomeResponse.get(mSRActivity.Incap311__Allowable_Outcome__c).get(selectedCannedResponseID).Incap311__Canned_Response__r.Incap311__Long_Response_Text__c;
            }

            if(mSRActivity.Incap311__Allowable_Outcome__c != null){
                list<Incap311__Activity_Outcome__c> activityOutcomes = [select id from Incap311__Activity_Outcome__c WHERE Incap311__Activity__c = :this.mSRActivity.Incap311__Service_Type_Version_Activity__r.Incap311__Activity__r.Id and Incap311__Outcome__c = :mSRActivity.Incap311__Allowable_Outcome__c];
                mSRActivity.Incap311__Activity_Outcome__c = activityOutcomes.size() > 0 ? activityOutcomes[0].Id : null;
            }

            update mSRActivity;

            List<Incap311__Activity_Question__c> sqList = new List<Incap311__Activity_Question__c>();
            // Grab all the service question answers from the wrapper objects to save.
            for (Console311_Wrap_ActivityQuestionAnswer oqaw : this.ooawList) {
                System.debug('oqaw.sq '+oqaw.sq);
                oqaw.sq.Incap311__Service_Request__c = mSRActivity.Incap311__Service_Request__c;
                oqaw.sq.Incap311__Service_activity__c = mSRActivity.Id;

                if(questionAnswerMap != null && oqaw.stvQuestion != null && oqaw.stvQuestion.Incap311__Question__c != null ){
                    oqaw.sq.Incap311__Answer__c = (String)questionAnswerMap.get(oqaw.stvQuestion.Incap311__Question__r.Incap311__Flex_Question_Code__c);
                }

                if (oqaw.stvQuestion.Incap311__Question__r.Incap311__Data_Type__c == 'MultiPicklist' && 
                    String.isNotBlank(oqaw.sq.Incap311__Answer__c) ) {
                    oqaw.sq.Incap311__Answer__c = parseMultipicklist(oqaw.sq.Incap311__Answer__c);
                }

                oqaw.validateValueType();

                sqList.add(oqaw.sq);
            }

            List<Incap311__Outcome__c> outList = [select Incap311__Outcome_Action__c from Incap311__Outcome__c where id  = :mSRActivity.Incap311__Allowable_Outcome__c];
            outcome = outList.size() > 0 ? outList.get(0) : null;

            upsert sqList;
            upsert activityQuestions;
            System.debug(outcomeActions);
            System.debug(outcomeActions.get(mSRActivity.Incap311__Allowable_Outcome__c));
            // if(outcomeActions.get(mSRActivity.Incap311__Allowable_Outcome__c) == 'Close'){


            //  }
            // Send user back to Outcome Activity details page.
            PageReference newPage = New PageReference('/' + ApexPages.currentPage().getParameters().get('id'));
            newPage.setRedirect(true);

            /*Reallocate Component related update*/
            if(outcomeActions.get(mSRActivity.Incap311__Allowable_Outcome__c) == 'Reallocate' && reallocateCtrl != null){
                reallocateCase();
            }
            //End of the reallocate changes



        } catch (Exception ex) {
            Database.rollback(sp);
            exceptions = new list<Exception>();
            //throw ex;
            exceptions.add((Exception)ex);
            ApexPages.addMessages(ex);
            saveNoErrors = false;

        }
        System.debug('----> End Saving');     

        return null;
    }

    public void caseClose(){

        Case updateCase = [select id from case where id = :mSRActivity.Incap311__Service_Request__c];
        if(mSRActivity.Incap311__Allowable_Outcome__c != null &&
           selectedCannedResponseID != null &&
           outcomeResponse.containskey(mSRActivity.Incap311__Allowable_Outcome__c) && 
           outcomeResponse.get(mSRActivity.Incap311__Allowable_Outcome__c).containskey(selectedCannedResponseID)){
            updateCase.Reason = outcomeResponse.get(mSRActivity.Incap311__Allowable_Outcome__c).get(selectedCannedResponseID).Incap311__Case_Closure_Reason__c;
            updateCase.Incap311__Closing_Respopnse__c = outcomeResponse.get(mSRActivity.Incap311__Allowable_Outcome__c).get(selectedCannedResponseID).Incap311__Canned_Response__r.name;
        }

        updateCase.Incap311__Additional_Comments__c = mSRActivity.Incap311__Additional_Comments__c;
        updateCase.Incap311__External_Comments__c = mSRActivity.Incap311__External_Comments__c;

        update updateCase;

        CaseComment caseComment = new CaseComment();
        caseComment.CommentBody = mSRActivity.Incap311__Internal_Comments__c;
        caseComment.parentId = updateCase.Id;
        insert caseComment;
    }

    public void reallocateCase(){
        Case updateCase = [select id,Ownerid,Incap311__Case_Comments__c from case where id = :mSRActivity.Incap311__Service_Request__c];
        if(reallocateCtrl.queueid != null){
            updateCase.OwnerID = reallocateCtrl.queueid;
        }
        if(reallocateCtrl.comment != null){
            updateCase.Incap311__Case_Comments__c = (updateCase.Incap311__Case_Comments__c != null ? updateCase.Incap311__Case_Comments__c : '') + 
                '\n\n' + 
                'Manually Reallocated Case - ' + 
                UserInfo.getUserName() + 
                ' - ' + 
                Incap311.Base311_Helper.formatDate(System.today()) + ' - ' + 
                reallocateCtrl.comment;
        }
        update updateCase;
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