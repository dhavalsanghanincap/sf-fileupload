public class Console311_Case_Event_Send_Email_Ext {
    
    private final Incap311__Case_Event__c caseEvent;
    public String outputedText {get;set;}
    
    // The extension constructor initializes the private member
    // variable acct by using the getRecord method from the standard
    // controller.
    public Console311_Case_Event_Send_Email_Ext(ApexPages.StandardController stdController) {
        String[] fields = new String[]{'Incap311__Service_Request__r.ContactId','Incap311__Service_Request__c','Incap311__Rich_Email_Body__c','Incap311__Email_Subject__c','Incap311__Notification_Recipient__c','Incap311__Distribution_List__c'};
        if(!test.isRunningTest()){ 
                    stdController.addFields(fields);
        }
        
        this.caseEvent = (Incap311__Case_Event__c)stdController.getRecord();
        sendEmail();
    }
    
    public void SendEmail() {
        try{
        Messaging.reserveSingleEmailCapacity(1);
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setTargetObjectId(caseEvent.Incap311__Service_Request__r.ContactId);
        email.setTreatTargetObjectAsRecipient(false);
        email.setWhatId(caseEvent.Incap311__Service_Request__c);
        email.setHtmlBody(caseEvent.Incap311__Rich_Email_Body__c.unescapeHtml4());
        email.setSubject(caseEvent.Incap311__Email_Subject__c);
        list<String> toAddresses = new list<String>();
        if(caseEvent.Incap311__Notification_Recipient__c != null){
            toAddresses.add(caseEvent.Incap311__Notification_Recipient__c);
        }else if(caseEvent.Incap311__Distribution_List__c != null){
            toAddresses = caseEvent.Incap311__Distribution_List__c.split(',');
        }
        email.setToAddresses(toAddresses);
        list<Messaging.SingleEmailMessage> emails = new list<Messaging.SingleEmailMessage>();
        emails.add(email);
        System.debug(email);
             System.debug(toAddresses);
         Messaging.SendEmailResult[] results = Messaging.sendEmail(emails,false);
            if(results[0].isSuccess()){
            	outputedText = 'Email Sent' ;
            }else{
                outputedText = 'Email Failed '+results[0].getErrors();
            }
        }catch(Exception e){
           outputedText = 'Email Failed '+e.getMessage();
        }
    }
}