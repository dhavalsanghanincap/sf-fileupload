@isTest
public class Test_Base311_Activity_Correspondence_UOW
{
    static testMethod void Test_Base311_Activity_Correspondence_UOW()
    {
         Service_Type_Version__c stv = Test_RestTestHelper.sericeTypeVersionAndVersion();
        Activity__c a = Test_RestTestHelper.activity();
        Service_Type_Version_Activity__c stva = Test_RestTestHelper.serviceTypeVersionActivity(a.Id, stv.Id);
        Case c = Test_RestTestHelper.serviceRequest(stv.Id);
        Service_Activity__c sa = Test_RestTestHelper.serviceActivity(stva.Id, c.Id);
        Outcome__c o = Test_RestTestHelper.outcome();
        
        Activity_Outcome__c ao = Test_RestTestHelper.activityOutcome(a.Id, o.Id);
        
        ao.Track_Use__c = true;
        update ao;
        
        Correspondence__c Correspondence = Test_RestTestHelper.Correspondence('Service_Activity');
        
        Activity_Correspondence__c ac = new Activity_Correspondence__c();
        ac.Incap311__Service_Type_Version_Activity__c = stva.Id;
        ac.Incap311__Correspondence__c = Correspondence.Id;
        ac.Incap311__Type__c = 'Complete';
        ac.Incap311__Activity_Outcome__c = o.Outcome_Code__c;
        ac.active__c = true;
        insert ac;
        Base311_Unit_Of_Work.mutexIdMap = new Map<String, Map<String, Set<Id>>>();
        
        sa = [ SELECT Name FROM Service_Activity__c WHERE Id = :sa.Id ];
        
        Test.starttest();
        system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@ update SA');
        sa.status__c = 'Complete';
        sa.Incap311__Activity_Outcome__c = ao.Id;
        update sa;
        
        Test.stopTest();
        
        list<Incap311__Case_Event__c> caseEvents = [Select id from Incap311__Case_Event__c where Event_Type__c = 'Complete' and Service_Request__c = :c.id];
        System.debug([Select id,Event_Type__c  from Incap311__Case_Event__c where Service_Request__c = :c.id]);
        System.assertEquals(caseEvents.size(), 1);
    }
    
