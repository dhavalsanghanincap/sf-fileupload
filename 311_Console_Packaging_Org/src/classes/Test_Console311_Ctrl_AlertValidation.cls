@istest
public class Test_Console311_Ctrl_AlertValidation {

	public static void testSetup() {
	    TestHelper.createData();
	  }
	 @isTest static void testgetInlineValidationMessage() {
         Test_Console311_Ctrl_AlertValidation.testSetup();

         Console311_Controller_AlertValidation ctrl = new Console311_Controller_AlertValidation();
         system.assertEquals(0, ctrl.getInlineValidationMessage().size());
        
         //List<Incap311__Service_Type__c> stlist = [SELECT Id, Incap311__Active_Service_Type_Version__c FROM Incap311__Service_Type__c WHERE Incap311__Service_Type_Code__c='BULKCOLL' LIMIT 1];
         //List<Incap311__Service_Type_Version__c> stvlist = [SELECT Id, Incap311__Validations__c, Incap311__Alert_Validations__c FROM Incap311__Service_Type_Version__c WHERE Id=:stlist.get(0).Incap311__Active_Service_Type_Version__c LIMIT 1];
         //ctrl.mServiceTypeVersion = stvlist.get(0);
         //system.assertEquals('Validation for question 789', ctrl.getInlineValidationMessage());
     }
    
    @isTest static void testgetAlertValidationMessage() {
     	 Test_Console311_Ctrl_AlertValidation.testSetup();
         Console311_Controller_AlertValidation ctrl = new Console311_Controller_AlertValidation();
         system.assertEquals(null, ctrl.getAlertValidationMessage());
     }

     @isTest static void testgetGeoValidationMessage() {
     	 Test_Console311_Ctrl_AlertValidation.testSetup();
         Console311_Controller_AlertValidation ctrl = new Console311_Controller_AlertValidation();
         system.assertEquals(0, ctrl.getGeoValidationMessage().size());
     }
}