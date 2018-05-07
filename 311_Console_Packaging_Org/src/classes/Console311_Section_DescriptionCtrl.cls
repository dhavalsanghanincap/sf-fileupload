public with sharing class Console311_Section_DescriptionCtrl  {
 private final String DESCRIPTION_CONFIG_NAME = 'Description';

  public List<Incap311Console__Console_311_Layout_Setting__mdt> mConsoleLayoutConfig { get; set; }
  public Incap311Console__Console_311_Layout_Setting__mdt mDescriptionSectionConfig { get; set; }

  public Console311_Section_DescriptionCtrl() {
    this.mConsoleLayoutConfig = [Select QualifiedApiName, Incap311Console__Visible__c, Incap311Console__Header__c, Incap311Console__Collapsible__c, Incap311Console__Title__c, MasterLabel, DeveloperName From Incap311Console__Console_311_Layout_Setting__mdt];
  	for (Incap311Console__Console_311_Layout_Setting__mdt config : this.mConsoleLayoutConfig) {
        if (config.DeveloperName.containsIgnoreCase(DESCRIPTION_CONFIG_NAME)) {
            this.mDescriptionSectionConfig = config;
        }
      }
  }
}