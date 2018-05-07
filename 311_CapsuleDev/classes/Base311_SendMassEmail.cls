/**
* @author   David Evans 
* @date 2/9/2017
* @group 
* @group-content
* @description 
*/
global class Base311_SendMassEmail {

    /**
    * @description Invocable method to send email
    * @param massEmails list of SendMassEmailInput
    * @return list of sucess result
    * @example
    */
    @InvocableMethod(label='Send Mass Email')
    global static List<boolean> SendMassEmail(List<SendMassEmailInput> massEmails) {
        List<String> emailAddresses = new List<String>();
        Set<String> recordIds = new Set<String>();
        Map<String,Set<String>> queryFields = new Map<String,Set<String>>();
        Base311_Service_DistributionList distList = new Base311_Service_DistributionList();
        // @REVIEW since this method is both pretty central to the entire process and
        // is a bit complicated, it may be worth adding a comment about whats happening
        // and factoring out this method into a seperate function for readability.
        for(SendMassEmailInput massEmail:massEmails){
            emailAddresses.addall(distList.arrayifyDistributionList(massEmail.emailAdresses));
            Schema.SObjectType token = massEmail.recordId.getSObjectType();
            Schema.DescribeSObjectResult dr = token.getDescribe();
            String objType = dr.getName();
            if(!queryFields.containsKey(objType)){
                queryFields.put(objType,new Set<String>());
            }
            if(massEmail.emailHeader != null){
                queryFields.get(objType).addAll(Base311_MailMerge.getFieldNames(massEmail.emailHeader));
            }
            if(massEmail.emailBody != null){
                queryFields.get(objType).addAll(Base311_MailMerge.getFieldNames(massEmail.emailBody));
            }
            if(massEmail.emailFooter != null){
                queryFields.get(objType).addAll(Base311_MailMerge.getFieldNames(massEmail.emailFooter));
            }
            queryFields.get(objType).add('id');
            recordIds.add(massEmail.RecordId);
        }

        Map<ID, Sobject> sobjects = getSobjects(queryFields,recordIds);

        // @REVIEW you can use Base311_Service_DistributionList.findTargets to get a list
        // of all Contacts and Users combined; if you do need to seperate them at that point
        // a single loop check instance of should be sufficient.

        Map<String, Id> userEmail = new Map<String, Id>();
        Map<String, Id> contactEmail = new Map<String, Id>();
        list<Sobject> userAndContacts = distList.findTargets(emailAddresses);  
        String userOrContactEmail;
        Id userOrContactID;
        String type;
        for(Sobject userOrContact: userAndContacts){
            userOrContactEmail = String.valueOF(userOrContact.get('email'));
            userOrContactID = (Id)userOrContact.get('id');
            type =  String.valueOF(userOrContact.getSObjectType());

            if(type == 'User'){
                userEmail.put(userOrContactEmail,userOrContactID);
            }else if(type == 'Contact'){
                contactEmail.put(userOrContactEmail,userOrContactID);
            }
        }

        list<Messaging.SingleEmailMessage> messages = new list<Messaging.SingleEmailMessage>();

        for(SendMassEmailInput massEmail:massEmails){
            Sobject so = sobjects.get(massEmail.RecordId);
            list<Id> userIds = new list<Id>();
            list<String> contactEmails = new list<String>();

            for(String email : distList.arrayifyDistributionList(massEmail.emailAdresses)){
                if(userEmail.containsKey(email)){
                    userIds.add(userEmail.get(email));
                }else if(contactEmail.containsKey(email)){
                    contactEmails.add(email);
                }
            }

            // @REVIEW is there an advantage to spliting User emails and Contact emails?
            // or does that have to do with the limits?
            // if it does, do we only need the email strings for the contacts?
            // looking at the docs for setTargetObjectId, it seems to suggest Contact.Id should
            // be sufficent

            if(userIds.size() > 0){
                messages.addAll(makeUserEmails(massEmail,userIds,so));
            }
            if(contactEmails.size() > 0){
                messages.addAll(makeContactEmails(massEmail,contactEmails,so));
            }
        }
        Messaging.SendEmail(messages);
        return null;
    }

    /**
    * @description method to make single email for user based on SendMassEmailInput massEmail,list<Id> Ids, Sobject so
    * @param SendMassEmailInput massEmail
    * @param list<Id> Ids
    * @param Sobject so
    * @return list of singleemailmessage
    * @example
    */
    public static list<Messaging.SingleEmailMessage> makeUserEmails(SendMassEmailInput massEmail,list<Id> Ids, Sobject so){
        list<Messaging.SingleEmailMessage> messages = new list<Messaging.SingleEmailMessage>();

        String body = Base311_MailMerge.replace(so, massEmail.emailHeader) + '<br/><br/>'+
            Base311_MailMerge.replace(so, massEmail.emailBody) + '<br/><br/>' +
            + Base311_MailMerge.replace(so, massEmail.emailFooter);

        for(Id userId : Ids){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setTargetObjectId(userId);
            email.setHtmlBody(body);
            email.setSaveAsActivity(false);
            messages.add(email);
        }

        return messages;
    }

    /**
    * @description method to make conact email based on SendMassEmailInput,list of email and sObject
    * @param SendMassEmailInput massEmail
    * @param  list<String> emails,
    * @param Sobject so
    * @return list of singleemailmessage
    * @example
    */
    public static list<Messaging.SingleEmailMessage> makeContactEmails(SendMassEmailInput massEmail,list<String> emails, Sobject so){
        list<Messaging.SingleEmailMessage> messages = new list<Messaging.SingleEmailMessage>();

        String body = Base311_MailMerge.replace(so, massEmail.emailHeader) + '<br/><br/>'+
            Base311_MailMerge.replace(so, massEmail.emailBody) + '<br/><br/>' +
            + Base311_MailMerge.replace(so, massEmail.emailFooter);

        list<list<String>> listOf100 = new List<list<String>>();
        Integer count = 0;
        list<String> emailsStrings = new list<String>();
        for(String email : emails){
            count++;
            emailsStrings.add(email);
            if( math.mod(count,100) == 0){
                listOf100.add(emailsStrings);
                emailsStrings = new list<String>();
            }
        }
        listOf100.add(emailsStrings);

        for(list<String> toAddresses: listOf100){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(toAddresses);
            email.setHtmlBody(body);
            email.setSaveAsActivity(false);
            messages.add(email);
        }

        return messages;
    }


    /**
    * @description method to get map of id and sobject from giben query and set of record ids
    * @param queryFields Map<String,Set<String>>
    * @param recordIds Set<String>
    * @return map of id and sobJect
    * @example
    */
    private static map<ID, Sobject> getSobjects(Map<String,Set<String>> queryFields, Set<String> recordIds){
        map<ID, Sobject> sobjects = new  map<ID, Sobject>();
        for(String key : queryFields.keySet()){
            list<String> fields = new list<String>(queryFields.get(key));
            String query = 'Select '+String.join(fields,',')+' from '+key+' where id in :recordIds';

            for(Sobject so : Database.query(String.escapeSingleQuotes(query))){
                sobjects.put(so.id,so);
            }
        }
        return sobjects;
    }

    global class SendMassEmailInput {
        @InvocableVariable(label='Email Addresses' required=true)
        global String emailAdresses;

        @InvocableVariable
        global String emailHeader;

        @InvocableVariable
        global String emailBody;

        @InvocableVariable
        global String emailFooter;

        @InvocableVariable
        global String sendFrom;

        @InvocableVariable
        global Id RecordId;

        //@InvocableVariable
        //public String subject;
    }
}