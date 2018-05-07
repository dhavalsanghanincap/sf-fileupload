/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class Test_Base311_AccountAndContactUtils {

    static void createTestData() {
        Account testAcct = new Account(Name = 'Acme', Phone = '555-555-5555', BillingStreet = '123 Main Street');
        insert testAcct;
        
        Contact testContact = new Contact(FirstName = 'John', LastName = 'Smith', Phone = '(202) 555-1234', Email = 'jsmithtest@test.com');
        insert testContact;
        
        Contact testContact2 = new Contact(FirstName = 'Mike', LastName = 'Frank', Phone = '', Email = 'mfrank@test.com');
        insert testContact2;
    }

    static testMethod void testFindContactByEmail() {
        createTestData();
        
        Test.startTest();
        Contact c = Base311_AccountAndContactUtils.findContactByEmail('jsmithtest@test.com');
        System.assert(c != null);
        
        c = Base311_AccountAndContactUtils.findContactByEmail('jsmithtest@demo.com');
        System.assert(c == null);
        
        c = Base311_AccountAndContactUtils.findContactByEmail(null);
        System.assert(c == null);
        
        c = Base311_AccountAndContactUtils.findContactByEmail('');
        System.assert(c == null);
        Test.stopTest();
    }
    
    static testMethod void testFindContactByPhone() {
        createTestData();
        
        Test.startTest();
        Contact c = Base311_AccountAndContactUtils.findContactByPhone('(202) 555-1234');
        System.assert(c != null);
        
        c = Base311_AccountAndContactUtils.findContactByPhone('(123) 456-7890');
        System.assert(c == null);
        
        c = Base311_AccountAndContactUtils.findContactByPhone(null);
        System.assert(c == null);
        
        c = Base311_AccountAndContactUtils.findContactByPhone('');
        System.assert(c == null);
        
        Test.stopTest();
    }
    
    static testMethod void testFindContactByName() {
        createTestData();
        
        Test.startTest();
        Contact c = Base311_AccountAndContactUtils.findContactByName('John', 'Smith');
        System.assert(c != null);
        
        c = Base311_AccountAndContactUtils.findContactByName('James', 'Dean');
        System.assert(c == null);
        
        c = Base311_AccountAndContactUtils.findContactByName(null, null);
        System.assert(c == null);
        
        c = Base311_AccountAndContactUtils.findContactByName('', null);
        System.assert(c == null);
        
        c = Base311_AccountAndContactUtils.findContactByName(null, '');
        System.assert(c == null);
        
        c = Base311_AccountAndContactUtils.findContactByName('', '');
        System.assert(c == null);
        Test.stopTest();
    }
    
    static testMethod void testFindContact() {
        createTestData();
        
        Test.startTest();
        Contact c = Base311_AccountAndContactUtils.findContact('John', 'Smith', '(202) 555-1234', 'jsmithtest@test.com');
        System.assert(c != null);
        
        c = Base311_AccountAndContactUtils.findContact('John', 'Smith', '(202) 555-1234', null);
        System.assert(c != null);
        
        c = Base311_AccountAndContactUtils.findContact('John', 'Smith', null, null);
        System.assert(c != null);
        
        c = Base311_AccountAndContactUtils.findContact(null, null, null, null);
        System.assert(c == null);
        
        c = Base311_AccountAndContactUtils.findContact('', '', '', '');
        System.assert(c == null);
        
        Test.stopTest();
    }
    
    static testMethod void testFindAccountByName() {
        createTestData();
        
        Test.startTest();
        Account a = Base311_AccountAndContactUtils.findAccountByName('Acme');
        System.assert(a != null);
        
        a = Base311_AccountAndContactUtils.findAccountByName('Sony');
        System.assert(a == null);
        
        a = Base311_AccountAndContactUtils.findAccountByName(null);
        System.assert(a == null);
        
        a = Base311_AccountAndContactUtils.findAccountByName('');
        System.assert(a == null);
        
        Test.stopTest();
    }
}