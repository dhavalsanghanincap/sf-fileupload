public with sharing class Console311_Section_ContactCtrl extends Console311_ComponentControllerBase {
    private Incap311Console__Console311_Lookup_Config__mdt lookupConfigSosl;
    private Map<String, String> mStates { get; set; }

    //public List<> mLayoutConfig { get; set; }
    public Contact mContact { get; set; }
    public String mContactId { get; set; }
    public Map<String, Map<String, Map<String, String>>> sObjectFieldUtilMap { get; set; }
    public Map<String, Map<String, String>> mSobjFieldUtilMapByName { get; set; }
    public List<Console311_Wrap_Config> mLayoutConfig { get; set; }

    public Console311_Section_ContactCtrl() {
        this.mContact = new Contact();
        this.lookupConfigSosl = [Select Incap311Console__New_Record_Layout__c, Incap311Console__Search_Layout__c, Incap311Console__Search_Result_Layout__c From Incap311Console__Console311_Lookup_Config__mdt Where MasterLabel = 'Contact'];
        //this.mLayoutConfig = [Select QualifiedApiName, Incap311Console__Visible__c, Incap311Console__Header__c, Incap311Console__Collapsible__c, Incap311Console__Title__c, MasterLabel, DeveloperName From Incap311Console__Console_311_Layout_Setting__mdt];

        if (String.isNotBlank(this.mContactId)) {
            this.feedContactInformationToPage(this.mContactId);
        }
    }

    public Contact feedContactInformationToPage() {
        Contact lContact = (Contact) JSON.deserialize(ApexPages.currentPage().getParameters().get('contactJson'), Contact.class);
        return this.feedContactInformationToPage(lContact);
    }

    public Contact feedContactInformationToPage(String contactId) {
        String query = 'Select Id,Name, MailingState, ' + String.join(getFieldNamesList(),',');
        query += ' From contact Where Id = :contactId';
        return database.query(query);
    }  

    public Contact feedContactInformationToPage(Contact contact) {
        return feedContactInformationToPage(contact.id);
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
        if (this.mContact != null && lookupConfigSosl.Incap311Console__Search_Layout__c != null) {
            this.sObjectFieldUtilMap = Console311_Util.formatSobjectDataUtilMap(new List<Contact> { mContact }, 'contact', lookupConfigSosl.Incap311Console__Search_Layout__c);
            return new List<String>(sObjectFieldUtilMap.get(this.mContact.Id).keySet());
        }
        return new List<String>();
    }

    public List<String> getNewEditFieldNamesList() {
        System.debug('----> getNewEditFieldNamesList: Start');
        System.debug('----> [getNewEditFieldNamesList] lookupConfigSosl.Incap311Console__New_Record_Layout__c: ' + lookupConfigSosl.Incap311Console__New_Record_Layout__c);

        if (lookupConfigSosl.Incap311Console__New_Record_Layout__c != null) {
            this.mSobjFieldUtilMapByName = Console311_Util.retrieveObjFieldNameListByLayoutConfiguration('contact', lookupConfigSosl.Incap311Console__New_Record_Layout__c);
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