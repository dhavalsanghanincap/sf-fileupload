@isTest
public class Test_Base311_LocationSearch {

    @isTest
    static void testGetLocationById() {
        Test_Base311_MockLocation.setupMocks();
        Test.startTest();
        Base311_Location loc = Base311_LocationSearch.getLocationById('1');
        Test.stopTest();
        System.assertEquals(loc.addressId, '243310.0');
    }

    @isTest
    static void testGetLocationByAddress() {
        Test_Base311_MockLocation.setupMocks();
        Test.startTest();
        List<Base311_Location> loc = Base311_LocationSearch.getLocationsByAddress('123');
        Test.stopTest();
        System.assertEquals(loc.size(), 3);
    }

    @isTest
    static void testGetLocationByLatLng() {
        Test_Base311_MockLocation.setupMocks();
        Test.startTest();
        List<Base311_Location> loc = Base311_LocationSearch.getLocationsByLatLng(10, 10);
        Test.stopTest();
        System.assertEquals(loc.size(), 5);
    }
    
}