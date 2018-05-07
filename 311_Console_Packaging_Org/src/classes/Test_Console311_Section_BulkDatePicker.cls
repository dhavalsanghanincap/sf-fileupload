@isTest
public class Test_Console311_Section_BulkDatePicker {
  
  @testSetup public static void testSetup() {
    TestHelper.createData();
  }

  @isTest public static void Test_Console311_Section_BulkDatePicker() {
    Console311_Section_BulkDatePicker ctrl = new Console311_Section_BulkDatePicker();

    List<Case> cList = [Select Id From Case Limit 1];

    List<Incap311__Service_Type_Version__c> sList = [Select Id,Incap311__Service_Name__c,Incap311__Service_Type__c,
                                                     Incap311__Version_Number__c, Incap311__Is_Draft__c, Incap311__Version_Code__c,
                                                     Incap311__Version_Name__c ,
                                                     Incap311__Service_Type__r.Id,
                                                     Incap311__Service_Type__r.Incap311__Schedulable_Requests_Limit_Month__c,
                                                     Incap311__Service_Type__r.Incap311__Schedule_Duplicate_Detection__c,
                                                     Incap311__Service_Type__r.Incap311__Schedulable_Requests_Limit_Year__c From Incap311__Service_Type_Version__c Limit 1];

    if (cList.size() > 0) {
      ctrl.stId = cList.get(0).Id;
      ctrl.zone = '07';
      ctrl.stSchAfterDays = 1;
      ctrl.mStv = sList[0];
        ctrl.mScheduleErrorMsg = '';
      ctrl.getBulkDateButtons();
    }


  }
}