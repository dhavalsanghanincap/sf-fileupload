@isTest
private class Test_Base311_DuplicateRequestUtil {

    @isTest
    static void testStandardStrategyMultipleTypes() {
        Service_Type_Version__c stv = Test_RestTestHelper.sericeTypeVersionAndVersion();
        Service_Type_Version__c stv2 = Test_RestTestHelper.sericeTypeVersionAndVersion();
        Service_Type_Version__c stv3 = Test_RestTestHelper.sericeTypeVersionAndVersion();

        stv.Is_Draft__c = false;
        update stv;
        stv.Service_Type__r.Active_Service_Type_Version__c = stv.Id;
        update stv.Service_Type__r;

        stv2.Is_Draft__c = false;
        update stv2;
        stv2.Service_Type__r.Active_Service_Type_Version__c = stv2.Id;
        update stv2.Service_Type__r;

        stv3.Is_Draft__c = false;
        update stv3;
        stv3.Service_Type__r.Active_Service_Type_Version__c = stv3.Id;
        update stv3.Service_Type__r;

        Test_RestTestHelper.duplicateServiceTypeMapping(stv.Id, stv2.Service_Type__c);

        stv.Duplicate_Match_Street__c = false;
        stv.Duplicate_Radius_feet__c = 10;
        stv.Duplicate_Threshold_Period_days__c = 365;
        stv.Duplicate_Detection_Method__c = 'Standard';
        update stv;

        Case c1 = Test_RestTestHelper.serviceRequest();
        c1.Location__Latitude__s = 10;
        c1.Location__Longitude__s = 10;
        c1.Street_Id__c = '1';
        c1.Service_Type_Version__c = stv.Id;
        update c1;

        Case c2 = Test_RestTestHelper.serviceRequest();
        c2.Location__Latitude__s = 10;
        c2.Location__Longitude__s = 10;
        c2.Street_Id__c = '1';
        c2.Service_Type_Version__c = stv2.Id;
        update c2;

        Case c3 = Test_RestTestHelper.serviceRequest();
        c3.Location__Latitude__s = 10;
        c3.Location__Longitude__s = 10;
        c3.Street_Id__c = '1';
        c3.Service_Type_Version__c = stv3.Id;
        update c3;

        Base311_Location loc = new Base311_Location();
        loc.lat = 10;
        loc.lng = 10;
        loc.addressId = '1';

        List<Case> items = Base311_DuplicateRequestsUtil.getDuplicates(loc, stv, true);

        System.assertEquals(items.size(), 2);
    }

    @isTest 
    static void testStandardStrategyNoAddress() {
        Service_Type_Version__c stv = Test_RestTestHelper.sericeTypeVersionAndVersion();
        stv.Duplicate_Match_Street__c = false;
        stv.Duplicate_Radius_feet__c = 10;
        stv.Duplicate_Threshold_Period_days__c = 365;
        stv.Duplicate_Detection_Method__c = 'Standard';
        update stv;

        Case c1 = Test_RestTestHelper.serviceRequest();
        c1.Location__Latitude__s = 10;
        c1.Location__Longitude__s = 10;
        c1.Street_Id__c = '1';
        c1.Service_Type_Version__c = stv.Id;
        update c1;

        Case c2 = Test_RestTestHelper.serviceRequest();
        c2.Location__Latitude__s = 10;
        c2.Location__Longitude__s = 10;
        c2.Street_Id__c = '2';
        c2.Service_Type_Version__c = stv.Id;
        update c2;

        Base311_Location loc = new Base311_Location();
        loc.lat = 10;
        loc.lng = 10;
        loc.addressId = '1';

        List<Case> items = Base311_DuplicateRequestsUtil.getDuplicates(loc, stv, true);

        System.assertEquals(items.size(), 2);
    }

