/*
 * Block comments with details of changes
 */
global class Base311_Log_Factory
{
    Static Base311_Log_Interface log;
    global static Base311_Log_Interface getLog(){
        if(log == null){
           log = new Base311_Log_Platform_Event();
        }
        return log;
    }
}