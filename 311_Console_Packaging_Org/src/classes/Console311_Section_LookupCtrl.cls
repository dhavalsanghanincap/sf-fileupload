public with sharing class Console311_Section_LookupCtrl {
  /*private Incap311Console__Console311_Lookup_Config__mdt lookupConfigSosl;

  public sObject mSobj { get; set; }
  public String mSobjName { get; set; }
  public String mSobjFieldName { get; set; }
  public List<Console311_Wrap_Config> mLayoutConfig { get; set; }
  public Map<String, Map<String, Map<String, String>>> sObjectFieldUtilMap { get; set; }

  public Console311_Section_LookupCtrl() {
    lookupConfigSosl = [Select Incap311Console__New_Record_Layout__c, Incap311Console__Search_Layout__c, Incap311Console__Search_Result_Layout__c From Incap311Console__Console311_Lookup_Config__mdt Where MasterLabel = :mSobjName];
  }

  public List<String> getFieldNamesList() {
    if (this.mSobj != null && lookupConfigSosl.Incap311Console__Search_Layout__c != null) {
      this.sObjectFieldUtilMap = Console311_Util.formatSobjectDataUtilMap(new List<sObject> { this.mSobj }, this.mSobjName, lookupConfigSosl.Incap311Console__Search_Layout__c);
      return new List<String>(sObjectFieldUtilMap.get(this.mSobj.Id).keySet());
    }
    return new List<String>();
  }

  public Incap311Console__Console_311_Layout_Setting__mdt getInformationLayoutConfig() {
    if (this.mLayoutConfig != null) {
      for (Console311_Wrap_Config config : this.mLayoutConfig) {
        if ((config.mName).equalsIgnoreCase('organization')) {
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
        if ((config.mName).equalsIgnoreCase('new_edit_organization')) {
          return (Incap311Console__Console_311_Layout_Setting__mdt) JSON.deserialize(config.mObjJson, Incap311Console__Console_311_Layout_Setting__mdt.class);
        } 
      }
    }
    return null;
  }*/
}