public with sharing class Console311_Section_ContactandUserField extends Console311_ComponentControllerBase {
    private Incap311Console__Console311_Lookup_Config__mdt lookupConfigSosl;
    private Map<String, String> mStates { get; set; }
    
    //public List<> mLayoutConfig { get; set; }
    public String mContactId { get; set; }
    public String Name { get; set; }
    public String Email { get; set; }
    public Map<String, Map<String, Map<String, String>>> sObjectFieldUtilMap { get; set; }
    public Map<String, Map<String, String>> mSobjFieldUtilMapByName { get; set; }
    public List<Console311_Wrap_Config> mLayoutConfig { get; set; }
    
    public Console311_Section_ContactandUserField() {
        setmContact((sobject)new Contact());
        this.lookupConfigSosl = [Select Incap311Console__New_Record_Layout__c, Incap311Console__Search_Layout__c, Incap311Console__Search_Result_Layout__c From Incap311Console__Console311_Lookup_Config__mdt Where MasterLabel = 'contactAndUser'];
        //this.mLayoutConfig = [Select QualifiedApiName, Incap311Console__Visible__c, Incap311Console__Header__c, Incap311Console__Collapsible__c, Incap311Console__Title__c, MasterLabel, DeveloperName From Incap311Console__Console_311_Layout_Setting__mdt];
        
        if (String.isNotBlank(this.mContactId)) {
            this.feedContactInformationToPage(this.mContactId);
        }
    }
    
    private Sobject mContactPrivate;
    public void setmContact(sobject so){
        mContactPrivate = so;
        if(mContactPrivate!= null){
        if(mContactPrivate.get('FirstName') != null){
            this.name = (String)mContactPrivate.get('FirstName')+' ';
        }else{
            this.name = '';
                }
        if(mContactPrivate.get('LastName') != null){
            this.name = this.name+(String)mContactPrivate.get('LastName');
        }
        if(mContactPrivate.get('email') != null){
            this.email = (String)mContactPrivate.get('email');
        }
        }
    }
    
    public Sobject getmContact(){
        return mContactPrivate;
    }
    
    public string getPhone(){
        if(mContactPrivate != null){
         return (String)mContactPrivate.get('phone');
        }
        return '';
    }
    
    public Sobject feedContactInformationToPage() {
        Contact lContact = (Contact) JSON.deserialize(ApexPages.currentPage().getParameters().get('contactJson'), Contact.class);
        return (sobject)this.feedContactInformationToPage(lContact);
    }
    
    public sobject feedContactInformationToPage(String contactId) {
        setmContact((sobject)[Select Id, Name, FirstName, LastName, Phone, Email, MailingStreet, MailingCity, MailingState, MailingPostalCode From Contact Where Id = :contactId]);
        return getmContact();
    }  
    
    public sobject feedContactInformationToPage(Contact lContact) {
        setmContact((sobject)[Select Id, Name, FirstName, LastName, Phone, Email, MailingStreet, MailingCity, MailingState, MailingPostalCode From Contact Where Id = :lContact.Id]);
        return getmContact();
    }
    
    public Map<String, String> getStatesMap() {
        if (this.mStates == null) {
            this.mStates = Console311_Util.getStateByStateCodeMap();
        }
        return this.mStates;
    }
    
    public String getDefaultStateOnExisitingContact() {
        // TODO: Grab from the custom setting the org value for the mailing state. 
        Map<String, Incap311__Jurisdiction__c> jurisdictionList = Incap311__Jurisdiction__c.getAll();
        
        if (jurisdictionList != null && jurisdictionList.size() == 1) {
            for (String key : jurisdictionList.keySet()) {
                return jurisdictionList.get(key).Incap311__State_Code__c;
            }
        }
        return '';
    }
    
    public List<String> getFieldNamesList() {
        /*if (this.mContact != null && lookupConfigSosl.Incap311Console__Search_Layout__c != null) {
this.sObjectFieldUtilMap = Console311_Util.formatSobjectDataUtilMap(new List<Contact> { mContact }, 'contact', lookupConfigSosl.Incap311Console__Search_Layout__c);
return new List<String>(sObjectFieldUtilMap.get(this.mContact.Id).keySet());
}*/
        return new List<String>();
    }
    
    public List<String> getNewEditFieldNamesList() {
        System.debug('----> getNewEditFieldNamesList: Start');
        System.debug('----> [getNewEditFieldNamesList] lookupConfigSosl.Incap311Console__New_Record_Layout__c: ' + lookupConfigSosl.Incap311Console__New_Record_Layout__c);
        
        if (lookupConfigSosl.Incap311Console__New_Record_Layout__c != null) {
            this.mSobjFieldUtilMapByName = Console311_Util.retrieveObjFieldNameListByLayoutConfiguration('contactanduser', lookupConfigSosl.Incap311Console__New_Record_Layout__c);
            System.debug('----> [getNewEditFieldNamesList] mSobjFieldUtilMapByName: ' + this.mSobjFieldUtilMapByName);
            return new List<String>(mSobjFieldUtilMapByName.keySet());
        }
        return new List<String>();
    }
    
    public Incap311Console__Console_311_Layout_Setting__mdt getInformationLayoutConfig() {
        if (this.mLayoutConfig != null) {
            for (Console311_Wrap_Config config : this.mLayoutConfig) {
                if ((config.mName).equalsIgnoreCase('contact_information')) {
                    return (Incap311Console__Console_311_Layout_Setting__mdt) JSON.deserialize(config.mObjJson, Incap311Console__Console_311_Layout_Setting__mdt.class);
                } 
            }
        }
        return null;
    }
    
    public Incap311Console__Console_311_Layout_Setting__mdt getNewEditLayoutConfig() {
        if (this.mLayoutConfig != null) {
            for (Console311_Wrap_Config config : this.mLayoutConfig) {
                System.debug('----> Searching for NewEdit Config - Processing: ' + config);
                if ((config.mName).equalsIgnoreCase('new_edit_contact')) {
                    return (Incap311Console__Console_311_Layout_Setting__mdt) JSON.deserialize(config.mObjJson, Incap311Console__Console_311_Layout_Setting__mdt.class);
                } 
            }
        }
        return null;
    }
}