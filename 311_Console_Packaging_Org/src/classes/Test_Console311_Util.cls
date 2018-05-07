@isTest
private class Test_Console311_Util {
    @isTest static void testUtilMethods() {
        Account acc = new Account();
        Contact contact = new Contact();
        Console311_Util.getPicklistValues(acc, 'Industry');
        Console311_Util.getStatesByCountry('USA');
        Console311_Util.isContactRequiredToCreateCase('LN', contact);
        Console311_Util.getStateByStateCodeMap();
        list<Incap311Console__Console311_Lookup_Config__mdt> lookupconfig = [
        Select 
          Incap311Console__New_Record_Layout__c, 
          Incap311Console__Search_Layout__c, 
          Incap311Console__Search_Result_Layout__c 
        From 
          Incap311Console__Console311_Lookup_Config__mdt 
        Where 
          MasterLabel = 'Contact'
      ];
         Map<String, Map<String, String>> mapthing = Console311_Util.retrieveObjFieldNameListByLayoutConfiguration('contact', lookupconfig[0].Incap311Console__New_Record_Layout__c);
        List<SObject> sobjects = new List<SObject>();
        sobjects.add(contact);
        
        Map<String, Map<String, Map<String, String>>> secondMapThing = Console311_Util.formatSobjectDataUtilMap(sobjects, 'contact', lookupconfig[0].Incap311Console__New_Record_Layout__c);
        
        /* Currently do not support Thursday due to ambiguious API result */
        String dowFormat = Console311_Util.genDayOfWeekFromFormatted('MTWTF', 'd');
        System.assertEquals(dowFormat, 'Monday,Tuesday,Wednesday,Tuesday,Friday');
    }
}