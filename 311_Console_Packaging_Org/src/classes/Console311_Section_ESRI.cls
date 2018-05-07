global class Console311_Section_ESRI {

    /*
     * A nasty hack because the Salesforce compiler is broken
     * re: maps in Visualforce. Take in an objcet (we assume its a map)
     * and then cast it to an actual map.
     * 
     * If the user makes a mistake, they'll know pretty quick
     */
    public Object intakeMap { get; set; }
    public Object mCustomBasemaps { get; set; }

    public Case activeCase { get; set; }
    
    public String getDefaultBasemap() {
        return Incap311.Base311_LocationSearch.getDefaultBasemap();
    }
    
    public String getSerializedCustomBasemaps() {
        System.debug('---> fetching basemaps ');
        System.debug(Incap311.Base311_LocationSearch.getRawCustomBasemaps());
        
        return Incap311.Base311_LocationSearch.getRawCustomBasemaps();
    }
    @RemoteAction
    global static void recordLocation(Incap311.Base311_Location loc, String reason) {
        Incap311__Reported_Location__c reportedLoc = new Incap311__Reported_Location__c(
        	Incap311__Location__Latitude__s = loc.lat,
            Incap311__Location__Longitude__s = loc.lng,
            Incap311__X_Position__c = loc.xCoord,
            Incap311__Y_Position__c = loc.yCoord,
            Incap311__Reason__c = reason
        );
        
        insert reportedLoc;
        
        
    }
    
    @RemoteAction
    global static List<Incap311.Base311_Location> reverseGeocode(Double lat, Double lng) {
        List<Incap311.Base311_Location> results = Incap311.Base311_LocationSearch.getLocationsByLatLng(lat, lng);
        List<Incap311.Base311_Location> finalResults = new List<Incap311.Base311_Location>();
        
        for(Incap311.Base311_Location bl : results) {
            if(bl.address != null && bl.lat != null && bl.lng != null) {
                finalResults.add(bl.addLayerInformation());
            }
        }
        
        return finalResults;
    }
    
    public List<Case> similarCases {
        get {
            if(activeCase == null) {
                return new List<Case>();
            }
            
            return [
                SELECT 
                    Incap311__Location__Latitude__s, 
                    Incap311__Location__Longitude__s, 
                    Description, 
                    Subject,
                    Incap311__Service_Request_Number__c
                FROM 
                    Case 
                WHERE 
                    Incap311__Service_Type_Version__c = :activeCase.Incap311__Service_Type_Version__c AND
                    Incap311__Location__Latitude__s != NULL AND 
                    CreatedDate = LAST_N_DAYS:14 AND
                    Id != :activeCase.Id
                LIMIT 10
            ];
        }
    }
    
    public List<Case> duplicateCases {
        get {
            if(activeCase == null || 
            activeCase.Incap311__Service_Type_Version__r == null || 
            activeCase.Incap311__Service_Type_Version__r.Name == null || 
            activeCase.Incap311__Location__Longitude__s == null || 
            activeCase.Incap311__Location__Latitude__s == null) {
                return new List<Case>();
            }
            
            return Incap311.Base311_DuplicateRequestsUtil.getDuplicateServiceRequests(
                '', 
                activeCase.Incap311__Service_Type_Version__r.Name, 
                String.valueOf(activeCase.Incap311__Location__Longitude__s),
                String.valueOf(activeCase.Incap311__Location__Latitude__s)
            );
        }
    }
    
    public Map<String, String> castedMap {
        get {
            return (Map<String, String>) intakeMap;
        }
    }
    
}