    static testMethod void Test_Base311_Activity_Correspondence_UOW_neg_complete()
    {
         Service_Type_Version__c stv = Test_RestTestHelper.sericeTypeVersionAndVersion();
        Activity__c a = Test_RestTestHelper.activity();
        Service_Type_Version_Activity__c stva = Test_RestTestHelper.serviceTypeVersionActivity(a.Id, stv.Id);
        Case c = Test_RestTestHelper.serviceRequest(stv.Id);
        Service_Activity__c sa = Test_RestTestHelper.serviceActivity(stva.Id, c.Id);
        Outcome__c o = Test_RestTestHelper.outcome();
        Outcome__c o2 = Test_RestTestHelper.outcome();
        
        Activity_Outcome__c ao = Test_RestTestHelper.activityOutcome(a.Id, o.Id);
        Activity_Outcome__c ao2 = Test_RestTestHelper.activityOutcome(a.Id, o2.Id);
        
        ao.Track_Use__c = true;
        update ao;
        
        Correspondence__c Correspondence = Test_RestTestHelper.Correspondence('Service_Activity');
        
        Activity_Correspondence__c ac = new Activity_Correspondence__c();
        ac.Incap311__Service_Type_Version_Activity__c = stva.Id;
        ac.Incap311__Correspondence__c = Correspondence.Id;
        ac.Incap311__Type__c = 'Complete';
        ac.Incap311__Activity_Outcome__c = o.Outcome_Code__c;
        ac.active__c = true;
        insert ac;
        Base311_Unit_Of_Work.mutexIdMap = new Map<String, Map<String, Set<Id>>>();
        
        sa = [ SELECT Name FROM Service_Activity__c WHERE Id = :sa.Id ];
        
        Test.starttest();
        system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@ update SA');
        sa.status__c = 'Complete';
        sa.Incap311__Activity_Outcome__c = ao2.Id;
        update sa;
        
        Test.stopTest();
        System.debug(o2.Outcome_Code__c+' = '+o.Outcome_Code__c);
        list<Incap311__Case_Event__c> caseEvents = [Select id from Incap311__Case_Event__c where Event_Type__c = 'Complete' and Service_Request__c = :c.id];
        System.assertEquals(caseEvents.size(),0);
    }

    
    static testMethod void Test_Base311_Activity_Correspondence_UOWUpdate()
    {
         Service_Type_Version__c stv = Test_RestTestHelper.sericeTypeVersionAndVersion();
        Activity__c a = Test_RestTestHelper.activity();
        Service_Type_Version_Activity__c stva = Test_RestTestHelper.serviceTypeVersionActivity(a.Id, stv.Id);
        Case c = Test_RestTestHelper.serviceRequest(stv.Id);
        Service_Activity__c sa = Test_RestTestHelper.serviceActivity(stva.Id, c.Id);
        Outcome__c o = Test_RestTestHelper.outcome();
        
        Activity_Outcome__c ao = Test_RestTestHelper.activityOutcome(a.Id, o.Id);
        
        ao.Track_Use__c = true;
        update ao;
        
        Correspondence__c Correspondence = Test_RestTestHelper.Correspondence('Service_Activity');
        
        Activity_Correspondence__c ac = new Activity_Correspondence__c();
        ac.Incap311__Service_Type_Version_Activity__c = stva.Id;
        ac.Incap311__Correspondence__c = Correspondence.Id;
        ac.Incap311__Type__c = 'Update';
        ac.active__c = true;
        insert ac;
        Base311_Unit_Of_Work.mutexIdMap = new Map<String, Map<String, Set<Id>>>();
        
        sa = [ SELECT Name FROM Service_Activity__c WHERE Id = :sa.Id ];
        
        Test.starttest();
        system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@ update SA');
        sa.status__c = 'In Progress';
        update sa;
        
        Test.stopTest();
        
        list<Incap311__Case_Event__c> caseEvents = [Select id from Incap311__Case_Event__c where Event_Type__c = 'Update' and Service_Request__c = :c.id];
        System.debug([Select id,Event_Type__c  from Incap311__Case_Event__c where Service_Request__c = :c.id]);
        System.assertEquals(caseEvents.size(), 1);
    }
    
    
    static testMethod void Test_Base311_Activity_Correspondence_UOWTestActive()
    {
         Service_Type_Version__c stv = Test_RestTestHelper.sericeTypeVersionAndVersion();
        Activity__c a = Test_RestTestHelper.activity();
        Service_Type_Version_Activity__c stva = Test_RestTestHelper.serviceTypeVersionActivity(a.Id, stv.Id);
        Case c = Test_RestTestHelper.serviceRequest(stv.Id);
        Service_Activity__c sa = Test_RestTestHelper.serviceActivity(stva.Id, c.Id);
        Outcome__c o = Test_RestTestHelper.outcome();
        
        Activity_Outcome__c ao = Test_RestTestHelper.activityOutcome(a.Id, o.Id);
        
        ao.Track_Use__c = true;
        update ao;
        
        Correspondence__c Correspondence = Test_RestTestHelper.Correspondence('Service_Activity');
        
        Activity_Correspondence__c ac = new Activity_Correspondence__c();
        ac.Incap311__Service_Type_Version_Activity__c = stva.Id;
        ac.Incap311__Correspondence__c = Correspondence.Id;
        ac.Incap311__Type__c = 'Update';
        ac.active__c = false;
        insert ac;
        Base311_Unit_Of_Work.mutexIdMap = new Map<String, Map<String, Set<Id>>>();
        
        sa = [ SELECT Name FROM Service_Activity__c WHERE Id = :sa.Id ];
        
        Test.starttest();
        system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@ update SA');
        sa.status__c = 'In Progress';
        update sa;
        
        Test.stopTest();
        list<Incap311__Case_Event__c> caseEvents = [Select id from Incap311__Case_Event__c where Event_Type__c = 'Update' and Service_Request__c = :c.id];
        System.debug([Select id,Event_Type__c  from Incap311__Case_Event__c where Service_Request__c = :c.id]);
        System.assertEquals(caseEvents.size(), 0);
    }
}