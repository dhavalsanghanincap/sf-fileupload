@isTest
private class Test_Console311_SR_ReferTo_Ctrl {
  
  public static void testSetup() {
    TestHelper.createData();

    List<Case> cList = [Select Id, CaseNumber From Case Limit 1];

    if (cList.size() > 0) {
      Test.setCurrentPageReference(new PageReference('Page.Console311_SR_ReferredTo')); 
      System.currentPageReference().getParameters().put('cid', cList.get(0).CaseNumber);  
    }
  }

  @isTest static void testReferToCtrl() {
    Test_Console311_SR_ReferTo_Ctrl.testSetup();
    
    Console311_SR_ReferredTo_Controller ctrl = new Console311_SR_ReferredTo_Controller();


    ctrl.getDistributionPicklist();
    System.debug('----> Picklist values: ' + ctrl.mDistPicklists);
    System.assertEquals(1, ctrl.mDistPicklists.size());

    ctrl.mDistPIcklistSelected = ctrl.mDistPicklists.get(0).Id;

    ctrl.retrieveDistrubutionEmailList();

    ctrl.mUpdateText = 'Some text for here.';
    ctrl.SaveEvent();

    List<Incap311__Case_Event__c> ceList = [Select Id From Incap311__Case_Event__c];
    System.assertEquals(1, ceList.size());
  }
}