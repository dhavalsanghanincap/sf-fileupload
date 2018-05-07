@isTest
private class Test_Console311_CaseController {
    
    public static void testSetup() {
        TestHelper.createData();
    }
    
    @isTest static void testgetCurrentCaseSST() {
        Test_Console311_CaseController.testSetup();
        Console311_CaseController ctrl = new Console311_CaseController();
        ctrl.mSavedCase = new Case();
        ctrl.mSpecialServiceTypeList = new List<Incap311__Special_Service_Type__mdt>();
        System.assertEquals(ctrl.getCurrentCaseSST(), null);
        ctrl.clearServiceType();
    }
    @isTest static void testGetters2() {
        Test_Console311_CaseController.testSetup();
        Console311_CaseController ctrl = new Console311_CaseController();
        System.assertEquals(ctrl.SST_SHORT_CODE_EMERGENCY, 'Emergency');
        System.assertEquals(ctrl.SST_SHORT_CODE_GENERIC, 'Generic');
        //Map<String, Incap311__Service_Type_Version__c> mServiceTypesMapByName = ctrl.mServiceTypesMapByName;
        String mstid = ctrl.mSTId;
        Incap311__Case_Event__c caseEvent =  ctrl.mLatestCaseEvent;
        ctrl.clearAndSetServiceType();
     }
    
    @isTest static void testgetdefaults() {
        Test_Console311_CaseController.testSetup();
        Console311_CaseController ctrl = new Console311_CaseController();
        System.assert(ctrl.getOrganizationConfig().size() > 0);
        System.assert(ctrl.getContactConfigs().size() > 0);
        ctrl.getServiceRequestItems();
        System.assertEquals(ctrl.getCurrentLocationLatitude(),0.00);
        System.assertEquals(ctrl.getCurrentLocationLongitude(),0.00);
        ctrl.clearServiceType();
        System.assertEquals(ctrl.mActiveServiceType,null);
    }
    
    
    @isTest static void testgetMapCoors() {
        Test_Console311_CaseController.testSetup();
        Console311_CaseController ctrl = new Console311_CaseController();
        ctrl.mLocation = new Incap311.Base311_Location(10, 10, '1', '1');
        System.assertEquals(ctrl.getMapCoords()[0], 10);
        System.assertEquals(ctrl.getMapCoords()[1], 10);
    }
    
    @isTest static void testGetPageTitle() {
        Test_Console311_CaseController.testSetup();
        Console311_CaseController ctrl = new Console311_CaseController();
        ctrl.mAction = 'edit';
        System.assertEquals(ctrl.getPageTitle(), 'edit');
        ctrl.mAction = 'new';
        System.assertEquals(ctrl.getPageTitle(), 'Creation');
    }
    
    @isTest static void testfeedParentInformationToPage() {
        Test_Console311_CaseController.testSetup();
        Console311_CaseController ctrl = new Console311_CaseController();
        ctrl.feedParentInformationToPage();
        System.assertEquals(ctrl.mActParentCaseNum, null);
    }
    
    @isTest static void testgenScheduleMatching() {
        Test_Console311_CaseController.testSetup();
        Console311_CaseController ctrl = new Console311_CaseController();
        Map<String, Console311_Wrap_LayerInformation> test = ctrl.genScheduleMatching();
        System.assertnotEquals(test, null);
    }

    @isTest static void testretrieveDistListUsingMatching() {
        Test_Console311_CaseController.testSetup();
        Console311_CaseController ctrl = new Console311_CaseController();
        //ctrl.retrieveDistListUsingMatching();
    }

    @isTest static void testgetDotwForLocation() {
        Test_Console311_CaseController.testSetup();
        Console311_CaseController ctrl = new Console311_CaseController();
        ctrl.getDotwForLocation();
    }

