/**
* @author Sean Murphy 
* @date  10/18/2016  
* @group 
* @group-content
* @description 
*/
global without sharing class Base311_DateTime_Util {

	public static List<Holiday> holidayList {get; private set;}

	public DateTime dateTimeValue { get; set; }
    
	global String getTimeZoneValue() {
		if( dateTimeValue != null ) { 
			String timezone = (isDST(dateTimeValue) ? 'EDT' : 'EST');
			String localeFormatDT = dateTimeValue.format('MMM dd, yyyy h:mm:ss a', 'America/New_York');
			return localeFormatDT;
		}
		return ' ';
	}
    
	global Boolean isDST(datetime dtDateTime) {
		Date dtDate = dtDateTime.Date();
		Date dtWeekStart = dtDate.toStartofWeek();
		Integer yy = dtDateTime.Year();
		     
		if (dtWeekStart >= (date.newInstance(yy, 03, 08)) && dtWeekStart <= (date.newInstance(yy, 11, 01))) {
			return true;
		}
		else {
			return false;
		}
	}
  
	global static DateTime getEndDate(DateTime startDateTime, String calcType, Decimal period, Boolean excludeHolidays) {
		if (calcType != NULL && calcType.toLowerCase() == 'business days') {
			return getEndDateTimeInBusinessDays(startDateTime, Integer.valueOf(period), excludeHolidays);
		}
		else if (calcType != NULL && calcType.toLowerCase() == 'calendar days') {
			return getEndDateTimeInCalendarDays(startDateTime, Integer.valueOf(period));
		}
		else if (calcType != NULL && calcType.toLowerCase() == 'hours') {
			return getEndDateTimeInHours(startDateTime, Integer.valueOf(period));
		}
		else {
			return null;
		}
	}
  
  
	global static DateTime getEndDateTimeInBusinessDays(DateTime startDateTime, Integer days, Boolean excludeHolidays) {
  		Boolean excludeDay;
    	List<Holiday> holidays = null;
    
    	if (excludeHolidays) {
      		holidayList = getHolidays(startDateTime.date());
    	}
    
    	if (days == 0) {
      		return startDateTime;
    	}
    	else if (days > 0) {
      		Integer daysAdded = 0;
      		DateTime endDate = DateTime.newInstance(startDateTime.date(), startDateTime.time());
      		while (daysAdded < days) {
        		endDate = endDate.addDays(1);
        		excludeDay = false;       
        		// check if it is a weekend day, if so exclude the day
        		if (endDate.format('E').toLowerCase().startsWith('s')) {
          			excludeDay = true;
        		}
        
        		// check if it is a holiday
        		if ((excludeHolidays) && (!excludeDay)) {
          			//for (Holiday h : holidays) {
            			//System.debug('@@@@@ holiday being checked: ' + h.ActivityDate);
            			//if (endDate.date().isSameDay(h.ActivityDate)) {
              				excludeDay = getIsHoliday(endDate.date());  //true;
              				//break;
            			//}
          			//}
        		} 
        
        		if (!excludeDay) {
          			daysAdded++;
        		}
      		}
      		return endDate;
    	}
    	else {
      		return null;
    	}
	}
  
	global static DateTime getEndDateTimeInCalendarDays(DateTime startDateTime, Integer days) {
		return startDateTime.addDays(days);
	}
  
	global static DateTime getEndDateTimeInHours(DateTime startDateTime, Integer hours) {
		return startDateTime.addHours(hours);
	}
  
	private static List<Holiday> getHolidays(Date startDate) {
		List<Holiday> holidays = [SELECT Id, Name, ActivityDate, IsAllDay, EndTimeInMinutes, StartTimeInMinutes FROM Holiday WHERE ActivityDate > :startDate];
		return holidays;
	}
	
	/*
     *	evaluates the SLA dates and dynamic SLA flag on insert using service type version start and end dates if applicable
     */
    public static void verifySLAonInsert(List<Case> newCase) {
        Set<Id> stids = new Set<Id>();
        for (Case c : newCase) {
            stids.add(c.Incap311__Service_Type_Version__c);
        }
        
        Map<Id, Incap311__Service_Type_Version__c> stvmap = new map<Id, Incap311__Service_Type_Version__c>([SELECT Id, Incap311__Start_Date__c, Incap311__Stop_Date__c, Incap311__SLA_Type__c, Incap311__SLA__c, Incap311__Enable_Operational_SLA__c
                                                                    						FROM Incap311__Service_Type_Version__c
                                                                    						WHERE Id IN :stids]);
        
        for (Case c : newCase) {
            Incap311__Service_Type_Version__c stv = stvmap.get(c.Incap311__Service_Type_Version__c);
            if ((stv != null) && (stv.Incap311__Enable_Operational_SLA__c)) {
                Case cs = getDynamicSLAStartDate(stv, c);
                c.Incap311__Expected_Start_Date__c = cs.Incap311__Expected_Start_Date__c;
                c.Incap311__Expected_Date_Time__c = getEndDate(c.Incap311__Expected_Start_Date__c, stv.Incap311__SLA_Type__c, stv.Incap311__SLA__c, true);		//cs.Expected_Date_Time__c;
                c.Status = cs.Status;
                //System.debug('>>>-----> Id: ' + c.Id);
                //System.debug('>>>-----> exp start date: ' + c.Incap311__Expected_Start_Date__c);
                //System.debug('>>>-----> exp date/time: ' + c.Incap311__Expected_Date_Time__c);
                //System.debug('>>>-----> status: ' + c.Status);
            }
        }
    }
	
	
	public static Case getDynamicSLAStartDate(Incap311__Service_Type_Version__c stv, Case c) {
            Date csstartdate, csenddate, stopdate, startdate;
            Boolean isstartdateleap = Date.isLeapYear(stv.Incap311__Start_Date__c.Year());
            Boolean isstopdateleap = Date.isLeapYear(stv.Incap311__Stop_Date__c.Year());
            
            if (date.today().Year() > stv.Incap311__Stop_Date__c.year()) {
                if (stv.Incap311__Start_Date__c.month() == 2 && stv.Incap311__Start_Date__c.day() == 29) {
                    stv.Incap311__Start_Date__c = stv.Incap311__Start_Date__c.addDays(1);
                }
                
                if (stv.Incap311__Stop_Date__c.month() == 2 && stv.Incap311__Stop_Date__c.day() == 29) {
                    stv.Incap311__Stop_Date__c = stv.Incap311__Stop_Date__c.addDays(1);
                }
                
                startdate = Date.newInstance(Date.today().Year(), stv.Incap311__Start_Date__c.month(), stv.Incap311__Start_Date__c.day());
                
                if (stv.Incap311__Start_Date__c.year() < stv.Incap311__Stop_Date__c.Year()) {
                		stopdate = Date.newInstance(Date.today().Year() + 1, stv.Incap311__Stop_Date__c.month(), stv.Incap311__Stop_Date__c.day());
                }
        		else {
           			stopdate = Date.newInstance(Date.today().Year(), stv.Incap311__Stop_Date__c.month(), stv.Incap311__Stop_Date__c.day());
        		}
            }
            else {
                startdate = stv.Incap311__Start_Date__c;
                stopdate = stv.Incap311__Stop_Date__c;
            }           
                
            if (date.today() >= startdate && date.today() <= stopdate) {
            		csstartdate = Date.today();  
            		//c.Status = 'In Progress';
            }
            else if (date.today() < startdate) {
                c.Status = 'Hold';
                csstartdate = startdate;
                
            }
            else if (date.today() > stopdate) {
                c.Status = 'Hold';
                csstartdate = Date.newInstance(Date.today().Year() + 1, startdate.month(), startdate.day());
            }
            
            if ((stv.Incap311__Start_Date__c.month() == 2) && (stv.Incap311__Start_Date__c.day() == 29) && (date.isLeapYear(csstartdate.year()))) {
                 csstartdate = csstartdate.addDays(-1);
            }
            
            Datetime csstartdatetime = Datetime.newInstance(csstartdate.year(), csstartdate.month(), csstartdate.day(), Datetime.now().hour(), Datetime.now().minute(), Datetime.now().second());
            c.Incap311__Expected_Start_Date__c = csstartdatetime;
            return c;
    }
	
	global static Decimal getElapsedSLA(DateTime startDateTime, DateTime endDateTime, String slaType) {
		return calcElapsedDaysInHours(startDateTime, endDateTime, slaType);
	}
	
	
	private static Decimal calcElapsedDaysInHours(DateTime startDateTime, DateTime endDateTime, String slaType) {
		System.debug('>>>-----> start date time: ' + startDateTime);
		holidayList = getHolidays(startDateTime.date());
		
		Date startDate = startDateTime.date();
		Date endDate = endDateTime.date();
		Integer numDays = startDate.daysBetween(endDate);
		if (numDays == 0) {
			// return now - start time calc'ed as end day
			return getPartialDayInHours(endDateTime, false) - getPartialDayInHours(startDateTime, false);  // for the same day, the start date is the end date
		}
		else if (numDays == 1) {
			// return remainder of start day + consumed last day
			return getPartialDayInHours(startDateTime, true) + getPartialDayInHours(endDateTime, false);
		}
		else {
			Date d;
			Decimal totalTime = 0.0;
			for (Integer i = 0; i <= numDays; i++) {
				d = startDate.addDays(i);
				
				if (d == startDate) {
					// add now - startDateTime	to TOTAL
					totalTime += getPartialDayInHours(startDateTime, true);
				}
				else if (d == endDate) {
					// add remainder of start day + consumed last day to TOTAL
					totalTime += getPartialDayInHours(endDateTime, false);
				}
				else {
					// if calendar days OR ((not weekend) and (not holiday)
					DateTime dt = DateTime.newInstance(d, Time.newInstance(0,0,0,0));
					if ((slaType.equalsIgnoreCase('calendar days')) || ((!dt.format('E').toLowerCase().startsWith('s')) && (!getIsHoliday(d)))) {
						// add 24 to total
						totalTime += 24.0;
					}
				}
			}
			
			return totalTime;
		}
	}
	
	
	public static Decimal getPartialDayInHours(DateTime dt, Boolean isFirstDay) {
		if (dt != null) {
			//24.0 - hours component
			Integer hours = dt.hour();
			//60 - minutes component
			Integer mins = dt.minute();
			//60 - seconds component
			Integer secs = dt.second();
			//1000 - milliseconds component
			Integer millis = dt.millisecond();
			
			if (isFirstDay) {						// calc remaining on first day
				
				if (hours > 0) {
					hours = (24 - hours);
				}
				
				if (mins > 0) {
					mins = (60 - mins);
				}
				
				if (secs > 0) {
					secs = (60 - secs);
				}
				
				if (millis > 0) {
					millis = (1000 - millis);
				}
			}
			
			return (hours + (mins / 60.0) + (secs / 3600.0) + (millis / 3600000.0));
		}
		else {
			return null;
		}
	}
	
	public static Boolean getIsHoliday(Date checkDate) {
		Boolean isHoliday = false;
    	for (Holiday h : holidayList) {
        	if (checkDate.isSameDay(h.ActivityDate)) {
         		isHoliday = true;
          		break;
        	}
      	}
      	
      	return isHoliday;
	}
	
	
	public static String transformDateTimeString(String srcDateTime) {
		List<String> dateAndTime = srcDateTime.split(' ');
        String dt = dateAndTime.get(0);
        String tm = dateAndTime.get(1);
        List<String> dayMonthYear = dt.split('/');
        List<String> hourMinute = tm.split(':');
        System.debug('>>>-----> dayMonthYear: ' + dayMonthYear);
        String day = dayMonthYear[1];
        String month = dayMonthYear[0];
        String year = dayMonthYear[2];
        String hour = hourMinute.get(0);
        String minute = hourMinute.get(1);
        String sec = '00';
        String yourLocaleDateTimeString = year + '-' + month + '-' + day + ' ' + hour + ':' + minute + ':' + sec;
        System.debug('>>>-----> localeDateTimeString: ' + yourLocaleDateTimeString);
        return yourLocaleDateTimeString;
	}
	
	
	/*
     *  recalculates the SLA on a case using service type version start and end dates if operational SLA has been enabled for the service type version and the start date
     *  is outside of the version start date/end date window
     */
    public static void recalcSLA(List<Case> newCase, Map<Id, SObject> oldCaseMap) {
    	System.debug('>>>-----> recalculating SLA...');
        Set<Id> stIds = new Set<Id>();
        List<Case> noOverrideCases = new List<Case>();
        for (Case c : newCase) {
            if(!c.Override_SLA_Calc__c){
                stIds.add(c.Incap311__Service_Type_Version__c); 
                noOverrideCases.add(c);
            }
        }
        
        Map<id, Incap311__Service_Type_Version__c> stvmap = new Map<id,Incap311__Service_Type_Version__c>([SELECT Id, Incap311__Start_Date__c, Incap311__Stop_Date__c,
                                                        Incap311__SLA_Type__c, Incap311__SLA__c, Incap311__Enable_Operational_SLA__c,Incap311__Service_Type__r.Incap311__Is_Bulk_Type__c FROM 
                                                        Incap311__Service_Type_Version__c WHERE id IN :stids]);
        
        for (Case c : noOverrideCases) {
            Incap311__Service_Type_Version__c stv = stvmap.get(c.Incap311__Service_Type_Version__c);
            Case oldCase = (Case)oldCaseMap.get(c.Id);
            if (stv.Incap311__Service_Type__r.Incap311__Is_Bulk_Type__c) {
                c.Incap311__Expected_Date_Time__c = c.Incap311__Auto_Close_Date__c;
            }
            else if (stv.Incap311__Enable_Operational_SLA__c) {
            	//System.debug('>>>-----> not a bulk case.  Id: ' + c.Id);
            	//System.debug('>>>-----> old status: ' + oldCase.Status);
                //System.debug('>>>-----> new status: ' + c.Status);
                //System.debug('>>>-----> exp start date: ' + c.Incap311__Expected_Start_Date__c);
                //System.debug('>>>-----> exp date time: ' + c.Incap311__Expected_Date_Time__c);
            	if (c.Status.containsIgnorecase('Hold') && !oldCase.Status.containsIgnorecase('Hold')) {
                    Double elapsed;
                    elapsed = Incap311.Base311_DateTime_Util.getElapsedSLA(c.Incap311__Expected_Start_Date__c, System.now(), stv.Incap311__SLA_Type__c);
                    if (elapsed > 0.0) {
                        c.Incap311__Elapsed_SLA_Hours__c = c.Incap311__Elapsed_SLA_Hours__c == null ? elapsed : c.Incap311__Elapsed_SLA_Hours__c + elapsed;
                    }
                    c.Incap311__Expected_Start_Date__c = null;
                    c.Incap311__Expected_Date_Time__c = null;
                }
                else if (!c.Status.containsIgnorecase('Hold') && oldCase.Status.containsIgnorecase('Hold')) {
                    Case cs = getDynamicSLAStartDate(stv, c);
                    c.Incap311__Expected_Start_Date__c = cs.Incap311__Expected_Start_Date__c;
                    if (c.Incap311__Elapsed_SLA_Hours__c > 0) {
                        cs.Incap311__Expected_Date_Time__c = cs.Incap311__Expected_Date_Time__c.addHours(-1 * Integer.valueOf(c.Incap311__Elapsed_SLA_Hours__c));
                    }
                    
                    // if not hours do calc
                    if ((stv.Incap311__SLA_Type__c.equalsIgnoreCase('calendar days')) || (stv.Incap311__SLA_Type__c.equalsIgnoreCase('business days'))) {
                        Decimal remainingSLA = ((stv.Incap311__SLA__c * 24.0) - oldCase.Incap311__Elapsed_SLA_Hours__c) / 24.0;
                        c.Incap311__Expected_Date_Time__c = Incap311.Base311_DateTime_Util.getEndDate(c.Incap311__Expected_Start_Date__c, stv.Incap311__SLA_Type__c, remainingSLA, true);
                    }
                    else {
                        c.Incap311__Expected_Date_Time__c = Incap311.Base311_DateTime_Util.getEndDate(c.Incap311__Expected_Start_Date__c, stv.Incap311__SLA_Type__c, stv.Incap311__SLA__c, true);
                    }
                }
            }
        }
    }
}