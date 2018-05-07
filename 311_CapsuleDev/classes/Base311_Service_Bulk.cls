/**
  *  Base311_Service_Bulk
  *
  *  @author Darkis
  *  @lastModified 10 Apr 2017
  *  @description A service layer class to handle methods involving the bulk/scheduling process.
  * 
  *  Method(s):
  *    - getSchedule(String schedule_id)
  *    - getScheduleByOverrideDate(Schedule__c)
  *    - getNextAvailableScheduledDates(str schedule_id)
  *    - getNextAvailableScheduledDates(str schedule_id, str zone)
  *    - getNextAvailableScheduledDates(str schedule_id, str zone, int number_of_schedules)
  *    - getNextAvailableScheduledDates(str schedule_id, str zone, int #_of_Schedules, int #_of_days_after)
  *    - getNextAvailableScheduledDates(str schedule_id, int #_of_schedules, bool service)
  *    - getNextAvailableScheduledDates(str schedule_id, str zone, int number_of_schedules)
  *    - getNextAvailableScheduledDates(str schedule_id, str zone, int number_of_schedules, int #_of_days_after)
  *    - getNextAvailableScheduledDates(str schedule_id, str zone, int number_of_schedules, bool service)
  *    - getNextAvailableScheduledDates(str schedule_id, str zone, int number_of_schedules, bool service, str dotw)
  *    - getNextAvailableScheduledDates(str schedule_id, str zone, int number_of_schedules, bool service, str dotw, Set idsToIgnore)
  *    - getNextAvailableScheduledDates(str schedule_id, str zone, int number_of_schedules, bool service, str dotw, Set idsToIgnore, int #_of_days_after)
  *    - getNextAvailableScheduledDates(str schedule_id, str zone, int number_of_schedules, bool service, Set idsToIgnore, int #_of_days_after)
  *    - verifyAvailablityByScheduleType(Schedule__c)
  *    - verifyAvailablityByScheduleType(Schedule__c, int #_of_items)
  *    - verifyLimitsReachedByLocation(Service_Type_Version__c, decimal latitude, decimal longitude)
  *    - updateScheduleCount (Schedule__c, dec count)
  *    - createServiceRequestSchedule(Schedule__c, Case)
  *    - createServiceRequestSchedule(Schedule__c, Case, Decimal numOfItems)
  */
