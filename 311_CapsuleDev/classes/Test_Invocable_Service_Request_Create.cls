@isTest
public class Test_Invocable_Service_Request_Create
{
    static testMethod void Test_Invocable_Service_Request_Create()
    {
        Service_Type__c st = Test_RestTestHelper.serviceType();
        st = [SELECT Service_Type_Code__c FROM Service_Type__c WHERE Id = :st.Id];


        Service_Type_Version__c stv1 = Test_RestTestHelper.serviceTypeVersion(st.Id, 'test1', true, true);

        st.Active_Service_Type_Version__c = stv1.Id;
        update st;

        Base311_Service_ServiceType rsst = new Base311_Service_ServiceType();

        //Service_Type_Version__c result = rsst.getActiveServiceType(st.name, true);
		//System.assert(result != null);
        //Service_Type_Version__c stv = [Select Id, Name, Allow_Citizen_Web_Intake__c, Service_Type__c, Service_Type_Code__c FROM Service_Type_Version__c Where Id = :result.Id];

        Base311_Invocable_Service_Request_Create.Input input = new Base311_Invocable_Service_Request_Create.Input();
        list<Base311_Invocable_Service_Request_Create.Input> inputs = new list<Base311_Invocable_Service_Request_Create.Input>();
        input.mediaURL = 'https://google.ca' ;
        input.firstName='John';
        input.lastName='Benson';
        input.email='john.benson@bluespurs.com';
        input.serviceCode =  stv1.name ;
        inputs.add(input);
		Test.startTest();
        list<id> outputs = Base311_Invocable_Service_Request_Create.createServiceRequest(inputs);
	
        System.assertequals(outputs.size(), 0);
        
        //inputs = new list<Base311_Invocable_Service_Request_Create.Input>();
        input.mediaURL = 'https://google.ca' ;
        input.firstName='John';
        input.lastName='Benson';
        input.email='john.benson@bluespurs.com';
        input.serviceCode =  stv1.name ;
        //input.parentCase = outputs[0];
        inputs.add(input);

        outputs = Base311_Invocable_Service_Request_Create.createServiceRequest(inputs);
        Test.stopTest();

       /* Case c = [
            SELECT 
            Id, Location__Latitude__s, Location__Longitude__s, Media_Url__c, Address_ID__c, 
            Service_Request_Number__c, Service_Type_Version__r.Name, Status,
            Service_Type_Version__r.Service_Name__c, Description,
            Requested_Date_Time__c, Expected_Date_Time__c, LastModifiedDate,
            Address__c, Zipcode__c
            FROM 
            Case where id in :outputs
        ];

        System.assertEquals(c.Media_Url__c, 'https://google.ca');*/
    }
}