/**
* @author 
* @date 
* @group 
* @group-content
* @description 
*/
global class Base311_LocationSearch { 
            
    private enum LocationFetchType {
        ById, ByLatLng, ByAddress, Layers, SubUnits
    }
    
    private static Location_Endpoint__mdt mActiveConfig;
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global static Location_Endpoint__mdt activeConfig { 
        get {
        
            if(Test.isRunningTest()) {
                StaticResource sr = [
                    SELECT Id, Body FROM StaticResource WHERE Name = 'MockLocationEndpoint' LIMIT 1
                ];    

                return (Location_Endpoint__mdt) JSON.deserialize(sr.Body.toString(), Location_Endpoint__mdt.class);
            }
        
            if(mActiveConfig == null) {
                List<Location_Endpoint__mdt> configs = [ 
                    SELECT 
                        Base_URL__c, By_Address_Endpoint__c, By_Id_Endpoint__c, By_Lat_Lng_Endpoint__c,
                        Address_Id_Mapping__c, Address_Mapping__c, By_Address_Path__c, By_Id_Path__c,
                        By_Lat_Lng_Path__c, Default_Path__c, Latitude_Mapping__c, Longitude_Mapping__c,
                        Neighbourhood_Mapping__c, Parcel_Mapping__c, Precinct_Ward_Mapping__c, 
                        Street_Id_Mapping__c, Unit_Mapping__c, Ward_Mapping__c, X_Coord_Mapping__c, 
                        Y_Coord_Mapping__c, Zip_Code_Mapping__c, Layers_Endpoint__c, ArcGIS_Dynamic_Layer_URL__c,
                        Map_Center_Latitude__c, Map_Center_Longitude__c, Default_Map_Zoom__c, Sub_Unit_Where_Fields__c,
                        By_Sub_Units_Path__c, Sub_Address_Endpoint__c, Sub_Address_Id_Mapping__c, Custom_Basemaps__c,
                        Default_Basemap__c
                    FROM 
                        Location_Endpoint__mdt
                    WHERE
                        Is_Active__c = true
                    LIMIT 1
                ];
                
                if(configs.size() > 0) { 
                    mActiveConfig = configs[0];
                } else {                
                    throw new Base311_Exceptions.UnsupportedException('Location configuration has not been defined');
                }
            }
            return mActiveConfig;
        }
    }

    
    private static List<Location_Endpoint_Filtering__mdt> mFilters  = [
        SELECT Field_Name__c, Field_Values__c
        FROM Location_Endpoint_Filtering__mdt
        WHERE Location_Endpoint__c = :activeConfig.Id
    ];
    
    global static String getDefaultBasemap() {
        return String.isEmpty(activeConfig.Default_Basemap__c) ? 'streets' : activeConfig.Default_Basemap__c;
    }
    
    global static String getRawCustomBasemaps() {
        return activeConfig.Custom_Basemaps__c;
    }

    global static Map<String, Base311_Location_Basemap> getCustomBasemaps() {
        if(String.isEmpty(activeConfig.Custom_Basemaps__c)) {
            return new Map<String, Base311_Location_Basemap>();
        }
        
        return (Map<String, Base311_Location_Basemap>) JSON.deserialize(activeConfig.Custom_Basemaps__c, Map<String, Base311_Location_Basemap>.class);
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global static List<X311_ESRI_Layer_Mapping__mdt> getActiveLayerMappings() { 
        return [
            SELECT Field_Name__c, Layer_Id__c, Layer_Value__c
            FROM X311_ESRI_Layer_Mapping__mdt
            WHERE Location_Endpoint__c = :activeConfig.Id
        ];
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global static List<String> getArcGISLayers() {
        if(activeConfig.ArcGIS_Dynamic_Layer_URL__c == null) {
            return new List<String>();
        }
    
        List<String> items = activeConfig.ArcGIS_Dynamic_Layer_URL__c.split(',');
        
        for(String item : items) {
            item = item.trim();
        }
        
        return items;
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global static Location getMapCenterCoordinates() {
        return Location.newInstance(activeConfig.Map_Center_Latitude__c, activeConfig.Map_Center_Longitude__c);
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global static Integer getMapZoom() {
        return activeConfig != NULL && activeConfig.Default_Map_Zoom__c != NULL ? Integer.valueOf(activeConfig.Default_Map_Zoom__c) : 13;
    }
    
    private static Object getRawLocationById(String id) {
        String url = constructUrl(LocationFetchType.ById, new Map<String, String>{ 'addressId' => id });
        
        if(String.isBlank(url)) {
            return new Base311_Location();
        }
        
        Object res = fetch(url);
        
        Object root = getStartElement(LocationFetchType.ById, res);
        
        return root;
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global static Base311_Location getLocationById(String id) {
        List<Base311_Location> locs = mapEntities(getRawLocationById(id), false);
        
        return locs.size() > 0 ? locs[0] : null;
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global static List<Base311_Location> getLocationsByLatLng(Double lat, Double lng) {
        String url = constructUrl(LocationFetchType.ByLatLng, new Map<String, String>{ 
            'lat' => String.valueOf(lat), 
            'lng' => String.valueOf(lng) 
        });
        
        if(String.isBlank(url)) {
            return new List<Base311_Location>();
        }
        
        Object res = fetch(url);
        
        Object root = getStartElement(LocationFetchType.ByLatLng, res);
        
        List<Base311_Location> locs = mapEntities(root, false);
        
        return locs;
    }
    
    /**
    * @description Find the "sub locations" for a given Base311_Location.
    * @param Base311_Location the location to search withing; if passed null or an empty addressId,
    * an empty list of locations will be returned.
    * @return List<Base311_Location> Sub locations for the provided location
    */
    global static List<Base311_Location> getSublocations(Base311_Location loc) {
        if(loc == null) {
            return new List<Base311_Location>();
        }
        
        // we need to be able to dynamically retrieve the location data
        // to build the where clause
        Map<String, Object> untypeLoc = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(loc));
        
        List<String> whereCriteria = Base311_Helper.csvToList(activeConfig.Sub_Unit_Where_Fields__c);
        
        String whereClause = '';
        
        for(String criteria : whereCriteria) {
            List<String> parts = criteria.split('=');
            String fieldName = parts[1].replace(':', '');
            Object fieldValue = untypeLoc.get(fieldName);
            
            if(fieldValue == null) {
                // skip null params
                continue;
            }
            
            whereClause += ' AND ' + parts[0] + '=' + String.valueOf(fieldValue);
        }
        
        whereClause = whereClause.replaceFirst(' AND ', '');
        
        String url = constructUrl(LocationFetchType.SubUnits, new Map<String, String>{ 
            'where' => whereClause 
        });
        
        List<Base311_Location> locs = mapEntities(getStartElement(LocationFetchType.SubUnits, fetch(url)), false); 
        
        // if ESRI isn't returning lat/lng points for sub addrs,
        // we can assume they  are at the same point as the initial 
        // location
        for(Base311_Location cloc : locs) {
            if(cloc.lat == null) {
                cloc.lat = loc.lat;
            }
            if(cloc.lng == null) {
                cloc.lng = loc.lng;
            }
        }
        
        return locs;
    }
    
    /**
    * @description Gets a list of locations; using a search string
    * @param String the location search string to use; this replaces the :address keyword in the
    * by location address endpoint
    * @return List<Base311_Location> the list of returned locations; if endpoint is not set
    * an empty list is returned
    */
    global static List<Base311_Location> getLocationsByAddress(String search) {
        String url = constructUrl(LocationFetchType.ByAddress, new Map<String, String>{ 
            'address' => search 
        });
        
        if(String.isBlank(url)) {
            return new List<Base311_Location>();
        }
        
        Object res = fetch(url);
        
        Object root = getStartElement(LocationFetchType.ByAddress, res);
        
        List<Base311_Location> locs = mapEntities(root, true);
        
        return locs;
    }
     
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global static List<Base311_ESRI_Layer> getESRILayers(Double lat, Double lng) {
        String url = constructUrl(LocationFetchType.Layers, new Map<String, String>{ 
            'lat' => String.valueOf(lat),
            'lng' => String.valueOf(lng)
        });
        
        if(String.isBlank(url)) {
            return new List<Base311_ESRI_Layer>();
        }
        
        Map<String, Object> result = (Map<String, Object>) fetch(url);
        
        if(result.containsKey('results')) {
            return (List<Base311_ESRI_Layer>) JSON.deserialize(JSON.serialize(result.get('results')),List<Base311_ESRI_Layer>.class);
        }
        
        return new List<Base311_ESRI_Layer>();
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    private static String getEndpointForType(LocationFetchType lft) {
        if(lft == LocationFetchType.ById) {
            if(Test.isRunningTest()) {
                return '/addressId';
            }
        
            return activeConfig.By_Id_Endpoint__c;
        }
        
        if(lft == LocationFetchType.ByLatLng) {
            if(Test.isRunningTest()) {
                return '/addressLatLng';
            }
        
            return activeConfig.By_Lat_Lng_Endpoint__c;
        }
        
        if(lft == LocationFetchType.Layers) {
            if(Test.isRunningTest()) {
                return '/layers';
            }
        
            return activeConfig.Layers_Endpoint__c;
        }
        
        if(lft == LocationFetchType.SubUnits) {
            return activeConfig.Sub_Address_Endpoint__c;
        }
        
        if(Test.isRunningTest()) {
            return '/address/:address';
        }
    
        
        return activeConfig.By_Address_Endpoint__c;
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    private static String getBaseEndpointUrl() {
        if(Test.isRunningTest()) {
            return 'http://test.com';
        }
        
        return activeConfig.Base_URL__c;
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    private static String constructUrl(LocationFetchType lft, Map<String, String> params) {
        String typeEndpoint = getEndpointForType(lft);
        
        if(String.isBlank(typeEndpoint)) {
            return null;
        }
        
        String finalUrl = getBaseEndpointUrl() + typeEndpoint;
        
        for(String key : params.keySet()) {
            finalUrl = finalUrl.replace(':' + key, EncodingUtil.urlEncode(params.get(key), 'UTF-8'));
        }
        
        return finalUrl;
    }
    
    /**
    * @description Filters out invalid locations based on the Location_Endpoint_Filtering__mdt configuration
    * @param Object the item to verify. We check the configured fields' value
    * @return Boolean true if the location is valid; false otherewise
    * @example validLocation(new Map<String, Object>{ })
    */
    private static Boolean validLocation(Object item) {
        if(item instanceof Map<String, Object>) {
            for(Location_Endpoint_Filtering__mdt filter : mFilters) {
                Object value = Base311_Helper.getField((Map<String, Object>) item, filter.Field_Name__c);
                List<String> acceptedValues = Base311_Helper.csvToList(filter.Field_Values__c);
                
                // if the location value is not one of the assigned values; 
                // return false; which will be filtered out by map entities
                if(!Base311_Helper.listContains(acceptedValues, value)) {
                    return false;
                }
            }
            
        }
        
        // default allow locations
        return true;
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    private static List<Base311_Location> mapEntities(Object item, Boolean applyFilters) {
        // if item isn't a list, then we must be looking
        // at a single record.
        
        if(item instanceof List<Object>) {
            List<Base311_Location> locs = new List<Base311_Location>();
            List<Object> items = (List<Object>) item;
            
            for(Object i : items) {
                List<Base311_Location> locations = mapEntities(i, applyFilters);
                
                if(locations != null) {
                    locs.addAll(locations);
                }
            }
            
            return locs;
        }
        
        if(applyFilters && !validLocation(item)) {
            return null;
        } 
        
        return new List<Base311_Location>{ Base311_Location.mapped((Map<String, Object>) item, getMappingConfig()) };
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    private static Map<String, String> getMappingConfig() {
        if(Test.isRunningTest()) {
            return new Map<String, String>{
                'addressId' => 'ADDRESS_ID',
                'lat' => 'LATITUDE',
                'lng' => 'LONGITUDE',
                'address' => 'FULLADDRESS',
                'xCoord' => '',
                'yCoord' => '',
                'neighbourhood' => '',
                'zipCode' => '',
                'unit' => '',
                'ward' => '',
                'streetId'=> '',
                'parcel' => '',
                'precinctWard' => '',
                'subAddressId' => ''
            };
        }
        
        return new Map<String, String>{
            'addressId' => activeConfig.Address_Id_Mapping__c,
            'lat' => activeConfig.Latitude_Mapping__c,
            'lng' => activeConfig.Longitude_Mapping__c,
            'address' => activeConfig.Address_Mapping__c,
            'xCoord' => activeConfig.X_Coord_Mapping__c,
            'yCoord' => activeConfig.Y_Coord_Mapping__c,
            'neighbourhood' => activeConfig.Neighbourhood_Mapping__c,
            'zipCode' => activeConfig.Zip_Code_Mapping__c,
            'unit' => activeConfig.Unit_Mapping__c,
            'ward' => activeConfig.Ward_Mapping__c,
            'streetId'=> activeConfig.Street_Id_Mapping__c,
            'parcel' => activeConfig.Parcel_Mapping__c,
            'precinctWard' => activeConfig.Precinct_Ward_Mapping__c,
            'subAddressId' => activeConfig.Sub_Address_Id_Mapping__c
        };
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    private static String getPathForType(LocationFetchType lft) {
        
        if(Test.isRunningTest()) {
            if(lft == LocationFetchType.ById || lft == LocationFetchType.ByAddress) {
                return 'returnDataset.Table1';
            }
            return 'Table1';
        }
        
        if(lft == LocationFetchType.ById && activeConfig.By_Address_Path__c != null) {
            return activeConfig.By_Address_Path__c;
        }
        
        if(lft == LocationFetchType.ByLatLng && activeConfig.By_Lat_Lng_Path__c != null) {
            return activeConfig.By_Lat_Lng_Path__c;
        }
        
        if(lft == LocationFetchType.ByAddress && activeConfig.By_Address_Path__c!= null) {
            return activeConfig.By_Address_Path__c;
        }
        
        if(lft == LocationFetchType.SubUnits && activeConfig.By_Sub_Units_Path__c != null) {
            return activeConfig.By_Sub_Units_Path__c;
        }
        
        return activeConfig.Default_Path__c;
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    private static Object getStartElement(LocationFetchType lft, Object res) {
        Object result = res;
        
        String path = getPathForType(lft);
        
        if(path != null && res instanceof Map<String, Object>) {
            List<String> paths = path.split('\\.');
            
            for(String chunk : paths) {
            	Map<String, Object> item = (Map<String, Object>) result;
                
                if(!item.containsKey(chunk)) {
                    throw new Base311_Exceptions.ServerException('Failed parsing location path for ' + chunk);
                }
                
                // we're assuming the path provided is valid
                // if things are borked this will throw 
                // an error and that's OK.
                result = item.get(chunk);
            }
        }
        
        return result;
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    private static Object fetch(String endpointUrl) {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(endpointUrl);
        HttpResponse res = h.Send(req);
        String body = res.getBody();
        return String.isEmpty(body) ? new List<Object>() : JSON.deserializeUntyped(body);
    }
    
}