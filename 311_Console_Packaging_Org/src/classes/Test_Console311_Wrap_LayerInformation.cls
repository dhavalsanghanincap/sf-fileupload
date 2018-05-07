@isTest
private class Test_Console311_Wrap_LayerInformation {
  
  @isTest static void testController() {
    Console311_Wrap_LayerInformation wl = new Console311_Wrap_LayerInformation();
    
    System.assertEquals(wl.layer_name, null);
    System.assertEquals(wl.layer_value, null);
    System.assertEquals(wl.layer_title, null);
    System.assertEquals(wl.format, null);
  
    wl = new Console311_Wrap_LayerInformation('testName', 'testvalue');

    System.assertEquals(wl.layer_name, 'testName');
    System.assertEquals(wl.layer_value, 'testvalue');
    System.assertEquals(wl.layer_title, null);
    System.assertEquals(wl.format, null);
    
    wl = new Console311_Wrap_LayerInformation('name2', 'value2', 'a title');

    System.assertEquals(wl.layer_name, 'name2');
    System.assertEquals(wl.layer_value, 'value2');
    System.assertEquals(wl.layer_title, 'a title');
    System.assertEquals(wl.format, null);
    
    wl = new Console311_Wrap_LayerInformation('name3', 'value3', 'a title3', 'a format');

    System.assertEquals(wl.layer_name, 'name3');
    System.assertEquals(wl.layer_value, 'value3');
    System.assertEquals(wl.layer_title, 'a title3');
    System.assertEquals(wl.format, 'a format');
  }
}