/**
* @author John Benson 
* @date 4/3/2017  
* @group 
* @group-content
* @description 
*/

public class Base311_Controller_ReallocateConfig {
    
    public Base311_Service_Reallocate sr = new Base311_Service_Reallocate();
    private Id serviceTypeId;
    private ApexPages.StandardController ctrl;
    
    public List<SelectOption> availableQueues { get; set; }
    public List<SelectOption> selectedQueues { get; set; }
    
    public List<SelectOption> availableQueuesActivites { get; set; }
    public List<SelectOption> selectedQueuesActivites { get; set; }
    
    public Base311_Controller_ReallocateConfig (ApexPages.StandardController controller) {
        serviceTypeId = controller.getId();
        availableQueues = initialAvailableQueues(false);
        selectedQueues = initialSelectedQueues(false);
        availableQueuesActivites = initialAvailableQueues(true);
        selectedQueuesActivites = initialSelectedQueues(true);
        ctrl = controller;
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
    * @description Method to check if given queue is part of allQueue list
    * @param QueueSobject queue
    * @param List<QueueSobject> allQueues
    * @return TRUE or FALSE
    * @example
    */
    private Boolean contains(QueueSobject queue, List<QueueSobject> allQueues) {
        for(QueueSobject q : allQueues) {
            if(q.Queue.Id == queue.Queue.Id) {
                return true;
            }
        }
        
        return false;
    }
    
    /**
    * @description Method to get available queues
    * @param Boolean forActivites
    * @return List<SelectOption>
    * @example
    */
    public List<SelectOption> initialAvailableQueues(Boolean forActivites) {
        List<QueueSObject> allQueues = sr.getAvailableQueues();
        List<QueueSObject> selectedQueues = sr.getActiveReallocateQueues(serviceTypeId, forActivites);
        List<SelectOption> opts = new List<SelectOption>();
        
        for(QueueSobject queue : allQueues) {
            if(!contains(queue, selectedQueues)) {
                opts.add(new SelectOption(queue.Queue.Id, queue.Queue.Name));
            }
        }
        
        return opts;
    }
    
    /**
    * @description Method to get selected queues 
    * @param Boolean forActivites
    * @return List<SelectOption>
    * @example
    */
    public List<SelectOption> initialSelectedQueues(Boolean forActivites) {
        List<QueueSObject> queues = sr.getActiveReallocateQueues(serviceTypeId, forActivites);
        List<SelectOption> opts = new List<SelectOption>();
        
        for(QueueSObject queue : queues) {
            opts.add(new SelectOption(queue.Queue.Id, queue.Queue.Name));
        }
        
        return opts;
    }
    
    /**
    * @description Save logic and redirection to view page
    * @param none
    * @return PageReference
    * @example
    */
    public PageReference save() {
        List<Reallocate_Service_Request_Type__c> toDelete = new List<Reallocate_Service_Request_Type__c>();
        List<Reallocate_Service_Request_Type__c> toCreate = new List<Reallocate_Service_Request_Type__c>();
        
        List<SelectOption> initial = initialSelectedQueues(false);
        List<SelectOption> initialType = initialSelectedQueues(true);
        
        //for service type
        for(SelectOption opt : selectedQueues) {
            if(!contains(opt, initial)) {
                toCreate.add(new Reallocate_Service_Request_Type__c(Service_Type__c = serviceTypeId, Queue_Id__c = opt.getValue()));
            }
        }
        
        // for activities
        for(SelectOption opt : selectedQueuesActivites) {
            if(!contains(opt, initialType)) {
                toCreate.add(new Reallocate_Service_Request_Type__c(Service_Type__c = serviceTypeId, Queue_Id__c = opt.getValue(), For_Activties__c = true));
            }
        }
        
        insert toCreate;
        
        List<Reallocate_Service_Request_Type__c> existing = sr.getReallocateConfig(serviceTypeId, false);
        List<Reallocate_Service_Request_Type__c> exitingType = sr.getReallocateConfig(serviceTypeId, true);
        
        for(Reallocate_Service_Request_Type__c existingConfig : existing) {
            if(!contains(existingConfig.Queue_Id__c, selectedQueues)) {
                toDelete.add(new  Reallocate_Service_Request_Type__c(Id = existingConfig.Id));
            }
        }
        
        for(Reallocate_Service_Request_Type__c existingConfig : exitingType) {
            if(!contains(existingConfig.Queue_Id__c, selectedQueuesActivites)) {
                toDelete.add(new  Reallocate_Service_Request_Type__c(Id = existingConfig.Id));
            }
        }
         
         
        delete toDelete;
         
        return ctrl.view();
    }
    
}