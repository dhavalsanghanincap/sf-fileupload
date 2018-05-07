/**
* @author Matt Darkis 
* @date 12/21/2016  
* @group Scheduler
* @group-content
* @description scheduler to run Base311_Batch_SRAutoClosure batch class
*/
global class Base311_Batch_SRAutoClose_Schedulable implements Schedulable {

  private final String mDefaultQuery = 'Select Id, Status, Reason, Incap311__Service_Type_Version__c, Incap311__Auto_Close__c, Incap311__Auto_Close_Date__c From Case Where Status = \'Open\' AND Incap311__Auto_Close__c = true AND Incap311__Auto_Close_Date__c = TODAY';
  public String mQuery { get; set; }

  global Base311_Batch_SRAutoClose_Schedulable() {}

  global Base311_Batch_SRAutoClose_Schedulable(String query) {
    this.mQuery = query;
  }

  /**
    * @description execute method of scheduler class
    * @param SchedulableContext sc
    * @return void
    * @example
    */
  global void execute(SchedulableContext sc) {
    Base311_Batch_SRAutoClosure SRAutoBatch = new Base311_Batch_SRAutoClosure(String.isNotBlank(this.mQuery) ? this.mQuery : this.mDefaultQuery);
    database.executebatch(SRAutoBatch);
  }
}