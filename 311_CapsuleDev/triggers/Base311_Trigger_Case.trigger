trigger Base311_Trigger_Case on Case (after insert, after update) {
/*    
    if(Trigger.isInsert) {
        Base311_TriggerHandler_Case.createCaseEvents(Trigger.newMap.keySet());
    }
     
    if(Trigger.isUpdate) {
        Map<Id, Case> cases = Trigger.newMap;
        Map<Id, Case> oldCases = Trigger.oldMap;
        Set<Id> caseIds = new Set<Id>();
        
        for(Id caseId : cases.keySet()) {
            Case newCase = cases.get(caseId);
            Case oldCase = oldCases.get(caseId);
            
            if(newCase.Status == 'Closed' && oldCase.Status != 'Closed') {
                caseIds.add(caseId);
            }
        }
        
        if(caseIds.size() > 0) {
            Base311_TriggerHandler_Case.closeCaseEvents(caseIds);
        }
    }*/
}