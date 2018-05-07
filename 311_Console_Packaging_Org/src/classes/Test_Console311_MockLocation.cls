@isTest
global class Test_Console311_MockLocation { 
    
    
    @isTest public static void  setupMocks() {
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource('http://test.com/addressId', 'MockIdSearch');
        multimock.setStaticResource('http://test.com/addressLatLng', 'MockLatLngSearch');
        multimock.setStaticResource('http://test.com/address/123', 'MockAddressSearch');
        multimock.setStaticResource('http://test.com/layers', 'MockAddressSearch');
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, multimock);
    }
    
}