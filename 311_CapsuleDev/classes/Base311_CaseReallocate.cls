/**
* @author John Benson
* @date 1/23/2017
*
* @group 
*
* @description extension Class for Service request reallocate functionality
*/
public with sharing class Base311_CaseReallocate extends Base311_ReallocatePageCtrlBase{
    /**
    * @description Case sObject
    */
    public Case c { get; set; }
    /**
    * @description flag to check if the functionality is for activity or Service request
    */
    public Boolean forActivities { get; set; }
    /**
    * @description Comment input by user
    */
    public String comment { get; set; }
    private Base311_Service_Reallocate sre = new Base311_Service_Reallocate();
    private ApexPages.StandardController ctrl;
    
    //Reallocate component implementation
    public Base311_ReallocateController Reallocatectrl{ get; set; }
    

    /**
   * @description set Reallocatectrl value 
   * @param  Base311_ReallocateComponentBase 
   * @return void
   * @example
   * 
   */
    public override void setComponentController(Base311_ReallocateComponentBase compController) {
        Reallocatectrl = (Base311_ReallocateController)compController;
        
    }
    
    /**
   * @description override getter method for reallocateComponentCtrl from Base311_ReallocatePageCtrlBase virtual class
   * @param  none 
   * @return void
   * @example
   * 
   */
    public override Base311_ReallocateComponentBase getreallocateComponentCtrl() {
        return Reallocatectrl; 
        
    }
     
    public Base311_CaseReallocate(ApexPages.StandardController controller) {
        if(!Test.isRunningTest()) {
            controller.addFields(new List<String>{ 'OwnerId', 'Incap311__Case_Comments__c', 'Service_Type_Version__r.Service_Type__c' });
        }
        
        c = (Case) controller.getRecord();
        Map<String, String> params = ApexPages.currentPage().getParameters();
        
        forActivities = params.containsKey('a') ? Boolean.valueOf(params.get('a')) : false;
        ctrl = controller;
    }
    /*
    public List<SelectOption> getQueues() {
        List<SelectOption> options = new List<SelectOption>(); 
        
        for (QueueSobject  q : sre.getActiveReallocateQueues(c.Service_Type_Version__r.Service_Type__c, forActivities)){
            options.add(new SelectOption(q.Queue.Id, q.Queue.Name)); 
        }
        
        return options;
    }
    */

     /**
   * @description save method to update all the changes done on component
   * @param  none 
   * @return PageReference sobject view page
   * @example
   * 
   */
    public PageReference save() {
        
        c.Case_Comments__c = (c.Case_Comments__c != null ? c.Case_Comments__c : '') + 
            '\n\n' + 
            'Manually Reallocated Case - ' + 
            UserInfo.getUserName() + 
            ' - ' + 
            Base311_Helper.formatDate(System.today()) + ' - ' + 
            Reallocatectrl.comment;
            c.ownerID = Reallocatectrl.queueID;
        update c;
        return ctrl.view();
    }
    
}