public with sharing class Console311_Section_ParentSRCtrl {
  private final String PARENT_CONFIG_NAME = 'Parent_Case';

  public List<Incap311Console__Console_311_Layout_Setting__mdt> mConsoleLayoutConfig { get; set; }
  public Incap311Console__Console_311_Layout_Setting__mdt mActiveConfig { get; set; }

  public Console311_Section_ParentSRCtrl() {
    this.mConsoleLayoutConfig = [Select QualifiedApiName, Incap311Console__Visible__c, Incap311Console__Header__c, Incap311Console__Collapsible__c, Incap311Console__Title__c, MasterLabel, DeveloperName From Incap311Console__Console_311_Layout_Setting__mdt];
  }

  public Incap311Console__Console_311_Layout_Setting__mdt getParentPageConfig() {
    if (this.mActiveConfig == null) {
      for (Incap311Console__Console_311_Layout_Setting__mdt config : this.mConsoleLayoutConfig) {
        if (config.DeveloperName.containsIgnoreCase(PARENT_CONFIG_NAME)) {
          return this.mActiveConfig = config;
        }
      }
    }
    return null;
  }
}