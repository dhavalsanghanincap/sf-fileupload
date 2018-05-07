@isTest
private class Test_Console311_Section_ESRI {

    @isTest static void testESRIMethods() {
        TestHelper.createData();
                
        Console311_Section_ESRI ctrl = new Console311_Section_ESRI();
        System.assertEquals(0, ctrl.similarCases.size());
        System.assertEquals(0, ctrl.duplicateCases.size());
        System.assertEquals(null, ctrl.castedMap);
        
        List<Case> cList = [Select Id, Incap311__Service_Type_Version__c, Incap311__Service_Type_Version__r.Name, Incap311__Location__c, Incap311__Location__Longitude__s, Incap311__Location__Latitude__s From Case];
        
        if (cList.size() > 0) {
            ctrl.activeCase = cList.get(0);
            System.assertEquals(0, ctrl.similarCases.size());
            System.assertEquals(0, ctrl.duplicateCases.size());
        }
    } 
    
    @isTest static void testgetDefaultBasemap() {
        
        TestHelper.createData();
        Console311_Section_ESRI ctrl = new Console311_Section_ESRI();
        
        List<Case> cList = [Select Id, Incap311__Service_Type_Version__c, Incap311__Service_Type_Version__r.Name, Incap311__Location__c, Incap311__Location__Longitude__s, Incap311__Location__Latitude__s From Case];
        
        test.startTest();
        if (cList.size() > 0) {
        	ctrl.getDefaultBasemap();
            System.assertEquals('streets', ctrl.getDefaultBasemap());
        }
        test.stopTest();
    }
    
     @isTest static void testgetSerializedCustomBasemaps() {
        
        TestHelper.createData();
        Console311_Section_ESRI ctrl = new Console311_Section_ESRI();
        
        List<Case> cList = [Select Id, Incap311__Service_Type_Version__c, Incap311__Service_Type_Version__r.Name, Incap311__Location__c, Incap311__Location__Longitude__s, Incap311__Location__Latitude__s From Case];
        Location loc1 = Location.newInstance(28.635308,77.22496);
        test.startTest();
        if (cList.size() > 0) {
        	System.assertEquals(null, ctrl.getSerializedCustomBasemaps());
        }
        test.stopTest();
    }
    
    @isTest static void testduplicateCases() {
        
        TestHelper.createData();
        List<Case> cList = [Select Id, Incap311__Service_Type_Version__c, Incap311__Service_Type_Version__r.Name, Incap311__Location__c, Incap311__Location__Longitude__s, Incap311__Location__Latitude__s From Case];
        Location loc1 = Location.newInstance(28.635308,77.22496);
        for(Case caseRecord : cList){
            caseRecord.Incap311__Location__Longitude__s = loc1.getLongitude();
            caseRecord.Incap311__Location__Latitude__s = loc1.getLatitude();
        }
        update cList;
        Console311_Section_ESRI ctrl = new Console311_Section_ESRI();
        test.startTest();
        if (cList.size() > 0) {
            ctrl.activeCase = cList.get(0);
            System.assertEquals(0, ctrl.duplicateCases.size());
        }
        test.stopTest();
    }

    @isTest static void testrecordLocation() {
    	Incap311.Base311_Location loc = new Incap311.Base311_Location();
    	loc.lat = 77.7;
        loc.lng = 33.3;
        loc.xCoord = 22222.22;
        loc.yCoord = 11111.11;

        Test.startTest();
        Console311_Section_ESRI.recordLocation(loc,'Test report location');
    	Test.stopTest();


    }
}