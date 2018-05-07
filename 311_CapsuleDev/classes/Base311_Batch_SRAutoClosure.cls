/**
* @author Matt Darkis 
* @date 12/21/2016  
* @group Batch
* @group-content
* @description Batch class to close the cases having status = open, Incap311__Auto_Close__c = true and Incap311__Auto_Close_Date__c = TODAY. The batch is called by Base311_Batch_SRAutoClose_Schedulable class
*/
global class Base311_Batch_SRAutoClosure implements Database.Batchable<SObject> {
  
  String query;
  Boolean isFinalRun { get; set; }
  
  global Base311_Batch_SRAutoClosure() {}

  global Base311_Batch_SRAutoClosure(String query) {
    this.query = query;
    this.isFinalRun = false;
  }
  /* 
    Example Query: 
      Select 
        Id,
        Status,
        Reason,
        Comments,
        Incap311__Service_Type_Version__c, 
        Incap311__Auto_Close__c,
		    Incap311__Auto_Close_Date__c
      From 
        Case 
      Where
        Status = 'Open' AND 
  		  Incap311__Auto_Close__c = true AND
		    Incap311__Auto_Close_Date__c = TODAY
  */
  /**
    * @description start method of the batch
    * @param Database.BatchableContext BC
    * @return Database.QueryLocator
    * @example
    */
  global Database.QueryLocator start(Database.BatchableContext BC) {
    Database.QueryLocator results;

    try {
      System.debug('----> Query: ' + query);
      results = Database.getQueryLocator(query);
      System.debug('----> Results: ' + results);

      if (results == null || (results != null && !results.Iterator().hasNext())) {
        this.isFinalRun = true;
      }
    } catch (Exception e) {
      System.debug('----> Unable to query any records for Auto Closure batch. Proceeding with cancellation...');
      results = Database.getQueryLocator('');
    }
    return results;
  }

  /**
    * @description execute method of the batch
    * @param Database.BatchableContext BC
    * @param List<Case> scope
    * @return void
    * @example
    */
  global void execute(Database.BatchableContext BC, List<Case> scope) {
    System.debug('----> Scope: ' + scope);
    // Capture the scope variables.
	  List<Case> casesToCloseList = scope;
    // Loop through the list of Versions and their related SR's. 
    for (Case c : casesToCloseList) {
      c.Status = 'Closed';
      c.Reason = 'Other';
      //c.Comments = 'Case closed automatically by Auto Closure System.';
    }
    // Call to update the case list. 
    update casesToCloseList;
  }
  
  /**
    * @description finish method of the batch
    * @param Database.BatchableContext BC 
    * @return void
    * @example
    */
  global void finish(Database.BatchableContext BC) {
    // Current implementation does not require any further processing. Closure emails, etc
    //   are being handled by the workflow rules in place. Any further additions to this logic
    //   can be added here. i.e - Recursive batchables if necessary.
  }
  
}