@isTest
public class Test_Base311_Log
{
	static Base311_Log_Interface log = Base311_Log_Factory.getLog();
    static String className = 'Test_Base311_Log';
    static String methodName = 'TESTMETHOD';
    static Object message = 'TEST';
    static Exception e = new Base311_Exceptions.SecurityException('User does not have access to Cases');
    
    static testMethod void debug(){
        log.debug(className, methodName, message);
        assert(Base311_Log.DEBUGSTRING);
    }
    static testMethod void debug2(){
        log.debug(className, methodName, message, e);
        assert(Base311_Log.DEBUGSTRING);
    }
    static testMethod void error(){
        log.error(className, methodName, message);
        assert(Base311_Log.ERRORSTRING);
    }
    static testMethod void error2(){
        log.error(className, methodName, message, e);
        assert(Base311_Log.ERRORSTRING);
    }
    static testMethod void fatal(){
        log.fatal(className, methodName, message);
        assert(Base311_Log.FATALSTRING);
    }
    static testMethod void fatal2(){
        log.fatal(className, methodName, message, e);
        assert(Base311_Log.FATALSTRING);
    }
    static testMethod void info(){
        log.info(className, methodName, message);
        assert(Base311_Log.INFOSTRING);
    }
    static testMethod void info2(){
        log.info(className, methodName, message, e);
        assert(Base311_Log.INFOSTRING);
    }

    static testMethod void isDebugEnabled(){
       System.assert(log.isDebugEnabled());
    }
    static testMethod void isErrorEnabled(){
       System.assert(log.isErrorEnabled());
    }
    static testMethod void isFatalEnabled(){
       System.assert(log.isFatalEnabled());
    }
    static testMethod void isInfoEnabled(){
        System.assert(log.isInfoEnabled());
    }
    static testMethod void isTraceEnabled(){
        System.assert(log.isTraceEnabled());
    }
    static testMethod void isWarnEnabled(){
        System.assert(log.isWarnEnabled());
    }

    static testMethod void trace(){
        log.trace(className, methodName, message);
        assert(Base311_Log.TRACESTRING);
    }
    static testMethod void trace2(){
        log.trace(className, methodName, message, e);
        assert(Base311_Log.TRACESTRING);
    }
    static testMethod void warn(){
        log.warn(className, methodName, message);
        assert(Base311_Log.WARNSTRING);
    }
    static testMethod void warn2(){
        log.warn(className, methodName, message, e);
        assert(Base311_Log.WARNSTRING);
    }

    static testMethod void write(){
        log.warn(className, methodName, message, e);
        log.write();
    }
    
    static void assert(String level){
        Base311_log logger = (Base311_log)log;
        System.assertEquals(logger.messages.size(),1);
        System.assertEquals(logger.messages[0].level,level);
    }


   /* static testMethod void LogMessage{
            this.className = className;
            this.methodName = methodName;
            this.level = level;
            this.Message = Message;
            this.t = t;
            this.timeStamp = System.now();
     }
     static testMethod void LogMessagetoString(){
           return  timeStamp+':'+level+': '+ClassName+'.'+methodName+' ; Exception: '+t+' ; Message: '+message;
     }*/
}