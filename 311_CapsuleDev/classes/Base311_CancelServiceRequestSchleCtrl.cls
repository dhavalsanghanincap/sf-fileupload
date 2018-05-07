/**
* @author Vrajesh Sheth
* @date 5/10/2017 
* @group 
* @group-content
* @description extension for Base311_CancelServiceRequestSchle page to cancel schedule request logic
*/
public with sharing class Base311_CancelServiceRequestSchleCtrl {
    public Service_Request_Schedule__c schedulerecord{get;set;}
    private ApexPages.StandardController stdcontroller;
    public Base311_CancelServiceRequestSchleCtrl(ApexPages.StandardController controller) {
        list<String> fields = new list<string>{'Incap311__Schedule__r.Name','Incap311__Schedule__r.Incap311__Schedule_Date__c','Incap311__Schedule__r.Incap311__Day_of_Week__c','Incap311__Schedule__r.Incap311__Item_Count__c','Incap311__Cancel_Reason__c','Incap311__Is_Cancelled__c','Incap311__Service_Request__r.CaseNumber','Incap311__Service_Request__r.Subject','Incap311__Number_Of_Items__c'};
        if(!test.isRunningTest()){
            controller.addFields(fields);
        }
        this.schedulerecord= (Service_Request_Schedule__c )controller.getRecord();
        stdcontroller = controller;
    }
    
    /**
    * @description method to perform cancel and save logic
    * @param none
    * @return pageReference view page of request scehdule
    * @example
    */
    public pageReference onSave(){
        try{
            Boolean IsCancelled  = Base311_ServiceRequestScheduleUtil.cancelServiceRequestSchedule(schedulerecord.Incap311__Cancel_Reason__c,schedulerecord);
            return stdcontroller.view();
            }catch(exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
                return null;
            }
    }
}