    @isTest static void testSetServiceTypeEdit() {
        Test_Console311_CaseController.testSetup();
        Console311_CaseController ctrl = new Console311_CaseController();
        ctrl.mAction = 'edit';
        List<Incap311__Service_Type_Version__c> stvList = [Select Id, Name, Incap311__Distribute_On__c, Incap311__Enable_Distribution_del__c, Incap311__Keywords__c From Incap311__Service_Type_Version__c Limit 1];
        stvList[0].Incap311__Enable_Distribution_del__c = true;
        update stvList; 

        ctrl.mActiveTypeVersion = stvList[0];
        ctrl.mSavedCase = new Case();
        System.currentPageReference().getParameters().put('activeServiceType', stvList.get(0).Name);
        ctrl.setServiceType();

        // DIST Methods
        ctrl.retrieveDistListUsingMatching();
        ctrl.getDistributionEnabledForServiceTypeVersion();

        stvList[0].Incap311__Distribute_On__c = 'Create';
        update stvList;
        ctrl.getDistributionEnabledForServiceTypeVersion();        

        stvList[0].Incap311__Distribute_On__c = '';
        update stvList;
        ctrl.getDistributionEnabledForServiceTypeVersion();        
    }
    
    
    @isTest static void testBulkMethods() {
        Test_Console311_CaseController.testSetup();
        Console311_CaseController ctrl = new Console311_CaseController();
        ctrl.storeLocationInformation();
        ctrl.storeSubLocation();
        List<Incap311__Service_Type_Version__c> stvList = [Select Id, Name, Incap311__Service_Type__c,Incap311__Include_System_Defaults_del__c From Incap311__Service_Type_Version__c Limit 1];
        ctrl.mActiveTypeVersion = stvList[0];
        ctrl.mActiveServiceType = stvList[0].Name;
        ctrl.getServiceRequestItems();
        ctrl.mSavedCase = new Case();
        ctrl.mLocation = TestHelper.generateMockLocationData().get(0);
        ctrl.mLocation.layers = TestHelper.genMockLayerInformation();
        //System.currentPageReference().getParameters().put('recycleDate', 'Monday');
        System.currentPageReference().getParameters().put('numOfItems', '1');
        System.currentPageReference().getParameters().put('addressStr', 'San Francisco');
        Map<String, String> mapLayers = ctrl.mapLayers;
        Double mapZoom = ctrl.mapZoom;
        Double mapCenterLongitude = ctrl.mapCenterLongitude;
        Double mapCenterLatitude = ctrl.mapCenterLatitude;
        ctrl.feedAccountInformationToPage();

        ctrl.getActivityParentCase();
        ctrl.getOrganizationConfig();
        ctrl.getContactConfigs();
        
        // Create a couple schedules for processing. Need to be specific dates. 
        Date tempD = Date.parse('02/10/2020');
        Incap311__Schedule__c s1 = new Incap311__Schedule__c(
            Incap311__Capacity__c = 20,
            Incap311__Zone__c = '07',
            Incap311__Schedule_Date__c = tempD,
            Incap311__Schedule_Override_Date__c = tempD.addDays(1),
            Incap311__Item_Count__c = 0,
            Incap311__No_Service__c = false,
            Incap311__Service_Type__c = stvList[0].Incap311__Service_Type__c
        );
        
        Incap311__Schedule__c s2 = new Incap311__Schedule__c(
            Incap311__Capacity__c = 20,
            Incap311__Zone__c = '07',
            Incap311__Schedule_Date__c = tempD.addDays(1),
            Incap311__Item_Count__c = 20,
            Incap311__No_Service__c = false,
            Incap311__Service_Type__c = stvList[0].Incap311__Service_Type__c
        );
        
        Incap311__Schedule__c s3 = new Incap311__Schedule__c(
            Incap311__Capacity__c = 20,
            Incap311__Zone__c = '07',
            Incap311__Schedule_Date__c = tempD.addDays(7),
            Incap311__Schedule_Override_Date__c = tempD.addDays(8),
            Incap311__Item_Count__c = 0,
            Incap311__No_Service__c = false,
            Incap311__Service_Type__c = stvList[0].Incap311__Service_Type__c
        );
        
        Incap311__Schedule__c s4 = new Incap311__Schedule__c(
            Incap311__Capacity__c = 20,
            Incap311__Zone__c = '07',
            Incap311__Schedule_Date__c = tempD.addDays(8),
            Incap311__Item_Count__c = 0,
            Incap311__No_Service__c = false,
            Incap311__Service_Type__c = stvList[0].Incap311__Service_Type__c
        );
        
        List<Incap311__Schedule__c> schToInsert = new List<Incap311__Schedule__c>{s1, s2, s3, s4};
            insert schToInsert;
        
        System.debug('----> schToInsert: ' + schToInsert);
        //List<Schedule__c> temp = [SELECT Id, Name, Incap311__Capacity__c, Incap311__Zone__c, Incap311__Schedule_Date__c, Incap311__Schedule_Override_Date__c, Incap311__Item_Count__c, Incap311__Day_of_Week__c, Incap311__No_Service__c, Incap311__Number_of_Service_Requests__c, Incap311__Service_Type__r.Incap311__Schedule_Type__c, Incap311__Service_Type__r.Incap311__Item_Limit__c, Incap311__Service_Type__r.Incap311__Daily_Request_Limit__c FROM Incap311__Schedule__c WHERE (Incap311__No_Service__c = false AND Incap311__Service_Type__c = :s1.Id AND Incap311__Zone__c = s1.Incap311__Zone__c AND Incap311__Schedule_Date__c > TODAY AND Day_of_Week__c = :tmpVar4 AND Id != :tmpVar5) ORDER BY Schedule_Date__c ASC NULLS FIRST LIMIT :tmpVar6]
        //System.debug('----> temp: ' temp);
        
        // Test the bulk pieces.
        System.assert(true, ctrl.getIsActiveTypeBulkType());

        ctrl.mLayerInfoMap = ctrl.genScheduleMatching();

        System.debug('----> [Test_Console311_CaseController] About to run [findSchedulableDate]. Output zone...');
        System.debug('----> [Test_Console311_CaseController] getZoneFromAddress: ' + ctrl.getZoneFromAddress());
        
        ctrl.findSchedulableDate();
        System.assertNotEquals(null, ctrl.scheduleToPresentList);
        System.assertNotEquals(0, ctrl.scheduleToPresentList.size());
        System.debug('----> ctrl.scheduleToPresentList: ' + ctrl.scheduleToPresentList);

        ctrl.storeNumberOfBulkItems();
        System.assertEquals(0, ctrl.mBulkItemCount);
        System.currentPageReference().getParameters().put('numberOfBulkItemsToProcess', '3');
        ctrl.storeNumberOfBulkItems();
        System.assertEquals(3, ctrl.mBulkItemCount);    
        
        ctrl.mGenericSRType = stvList[0];
        System.currentPageReference().getParameters().put('districtName', '');
        ctrl.retrieveDistributionListFromDistrict();
        ctrl.retrieveDistributionListFromDistrictWithLocation();
        //incap311.Test_Base311_MockLocation.setupMocks();
        //Test.startTest();
        	//ctrl.storeLocationInformation();
        //Test.stopTest();
    }
    
    
    @isTest static void testGetters() {
        Test_Console311_CaseController.testSetup();
        
        Test.setCurrentPageReference(new PageReference('Page.Console311_Case')); 
        System.currentPageReference().getParameters().put('contactJson', '{"attributes":{"type":"Contact","url":"/services/data/v38.0/sobjects/Contact/0034100000BBl18AAD"},"Id":"0034100000BBl18AAD","Name":"Tim Barr","FirstName":"Tim","LastName":"Barr"}');
        
        Console311_CaseController ctrl = new Console311_CaseController();
        ctrl.setComponentControllerMap('contact', new Console311_Section_ContactCtrl()); 
        
        ctrl.mSavedCase = new Case();
        ctrl.mErrorMsg = '';
        ctrl.mKnowledgeKeyword = '';
        
        System.assertEquals(null, ctrl.bulkscheduleTypeId);
        System.assertEquals(ctrl, ctrl.ctrl);
        System.assertEquals(0, ctrl.getCurrentServiceTypeAsList().size());
        
        List<Incap311__Service_Type_Version__c> stvList = [Select Id, Name From Incap311__Service_Type_Version__c Limit 1];
        Incap311__Service_Type_Version__c stv;
        
        if (stvList != null && stvList.size() > 0) {
            stv = stvList.get(0);
            ctrl.mActiveServiceType = stv.Name;  
            
            ctrl.setActiveServiceType();
            System.assertEquals(ctrl.mErrorMsg, 'Service type selection unsuccessful. Please try again.');
            
            ctrl.mActiveServiceType = '';
            ctrl.setServiceType();
            System.assertEquals(ctrl.mErrorMsg, 'Unable to detect service type selection. Please try again.');
            
            ctrl.mActiveServiceType = stv.Name;
            System.currentPageReference().getParameters().put('activeServiceType', stv.Name);
            ctrl.setActiveServiceType();
            
            ctrl.setServiceType();
            System.assertNotEquals(null, ctrl.mActiveTypeVersion);
            System.assert(ctrl.getIsActiveSerivceTypeSet());
            
            System.assertEquals(1, ctrl.getCurrentServiceTypeAsList().size());
        }
        
        ctrl.refreshPanel();
        
        ctrl.getDuplicatesAvailable();
        
        System.assertNotEquals(null, ctrl.conCtrl);
        //ctrl.feedContactInformationToPage();
        
        List<Incap311__Service_Type_Version__c> srItems = ctrl.getServiceRequestItems();
        System.assertNotEquals(null, srItems);
        
        String srNameJson = ctrl.getServiceRequestNames();
        System.assert(String.isNotBlank(srNameJson));
        System.assertEquals(srNameJson,'["Test Version"]');
        
        String srMapJson = ctrl.getServiceRequestsMap();
        System.assert(String.isNotBlank(srMapJson));
        System.assert(!srMapJson.equalsIgnoreCase('[]'));
        
        System.assertNotEquals(null, ctrl.getOriginOptions());
        System.assertNotEquals(null, ctrl.getStatusOptions());
        System.assertNotEquals(null, ctrl.getStateOptions());
        
        System.assertEquals(51, Console311_Util.getStateByStateCodeMap().size());
        System.assertEquals(ctrl.getPageTitle(), 'Creation');
        
        ctrl.mAction = 'new';
        System.assertEquals(ctrl.getPageTitle(), 'Creation');
        
        ctrl.mAction = 'edit';
        System.assertEquals(ctrl.getPageTitle(), 'edit');
    } 
    
