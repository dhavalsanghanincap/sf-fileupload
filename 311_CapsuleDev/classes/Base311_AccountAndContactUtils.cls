/**
* @author John Benson
* @date 5/10/2017
* @group util
* @group-content
* @description This class provides seach capabilities for matching contacts and accounts based on different criteria (name, email, etc.)
*/

global without sharing class Base311_AccountAndContactUtils {

    /**
    * @description searches for contact match based on email
    * @param email is email address of comtact
    * @return contact record 
    * @example
    */
    global static Contact findContactByEmail(String email) {
        if (String.isNotBlank(email)) {
            List<Contact> contacts = [SELECT Id, FirstName, LastName, Phone, Email, MailingStreet, MailingCity, MailingState, MailingPostalCode FROM Contact where Email = :email];
            if ((contacts != null) && (contacts.size() > 0)) {
                return contacts[0];
            }
        }
        return null;
    }
    
    /**
    * @description Find contact by email
    * @param email is email address of comtact
    * @return contact record
    * @example
    */
    @deprecated
    global static Contact findContactByEmailExtended(String email) {
        return null;
    }
    
    /**
    * @description searches for contact match based on phone numbers
    * @param phone is string value of phone number
    * @return Contact record
    * @example 
    */ 
    global static Contact findContactByPhone(String phone) {
        if (String.isNotBlank(phone)) {
            List<Contact> contacts = [SELECT Id, FirstName, LastName, Phone, Email, MailingStreet, MailingCity, MailingState, MailingPostalCode FROM Contact WHERE Phone = :phone OR OtherPhone = :phone OR HomePhone = :phone];
            if ((contacts != null) && (contacts.size() > 0)) {
                return contacts[0];
            }
        }
        return null;
    }
    
    /**
    * @description searches for contact match based on first and last name
    * @param firstName is string value of contact first name
    * @param lastname is string value of contact first name
    * @return Contact record
    * @example 
    */
    global static Contact findContactByName(String firstName, String lastName) {
        if (String.isNotBlank(firstName) && String.isNotBlank(lastName)) {
            List<Contact> contacts = [SELECT Id, FirstName, LastName, Phone, Email, MailingStreet, MailingCity, MailingState, MailingPostalCode FROM Contact WHERE FirstName = :firstName AND LastName = :lastName];
            if ((contacts != null) && (contacts.size() > 0)) {
                return contacts[0];
            }
        }
        return null;
    }
    
    /**
    * @description searches using all criteria, prioritized by email, then phone, then name
    * @param firstName is string value of contact first name
    * @param lastname is string value of contact first name
    * @param phone is string value of phone number
    * @param email is string value of email
    * @return Contact record
    * @example
    */
    // 
    global static Contact findContact(String firstName, String lastName, String phone, String email) {
        
        
        Contact c = findContactByEmail(email);
        if (c != null) {
            return c;
        } 

        c = findContactByPhone(phone);
        if (c != null) {
            return c;
        }

        c = findContactByName(firstName, lastName);
        if (c != null) {
            return c;
        }

        return c;
    }
    
    /**
    * @description Method to find contact based on string
    * @param terms is csv string
    * @return list of contact
    * @example
    */
    global static List<Contact> searchContacts(String terms) {
        String findTerms = String.join(Base311_Helper.csvToList(terms), ' OR ');
        
        List<List<Sobject>> items = [
            FIND :findTerms
            IN ALL FIELDS
            RETURNING Contact (Id, FirstName, LastName, Phone, Email, MailingStreet, MailingCity, MailingState, MailingPostalCode)
        ];
        
        if(items.size() > 0) {
            return (List<Contact>) items.get(0);
        }
        
        return new List<Contact>();
    }
    
    /**
    * @description searches for accouint match based on name
    * @param acctName is account name
    * @return Account record
    * @example
    */
    global static Account findAccountByName(String acctName) {
        if (acctName != null) {
            List<Account> accounts = [SELECT Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode FROM Account where Name = :acctName];
            if ((accounts != null) && (accounts.size() > 0)) {
                return accounts[0];
            }
        }
        return null;
    }

    /**
    * @description searches for accouint match based on csv string
    * @param terms is csv string
    * @return list of account
    * @example
    */
    global static List<Account> searchAccounts(String terms) {
        String findTerms = String.join(Base311_Helper.csvToList(terms), ' OR ');
        
        List<List<Sobject>> items = [
            FIND :findTerms
            IN ALL FIELDS
            RETURNING Account (Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode)
        ];
        
        if(items.size() > 0) {
            return (List<Account>) items.get(0);
        }
        
        return new List<Account>();
    }
}