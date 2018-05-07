@isTest
public class Test_Base311_SendMassEmail
{
    static testMethod void Test_Base311_SendMassEmail()
    {
        Account acc = new Account();
        acc.Name = 'TestAccount';
        insert acc;
        
         Base311_SendMassEmail.SendMassEmailInput sMI = new Base311_SendMassEmail.SendMassEmailInput();
        sMI.emailHeader = 'Test123';
        sMI.emailBody = 'This is the Body';
        sMI.emailFooter = 'This is a footer';
        sMI.emailAdresses = 'devans@incapsulate.com';
        sMI.recordId = acc.Id;
        list<Base311_SendMassEmail.SendMassEmailInput> sMIs = new list<Base311_SendMassEmail.SendMassEmailInput>();
        sMIs.add(sMI);
        Base311_SendMassEmail.SendMassEmail(sMIs);
        delete acc;
    }
}