    @isTest 
    static void testStandardStrategy() {
        Service_Type_Version__c stv = Test_RestTestHelper.sericeTypeVersionAndVersion();
        Service_Type_Version__c stv2 = Test_RestTestHelper.sericeTypeVersionAndVersion();
        stv.Duplicate_Match_Street__c = true;
        stv.Duplicate_Radius_feet__c = 10;
        stv.Duplicate_Threshold_Period_days__c = 365;
        stv.Duplicate_Detection_Method__c = 'Standard';
        stv.Duplicate_Statuses__c = 'Hold;Escalated';
        update stv;

        Case c1 = Test_RestTestHelper.serviceRequest();
        c1.Location__Latitude__s = 10;
        c1.Location__Longitude__s = 10;
        c1.Street_Id__c = '1';
        c1.Service_Type_Version__c = stv.Id;
        c1.Status = 'Hold';
        update c1;

        Case c2 = Test_RestTestHelper.serviceRequest();
        c2.Location__Latitude__s = 10;
        c2.Location__Longitude__s = 10;
        c2.Street_Id__c = '2';
        c2.Service_Type_Version__c = stv.Id;
        c2.Status = 'Escalated';
        update c2;

        Case c3 = Test_RestTestHelper.serviceRequest();
        c3.Location__Latitude__s = 10;
        c3.Location__Longitude__s = 10;
        c3.Street_Id__c = '1';
        c3.Service_Type_Version__c = stv.Id;
        c3.Status = 'Working';
        update c3;

        Case c4 = Test_RestTestHelper.serviceRequest();
        c4.Location__Latitude__s = 40;
        c4.Location__Longitude__s = 40;
        c4.Street_Id__c = '1';
        c4.Service_Type_Version__c = stv.Id;
        c4.Status = 'Hold';
        update c4;

        Case c5 = Test_RestTestHelper.serviceRequest();
        c5.Location__Latitude__s = 10;
        c5.Location__Longitude__s = 10;
        c5.Street_Id__c = '1';
        c5.Service_Type_Version__c = stv2.Id;
        c5.Status = 'Hold';
        update c5;

        Base311_Location loc = new Base311_Location();
        loc.lat = 10;
        loc.lng = 10;
        loc.addressId = '1';

        List<Case> items = Base311_DuplicateRequestsUtil.getDuplicates(loc, stv, true);

        System.assertEquals(items.size(), 1);
        System.assertEquals(items[0].Id, c1.Id);
    }

    @isTest
    static void test_method_one() {
        // create service type
        Incap311__Service_Type__c testSvcType = new Incap311__Service_Type__c();
        testSvcType.Incap311__External_Name__c = 'test type';
        testSvcType.Incap311__Service_Name__c = 'test type';
        testSvcType.Service_Type_Code__c = '123';
        insert testSvcType;

        // create service type version
        Incap311__Service_Type_Version__c testSTVersion = new Incap311__Service_Type_Version__c();
        testSTVersion.Incap311__Default_Status__c = 'Open';
        testSTVersion.Incap311__Default_Method__c = 'Phone';
        testSTVersion.Incap311__Default_Priority__c = 'Standard';
        testSTVersion.Incap311__Service_Name__c = 'test type';
        testSTVersion.Incap311__Service_Type__c = testSvcType.Id;
        testSTVersion.Incap311__Is_Draft__c = false;
        testSTVersion.Version_Name__c = '123';
        testSTVersion.Version_Code__c = '123';
        insert testSTVersion;

        // update service type with version
        Incap311__Service_Type__c qST = [SELECT Id, Incap311__Active_Service_Type_Version__c FROM Incap311__Service_Type__c WHERE ID = :testSvcType.Id];
        qST.Incap311__Active_Service_Type_Version__c = testSTVersion.Id;
        update qST;

        Incap311__Service_Type_Version__c qstv = [SELECT Id, Name, Incap311__Duplicate_Detection_Method__c, Incap311__Duplicate_Radius_feet__c, Incap311__Duplicate_Threshold_Period_days__c FROM Incap311__Service_Type_Version__c WHERE Id = :testSTVersion.Id];

        // create service request (Case)
        Case testCase1 = new Case();
        testCase1.Incap311__Service_Type_Version__c = testSTVersion.Id;
        testCase1.Incap311__Location__latitude__s = 25.0;
        testCase1.Incap311__Location__longitude__s = 25.0;
        testCase1.Status = 'Open';
        insert testCase1;

        // test some stuff
        Incap311__Service_Type_Version__c qSTVer = [SELECT Id, Name, Duplicate_Detection_Method__c FROM Incap311__Service_Type_Version__c WHERE Id = :testSTVersion.Id];
        Base311_DuplicateRequestsUtil dru = new Base311_DuplicateRequestsUtil();
        Base311_DuplicateRequestsUtil.getDuplicateServiceRequestsBase('123 Main Street', qSTVer, '25.00000001', '25.00000001', true);
        Base311_DuplicateRequestsUtil.getDuplicateServiceRequests('123 Main Street', 'test type', '25.00000001', '25.00000001', true);
        Base311_DuplicateRequestsUtil.getDuplicateServiceRequests('123 Main Street', qSTVer, '25.00000001', '25.00000001');
    }

