@isTest
public class Test_Console311_Map_Extension {

    @isTest
    public static void testMapExtension(){
    
        // create a case record
        Case cse = new Case(Incap311__Location__latitude__s = 38.0, Incap311__Location__longitude__s=-79.9); 
            
        // create a new case standard controller by passing it the case record
        ApexPages.StandardController controller = new ApexPages.StandardController(cse);
    
        // now pass it to the extension
        Console311_Map_Extension mapExtension = new Console311_Map_Extension(controller);
    
        system.assert(mapExtension != null); // controller has successfully been created
        system.assert(mapExtension.mapCenterLatitude == 38.0);
        system.assert(mapExtension.mapCenterLongitude == -79.9);
        system.assert(mapExtension.serviceRequest.Incap311__Service_Request_Number__c == cse.Incap311__Service_Request_Number__c);
        system.assert(mapExtension.mapLayers != null);
    }
}