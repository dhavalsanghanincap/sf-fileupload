@isTest
private class Test_Base311_Batch_SRAutoClosure {
  
  @isTest static void testBase311BatchSRAutoClosure() {
    Test_Base311_MockLocation.setupMocks();

    
    Test.startTest();
      Contact con = new Contact(FirstName = 'Test', LastName = 'Test', Email = 'test@test.com');
      insert con;

      Service_Type__c st = Test_RestTestHelper.serviceType();
      st.Auto_Close__c = true;
      st.Auto_Close_Days__c = 0;
      update st;

      Service_Type_Version__c stv = Test_RestTestHelper.serviceTypeVersion(st.Id);
      
      Case c = Test_RestTestHelper.serviceRequest();
      c.ContactId = con.id;
      c.Service_Type_Version__c = stv.Id;
      c.Status = 'Open';
      update c;

    
      Base311_Batch_SRAutoClose_Schedulable srBatchSchedule = new Base311_Batch_SRAutoClose_Schedulable();
      srBatchSchedule.execute(null);

      Base311_Batch_SRAutoClosure srBatch = new Base311_Batch_SRAutoClosure();
      Date today = Date.today();
      List<Case> caseList = [Select Id, Status, Reason, Incap311__Service_Type_Version__c, Incap311__Auto_Close__c, Incap311__Auto_Close_Date__c From Case Where Status = 'Open' AND Incap311__Auto_Close__c = true AND Incap311__Auto_Close_Date__c = :today];
      Database.BatchableContext context;

      srBatch.execute(context, caseList);
    Test.stopTest();
  }
  
}