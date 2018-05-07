@isTest
public class Test_Console311_Section_ContactCases
{
    static testMethod void Test_Console311_Section_ContactCases()
    {
        Console311_Section_ContactCases contactcasesctrl = new Console311_Section_ContactCases();
        TestHelper.createData();
        
        Contact con = [SELECT id, email FROM Contact WHERE Contact.Email = 'testContact@abc.com'];
        contactcasesctrl.cId = con.Id;
        contactcasesctrl.getContactCases();

    }
}