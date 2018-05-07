@isTest
private class Test_Console311_Section_ContactCtrl {
  
  @isTest static void testContactSectionController() {
    Console311_Section_ContactCtrl ctrl = new Console311_Section_ContactCtrl();
      
    Contact c = new Contact(FirstName = 'Testy', LastName = 'Test', Email = 'test@test.com');
    insert c;
	
      Incap311__Jurisdiction__c jurisdiction = new Incap311__Jurisdiction__c(Name = 'Baltimore', Incap311__City__c = 'Baltimore', Incap311__Jurisdiction_Id__c = 'Baltimore', Incap311__State__c = 'Baltimore', Incap311__State_Code__c = 'BA');
      insert jurisdiction;
      
    List<Incap311Console__Console_311_Layout_Setting__mdt> mConsoleLayoutConfig = [Select QualifiedApiName, Incap311Console__Visible__c, Incap311Console__Header__c, Incap311Console__Collapsible__c, Incap311Console__Title__c, MasterLabel, DeveloperName From Incap311Console__Console_311_Layout_Setting__mdt];
    List<Console311_Wrap_Config> cwcList = new List<Console311_Wrap_Config>();

    for (Incap311Console__Console_311_Layout_Setting__mdt config : mConsoleLayoutConfig) {
      cwcList.add(new Console311_Wrap_Config(config.DeveloperName, JSON.serialize(config), config.QualifiedApiName));
    }
      
    ctrl.mContactId = c.Id;
    ctrl = new Console311_Section_ContactCtrl();
      
    ctrl.feedContactInformationToPage(c.Id);
    ctrl.feedContactInformationToPage(c);
    System.assertEquals(51, ctrl.getStatesMap().size());
      
    Test.setCurrentPageReference(new PageReference('Page.Console311_Case')); 
    System.currentPageReference().getParameters().put('contactJson', '{"Id": "' + c.Id + '", "FirstName": "Testy", "LastName": "Test", "Email": "test@test.com"}');
    ctrl.feedContactInformationToPage();
    ctrl.getDefaultStateOnExisitingContact();

    ctrl.mContact = c;
    ctrl.getFieldNamesList();

    ctrl.getInformationLayoutConfig();
    ctrl.getNewEditLayoutConfig();

    ctrl.mLayoutConfig = cwcList;

    ctrl.getInformationLayoutConfig();
    ctrl.getNewEditLayoutConfig();
      ctrl.getNewEditFieldNamesList();
  }

  // TODO: These controllers should simply be mereged into one as we have duplicated data. 
  @isTest static void testAccountSectionController() {
    Console311_Section_AccountCtrl ctrl = new Console311_Section_AccountCtrl();
      
    Account acc = new Account(Name = 'Testy');
    insert acc;

    List<Incap311Console__Console_311_Layout_Setting__mdt> mConsoleLayoutConfig = [Select QualifiedApiName, Incap311Console__Visible__c, Incap311Console__Header__c, Incap311Console__Collapsible__c, Incap311Console__Title__c, MasterLabel, DeveloperName From Incap311Console__Console_311_Layout_Setting__mdt];
    List<Console311_Wrap_Config> cwcList = new List<Console311_Wrap_Config>();

    for (Incap311Console__Console_311_Layout_Setting__mdt config : mConsoleLayoutConfig) {
      cwcList.add(new Console311_Wrap_Config(config.DeveloperName, JSON.serialize(config), config.QualifiedApiName));
    }
      
    ctrl.mAccount = acc;
    ctrl.getFieldNamesList();

    ctrl.getInformationLayoutConfig();
    ctrl.getNewEditLayoutConfig();

    ctrl.mLayoutConfig = cwcList;

    ctrl.getInformationLayoutConfig();
    ctrl.getNewEditLayoutConfig();
  }

  @isTest static void testGenericSectionController() {
    Console_Section_ConfiguredLayoutCtrl ctrl = new Console_Section_ConfiguredLayoutCtrl();

    System.assertNotEquals(null, ctrl.getStatesMap());
    System.assertEquals(0, (ctrl.getFieldNamesList()).size());
    System.assertEquals(0, (ctrl.getNewEditFieldNamesList()).size());

    Account acc = new Account(Name = 'Testy');
    insert acc;

    ctrl.mObj = acc;
    ctrl.mObjName = 'Account';

    System.assert((ctrl.getFieldNamesList()).size() > 0);
    System.assert((ctrl.getNewEditFieldNamesList()).size() > 0);
    System.assertNotEquals(null, ctrl.getInformationLayoutConfig());
    System.assertNotEquals(null, ctrl.getNewEditLayoutConfig());
  }
}