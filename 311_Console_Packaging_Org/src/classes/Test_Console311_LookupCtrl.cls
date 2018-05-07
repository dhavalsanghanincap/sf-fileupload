@isTest
private class Test_Console311_LookupCtrl {

    @testSetup static void setup() {}

    @isTest static void testConstructor() {
        Test_Console311_LookupCtrl.pageSetup();
        // Call the constructor.
        System.currentPageReference().getParameters().put('queryType', 'soql');
        Console311_LookupCtrl ctrl = new Console311_LookupCtrl();
        System.assertEquals(ctrl.sObjectName, 'Account');  
    }

    @isTest static void testQuery() {
        Test_Console311_LookupCtrl.pageSetup();
        System.currentPageReference().getParameters().put('queryType', 'soql');

        Console311_LookupCtrl ctrl = new Console311_LookupCtrl();
        ctrl.sObjectName = null;
        System.assertEquals(null, ctrl.query());

        ctrl.sObjectName = 'Account';
        ctrl.queryStr = 'Test';
        ctrl.query();
        System.assertEquals(ctrl.errorMessage,'No results found.');

        Account acc1 = new Account(
            Name = 'Testing'
        );
        insert acc1;
        ctrl.query();

        ctrl.queryStr = '';
        ctrl.query();
        System.assertEquals(ctrl.errorMessage,'Search term must be greater than one character.');

        List<Id> idSet = new List<Id>();
        idSet.add(acc1.Id);
        Test.setFixedSearchResults(idSet);
        System.currentPageReference().getParameters().put('queryType', 'sosl');

        ctrl = new Console311_LookupCtrl();
        ctrl.queryStr = 'Test';
        ctrl.query();
    }

    @isTest static void pageSetup() {
        // Setup an instance of the page. 
        PageReference page = new PageReference('Page.Console311_Lookup');
        Test.setCurrentPageReference(page);
        // Set the get params for the page.
        System.currentPageReference().getParameters().put('sobject', 'Account');
        System.currentPageReference().getParameters().put('sortfield', 'Name');

    }

}