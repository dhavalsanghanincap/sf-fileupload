@isTest
private class Test_Console311_ComponentControllerBase {
    
  @isTest static void testComponentControllerBase() {
    Console311_ComponentControllerBase ctrl = new Console311_ComponentControllerBase();
    Console311_CaseController ctrlBase = new Console311_CaseController();

    ctrl.pageController = ctrlBase;
    System.assertNotEquals(null, ctrlBase.getComponentController());

    ctrl.key = 'Test1';
    Map<String, Console311_ComponentControllerBase> componentBaseMapping = ctrlBase.getComponentControllerMap();
    System.assertEquals(componentBaseMapping.size(), 1);
    System.assert(componentBaseMapping.containsKey('Test1'));
  }
  
}