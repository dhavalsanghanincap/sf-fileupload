/**
* @author 
* @date 
* @group 
* @group-content
* @description 
*/
public class Base311_TriggerHandler_QueueMember {

    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    @future
    public static void afterInsert(Set<Id> sqmsIds) {
        /*List<Id> groupIds = new List<Id>();
        List<Id> contactIds = new List<Id>();
        List<Service_Queue_Member__c> sqms = [SELECT Contact__c, Service_Queue__c,Service_Queue__r.RecordType.Id FROM Service_Queue_Member__c WHERE ID IN :sqmsIds];
        Id recordTypeId = [Select Id From RecordType Where DeveloperName = 'Service_Request_Queue' and SobjectType = 'Incap311__Service_Queue__c'].Id;

        for(Service_Queue_Member__c sqm : sqms) {
            if(sqm.Service_Queue__r.RecordType.Id == recordTypeId){
                groupIds.add(sqm.Service_Queue__c);
                contactIds.add(sqm.Contact__c);
            }
        }

        List<Group> groups = [SELECT Id, DeveloperName FROM Group WHERE DeveloperName IN :groupIds];
        Map<Id, Contact> contacts = new Map<Id, Contact>([SELECT Service_Queue_Member_User__c FROM Contact WHERE Id IN :contactIds]);

        Map<Id, Group> groupMap = new Map<Id, Group>();

        for(Group g : groups) {
            groupMap.put(g.DeveloperName, g);
        }

        List<GroupMember> members = new List<GroupMember>();

        for(Service_Queue_Member__c sqm : sqms) {
            if(sqm.Service_Queue__r.RecordType.Id == recordTypeId){
                Contact c = contacts.get(sqm.Contact__c);

                members.add(new GroupMember(
                    GroupId = groupMap.get(sqm.Service_Queue__c).Id,
                    UserOrGroupId = c.Service_Queue_Member_User__c
                ));
            }
        }

        insert members;*/
    }
}