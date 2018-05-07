public class ESRI_Component_Test_Extension {
    Incap311.Base311_Service_Request bsr = new Incap311.Base311_Service_Request();
    
    public Case getCase() {
        return bsr.getServiceRequest('00007403');
            
    }
    
    public Map<String, String> getArcgisLayers() {
        return new Map<String, String>{
            'Boston' => 'https://maps.cityofboston.gov/ArcGIS/rest/services/SAM/BOUNDARIES/MapServer'
        };     
    
    }
}