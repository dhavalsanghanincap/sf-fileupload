/*********
* @author 
* @date 
* @group 
* @group-content
* @description 
*/
public with sharing class Base311_ServiceTypeTransferConfig {

    private Base311_Service_TSRT tts = new Base311_Service_TSRT();
    private Incap311.Base311_Service_ServiceType sst = new Incap311.Base311_Service_ServiceType();
    

    private List<Incap311__Service_Type__c> sts { get; set; }  
    private List<Transfer_Service_Request_Type__c> tsrts { get; set; }  
    private List<Transfer_Service_Request_Type__c> tsrtsForActivites { get; set; }  
    private ApexPages.StandardController ctrl { get; set; }
    
    public String currentServiceTypeId { get; set; }
    public List<SelectOption> selectedTypes { get; set; }
    public List<SelectOption> selectedTypesForActivites { get; set; }
    
    public Base311_ServiceTypeTransferConfig(ApexPages.StandardController ctrl) {
        this.sts = tts.getServiceTypes();
        this.currentServiceTypeId = ctrl.getId();
        this.tsrts = tts.getTransferTypesForServiceType(ctrl.getId());
        this.tsrtsForActivites = tts.getTransferTypesForServiceType(ctrl.getId(), true);
        
        this.selectedTypes = getSelectedTypes(tsrts);
        this.selectedTypesForActivites = getSelectedTypes(tsrtsForActivites);
        this.ctrl = ctrl;
    }

    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    private Boolean isSelected(String id, List<SelectOption> opts) {
        for(SelectOption selected : opts) {
            
            if(selected.getValue() == id) {
                return true;
            }
        }
        
        return false;
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */ 
    public List<SelectOption> getPossibleTypes() {
        return getPossibleTypes(tsrts );
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    public List<SelectOption> getPossibleTypesForActivities() {
        return getPossibleTypes(tsrtsForActivites );
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */ 
    private List<SelectOption> getPossibleTypes(List<Transfer_Service_Request_Type__c> exsitingTransferTypes) {
        List<SelectOption> opts = new List<SelectOption>();
        
        for(Incap311__Service_Type__c st : this.sts) {
            if(!isSelected(st.Id, getSelectedTypes(exsitingTransferTypes)) && st.Id != this.currentServiceTypeId) {
                opts.add(new SelectOption(st.Id, st.Incap311__Service_Name__c));
            }
        }
                
        return opts;
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    @TestVisible 
    private List<SelectOption> getSelectedTypes(List<Transfer_Service_Request_Type__c> exsitingTransferTypes) {
        List<SelectOption> opts = new List<SelectOption>();
        
        for(Transfer_Service_Request_Type__c tsrt : exsitingTransferTypes) {
            opts.add(new SelectOption(tsrt.Incap311__To_Service_Type__c, tsrt.Incap311__To_Service_Type__r.Incap311__Service_Name__c));
        }
        
        return opts;
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    private Id getTSRTByServiceType(List<Transfer_Service_Request_Type__c> transferTypes, String id) {
        for(Transfer_Service_Request_Type__c tsrt : transferTypes) {
            if(tsrt.To_Service_Type__c == id) {
                return tsrt.Id;
            }
        }
        
        return null;
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    public PageReference save() {
        List<Transfer_Service_Request_Type__c> toDelete = new List<Transfer_Service_Request_Type__c>();
        List<Transfer_Service_Request_Type__c> toCreate = new List<Transfer_Service_Request_Type__c>();
        
        // for normal transfer types
        for(SelectOption opt : selectedTypes) {
            if(!isSelected(opt.getValue(), getSelectedTypes(tsrts))) {
                toCreate.add(new Transfer_Service_Request_Type__c(To_Service_Type__c = opt.getValue(), From_Service_Type__c = this.currentServiceTypeId ));
            }
        }
        
        // for activity transfer types
        for(SelectOption opt : selectedTypesForActivites) {
            if(!isSelected(opt.getValue(), getSelectedTypes(tsrtsForActivites))) {
                toCreate.add(new Transfer_Service_Request_Type__c(To_Service_Type__c = opt.getValue(), From_Service_Type__c = this.currentServiceTypeId, For_Activity_Transfer__c = true));
            }
        }
        
        insert toCreate;
        
        // for normal transfer types
        for(SelectOption opt : getSelectedTypes(tsrts)) {
            if(!isSelected(opt.getValue(), selectedTypes)) {
                toDelete.add(new Transfer_Service_Request_Type__c(Id = getTSRTByServiceType(tsrts, opt.getValue())));
            }
        }
        
        // for activity transfer types
        for(SelectOption opt : getSelectedTypes(tsrtsForActivites)) {
            if(!isSelected(opt.getValue(), selectedTypesForActivites)) {
                toDelete.add(new Transfer_Service_Request_Type__c(Id = getTSRTByServiceType(tsrtsForActivites, opt.getValue())));
            }
        }
        
        delete toDelete;
        
        return ctrl.view();
    }
}