/**
* @author 
* @date 
* @group 
* @group-content
* @description 
*/
global class Base311_Service_Reallocate {
    
    private static final String CASE_SOBJECT_TYPE = 'Case';

    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    public List<Reallocate_Service_Request_Type__c> getReallocateConfig(Id serviceTypeId, Boolean forActivities) {
        return [
            SELECT Queue_Id__c, Service_Type__c
            FROM Reallocate_Service_Request_Type__c
            WHERE Service_Type__c = :serviceTypeId AND For_Activties__c = :forActivities
        ];
        
    }

    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    public List<QueueSobject> getActiveReallocateQueuesForActivties(Id serviceTypeId) {
        return getActiveReallocateQueues(serviceTypeId, true);
    }

    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    public List<QueueSobject> getActiveReallocateQueues(Id serviceTypeId) {
        return getActiveReallocateQueues(serviceTypeId, false);
    }

    /**
    * @description Gets the available reallocate queues for a service type (for either its 
    * activities or case) by its ID.
    * @param Id The service type ID to search on
    * @param Boolean Whether the reallocate configuration for Activities or Cases should be returned
    * @return List<QueueSobject> List of queues that can be reallocated to
    */
    global List<QueueSobject> getActiveReallocateQueues(Id serviceTypeId, Boolean forActivities) {
        Set<String> queueIds = new Set<String>();
        
        for(Reallocate_Service_Request_Type__c item : getReallocateConfig(serviceTypeId, forActivities)) {
            queueIds.add(item.Queue_Id__c);
        }
        
        return getQueues(queueIds);
    }

    /**
    * @description Reallocates a given case to a given queue. Will throw an error if the queue
    * is invalid for the case
    * @param Case the Case to reallocate to
    * @param String The reason for the reallocation
    * @param String The entity reallocating for assigned the case
    * @param QueueSobject the Queue object to reallocate to
    * @return Case the updated Case
    */
    global Case reallocateCase(Case c, String reason, String assigner, QueueSobject queue) {
        if(c.IsClosed) {
            throw new Base311_Exceptions.UnsupportedException('Unable to reallocate a closed request');
        }
        
    	c.Case_Comments__c = (c.Case_Comments__c != null ? c.Case_Comments__c : '') + 
            '\n\n' + 
            'Manually Reallocated Case - ' + 
            assigner + 
            ' - ' + 
            Base311_Helper.formatDate(System.today()) + ' - ' + 
            reason;
            
       	c.ownerID = queue.Queue.Id;
        
        update c;
        
        return c;
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    public List<QueueSObject> getAvailableQueues() {
        return getQueues(null);
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    private List<QueueSObject> getQueues(Set<String> queueIds) {
        String query = 'SELECT Queue.Name, Queue.Id ' +
        'FROM QueueSobject ' +
        'WHERE SobjectType = :CASE_SOBJECT_TYPE ' +
        (queueIds != null ? ' AND Queue.Id IN :queueIds ' : '')  +
        'ORDER BY Queue.Name ASC';
    
        List<QueueSObject> items = Database.query(String.escapeSingleQuotes(query));
        
        return items;
    }
    
}