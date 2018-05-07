public with sharing class TestHelper {
    public static Contact cont;
    public static Incap311__Service_Type__c serviceType1;
    public static Case caseRrd;
    public static List<case> caseRrdList;
    public static List<Incap311__Question__c> flexQuestList;
    //public static List<FlexNote__c> AnswersList;
    public static List<Incap311__Service_Type_Version_Question__c> verQuestJuncList;   
    public static String APIKey;

    private static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
           Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
           randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }

    public static void createData(){
        Account a = new Account(Name = 'Mars Inc.');
        insert a;

        // create contact
        Contact con=new Contact(FirstName='Bruno', LastName='Mars', email='testContact@abc.com', Phone='1234567890');
        insert con;
        cont = con;
        
        // create contact
        Contact con2=new Contact(FirstName='Bruno2', LastName='Mars2', email='testContact2222@ab56c.com', Phone='45453465');
        insert con2;

        // create decode object
        Incap311__Decode_Object__c obj = new Incap311__Decode_Object__c(Incap311__code__c='A123',Incap311__value__c='this is a test ans');
        insert obj;

        // create service request type        
        Incap311__Service_Type__c svcType = new Incap311__Service_Type__c(Incap311__Service_Type_Code__c =' 123');  //,Object__c='Case',Service_Name__c='Abandoned Vehicle- On Private Property',Default_Status__c='New',Default_Priority__c='Standard',Default_Method__c='Phone',SR_Alert_Message__c='Test Message');
        svcType.Incap311__Service_Name__c = 'Abandoned Vehicle- On Private Property';
        svcType.Incap311__Is_Bulk_Type__c = true;
        svcType.Incap311__Schedule_Type__c = 'Items';
        svcType.Incap311__Service_Type_Code__c ='BULKCOLL' ;
        svcType.Incap311__Schedule_Matching__c = '{"zone" : {"layer_name":"PWD Districts", "layer_value":"value"},"days_of_week" : {"layer_name":"PWD Recycling Day", "layer_value":"value", "format":"d"}}';
        svcType.Incap311__Schedulable_Requests_Limit_Month__c = null;
        svcType.Incap311__Schedulable_Requests_Limit_Year__c = null;
        insert svcType;
        serviceType1 = svcType;

        // create service request type version
        Incap311__Service_Type_Version__c stVer = new Incap311__Service_Type_Version__c();
        //stVer.Name = 'Test Version';
        stVer.Incap311__Service_Name__c = 'Test Version';
        stVer.Incap311__Service_Type__c = svcType.Id;
        stVer.Incap311__Version_Number__c = 1;
        stVer.Incap311__Is_Draft__c = false;
        stVer.Incap311__Version_Code__c = '123';
        stVer.Incap311__Version_Name__c = 'abc';
        stVer.Incap311__Allow_Citizen_Web_Intake__c = true;
        stVer.Incap311__Layer_Information__c = '[{"layer_name": "PWD Recycling Day", "layer_value": "value"}, {"layer_name": "PWD Recycling Day", "layer_value": "attributes.TRASHDAY"}]';
        stVer.Incap311__Alert_Validations__c = '[{"dependentOn":{"clause":"OR","conditions":[{"left":"ServiceQuestionCode[123].Incap311__Answer__c","op":"eq","right":"a1"}]},"message":"Alert Validation for question 123"}]';
        stVer.Incap311__Validations__c = '[{"dependentOn":{"clause":"OR","conditions":[{"left":"ServiceQuestionCode[789].Incap311__Answer__c","op":"eq","right":"a1"}]},"message":"Validation for question 789"}]';
        insert stVer;

        svcType.Incap311__Active_Service_Type_Version__c = stVer.Id;
        update svcType;

        // create questions
        flexQuestList = new List<Incap311__Question__c>();

        Incap311__Question__c fQuestion = new Incap311__Question__c(
            Incap311__Object_Name__c='Case',
            Incap311__Question__c='This is the test Question',
            Incap311__Data_Type__c='MultiPicklist' ,
            Incap311__Answer_Values__c= '[{"key":"test1", "value":"a1"}, {"key":"test2", "value": "a2"}]',
            Incap311__Flex_Question_Code__c = '123'
        );//,Answer_Values__c='test1:a1,test2:a2');//Question__c='This is the test Question'

        Incap311__Question__c fQuestion1 = new Incap311__Question__c(
            Incap311__Object_Name__c='Case',
            Incap311__Question__c='This is the test',
            Incap311__Data_Type__c='Text',
            Incap311__Flex_Question_Code__c = '456'
        );//,Incap311__Answer_Values__c='test1:a1,test2:a2');//,Question__c='This is the test'

        Incap311__Question__c fQuestion2 = new Incap311__Question__c(
            Incap311__Object_Name__c='Case',
            Incap311__Question__c='This is the test picklist',
            Incap311__Data_Type__c='Picklist', 
            Incap311__Answer_Values__c='[{"key":"test1", "value":"a1"}, {"key":"test2", "value": "a2"}]',
            Incap311__Flex_Question_Code__c = '789'
        );//,Answer_Values__c='test1:a1,test2:a2');//Question__c='This is the test picklist'

        flexQuestList.add(fQuestion);
        flexQuestList.add(fQuestion1);
        flexQuestList.add(fQuestion2);

        insert flexQuestList;

        // relate questions to service type version (junction object is Incap311__Service_Type_Version_Question__c)
        verQuestJuncList = new List<Incap311__Service_Type_Version_Question__c>();


        Incap311__Service_Type_Version_Question__c typeVerQRelation = new Incap311__Service_Type_Version_Question__c(Incap311__Service_Type_Version__c=stVer.Id,Incap311__Question__c=fQuestion.Id, Incap311__Override_Order__c=1, Incap311__Is_Required__c=false);

        Incap311__Service_Type_Version_Question__c typeVerQRelation1 = new Incap311__Service_Type_Version_Question__c(Incap311__Service_Type_Version__c=stVer.Id,Incap311__Question__c=fQuestion2.Id, Incap311__Override_Order__c=1);

        Incap311__Service_Type_Version_Question__c typeVerQRelation2 = new Incap311__Service_Type_Version_Question__c(Incap311__Service_Type_Version__c=stVer.Id,Incap311__Question__c=fQuestion1.Id, Incap311__Override_Order__c=1);

        verQuestJuncList.add(typeVerQRelation);
        verQuestJuncList.add(typeVerQRelation1);
        verQuestJuncList.add(typeVerQRelation2);

        insert verQuestJuncList;

        caseRrdList=new list<case>();

        Case c=new Case(Origin='Phone', Status='New', ContactId=con.Id, Incap311__Service_Type_Version__c=stVer.Id);
        insert c;      
        caseRrd=c;

        caseRrdList.add(caseRrd);

        Case c2=new Case(Origin='Phone', Status='Open', Incap311__LegacyID__c='CSR-test', ContactId=con.Id, Incap311__Service_Type_Version__c=stVer.Id);
        insert c2;      

        Date tempD = Date.today().addDays(1);
        Incap311__Schedule__c s1 = new Incap311__Schedule__c(
            Incap311__Capacity__c = 20,
            Incap311__Zone__c = '07',
            Incap311__Schedule_Date__c = tempD,
            Incap311__Item_Count__c = 0,
            Incap311__No_Service__c = false,
            Incap311__Service_Type__c = svcType.Id
        );
        insert s1;

        Incap311__Service_Queue__c sq = new Incap311__Service_Queue__c(Incap311__Is_Coordinator__c = false);
        insert sq;

        Incap311__Service_Queue_Member__c sqm = new Incap311__Service_Queue_Member__c();
        insert sqm;

        Incap311__Distributions__c dist = new Incap311__Distributions__c(Incap311__Name__c='Test Dist', Incap311__Is_System_Default__c = true);
        insert dist;

        Incap311__Distribution_Member__c member = new Incap311__Distribution_Member__c (Incap311__Contact__c = con.Id);
        insert member;

        Incap311__Distribution_Member_Zone_Type__c distMember = new Incap311__Distribution_Member_Zone_Type__c(Incap311__Distribution__c = dist.Id, Incap311__Distribution_Member__c = member.Id);
        insert distMember;
        
         Incap311__Distribution_Member__c member2 = new Incap311__Distribution_Member__c (Incap311__Contact__c = con2.Id);
        insert member2;
        
        Incap311__Distribution_Member_Zone_Type__c distMember2 = new Incap311__Distribution_Member_Zone_Type__c(Incap311__Distribution__c = dist.Id, Incap311__Distribution_Member__c = member2.Id, Incap311__Service_Type__c = svcType.Id);
        insert distMember2;

        //caseRrdList.add(c2);
        /*        
    AnswersList=new list<FlexNote__c>();

    FlexNote__c fn=new FlexNote__c(Case__c=c.Id,FlexNote_Question__c=fNQuestion.Id,Answer__c='test1:a1',Questions__c=fNQuestion.Question__c);//Question__c=fNQuestion.Question__c //Is_Answer__c='test1:a1',
    FlexNote__c fn1=new FlexNote__c(Case__c=c.Id,FlexNote_Question__c=fNQuestion1.Id,Answer__c='test1:a1',Questions__c=fNQuestion1.Question__c);//,Is_Answer__c='test1:a1'..,Question__c=fNQuestion.Question__c,
    FlexNote__c fn2=new FlexNote__c(Case__c=c2.Id,FlexNote_Question__c=fNQuestion.Id,LegacyId__c='CSR-test1',Answer__c='test1:a1',CodeDescriptionSourcePart1__c='CODE1,CODE2',CodeDescriptionSourcePart2__c='value1,othervalue',Questions__c=fNQuestion.Question__c);//Question__c=fNQuestion.Question__c //Is_Answer__c='test1:a1',
    FlexNote__c fn3=new FlexNote__c(Case__c=c2.Id,FlexNote_Question__c=fNQuestion1.Id,LegacyId__c='CSR-test2422',Answer__c='otherwanswertest1:a1',Questions__c=fNQuestion1.Question__c);//,Is_Answer__c='test1:a1'..,Question__c=fNQuestion.Question__c,

    AnswersList.add(fn);
    AnswersList.add(fn1);    
    AnswersList.add(fn2);
    AnswersList.add(fn3);    
    insert AnswersList;

    OUC_Activity__c oucActivity= new OUC_Activity__c(Case__c=c.Id);
    insert oucActivity;


    Service_Request_History__c h = new Service_Request_History__c(Origin__c='Phone',Status__c='New',DateTimeOpened__c=DateTime.valueofGMT('2015-01-01 00:01:02'),IsClosed__c=true);
    insert h;
    Service_Request_History__c h2 = new Service_Request_History__c(Origin__c='Phone',Status__c='New',DateTimeOpened__c=DateTime.valueofGMT('2015-01-01 00:02:03'),IsClosed__c=false);
    insert h2;

    Map<String,String> code = new Map<String,String>();
    code.put('FYTRS','This is a test');
    List<Flex_Note_History__c> hL= new List<Flex_Note_History__c>();
    Flex_Note_History__c fnh=new Flex_Note_History__c(CodeDescription__c= JSON.serialize(code),Service_Request_History__c=h.Id,Flex_Note_Id__c=fNQuestion.Id,Answer__c='test1:a1',Questions__c=fNQuestion.Question__c);//Question__c=fNQuestion.Question__c //Is_Answer__c='test1:a1',
    Flex_Note_History__c fnh1=new Flex_Note_History__c(CodeDescription__c= JSON.serialize(code),Service_Request_History__c=h.Id,Flex_Note_Id__c=fNQuestion1.Id,Answer__c='test1:a1',Questions__c=fNQuestion.Question__c);//,Is_Answer__c='test1:a1'..,Question__c=fNQuestion.Question__c,
    Flex_Note_History__c fnh2=new Flex_Note_History__c(CodeDescriptionSourcePart1__c='CODE1,CODE2',CodeDescriptionSourcePart2__c='value1,Value22',Service_Request_History__c=h.Id,Flex_Note_Id__c='CSR-test1234',Answer__c='test1:a1',Questions__c=fNQuestion.Question__c);//,Is_Answer__c='test1:a1'..,Question__c=fNQuestion.Question__c,

    hL.add(fnh);
    hL.add(fnh1);
    hl.add(fnh2);

    insert hL; 

    OUC_Activity_History__c oucActivity2= new OUC_Activity_History__c(Service_Request_History__c=h.Id);
    insert oucActivity2;

    OUC_Activity_History__c oucActivity3= new OUC_Activity_History__c(Service_Request_History__c=h2.Id);
    insert oucActivity3;
*/ 
    }

    public static List<Incap311.Base311_ESRI_Layer> genMockLayerInformation() {
        List<Incap311.Base311_ESRI_Layer> esriList = new List<Incap311.Base311_ESRI_Layer>();

        Incap311.Base311_ESRI_Layer esriRec = new Incap311.Base311_ESRI_Layer();
        esriRec.layerName = 'PWD Recycling Day';
        esriRec.value = 'MF';

        Incap311.Base311_ESRI_Layer esriRec2 = new Incap311.Base311_ESRI_Layer();
        esriRec2.layerName = 'PWD Districts';
        esriRec2.value = '07';

        esriList.add(esriRec);
        esriList.add(esriRec2);
        return esriList;
    }

    public static List<Incap311.Base311_Location> generateMockLocationData() {
        String testBody = '[{"address": "50 Middle St","lat": "-71.055860588399995","lng": "42.3318186686","zipCode": "02127",' +
            '"neighbourhood": "South Boston","parcel": "0700187000","precinctWard": "0705",' +
            '"addressId": "2756","streetId": "2756",' +
            '"ward": "07","xCoord": "776258.900415","yCoord": "2946252.73562"}]';

        List<Incap311.Base311_Location> resp = (List<Incap311.Base311_Location>) JSON.deserialize(testBody, List<Incap311.Base311_Location>.class);
        return resp;
    }
}