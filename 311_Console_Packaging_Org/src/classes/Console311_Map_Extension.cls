public class Console311_Map_Extension {

    private final Case sr;
    
    public Case serviceRequest {
        get {
                Incap311.Base311_Service_Request bsr = new Incap311.Base311_Service_Request();
                return bsr.getServiceRequest(sr.Incap311__Service_Request_Number__c);
        }
    }

    public Map<String, String> mapLayers {
        get {
            List<String> layers = Incap311.Base311_LocationSearch.getArcGISLayers();

            if(layers.size() > 0) {
                return new Map<String, String>{
                    'Dynamic Layers' => layers[0]
                };
            }

            return new Map<String, String>{ };
        }
    }

    public Double mapCenterLongitude {
        get {
            return sr.Incap311__Location__longitude__s != null? sr.Incap311__Location__longitude__s : Incap311.Base311_LocationSearch.getMapCenterCoordinates().longitude;
        }
    }

    public Double mapCenterLatitude {
        get {
            return sr.Incap311__Location__latitude__s != null ? sr.Incap311__Location__latitude__s : Incap311.Base311_LocationSearch.getMapCenterCoordinates().latitude;
        }
    }
    
    public Console311_Map_Extension(ApexPages.StandardController stdController) {
    
        if(!test.isRunningTest())
        {
            stdController.addFields(new List<String>{'Incap311__Service_Request_Number__c','Incap311__Location__c','Incap311__Location__latitude__s','Incap311__Location__longitude__s' });       
        }
        this.sr = (Case)stdController.getRecord();

    }
}