/*********
* @author 
* @date 
* @group 
* @group-content
* @description Class to handle finding / creating Contacts to be made part of a distribution list.
*/

global class Base311_Service_DistributionList {

    private final String CONTACT_STUB_ACCOUNT = 'Distribution';

    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    private Boolean contains(List<SObject> records, String fieldName, String fieldValue) {
        for(SOBject record : records) {
            if(String.valueOf(record.get(fieldName)) == fieldValue) {
                return true;
            }
        }
        
        return false;
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global List<Contact> getWardDistributionList(Boolean isCoordinatorList, Service_Type_Version__c stv, String ward, String departmentName) {
        if(!Base311_Security.areAccessible(Service_Queue_Member__c.SObjectType, new List<String>{ 'Id' } )) {
            throw new Base311_Exceptions.SecurityException('Current user does not have access to Service Queue Members');
        }
    
        if(!Base311_Security.areAccessible(Service_Queue__c.SObjectType, new List<String>{ 'Id' } )) {
            throw new Base311_Exceptions.SecurityException('Current user does not have access to Service Queues');
        }
    
        if(!Base311_Security.areAccessible(Contact.SObjectType, new List<String>{ 'Id', 'Email' } )) {
            throw new Base311_Exceptions.SecurityException('Current user does not have access to Contacts');
        }
    
        //Get all service queue memebers in service queues associated to the department (Zone)
        List<Service_Queue__c> queues = [
            SELECT
                (
                    SELECT
                        Id, Contact__r.Email, Contact__r.LastName
                    FROM 
                        Service_Queue_Members__r
                ) 
            FROM
                Service_Queue__c
            WHERE 
                Id IN (
                    SELECT Service_Queue__c 
                    FROM Service_Type_Queue_Zone__c 
                    WHERE Service_Type_Version__c = :stv.Id AND Zone__r.Value__c = :ward AND Service_Queue__r.Is_Coordinator__c = :isCoordinatorList
                ) AND
                Account__r.Name = :departmentName
                
        ];
        
        List<Contact> emails = new List<Contact>();
        
        for(Service_Queue__c sq : queues) {
            for(Service_Queue_Member__c sqm : sq.Service_Queue_Members__r) {
                emails.add(sqm.Contact__r);
            }
        }
        
        return emails;
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global List<Contact> getWardCoordinatorDistributionList(Service_Type_Version__c stv, String ward, String departmentName) {
        return getWardDistributionList(true, stv, ward, departmentName);
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global List<Contact> getWardDistributionList(Service_Type_Version__c stv, String ward, String departmentName) {
        return getWardDistributionList(false, stv, ward, departmentName);
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global Map<DISTRIBUTION_LIST_TYPE, List<Contact>> getWardDistributionLists(Service_Type_Version__c stv, String ward, String departmentName) {
        List<Contact> nonCoordinators = this.getWardDistributionList(false, stv, ward, departmentName);
        List<Contact> coordinators = this.getWardDistributionList(true, stv, ward, departmentName);
        
        List<Contact> finalNormal = new List<Contact>();
        
        for(Contact nc : nonCoordinators) {
            if(!contains(coordinators, 'Email', nc.Email)) {
                finalNormal.add(nc);
            }
        }
        
        return new Map<DISTRIBUTION_LIST_TYPE, List<Contact>>{
            DISTRIBUTION_LIST_TYPE.COORDINATOR => coordinators,
            DISTRIBUTION_LIST_TYPE.NORMAL => finalNormal
        };
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global List<Contact> getDefaultDistributionList(Boolean isCoordinator, Service_Type_Version__c stv, String departmentName) {
        if(!Base311_Security.areAccessible(Service_Queue_Member__c.SObjectType, new List<String>{ 'Id' } )) {
            throw new Base311_Exceptions.SecurityException('Current user does not have access to Service Queue Members');
        }
    
        if(!Base311_Security.areAccessible(Service_Queue__c.SObjectType, new List<String>{ 'Id' } )) {
            throw new Base311_Exceptions.SecurityException('Current user does not have access to Service Queues');
        }
    
        if(!Base311_Security.areAccessible(Contact.SObjectType, new List<String>{ 'Id', 'Email' } )) {
            throw new Base311_Exceptions.SecurityException('Current user does not have access to Contacts');
        }
    
        // Get all service queue memebers for Service Queues that belong to the department (account)
        // and are related to the provided service type.
        List<Service_Queue__c> queues = [
            SELECT
                (
                    SELECT
                        Id, Contact__r.Email, Contact__r.LastName
                    FROM 
                        Service_Queue_Members__r
                ) 
            FROM
                Service_Queue__c
            WHERE 
                Id IN (SELECT Service_Queue__c FROM Service_Type_Queue_Zone__c WHERE Service_Type_Version__c = :stv.Id) AND
                Account__r.Name = :departmentName AND 
                Is_Coordinator__c = :isCoordinator
                  
        ];
        
        List<Contact> emails = new List<Contact>();
        
        for(Service_Queue__c sq : queues) {
            for(Service_Queue_Member__c sqm : sq.Service_Queue_Members__r) {
                emails.add(sqm.Contact__r);
            }
        }
        
        return emails;
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global List<Contact> getDefaultDistributionList(Service_Type_Version__c stv, String wardName, String departmentName) {
        return getDefaultDistributionList(false, stv, departmentName);
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global List<Contact> getDefaultCoordinatorDistributionList(Service_Type_Version__c stv, String departmentName) {
        return getDefaultDistributionList(true, stv, departmentName);
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global List<Contact> getDefaultDistributionList(Service_Type_Version__c stv, String departmentName) {
        return getDefaultDistributionList(false, stv, departmentName);
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global Map<DISTRIBUTION_LIST_TYPE, List<Contact>> getDefaultDistributionLists(Service_Type_Version__c stv, String departmentName) {
        List<Contact> nonCoordinators = this.getDefaultDistributionList(false, stv, departmentName);
        List<Contact> coordinators = this.getDefaultDistributionList(true, stv, departmentName);
        
        List<Contact> finalNormal = new List<Contact>();
        
        for(Contact nc : nonCoordinators) {
            if(!contains(coordinators, 'Email', nc.Email)) {
                finalNormal.add(nc);
            }
        }
        
        return new Map<DISTRIBUTION_LIST_TYPE, List<Contact>>{
            DISTRIBUTION_LIST_TYPE.COORDINATOR => coordinators,
            DISTRIBUTION_LIST_TYPE.NORMAL => finalNormal
        };
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global String stringifyContactDistributionList(List<Contact> contacts) {
        List<String> emails = new List<String>();
        
        for(Contact c : contacts) {
            emails.add(c.Email);
        }
        
        return stringifyDistributionList(emails);
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global String stringifyDistributionList(List<String> distributionList) {
        if(distributionList == null) {
            return '';
        }
        
        List<String> finalList = new List<String>();
        
        for(String item : distributionList) {
            item = item.trim();
            finalList.add(item);
        }
        
        
        return String.join(finalList, ',');
    }

    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global List<String> arrayifyDistributionList(String distributionList) {
        if(distributionList == null) {
            return new List<String>();
        }
    
    
        List<String> items = distributionList.split(',');
        List<String> finalItems = new List<String>();
        
        for(String item : items) {
            item = item.trim();
            finalItems.add(item);
        }
        
        return finalItems;
    }

    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global List<SObject> stubContactsByEmail(List<String> emails) {
    
        if(!Base311_Security.areCreateable(Contact.SObjectType, new List<String>{ 'LastName', 'Email', 'AccountId' } )) {
            throw new Base311_Exceptions.SecurityException('Current user cannot create Contacts');
        }
        
        List<SObject> existing = findTargets(emails);
        List<String> actuallyMissing = new List<String>();
        
        for(String email : emails) {
            if(!contains(existing, 'Email', email)) {
                actuallyMissing.add(email);
            }
        }
    
        
        List<Contact> newContacts = new List<Contact>();
        Account distributionAccount = null;
        List<Account> accounts = [SELECT Id FROM Account WHERE Name = :CONTACT_STUB_ACCOUNT];
        
        if(accounts.size() > 0) {
            if(!Base311_Security.areAccessible(Account.SObjectType, new List<String>{ 'Name' } )) {
                throw new Base311_Exceptions.SecurityException('Current user access Accounts');
            }
            
            distributionAccount = accounts[0];
        } else {
    
            if(!Base311_Security.areCreateable(Account.SObjectType, new List<String>{ 'Name' } )) {
                throw new Base311_Exceptions.SecurityException('Current user cannot create Accounts');
            }
            
            distributionAccount = new Account(Name = CONTACT_STUB_ACCOUNT);
            insert distributionAccount;
        }
        
        for(String email : actuallyMissing) {
            if(email != NULL && email.contains('@')) {
                List<String> emailPieces = email.split('@');
                
                newContacts.add(new Contact(
                    Email = email, AccountId = distributionAccount.Id, LastName = emailPieces[0]
                ));
            } else {
                throw new Base311_Exceptions.UnsupportedException('Provided email address ' + email + ' is invalid');
            }
        }
        
        insert newContacts;
        
        existing.addAll((List<SObject>) newContacts);
        
        return existing;
    }

    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global List<SObject> findTargets(String distributionList) {
        return findTargets(arrayifyDistributionList(distributionList));
    }

    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global List<SObject> findTargets(List<String> distributionList) {
    
        if(!Base311_Security.areAccessible(Contact.SObjectType, new List<String>{ 'Id', 'Email' } )) {
            throw new Base311_Exceptions.SecurityException('Current user does not have access to Contacts');
        }
    
        if(!Base311_Security.areAccessible(User.SObjectType, new List<String>{ 'Id', 'Email' } )) {
            throw new Base311_Exceptions.SecurityException('Current user does not have access to Users');
        }
        
        List<SObject> records = new List<SObject>();
        
        List<SObject> users = [SELECT Id, Email FROM User WHERE Email IN :distributionList];
        List<String> alreadyFound = new List<String>();
        
        for(SObject user : users) {
            alreadyFound.add(String.valueOf(user.get('Email')));
        }
        
        List<SObject> contacts = [
            SELECT Id, Email 
            FROM Contact 
            WHERE Email IN :distributionList AND Email NOT IN :alreadyFound
        ];
        
        records.addAll(users);
        records.addAll(contacts);
        
        return records;
    }
       
}