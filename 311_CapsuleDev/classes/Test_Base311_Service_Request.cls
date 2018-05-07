@isTest
public class Test_Base311_Service_Request {

    @isTest
    static void testGetContactRequests() {
        Contact con = Test_RestTestHelper.contact();
        
        Case c1 = Test_RestTestHelper.serviceRequest();
        Case c2 = Test_RestTestHelper.serviceRequest();
        Case c3 = Test_RestTestHelper.serviceRequest();
        
        c3.ContactId = c2.ContactId = c1.ContactId = con.Id;
        
        update c1;
        update c2;
        update c3;
        
        
        Base311_Service_Request rsq = new Base311_Service_Request();
        List<Case> cases = rsq.getContactRequests(con.Id);
        System.assertEquals(cases.size(), 3);
    }
    
    @isTest
    static void testUpdateServiceRequestUpdateContactRequired() {
        
        Test_Base311_MockLocation.setupMocks();

        Service_Type_Version__c stv = Test_RestTestHelper.sericeTypeVersionAndVersion('TEST1');
        stv.Override_Contact_Status__c = Base311_Contact.CONTACT_REQUIRED_STATUS;
        update stv;
        
        Contact con = new Contact(FirstName = 'John', LastName = 'Benson', Email = 'john.benson@bluespurs.com');
        insert con;
        
        Case c = Test_RestTestHelper.serviceRequest(stv.Id);
        c.ContactId = con.id;
        c.Service_Type_Version__c = stv.Id;
        update c;
        
        Base311_Service_Request rsq = new Base311_Service_Request();
        
        Base311_Contact rc = new Base311_Contact();
        rc.firstName = null;
        rc.lastName = null;
        rc.email = null;
        
        Test.startTest();
        try {
            Case result = rsq.updateServiceRequest(
                c.Service_Request_Number__c, Double.valueOf(10.1), Double.valueOf(11.1), 
                '', '', '', '', 'Open', new Map<String, Base311_Attribute>(), rc, new List<Base311_Activity>()
            ); 
        } 
        catch (Base311_Exceptions.UnsupportedException e) {
            System.assert(true);
            return;
        }
        
        Test.stopTest();
    }
   
    @isTest
    static void testGetSimilarCases() {
        
        Service_Type_Version__c stv = Test_RestTestHelper.sericeTypeVersionAndVersion('TEST1');
        Case c = Test_RestTestHelper.serviceRequest(stv.Id);
        Case c2 = Test_RestTestHelper.serviceRequest(stv.Id);
        
        Base311_Service_Request rsq = new Base311_Service_Request();
        List<Case> result = rsq.getSimilarCases(stv.Name);
        
        System.assertEquals(result.size(), 2);
    }
   
