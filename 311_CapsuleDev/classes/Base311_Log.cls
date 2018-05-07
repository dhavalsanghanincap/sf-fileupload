global virtual class Base311_Log implements Base311_Log_Interface
{
    global Static String DEBUGSTRING = 'DEBUG';
    global Static String ERRORSTRING = 'ERROR';
    global Static String FATALSTRING = 'FATAL';
    global Static String INFOSTRING = 'INFO';
    global Static String TRACESTRING = 'TRACE';
    global Static String WARNSTRING = 'WARN';

    global boolean DebugEnabled = true;
    global boolean ErrorEnabled = true;
    global boolean FatalEnabled = true;
    global boolean InfoEnabled = true;
    global boolean TraceEnabled = true;
    global boolean WarnEnabled = true;
    global list<LogMessage> messages = new list<LogMessage>();

    global Base311_Log()
    {

    }

    global void debug(String className, String methodName,Object message){
        if(isDebugEnabled()){
            log(className, methodName,DEBUGSTRING,message);
        }
    }
    global void debug(String className, String methodName,Object message, Exception t){
        if(isDebugEnabled()){
            log(className, methodName,DEBUGSTRING,message,t);
        }
    }
    global void error(String className, String methodName,Object message){
        if(isErrorEnabled()){
            log(className, methodName,ERRORSTRING,message);
        }
    }
    global void error(String className, String methodName,Object message, Exception t){
        if(isErrorEnabled()){
            log(className, methodName,ERRORSTRING,message,t);
        }
    }
    global void fatal(String className, String methodName,Object message){
        if(isFatalEnabled()){
            log(className, methodName,FATALSTRING,message);
        }
    }
    global void fatal(String className, String methodName,Object message, Exception t){
        if(isFatalEnabled()){
            log(className, methodName,FATALSTRING,message,t);
        }
    }
    global void info(String className, String methodName,Object message){
        if(isInfoEnabled()){
            log(className, methodName,INFOSTRING,message);
        }
    }
    global void info(String className, String methodName,Object message, Exception t){
        if(isInfoEnabled()){
            log(className, methodName,INFOSTRING,message,t);
        }
    }

    global boolean isDebugEnabled(){
        return DebugEnabled;
    }
    global boolean isErrorEnabled(){
        return ErrorEnabled;
    }
    global boolean isFatalEnabled(){
        return FatalEnabled;
    }
    global boolean isInfoEnabled(){
        return InfoEnabled;
    }
    global boolean isTraceEnabled(){
        return TraceEnabled;
    }
    global boolean isWarnEnabled(){
        return WarnEnabled;
    }

    global void trace(String className, String methodName,Object message){
        if(isTraceEnabled()){
            log( className, methodName,TRACESTRING,message);
        }
    }
    global void trace(String className, String methodName,Object message, Exception t){
        if(isTraceEnabled()){
            log( className, methodName,TRACESTRING,message,t);
        }
    }
    global void warn(String className, String methodName,Object message){
        if(isWarnEnabled()){
            log( className, methodName,WARNSTRING,message);
        }
    }
    global void warn(String className, String methodName,Object message, Exception t){
        if(isWarnEnabled()){
            log(className, methodName,WARNSTRING,message,t);
        }
    }

    global void log(String className, String methodName,String level, Object Message, Exception t){
        messages.add(new LogMessage(className, methodName, level, Message, t));
    }
    global void log(String className, String methodName,String level, Object Message){
        log(className, methodName, level, Message, null);
    }
    global virtual void write(){
        
    }


    global class LogMessage{
        String className;
        String methodName;
        public String level;
        Object Message;
        Exception t;
        global Datetime timestamp;

        global LogMessage(String className, String methodName,String level, Object Message, Exception t){
            this.className = className;
            this.methodName = methodName;
            this.level = level;
            this.Message = Message;
            this.t = t;
            this.timeStamp = System.now();
        }
        global override String toString(){
           return  timeStamp+':'+level+': '+ClassName+'.'+methodName+' ; Exception: '+t+' ; Message: '+message;
        }
    }

}