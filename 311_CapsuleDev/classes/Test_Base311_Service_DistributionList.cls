@isTest
public class Test_Base311_Service_DistributionList {

    private static Base311_Service_DistributionList sdl = new Base311_Service_DistributionList();

    @isTest
    static void testGetDefaultDistributionList() {
        Account a = Test_RestTestHelper.account('Abc123');
        Service_Queue__c sq = Test_RestTestHelper.serviceQueue(a.Id);
        Service_Queue__c sq2 = Test_RestTestHelper.serviceQueue(a.Id);
        User u = Test_RestTestHelper.user();
        Contact c1 = Test_RestTestHelper.contact(u.Id);
        Contact c2 = Test_RestTestHelper.contact(u.Id);
        Contact c3 = Test_RestTestHelper.contact(u.Id);
        Service_Queue_Member__c sqm1 = Test_RestTestHelper.serviceQueueMember(sq.Id, c1.Id);
        Service_Queue_Member__c sqm2 = Test_RestTestHelper.serviceQueueMember(sq.Id, c2.Id);
        Service_Queue_Member__c sqm3 = Test_RestTestHelper.serviceQueueMember(sq2.Id, c3.Id);
        Service_Type_Version__c stv = Test_RestTestHelper.sericeTypeVersionAndVersion();
        Service_Type_Queue_Zone__c stqz = Test_RestTestHelper.serviceTypeQueueZone(stv.Id, null, sq.Id);
         
        List<Contact> contacts = sdl.getDefaultDistributionList(stv, 'Abc123');
        System.assertEquals(contacts.size(), 2);
    }

    @isTest
    static void testGetWardDistributionList() {
        Account a = Test_RestTestHelper.account('Abc123');
        Service_Queue__c sq = Test_RestTestHelper.serviceQueue(a.Id, false);
        Service_Queue__c sq2 = Test_RestTestHelper.serviceQueue(a.Id, true);
        User u = Test_RestTestHelper.user();
        Contact c1 = Test_RestTestHelper.contact(u.Id);
        Contact c2 = Test_RestTestHelper.contact(u.Id);
        Contact c3 = Test_RestTestHelper.contact(u.Id);
        Zone__c z = Test_RestTestHelper.zone('abc', Schema.SObjectType.Zone__c.RecordTypeInfosByName.get('Asset').RecordTypeId);
        Zone__c z2 = Test_RestTestHelper.zone('def', Schema.SObjectType.Zone__c.RecordTypeInfosByName.get('Asset').RecordTypeId);
        Service_Queue_Member__c sqm1 = Test_RestTestHelper.serviceQueueMember(sq.Id, c1.Id);
        Service_Queue_Member__c sqm2 = Test_RestTestHelper.serviceQueueMember(sq.Id, c2.Id);
        Service_Queue_Member__c sqm3 = Test_RestTestHelper.serviceQueueMember(sq2.Id, c3.Id);
        Service_Type_Version__c stv = Test_RestTestHelper.sericeTypeVersionAndVersion();
        Service_Type_Queue_Zone__c stqz = Test_RestTestHelper.serviceTypeQueueZone(stv.Id, z.Id, sq.Id);
        Service_Type_Queue_Zone__c stqz2 = Test_RestTestHelper.serviceTypeQueueZone(stv.Id, z.Id, sq2.Id);
         
        List<Contact> contacts = sdl.getWardDistributionList(stv, 'abc', 'Abc123');
        System.assertEquals(contacts.size(), 2);
    }

