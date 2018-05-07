@isTest
private class Test_Console311_FormatDatetimeCtrl {
  
  @isTest static void testGetTimeZoneValue() {
    Console311_FormateDatetimeController fdtCtrl = new Console311_FormateDatetimeController();

    System.assertEquals(' ', fdtCtrl.getTimeZoneValue());

    Datetime dt = Datetime.now();
    fdtCtrl.dateTimeValue = dt;
    System.assertEquals(dt.format('MMM dd, yyyy h:mm:ss a', 'America/New_York'), fdtCtrl.getTimeZoneValue());
  }
}