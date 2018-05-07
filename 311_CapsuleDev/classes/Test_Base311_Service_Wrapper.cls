@isTest
public class Test_Base311_Service_Wrapper {
 
    @isTest
    static void testSearchArticles() { 
        Base311_Service_Wrapper.handleRemote('Base311_Service_Knowledge', 'searchArticles', '["Bic"]');
    }
    
    @isTest
    static void testKnowledgeException() { 
        try {
        	Base311_Service_Wrapper.handleRemote('Base311_Service_Knowledge', 'notReal', '[]');
        } catch (Exception e) {}
    }
    
    @isTest
    static void testGetActiveServiceTypes() { 
        Base311_Service_Wrapper.handleRemote('Base311_Service_ServiceType', 'getActiveServiceTypes', '[true]');
    }
    
    @isTest
    static void testGetServiceType() { 
        Base311_Service_Wrapper.handleRemote('Base311_Service_ServiceType', 'getServiceType', '["abc", false]');
    }
    
    @isTest
    static void testGetServiceTypeByCode() { 
        Base311_Service_Wrapper.handleRemote('Base311_Service_ServiceType', 'getServiceTypeByCode', '["abc", false]');
    }
    
    @isTest
    static void testCreateServiceRequest() { 
        try {
        	Base311_Service_Wrapper.handleRemote('Base311_Service_Request', 'createServiceRequest', '[{}, {}, {}, {}]');
        } catch (Exception e) {}
    }
    
    @isTest
    static void testGetContactRequests() { 
        try {
        	Base311_Service_Wrapper.handleRemote('Base311_Service_Request', 'getContactRequests', '["213"]');
        } catch (Exception e) {}
    }
    
    @isTest
    static void testGetSimilarCases() { 
        try {
        	Base311_Service_Wrapper.handleRemote('Base311_Service_Request', 'getSimilarCases', '["213"]');
        } catch (Exception e) {}
    }
    
    @isTest
    static void testGetServiceRequest() { 
        try {
        	Base311_Service_Wrapper.handleRemote('Base311_Service_Request', 'getServiceRequest', '["213"]');
        } catch (Exception e) {}
    }
    
    @isTest
    static void testSearchServiceRequests() { 
        try {
        	Base311_Service_Wrapper.handleRemote('Base311_Service_Request', 'searchServiceRequests', '["213"]');
        } catch (Exception e) {}
    }
    
    @isTest
    static void testUpdateServiceRequest() { 
        try {
        	Base311_Service_Wrapper.handleRemote('Base311_Service_Request', 'updateServiceRequest', '[{}, {}, {}, {}, []]');
        } catch (Exception e) {}
    }
    
    @isTest
    static void testFailed() { 
        try {
        	Base311_Service_Wrapper.handleRemote('Base311_Service_Request', 'notReal', '[]');
        } catch (Exception e) {}
    }
    
    @isTest
    static void testServiceServiceTypeException() { 
        try {
        	Base311_Service_Wrapper.handleRemote('Base311_Service_ServiceType', 'notReal', '[]');
        } catch (Exception e)  {} 
    }
    
    @isTest
    static void testGetLocationsByAddress() { 
        try {
        	Base311_Service_Wrapper.handleRemote('Base311_LocationSearch', 'getLocationsByAddress', '["ABC"]');
        } catch (Exception e)  {} 
    }
    
    @isTest
    static void testGetLocationsByLatLng() { 
        try {
        	Base311_Service_Wrapper.handleRemote('Base311_LocationSearch', 'getLocationsByLatLng', '[12, 12]');
        } catch (Exception e)  {} 
    }
    
    @isTest
    static void testGetLocationsException() { 
        try {
        	Base311_Service_Wrapper.handleRemote('Base311_LocationSearch', 'notReal', '[]');
        } catch (Exception e)  {} 
    }
}