/**
* @author 
* @date 
* @group 
* @group-content
* @description 
*/
global class Base311_Location extends Base311_Object {

    global Double lat { get; set; }
    global Double lng { get; set; }
    global String addressId { get; set; }
    global String subAddressId { get; set; }
    global String address { get; set; }
    global String zipCode { get; set; }
    global Double xCoord { get; set; }
    global Double yCoord { get; set; }
    global String neighbourhood { get; set; }
    global String parcel { get; set; }
    global String precinctWard { get; set; }
    global String streetId { get; set; }
    global String unit { get; set; }
    global String ward { get; set; }
    global List<Base311_ESRI_Layer> layers { get; set; }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global List<String> getLayerValue(String layerId, String valuePath) {
        if(layers == null) {
            return new List<String>();
        }
        
        List<String> values = new List<String>();
        
        for(Base311_ESRI_Layer layer : layers) {
            try {
                if(String.valueOf(layer.layerId) == layerId || layer.layerName == layerId) { 
                        values.add(String.valueOf(Base311_Helper.getSingleField(
                            (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(layer)),
                            valuePath
                        )));
                    }
                } catch (Exception e) {
                    // eat the errors
                }
        }
        
        return values;
    }
    
    global Base311_Location() {
        
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global static Base311_Location mapped(Map<String, Object> entity, Map<String, String> mappings) { 
        Base311_Location loc = new Base311_Location();
        loc.lat = getDouble(entity, mappings, 'lat');
        loc.lng = getDouble(entity, mappings, 'lng');
        loc.addressId = getString(entity, mappings, 'addressId'); 
        loc.address = getString(entity, mappings, 'address');
        loc.zipCode = getString(entity, mappings, 'zipCode');
        loc.xCoord = getDouble(entity, mappings, 'xCoord');
        loc.yCoord = getDouble(entity, mappings, 'yCoord');
        loc.neighbourhood = getString(entity, mappings, 'neighbourhood');
        loc.parcel = getString(entity, mappings, 'parcel');
        loc.precinctWard = getString(entity, mappings, 'precinctWard');
        loc.streetId = getString(entity, mappings, 'streetId');
        loc.unit = getString(entity, mappings, 'unit');
        loc.ward = getString(entity, mappings, 'ward');
        loc.subAddressId = getString(entity, mappings, 'subAddressId');
        return loc;
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    private static Double getDouble(Map<String, Object> entity, Map<String, String> mappings, String field) {
        return Double.valueOf(getField(entity, mappings, field));
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    private static String getString(Map<String, Object> entity, Map<String, String> mappings, String field) {
        return String.valueOf(getField(entity, mappings, field));
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    private static Object getField(Map<String, Object> entity, Map<String, String> mappings, String field) {
        String mappedFieldName = mappings.containsKey(field) ? mappings.get(field) : null;
        
        if(mappedFieldName == null) {
            return null;
        }
        

        return Base311_Helper.getField(entity, mappedFieldName);
    }
    
    
    global Base311_Location (Double lat, Double lng, String addressId, String address) {
        this(lat, lng, addressId, address, null, null, null);
    }
    
    global Base311_Location (
        Double lat, Double lng, String addressId, String address, String zipCode,
        Double xCoord, Double yCoord 
    ) {
      this(lat, lng, addressId, address, zipCode, xCoord, yCoord, null, null, null, null, null, null);
    }

    global Base311_Location(
        Double lat, Double lng, String addressId, String address, String zipCode,
        Double xCoord, Double yCoord, String neighbourhood, String parcel, String precinctWard, 
        String streetId, String unit, String ward
    ) {
        this.lat = lat;
        this.lng = lng;
        this.addressId = addressId;
        this.address = address;
        this.zipCode = zipCode;
        this.xCoord = xCoord;
        this.yCoord = yCoord;
        this.neighbourhood = neighbourhood;
        this.parcel = parcel;
        this.precinctWard = precinctWard;
        this.streetId = streetId;
        this.unit = unit;
        this.ward = ward;
    }
    
    global override void validation() {
        
    }
    
    global Base311_Location refineAddress() {
        if(addressId == null && address != null) {
            List<Base311_Location> locations = Base311_LocationSearch.getLocationsByAddress(address);
            
            if(locations.size() > 0) {
                return locations[0];
            }
        }
        
        return this;
    }

    global Base311_Location addLayerInformation() {
        if(this.lat != null && this.lng != null) {
            this.layers = Base311_LocationSearch.getESRILayers(this.lat, this.lng);
        }
        
        return this;
    }
    
    
    global String toJSON() {
        return JSON.serialize(this);
    }
    
    global static Base311_Location findMatch(Double lat, Double lng, String addressId, String address, Boolean required) {
        List<Base311_Location> locs;
        
        if(addressId != null) {
           Base311_Location loc = Base311_LocationSearch.getLocationById(addressId); 
           return loc == null ? new Base311_Location() : loc;
        } 
        else if(lat != null && lng != null) {
           locs = Base311_LocationSearch.getLocationsByLatLng(lat, lng);
        }
        else if(address != null) {
            locs = Base311_LocationSearch.getLocationsByAddress(address);
            
            if(locs.size() == 0 && required) {
                throw new Base311_Exceptions.UnsupportedException('Could not find any matches for address_string '  + address);
            }
        }
        
        if(locs == null && required) {
            throw new Base311_Exceptions.UnsupportedException('One of address_id, lat + long, or address_string are required');
        }
        
        if(locs == null || locs.size() == 0) {
            return new Base311_Location();
        }

        return locs[0];
    }
}