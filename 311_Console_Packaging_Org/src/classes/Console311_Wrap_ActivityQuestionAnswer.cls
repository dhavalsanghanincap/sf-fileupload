/*
 * Block comments with details of changes
 */
public class Console311_Wrap_ActivityQuestionAnswer extends Console311_Wrap_QuestionAnswer
{
    public Console311_Wrap_ActivityQuestionAnswer()
    {

    } 

    public Incap311__Outcome_Question__c stvQuestion { get; set; }

    public Incap311__Activity_Question__c sq { get;  set;}
    public Map<String,Object> qAMap = new Map<String,Object>();

    public Console311_Wrap_ActivityQuestionAnswer(Incap311__Outcome_Question__c stvQuestion) {
        this.stvQuestion = stvQuestion;
        sq = new Incap311__Activity_Question__c();
        sq.Incap311__Outcome_Question__c = stvQuestion.Id;
        sq.Incap311__Question__c = stvQuestion.Incap311__Question_Text__c;
    }

    public Console311_Wrap_ActivityQuestionAnswer(Incap311__Outcome_Question__c stvQuestion,  Map<String,Object> qAMap) {
        this(stvQuestion);
        this.qAMap = qAMap;
    }

    public Console311_Wrap_ActivityQuestionAnswer(Incap311__Outcome_Question__c stvQuestion, Incap311__Activity_Question__c sq) {
        this(stvQuestion);
        this.stvQuestion = stvQuestion;
        this.sq = sq;
    }




    public override Object getCurrentAnswer() {
        String flexCode = this.stvQuestion.Incap311__Question_Code__c;

        if(qAMap.containsKey(flexCode)) {
            return qaMAP.get(flexCode);
        }
        return null;
    }

    public override Integer getQuestionOrderRank() {
        if (this.stvQuestion == null || (!this.stvQuestion.Incap311__Is_Required_Question__c && this.stvQuestion.Incap311__Order__c == null && stvQuestion.Incap311__Override_Order__c == null)) {
            return 99;       
        }
        return stvQuestion.Incap311__Override_Order__c != null ? Integer.valueOf(stvQuestion.Incap311__Override_Order__c) : (stvQuestion.Incap311__Order__c != null ? Integer.valueOf(stvQuestion.Incap311__Order__c) : 1);
    }

    public override List<Incap311.Base311_QuestionAnswer> getActivePicklist(){
        List<Incap311.Base311_QuestionAnswer> qaList = new  List<Incap311.Base311_QuestionAnswer>();
        return  Incap311.Base311_Dependencies.getSobjectActivePicklist((sobject)this.stvQuestion, qAMap);

        return qaList;
    }

    public override sobject getQuestion(){
        return stvQuestion;
    }

    public override string getQuestionCode(){
        return stvQuestion.Incap311__Question__r.Incap311__Flex_Question_Code__c;
    }

    public  void setAnswer(String answer){
        System.debug('-----> Setting answer '+ answer);
        this.sq.Incap311__answer__c = answer;
    }

    public  String getAnswer(){
        return sq.Incap311__answer__c;
    }
    
    public Boolean validateValueType() {
        String datatype = stvQuestion.Incap311__Question__r.Incap311__Data_Type__c;
        return validateValueType( datatype);
    }

    public Boolean validateValueType( String datatype) {
        String value = getAnswer();
        if(value == null && this.stvQuestion.Incap311__Is_Required_Question__c){
            throw new InvalidAnswerException('Question : '+sq.Incap311__question__c+' is required');
            return false;
        }

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
                if( value == 'true' || value == 'false') {
                    return true;
                }

                return false;
            }

            if(dataType == 'Date/Time' || dataType == 'Date') {
                Datetime dt = incap311.Base311_Helper.parseDate((String) value);
                return true;
            }

            if(dataType == 'MultiPicklist' ) {
                for(String picklistOption: value.split(Incap311.Base311_Attribute.MULTI_PICKLIST_SEPERATOR)){
                    if(!validatePicklistOption((String) value)){
                        return false;
                    }
                }
                return true;
            }

            if(dataType == 'MultiPicklist' || dataType == 'Picklist') {
                return validatePicklistOption((String) value);
            }

            return true;
        } 
        catch(Exception e) { }

        throw new InvalidAnswerException('Question : '+sq.Incap311__question__c+' is of type '+datatype+' Answer :'+value+ 'is not of type '+datatype);


        return false;
    }

    public class InvalidAnswerException extends Exception {}


}