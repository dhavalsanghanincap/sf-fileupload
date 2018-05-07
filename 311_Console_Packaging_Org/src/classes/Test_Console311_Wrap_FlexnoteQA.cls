@isTest
private class Test_Console311_Wrap_FlexnoteQA {

  public static void testSetup() {
    TestHelper.createData();
  }
  
  @isTest static void testConsole311WrapFlexnoteQA() {
    Test_Console311_Wrap_FlexnoteQA.testSetup();

    Console311_Wrap_FlexnoteQuestionAnswer fqa = new Console311_Wrap_FlexnoteQuestionAnswer();

    List<Incap311__Service_Type_Version_Question__c> stvqList = [
      Select 
        Id, 
        Name, 
        Incap311__Question__r.Incap311__Flex_Question_Code__c, 
        Incap311__Is_Required_Question__c,
        Incap311__Order__c,
        Incap311__Override_Order__c,
        Incap311__Override_Answer_Values__c,
        Incap311__Question__r.Incap311__Answer_Values__c
      From
        Incap311__Service_Type_Version_Question__c
      Where 
        Incap311__Question__r.Incap311__Data_Type__c = 'Picklist'
    ];

    if (stvqList.size() > 0) {
      Incap311__Service_Type_Version_Question__c stvq = stvqList.get(0);

      Incap311__Service_Question__c sq = new Incap311__Service_Question__c(
        Incap311__Answer__c = '00',
        Incap311__Service_Type_Version_Question__c = stvq.Id
      );

      fqa = new Console311_Wrap_FlexnoteQuestionAnswer(stvq, sq);
      System.assertEquals('', fqa.getSelectedItemsJSON());
      fqa.getQuestionOrderRank();
      fqa.getPicklistOptions();
      fqa.validatePicklistOption('');
    }

  }
}