public class CommonUtil 
{
  /**
    * @description Getting the current data time for the report generation.
    * @return Specified data format
    **/
    public static String getCurrentDatetime() 
    {
        Datetime today = Datetime.now();
        return today.format('MMM d, yyyy - h:mm:ss aaa');
    }
    
    /**
    * @description Converting the time to a specied format.
    * @param Datetime
    * @return String
    **/
    public static String getTimeZoneValue(Datetime dt) 
    {
      if (dt != null) 
      {
        String localeFormatDT = dt.format('MMM dd, yyyy h:mm:ss a');
        return localeFormatDT;
      }
      return ' ';
    }

    
}