    @isTest
    static void testGetCoordinatorWardDistributionList() {
        Account a = Test_RestTestHelper.account('Abc123');
        Service_Queue__c sq = Test_RestTestHelper.serviceQueue(a.Id, false);
        Service_Queue__c sq2 = Test_RestTestHelper.serviceQueue(a.Id, true);
        User u = Test_RestTestHelper.user();
        Contact c1 = Test_RestTestHelper.contact(u.Id);
        Contact c2 = Test_RestTestHelper.contact(u.Id);
        Contact c3 = Test_RestTestHelper.contact(u.Id);
        Zone__c z = Test_RestTestHelper.zone('abc', Schema.SObjectType.Zone__c.RecordTypeInfosByName.get('Asset').RecordTypeId);
        Zone__c z2 = Test_RestTestHelper.zone('def', Schema.SObjectType.Zone__c.RecordTypeInfosByName.get('Asset').RecordTypeId);
        Service_Queue_Member__c sqm1 = Test_RestTestHelper.serviceQueueMember(sq.Id, c1.Id);
        Service_Queue_Member__c sqm2 = Test_RestTestHelper.serviceQueueMember(sq.Id, c2.Id);
        Service_Queue_Member__c sqm3 = Test_RestTestHelper.serviceQueueMember(sq2.Id, c3.Id);
        Service_Type_Version__c stv = Test_RestTestHelper.sericeTypeVersionAndVersion();
        Service_Type_Queue_Zone__c stqz = Test_RestTestHelper.serviceTypeQueueZone(stv.Id, z.Id, sq.Id);
        Service_Type_Queue_Zone__c stqz2 = Test_RestTestHelper.serviceTypeQueueZone(stv.Id, z.Id, sq2.Id);
         
        List<Contact> contacts = sdl.getWardCoordinatorDistributionList(stv, 'abc', 'Abc123');
        System.assertEquals(contacts.size(), 1);
    }
    
    @isTest
    static void testStringifyDistributionList() {
        String res = sdl.stringifyDistributionList(new List<String>{ 'a  d', 'b', 'c' });
        System.assertEquals(res, 'a  d,b,c');
    }
    
    @isTest
    static void testStringifyDistributionListNull() {
        String res = sdl.stringifyDistributionList(null);
        System.assertEquals(res, '');
    }
    
    @isTest
    static void testArrayifyDistributionList() {
        List<String> res = sdl.arrayifyDistributionList('a d, b, c ');
        System.assertEquals(res.size(), 3);
        System.assertEquals(res[0], 'a d');
        System.assertEquals(res[1], 'b');
        System.assertEquals(res[2], 'c');
    }
    
    @isTest
    static void testArrayifyDistributionListNull() {
        List<String> res = sdl.arrayifyDistributionList(null);
        System.assertEquals(res.size(), 0);
    }

    @isTest
    static void testStubContactsByEmailDistributionExists() {
        Account a = new Account(Name = 'Distribution');
        insert a;
    
        Contact c = Test_RestTestHelper.contact();
        User u = Test_RestTestHelper.user();
        List<SObject> stubContacts = sdl.stubContactsByEmail(new List<String>{ c.Email, u.Email, 'test123@test.com' });
        System.assertEquals(stubContacts.size(), 3);
        
        a = [ SELECT Id, (SELECT Id, Email, LastName FROM Contacts) FROM Account WHERE Name = 'Distribution' ];
        
        System.assertEquals(a.Contacts.size(), 1);
        System.assertEquals(a.Contacts[0].LastName, 'test123');
        System.assertEquals(a.Contacts[0].Email, 'test123@test.com');
    }

    @isTest
    static void testStubContactsByEmail() {
        Contact c = Test_RestTestHelper.contact();
        User u = Test_RestTestHelper.user();
        List<SObject> stubContacts = sdl.stubContactsByEmail(new List<String>{ c.Email, u.Email, 'test123@test.com' });
        System.assertEquals(stubContacts.size(), 3);
        
        Account a = [ SELECT Id, (SELECT Id, Email, LastName FROM Contacts) FROM Account WHERE Name = 'Distribution' ];
        
        System.assertEquals(a.Contacts.size(), 1);
        System.assertEquals(a.Contacts[0].LastName, 'test123');
        System.assertEquals(a.Contacts[0].Email, 'test123@test.com');
    }

    @isTest
    static void testFindTargetsByString() {
        Contact c = Test_RestTestHelper.contact();
        User u = Test_RestTestHelper.user();
        Contact c2 = new Contact(Email = u.Email, LastName = 'othertest', Service_Queue_Member_User__c = u.Id);
        insert c2;
        
        System.assertEquals(sdl.findTargets(c.Email + ',' + u.Email + ',' + c2.Email + ',' + 'test@dne.com').size(), 2);
    }

}