    @isTest
    static void test_method_two() {
        // create service type
        Incap311__Service_Type__c testSvcType = new Incap311__Service_Type__c();
        testSvcType.Incap311__External_Name__c = 'test type';
        testSvcType.Incap311__Service_Name__c = 'test type';
        testSvcType.Service_Type_Code__c = '123';
        insert testSvcType;

        // create service type version
        Incap311__Service_Type_Version__c testSTVersion = new Incap311__Service_Type_Version__c();
        testSTVersion.Incap311__Default_Status__c = 'Open';
        testSTVersion.Incap311__Default_Method__c = 'Phone';
        testSTVersion.Incap311__Default_Priority__c = 'Standard';
        testSTVersion.Incap311__Duplicate_Detection_Method__c = 'Standard';
        testSTVersion.Incap311__Duplicate_Radius_feet__c = 2500;
        testSTVersion.Incap311__Duplicate_Threshold_Period_days__c = 3;
        testSTVersion.Incap311__Service_Name__c = 'test type';
        testSTVersion.Incap311__Service_Type__c = testSvcType.Id;
        testSTVersion.Incap311__Is_Draft__c = false;
        testSTVersion.Version_Name__c = '123';
        testSTVersion.Version_Code__c = '123';
        insert testSTVersion;

        // update service type with version
        Incap311__Service_Type__c qST = [SELECT Id, Incap311__Active_Service_Type_Version__c FROM Incap311__Service_Type__c WHERE ID = :testSvcType.Id];
        qST.Incap311__Active_Service_Type_Version__c = testSTVersion.Id;
        update qST;

        Incap311__Service_Type_Version__c qstv = [SELECT Id, Name, Incap311__Duplicate_Detection_Method__c, Incap311__Duplicate_Statuses__c, Incap311__Duplicate_Radius_feet__c, Incap311__Duplicate_Threshold_Period_days__c FROM Incap311__Service_Type_Version__c WHERE Id = :testSTVersion.Id];
        System.debug('>>> 2 dupe method: ' + qstv.Incap311__Duplicate_Detection_Method__c);
        System.debug('>>> 2 dupe radius: ' + qstv.Incap311__Duplicate_Radius_feet__c);
        System.debug('>>> 2 dupe period: ' + qstv.Incap311__Duplicate_Threshold_Period_days__c);
        System.debug('>>> 2 svc type version name:' + qstv.Name);
        System.debug('>>> 2 svc type version Id: ' + qstv.Id);

        // create service request (Case)
        Case testCase1 = new Case();
        testCase1.Incap311__Service_Type_Version__c = testSTVersion.Id;
        testCase1.Incap311__Location__latitude__s = 25.0;
        testCase1.Incap311__Location__longitude__s = 25.0;
        testCase1.Status = 'Open';
        insert testCase1;

        // test some stuff
        Incap311__Service_Type_Version__c qSTVer = [SELECT Id, Name, Incap311__Duplicate_Statuses__c,Duplicate_Detection_Method__c FROM Incap311__Service_Type_Version__c WHERE Id = :testSTVersion.Id];
        Base311_DuplicateRequestsUtil dru = new Base311_DuplicateRequestsUtil();
        Base311_DuplicateRequestsUtil.getDuplicateServiceRequestsBase('123 Main Street', /*qSTVer*/qstv, '25.00000001', '25.00000001', true);
        Base311_DuplicateRequestsUtil.getDuplicateServiceRequests('123 Main Street', /*qSTVer*/qstv, '25.00000001', '25.00000001');

        Base311_DuplicateRequestsUtil.getDuplicateServiceRequests('123 Main Street', 'test type', '25.00000001', '25.00000001', true);

        List<Case> dupes = Base311_DuplicateRequestsUtil.getDuplicateServiceRequests('123 Main Street', /*qSTVer.Name*/qstv.Name, '25.00000001', '25.00000001');

        System.assertEquals(1, dupes.size());
    }

