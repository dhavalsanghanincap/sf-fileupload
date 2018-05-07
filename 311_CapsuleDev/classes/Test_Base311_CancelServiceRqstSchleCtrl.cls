/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class Test_Base311_CancelServiceRqstSchleCtrl {

    static testMethod void testOnSave() {
        User u = Test_RestTestHelper.user();
        System.runAs(u){
        	Service_Type__c st = Test_RestTestHelper.serviceType();
            Service_Type_Version__c stv = Test_RestTestHelper.serviceTypeVersion(st.Id);
        	Case c = Test_RestTestHelper.serviceRequest(stv.Id);
        	
        	Schedule__c schedule = Test_RestTestHelper.schedule('',st.id,10,date.today());
        	
        	//Insert Incap311__Service_Request_Schedule__c
        	Incap311__Service_Request_Schedule__c serviceRequestScheduleRecord = new Incap311__Service_Request_Schedule__c(Incap311__Schedule__c = schedule.id,Incap311__Service_Request__c = c.id,Incap311__Number_Of_Items__c = 10);
        	insert serviceRequestScheduleRecord;
        	
        	PageReference pageRef = Page.Base311_CancelServiceRequestSchedule;
        	Test.setCurrentPage(pageRef);
        	serviceRequestScheduleRecord = [Select id,Incap311__Schedule__r.Name
        											,Incap311__Schedule__r.Incap311__Schedule_Date__c
        											,Incap311__Schedule__r.Incap311__Day_of_Week__c
        											,Incap311__Schedule__r.Incap311__Item_Count__c
        											,Incap311__Cancel_Reason__c
        											,Incap311__Is_Cancelled__c
        											,Incap311__Service_Request__r.CaseNumber
        											,Incap311__Service_Request__r.Subject
        									FROM Incap311__Service_Request_Schedule__c
        									WHERE id = :serviceRequestScheduleRecord.id];
        	ApexPages.StandardController sc = new ApexPages.StandardController(serviceRequestScheduleRecord);
        	Base311_CancelServiceRequestSchleCtrl controller = new Base311_CancelServiceRequestSchleCtrl(sc);
        	
        	serviceRequestScheduleRecord.Incap311__Cancel_Reason__c = 'This is test';
        	controller.onSave();
        	System.assert(serviceRequestScheduleRecord.Incap311__Is_Cancelled__c);								
        }
        
        
        
    }
    
    static testMethod void testOnSaveNegative() {
        User u = Test_RestTestHelper.user();
        System.runAs(u){
        	Service_Type__c st = Test_RestTestHelper.serviceType();
            Service_Type_Version__c stv = Test_RestTestHelper.serviceTypeVersion(st.Id);
        	Case c = Test_RestTestHelper.serviceRequest(stv.Id);
        	
        	Schedule__c schedule = Test_RestTestHelper.schedule('',st.id,10,date.today());
        	
        	//Insert Incap311__Service_Request_Schedule__c
        	Incap311__Service_Request_Schedule__c serviceRequestScheduleRecord = new Incap311__Service_Request_Schedule__c(Incap311__Schedule__c = schedule.id,Incap311__Service_Request__c = c.id,Incap311__Is_Cancelled__c= true);
        	insert serviceRequestScheduleRecord;
        	
        	PageReference pageRef = Page.Base311_CancelServiceRequestSchedule;
        	Test.setCurrentPage(pageRef);
        	serviceRequestScheduleRecord = [Select id,Incap311__Schedule__r.Name
        											,Incap311__Schedule__r.Incap311__Schedule_Date__c
        											,Incap311__Schedule__r.Incap311__Day_of_Week__c
        											,Incap311__Schedule__r.Incap311__Item_Count__c
        											,Incap311__Cancel_Reason__c
        											,Incap311__Is_Cancelled__c
        											,Incap311__Service_Request__r.CaseNumber
        											,Incap311__Service_Request__r.Subject
        									FROM Incap311__Service_Request_Schedule__c
        									WHERE id = :serviceRequestScheduleRecord.id];
        	ApexPages.StandardController sc = new ApexPages.StandardController(serviceRequestScheduleRecord);
        	Base311_CancelServiceRequestSchleCtrl controller = new Base311_CancelServiceRequestSchleCtrl(sc);
        	try{
        	serviceRequestScheduleRecord.Incap311__Cancel_Reason__c = 'This is test';
        	controller.onSave();
        	}catch(exception e){
        	Boolean expectedExceptionThrown =  e.getMessage().contains('The schedule is already cancelled') ? true : false;
        	System.assert(expectedExceptionThrown);
        	}								
        }
        
        
        
    }
}