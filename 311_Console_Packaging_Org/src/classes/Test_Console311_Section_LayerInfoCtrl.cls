@isTest
private class Test_Console311_Section_LayerInfoCtrl {

  @isTest static void testConstuctor() {
    Console311_Section_LayerInfoCtrl ctrl = new Console311_Section_LayerInfoCtrl();
    System.assertEquals('Incap311__Layer_Information__c', ctrl.mObjJsonConfigFieldName);

    ctrl = new Console311_Section_LayerInfoCtrl('test_name');
    System.assertEquals('test_name', ctrl.mObjJsonConfigFieldName);    
  }
  
  @isTest static void testGetRecycleDate() {
    Console311_Section_LayerInfoCtrl ctrl = new Console311_Section_LayerInfoCtrl();
    System.assertEquals('', ctrl.getRecycleDate());

    List<Incap311.Base311_ESRI_Layer> esriList = new List<Incap311.Base311_ESRI_Layer>();
    Incap311.Base311_ESRI_Layer esriRec = new Incap311.Base311_ESRI_Layer();
    esriRec.layerName = 'PWD Recycling Day';
    esriRec.value = 'value';
    esriList.add(esriRec);
    ctrl.mLayers = esriList;

    System.assertEquals('value', ctrl.getRecycleDate());
  }

  @isTest static void testGetLayerInformation() {
    TestHelper.createData();
    Console311_Section_LayerInfoCtrl ctrl = new Console311_Section_LayerInfoCtrl();

    List<Incap311.Base311_ESRI_Layer> esriList = new List<Incap311.Base311_ESRI_Layer>();
    Incap311.Base311_ESRI_Layer esriRec = new Incap311.Base311_ESRI_Layer();
    esriRec.layerName = 'test_name';
    esriRec.value = 'value';
    esriList.add(esriRec);
    ctrl.mLayers = esriList;

    List<Incap311__Service_Type_Version__c> stvList = [Select Id, Name, Incap311__Layer_Information__c, Incap311__Keywords__c From Incap311__Service_Type_Version__c Limit 1];
    ctrl.mStv = stvList[0];
    ctrl.getLayerInformation();
  }
}