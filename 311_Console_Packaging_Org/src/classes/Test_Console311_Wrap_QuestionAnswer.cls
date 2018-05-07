@isTest
private class Test_Console311_Wrap_QuestionAnswer {
  
  @isTest static void testWrapper() {
    Console311_Wrap_QuestionAnswer wqa = new Console311_Wrap_QuestionAnswer();

    System.assertEquals(null, wqa.getCurrentAnswer());
    System.assertEquals('', wqa.getSelectedItemsJson());
    System.assertEquals(99, wqa.getQuestionOrderRank());
    System.assertEquals(null, wqa.getActivePicklist());
    System.assertEquals(null, wqa.getPicklistOptions());
    System.assertEquals(true, wqa.validatePicklistOption('bleh'));
    System.assertEquals(null, wqa.getQuestion());
    System.assertEquals(null, wqa.getQuestionCode());
  }
    

}