    @isTest
    static void testUpdateServiceRequestUpdateContact() {
        
        Test_Base311_MockLocation.setupMocks();

        Contact con = new Contact(FirstName = 'John', LastName = 'Benson', Email = 'john.benson@bluespurs.com');
        insert con;
        
        Service_Type_Version__c stv = Test_RestTestHelper.sericeTypeVersionAndVersion('TEST1');
        Case c = Test_RestTestHelper.serviceRequest(stv.Id);
        c.ContactId = con.id;
        update c;
        
        Base311_Service_Request rsq = new Base311_Service_Request();
        
        Base311_Contact rc = new Base311_Contact();
        rc.firstName = 'Mike';
        rc.lastName = 'Benson';
        rc.email = 'john.benson@bluespurs.com';
        
        Test.startTest();
        Case result = rsq.updateServiceRequest(
            c.Service_Request_Number__c, Double.valueOf(10.1), Double.valueOf(11.1), 
            '', '', '', '', 'Open', new Map<String, Base311_Attribute>(), rc, new List<Base311_Activity>()
        );
        
        System.assertEquals(result.Contact.Email, 'john.benson@bluespurs.com');
        
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateServiceRequestNoContact() {
        Service_Type_Version__c stv = Test_RestTestHelper.sericeTypeVersionAndVersion();
        Case c = Test_RestTestHelper.serviceRequest(stv.Id);
        Base311_Service_Request rsq = new Base311_Service_Request();
        
        Contact con = new Contact(FirstName = 'John', LastName = 'Benson', Email = 'john.benson@bluespurs.com', Phone = '5064704361');
        insert con;
        
        Base311_Contact rc = new Base311_Contact(con.Id, 'John', 'Benson', '5064704361', 'john.benson@bluespurs.com');
        
        Case result = rsq.updateServiceRequest(
            c.Service_Request_Number__c, null, null, 
            null, null, null, '', 'Open', new Map<String, Base311_Attribute>(), rc, new List<Base311_Activity>()
        );
        
        System.assertEquals(result.ContactId, con.Id);
    }
    
    @isTest
    static void testPatchServiceRequest() {
        Case c = Test_RestTestHelper.serviceRequest();
        Base311_Service_Request rsq = new Base311_Service_Request();
        c = rsq.patchServiceRequest(
            c.Service_Request_Number__c, new Base311_PatchValue(true, 'Closed'), 
            new Base311_PatchValue(false, 'Closed'), new Base311_PatchValue(false, 'Closed'), 
            new Base311_PatchValue(false, 'Closed'), new Base311_PatchValue(false, 'Closed'), 
            new Base311_PatchValue(false, 'Closed'), new Base311_PatchValue(false, 'Closed'), 
            new Base311_PatchValue(false, 'Closed'), new Base311_PatchValue(false, 'Closed'), 
            new Base311_PatchValue(false, 'Closed')
        );
        System.assertEquals(c.Status, 'Closed');
    }
    
    @isTest
    static void testGetServiceRequestsNone() {
        Base311_Service_Request rsq = new Base311_Service_Request();
        
        Case c = Test_RestTestHelper.serviceRequest();
        Case c2 = Test_RestTestHelper.serviceRequest();
        
        List<Case> cases = rsq.getServiceRequests(new List<String>{ 'abc123notareal' });
         
        System.assertEquals(cases.size(), 1);
        System.assertEquals(cases[0].Id, null);
        System.assertEquals(cases[0].Service_Request_Number__c, 'abc123notareal');
        System.assertEquals(cases[0].Status, 'Not Found');
    }
    
    @isTest
    static void testGetServiceRequestsByUpdatedStartDate() {
        Base311_Service_Request rsq = new Base311_Service_Request();
        
        Case c = Test_RestTestHelper.serviceRequest(null, DateTime.newInstance(2000, 1, 2));
        c.Updated_Date_Time__c = DateTime.newInstance(2000, 1, 2);
        update c;
        Case c2 = Test_RestTestHelper.serviceRequest(null, DateTime.newInstance(2000, 1, 3));
        c2.Updated_Date_Time__c = DateTime.newInstance(2000, 1, 3);
        update c2;
        
        List<Case> cases = rsq.getServiceRequests(new List<String>(), null, null, Datetime.newInstance(2000, 1, 3), null, new List<String>(), new List<String>());
        
        System.assertEquals(cases.size(), 1);
        System.assertEquals(cases[0].Id, c2.Id);
    }
    
    @isTest
    static void testGetServiceRequestsByUpdatedEndDate() {
        Base311_Service_Request rsq = new Base311_Service_Request();
        
        Case c = Test_RestTestHelper.serviceRequest(null, DateTime.newInstance(2000, 1, 2));
        c.Updated_Date_Time__c = DateTime.newInstance(2000, 1, 2);
        update c;
        Case c2 = Test_RestTestHelper.serviceRequest(null, DateTime.newInstance(2000, 1, 3));
        c2.Updated_Date_Time__c = DateTime.newInstance(2000, 1, 3);
        update c2;
        
        List<Case> cases = rsq.getServiceRequests(new List<String>(), null, null, null, Datetime.newInstance(2000, 1, 2), new List<String>(), new List<String>());
        
        System.assertEquals(cases.size(), 1);
        System.assertEquals(cases[0].Id, c.Id);
    }
    
    @isTest
    static void testGetServiceRequestsByEndDate() {
        Base311_Service_Request rsq = new Base311_Service_Request();
        
        Case c = Test_RestTestHelper.serviceRequest(null, DateTime.newInstance(2000, 1, 2));
        Case c2 = Test_RestTestHelper.serviceRequest(null, DateTime.newInstance(2000, 1, 3));
        
        List<Case> cases = rsq.getServiceRequests(new List<String>(), null, Datetime.newInstance(2000, 1, 2));
        
        System.assertEquals(cases.size(), 1);
        System.assertEquals(cases[0].Id, c.Id);
    }
    
    
    
    @isTest
    static void testGetServiceRequestsByServiceCode() {
        Base311_Service_Request rsq = new Base311_Service_Request();
        
        Service_Type_Version__c stv = Test_RestTestHelper.sericeTypeVersionAndVersion('TEST1');
        Case c = Test_RestTestHelper.serviceRequest(stv.Id);
        Case c2 = Test_RestTestHelper.serviceRequest();
        
        List<Case> cases = rsq.getServiceRequests(new List<String>(), null, null, new List<String>(), new List<String>{ stv.Name });
        
        System.assertEquals(cases.size(), 1);
        System.assertEquals(cases[0].Id, c.Id);
    }  
    
    @isTest
    static void testGetServiceRequestsByStatus() {
        Base311_Service_Request rsq = new Base311_Service_Request();
        
        Case c = Test_RestTestHelper.serviceRequest(null, null, 'New');
        Case c2 = Test_RestTestHelper.serviceRequest(null, null, 'Closed');
        
        List<Case> cases = rsq.getServiceRequests(new List<String>(), null, null, new List<String>{ 'New' });
        
        System.assertEquals(cases.size(), 1);
        System.assertEquals(cases[0].Id, c.Id);
    }
    
    @isTest
    static void testGetServiceRequestsByStartDate() {
        Base311_Service_Request rsq = new Base311_Service_Request();
        
        Case c = Test_RestTestHelper.serviceRequest(null, DateTime.newInstance(2000, 1, 2));
        Case c2 = Test_RestTestHelper.serviceRequest(null, DateTime.newInstance(2000, 1, 3));
        
        List<Case> cases = rsq.getServiceRequests(new List<String>(), Datetime.newInstance(2000, 1, 3), null);
        
        System.debug(c);
        System.debug(c2);
        
        System.assertEquals(cases.size(), 1);
        System.assertEquals(cases[0].Id, c2.Id);
    }
    
    @isTest
    static void testGetServiceRequestsByServiceRequestId() {
        Base311_Service_Request rsq = new Base311_Service_Request();
        
        
        Case c = Test_RestTestHelper.serviceRequest();
        Case c2 = Test_RestTestHelper.serviceRequest();
        
        List<Case> cases = rsq.getServiceRequests(new List<String>{ c.Service_Request_Number__c });
        
        System.assertEquals(cases.size(), 1);
        System.assertEquals(cases[0].Id, c.Id);
    }
    
    @isTest
    static void testGetServiceRequestsAll() {
        Base311_Service_Request rsq = new Base311_Service_Request();
        
        Case c = Test_RestTestHelper.serviceRequest();
        
        List<Case> cases = rsq.getServiceRequests(new List<String>());
        
        System.assertEquals(cases.size(), 1);
        System.assertEquals(cases[0].Id, c.Id);
    }
    
    @isTest
    static void testGetServiceRequest() {       
        Base311_Service_Request rsq = new Base311_Service_Request();
        Case c = Test_RestTestHelper.serviceRequest();
        
        Case found = rsq.getServiceRequest(c.Service_Request_Number__c);
        
        System.assertEquals(found.Id, c.Id);
    }
    
    @isTest
    static void testGetServiceRequestEmpty() {      
        Base311_Service_Request rsq = new Base311_Service_Request();
        
        Case c = rsq.getServiceRequest('dne');
        
        System.assertEquals(c, null);
    }
    
    @isTest
    static void testCreateServiceRequestPartialContact() {
        Test_Base311_MockLocation.setupMocks();
        
        Base311_Service_Request rsq = new Base311_Service_Request();
        
        Service_Type_Version__c stv = Test_RestTestHelper.sericeTypeVersionAndVersion('TEST1');
        update stv;
        
        Test.startTest();
        
        try {
            Case c = rsq.createServiceRequest(
                null,  null, 'https://google.ca', null,
                null, stv.Name, 'Test description', new Map<String, Base311_Attribute>(),
                'John', null, null, null, 'API', 'Public'
            );
        } 
        catch (Base311_Exceptions.UnsupportedException e) {
            System.assert(true);
            return;
        }
        
        System.assert(false, 'Contact status was partially provided but we passed');
        
        Test.stopTest();
    }
    
    @isTest
    static void testCreateServiceRequestContactRequired() {
        Test_Base311_MockLocation.setupMocks();
        
        Base311_Service_Request rsq = new Base311_Service_Request();
        
        Service_Type_Version__c stv = Test_RestTestHelper.sericeTypeVersionAndVersion('TEST1');
        stv.Override_Contact_Status__c = Base311_Contact.CONTACT_REQUIRED_STATUS;
        update stv;
        
        Test.startTest();
        
        try {
            Case c = rsq.createServiceRequest(
                null,  null, 'https://google.ca', null,
                null, stv.Name, 'Test description', new Map<String, Base311_Attribute>(),
                null, null, null, null, 'API', 'Public'
            );
        } 
        catch (Base311_Exceptions.UnsupportedException e) {
            System.assert(true);
            return;
        }
        
        System.assert(false, 'Contact status was required but we passed');
        
        Test.stopTest();
    }
    
    @isTest
    static void testCreateServiceRequest() {
        Test_Base311_MockLocation.setupMocks();
        
        Base311_Service_Request rsq = new Base311_Service_Request();
        
        Service_Type_Version__c stv = Test_RestTestHelper.sericeTypeVersionAndVersion('TEST1');

        Test.startTest();
        
        Case c = rsq.createServiceRequest(
            null,  null, 'https://google.ca', null,
            null, stv.Name, 'Test description', new Map<String, Base311_Attribute>(),
            'John', 'Benson', 'john.benson@bluespurs.com', '5064704361', 'API', 'Public'
        );
        
        Case found = [SELECT Id, Location__Latitude__s, Location__Longitude__s, Media_Url__c FROM Case WHERE Id = :c.Id];
        
        System.assertEquals(found.Media_Url__c, 'https://google.ca');
        Test.stopTest();
    }
    
    @isTest
    static void testDaysOfWeekInvalid() {
        Test_Base311_MockLocation.setupMocks();
        
        Base311_Service_Request rsq = new Base311_Service_Request();
        
        Service_Type_Version__c stv = Test_RestTestHelper.sericeTypeVersionAndVersion('TEST1');
        stv.Days_Of_Week__c = Datetime.now().addDays(2).format('EEEE');
        update stv;
        
        Test.startTest();
        
        try {
            Case c = rsq.createServiceRequest(
                null,  null, 'https://google.ca', null,
                null, stv.Name, 'Test description', new Map<String, Base311_Attribute>(),
                'John', 'Benson', 'john.benson@bluespurs.com', '5064704361', 'API', 'Public'
            );
        } catch (Base311_Exceptions.UnsupportedException ue) {
            System.assert(true);
            return;
        }
        
        System.assert(false);
        Test.stopTest();
    }

    @isTest
    static void testSearchServiceRequests() {
        Test_Base311_MockLocation.setupMocks();
        
        Base311_Service_Request rsq = new Base311_Service_Request();
        
        Service_Type_Version__c stv = Test_RestTestHelper.sericeTypeVersionAndVersion('TEST1');

        Case c = rsq.createServiceRequest(
            null,  null, null, null,
            null, stv.Name, 'Test description', new Map<String, Base311_Attribute>(),
            'Matt', 'Darkis', 'matt.darkis@bluespurs.com', '5069999999', 'API', 'Public'
        );

        System.assertEquals(0, (rsq.searchServiceRequests('00')).size());

        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = c.Id;
        Test.setFixedSearchResults(fixedSearchResults);

        System.assertNotEquals(0, (rsq.searchServiceRequests('00')).size());
    }

}