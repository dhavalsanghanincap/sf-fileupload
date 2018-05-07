@isTest
public class Test_Console311_Section_DistCtrl {

	public static void testSetup() {
	    TestHelper.createData();
	  }
  
  @isTest static void testGetDistributionPicklist() {
    Test_Console311_Section_DistCtrl.testSetup();
    Console311_Section_DistributionCtrl ctrl = new Console311_Section_DistributionCtrl();

    Test.startTest();

    List<Incap311__Service_Type_Version__c> stvList = [
      SELECT 
        Id, 
        Name,
        Incap311__Include_System_Defaults_del__c
      FROM 
        Incap311__Service_Type_Version__c
      LIMIT 1
    ];  

    if (stvList != null && stvList.size() > 0) {
      ctrl.mStv =  stvList.get(0);
      List<SelectOption> soList = ctrl.getDistributionPicklist();
      System.assertEquals(1, soList.size());
    }
  }
  
  @isTest static void testRetrieveDistrubutionEmailList() {
    Test_Console311_Section_DistCtrl.testSetup();
  }

   @isTest static void testgetDistDescription() {
     	 Test_Console311_Section_DistCtrl.testSetup();
         Console311_Section_DistributionCtrl ctrl = new Console311_Section_DistributionCtrl();
         system.assertEquals('', ctrl.getDistDescription());
     }
  
}