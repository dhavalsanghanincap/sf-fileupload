public with sharing class Console_Section_ConfiguredLayoutCtrl {
  private Incap311Console__Console311_Lookup_Config__mdt lookupConfigSosl;

  public Map<String, Map<String, Map<String, String>>> sObjectFieldUtilMap { get; set; }
  public Map<String, Map<String, String>> mSobjFieldUtilMapByName { get; set; }
  public Map<String, List<SelectOption>> mObjPicklistValuesByFieldName { get; set; }

  public sObject mObj { get; set; }
  public String mObjName { get; set; }
  public List<Incap311Console__Console_311_Layout_Setting__mdt> mLayoutConfig { get; set; }

  public Console_Section_ConfiguredLayoutCtrl() {
    this.mObjPicklistValuesByFieldName = new Map<String, List<SelectOption>>();
    
    // TODO: Update this to filter based on object name for sections. Possible new field or guidelines for naming of sections.
    this.mLayoutConfig = [
      Select 
        QualifiedApiName, 
        Incap311Console__Visible__c, 
        Incap311Console__Header__c, 
        Incap311Console__Collapsible__c, 
        Incap311Console__Title__c, 
        MasterLabel, 
        DeveloperName 
      From 
        Incap311Console__Console_311_Layout_Setting__mdt
    ];
  }

  public Map<String, String> getStatesMap() {
    return Console311_Util.getStateByStateCodeMap();
  }

  public List<String> getFieldNamesList() {
    buildConfiguration();

    if (this.mObj != null && lookupConfigSosl != null && lookupConfigSosl.Incap311Console__Search_Layout__c != null) {
      this.sObjectFieldUtilMap = Console311_Util.formatSobjectDataUtilMap(new List<sObject> { mObj }, mObjName, lookupConfigSosl.Incap311Console__Search_Layout__c);
      return new List<String>(sObjectFieldUtilMap.get(this.mObj.Id).keySet());
    }
    return new List<String>();
  }

  public List<String> getNewEditFieldNamesList() {
    buildConfiguration();

    // TODO: Take the mObjPicklistValuesByFieldName and fill it using the generated picklist values..
    //       from the layout field config return. They will need to be unserialized JSON cast to List<Schema.PicklistEntry>.
    //       States are still unable to be processed from the generic obj. Grab the pre-generated list and use it instead.

    System.debug('----> getNewEditFieldNamesList: Start');
    if (lookupConfigSosl != null && lookupConfigSosl.Incap311Console__New_Record_Layout__c != null) {
      this.mSobjFieldUtilMapByName = Console311_Util.retrieveObjFieldNameListByLayoutConfiguration('contact', lookupConfigSosl.Incap311Console__New_Record_Layout__c);
      System.debug('----> [getNewEditFieldNamesList] mSobjFieldUtilMapByName: ' + this.mSobjFieldUtilMapByName);
      return new List<String>(mSobjFieldUtilMapByName.keySet());
    }
    return new List<String>();
  }

  public Incap311Console__Console_311_Layout_Setting__mdt getInformationLayoutConfig() {
    if (this.mLayoutConfig != null) {
      for (Incap311Console__Console_311_Layout_Setting__mdt config : this.mLayoutConfig) {
        if ((config.DeveloperName).equalsIgnoreCase('contact_information')) {
          return config;
        } 
      }
    }
    return null;
  }

  public Incap311Console__Console_311_Layout_Setting__mdt getNewEditLayoutConfig() {
    if (this.mLayoutConfig != null) {
      for (Incap311Console__Console_311_Layout_Setting__mdt config : this.mLayoutConfig) {
        System.debug('----> Searching for NewEdit Config - Processing: ' + config);
        if ((config.DeveloperName).equalsIgnoreCase('new_edit_contact')) {
          return config;
        } 
      }
    }
    return null;
  }

  private void buildConfiguration() {
    if (this.lookupConfigSosl == null) {
      List<Incap311Console__Console311_Lookup_Config__mdt> configList = [
        Select 
          Incap311Console__New_Record_Layout__c, 
          Incap311Console__Search_Layout__c, 
          Incap311Console__Search_Result_Layout__c 
        From 
          Incap311Console__Console311_Lookup_Config__mdt 
        Where 
          MasterLabel = :this.mObjName
      ];
      System.debug('----> mObjName: ' + this.mObjName);
      System.debug('----> configList: ' + configList);

      if (configList.size() > 0) {
        this.lookupConfigSosl = configList.get(0);
      }
    }
  }
}