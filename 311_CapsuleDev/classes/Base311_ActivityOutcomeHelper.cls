/**
* @author   David Evans
* @date  6/9/2017
* @group 
* @group-content
* @description 
*/
/*
 * Block comments with details of changes
 */
public class Base311_ActivityOutcomeHelper
{
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
  /*  public static void checkMailMergeFields(List<Activity_Outcome__c> stVersions){
        for(Activity_Outcome__c stv : stVersions) {
            String Error = checkMailMergeFields(stv,Base311_MailMerge.getFieldNames(stv.Rich_Email_Intro_Close__c));
            if(Error != null){
                 stv.Rich_Email_Intro_Close__c.addError(error);
            }
            Error =  checkMailMergeFields(stv,Base311_MailMerge.getFieldNames(stv.Rich_Email_Body_Close__c));
            if(Error != null){
                stv.Rich_Email_Body_Close__c.addError(Error);
            }
            Error =  checkMailMergeFields(stv,Base311_MailMerge.getFieldNames(stv.Rich_Email_Closing_Close__c));
            if(Error != null){
                stv.Rich_Email_Closing_Close__c.addError(Error);
           }
        }
    }*/

    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
   /* public static String checkMailMergeFields(Service_Type_Version_Activity__c stv, List<String> fields){
        for(String field : fields) {
            System.debug('Does '+field+' exist '+Base311_Schema.doesFieldExist('Service_Activity__c',field));
            try{
                if(!Base311_Schema.doesFieldExist('Case',field)){
                    return 'Merge field '+Field+' cannot be found on the Activity object';
                }
            }catch(Exception e){
                return 'Merge field '+Field+' cannot be found on the Activity object';
            }
        }
        return null;
    }*/
}