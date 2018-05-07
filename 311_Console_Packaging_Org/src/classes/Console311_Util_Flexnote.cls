public with sharing class Console311_Util_Flexnote {
  public Console311_Util_Flexnote() {}

  public static List<Console311_Wrap_FlexnoteQuestionAnswer> fetchWithUpdates(String serviceCode, Map<String, Object> answerMap, List<Console311_Wrap_FlexnoteQuestionAnswer> quesWrapList) {
    System.debug('----> [FlexnoteUtil] fetchWithUpdates => Begin');
    Incap311.Base311_Service_ServiceType rss = new Incap311.Base311_Service_ServiceType();
    Incap311.Base311_Dependencies rd = new Incap311.Base311_Dependencies();

    List<Console311_Wrap_FlexnoteQuestionAnswer> mFNQuestionAnswerList = quesWrapList;
    List<Console311_Wrap_FlexnoteQuestionAnswer> mFNQuestionAnswerListBackup = new List<Console311_Wrap_FlexnoteQuestionAnswer>();

    try {
        // Make a backup of the current answers list.
        mFNQuestionAnswerListBackup = mFNQuestionAnswerList;
        // Get the STV to send with the answers to Core.
        Incap311__Service_Type_Version__c stv = rss.getServiceType(serviceCode, true);
        System.debug('---> [FlexnoteUtil] STV: ' + stv);
        // Get an updated list of the questions with the answers pre-mapped.
        List<Incap311__Service_Type_Version_Question__c> qs = rd.getActiveQuestions(stv, answerMap);

        if (qs != null && qs.size() > 0) {
            // Reset the current answer list.
            mFNQuestionAnswerList = new List<Console311_Wrap_FlexnoteQuestionAnswer>();
            // Generate a new one using the new values.
            for (Incap311__Service_Type_Version_Question__c vQuestion : qs) {
                System.debug('----> [FlexnoteUtil] qs: ' + qs);
                Console311_Wrap_FlexnoteQuestionAnswer fnqaw = new Console311_Wrap_FlexnoteQuestionAnswer(vQuestion,answerMap);   
                // Take the answer map and map the answers BACK into the questions.
                if (!vQuestion.Incap311__Is_Dependent__c && answerMap.containsKey(fnqaw.stvQuestion.Incap311__Question__r.Incap311__Flex_Question_Code__c) ) {
                    if(fnqaw.validatePicklistOption(String.valueOf(answerMap.get(fnqaw.stvQuestion.Incap311__Question__r.Incap311__Flex_Question_Code__c)))){
                        fnqaw.sq.Incap311__Answer__c = String.valueOf(answerMap.get(fnqaw.stvQuestion.Incap311__Question__r.Incap311__Flex_Question_Code__c));
                    }
                }else{
                    fnqaw.sq.Incap311__Answer__c = '';
                }
                mFNQuestionAnswerList.add(fnqaw);
            }
        }
    } catch (Exception e) {
        System.debug('----> [FlexnoteUtil] Error: ' + e.getMessage());
        System.debug(e.getStackTraceString());

        System.debug('----> [FlexnoteUtil] Resetting values back to last backup copy...');
        mFNQuestionAnswerList = mFNQuestionAnswerListBackup;
    }
    System.debug('[FlexnoteUtil] flexnotes ' + mFNQuestionAnswerList);
    System.debug('----> [FlexnoteUtil] fetchWithUpdates => End ');
    return mFNQuestionAnswerList;
  }

  public Map<String, Object> convertFlexnoteAnswersToMap(List<ServiceQuestionWrapper> sqWrapList, Boolean convertCheckboxes) {
    Map<String, Object> flexnoteSaveMapping = new Map<String, Object>();
    // Loop through all the service questions and generate the flexnote mappings. 
    for (ServiceQuestionWrapper sqw : sqWrapList) {     
      Object tempObj = sqw.question.Incap311__Answer__c;
      System.debug('----> Question Answer: ' + tempObj);
      // If the answer has commas then we know it's a multi picklist. 
      if(sqw.question.Incap311__Answer__c != null){
        System.debug('----> sqw.mDataType: ' + sqw.mDataType);
        if (String.isNotBlank(sqw.mDataType) && sqw.mDataType.equalsIgnoreCase('MultiPicklist') && sqw.question.Incap311__Answer__c.contains(',')) {
          tempObj = sqw.question.Incap311__Answer__c.split(',');
        }

        if (convertCheckboxes && String.isNotBlank(sqw.mDataType) && sqw.mDataType.equalsIgnoreCase('Boolean (checkbox)')) {
          if (tempObj == true || tempObj == false || tempObj == 'true' || tempObj == 'false') {
            tempObj = tempObj;
            System.debug('----> Checkbox was indeed already a boolean.');
          } else {
            System.debug('----> Checkbox was not set as a Boolean. Correcting...');
            tempObj = ((String) tempObj).equalsIgnoreCase('on') ? true : false;
          }
        }

        if (String.isNotBlank(sqw.mDataType) && sqw.mDataType.equalsIgnoreCase('Date')) {
          System.debug('----> Date Answer: ' + sqw.question.Incap311__Answer__c);
          //Date tempD = Date.parse(sqw.question.Incap311__Answer__c);
        }

        if (String.isNotBlank(sqw.mDataType) && sqw.mDataType.equalsIgnoreCase('Date/Time')) {
          System.debug('----> Datetime BEFORE conversion: ' + sqw.question.Incap311__Answer__c);
          //Datetime tempD = Datetime.parse(sqw.question.Incap311__Answer__c);
          tempObj = Incap311.Base311_Helper.convert12HourTo24Hour(sqw.question.Incap311__Answer__c);
          System.debug('----> Datetime AFTER conversion: ' + tempObj);
        }

        flexnoteSaveMapping.put(sqw.mSRTypeVQuestionName, tempObj);
      }
    }
    System.debug('----> Flexnote mapping created. Processing...');
    System.debug('----> flexnoteSaveMapping: ' + flexnoteSaveMapping);
    return flexnoteSaveMapping;
  }

  public class ServiceQuestionWrapper {
    public String mSRTypeVQuestionName { get; set; }
    public String mDataType { get; set; }
    public Incap311__Service_Question__c question { get; set; }

    public ServiceQuestionWrapper() {}
  }
}