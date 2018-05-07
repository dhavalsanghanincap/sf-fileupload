@isTest
private class Test_Base311_Service_SpecialServiceType {

  @isTest static void testMetadataMethods() {
    Base311_Service_SpecialServiceType rssst = new Base311_Service_SpecialServiceType();

    // In case of values not being consistent or removed there is no assertion here.
    rssst.getSpecialServiceTypes();
    rssst.getSpecialServiceType('Emergency');
  }
  
  @isTest static void testGetSpecialServiceTypeRelatedTypeVersion() {
    Base311_Service_SpecialServiceType rssst = new Base311_Service_SpecialServiceType();
        
    //Service_Type_Version__c stv = Test_RestTestHelper.sericeTypeVersionAndVersion('TEST1');

    Service_Type__c st = Test_RestTestHelper.serviceType();
    Service_Type_Version__c stv = Test_RestTestHelper.serviceTypeVersion(st.Id, 'TEST1', null, true);
    System.debug('---> stv: ' + stv);

    stv.Service_Type__r.Active_Service_Type_Version__c = stv.Id;
    update stv.Service_Type__r;

    Service_Type_Version__c stvFromService = rssst.getSpecialServiceTypeRelatedTypeVersion(stv.Service_Type__r.Service_Type_Code__c);

    System.assertNotEquals(null, stvFromService);
    System.assertEquals(stv.Id, stvFromService.Id);
  }
}