@isTest
public class Test_Base311_TriggerHandler_QueueMember {

    @isTest
    static void testAfterInsert() {
		/*Contact c = Test_RestTestHelper.contact(); 
        c.Service_Queue_Member_User__c = Test_RestTestHelper.user().Id;
        update c;
        
        Service_Queue__c sq = new Service_Queue__c(Name = 'Test1');
        insert sq;
         
        Test.startTest();
        Service_Queue_Member__c sqm = new Service_Queue_Member__c(Contact__c = c.Id, Service_Queue__c = sq.Id);
        sqm.Contact__r = c;
        insert sqm;
        Test.stopTest();
        
        List<GroupMember> gm = [SELECT UserOrGroupId FROM GroupMember WHERE UserOrGroupId = :c.Service_Queue_Member_User__c];
        
        System.assertEquals(gm.size(), 1);*/ 
    }
    
}