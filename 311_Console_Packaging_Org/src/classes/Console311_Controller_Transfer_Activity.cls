/*
 * Block comments with details of changes
 */
public class Console311_Controller_Transfer_Activity
{
    
    public String serviceTypeId {get;set;} 
    
    public Console311_Controller_Transfer_Activity()
    {
        
    }
    
    public List<SelectOption> getSRTypes(){
        List<Incap311__Service_Type_Version__c> tempStvList = Incap311.Base311_Transfer_Case.getActiveServiceTypes(serviceTypeId, true) ;
        List<SelectOption> types = new List<SelectOption>();
        for(Incap311__Service_Type_Version__c stv: tempStvList){
            types.add(new SelectOption(stv.Incap311__Service_Type_Code__c,stv.Incap311__Service_Name__c));
        }
        return types;
    }
}