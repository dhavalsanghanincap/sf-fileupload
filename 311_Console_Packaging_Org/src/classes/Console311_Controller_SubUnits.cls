public with sharing class Console311_Controller_SubUnits { 

    public Incap311.Base311_Location selectedLocation { get; set; }
    private List<Incap311.Base311_Location> activeSubUnits = new List<Incap311.Base311_Location>();
    
    public class SortedSubLocation implements Comparable {
        public Incap311.Base311_Location loc { get; set; }
    
        // Constructor
        public SortedSubLocation (Incap311.Base311_Location loc) {
            this.loc = loc;
        }
        
        public Integer compareTo(Object compareTo) {
            // Cast argument to OpportunityWrapper
            SortedSubLocation compareToLoc = (SortedSubLocation )compareTo;
            
            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            
            // compare by full address first
            if (loc.address > compareToLoc.loc.address) {
                returnValue = 1;
            } else if (loc.address < compareToLoc.loc.address) {
                returnValue = -1;
            } else {
            
                // if the full address is the same; compare by unit
                if (loc.unit > compareToLoc.loc.unit ) {
                    returnValue = 1;
                } else if (loc.unit < compareToLoc.loc.unit) {
                    returnValue = -1;
                }
            }
            
            return returnValue;       
        }
    }
    
    public List<SortedSubLocation > getSubUnits() {
        try { 
             List<SortedSubLocation > sortedUnits = new List<SortedSubLocation >();
        
            if(activeSubUnits.size() == 0 || selectedLocation == null || activeSubUnits.get(0).addressId != selectedLocation.addressId) {
                activeSubUnits = Incap311.Base311_LocationSearch.getSublocations(selectedLocation);
            }
            
            for(Incap311.Base311_Location loc : activeSubUnits) {
                sortedUnits.add(new SortedSubLocation(loc));
            }
            
            sortedUnits.sort();
            
            return sortedUnits ;
        } catch (Exception e) {

            return new List<SortedSubLocation>{  };
        }
    }
    
    public Map<String, String> getEncodedSubunits() {
        Map<String, String> mappings = new Map<String, String>();
        
        for(SortedSubLocation subUnit : getSubUnits()){ 
            mappings.put(subUnit.loc.subAddressId, subUnit.loc.toJSON());
        }
        
        return mappings;
    }

}