    // test update duplicate status
    static testmethod void updateDuplicateStatuses() {

        // create service type
        Incap311__Service_Type__c testSvcType = new Incap311__Service_Type__c();
        testSvcType.Incap311__External_Name__c = 'test type';
        testSvcType.Incap311__Service_Name__c = 'test type';
        testSvcType.Service_Type_Code__c = '123';
        insert testSvcType;

        // create service type version
        Incap311__Service_Type_Version__c testSTVersion = new Incap311__Service_Type_Version__c();
        testSTVersion.Incap311__Default_Status__c = 'Open';
        testSTVersion.Incap311__Default_Method__c = 'Phone';
        testSTVersion.Incap311__Default_Priority__c = 'Standard';
        testSTVersion.Incap311__Service_Name__c = 'test type';
        testSTVersion.Incap311__Service_Type__c = testSvcType.Id;
        testSTVersion.Incap311__Is_Draft__c = false;
        testSTVersion.Version_Name__c = '123';
        testSTVersion.Version_Code__c = '123';
        insert testSTVersion;

        // update service type with version
        Incap311__Service_Type__c qST = [SELECT Id, Incap311__Active_Service_Type_Version__c FROM Incap311__Service_Type__c WHERE ID = :testSvcType.Id];
        qST.Incap311__Active_Service_Type_Version__c = testSTVersion.Id;
        update qST;

        // create service request (Case) - parent
        Case parentCase = new Case();
        parentCase.Incap311__Service_Type_Version__c = testSTVersion.Id;
        parentCase.Incap311__Location__latitude__s = 25.0;
        parentCase.Incap311__Location__longitude__s = 25.0;
        parentCase.Status = 'Open';
        insert parentCase;

        // need duplicate cases
        Case dupe1 = new Case();
        dupe1.Incap311__Service_Type_Version__c = testSTVersion.Id;
        dupe1.Incap311__Location__latitude__s = 25.0;
        dupe1.Incap311__Location__longitude__s = 25.0;
        dupe1.Status = 'Open';
        dupe1.Incap311__Duplicate_Parent__c = parentCase.Id;
        insert dupe1;

        Case dupe2 = new Case();
        dupe2.Incap311__Service_Type_Version__c = testSTVersion.Id;
        dupe2.Incap311__Location__latitude__s = 25.0;
        dupe2.Incap311__Location__longitude__s = 25.0;
        dupe2.Status = 'Open';
        dupe2.Incap311__Duplicate_Parent__c = parentCase.Id;
        insert dupe2;

        Test.startTest();
        // update parent case
        System.debug('@@@@ updating parent case...');
        Case qCase = [SELECT Id, Status FROM Case WHERE Id = :parentCase.Id];
        qCase.Status = 'Escalated';
        update qCase;

        Test.stopTest();

        // assert duplicate cases
        List<Case> qDupes = [SELECT Id, Status FROM Case WHERE Id = :dupe1.Id OR Id = :dupe2.Id];
        System.assertEquals('Duplicate (Escalated)', qDupes[0].Status);
        System.assertEquals('Duplicate (Escalated)', qDupes[1].Status);
    } 




    //=============================================================================================================================================================

