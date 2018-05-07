/**
* @author 
* @date 
* @group 
* @group-content
* @description 
*/
global class Base311_Service_Contact {

    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global Contact upsertContact(Base311_Contact rc) {
        
        List<String> fields = new List<String>{ 'FirstName', 'LastName', 'Email', 'Phone' };
    
        if(!Base311_Security.areAccessible(Contact.SObjectType, fields)) {
            throw new Base311_Exceptions.SecurityException('User does not have access to update Contact');
        } 
        
        Contact updated = new Contact(
            Id = rc.id, FirstName = rc.firstName, LastName = rc.lastName, 
            Email = rc.email, Phone = rc.phone
        );
        
        upsert updated;
        return updated;
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global Contact updateContactAddressInformation(Id contactId, String street, String city, String state, String postal) {
      if (contactId != null) {
        List<Contact> cs = [SELECT FirstName, LastName, Phone, Email, MailingStreet, MailingCity, MailingState, MailingPostalCode FROM Contact WHERE Id = :contactId];

        if (cs.size() > 0) {
          Contact c = cs[0];
          c.MailingStreet = street;
          c.MailingCity = city;
          c.MailingState = state;
          c.MailingPostalCode = postal;
          upsert c;
          return c;
        }
      }
      return null;
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global Contact patchContact(Id contactId, Base311_PatchValue con) {
        List<Contact> cs = [SELECT FirstName, LastName, Phone, Email FROM Contact WHERE Id = :contactId];
        
        Contact c = cs.size() > 0 ? cs[0] : new Contact();
     
        Base311_PatchValue firstName = Base311_PatchValue.fromPatchValue(con, 'first_name');
        Base311_PatchValue lastName = Base311_PatchValue.fromPatchValue(con, 'last_name');
        Base311_PatchValue email = Base311_PatchValue.fromPatchValue(con, 'email');
        Base311_PatchValue phone = Base311_PatchValue.fromPatchValue(con, 'phone');
        
        Base311_Contact rc = new Base311_Contact(
            (String) firstName.value, (String) lastName.value, (String) phone.value,  (String) email.value
        );
        
        c.Id = contactId;
        
        List<String> fields = new List<String>{ 'FirstName', 'LastName', 'Email', 'Phone' };
    
        if(!Base311_Security.areCreateable(Contact.SObjectType, fields)) {
            throw new Base311_Exceptions.SecurityException('User does not have access to update Contact');
        } 
        
        if(contactId == null) {
            rc.validate().throwErrors();
        }
        
        if(firstName.isSet) {
            c.FirstName = String.valueOf(rc.firstName);
        }
        
        if(lastName.isSet) {
            c.LastName = String.valueOf(rc.lastName);
        }
        
        if(email.isSet) {
            c.Email = String.valueOf(rc.email);
        }
        
        if(phone.isSet) {
            c.Phone = String.valueOf(rc.phone);
        }
        
        upsert c; 
        
        return c;
    }
}