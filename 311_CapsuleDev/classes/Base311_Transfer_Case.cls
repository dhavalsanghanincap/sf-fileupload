/**
* @author 
* @date 
* @group 
* @group-content
* @description 
*/
global class Base311_Transfer_Case {

    private static Base311_Service_TSRT tts = new Base311_Service_TSRT();
    private static Base311_Service_Question ssq = new Base311_Service_Question();
    private static Base311_Service_Activity ssa = new Base311_Service_Activity();
    private static Base311_Service_Request ssr = new Base311_Service_Request();
    private static Base311_Service_ServiceType sst = new Base311_Service_ServiceType();
    private static Base311_Service_CaseEvents sce = new Base311_Service_CaseEvents();
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global static List<Service_Type_Version__c> getActiveServiceTypes(Id serviceTypeId) {
        return tts.getActiveTransferVersions(serviceTypeId);
    }

    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global static List<Service_Type_Version__c> getActiveServiceTypes(Id serviceTypeId, Boolean forAct) {
        return tts.getActiveTransferVersions(serviceTypeId, forAct);
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    private static String getNewSubjectFromVersion(String id) {
        List<Service_Type_Version__c> versions = [SELECT Service_Name__c FROM Service_Type_Version__c WHERE Id = :id];
        
        if(versions.size() == 0) {
            return '';
        }
        
        return versions.get(0).Service_Name__c;
    }

    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    global static Case transferCase(Case updatedCase, Case unmodifiedCase, Map<String, Object> items) {
        Savepoint sp = Database.setSavepoint();

        try {
            if(unmodifiedCase.IsClosed) {
                throw new Base311_Exceptions.UnsupportedException('Unable to transfer a closed request');
            }
            
            Case clonedCase = Base311_Helper.getCompleteCase(unmodifiedCase).clone(false, true, true, false);
            clonedCase.Status = 'Closed (Transferred)';
            clonedCase.Transfer_Parent__c = updatedCase.Id;
            insert clonedCase;
            
            clonedCase = [ SELECT Id, Service_Request_Number__c FROM Case WHERE ID = :clonedCase.Id ];
            clonedCase = ssr.getServiceRequest(clonedCase.Service_Request_Number__c);
    
            updatedCase.Subject = getNewSubjectFromVersion(updatedCase.Service_Type_Version__c);
            update updatedCase;
            
            List<Service_Activity__c> clonedActivities = new List<Service_Activity__c>();
            List<Service_Question__c> clonedQuestions = new List<Service_Question__c>();
            
            for(Service_Activity__c sa : unmodifiedCase.Service_Activities__r) {
                Service_Activity__c clonedSA = sa.clone(false, true, true, false);
                clonedSA.Service_Request__c = clonedCase.Id;
                clonedActivities.add(clonedSA);
            }
            
            for(Service_Question__c sq : unmodifiedCase.Service_Questions__r) {
                Service_Question__c clonedSQ = sq.clone(false, true, true, false);
                clonedSQ.Service_Request__c = clonedCase.Id;
                clonedQuestions.add(clonedSQ);
            }
            
            insert clonedQuestions;
            insert clonedActivities;
            
            update updatedCase;
            delete updatedCase.Service_Activities__r;
            delete updatedCase.Service_Questions__r;
            
            updatedCase = ssr.getServiceRequest(updatedCase.Service_Request_Number__c);
             
            List<Service_Question__c> stvqs = ssq.upsertQuestionResponses(updatedCase, Base311_Attribute.fromMap(items));
            List<Service_Activity__c> stvas = ssa.upsertServiceActivities(updatedCase, sst.getServiceType(updatedCase.Service_Type_Version__r.Name, true));
        
            /*sce.details(updatedCase, 'Transfer', 
                'Case ' + updatedCase.Service_Request_Number__c + 
                ' was transfered from ' + clonedCase.Service_Type_Version__r.Service_Type_Code__c + 
                ' to ' + updatedCase.Service_Type_Version__r.Service_Type_Code__c + 
                '. A historical service request has been created with number ' + clonedCase.Service_Request_Number__c + ' and is marked as ' + clonedCase.Status + '.'
            );*/
        
            return ssr.getServiceRequest(updatedCase.Service_Request_Number__c);
        } catch (Exception e) {
            Database.rollback(sp);
            throw e;
        }
    }
}