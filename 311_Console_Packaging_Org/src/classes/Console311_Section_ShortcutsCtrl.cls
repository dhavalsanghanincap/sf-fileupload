public with sharing class Console311_Section_ShortcutsCtrl {

  public List<Incap311Console__X311_Console_Shortcut__mdt> mShortcuts { get; set; }

  public Console311_Section_ShortcutsCtrl() {

    this.mShortcuts = [
      SELECT
        MasterLabel,
        Incap311Console__Color__c,
        Incap311Console__Link__c,
        Incap311Console__Link_Type__c
      FROM 
        Incap311Console__X311_Console_Shortcut__mdt
    ];
  }
}