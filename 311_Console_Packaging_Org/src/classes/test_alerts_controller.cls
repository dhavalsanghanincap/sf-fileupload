public class test_alerts_controller {

    public Incap311__Service_Type_Version__c stv { 
        get {
            Incap311.Base311_Service_ServiceType bsst = new Incap311.Base311_Service_ServiceType();
            
            return bsst.getServiceType('SRTV-00000136');   
        }
    }
    
    public Map<String, Object> context {
        get {
            return new Map<String, Object>{
                'ST-SIZE' => 'Large'
            };
        }
    }

}