/**
* @author Sean Murphy
* @date 4/27/2017  
* @group batch
* @group-content
* @description batch to update cases having hold status and Incap311__Expected_Start_Date__c as tomorrow to New
*/
global class Base311_Batch_OperationalSLAStatusUpdate implements Database.Batchable<sObject> {
    
    /**
    * @description start method for batch to define the scope
    * @param Database.BatchableContext BC
    * @return Database.getQueryLocator
    * @example
    */
    global Database.QueryLocator start(Database.BatchableContext BC) {
    	return Database.getQueryLocator([SELECT Id, Status FROM Case WHERE Status = 'Hold' AND Incap311__Expected_Start_Date__c < :date.today().addDays(1)]);
    }
    
    /**
    * @description execute method of the batch
    * @param Database.BatchableContext bc
    * @param List<SObject> scope
    * @return void
    * @example
    */
    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        List<Case> cs = new List<Case>();
        for (SObject s : scope) {
            Case c = (Case)s;
            System.debug('>>' + c.id);
            c.Status = 'New';
            cs.add(c);
        }
        update cs;
    }
    
    /**
    * @description finish method of batch
    * @param Database.BatchableContext bc
    * @return void
    * @example
    */
    global void finish(Database.BatchableContext bc){
        system.debug('Operational SLA Status Update batch is complete.');
    }
}