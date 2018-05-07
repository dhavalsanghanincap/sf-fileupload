/**
* @author John Benson 
* @date 10/26/2016   
* @group 
* @group-content
* @description 
*/
global class Base311_Contact extends Base311_Object {

    global String id;
    global String firstName;
    global String lastName;
    global String phone;
    global String email;
    global Boolean required;
    
    /**
    * @description Method to check if the contact name is defined partially or not
    * @param none
    * @return TRUE or FALSE
    * @example
    */
    private Boolean partiallyDefined() {
        return (!String.isEmpty(lastName) || !String.isEmpty(firstName) || !String.isEmpty(email)) && 
        (String.isEmpty(firstName) || String.isEmpty(lastName) || String.isEmpty(email));
    }
    
    global static String CONTACT_REQUIRED_STATUS = 'Required (LN, FN, EM)';
    
    global Base311_Contact() {
        
    }
    
    /**
    * @description Method to validate if firstname,lastname and email are populated or not
    * @param None
    * @return TRUE or False
    * @example
    */
    public Boolean canCreate() {
        return !String.isEmpty(firstName) && !String.isEmpty(lastName) && !String.isEmpty(email);
    }
    
    global Base311_Contact(String id, String firstName, String lastName, String phone, String email) {
        this.id = id;
        this.firstName = firstName;
        this.lastName = lastName;
        this.phone = phone;
        this.email = email;
    }
    
    global Base311_Contact(String firstName, String lastName, String phone, String email) {
        this(null, firstName, lastName, phone, email);
        
        this.id = this.findId();
    }
    
    global Base311_Contact setRequired(Service_Type_Version__c stv) {
        this.required = stv == null ? false : stv.Contact_Status__c == CONTACT_REQUIRED_STATUS;
        
        return this;
    }
    
    /**
    * @description Method to find contact id 
    * @param None
    * @return ID
    * @example
    */
    global Id findId() {
        Contact foundContact = Base311_AccountAndContactUtils.findContact(firstName, lastName, phone, email);
        this.id = foundContact != null ? foundContact.Id : null;
        return this.id;
    }
    
    /**
    * @description Method to validate contact information
    * @param none
    * @return void
    * @example
    */
    global override void validation() {
        Boolean isRequired = required == null ? false : required;
    
        if(partiallyDefined()) {
            this.addError('Contact information cannot be partially defined. You must provide first_name, last_name and email, or none of them.');
        }
    
        if(isRequired && firstName == null) {
            this.addError('First name is required');
        }
        
        if(isRequired && lastName == null) {
            this.addError('Last name is required');
        }
        
        if(isRequired && email == null) {
            this.addError('Email is required');
        }
    }
    
    /**
    * @description Method to get contact from map
    * @param Map<String, Object> values
    * @return Base311_Contact
    * @example
    */
    global static Base311_Contact fromMap(Map<String, Object> values) {
        Base311_Contact rc = new Base311_Contact(
            null, String.valueOf(values.get('first_name')),
            String.valueOf(values.get('last_name')), String.valueOf(values.get('phone')),
            String.valueOf(values.get('email'))
        );
        
        return rc;
    }
    
}