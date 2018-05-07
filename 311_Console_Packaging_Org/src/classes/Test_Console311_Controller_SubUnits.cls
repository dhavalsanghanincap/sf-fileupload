@isTest
private class Test_Console311_Controller_SubUnits {

  @isTest static void testControllerSubUnits() {
    Console311_Controller_SubUnits ctrl = new Console311_Controller_SubUnits();
    Double lat = 45.4220856;
    Double lng = -75.7005243;
    Incap311.Base311_Location loc = new Incap311.Base311_Location(lat, lng, null, 'Wellington St, Ottawa');
    
    ctrl.selectedLocation = loc;
    ctrl.getSubUnits();
    ctrl.getEncodedSubunits();
    Console311_Controller_SubUnits.SortedSubLocation sortedClass = new Console311_Controller_SubUnits.SortedSubLocation(loc);
    Console311_Controller_SubUnits.SortedSubLocation sortedClass2 = new Console311_Controller_SubUnits.SortedSubLocation(loc);
    System.assertEquals(sortedClass.compareTo(sortedClass2),0);
  }
    
    @isTest static void testControllerSubUnits2() {
    Console311_Controller_SubUnits ctrl = new Console311_Controller_SubUnits();
    Double lat = 45.4220856;
    Double lng = -75.7005243;
    Incap311.Base311_Location loc = new Incap311.Base311_Location(lat, lng, null, 'Wellington St, Ottawa');
        
    Double lat2 = -45.4220856;
    Double lng2 = 75.7005243;
    Incap311.Base311_Location loc2 = new Incap311.Base311_Location(lat2, lng2, null, 'Poorlyton St, Not Ottawa');
    
    ctrl.selectedLocation = loc;
    ctrl.getSubUnits();
    ctrl.getEncodedSubunits();
    Console311_Controller_SubUnits.SortedSubLocation sortedClass = new Console311_Controller_SubUnits.SortedSubLocation(loc);
    Console311_Controller_SubUnits.SortedSubLocation sortedClass2 = new Console311_Controller_SubUnits.SortedSubLocation(loc2);
    System.assertEquals(sortedClass.compareTo(sortedClass2),1);
  }
    
  @isTest static void testControllerSubUnits3() {
    Console311_Controller_SubUnits ctrl = new Console311_Controller_SubUnits();
    Double lat = 45.4220856;
    Double lng = -75.7005243;
    Incap311.Base311_Location loc = new Incap311.Base311_Location(lat, lng, null, 'Wellington St, Ottawa');
        
    Double lat2 = -45.4220856;
    Double lng2 = 75.7005243;
    Incap311.Base311_Location loc2 = new Incap311.Base311_Location(lat2, lng2, null, 'Poorlyton St, Not Ottawa');
    
    ctrl.selectedLocation = loc;
    ctrl.getSubUnits();
    ctrl.getEncodedSubunits();
    Console311_Controller_SubUnits.SortedSubLocation sortedClass = new Console311_Controller_SubUnits.SortedSubLocation(loc);
    Console311_Controller_SubUnits.SortedSubLocation sortedClass2 = new Console311_Controller_SubUnits.SortedSubLocation(loc2);
    System.assertEquals(sortedClass2.compareTo(sortedClass),-1);
  }
    
    
  
}