global without sharing class Base311_Service_Bulk {
  private final Integer DEFAULT_NUM_OF_SCHEDULES = 5;
  private final Integer TYPE_REQUESTS_INCREMENT_VALUE = 1;

  global Base311_Service_Bulk() {}

  global Schedule__c getSchedule(String sId) {
    return [
      Select 
        Id, 
        Name, 
        Capacity__c,
        Zone__c,
        Schedule_Date__c, 
        Schedule_Override_Date__c,
        Item_Count__c, 
        Day_of_Week__c,
        No_Service__c,
        Number_of_Service_Requests__c,
        Service_Type__r.Schedule_Type__c,  
        Service_Type__r.Item_Limit__c,
        Service_Type__r.Daily_Request_Limit__c,
        Service_Type__r.Schedule_After_Days__c
      From 
        Schedule__c 
      Where 
        Id = :sId
    ];
  }

  global List<Schedule__c> getScheduleByOverrideDate(Schedule__c sch) {
    return [
      Select 
        Id, 
        Name, 
        Capacity__c,
        Zone__c,
        Schedule_Date__c, 
        Schedule_Override_Date__c,
        Item_Count__c, 
        Day_of_Week__c,
        No_Service__c,
        Number_of_Service_Requests__c,
        Service_Type__r.Schedule_Type__c,  
        Service_Type__r.Item_Limit__c,
        Service_Type__r.Daily_Request_Limit__c,
        Service_Type__r.Schedule_After_Days__c
      From 
        Schedule__c 
      Where 
        No_Service__c = :sch.No_Service__c AND 
        Service_Type__c = :sch.Service_Type__c AND 
        Zone__c = :sch.Zone__c AND
        Schedule_Date__c = :sch.Schedule_Override_Date__c
      Limit 1
    ];
  }

  global List<Schedule__c> getNextAvailableScheduledDates(String stId) {
    return this.getNextAvailableScheduledDates(stId, '', this.DEFAULT_NUM_OF_SCHEDULES, false);
  }  

  global List<Schedule__c> getNextAvailableScheduledDates(String stId, String zone) {    
    return this.getNextAvailableScheduledDates(stId, zone, this.DEFAULT_NUM_OF_SCHEDULES, false);
  }

  global List<Schedule__c> getNextAvailableScheduledDates(String stId, String zone, Integer numOfSchedules) {
    return this.getNextAvailableScheduledDates(stId, zone, numOfSchedules, false);
  }

  global List<Schedule__c> getNextAvailableScheduledDates(String stId, String zone, Integer numOfSchedules, Integer schAfterDays) {
    return this.getNextAvailableScheduledDates(stId, zone, numOfSchedules, false, schAfterDays); 
  }

  global List<Schedule__c> getNextAvailableScheduledDates(String stId, Integer numOfSchedules, Boolean service) {
    List<Incap311__Schedule__c> nextAvailableSchedules = [
      Select 
        Id, 
        Name, 
        Capacity__c,
        Zone__c,
        Schedule_Date__c,
        Schedule_Override_Date__c, 
        Item_Count__c, 
        Day_of_Week__c,
        No_Service__c,
        Number_of_Service_Requests__c,
        Service_Type__r.Schedule_Type__c,  
        Service_Type__r.Item_Limit__c,
        Service_Type__r.Daily_Request_Limit__c,
        Service_Type__r.Schedule_After_Days__c
      From 
        Schedule__c 
      Where 
        No_Service__c = :service AND 
        Service_Type__c = :stId AND 
        Schedule_Date__c >= TODAY
      Order By
        Schedule_Date__c ASC
      Limit :numOfSchedules
    ];
    return nextAvailableSchedules;
  }

  global List<Schedule__c> getNextAvailableScheduledDates(String stId, String zone, Integer numOfSchedules, Boolean service) {
    return this.getNextAvailableScheduledDates(stId, zone, numOfSchedules, service, 0);
  }

  global List<Schedule__c> getNextAvailableScheduledDates(String stId, String zone, Integer numOfSchedules, Boolean service, Integer schAfterDays) {
    Date queryDate = schAfterDays > 0 ? Date.today().addDays(schAfterDays) : Date.today();

    List<Incap311__Schedule__c> nextAvailableSchedules = [
      Select 
        Id, 
        Name, 
        Capacity__c,
        Zone__c,
        Schedule_Date__c, 
        Schedule_Override_Date__c,
        Item_Count__c, 
        Day_of_Week__c,
        No_Service__c,
        Number_of_Service_Requests__c,
        Service_Type__r.Schedule_Type__c,  
        Service_Type__r.Item_Limit__c,
        Service_Type__r.Daily_Request_Limit__c,
        Service_Type__r.Schedule_After_Days__c
      From 
        Schedule__c 
      Where 
        No_Service__c = :service AND 
        Service_Type__c = :stId AND 
        Zone__c = :zone AND
        Schedule_Date__c >= :queryDate
      Order By
        Schedule_Date__c ASC
      Limit :numOfSchedules
    ];
    return nextAvailableSchedules;
  }

  global List<Schedule__c> getNextAvailableScheduledDates(String stId, String zone, Integer numOfSchedules, Boolean service, String recycleDayOfWeek) {
    return this.getNextAvailableScheduledDates(stId, zone, numOfSchedules, service, recycleDayOfWeek, new Set<Id>(), 0);
  }

  global List<Schedule__c> getNextAvailableScheduledDates(String stId, String zone, Integer numOfSchedules, Boolean service, String recycleDayOfWeek, Set<Id> idsToIgnore) {
    return this.getNextAvailableScheduledDates(stId, zone, numOfSchedules, service, recycleDayOfWeek, idsToIgnore, 0);
  }

  global List<Schedule__c> getNextAvailableScheduledDates(String stId, String zone, Integer numOfSchedules, Boolean service, String recycleDayOfWeek, Set<Id> idsToIgnore, Integer schAfterDays) {
    Date queryDate = schAfterDays > 0 ? Date.today().addDays(schAfterDays) : Date.today();
    // Dotw should always be a comma seperated string and split back into a list for use in the SOQL.
    List<String> dotwList = recycleDayOfWeek != null ? recycleDayOfWeek.split(',') : new List<String>();

    List<Incap311__Schedule__c> nextAvailableSchedules = [
      Select 
        Id, 
        Name, 
        Capacity__c,
        Zone__c,
        Schedule_Date__c, 
        Schedule_Override_Date__c,
        Item_Count__c, 
        Day_of_Week__c,
        No_Service__c,
        Number_of_Service_Requests__c,
        Service_Type__r.Schedule_Type__c,  
        Service_Type__r.Item_Limit__c,
        Service_Type__r.Daily_Request_Limit__c,
        Service_Type__r.Schedule_After_Days__c
      From 
        Schedule__c 
      Where 
        No_Service__c = :service AND 
        Service_Type__c = :stId AND 
        Zone__c = :zone AND
        Schedule_Date__c >= :queryDate AND
        Day_of_Week__c IN :dotwList AND
        Id NOT IN :idsToIgnore
      Order By
        Schedule_Date__c ASC
      Limit :numOfSchedules
    ];
    return nextAvailableSchedules;
  }

    global List<Schedule__c> getNextAvailableScheduledDates(String stId, String zone, Integer numOfSchedules, Boolean service, Set<Id> idsToIgnore, Integer schAfterDays) {
    Date queryDate = schAfterDays > 0 ? Date.today().addDays(schAfterDays) : Date.today();

    List<Incap311__Schedule__c> nextAvailableSchedules = [
      Select 
        Id, 
        Name, 
        Capacity__c,
        Zone__c,
        Schedule_Date__c, 
        Schedule_Override_Date__c,
        Item_Count__c, 
        Day_of_Week__c,
        No_Service__c,
        Number_of_Service_Requests__c,
        Service_Type__r.Schedule_Type__c,  
        Service_Type__r.Item_Limit__c,
        Service_Type__r.Daily_Request_Limit__c,
        Service_Type__r.Schedule_After_Days__c
      From 
        Schedule__c 
      Where 
        No_Service__c = :service AND 
        Service_Type__c = :stId AND 
        Zone__c = :zone AND
        Schedule_Date__c >= :queryDate AND
        Id NOT IN :idsToIgnore
      Order By
        Schedule_Date__c ASC
      Limit :numOfSchedules
    ];
    return nextAvailableSchedules;
  }

  global Boolean verifyAvailablityByScheduleType(Schedule__c sch) {
    if (sch.Service_Type__r.Schedule_Type__c == 'Requests') {
      // 13 Apr 2017: Changed #Requests to Item count to keep consistent with items type. 
      Integer tally = Integer.valueOf(sch.Item_Count__c + TYPE_REQUESTS_INCREMENT_VALUE); 
      // IF the capacity is filled, treat it like an override. Use the default daily request limit on the type otherwise. 
      Integer schLimit = Integer.valueOf(sch.Capacity__c != null ? sch.Capacity__c : sch.Service_Type__r.Daily_Request_Limit__c);
      // TODO: Check the roll up summary agaiunst the capacity and default value for number of allowed requests. 
      if (tally <= schLimit) {
        return true;
      }
    }
    return false;
  } 

  global Boolean verifyAvailablityByScheduleType(Schedule__c sch, Integer items) {
    items = (items != null ? items : 0);
    Integer schLimit = Integer.valueOf(sch.Capacity__c != null ? sch.Capacity__c : sch.Service_Type__r.Daily_Request_Limit__c);

    if (sch.Service_Type__r.Schedule_Type__c == 'Items') {
      // TODO: Verify the number of items passed into the function against the capacity/default value.
      Integer tally = Integer.valueOf((sch.Item_Count__c != null ? sch.Item_Count__c : 0) + items); 

      if (items != 0 && tally <= schLimit) {
        return true;
      }
    } else if (sch.Service_Type__r.Schedule_Type__c == 'Requests') {
      return verifyAvailablityByScheduleType(sch);
    }
    return false;
  }

  // False = Limits not reached. True = Limit reached. 
  global Boolean verifyLimitsReachedByLocation(Service_Type_Version__c stv, Decimal lat, Decimal lng) {
    // If both fields are null then assume unlimited/no restriction. 
    if (stv.Service_Type__r.Schedulable_Requests_Limit_Month__c == null && stv.Service_Type__r.Schedulable_Requests_Limit_Year__c == null) {
      return false;
    }

    Integer monthInt = System.Today().Month();
    Integer yearInt = System.Today().Year();
    // Query SR_Schedulable for SR's pretaining to the location provided. Will need count based on month and year.
    List<Service_Request_Schedule__c> srMonthCount = [
      Select 
        Id
      From 
        Service_Request_Schedule__c
      Where 
        Schedule__r.Service_Type__c = :stv.Service_Type__c AND 
        Service_Request__r.Location__Latitude__s = :lat AND
        Service_Request__r.Location__Longitude__s = :lng AND 
        CALENDAR_MONTH(CreatedDate) = :monthInt
    ];

    List<Service_Request_Schedule__c> srYearCount = [
      Select 
        Id
      From 
        Service_Request_Schedule__c
      Where 
        Schedule__r.Service_Type__c = :stv.Service_Type__c AND 
        Service_Request__r.Location__Latitude__s = :lat AND
        Service_Request__r.Location__Longitude__s = :lng AND 
        CALENDAR_YEAR(CreatedDate) = :yearInt
    ];

    // Check month for overage. 
    if (stv.Service_Type__r.Schedulable_Requests_Limit_Month__c <= srMonthCount.size()) {
      return true;
    }

    // Check year for overage.
    if (stv.Service_Type__r.Schedulable_Requests_Limit_Year__c <= srYearCount.size()) {
      return true;
    }
    return false;
  }

  global Map<String, Boolean> verifyLimitsReachedByLocationIndividually(Service_Type_Version__c stv, Decimal lat, Decimal lng) {
    Map<String, Boolean> returnMap = new Map<String, Boolean>{
      'month' => false,
      'year' => false
    };

    // If both fields are null then assume unlimited/no restriction. 
    if (stv.Service_Type__r.Schedulable_Requests_Limit_Month__c == null && stv.Service_Type__r.Schedulable_Requests_Limit_Year__c == null) {
      return returnMap;
    }

    Integer monthInt = System.Today().Month();
    Integer yearInt = System.Today().Year();
    // Query SR_Schedulable for SR's pretaining to the location provided. Will need count based on month and year.
    List<Service_Request_Schedule__c> srMonthCount = [
      Select 
        Id
      From 
        Service_Request_Schedule__c
      Where 
        Schedule__r.Service_Type__c = :stv.Service_Type__c AND 
        Service_Request__r.Location__Latitude__s = :lat AND
        Service_Request__r.Location__Longitude__s = :lng AND 
        CALENDAR_MONTH(CreatedDate) = :monthInt
    ];

    List<Service_Request_Schedule__c> srYearCount = [
      Select 
        Id
      From 
        Service_Request_Schedule__c
      Where 
        Schedule__r.Service_Type__c = :stv.Service_Type__c AND 
        Service_Request__r.Location__Latitude__s = :lat AND
        Service_Request__r.Location__Longitude__s = :lng AND 
        CALENDAR_YEAR(CreatedDate) = :yearInt
    ];

    // Check month for overage. 
    returnMap.put('month', stv.Service_Type__r.Schedulable_Requests_Limit_Month__c <= srMonthCount.size() ? true : false);
    returnMap.put('year', stv.Service_Type__r.Schedulable_Requests_Limit_Year__c <= srYearCount.size() ? true : false);
    return returnMap;
  }

  global Boolean verifyDuplicateScheduleByLocation(Service_Type_Version__c stv, Decimal lat, Decimal lng) {
    if (stv.Service_Type__r.Schedule_Duplicate_Detection__c) {
      List<Service_Request_Schedule__c> srDayCountList = [
        Select 
          Id
        From 
          Service_Request_Schedule__c
        Where 
          Schedule__r.Service_Type__c = :stv.Service_Type__c AND 
          Service_Request__r.Location__Latitude__s = :lat AND
          Service_Request__r.Location__Longitude__s = :lng AND 
          CreatedDate = TODAY
      ];
      // If one or more requests are found for today with dupe detection active then return false.
      // This signifies that no more schedules may be made for this day.
      return srDayCountList.size() > 0 ? false : true;
    }
    return true;
  }

  global Schedule__c updateScheduleCount(Schedule__c sch, Decimal count) {
    sch.Item_Count__c = sch.Item_Count__c + count;
    update sch;
    return getSchedule(sch.Id);
  }

  global Service_Request_Schedule__c createServiceRequestSchedule(Schedule__c chosenSchedule, Case c) {
    System.debug('----> Creating SR Schedule link...');
    // Create a new mapping object beterrn the case and schedule.
    Service_Request_Schedule__c src = new Service_Request_Schedule__c(
      Schedule__c = chosenSchedule.Id,
      Service_Request__c = c.Id
    );
    insert src;
    System.debug('----> Updating SR auto close feature using collection information...');
    // Update the case to auto close on the date of the next available schedule. 
    c.Auto_Close__c = true;
    c.Auto_Close_Date__c = chosenSchedule.Schedule_Date__c;
    update c;

    return src;
  }

  global Service_Request_Schedule__c createServiceRequestSchedule(Schedule__c chosenSchedule, Case c, Decimal numOfItems) {
    Service_Request_Schedule__c src = createServiceRequestSchedule(chosenSchedule, c);

    if (numOfItems != null) {
      src.Number_Of_Items__c = numOfItems;
      update src;
    }
    return src;
  }
}