@istest
public class Test_Console311_Controller_Recom {

    
    @istest
    public static void testControllerRec(){
        TestHelper.createData();
        List<Incap311__Service_Type_Version__c> stvList = [Select Id, Name ,Incap311__Service_Type_Code__c From Incap311__Service_Type_Version__c Limit 1];
        Console311_Controller_Recommendations controller = new Console311_Controller_Recommendations();
        controller.mVersion = controller.findVersion(stvList[0].Incap311__Service_Type_Code__c);
        System.assertEquals( controller.mVersion.Incap311__Service_Type_Code__c, stvList[0].Incap311__Service_Type_Code__c);
        controller.mContext = new Map<String, Object>();
        controller.getRecommendations();
        
    }
}