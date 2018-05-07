/**
* @author John Benson
* @date  12/22/2016  
* @group 
* @group-content
* @description 
*/
public class Base311_DependentPicklist {

    public Base311_Dependency dependentOn = null;
    public List<Base311_QuestionAnswer> values;
    
    // hold over from the UI that tracks which thing is open;
    // not actually used for anything
    private Boolean open;
    
    private Base311_DependentPicklist(List<Base311_QuestionAnswer> values) {
        this.values = values;
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    public static List<Base311_DependentPicklist> fromJSON(String jsonString) {
    
        try {
            // first try to marshal it into a dependent picklist; if that works return it
            return (List<Base311_DependentPicklist>) JSON.deserializeStrict(jsonString, List<Base311_DependentPicklist>.class);
        } catch (JSONException e) {
            // if we hit a JSON exception; then we might have a normal picklist; if we do, try to deserialize the json
            // into a Question Answer list and return a dependent picklist with a single item which has no conditions
            List<Base311_QuestionAnswer> values = Base311_QuestionAnswer.fromJSON(jsonString);
            
            System.debug(e);
            System.debug(jsonString);
            System.debug(values);
            
            return new List<Base311_DependentPicklist>{ new Base311_DependentPicklist(values) };
        }
        
        return null;
    }
}