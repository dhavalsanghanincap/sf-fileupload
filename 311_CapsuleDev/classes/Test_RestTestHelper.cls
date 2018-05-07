@isTest
global class Test_RestTestHelper {
    
    private static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
           Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
           randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }
    
    global static User user() {
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        
        insert u;
        
        return u;
    }
    
    global static Transfer_Service_Request_Type__c tsrt(Id fromST, Id toST) {
        Transfer_Service_Request_Type__c rec = new Transfer_Service_Request_Type__c(To_Service_Type__c = toST, From_Service_Type__C = fromST);
        insert rec;
        return rec;
    }
    
    global static Contact contact() {
        return contact(null);
    }
    
    global static Activity_Question__c activityQuestion(Id srId, Id saId, Id oqId, String answer) {
        Activity_Question__c aq = new Activity_Question__c(
        	Service_Request__c = srId,
            Service_Activity__c = saId,
            Outcome_Question__c = oqId,
            Answer__c = answer
        );
        
        insert aq;
        
        return aq;
    }
    
    global static Contact contact(Id uId) {
        Contact c = new Contact(
            FirstName = generateRandomString(5), LastName = generateRandomString(5), 
            Email = generateRandomString(5) + '@' + generateRandomString(5) + '.com',
            Service_Queue_Member_User__c = uId
        );
        insert c;
        return c;
    }

    global static Activity_Outcome__c stvaActivityOutcome(Id stvaId, Id oId) { 
        Activity__c a = activity(generateRandomString(5));
        Activity_Outcome__c ao = new Activity_Outcome__c(Activity__c = a.Id, Outcome__c = oId, Service_Type_Version_Activity__c = stvaId);
        
        insert ao;
        
        return ao;
    }
    
    global static Activity_Outcome__c activityOutcome(Id aId, Id oid) {
        // @TODO: This will need to eventually be configuration
        // for a specific service type version
        Service_Type_Version_Activity__c stva = serviceTypeVersionActivity(aId, sericeTypeVersionAndVersion().Id);
        
        Activity_Outcome__c ao = new Activity_Outcome__c(Activity__c = aId, Outcome__c = oId, Service_Type_Version_Activity__c = stva.Id);
        
        insert ao;
        
        return ao;
    }
    
    global static Response__c response() {
        Response__c r = new Response__c(Long_Response_Text__c = 'Some test text', Response_Code__c = generateRandomString(5));
        insert r;
        return r;
    }
    
    global static Outcome_Question__c oq(Id aoId, Id qId) {
        Outcome_Question__c oq = new Outcome_Question__c(
        Service_Type_Version_Activity_Outcome__c = aoId,
            Activity_Outcome__c = outcome().Id,
            Question__c = qId
        );
        insert oq;
        return oq;
    }
    
    global static Activity_Outcome_Response__C aor(Id respId, Id aoId) {
        Activity_Outcome_Response__c aor = new Activity_Outcome_Response__c(Canned_Response__c = respId, Activity_Outcome__c = aoId);
        insert aor;
        return aor;
    }
    
    global static Service_Question__c serviceQuestion(Id caseId, Id typeQuestionId) {
        Service_Question__c sq = new Service_Question__c(
            Service_Request__c = caseId, Service_Type_Version_Question__c = typeQuestionId
        );
        
        insert sq;
        
        return sq;
    }
    
    global static Service_Activity__c service(Id caseId, Id stvaId) {
        Service_Activity__c service = new Service_Activity__c(
            Service_Request__c = caseId, Service_Type_Version_Activity__c = stvaId,
            Status__c = 'Not Started'
        );
        
        insert service;
        
        return service;
    }

    global static Question__c question() {
        return question(null, 'Text', null);
    }

    global static Question__c question(String question, String dataType, String questionHint) {
        Question__c q = new Question__c(
            Question__c = question, 
            Data_Type__c = dataType, 
            Hint_Text__c = questionHint,
            Flex_Question_Code__c = generateRandomString(5)
        );
        insert q;
        return q;
    }
    
    global static Activity__c activity() {
        Activity__c a = new Activity__c(Activity_Code__c = '123');
        insert a;
        return a;
    }
    
    global static Activity__c activity(String actCode) {
    Activity__c a = new Activity__c(Activity_Code__c = actCode);
        insert a;
        return a;
    }
    
    global static Service_Type_Version_Activity__c serviceTypeVersionActivity(Id actId, Id stvId) {
        Service_Type_Version_Activity__c stva = new Service_Type_Version_Activity__c(
            Service_Type_Version__c = stvId, Order__c = 1, Activity__c = actId
        );
        
        insert stva;
        return stva;
    }
    
    global static Service_Type_Version_Activity__c serviceTypeVersionActivity(Id actId, Id stvId, Integer stvaOrder) {
        Service_Type_Version_Activity__c stva = new Service_Type_Version_Activity__c(
            Service_Type_Version__c = stvId, Order__c = stvaOrder, Activity__c = actId
        );
        
        insert stva;
        return stva;
    }
    
    global static Service_Type_Version_Question__c serviceTypeVersionQuestion(Id qId, Id serviceTypeVersionId) {
        return serviceTypeVersionQuestion(qId, serviceTypeVersionId, null);
    }
    
    global static Service_Type_Version_Question__c serviceTypeVersionQuestion(Id qId, Id serviceTypeVersionId, Integer overrideOrder) {
        return serviceTypeVersionQuestion(qId, serviceTypeVersionId, overrideOrder, true);
    }
    
    Static Integer overrideOrderPlaceholder = 20;
    global static Service_Type_Version_Question__c serviceTypeVersionQuestion(Id qId, Id serviceTypeVersionId, Integer overrideOrder, Boolean webIntake) {
        if(overrideOrder == null){
            overrideOrder = overrideOrderPlaceholder;
            overrideOrderPlaceholder++;
        }
        Service_Type_Version_Question__c q = new Service_Type_Version_Question__c(
            Question__c = qId, Service_Type_Version__c = serviceTypeVersionId, Override_Order__c = overrideOrder,
            Citizen_Web_Intake__c = webIntake, Dependencies__c = null
        );
        insert q;

        q = [Select Id, Name, Question__c, Service_Type_Version__c, Override_Order__c, Citizen_Web_Intake__c, Question__r.Data_Type__c, Override_Answer_Values__c, Question__r.Answer_Values__c From Service_Type_Version_Question__c Where Id = :q.Id];

        return q;
    }
    
        global static Outcome_Question__c outcomeQuestion(Id qId, Id activityOutcomeId) {
        return outcomeQuestion(qId, activityOutcomeId, null);
    }
    
    global static Outcome_Question__c outcomeQuestion(Id qId, Id activityOutcomeId, Integer overrideOrder) {
        return outcomeQuestion(qId, activityOutcomeId, overrideOrder, true);
    }
    
    global static Outcome_Question__c outcomeQuestion(Id qId, Id activityOutcomeId, Integer overrideOrder, Boolean webIntake) {
        Service_Type_Version__c stv = sericeTypeVersionAndVersion();
        Activity__c a = activity();
        Service_Type_Version_Activity__c stva = serviceTypeVersionActivity(a.Id, stv.Id);
        Activity_Outcome__c ao = activityOutcome(a.Id, activityOutcomeId);
        
        if(overrideOrder == null){
            overrideOrder = overrideOrderPlaceholder;
            overrideOrderPlaceholder++;
        }
        Outcome_Question__c q = new Outcome_Question__c(
            Question__c = qId, Activity_Outcome__c = activityOutcomeId, Override_Order__c = overrideOrder,
            Dependencies__c = null, Service_Type_Version_Activity_Outcome__c = ao.Id
        );
        insert q;

        q = [Select Id, Name, Question__c, Activity_Outcome__c, Override_Order__c, Question__r.Data_Type__c, Override_Answer_Values__c, Question__r.Answer_Values__c From Outcome_Question__c Where Id = :q.Id];

        return q;
    }
    
    Static Integer serviceName = 0;
    global static Service_Type__c serviceType() {
        Service_Type__c st = new Service_Type__c(Service_Type_Code__c = generateRandomString(5), Service_Name__c = generateRandomString(35)+String.ValueOf(serviceName), Schedule_Duplicate_Detection__c = false);
        insert st;
        serviceName++;
        return st;
    }
    
    global static Service_Type_Version__c sericeTypeVersionAndVersion() {
        return serviceTypeVersion(serviceType().Id);
    }
    
    global static Service_Type_Version__c sericeTypeVersionAndVersion(String name) {
        return serviceTypeVersion(serviceType().Id, name);
    }
    
    global static Service_Type_Version__c serviceTypeVersion(Id stId) {
        return serviceTypeVersion(stId, null);
    }
    
    global static Service_Type_Version__c serviceTypeVersion(Id stId, String name) {
        return serviceTypeVersion(stId, name, null);
    }
    
    global static Service_Type_Version__c serviceTypeVersion(Id stId, String name, Boolean allowWebIntake) {
        return serviceTypeVersion(stId, name, allowWebIntake, null);
    }
    global static Service_Type_Version__c serviceTypeVersion(Id stId, String name, Boolean allowWebIntake, Boolean active) {
        if(allowWebIntake == null) {
            allowWebIntake = false;
        }
        
        if(active == null) {
            active = false;
        }
        
        Service_Type_Version__c stv = new Service_Type_Version__c(
            Service_Type__c = stId, Allow_Citizen_Web_Intake__c = allowWebIntake, Is_Draft__c = !active, Service_Name__c = generateRandomString(5),
            SLA_Type__c = 'Hours', Version_Code__c = generateRandomString(5), Version_Name__c =  generateRandomString(5), SLA__c = 5.0, Version_Number__c = versionNumber
        );
        insert stv;
        versionNumber++;

        stv = [
            SELECT 
                Id, Name, Service_Name__c, Service_Type__c, Service_Type__r.External_Description__c, 
                Keywords__c, Group__c, Has_Metadata__c, Resolution_Type__c, Allow_Citizen_Web_Intake__c, 
                Is_Draft__c, SLA_Type__c, Is_Activatable__c, Service_Type__r.Service_Type_Code__c,
                Enable_Business_Hours__c, Service_Type__r.Schedule_Duplicate_Detection__c
            FROM 
                Service_Type_Version__c 
            WHERE 
                Id = :stv.Id
        ];

        return stv;
    }
    
    Static Decimal versionNumber = 0;
  
    
    global static Case serviceRequest() {
        return serviceRequest(null);
    }
    
    global static Case serviceRequest(Id stvId) {
        return serviceRequest(stvId, null);
    }
    
    global static Case serviceRequest(Id stvId, Datetime requestedDatetime) {
        return serviceRequest(stvId, requestedDatetime, null);
    }
    
    global static Service_Activity__c serviceActivity(Id stvaId, Id cId) {
        Service_Activity__c sa = new Service_Activity__c(
            Service_Type_Version_Activity__c = stvaId, Service_Request__c = cId, Status__c = 'Not Started'
        );
        insert sa;
        return sa;
    }
    
    global static Case serviceRequest(Id stvId, Datetime requestedDatetime, String status) {
        Case c = new Case(
            Service_Type_Version__c = stvId, Requested_Date_Time__c = requestedDatetime, Status = status
        );
        insert c;
        c.recalculateFormulas();
        return c;
    }
    
    global static Zone__c zone(Id recordType) {
        return zone(null, recordType);
    }
    
    global static Zone__c zone(String value) {
        return zone(value, Schema.SObjectType.Zone__c.getRecordTypeInfosByName().get('Asset').getRecordTypeId());
    }
    
    global static Zone__c zone(String value, Id recordType) {
        Zone__c z = new Zone__c(Value__c = value, RecordTypeId = recordType);
        insert z;
        z.recalculateFormulas();
        return z;
    }
    
    global static Service_Type_Queue_Zone__c serviceTypeQueueZone(Id stvId, Id zId, Id sqId) {
        Service_Type_Queue_Zone__c stqz = new Service_Type_Queue_Zone__c(Service_Type_Version__c = stvId, Zone__c = zId, Service_Queue__c = sqId);
        insert stqz;
        return stqz;
    }
    
    global static Service_Queue__c serviceQueue(Id aId, Boolean isCoordinator) {
        Service_Queue__c sq = new Service_Queue__c(Account__c = aId, Is_Coordinator__c = isCoordinator);
        insert sq;
        return sq;
    }
    
    global static Service_Queue__c serviceQueue(Id aId) {
        return serviceQueue(aId, false);
    }
    
    global static Service_Queue__c serviceQueue() {
        return serviceQueue(null);
    }
    
    global static Service_Queue_Member__c serviceQueueMember(Id sqId, Id contactId) {
        Service_Queue_Member__c sqm = new Service_Queue_Member__c(Contact__c = contactId, Service_Queue__c = sqId);
        insert sqm;
        return sqm;
    }
    
    global static Account account(String name) {
        Account a = new Account(Name = name);
        insert a;
        return a;
    }

    global static Schedule__c schedule(String zone, String serviceType) {
        return schedule(zone, serviceType, 0.0, Date.today().addDays(3));
    }

    global static QueueSobject queue(String sObjectType) {
        Group g1 = new Group(Name=generateRandomString(15), type='Queue');
        insert g1;
        
        QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = sObjectType);
        insert q1;
        
        return q1;
    }

    global static Reallocate_Service_Request_Type__c  reallocateServiceType(Id queueId, Id stId) {
        Reallocate_Service_Request_Type__c rsrt = new Reallocate_Service_Request_Type__c(Queue_Id__c = queueId, Service_Type__c = stId);
        insert rsrt;
        return rsrt;
    }

    global static Outcome__c outcome() {
        Outcome__c o = new Outcome__c(Outcome_Code__c = generateRandomString(5));
        insert o;
        return o;
    }
    
    global static Outcome_Question__c outcomeQuestion() {
        Activity__c a = activity();
        Question__c q = question();
Outcome__c o = outcome();
    Activity_Outcome__c ao = activityOutcome(a.Id, o.Id);
        
        Outcome_Question__c oq = new Outcome_Question__c(
            Service_Type_Version_Activity_Outcome__c = ao.Id,
            Question__c = q.Id, Activity_Outcome__c = o.Id
        );
        
        insert oq;
        
        return oq;
    }
    
    global static Duplicate_Service_Type_Mapping__c duplicateServiceTypeMapping(Id fromSTV, Id toST) {
        Duplicate_Service_Type_Mapping__c dstm = new Duplicate_Service_Type_Mapping__c(
        To_Service_Type__c = toST,
            From_Service_Type_Version__c = fromSTV
        );
        
        insert dstm;
        
        return dstm;
    }
    
    global static Schedule__c schedule(String zone, String serviceType, Decimal capacity, Date scheduleDate) {
        Schedule__c s = new Schedule__c (
            Capacity__c = capacity,
            Zone__c = zone, 
            Service_Type__c = serviceType,
            Schedule_Date__c = scheduleDate,
            Incap311__Item_Count__c = 10
        );
        insert s;

        s = [
          Select 
            Id, 
            Name, 
            Capacity__c,
            Zone__c,
            Schedule_Date__c, 
            Item_Count__c, 
            Day_of_Week__c,
            No_Service__c
          From 
            Schedule__c 
          Where 
            Id = :s.Id
        ];
        return s;
    }
    
    global static Correspondence__c Correspondence(String RecordTypeName) {
       // Id devRecordTypeId = Schema.SObjectType.Correspondence__c.getRecordTypeInfosByName().get('Service_Activity').getRecordTypeId();
        Correspondence__c c = new Correspondence__c (
            Body__c = 'Test Body',
            Closing__c = 'Test Closing', 
            Intro__c = 'Test Intro',
            Type__c = '',
            Incap311__Correspondence_Code__c = 'TestCODE'
            //RecordTypeId = devRecordTypeId
        );
        insert c;
        return c;
    }
    
    global static Activity_Correspondence__c ActivityCorrespondence() {
        Service_Type_Version__c stv = Test_RestTestHelper.sericeTypeVersionAndVersion();
        Activity__c a = Test_RestTestHelper.activity();
        Service_Type_Version_Activity__c stva = Test_RestTestHelper.serviceTypeVersionActivity(a.Id, stv.Id);
        Case c = Test_RestTestHelper.serviceRequest(stv.Id);
        Service_Activity__c sa = Test_RestTestHelper.serviceActivity(stva.Id, c.Id);
        Service_Activity__c sa2 = sa.clone();
        Outcome__c o = Test_RestTestHelper.outcome();
        Activity_Outcome__c ao = Test_RestTestHelper.activityOutcome(a.Id, o.Id);
        
        Correspondence__c Correspondence = Correspondence('Service_Activity');
        
        Activity_Correspondence__c ac = new Activity_Correspondence__c();
        ac.Incap311__Service_Type_Version_Activity__c = stva.Id;
        ac.Incap311__Correspondence__c = Correspondence.Id;
        ac.Incap311__Type__c = 'Complete';
        ac.Incap311__Activity_Outcome__c = o.Outcome_Code__c;
        ac.active__c = true;
        return ac;
    }


}