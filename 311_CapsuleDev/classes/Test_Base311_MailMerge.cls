@isTest
public class Test_Base311_MailMerge
{
    static testMethod void Test_Base311_MailMerge()
    {
        String mergeText = '{!  CaseNumber  } is the case number';
        
        Case c1 = new Case();
        insert c1;
        Case so = [select caseNumber from case where id = :c1.Id];
        System.assertEquals(Base311_MailMerge.replace(so,mergeText), so.caseNumber + ' is the case number');
        list<String> fields = Base311_MailMerge.getFieldNames(mergeText);
         System.assertEquals('CaseNumber',fields[0]);
    }
}