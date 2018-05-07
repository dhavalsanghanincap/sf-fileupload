global class Base311_Log_Platform_Event extends Base311_Log
{
    global Base311_Log_Platform_Event()
    {
        
    }
    
    global override void write(){
        list<Log_Event__e> events = new list<Log_Event__e>();
        for(LogMessage message : messages){
            incap311__Log_Event__e event = new incap311__Log_Event__e();
            event.UserId__c = UserInfo.getUserId();
            event.Log_Details__c = message.toString();
            event.Event_Time__c = message.timestamp;
            events.add(event);
        }
        EventBus.publish(events);
        messages.clear();
    }
}