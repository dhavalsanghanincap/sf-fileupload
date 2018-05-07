@isTest
public class Test_Base311_Service_Activity {

    @isTest
    static void testTrackOutcomes() {
        Service_Type_Version__c stv = Test_RestTestHelper.sericeTypeVersionAndVersion();
        Activity__c a = Test_RestTestHelper.activity();
        Service_Type_Version_Activity__c stva = Test_RestTestHelper.serviceTypeVersionActivity(a.Id, stv.Id);
        Case c = Test_RestTestHelper.serviceRequest(stv.Id);
        Service_Activity__c sa = Test_RestTestHelper.serviceActivity(stva.Id, c.Id);
        Service_Activity__c sa2 = sa.clone();
        Outcome__c o = Test_RestTestHelper.outcome();
        
        Activity_Outcome__c ao = Test_RestTestHelper.activityOutcome(a.Id, o.Id);
        
        ao.Track_Use__c = true;
        update ao;
        
       	Base311_Service_Activity rsa = new Base311_Service_Activity();
        
        sa.Activity_Outcome__c = ao.Id;
        update sa;
        
        List<Case_Event__c> ces = rsa.trackOutcomes(new Map<Id, Service_Activity__c>{ sa.Id => sa }, new Map<Id, Service_Activity__c>{ sa.Id => sa2 });
        
        System.assertEquals(ces.size(), 1);
    }
    
    @isTest
    static void testPatchServiceActivities() {
        Service_Type_Version__c stv = Test_RestTestHelper.sericeTypeVersionAndVersion('TEST1');
        Case c = Test_RestTestHelper.serviceRequest();
        Activity__c a = Test_RestTestHelper.activity();
        Service_Type_Version_Activity__c stva = Test_RestTestHelper.serviceTypeVersionActivity(a.Id, stv.Id);
        Service_Activity__c serv = Test_RestTestHelper.service(c.Id, stva.Id);
        
        serv = [ SELECT Name FROM Service_Activity__c WHERE Id = :serv.Id ];
        
        
        List<Base311_Activity> attrUpdates = new List<Base311_Activity>{
            Base311_Activity.fromMap(new Map<String, String>{
                'code' => serv.Name,
                'status' => 'Not Started'
            })
        };
        
        Base311_Service_ServiceType rsst = new Base311_Service_ServiceType();
       	Base311_Service_Activity rsa = new Base311_Service_Activity();
        Base311_Service_Request rsq = new Base311_Service_Request();
        
        Base311_PatchValue pv = new Base311_PatchValue(true, new List<Map<String, String>>{
            new Map<String, String>{
                'code' => serv.Name,
                'status' => 'In Progress'
            }
        });
        
        List<Service_Activity__c> sa = rsa.patchActivities(
            rsq.getServiceRequest(c.Service_Request_Number__c), 
            pv 
        );
        
        System.assertEquals(sa[0].Status__c, 'In Progress');
    }

    @isTest
    static void testUpsertServiceActivitiesUpdate() {
        Service_Type_Version__c stv = Test_RestTestHelper.sericeTypeVersionAndVersion('TEST1');
        Case c = Test_RestTestHelper.serviceRequest();
        Activity__c a = Test_RestTestHelper.activity();
        Service_Type_Version_Activity__c stva = Test_RestTestHelper.serviceTypeVersionActivity(a.Id, stv.Id);
        Service_Activity__c serv = Test_RestTestHelper.service(c.Id, stva.Id);
        
        serv = [ SELECT Name FROM Service_Activity__c WHERE Id = :serv.Id ];
        
        
        List<Base311_Activity> attrUpdates = new List<Base311_Activity>{
            Base311_Activity.fromMap(new Map<String, String>{
                'code' => serv.Name,
                'status' => 'Not Started'
            })
        };
        
        Base311_Service_ServiceType rsst = new Base311_Service_ServiceType();
        Base311_Service_Activity rsa = new Base311_Service_Activity();
        Base311_Service_Request rsq = new Base311_Service_Request();
 
        rsa.upsertServiceActivities(
            rsq.getServiceRequest(c.Service_Request_Number__c), 
            rsst.getServiceType(stv.Name), 
            attrUpdates
        );
        
        Service_Activity__c updates = [SELECT Status__c FROM Service_Activity__c WHERE Id = :serv.Id];
        
        System.assertEquals(updates.Status__c, 'Not Started');
    }
    
    @isTest
    static void testSetNextActivity(){
        Service_Type_Version__c stv = Test_RestTestHelper.sericeTypeVersionAndVersion('TEST1');
        Case c = Test_RestTestHelper.serviceRequest();
        Activity__c a = Test_RestTestHelper.activity('123');
        Activity__c a2 = Test_RestTestHelper.activity('124');
        Service_Type_Version_Activity__c stva = Test_RestTestHelper.serviceTypeVersionActivity(a.Id, stv.Id, 1);
        Service_Activity__c serv = Test_RestTestHelper.service(c.Id, stva.Id);
        Service_Type_Version_Activity__c stva2 = Test_RestTestHelper.serviceTypeVersionActivity(a2.Id, stv.Id, 2);
        Service_Activity__c serv2 = Test_RestTestHelper.service(c.Id, stva2.Id);
        
        stva.Incap311__Next_Activity__c = '124';
        update stva;
        
        //stva2.Incap311__Next_Activity__c = '123';
        //update stva2;
        
        list<Id> servId = new list<Id>();
        servId.add(serv.Id);
        Base311_Service_Activity.setNextActivity(servId);
        
        Service_Activity__c serv2Check = [select Incap311__Status__c from Service_Activity__c where id = :serv2.Id];
        System.assertEquals('In Progress',serv2Check.Incap311__Status__c);
    }
    
    
     @isTest
    static void testSetNextActivityOutcome(){
        Service_Type_Version__c stv = Test_RestTestHelper.sericeTypeVersionAndVersion('TEST1');
        Case c = Test_RestTestHelper.serviceRequest();
        Activity__c a = Test_RestTestHelper.activity('123');
        Activity__c a2 = Test_RestTestHelper.activity('124');
        Service_Type_Version_Activity__c stva = Test_RestTestHelper.serviceTypeVersionActivity(a.Id, stv.Id, 1);
        Service_Activity__c serv = Test_RestTestHelper.service(c.Id, stva.Id);
        Service_Type_Version_Activity__c stva2 = Test_RestTestHelper.serviceTypeVersionActivity(a2.Id, stv.Id, 2);
        Service_Activity__c serv2 = Test_RestTestHelper.service(c.Id, stva2.Id);
        
        Outcome__c out1 = new Outcome__c(Outcome_Detail__c='out1', Outcome_Code__c='OUT1');
        insert out1;
        
        Activity_Outcome__c actOUt = new Activity_Outcome__c(outcome__c = out1.Id, Activity__c=a.ID, Next_Activity__c = '124', Service_Type_Version_Activity__c = stva.Id);
        insert actOut;
        
        serv.Allowable_Outcome__c = out1.Id;
        update serv;
        
        //stva2.Incap311__Next_Activity__c = '123';
        //update stva2;
        
        list<Id> servId = new list<Id>();
        servId.add(serv.Id);
        Base311_Service_Activity.setNextActivity(servId);
        
        Service_Activity__c serv2Check = [select Incap311__Status__c from Service_Activity__c where id = :serv2.Id];
        System.assertEquals('In Progress',serv2Check.Incap311__Status__c);
    }
}