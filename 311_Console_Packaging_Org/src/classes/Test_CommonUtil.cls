@isTest
private class Test_CommonUtil 
{
    static testMethod void Test_getCurrentDatetime()
    {
        Datetime today = Datetime.now();
        String timestamp  =  today.format('MMM d, yyyy - h:mm:ss aaa');
        
        System.assertEquals(timestamp, CommonUtil.getCurrentDatetime()); 
    }
    
    static testMethod void Test_getTimeZoneValue()
    {
        Datetime today = Datetime.now();
        
        String expectedResult  =  today.format('MMM dd, yyyy h:mm:ss a');
        String actualResult    =  CommonUtil.getTimeZoneValue(today);
        
        System.assertEquals(expectedResult,actualResult); 
        
        //Check for null datetime
        System.assertEquals(' ', CommonUtil.getTimeZoneValue(null)); 
    }
}