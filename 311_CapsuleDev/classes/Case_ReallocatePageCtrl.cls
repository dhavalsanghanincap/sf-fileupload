/*********
* @author 
* @date 
* @group 
* @group-content
* @description 
*/
public with sharing class Case_ReallocatePageCtrl  {
    //Reallocatecontroller 
    /*public ReallocateController Reallocatectrl{ get; set; }
    
    public override void setComponentController(ReallocateComponentBase compController) {
        Reallocatectrl = (ReallocateController)compController;
        
    }
    
    public override ReallocateComponentBase getreallocateComponentCtrl() {
        return Reallocatectrl; 
        
    }
    */
    public Case c { get; set; }
    private ApexPages.StandardController ctrl;
    //Constructor
    public Case_ReallocatePageCtrl(ApexPages.StandardController controller) {
        if(!Test.isRunningTest()) {
            controller.addFields(new List<String>{ 'OwnerId', 'Incap311__Case_Comments__c', 'Service_Type_Version__r.Service_Type__c' });
        }
        
        c = (Case)controller.getRecord();
        ctrl = controller;
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    //Method on click of Save
    public PageReference onSave(){
        /*c.Case_Comments__c = (c.Case_Comments__c != null ? c.Case_Comments__c : '') + 
            '\n\n' + 
            'Manually Reallocated Case - ' + 
            UserInfo.getUserName() + 
            ' - ' + 
            Base311_Helper.formatDate(System.today()) + ' - ' + 
            Reallocatectrl.comment;
        c.OwnerID =  Reallocatectrl.queueID;   
        update c;*/
        return ctrl.view();
    }
    
}