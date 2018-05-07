/**
* @author 
* @date 
* @group 
* @group-content
* @description 
*/
global class Base311_MailMerge
{

    private static final Pattern regex = Pattern.compile('\\{![^}]*\\}');
    private static final Pattern urlEncodeRegex = Pattern.compile('URLENCODE([^}]*)');


    private static final Case_Event_Setting__mdt createDefaultSetting = [SELECT Default_Correspondence_Code__c FROM Case_Event_Setting__mdt where MasterLabel = 'Service Request Create'][0];
    private static list<Correspondence__c> createDefaults = [select Incap311__Intro__c,Incap311__Body__c,Incap311__Closing__c from Correspondence__c where Incap311__Correspondence_Code__c = :createDefaultSetting.Default_Correspondence_Code__c  and Incap311__Correspondence_Code__c != null limit 1];
    private static final Case_Event_Setting__mdt closeDefaultSetting = [SELECT Default_Correspondence_Code__c FROM Case_Event_Setting__mdt where MasterLabel = 'Service Request Close' ][0];
    private static  list<Correspondence__c> closeDefaults = [select Incap311__Intro__c,Incap311__Body__c,Incap311__Closing__c from Correspondence__c where Incap311__Correspondence_Code__c = :closeDefaultSetting.Default_Correspondence_Code__c and Incap311__Correspondence_Code__c != null limit 1];


    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    private static String getIntro(Case serviceType, Boolean isCreate) {
        if(isCreate){
             return serviceType.Service_Type_Version__r.Rich_Email_Intro_Create__c == null && createDefaults.size() > 0 ? createDefaults[0].Intro__c :serviceType.Service_Type_Version__r.Rich_Email_Intro_Create__c;
        }else{
             return serviceType.Service_Type_Version__r.Rich_Email_Intro_Close__c == null && closeDefaults.size() > 0  ? closeDefaults[0].Intro__c : serviceType.Service_Type_Version__r.Rich_Email_Intro_Close__c ;
        }  
    }
    
    

    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    private static String getBody(Case serviceType, Boolean isCreate) {
        if(isCreate){
             return serviceType.Service_Type_Version__r.Rich_Email_Body_Create__c == null && createDefaults.size() > 0  ? createDefaults[0].Body__c : serviceType.Service_Type_Version__r.Rich_Email_Body_Create__c;
        }else{
             return serviceType.Service_Type_Version__r.Rich_Email_Body_Close__c == null && closeDefaults.size() > 0  ? closeDefaults[0].Body__c : serviceType.Service_Type_Version__r.Rich_Email_Body_Close__c;
        }  
    }

    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    private static String getClose(Case serviceType, Boolean isCreate) {
        if(isCreate){
             return serviceType.Service_Type_Version__r.Rich_Email_Closing_Create__c == null && createDefaults.size() > 0  ? createDefaults[0].Closing__c : serviceType.Service_Type_Version__r.Rich_Email_Closing_Create__c;
        }else{
             return serviceType.Service_Type_Version__r.Rich_Email_Closing_Close__c == null && closeDefaults.size() > 0  ? closeDefaults[0].Closing__c : serviceType.Service_Type_Version__r.Rich_Email_Closing_Close__c;
        }  
    }
    

    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global static String caseNotifyEmail(Case c, Boolean isCreate) {
        return caseNotifyEmail(c,c,isCreate);
    }

    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    public static String caseNotifyEmail(Case c,Case serviceType, Boolean isCreate) {
        String intro = Base311_MailMerge.replace(c, getIntro(serviceType, isCreate)) + '<br/><br/>';
        String body = Base311_MailMerge.replace(c, getBody(serviceType, isCreate)) + '<br/><br/>';
        String closing = Base311_MailMerge.replace(c, getClose(serviceType, isCreate));

        return (intro + body + closing);
    }

    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    public static Set<String> caseNotifyEmailFields(Case serviceType, Boolean isCreate) {
        Set<String> fields = new Set<String>();
        fields.addAll(Base311_MailMerge.getFieldNames(getIntro(serviceType, isCreate)));
        fields.addAll(Base311_MailMerge.getFieldNames(getBody(serviceType, isCreate)));
        fields.addAll(Base311_MailMerge.getFieldNames(getClose(serviceType, isCreate)));

        return fields;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
    }


    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    public static String replace(SObject c, String body){
        if(body == null) {
            return '';
        }

        Matcher regexMatcher = regex.matcher(body);
        list<VariableDetail> details = getVariablesDetails(body);
        for(VariableDetail detail : details){
            String replaceVal = determineReplaceValue(c, detail);
            // replace the existing string 
            body = body.replace(detail.dirtyVariable, replaceVal);
        }

        return body;
    }

    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    public static List<VariableDetail> getVariablesDetails(String body){
        Matcher regexMatcher = regex.matcher(body);
        list<VariableDetail> details = new list<VariableDetail>();
        while (regexMatcher.find()){
            // find the match group (anything between {! } inclusive)
            String dirtyVariable = regexMatcher.group();
            VariableDetail detail = new VariableDetail(dirtyVariable);
            details.add(detail);
        }
        return details;
    }

    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    public static List<String> getFieldNames(String body){
        List<String> fieldNames = new List<String>();

        if(body != null && body !=''){
            Matcher regexMatcher = regex.matcher(body);
            while (regexMatcher.find()){
                // find the match group (anything between {! } inclusive)
                String dirtyVariable = regexMatcher.group();
                VariableDetail detail = new VariableDetail(dirtyVariable);
                fieldNames.add(detail.fieldName);
            }
        }
        return fieldNames;
    }

    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    private static String determineReplaceValue(SObject c, VariableDetail detail) {
        if(detail.UrlEncoded) {
            return EncodingUtil.urlEncode(getFieldValue(c, detail.fieldName), 'UTF-8');
        }

        return getFieldValue(c, detail.fieldName);
    }

    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    private static String getFieldValue(SObject c, String fieldName) {
        try{
            if(c == null) {
                return '';
            }

            List<String> parts = fieldName.split('\\.');

            if(parts.size() == 1) {
                Object res = c.get(parts[0]);
                return res == null ? '' : Base311_Helper.friendlyFormat(res);
            }

            String objName = parts[0];

            parts.remove(0);

            return getFieldValue(c.getSObject(objName), String.join(parts, '.'));
        }catch(Exception e){
            return fieldName; 
        }

    }

    private class VariableDetail{
        String dirtyVariable;
        String fieldName;
        boolean uRLEncoded;

        public VariableDetail(String dirtyVariable){
            this.dirtyVariable = dirtyVariable;
            String variable = dirtyVariable.substring(2,dirtyVariable.length() - 1).trim();
            uRLEncoded =  isUrlEncoded(variable);
            fieldName = determineFieldName(variable);
        }

        private boolean isUrlEncoded(String variable){
            Matcher urlEncodedMatcher = urlEncodeRegex.matcher(variable);
            return urlEncodedMatcher.find();
        }

        private String determineFieldName(String variable) {
            Matcher urlEncodedMatcher = urlEncodeRegex.matcher(variable);
            if(isUrlEncoded(variable)) {
                String encodedGroup = urlEncodedMatcher.group().replace('URLENCODE', '');
                variable = encodedGroup.substring(1, encodedGroup.length() - 1).trim();
            }
            variable = variable.remove('Incap311__');

            return variable;
        }
    }


}