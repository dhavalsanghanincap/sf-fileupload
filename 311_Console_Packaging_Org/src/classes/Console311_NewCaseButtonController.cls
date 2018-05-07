public class Console311_NewCaseButtonController {

    private final Case casex;
 

    // The extension constructor initializes the private member
    // variable acct by using the getRecord method from the standard
    // controller.
    public Console311_NewCaseButtonController(ApexPages.StandardController stdController) {
        this.casex = (Case)stdController.getRecord();
    }
	
    @RemoteAction
    public static PageReference redirect() {
        AppMenuItem app =   [select Id, NamespacePrefix, name ,StartUrl,ApplicationId
                             from AppMenuItem 
                             where NamespacePrefix = 'Incap311Console' and Type = 'TabSet' and name = 'X311_Console' limit 1];
        PageReference pageRef = new PageReference(app.startURL+'#/apex/Incap311Console__Console311_Case');

        return pageRef;
    }
    
    @RemoteAction
     public static PageReference redirectConsole() {
        PageReference pageRef = new PageReference('/apex/Incap311Console__Console311_Case');

        return pageRef;
    }
}