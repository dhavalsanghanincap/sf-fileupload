@isTest
public class Test_Base311_Service_Contact {

	@isTest
    static void testUpdateContactAddressInformation() {
        Contact c = Test_RestTestHelper.contact();
        
        Base311_Service_Contact rsc = new Base311_Service_Contact();
        rsc.updateContactAddressInformation(c.Id, '50 Boyne', 'Fredericton', 'NB', 'E3B0S5');
        
        c = [SELECT MailingStreet, MailingCity, MailingState, MailingPostalCode FROM Contact WHERE Id = :c.Id];
        
        System.assertEquals(c.MailingStreet, '50 Boyne');
        System.assertEquals(c.MailingCity, 'Fredericton');
        System.assertEquals(c.MailingState, 'NB');
        System.assertEquals(c.MailingPostalCode, 'E3B0S5');
    }

    @isTest
    static void testPatchContact() {
        Base311_Service_Contact rsc = new Base311_Service_Contact();
        Contact c = Test_RestTestHelper.contact();
        Base311_PatchValue pv = new Base311_PatchValue(true, new Map<String, String>{
            'first_name' => 'Test',
            'last_name' => 'Benson',
            'email' => 'john.benson@bluespurs.com'
        });
        Contact result = rsc.patchContact(c.Id, pv);
        
        System.assertEquals(result.FirstName, 'Test');
        System.assertEquals(result.LastName, 'Benson');
        System.assertEquals(result.Email, 'john.benson@bluespurs.com');
    }
    
}