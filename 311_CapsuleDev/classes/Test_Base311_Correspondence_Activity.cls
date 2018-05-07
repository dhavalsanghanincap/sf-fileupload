@isTest
public class Test_Base311_Correspondence_Activity
{
    static testMethod void Test_validateMergeFields()
    {
        Base311_Correspondence_Activity corrActivity = new Base311_Correspondence_Activity();
        corrActivity.correspondence.intro__c = '{!Finish_Date__c}';
        corrActivity.validateMergeFields();
    }
    
    static testMethod void Test_validateMergeParentFields()
    {
        Base311_Correspondence_Activity corrActivity = new Base311_Correspondence_Activity();
        corrActivity.correspondence.intro__c = '{!Incap311__Service_request__r.subject}';
        corrActivity.validateMergeFields();
    }
    
    static testMethod void Test_Neg_validateMergeFields()
    {
        Base311_Correspondence_Activity corrActivity = new Base311_Correspondence_Activity();
        corrActivity.correspondence.intro__c = '{!asdfasdf}';
        boolean exceptionCaught = false;
        try{
        	corrActivity.validateMergeFields();
        }catch(exception e){
             exceptionCaught = true;
        }
        System.assert(exceptionCaught);
    }
    
    
    static testMethod void Test_init()
    {
        Activity_Correspondence__c ActivityCorrespondence = Test_RestTestHelper.ActivityCorrespondence();
        Base311_Correspondence_Activity ca = new Base311_Correspondence_Activity(ActivityCorrespondence);
        ca.getAdditionalFields();
        ca.getEventType();
    }
}