    @isTest static void testSave() {
        Test_Console311_CaseController.testSetup();
        
        Console311_CaseController ctrl = new Console311_CaseController();
        ctrl.mLocation = TestHelper.generateMockLocationData().get(0);
        System.assertEquals(null, ctrl.mErrorCodeActive);
        
        List<Incap311__Service_Type_Version__c> stvList = [Select Id, Name From Incap311__Service_Type_Version__c Limit 1];
        ctrl.mActiveServiceType = stvList.get(0).Name;  
        System.currentPageReference().getParameters().put('activeServiceType', stvList.get(0).Name);
        ctrl.setServiceType();
        
        List<Incap311__Service_Type_Version_Question__c> stvqList = [Select Id, Name, Incap311__Data_Type__c, Incap311__Question__r.Incap311__Flex_Question_Code__c From Incap311__Service_Type_Version_Question__c Where Incap311__Service_Type_Version__c = :stvList.get(0).Id AND Incap311__Data_Type__c = 'Text'];
        System.debug('----> [Test] stvqList: ' + stvqList);
        
        String stvqJsonString = '';
        List<Console311_Wrap_FlexnoteQuestionAnswer> mFNQuestionAnswerList = new List<Console311_Wrap_FlexnoteQuestionAnswer>();
        Integer counter = 1;
        for (Incap311__Service_Type_Version_Question__c stvqTemp : stvqList) {
            String answer = 'a1';
            
            stvqJsonString += '{"mSRTypeVQuestionName":"' + stvqTemp.Incap311__Question__r.Incap311__Flex_Question_Code__c + '","question":{"Incap311__Answer__c":"' + answer + '","Incap311__Service_Type_Version_Question__c":"' + stvqTemp.Id + '"}}';
            mFNQuestionAnswerList.add(new Console311_Wrap_FlexnoteQuestionAnswer(stvqTemp, new Map<String,Object>()));
            
            if (counter >= 1 && counter != stvqList.size()) {
                stvqJsonString += ',';
            }
            counter = counter + 1;
        }
        String caseJson = '{"c":{"SLA__c":"4","Status":"Open","Origin":"Web","Description":"dawda"},"serviceQuestions":[' + stvqJsonString + '],"contact":{"FirstName":"Test","LastName":"Test","Phone":"5069999999","Email":"test@test.com","MailingStreet":"123 Fake St","MailingCity":"Fakeville","MailingState":"AZ","MailingCountryCode":"US","MailingPostalCode":"0H0H0H"},"shouldSetDupe":false,"ai":{"distributionList": "john.benson@Bluespurs.com", "coordinatorList": "john.benson@Bluespurs.com"}}';
        ctrl.mCaseJson = caseJson;
        
        List<Incap311__Service_Type_Version__c> srItems = ctrl.getServiceRequestItems();
        System.assertNotEquals(null, srItems);
        
        ctrl.saveCase();
        
        ctrl.mActiveServiceType = '';
        ctrl.saveCase();
        System.assertNotEquals(null, ctrl.mErrorCodeActive);
        
        List<Case> tempCaseList = [Select Id, CaseNumber, Incap311__Duplicate_Parent__c From Case];    
        ctrl.mAction = 'edit';//should be transfer having an issue
        ctrl.mActiveServiceType = stvList.get(0).Name;
        ctrl.mOrgTransferCaseNum = (tempCaseList.size() > 0 ? tempCaseList[0].CaseNumber : '1234');
        ctrl.mOrgTransferCase = ctrl.restServiceRequest.getServiceRequest(ctrl.mOrgTransferCaseNum);
        ctrl.mOrgTransferCase.Status = 'Open';
        update ctrl.mOrgTransferCase;
        ctrl.mSavedCase = tempCaseList[0];
        System.assert(ctrl.getServiceRequestWrapper().isValid());
        Console311_CaseController.ServiceRequestWrapper srWrapper = ctrl.getServiceRequestWrapper();
        String srVTypeName = String.isNotBlank(srWrapper.c.Incap311__Service_Type_Version__c) ? String.valueOf(srWrapper.c.Incap311__Service_Type_Version__c) : ctrl.mActiveServiceType;         
        System.assert(String.isNotBlank(srVTypeName));
        srWrapper.ai = new Console311_CaseController.AdditionalInfo();
        srWrapper.ai.distributionList = 'distributionList@example.com';
        srWrapper.ai.coordinatorList = 'coordinatorList@example.com';
        //ctrl.saveCase();
        
        
        ctrl.mAction = 'edit';
        ctrl.saveCase();  
        
        // Test Contact Required.
        Contact tempC = new Contact(LastName = 'Testy', FirstName = 'Test', Phone = '5069999999', Email = 'test@test.com');
        System.assert(!Console311_Util.isContactRequiredToCreateCase('', null));
        System.assertEquals(null, Console311_Util.isContactRequiredToCreateCase('Required (LN, FN, EM)', null));
        System.assert(Console311_Util.isContactRequiredToCreateCase('Required (LN, FN, EM)', new Contact()));
        System.assert(Console311_Util.isContactRequiredToCreateCase('', tempC));
        
        // Test Transfer portions.
        Test.setCurrentPageReference(new PageReference('Page.Console311_Case')); 
        System.currentPageReference().getParameters().put('cid','1234');
        System.currentPageReference().getParameters().put('activity','transfer');
        System.currentPageReference().getParameters().put('flexnoteAnswersJson', '{"c":{"Service_Type_Version__c":"' + stvList.get(0).Name + '","Status":"Open","Origin":"Phone"},"serviceQuestions":[{"Incap311__Answer__c":"Front","Incap311__Service_Type_Version_Question__c":"' + stvqList[0].Id + '"},{"mSRTypeVQuestionName":"ST-EXCTLOC","question":{"Incap311__Answer__c":"Front","Incap311__Service_Type_Version_Question__c":"' + stvqList[0].Id + '"}}],"contact":{"MailingCountryCode":"US"}}');
        case c = [select casenumber from case limit 1];
        ctrl.mAction = 'edit';//should be transfer having an issue
        ctrl.mOrgTransferCaseNum = c.casenumber;//(tempCaseList.size() > 0 ? tempCaseList[0].Id : '1234');
        //ctrl.init();
        //ctrl.instantiate();
        
        System.assert(ctrl.getServiceRequestWrapper().isValid());
        srWrapper = ctrl.getServiceRequestWrapper();
        srWrapper.ai = new Console311_CaseController.AdditionalInfo();
        srWrapper.ai.distributionList = 'distributionList@example.com';
        srWrapper.ai.coordinatorList = 'coordinatorList@example.com';
        srVTypeName = String.isNotBlank(srWrapper.c.Incap311__Service_Type_Version__c) ? String.valueOf(srWrapper.c.Incap311__Service_Type_Version__c) : ctrl.mActiveServiceType;  
        srWrapper.stv = ctrl.mActiveTypeVersion;
        Account acc = new Account(Name = 'TEst');
        insert acc;
        srWrapper.account = acc;
        System.assert(String.isNotBlank(srVTypeName));
        //System.assert(ctrl.ACTIVITY_TYPE_TRANSFER.equalsIgnoreCase(ctrl.mAction));
        
        ctrl.saveCase();
        ctrl.refreshFlexnotesWithAnswers();
        Case inProgressCase = ctrl.getInprogressCase();
        
        ctrl = new Console311_CaseController(); 
        System.assertEquals(ctrl.getPageTitle(), 'transfer');
        
        ctrl.fetchDuplicateParent();
        
        // Bulk Items
        System.currentPageReference().getParameters().put('numberOfBulkItemsToProcess', '5');
        ctrl.storeNumberOfBulkItems();
        
        
        // Edit
        ctrl.getInprogressCase();
        ctrl.getCaseLayers();
        ctrl.getThis();
        
        String wJson = '{"c":{"Service_Type_Version__c":"' + stvList.get(0).Name + '","Status":"Open","Origin":"Phone"},"serviceQuestions":[{"Incap311__Answer__c":"Front","Incap311__Service_Type_Version_Question__c":"' + stvqList[0].Id + '"},{"mSRTypeVQuestionName":"ST-EXCTLOC","question":{"Incap311__Answer__c":"Front","Incap311__Service_Type_Version_Question__c":"' + stvqList[0].Id + '"}}],"contact":{"MailingCountryCode":"US"}}';
        Console311_Util_Flexnote.ServiceQuestionWrapper sqw = (Console311_Util_Flexnote.ServiceQuestionWrapper) JSON.deserialize(wJson, Console311_Util_Flexnote.ServiceQuestionWrapper.class);
        
        Console311_Util_Flexnote cuf = new Console311_Util_Flexnote();
        cuf.convertFlexnoteAnswersToMap(new List<Console311_Util_Flexnote.ServiceQuestionWrapper> { sqw }, false);
        Console311_Util_Flexnote.fetchWithUpdates('', new Map<String,Object>(), mFNQuestionAnswerList);
    }
    
     @isTest static void testinit() {
         Test_Console311_CaseController.testSetup();
         Console311_CaseController ctrl = new Console311_CaseController();
         Test.setCurrentPageReference(new PageReference('Page.Console311_Case')); 
         System.currentPageReference().getParameters().put('cid','1234');
         System.currentPageReference().getParameters().put('activity','edit');
         //ctrl.mAction = 'edit';
         ctrl.init();
     }
    
}