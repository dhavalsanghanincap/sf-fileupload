public with sharing class Console311_Section_BulkDatePicker {
  public final Integer ERROR_LIMIT_EXCEEDED = 1;
  public final Integer ERROR_DUPLICATE_DETECTED = 2;

  private final Incap311.Base311_Service_Bulk restServiceBulk = new Incap311.Base311_Service_Bulk();
  public String stId { get; set; }
  public Integer stSchAfterDays {get; set; }
  public String zone { get; set; }
  public String mDayOfTheWeek { get; set; }
  public String mScheduleErrorMsg { get; set; }
  public String mDotw { get; set; }
  public Boolean showCalendar { get; set; }

  public Integer mErrorCode { get; set; }

  public Incap311__Service_Type_Version__c mStv { get; set; }
  public Decimal mLat { get; set; }
  public Decimal mLng { get; set; }

  public Console311_Section_BulkDatePicker() {} 

  public List<Incap311__Schedule__c> getBulkDateButtons() {
    System.debug('----> [Console311_Section_BulkDatePicker] stId: ' + this.stId);
    System.debug('----> [Console311_Section_BulkDatePicker] zone: ' + this.zone);
    System.debug('----> [Console311_Section_BulkDatePicker] mDotw: ' + this.mDotw);
    System.debug('----> [Console311_Section_BulkDatePicker] stSchAfterDays: ' + this.stSchAfterDays);

    this.mDotw = this.mDotw != null ? this.mDotw : '';

    List<Incap311__Schedule__c> finalListofSch = new List<Incap311__Schedule__c>();
    List<Incap311__Schedule__c> listOfSchedules = new List<Incap311__Schedule__c>();
      
    if(this.mDotw == '')
        listOfSchedules = this.restServiceBulk.getNextAvailableScheduledDates(stId, zone, 3, false, new Set<Id>(), stSchAfterDays);
      else
        listOfSchedules = this.restServiceBulk.getNextAvailableScheduledDates(stId, zone, 3, false, this.mDotw, new Set<Id>(), stSchAfterDays);
      
    System.debug('----> [Console311_Section_BulkDatePicker] Dates Available: ' + listOfSchedules);

    if (listOfSchedules.size() == 0) {
      listOfSchedules = this.restServiceBulk.getNextAvailableScheduledDates(stId, '');
      System.debug('----> [Console311_Section_BulkDatePicker] Dates Available w/o Zone: ' + listOfSchedules);
    }
    System.debug('----> [Console311_Section_BulkDatePicker] mStv: ' + mStv);
    System.debug('----> [Console311_Section_BulkDatePicker] Lat & Lng: ' + this.mLat + ', ' + this.mLng);
    Map<String, Boolean> scheduleLimitResults = restServiceBulk.verifyLimitsReachedByLocationIndividually(mStv, this.mLat, this.mLng);

    // TODO: Add check for the yearly and monthly limits on the schedules. Call func from Core Service.
    if (scheduleLimitResults != null && !scheduleLimitResults.get('month') && !scheduleLimitResults.get('year')) {
      if (restServiceBulk.verifyDuplicateScheduleByLocation(mStv, this.mLat, this.mLng)) {
        for (Incap311__Schedule__c sch : listOfSchedules) {
          if (this.restServiceBulk.verifyAvailablityByScheduleType(sch)) {
            finalListofSch.add(sch);
          }
        }
      } else {
        this.mErrorCode = ERROR_DUPLICATE_DETECTED;
        System.debug('----> [Console311_Section_BulkDatePicker] Duplicate Detection is active. Duplicate found and not allowed. Denying request. ');
        this.mScheduleErrorMsg = 'Scheduled request detected for this location. Duplicates are not allowed for addresses using this service type.';  
      }
    } else {
      System.debug('----> [findSchedulableDate] Unable to obtain Schedule. Limits for Month or Year have been met.');
      this.mScheduleErrorMsg = 'This location is unable to be serviced at this time. Please try again later.';

      if (scheduleLimitResults != null) {
        this.mErrorCode = ERROR_LIMIT_EXCEEDED;
        String limitReachedStr = scheduleLimitResults.get('month') ? 'monthly' : 'yearly';
        this.mScheduleErrorMsg = 'This location has reached its ' + limitReachedStr + ' limit and is unable to create further schedules.';
      }
      // Limits reached. Throw error and return.
    }

    return finalListofSch;
  }
}