    @istest
    static void testMethod1() {
        Contact cont;
        Service_Type__c serviceType1;
        Case caseRrd;
        Case caseRrd1;
        List<case> caseRrdList;
        List<Question__c> flexQuestList;
        //  List<FlexNote__c> AnswersList;
        List<Service_Type_Version_Question__c> verQuestJuncList;   
        String APIKey;

        //@testSetup
        //static void dataSetup() {

        // create contact
        Contact con = new Contact(FirstName = 'Bruno', LastName = 'Mars', email = 'testContact@abc.com', Phone = '1234567890');
        insert con;
        cont = con;

        // create decode object
        Decode_Object__c obj = new Decode_Object__c(code__c = 'A123',value__c = 'this is a test ans');
        insert obj;

        // create service request type        
        Service_Type__c svcType = new Service_Type__c(Service_Type_Code__c =' 123');  //,Object__c = 'Case',Service_Name__c = 'Abandoned Vehicle- On Private Property',Default_Status__c = 'New',Default_Priority__c = 'Standard',Default_Method__c = 'Phone',SR_Alert_Message__c = 'Test Message');
        svcType.Service_Name__c = 'Abandoned Vehicle- On Private Property';
        svcType.Is_Bulk_Type__c = true;
        svcType.Schedule_Type__c = 'Items';
        svcType.Service_Type_Code__c = 'BULKCOLL' ;
        insert svcType;
        serviceType1 = svcType;

        // create service request type version
        Service_Type_Version__c stVer = new Service_Type_Version__c();
        //stVer.Name = 'Test Version';
        stVer.Service_Name__c = 'Test Version';
        stVer.Service_Type__c = svcType.Id;
        stVer.Version_Number__c = 1;
        stVer.Is_Draft__c = false;
        stVer.Version_Code__c = '123';
        stVer.Version_Name__c = 'abc';
        insert stVer;

        svcType.Active_Service_Type_Version__c = stVer.Id;
        update svcType;

        // create questions
        flexQuestList = new List<Question__c>();

        Question__c fQuestion = new Question__c(
            Object_Name__c = 'Case',
            Question__c = 'This is the test Question',
            Data_Type__c = 'MultiPicklist' ,
            Answer_Values__c = 'test1:a1,test2:a2',
            Flex_Question_Code__c = '123'
        );//,Answer_Values__c = 'test1:a1,test2:a2');//Question__c = 'This is the test Question'

        Question__c fQuestion1 = new Question__c(
            Object_Name__c = 'Case',
            Question__c = 'This is the test',
            Data_Type__c = 'Text',
            Flex_Question_Code__c = '456'
        );//,Answer_Values__c = 'test1:a1,test2:a2');//,Question__c = 'This is the test'

        Question__c fQuestion2 = new Question__c(
            Object_Name__c = 'Case',
            Question__c = 'This is the test picklist',
            Data_Type__c = 'Picklist', 
            Answer_Values__c = 'test1:a1,test2:a2',
            Flex_Question_Code__c = '789'
        );//,Answer_Values__c = 'test1:a1,test2:a2');//Question__c = 'This is the test picklist'

        flexQuestList.add(fQuestion);
        flexQuestList.add(fQuestion1);
        flexQuestList.add(fQuestion2);

        insert flexQuestList;

        // relate questions to service type version (junction object is Service_Type_Version_Question__c)
        verQuestJuncList = new List<Service_Type_Version_Question__c>();


        Service_Type_Version_Question__c typeVerQRelation = new Service_Type_Version_Question__c(Service_Type_Version__c = stVer.Id,Question__c = fQuestion.Id, Override_Order__c = 1, Is_Required__c = false);

        Service_Type_Version_Question__c typeVerQRelation1 = new Service_Type_Version_Question__c(Service_Type_Version__c = stVer.Id,Question__c = fQuestion2.Id, Override_Order__c = 1);

        Service_Type_Version_Question__c typeVerQRelation2 = new Service_Type_Version_Question__c(Service_Type_Version__c = stVer.Id,Question__c = fQuestion1.Id, Override_Order__c = 1);

        verQuestJuncList.add(typeVerQRelation);
        verQuestJuncList.add(typeVerQRelation1);
        verQuestJuncList.add(typeVerQRelation2);

        insert verQuestJuncList;

        caseRrdList = new list<case>();

        Case c = new Case(Origin = 'Phone', Status = 'New', ContactId = con.Id, Service_Type_Version__c = stVer.Id);
        insert c;      
        caseRrd = c;
        Base311_DuplicateRequestsUtil.findModifiedFieldsCase(caseRrd,c);

        caseRrdList.add(caseRrd);

        Case c2 = new Case(Origin = 'Phone', Status = 'Open', LegacyID__c = 'CSR-test', ContactId = con.Id, Service_Type_Version__c = stVer.Id);
        insert c2;   
        caseRrd1 = c;

        Date tempD = Date.today().addDays(1);
        Schedule__c s1 = new Schedule__c(
            Capacity__c = 20,
            Zone__c = '07',
            Schedule_Date__c = tempD,
            Item_Count__c = 0,
            No_Service__c = false,
            Service_Type__c = svcType.Id
        );
        insert s1;        



        Test.startTest();

        Contact co = [Select id,name from contact LIMIT 1];
        System.debug('con>>' + co);

        List<Case> cslist = [Select id, Origin, Duplicate_Parent__c from Case limit 2];
        System.debug('>>' + cslist);

        Service_Activity__c sa = new Service_Activity__c();
        sa.Service_Request__c = cslist[0].id;
        sa.Description__c = 'test';
        insert sa;
        Service_Activity__c saCompare =  sa;

        Service_Question__c sq = new Service_Question__c();
        sq.Service_Request__c = cslist[0].id;
        sq.Answer__c = 'test';
        insert sq;
        Service_Question__c sqCompare = sq;

        cslist[0].Duplicate_Parent__c = cslist[1].id;
        update cslist[0];

        cslist[0].Origin = 'Email';
        update cslist;

        // update a field on the SQ
        sq.Answer__c = 'updated';
        update sq;

        Base311_DuplicateRequestsUtil.FindModifiedFieldsSRQuestions(sq, sqCompare);

        Service_Question__c sq2 = new Service_Question__c();
        sq2.Service_Request__c = cslist[0].id;
        sq2.Answer__c = 'test';
        insert sq2;

        // update a field on the SA
        sa.Description__c = 'updated';
        update sa;

        Base311_DuplicateRequestsUtil.findModifiedFieldsSRActivity(sa,saCompare);

        Service_Activity__c sa2 = new Service_Activity__c();
        sa2.Service_Request__c = cslist[0].id;
        sa2.Description__c = 'test';
        insert sa2;

        cslist[1].Status = 'Closed';
        update cslist[1];

        Test.stopTest();
    }
}