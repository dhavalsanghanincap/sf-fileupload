@isTest
public class Test_Console311_Section_CUF {
 
  @isTest static void Test_Console311_Section_CUF() {
    Console311_Section_ContactandUserField ctrl = new Console311_Section_ContactandUserField();
      
    Contact c = new Contact(FirstName = 'Testy', LastName = 'Test', Email = 'test@test.com');
    insert c;

    List<Incap311Console__Console_311_Layout_Setting__mdt> mConsoleLayoutConfig = [Select QualifiedApiName, Incap311Console__Visible__c, Incap311Console__Header__c, Incap311Console__Collapsible__c, Incap311Console__Title__c, MasterLabel, DeveloperName From Incap311Console__Console_311_Layout_Setting__mdt];
    List<Console311_Wrap_Config> cwcList = new List<Console311_Wrap_Config>();

    for (Incap311Console__Console_311_Layout_Setting__mdt config : mConsoleLayoutConfig) {
      cwcList.add(new Console311_Wrap_Config(config.DeveloperName, JSON.serialize(config), config.QualifiedApiName));
    }
      
    ctrl.mContactId = c.Id;
    ctrl = new Console311_Section_ContactandUserField();
      
    ctrl.feedContactInformationToPage(c.Id);
    ctrl.feedContactInformationToPage(c);
    System.assertEquals(51, ctrl.getStatesMap().size());
      
    Test.setCurrentPageReference(new PageReference('Page.Console311_Case')); 
    System.currentPageReference().getParameters().put('contactJson', '{"Id": "' + c.Id + '", "FirstName": "Testy", "LastName": "Test", "Email": "test@test.com"}');
    ctrl.feedContactInformationToPage();
    ctrl.getDefaultStateOnExisitingContact();

    ctrl.setmContact((Sobject)c);
    ctrl.getFieldNamesList();

    ctrl.getInformationLayoutConfig();
    ctrl.getNewEditLayoutConfig();

    ctrl.mLayoutConfig = cwcList;

    ctrl.getInformationLayoutConfig();
    ctrl.getNewEditLayoutConfig();
     // ctrl.getNewEditFieldNamesList();
  }

  
}