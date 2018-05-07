@isTest
private class Test_Base311_Service_Bulk {
  
  @isTest static void testGetNextAvailableScheduledDates() {
    Service_Type__c st = Test_RestTestHelper.serviceType();

    Schedule__c s = Test_RestTestHelper.schedule('21', st.Id);

    Base311_Service_Bulk bsb = new Base311_Service_Bulk();

    List<Schedule__c> sList = bsb.getNextAvailableScheduledDates(st.Id, '21');
    System.assertEquals(1, sList.size());

    Test_RestTestHelper.schedule('21', st.Id);
    sList = bsb.getNextAvailableScheduledDates(st.Id, '21', 1);
    System.assertEquals(1, sList.size());    

    sList = bsb.getNextAvailableScheduledDates(st.Id);
    System.assertEquals(0, sList.size());    
      
    sList = bsb.getNextAvailableScheduledDates(st.Id, '21', 1, false, s.Day_of_Week__c);
    System.assertEquals(1, sList.size());
      
    sList  = bsb.getNextAvailableScheduledDates(st.Id, 1, false);
    System.assertEquals(1, sList.size());
  }
  
  @isTest static void testCreateServiceRequestSchedule() {
    Service_Type__c st = Test_RestTestHelper.serviceType();

    Schedule__c s = Test_RestTestHelper.schedule('21', st.Id);
    Case c = Test_RestTestHelper.serviceRequest();

    Base311_Service_Bulk bsb = new Base311_Service_Bulk();
    System.assertNotEquals(null, bsb.createServiceRequestSchedule(s, c, 0));
  }

  @isTest static void testUpdateScheduleCount() {
    Service_Type__c st = Test_RestTestHelper.serviceType();
    Schedule__c s = Test_RestTestHelper.schedule('21', st.Id);

    Base311_Service_Bulk bsb = new Base311_Service_Bulk();
    s = bsb.updateScheduleCount(s, 1);
    System.assertEquals(11, s.Item_Count__c); 
  }

  @isTest static void testVerifyDuplicateScheduleByLocation() {
    Service_Type__c st = Test_RestTestHelper.serviceType();
    Service_Type_Version__c stv = Test_RestTestHelper.serviceTypeVersion(st.Id);
    Schedule__c s = Test_RestTestHelper.schedule('21', st.Id);

    Base311_Service_Bulk bsb = new Base311_Service_Bulk();
    System.assertEquals(true, bsb.verifyDuplicateScheduleByLocation(stv, 0.0, 0.0));

    st.Schedule_Duplicate_Detection__c = true;
    update st;

    stv = [
      SELECT 
        Id, Name, Service_Name__c, Service_Type__c, Service_Type__r.External_Description__c, 
        Keywords__c, Group__c, Has_Metadata__c, Resolution_Type__c, Allow_Citizen_Web_Intake__c, 
        Is_Draft__c, SLA_Type__c, Is_Activatable__c, Service_Type__r.Service_Type_Code__c,
        Enable_Business_Hours__c, Service_Type__r.Schedule_Duplicate_Detection__c
      FROM 
        Service_Type_Version__c 
      WHERE 
        Id = :stv.Id
    ];
  
    System.assertEquals(true, bsb.verifyDuplicateScheduleByLocation(stv, 0.0, 0.0));    
  }

    
    @isTest static void testVerifyLimitsReachedByLocationIndividually() {
    Service_Type__c st = Test_RestTestHelper.serviceType();
    Service_Type_Version__c stv = Test_RestTestHelper.serviceTypeVersion(st.Id);
    Schedule__c s = Test_RestTestHelper.schedule('21', st.Id);

    stv = [
      SELECT 
        Id, Name, Service_Name__c, Service_Type__c, Service_Type__r.External_Description__c, 
        Keywords__c, Group__c, Has_Metadata__c, Resolution_Type__c, Allow_Citizen_Web_Intake__c, 
        Is_Draft__c, SLA_Type__c, Is_Activatable__c, Service_Type__r.Service_Type_Code__c,
        Enable_Business_Hours__c, Service_Type__r.Schedule_Duplicate_Detection__c, 
        Service_Type__r.Incap311__Schedulable_Requests_Limit_Month__c, Service_Type__r.Incap311__Schedulable_Requests_Limit_Year__c
      FROM 
        Service_Type_Version__c 
      WHERE 
        Id = :stv.Id
    ];

    Base311_Service_Bulk bsb = new Base311_Service_Bulk();
    Map<String, Boolean> results = bsb.verifyLimitsReachedByLocationIndividually(stv, 0.0, 0.0);
    System.assertEquals(false, results.get('month'));
    System.assertEquals(false, results.get('year'));

    st.Incap311__Schedulable_Requests_Limit_Month__c = 1;
    st.Incap311__Schedulable_Requests_Limit_Year__c = 1;
    update st;

    stv = [
      SELECT 
        Id, Name, Service_Name__c, Service_Type__c, Service_Type__r.External_Description__c, 
        Keywords__c, Group__c, Has_Metadata__c, Resolution_Type__c, Allow_Citizen_Web_Intake__c, 
        Is_Draft__c, SLA_Type__c, Is_Activatable__c, Service_Type__r.Service_Type_Code__c,
        Enable_Business_Hours__c, Service_Type__r.Schedule_Duplicate_Detection__c, 
        Service_Type__r.Incap311__Schedulable_Requests_Limit_Month__c, Service_Type__r.Incap311__Schedulable_Requests_Limit_Year__c
      FROM 
        Service_Type_Version__c 
      WHERE 
        Id = :stv.Id
    ];

    results = bsb.verifyLimitsReachedByLocationIndividually(stv, 0.0, 0.0);
    System.assertEquals(false, results.get('month'));
    System.assertEquals(false, results.get('year'));
  }
}