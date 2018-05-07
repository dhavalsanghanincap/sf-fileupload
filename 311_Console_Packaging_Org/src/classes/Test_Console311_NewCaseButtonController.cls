@isTest
public class Test_Console311_NewCaseButtonController {
 
  static testMethod void testMoveOpenOnly() {
    Test.startTest();
    PageReference pref = Console311_NewCaseButtonController.redirect();
    pref = Console311_NewCaseButtonController.redirectConsole();
    System.assertEquals(pref.getUrl(),'/apex/Incap311Console__Console311_Case');
    Test.stopTest();
  }
}