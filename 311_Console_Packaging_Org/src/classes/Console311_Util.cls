public class Console311_Util {

  public final static String CONTACT_REQUIRED_STATUS = 'Required (LN, FN, EM)';

   /**
   * getPicklistValues
   *
   * This function will return a select option list of picklist values using a passed in object and field name.
   * @author Darkis
   * @param obj SObject The object to grab the picklist values from.
   * @param fld String The field name where the picklist values are stored in the object.
   * @return List<SelectOption> A list of select options for visualforce.
   */
  public static list<SelectOption> getPicklistValues(SObject obj, String fld){
    list<SelectOption> options = new list<SelectOption>();
    // Get the object type of the SObject.
    Schema.sObjectType objType = obj.getSObjectType();
    // Describe the SObject using its object type.
    Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
    // Get a map of fields for the SObject
    map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
    // Get the list of picklist values for this field.
    list<Schema.PicklistEntry> values =
    fieldMap.get(fld).getDescribe().getPickListValues();
    // Add these values to the selectoption list.
    for (Schema.PicklistEntry a : values) {
      options.add(new SelectOption(a.getLabel(), a.getValue()));
    }
    return options;
  }

  /**
   * getStatesByCountry
   *
   * This function will return a select option list of state values for a specified country.
   * @author Darkis
   * @param String countryCode The code for the country desired.
   * @return List<SelectOption> A list of select options for visualforce.
   */
  public static list<SelectOption> getStatesByCountry(String countryCode){
    list<SelectOption> options = new list<SelectOption>();
    // Get the object type of the SObject.
    Schema.sObjectType objType = Contact.getSObjectType();
    // Describe the SObject using its object type.
    Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
    // Get a map of fields for the SObject
    map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
    // Get the list of picklist values for this field.
    list<Schema.PicklistEntry> values =
    fieldMap.get('MailingState').getDescribe().getPickListValues();
    // Add these values to the selectoption list.
    for (Schema.PicklistEntry a : values) {
      options.add(new SelectOption(a.getLabel(), a.getValue()));
    }
    return options;
  }

  /**
   * isContactRequiredToCreateCase
   *
   * @author Darkis
   * @description This function will verify that for the specified type if a contact is required or not.
   * @param contactStatus String The validation string for if a contact is necessary.
   * @param con Contact The contact object to save.
   * @return Boolean 
   */
  public static Boolean isContactRequiredToCreateCase(String contactStatus, Contact con) {
    Boolean isContactReq = false;
    try {
      if (contactStatus == Console311_Util.CONTACT_REQUIRED_STATUS) {
        isContactReq = (con == null ? null : true);
      } else {
        if (con != null && (!String.isBlank(con.LastName) || !String.isBlank(con.firstName) || !String.isBlank(con.phone) || !String.isBlank(con.email))) {
          isContactReq = true;
        }
      }
    } catch(exception e) {
      system.debug('----> Unable to complete process for contact validation: ' + e.getMessage());
      throw new Console311_Exceptions.Console311RequiredException(e); // custom Exception message added
    }
    return isContactReq;
  }

  public static Map<String, String> getStateByStateCodeMap() {
    Map<String, String> codeToStateMap = new Map<String,String>();
    codeToStateMap.put('AL', 'Alabama');
    codeToStateMap.put('AK', 'Alaska');
    codeToStateMap.put('AZ', 'Arizona');
    codeToStateMap.put('AR', 'Arkansas');
    codeToStateMap.put('CA', 'California');
    codeToStateMap.put('CO', 'Colorado');
    codeToStateMap.put('CT', 'Connecticut');
    codeToStateMap.put('DE', 'Delaware');
    codeToStateMap.put('DC', 'District of Columbia');
    codeToStateMap.put('FL', 'Florida');
    codeToStateMap.put('GA', 'Georgia');
    codeToStateMap.put('HI', 'Hawaii');
    codeToStateMap.put('ID', 'Idaho');
    codeToStateMap.put('IL', 'Ilinois');
    codeToStateMap.put('IN', 'Indiana');
    codeToStateMap.put('IA', 'Iowa');
    codeToStateMap.put('KS', 'Kansas');
    codeToStateMap.put('KY', 'Kentucky');
    codeToStateMap.put('LA', 'Louisiana');
    codeToStateMap.put('ME', 'Maine');
    codeToStateMap.put('MD', 'Maryland');
    codeToStateMap.put('MA', 'Massachusetts');
    codeToStateMap.put('MI', 'Michigan');
    codeToStateMap.put('MN', 'Minnesota');
    codeToStateMap.put('MS', 'Mississippi');
    codeToStateMap.put('MO', 'Missouri');
    codeToStateMap.put('MT', 'Montana');
    codeToStateMap.put('NE', 'Nebraska');
    codeToStateMap.put('NV', 'Nevada');
    codeToStateMap.put('NH', 'New Hampshire');
    codeToStateMap.put('NJ', 'New Jersey');
    codeToStateMap.put('NM', 'New Mexico');
    codeToStateMap.put('NY', 'New York');
    codeToStateMap.put('NC', 'North Carolina');
    codeToStateMap.put('ND', 'North Dakota');
    codeToStateMap.put('OH', 'Ohio');
    codeToStateMap.put('OK', 'Oklahoma');
    codeToStateMap.put('OR', 'Oregon');
    codeToStateMap.put('PA', 'Pennsylvania');
    codeToStateMap.put('RI', 'Rhode Island');
    codeToStateMap.put('SC', 'South Carolina');
    codeToStateMap.put('SD', 'South Dakota');
    codeToStateMap.put('TN', 'Tennessee');
    codeToStateMap.put('TX', 'Texas');
    codeToStateMap.put('UT', 'Utah');
    codeToStateMap.put('VT', 'Vermont');
    codeToStateMap.put('VA', 'Virginia');
    codeToStateMap.put('WA', 'Washington');
    codeToStateMap.put('WV', 'West Virginia');
    codeToStateMap.put('WI', 'Wisconsin');
    codeToStateMap.put('WY', 'Wyoming');
    return codeToStateMap;
  }

  public static Map<String, Map<String, String>> retrieveObjFieldNameListByLayoutConfiguration(String sObjectName, String csvFieldLayout) {
    Map<String, Map<String, String>> fieldNameMap = new Map<String, Map<String, String>>();
    List<String> fieldNamesForObject = csvFieldLayout.replaceAll( '\\s+', '').split(',');

    // Get the objects schema.
    Schema.DescribeSObjectResult r = (Schema.getGlobalDescribe().get(sObjectName)).getDescribe();
    // Loop througbh the field names of the object presented in the configuration.
    for (String fieldName : fieldNamesForObject) {
      Schema.DescribeFieldResult f;
      String typeStr = '';
      // Check if the fieldname is in the mapping.
      if (r.fields.getMap().get(fieldName) != null) {
        f = r.fields.getMap().get(fieldName).getDescribe();
      }
     
      fieldNameMap.put(
        fieldName, 
        new Map<String,String>{
          'Data_Type' => (f != null ? String.valueOf(f.getType()) : 'UNKNOWN'),
          'Label' => (f != null ? String.valueOf(f.getLabel()) : fieldName),
          'Picklist_Values' => (f != null ? JSON.serialize(f.getPicklistValues()) : '')
        }
      ); 
    }
    return fieldNameMap;
  }

  public static Map<String, Map<String, Map<String, String>>> formatSobjectDataUtilMap(List<SObject> objList, String sObjectName, String csvFieldLayout) {
    Map<String, Map<String, Map<String, String>>> sObjectFieldUtilMap = new Map<String, Map<String, Map<String, String>>>();
    List<String> fieldNamesForObject = csvFieldLayout.replaceAll( '\\s+', '').split(',');

    // Loop through the result set.
    for (sObject obj : objList) {
      // Get the objects schema.
      Schema.DescribeSObjectResult r = obj.getSObjectType().getDescribe();//(Schema.getGlobalDescribe().get(sObjectName)).getDescribe();
      // Loop througbh the field names of the object presented in the configuration.
      for (String fieldName : fieldNamesForObject) {
        Schema.DescribeFieldResult f;
        String type = 'UNKNOWN';
        // Check if the fieldname is in the mapping.
        if (r.fields.getMap().get(fieldName) != null) {
          f = r.fields.getMap().get(fieldName).getDescribe();
        }
        System.debug('----> obj: ' + obj);
        System.debug('----> sObjectFieldUtilMap: ' + sObjectFieldUtilMap);
        // If the object key already exists then simply add to the map otherwise create it new. 
        // When adding to the map add the primiative data type for the field. If no type is available due to it being a relation then say 'UNKNOWN'.
        if (sObjectFieldUtilMap.containsKey(obj.Id)) {
          (sObjectFieldUtilMap.get(obj.Id)).put(
            fieldName, 
            new Map<String,String>{
              'Data_Type' => (f != null ? String.valueOf(f.getType()) : 'UNKNOWN'),
              'Label' => (f != null ? String.valueOf(f.getLabel()) : fieldName),
              'Picklist_Values' => (f != null ? JSON.serialize(f.getPicklistValues()) : '')
            }
          );
        } else {
          sObjectFieldUtilMap.put(
            obj.Id, 
            new Map<String, Map<String,String>> {
              fieldName => new Map<String,String> {
                'Data_Type' => (f != null ? String.valueOf(f.getType()) : 'UNKNOWN'),
                'Label' => (f != null ? String.valueOf(f.getLabel()) : fieldName),
                'Picklist_Values' => (f != null ? JSON.serialize(f.getPicklistValues()) : '') 
              }
            }
          );
        }
        // If it is a date sObject field then get a formatted date string result.
        if (fieldName.containsIgnoreCase('Date')) {
          // Attempt to convery the sObjects date field into a Date Object.
          Date tempDatetime = (Date) obj.get(fieldName);
          // Place into the util map the formatted date if applicable or a null string. 
          sObjectFieldUtilMap.get(obj.Id).get(fieldName).put('Formatted_Date', (tempDatetime != null ? tempDatetime.format() : 'null'));
        }
      }
    }
    return sObjectFieldUtilMap;
  }

  public static String genDayOfWeekFromFormatted(String formattedDotw, String format) {
    List<String> dotwStr = new List<String>();

    System.debug('----> [genDayOfWeekFromFormatted] formattedDotw: ' + formattedDotw);
    System.debug('----> [genDayOfWeekFromFormatted] format: ' + format);

    if (format.equalsIgnoreCase('d')) {
      List<String> stringCharacters = formattedDotw.split('');
      System.debug('----> [genDayOfWeekFromFormatted] stringCharacters: ' + stringCharacters);
      Integer count = 0;

      for (String dotw : stringCharacters) {
        System.debug('----> [genDayOfWeekFromFormatted] dotw: ' + dotw);

        if (dotw.equalsIgnoreCase('M')) {
          dotwStr.add('Monday');
        } else if (dotw.equalsIgnoreCase('T')) {
          if (stringCharacters.size() >= (count + 1) && stringCharacters[count + 1] == 'H') {
            dotwStr.add('Thursday');
          } else {
            dotwStr.add('Tuesday');
          }
        } else if (dotw.equalsIgnoreCase('W')) {
          dotwStr.add('Wednesday');
        } else if (dotw.equalsIgnoreCase('F')) {
          dotwStr.add('Friday');
        }
        count += 1; 
      }
    }
    System.debug('----> JSON dotw Str: ' + dotwStr);
    return String.join(dotwStr,',');
  }
}