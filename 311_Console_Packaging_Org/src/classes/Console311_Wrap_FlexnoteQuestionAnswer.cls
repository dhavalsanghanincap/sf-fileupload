public with sharing class Console311_Wrap_FlexnoteQuestionAnswer extends Console311_Wrap_QuestionAnswer{
    public Console311_Wrap_FlexnoteQuestionAnswer() {

    }

    public Incap311__Service_Type_Version_Question__c stvQuestion { get; set; }
    public Incap311__Service_Question__c sq { get; set; }
    public Map<String,Object> qAMap = new Map<String,Object>();

    public Console311_Wrap_FlexnoteQuestionAnswer(Incap311__Service_Type_Version_Question__c stvq) {
        this.stvQuestion = stvq;
        this.sq = new Incap311__Service_Question__c();
    }

    public Console311_Wrap_FlexnoteQuestionAnswer(Incap311__Service_Type_Version_Question__c stvq,  Map<String,Object> qAMap) {
        this(stvq);
        this.qAMap = qAMap;
    }

    public Console311_Wrap_FlexnoteQuestionAnswer(Incap311__Service_Type_Version_Question__c stvq, Incap311__Service_Question__c sq) {
        this.sq = sq;
        this.stvQuestion = stvq;
    }

    public override Object getCurrentAnswer() {
        String flexCode = this.stvQuestion.Incap311__Question__r.Incap311__Flex_Question_Code__c;

        if(qAMap.containsKey(flexCode)) {
            return qaMAP.get(flexCode);
        }
        return null;
    }


    public override Integer getQuestionOrderRank() {
        if (!this.stvQuestion.Incap311__Is_Required_Question__c && this.stvQuestion.Incap311__Order__c == null) {
            return 99;       
        }
        return stvQuestion.Incap311__Override_Order__c != null ? Integer.valueOf(stvQuestion.Incap311__Override_Order__c) : (stvQuestion.Incap311__Order__c != null ? Integer.valueOf(stvQuestion.Incap311__Order__c) : 1);
    }

    public override List<Incap311.Base311_QuestionAnswer> getActivePicklist(){
        return  Incap311.Base311_Dependencies.getActivePicklist(this.stvQuestion, qAMap);
    }
    
    public override string getQuestionCode(){
        return stvQuestion.Incap311__Question__r.Incap311__Flex_Question_Code__c;
    }

}