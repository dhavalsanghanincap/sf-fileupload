@isTest
private class Test_SRReportController 
{
  static testMethod void testSRReportController()
    {
        //Creat a case
        Case newCase  =  TestDataFactory.createServiceRequest(); 
        
        //Create Corresponding Question/Answer
        List<Incap311__Service_Question__c>  lstQuestion  =  TestDataFactory.createServiceQuestion(newCase,5);
        
        //Set GET Param
        ApexPages.currentPage().getParameters().put('selectedId',newCase.Id);
        
        SRReportController reportController  =  new SRReportController();
        
        System.assertEquals(1, reportController.lstCase.size());
    }
}