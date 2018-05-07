public with sharing class Console311_Section_AccountCtrl {
  private Incap311Console__Console311_Lookup_Config__mdt lookupConfigSosl;

  public Account mAccount { get; set; }
  public List<Console311_Wrap_Config> mLayoutConfig { get; set; }
  public Map<String, Map<String, Map<String, String>>> sObjectFieldUtilMap { get; set; }

  public Console311_Section_AccountCtrl() {
    lookupConfigSosl = [Select Incap311Console__New_Record_Layout__c, Incap311Console__Search_Layout__c, Incap311Console__Search_Result_Layout__c From Incap311Console__Console311_Lookup_Config__mdt Where MasterLabel = 'Account'];
  }

  public List<String> getFieldNamesList() {
    if (this.mAccount != null && lookupConfigSosl.Incap311Console__Search_Layout__c != null) {
      this.sObjectFieldUtilMap = Console311_Util.formatSobjectDataUtilMap(new List<Account> { mAccount }, 'account', lookupConfigSosl.Incap311Console__Search_Layout__c);
      return new List<String>(sObjectFieldUtilMap.get(this.mAccount.Id).keySet());
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
  }
}