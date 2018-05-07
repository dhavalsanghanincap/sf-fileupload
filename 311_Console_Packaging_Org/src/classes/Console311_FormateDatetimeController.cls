public class Console311_FormateDatetimeController {
    public DateTime dateTimeValue { get; set; }
    public String formatStr { get; set; }
    public String timezoneStr { get; set; }
    
    private Incap311.Base311_DateTime_Util dtu = new Incap311.Base311_DateTime_Util();

    public Console311_FormateDatetimeController() {
      this.formatStr = String.isNotBlank(this.formatStr) ? this.formatStr : 'MMM dd, yyyy h:mm:ss a';
      this.timezoneStr = String.isNotBlank(this.timezoneStr) ? this.timezoneStr : 'America/New_York';
    }
    
    public String getTimeZoneValue() {
        this.formatStr = String.isNotBlank(this.formatStr) ? this.formatStr : 'MMM dd, yyyy h:mm:ss a';
        this.timezoneStr = String.isNotBlank(this.timezoneStr) ? this.timezoneStr : 'America/New_York';

        if( dateTimeValue != null && String.isNotBlank(this.formatStr)) { 
          String timezone = (dtu.isDST(dateTimeValue) ? 'EDT' : 'EST');
          String localeFormatDT = dateTimeValue.format(this.formatStr, timezoneStr);
          return localeFormatDT;
        }
        return ' ';
    }
    
}