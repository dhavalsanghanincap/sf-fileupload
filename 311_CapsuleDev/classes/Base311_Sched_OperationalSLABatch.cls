/**
* @author Sean Murphy  
* @date 4/27/2017
* @group 
* @group-content
* @description Scheduler class to run Base311_Batch_OperationalSLAStatusUpdate batch class
*/
global class Base311_Sched_OperationalSLABatch implements Schedulable {

	/**
    * @description Execute method to run Base311_Batch_OperationalSLAStatusUpdate batch class and schedule it
    * @param SchedulableContext sc
    * @return void
    * @example
    */
    global void execute(SchedulableContext sc) {
        Base311_Batch_OperationalSLAStatusUpdate slaUpdate = new Base311_Batch_OperationalSLAStatusUpdate();
        Database.executeBatch(slaUpdate);   
    }
}