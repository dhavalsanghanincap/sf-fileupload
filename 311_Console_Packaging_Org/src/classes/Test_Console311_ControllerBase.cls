@isTest
private class Test_Console311_ControllerBase {

  @isTest static void testControllerBase() {
    Console311_ControllerBase ctrl = new Console311_ControllerBase();
    Console311_ComponentControllerBase comCtrl = new Console311_ComponentControllerBase();

    ctrl.setComponentController(comCtrl);
    System.assertNotEquals(null, ctrl.getComponentController());

    ctrl.setComponentControllerMap('ctrl1', comCtrl);
    Map<String, Console311_ComponentControllerBase> comMap = ctrl.getComponentControllerMap();
    System.assertEquals(comMap.size(), 1);

    ctrl.setComponentControllerMap('ctrl2', comCtrl);
    comMap = ctrl.getComponentControllerMap();
    System.assertEquals(comMap.size(), 2);
  }
  
}