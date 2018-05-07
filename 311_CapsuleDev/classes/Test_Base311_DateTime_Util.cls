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
private class Test_Base311_DateTime_Util {

    static testMethod void testBusinessDays() {
        // use a start date that is a Monday (1/1/2007)
        DateTime sdt = DateTime.newInstance(2007, 1, 1);
        DateTime edt = Base311_DateTime_Util.getEndDate(sdt, 'business days', 3.0, false);
        System.assertEquals(4, edt.day());
        
        // use a start date this is a Friday (1/5/2007)
        sdt = DateTime.newInstance(2007, 1, 5);
        edt = Base311_DateTime_Util.getEndDate(sdt, 'business days', 3.0, false);
        System.assertEquals(10, edt.day());

        // test 0 days
        sdt = DateTime.newInstance(2007, 1, 1);
        edt = Base311_DateTime_Util.getEndDate(sdt, 'business days', 0.0, false);
        System.assertEquals(sdt.day(), edt.day());
        
        // test negative days
        sdt = DateTime.newInstance(2007, 1, 1);
        edt = Base311_DateTime_Util.getEndDate(sdt, 'business days', -2.0, false);
        System.assertEquals(null, edt);
    }
    
    static testMethod void testHolidays() {
    	Holiday testHoliday = new Holiday(Name='test holiday');
    	testHoliday.ActivityDate = Date.newInstance(2007, 1, 2);
    	insert testHoliday;
    	
    	// use a start date that is a Monday (1/1/2007)
        DateTime sdt = DateTime.newInstance(2007, 1, 1);
        DateTime edt = Base311_DateTime_Util.getEndDate(sdt, 'business days', 3.0, true);
        System.assertEquals(5, edt.day());
    }
    
    static testMethod void testCalendarDays() {
    	// use a start date that is the first of the a month (2/1/2007...Feb has 28 days in 2007)
    	DateTime sdt = DateTime.newInstance(2007, 2, 1);
        DateTime edt = Base311_DateTime_Util.getEndDate(sdt, 'calendar days', 30.0, false);
        System.assertEquals(edt.day(), 3);
    }
    
    static testMethod void testHours() {
    	// use a start time that is the noon
    	DateTime sdt = DateTime.newInstance(2007, 2, 1, 12, 0, 0);
        DateTime edt = Base311_DateTime_Util.getEndDate(sdt, 'hours', 19.0, false);
        System.assertEquals(7, edt.hour());
    }
    
    static testMethod void testNoCalcType() {
    	// use a start date that is a Monday (1/1/2007)
        DateTime sdt = DateTime.newInstance(2007, 1, 1);
        DateTime edt = Base311_DateTime_Util.getEndDate(sdt, '', 3.0, false);
        System.assertEquals(null, edt);
    }
    
    static testMethod void testElapsedSLACalendarDays() {
    	DateTime testEndDT = DateTime.now();
    	Date startDate = testEndDT.date();
    	DateTime testStartDT = DateTime.newInstance(startDate.addDays(-2), testEndDT.time());
    	Decimal elapsedHours = Base311_DateTime_Util.getElapsedSLA(testStartDT, testEndDT, 'calendar days');
    }
    
    static testMethod void testElapsedSLABusinessDays() {
    	DateTime testEndDT = DateTime.now();
    	Date startDate = testEndDT.date();
    	DateTime testStartDT = DateTime.newInstance(startDate.addDays(-7), testEndDT.time());
    	Decimal elapsedHours = Base311_DateTime_Util.getElapsedSLA(testStartDT, testEndDT, 'business days');
    }
    
    static testMethod void testVerifySLA() {
    	// setup service type and service type version
    	Service_Type__c st = Test_RestTestHelper.serviceType();
    	Service_Type_Version__c stv = Test_RestTestHelper.serviceTypeVersion(st.Id);
    	stv.SLA__c = 7;
    	stv.SLA_Type__c = 'Calendar Days';
    	stv.Start_Date__c = Date.today().addDays(30);
    	stv.Stop_Date__c = Date.today().addDays(210);
    	stv.Enable_Operational_SLA__c = true;
    	update stv;
    	
    	Test.startTest();
    	Case testCase = new Case();
    	testCase.Service_Type_Version__c = stv.Id;
    	testCase.Expected_Start_Date__c = DateTime.now();
    	testCase.Requested_Date_Time__c = DateTime.now();
    	testCase.Expected_Date_Time__c = DateTime.now();
    	testCase.Subject = 'testing';
    	insert testCase;
    	Test.stopTest();
    }
    
