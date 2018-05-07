public with sharing class Console311_LookupCtrl {

    private final String QUERY_TYPE_SOQL = 'soql';
    private final String QUERY_TYPE_SOSL = 'sosl';
    private final Map<String, Map<String, String>> mObjToServiceMap = new Map<String, Map<String,String>> {
      'contact' => new Map<String,String> {
        'service' => 'Base311_AccountAndContactUtils',
        'method' => 'searchContacts'
      },
        'contactanduser' => new Map<String,String> {
        'service' => 'Base311_AccountAndContactUtils',
        'method' => 'searchContactsandUsers'
      },
      'account' => new Map<String, String> {
        'service' => 'Base311_AccountAndContactUtils',
        'method' => 'searchAccounts'
      },
      'case' => new Map<String, String> {
        'service' => 'Base311_Service_Request',
        'method' => 'searchServiceRequests'
      }
    };

    public String sObjectName { get; set; }
    public String mCallbackFuncName { get; set; }
    public String mActiveQueryLangType { get; set; }

    public String queryStr { get; set; }
    public String errorMessage { get; set; }
    public String mOrderCondition { get; set; }
    public List<SObject> queryResults { get; set; }
    public List<String> fieldNamesForObject { get; set; }
    public Map<String, String> mQueryResultJsonMapById { get; set; }
    public Map<String, Map<String, String>> fileNamesForObjectFormatted { get; set; }
    public Map<String, Map<String, Map<String, String>>> sObjectFieldUtilMap { get; set; }

    private Incap311__Lookup_Config__mdt lookupConfigSoql { get; set; }
    private Incap311Console__Console311_Lookup_Config__mdt lookupConfigSosl { get; set; }
    private List<String> dateSObjectFields { get; set; }

    public Console311_LookupCtrl() {
      sObjectName = ApexPages.currentPage().getParameters().get('sobject');
      mCallbackFuncName = ApexPages.currentPage().getParameters().get('callback'); 
      mActiveQueryLangType = ApexPages.currentPage().getParameters().get('queryType') != null ? ApexPages.currentPage().getParameters().get('queryType') : 'sosl';
      queryResults = new List<SObject>();
      dateSObjectFields = new List<String>();
      mQueryResultJsonMapById = new Map<String, String>();
      fileNamesForObjectFormatted = new Map<String, Map<String, String>> ();
      sObjectFieldUtilMap = new Map<String, Map<String, Map<String, String>>> ();

      if (mActiveQueryLangType.equalsIgnoreCase(QUERY_TYPE_SOQL)) {
        lookupConfigSoql = [Select Incap311__Like_Conditional_Operator__c, Incap311__Like_Conditions__c, Incap311__Order_Conditions__c, Incap311__Query_Field_Labels__c, Incap311__Query_Fields__c, Incap311__sObject_Name__c, Incap311__Where_Conditions__c From Incap311__Lookup_Config__mdt Where Incap311__sObject_Name__c = :sObjectName];
      } else if (mActiveQueryLangType.equalsIgnoreCase(QUERY_TYPE_SOSL)) {
          System.debug(sObjectName);
        lookupConfigSosl = [Select Incap311Console__New_Record_Layout__c, Incap311Console__Search_Layout__c, Incap311Console__Search_Result_Layout__c From Incap311Console__Console311_Lookup_Config__mdt Where MasterLabel = :sObjectName];
      }
      
      System.debug('----> Lookup Config [SOQL]: ' + lookupConfigSoql);
      System.debug('----> Lookup Config [SOSL]: ' + lookupConfigSosl);
      // Create a formatted name list of the query fields to show on the page.
      if ((lookupConfigSoql != null && String.isNotBlank(lookupConfigSoql.Incap311__Query_Fields__c)) || (lookupConfigSosl != null && String.isNotBlank(lookupConfigSosl.Incap311Console__Search_Result_Layout__c))) {
        
        String fieldsTrimmed = '';

        if (mActiveQueryLangType.equalsIgnoreCase(QUERY_TYPE_SOQL)) {
          fieldsTrimmed = lookupConfigSoql.Incap311__Query_Fields__c.replaceAll( '\\s+', '');
        } else if (mActiveQueryLangType.equalsIgnoreCase(QUERY_TYPE_SOSL)) {
          fieldsTrimmed = lookupConfigSosl.Incap311Console__Search_Result_Layout__c.replaceAll( '\\s+', '');
        }

        
        fieldNamesForObject = fieldsTrimmed.split(',');

        // SOQL ONLY - Custom Labels
        List<String> fieldNameCustomLabels = new List<String>();
        if (mActiveQueryLangType.equalsIgnoreCase(QUERY_TYPE_SOQL)) {
          mOrderCondition = lookupConfigSoql.Incap311__Order_Conditions__c != '' ? lookupConfigSoql.Incap311__Order_Conditions__c : 'Relavence';
          fieldNameCustomLabels = (String.isNotBlank(lookupConfigSoql.Incap311__Query_Field_Labels__c) ? lookupConfigSoql.Incap311__Query_Field_Labels__c.split(',') : new List<String> ());
        }

        //String name : fieldNamesForObject
        for (Integer i = 0; i < fieldNamesForObject.size(); i++) {
          String name = fieldNamesForObject.get(i);
          String formattedDefaultName = name;

          formattedDefaultName = formattedDefaultName.replaceAll('_c', '');
          formattedDefaultName = formattedDefaultName.replaceAll('_', ' ');
          formattedDefaultName = formattedDefaultName.replaceAll('r\\.', '');

          if (name.containsIgnoreCase('Date')) {
            dateSObjectFields.add(name);
          }
          // SOQL ONLY - Custom Name Labels
          String customLabel = ((fieldNameCustomLabels.size() > 0 && i <= fieldNameCustomLabels.size() - 1) ? fieldNameCustomLabels.get(i) : 'null');
          fileNamesForObjectFormatted.put(
            name, 
            new Map<String, String> { 
              'Default' => formattedDefaultName, 
              'Custom' => customLabel 
            }
          );
        }
      }

      queryStr = ApexPages.currentPage().getParameters().get('query');

      if (String.isNotBlank(queryStr)) {
        this.query();
      }
    }

    public PageReference query() {
      errorMessage = '';
      queryResults = new List<SObject> ();

      if (String.isNotBlank(queryStr) && queryStr.length() > 1) {
        if (mActiveQueryLangType.equalsIgnoreCase(QUERY_TYPE_SOQL)) {
          querySoql();
            System.debug('!! SOQL');
        } else if (mActiveQueryLangType.equalsIgnoreCase(QUERY_TYPE_SOSL)) {
            System.debug('!! SOSL');
          querySosl();
        }
      } else {
        errorMessage = 'Search term must be greater than one character.';
      }
      return null;
    }

    public void querySosl() {
      Map<String,String> serviceMap = mObjToServiceMap.containsKey(sObjectName.toLowerCase()) ? mObjToServiceMap.get(sObjectName.toLowerCase()) : null;
 		System.debug('----> serviceMap: ' + serviceMap);
      if (serviceMap != null) {
        try {
        List<Object> params = new List<Object>();
        params.add(queryStr);
        params.add(fieldNamesForObject);
        if(serviceMap.get('method') == 'searchContactsandUsers'){
          params.add(fieldNamesForObject);
        }
        //params.add(fieldNamesForObject);
        queryResults = (List<sObject>) Incap311.Base311_Service_Wrapper.handleRemote(serviceMap.get('service'), serviceMap.get('method'), JSON.serialize(params));
        System.debug('----> queryResults: ' + queryResults);
        } catch (Exception e) {
          System.debug('----> Error retrieving results: ' + e.getMessage());
            throw e;

          if (String.isBlank(serviceMap.get('method'))) {
            errorMessage = 'Required service method not defined for this object type.';
          } else if (String.isBlank(serviceMap.get('service'))) {
            errorMessage = 'Service not defined for this object type.';   
          }
          return;
        }
      } else {
        queryResults = new List<sObject>();
      }

      if (queryResults == null || queryResults.size() == 0) {
        errorMessage = 'No results found.';
      } else {
        this.formatObjectResultData();
        this.generateObjectToJsonMap();
      }
    }

    public PageReference querySoql() {
      try {

        if (String.isBlank(queryStr)) {
          errorMessage = 'You cannot have an empty search. Please enter your query into the search text field.';
          return null;
        }

        String likeQueryCommand = '(';
        // Ensure that the like conditions and like conditional operator are present. 
        if (lookupConfigSoql != null && String.isNotBlank(lookupConfigSoql.Incap311__Like_Conditions__c) && String.isNotBlank(lookupConfigSoql.Incap311__Like_Conditional_Operator__c)) {
          List<String> likeFields = lookupConfigSoql.Incap311__Like_Conditions__c.split(',');
          // Loop through conditional and create a query command. 
          for (Integer i = 0; i < likeFields.size(); i++) {
            likeQueryCommand += likeFields[i] + ' Like \'%' + queryStr + '%\' ';
            // If we are not on the last entry then add the conditional operator.
            // TODO: Make this allow multiple types of operators rather than just one. 
            if ((i + 1) != likeFields.size()) {
              likeQueryCommand += lookupConfigSoql.Incap311__Like_Conditional_Operator__c + ' ';
            }
          }
        }
        // Begin building the query.
        String query = 'Select ' + (lookupConfigSoql != null && String.isNotBlank(lookupConfigSoql.Incap311__Query_Fields__c) ? (lookupConfigSoql.Incap311__Query_Fields__c) : '');
        query += ' From ' + sObjectName;
        query += ' Where ' + likeQueryCommand + ')';
        if (lookupConfigSoql != null && String.isNotBlank(lookupConfigSoql.Incap311__Where_Conditions__c)) {
          query += ' AND ' + lookupConfigSoql.Incap311__Where_Conditions__c;
        }
        query += (lookupConfigSoql != null && String.isNotBlank(lookupConfigSoql.Incap311__Order_Conditions__c) ? (' ORDER BY ' + lookupConfigSoql.Incap311__Order_Conditions__c) : '');
        query += ' LIMIT 10000';
        System.debug('----> Query: ' + query);
        queryResults = Database.query(query);
        
        if (queryResults.size() == 0) {
          errorMessage = 'No results found.';
        } else {
          this.formatObjectResultData();
        }
        this.generateObjectToJsonMap();
      } catch(Exception e) {
        System.debug('Error: ' + e.getMessage());
        errorMessage = 'An error has occured attempting to get your results. Please try again later.';
      }
      return null;
    }

    private void formatObjectResultData() {
      this.sObjectFieldUtilMap = Console311_Util.formatSobjectDataUtilMap(queryResults, sObjectName, String.join(fieldNamesForObject, ','));
    }

    private void generateObjectToJsonMap() {
        this.mQueryResultJsonMapById.clear();

        for (sObject obj : queryResults) {
            this.mQueryResultJsonMapById.put(obj.Id, JSON.serialize(obj));
        }
        System.debug('----> mQueryResultJsonMapById: ' + mQueryResultJsonMapById);
    }
}