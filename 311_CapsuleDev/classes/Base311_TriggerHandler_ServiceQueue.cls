/**
* @author 
* @date 
* @group 
* @group-content
* @description 
*/
public class Base311_TriggerHandler_ServiceQueue {

    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    public static void afterInsert(List<Service_Queue__c> sqs) {

        Id recordTypeId = [Select Id From RecordType Where DeveloperName = 'Service_Request_Queue' and SobjectType = 'Incap311__Service_Queue__c'].Id;

        List<Group> groups = new List<Group>();

        for(Service_Queue__c sq : sqs) {
            if(sq.RecordTypeId == recordTypeId){
                groups.add(new Group(
                    Type = 'Queue',
                    DeveloperName = sq.Id,
                    Name = sq.Name
                ));
            }
        }

        insert groups;
    }

}