    static testMethod void testTransformDateTimeString() {
    	String testDateTime = '05/05/2025 18:22:51';
    	String testFormattedDate = Base311_DateTime_Util.transformDateTimeString(testDateTime);
    	System.assertEquals('2025-05-05 18:22:00', testFormattedDate);
    	
    }
    
    static testMethod void testRecalcSLAToHold() {
    	Service_Type__c st = Test_RestTestHelper.serviceType();
    	Service_Type_Version__c stv = Test_RestTestHelper.serviceTypeVersion(st.Id);
    	stv.SLA__c = 7;
    	stv.SLA_Type__c = 'Calendar Days';
    	stv.Start_Date__c = Date.today().addDays(-15);
    	stv.Stop_Date__c = Date.today().addDays(210);
    	stv.Enable_Operational_SLA__c = true;
    	update stv;
    	
    	
    	System.debug('>>>-----> inserting case with Status NEW...');
    	Case testCase = new Case();
    	testCase.Service_Type_Version__c = stv.Id;
    	testCase.Expected_Start_Date__c = DateTime.now();
    	testCase.Requested_Date_Time__c = DateTime.now();
    	testCase.Expected_Date_Time__c = DateTime.now();
    	testCase.Status = 'New';
    	testCase.Subject = 'testing';
    	insert testCase;
    	
    	Test.startTest();
    	
    	
    	System.debug('>>>-----> updating to HOLD...');
    	Case qCase = [SELECT Id, Subject, Status, Incap311__Expected_Date_Time__c, Incap311__Expected_Start_Date__c FROM Case WHERE Id = :testCase.Id];
    	qCase.Status = 'Hold';
    	update qCase;
    	
    	Test.stopTest();
    }
    
    static testMethod void testRecalcSLAFromHold() {
    	Service_Type__c st = Test_RestTestHelper.serviceType();
    	Service_Type_Version__c stv = Test_RestTestHelper.serviceTypeVersion(st.Id);
    	stv.SLA__c = 7;
    	stv.SLA_Type__c = 'Calendar Days';
    	stv.Start_Date__c = Date.today().addDays(-15);
    	stv.Stop_Date__c = Date.today().addDays(210);
    	stv.Enable_Operational_SLA__c = true;
    	update stv;
    	
    	
    	System.debug('>>>-----> inserting case with Status NEW...');
    	Case testCase = new Case();
    	testCase.Service_Type_Version__c = stv.Id;
    	testCase.Expected_Start_Date__c = DateTime.now();
    	testCase.Requested_Date_Time__c = DateTime.now();
    	testCase.Expected_Date_Time__c = DateTime.now();
    	testCase.Status = 'Hold';
    	testCase.Subject = 'testing';
    	insert testCase;
    	
    	Test.startTest();
    	
    	
    	System.debug('>>>-----> updating from HOLD...');
    	Case qCase = [SELECT Id, Subject, Status, Incap311__Expected_Date_Time__c, Incap311__Expected_Start_Date__c FROM Case WHERE Id = :testCase.Id];
    	qCase.Status = 'New';
    	update qCase;
    	
    	Test.stopTest();
    }
    
    static testMethod void testRecalcSLABulk() {
    	Service_Type__c st = Test_RestTestHelper.serviceType();
    	st.Incap311__Is_Bulk_Type__c = true;
    	update st;
    	
    	Service_Type_Version__c stv = Test_RestTestHelper.serviceTypeVersion(st.Id);
    	stv.SLA__c = 7;
    	stv.SLA_Type__c = 'Calendar Days';
    	stv.Start_Date__c = Date.today().addDays(-15);
    	stv.Stop_Date__c = Date.today().addDays(210);
    	stv.Enable_Operational_SLA__c = true;
    	update stv;
    	
    	Case testCase = new Case();
    	testCase.Service_Type_Version__c = stv.Id;
    	testCase.Expected_Start_Date__c = DateTime.now();
    	testCase.Requested_Date_Time__c = DateTime.now();
    	testCase.Expected_Date_Time__c = DateTime.now();
    	testCase.Auto_Close_Date__c = Date.today().addDays(4);
    	testCase.Status = 'New';
    	testCase.Subject = 'testing';
    	insert testCase;
    	
    	Test.startTest();
    	
    	Case qCase = [SELECT Id, Subject, Status FROM Case WHERE Id = :testCase.Id];
    	qCase.Status = 'In Progress';
    	update qCase;
    	
    	Test.stopTest();
    }
    
    static testMethod void testMethods() {
    	Base311_DateTime_Util dtu = new Base311_DateTime_Util();
    	dtu.dateTimeValue = DateTime.now();
    	String timezone = dtu.getTimeZoneValue();
    	System.assert(timezone != null);
    	dtu.isDST(DateTime.now());
    }
}