@isTest
public class TestDataFactory 
{
    
    public static Contact createContact()
    {
        Contact c  =  new Contact();
        c.LastName  =  'Test Contact';
        c.Email  =  'test@salesforce.com';
        c.MailingStreet  =  'Test Street';
        c.MailingCity  =  'Test City';
        c.MailingState  =  'Test State';
        c.MailingPostalCode  =  '123456';
        
        INSERT c;
        
        return c;
    }
    
  
    public static Case createServiceRequest()
    {
        //create a contact first
        Contact newContact  =  createContact();
        
        Case c  =  new Case();
        c.Origin  =  'Phone';
        c.Description  =  'Test Description';
        c.Status  =  'Open';
        c.Incap311__Address__c  =  'Test Address';
        c.Incap311__Expected_Date_Time__c  =  Datetime.now();
        c.ContactId  =  newContact.Id;
        insert c;
        
        return c;
    }
    
   
    public static List<Incap311__Service_Question__c> createServiceQuestion(Case newCase,Integer numQues)
    {
        List<Incap311__Service_Question__c> lstQuestions  =  new List<Incap311__Service_Question__c>();
        
        for(Integer counter=1;counter<=numQues;counter++)
        {
            Incap311__Service_Question__c question  =  new Incap311__Service_Question__c();
        
            question.Incap311__Service_Request__c  =  newCase.Id;
            question.Incap311__Question__c  =  'Test Question '+counter;
            question.Incap311__Answer__c  =  'Test Answer '+counter;
            
            lstQuestions.add(question);
        }
        
        insert lstQuestions;
        
        return lstQuestions;
    }
}