@isTest
public class Test_Base311_Activity_Correspondence_Ext {
	@isTest
    public static void testExt(){
        Activity_Correspondence__c ActivityCorrespondence = Test_RestTestHelper.ActivityCorrespondence();
        insert ActivityCorrespondence;
        ApexPages.currentPage().getParameters().put('id',ActivityCorrespondence.id);
		ApexPages.StandardController stdcontroller = new ApexPages.StandardController(ActivityCorrespondence);
	    Base311_Activity_Correspondence_Ext controllerExt  = new Base311_Activity_Correspondence_Ext(stdcontroller);
        controllerExt.save();
    }
}