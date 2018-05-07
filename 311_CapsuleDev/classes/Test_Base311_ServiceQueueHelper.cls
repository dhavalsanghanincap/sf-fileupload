@isTest
private class Test_Base311_ServiceQueueHelper {
    
    static testMethod void testCreateServiceQueueAndMember() {
    	
    	// create user
		User testUser = Test_RestTestHelper.user();    	
    	
    	// create contact
    	Contact testCon = Test_RestTestHelper.contact(testUser.Id);
    	
    	// get service queue record type id
    	Id recordTypeId = [Select Id From RecordType Where DeveloperName = 'Service_Request_Queue' and SobjectType = 'Incap311__Service_Queue__c'].Id;
    	
		Test.startTest();
		
		// create service queue    	
    	Service_Queue__c sq = new Service_Queue__c();
    	sq.RecordTypeId = recordTypeId;
    	sq.Name = 'TestServiceQueue';
    	insert sq;
    	
    	// create service queue member
    	Service_Queue_Member__c sqm = new Service_Queue_Member__c();
    	sqm.Service_Queue__c = sq.Id;
    	sqm.Contact__c = testCon.Id;
    	insert sqm;
    	
		Test.stopTest();    	
    	
    	// verify SF queue was created
    	Group g = [SELECT Id, Name, DeveloperName, Type FROM Group WHERE Name = :sq.Name];
    	System.assert(g != null);
    	System.assertEquals(g.Type, 'Queue');
    	
    	// verify SF group member was created
    	GroupMember gm = [SELECT Id, GroupId, UserOrGroupId FROM GroupMember WHERE GroupId = :g.Id];
    	System.assert(gm != null);
    	System.assertEquals(gm.UserOrGroupId, testUser.Id);
    }  
}