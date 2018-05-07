/**
* @author John Benson 
* @date 5/3/2017  
* @group 
* @group-content
* @description 
*/
public class Base311_Controller_DuplicateSTVConfig {
    
    public Base311_Service_ServiceType sst = new Base311_Service_ServiceType();
    private Id serviceTypeVersionId;
    private ApexPages.StandardController ctrl;
    private Service_Type_Version__c curSTV;
    
    public List<SelectOption> availableTypes { get; set; }
    public List<SelectOption> selectedTypes { get; set; }
    
    
    public Base311_Controller_DuplicateSTVConfig (ApexPages.StandardController controller) {
        serviceTypeVersionId = controller.getId();
        curSTV = [SELECT Service_Type__c FROM Service_Type_Version__c WHERE Id = :serviceTypeVersionId];
        ctrl = controller;
        availableTypes = getAvailableTypes();
        selectedTypes = getInitialSelected();
    }
    
    /**
    * @description Method to check if alloption contains value or not
    * @param String val
    * @param List<SelectOption> allOption
    * @return TRUE or FALSE
    * @example
    */
    private Boolean contains(String val, List<SelectOption> allOption) {
        for(SelectOption option : allOption) {
            if(val == option.getValue()) {
                return true;
            }
        }
        
        return false;
    }
    
    /**
    * @description Method to check if opt contains allOption
    * @param SelectOption opt
    * @param List<SelectOption> allOption
    * @return TRUE or FALSE
    * @example
    */
    private Boolean contains(SelectOption opt, List<SelectOption> allOption) {
        return contains(opt.getValue(), allOption);
    }
    
    /**
    * @description Method to check if opts contains service type or not
    * @param Service_Type__c st
    * @param List<SelectOption> opts
    * @return TRUE or FALSE
    * @example
    */
    public Boolean contains(Service_Type__c st, List<SelectOption> opts) {
        for(SelectOption opt : opts) {
            if(st.Id == opt.getValue()) {
                return true;
            }
        }
        
        return false;
    }
    
    /**
    * @description Getter method to get availabelTypes
    * @param none
    * @return List<SelectOption>
    * @example
    */
    public List<SelectOption> getAvailableTypes() {
        List<Service_Type__c> serviceTypes = sst.getBaseServiceTypes(); 
        List<SelectOption> currentOpts = this.getInitialSelected();
        List<SelectOption> opts = new List<SelectOption>();
        
        for(Service_Type__c st : serviceTypes) {
            if(!contains(st, currentOpts) && st.Id != curSTV.Service_Type__c) {
                opts.add(new SelectOption(st.Id, st.Service_Type_Code__c));
            }
        }
        
        
        return opts;
    }
    
    /**
    * @description getter method to get InitialSelected
    * @param none
    * @return List<SelectOption>
    * @example
    */
    public List<SelectOption> getInitialSelected() {
        List<SelectOption> opts = new List<SelectOption>();
        List<Duplicate_Service_Type_Mapping__c> dstms = sst.getDuplicateMappings(serviceTypeVersionId);
        
        for(Duplicate_Service_Type_Mapping__c dstm : dstms) {
            opts.add(new SelectOption(dstm.To_Service_Type__c, dstm.To_Service_Type__r.Service_Type_Code__c));
        }
    
        return opts;
    }
    
    /**
    * @description Save logic and redirect the user to view page
    * @param none
    * @return Service_Type_Version__c view page
    * @example
    */
    public PageReference save() {
        List<Duplicate_Service_Type_Mapping__c> toDelete = new List<Duplicate_Service_Type_Mapping__c>();
        List<Duplicate_Service_Type_Mapping__c> toCreate = new List<Duplicate_Service_Type_Mapping__c>();
        
        List<SelectOption> initial = getInitialSelected();
        
        for(SelectOption opt : selectedTypes) {
            if(!contains(opt, initial)) {
                toCreate.add(new Duplicate_Service_Type_Mapping__c(From_Service_Type_Version__c = serviceTypeVersionId, To_Service_Type__c = opt.getValue()));
            }
        }
        
        insert toCreate;
        
        List<Duplicate_Service_Type_Mapping__c> existing = sst.getDuplicateMappings(serviceTypeVersionId);
        
        for(Duplicate_Service_Type_Mapping__c existingConfig : existing) {
            if(!contains(existingConfig.To_Service_Type__c, selectedTypes)) {
                toDelete.add(new Duplicate_Service_Type_Mapping__c(Id = existingConfig.Id));
            }
        }
        
        delete toDelete;
         
        return ctrl.view();
    }
    
}