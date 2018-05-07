/**
* @author 
* @date 
* @group 
* @group-content
* @description 
*/
/*
 * Block comments with details of changes
 */
public class Base311_Validation
{
    public Base311_Dependency dependentOn = null;
    public String message;

    private Base311_Validation(String message) {
        this.message = message;
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    public static List<Base311_Validation> fromJSON(String jsonString) {
    
        try {
            // first try to marshal it into a dependent picklist; if that works return it
            return (List<Base311_Validation>) JSON.deserializeStrict(jsonString, List<Base311_Validation>.class);
        } catch (JSONException e) {
            System.debug(e);
        }
        
        return new  List<Base311_Validation>();
    }
    
 

}