/**
* @Author DhavalS
* @Date 06/23/2017
*
* @Description Apex Custom controller class for querying all the 
* necessary fields from objects that are related to Case object
* to display case records in a report(PDF Report is generated from VF Page).
*/

public with sharing class SRReportController 
{
  public Map<Id, Map<String, String>> caseDatetimes { get; set; }
  public Map<Id, List<Incap311__Service_Question__c>> caseQA { get; set; }
  public List<Case> lstCase { get; set; }
  public String currentDatetime { get; set; }
  public List<Incap311__Service_Question__c> lstQA;
  
  /**
    * @description Get case and related Question/Answer details
    * @return
    **/
  public SRReportController()
    {
        //Fetch comma separated caseIds from HTTP GET Param
        String cases  =  ApexPages.currentPage().getParameters().get('selectedId'); 
        
        //Create a set of case Ids
       Set<Id> SR  =  new Set<Id>();
       
        List<Id> lstCaseIds  =  cases.split(',');
        SR.addAll(lstCaseIds);
      
    if(SR.size()>0)
    {
      //First fetch case details
      Map<Id,case> caseMap = new Map<Id,case>([Select  Id,
                           Origin,
                           Description,
                           Incap311__Service_Request_Number__c,
                           Incap311__Service_Type_Version__r.Incap311__Service_Name__c,
                           Status,
                           CreatedDate,
                           CreatedBy.Name,
                           Contact.MailingStreet,
                           Contact.MailingCity,
                           Contact.MailingState,
                           Contact.MailingCountry,
                           Contact.MailingPostalCode,
                           Contact.Name,
                           Contact.Email,
                           Contact.Phone,
                           Incap311__Address__c,
                           Priority,
                           LastModifiedDate,
                           Incap311__Expected_Date_Time__c From Case Where Id in:SR]); 
         
           //Create a map for case address and timestamp fields
          caseDatetimes = new Map<Id, Map<String, String>>();
      for(Case curCase:caseMap.values())
      {
              String address = '';
              
          //Appending address fields to a single variable.
              if (curCase.Contact.MailingStreet != null) {
                address += curCase.Contact.MailingStreet;
              }
      
              if (curCase.Contact.MailingCity != null) {
                address += (address != null ? ', ' : '') + curCase.Contact.MailingCity;
              }
      
              if (curCase.Contact.MailingState != null) {
                address += (address != null ? ', ' : '') + curCase.Contact.MailingState;
              }
      
              if (curCase.Contact.MailingPostalCode != null) {
                address += (address != null ? ', ' : '') + curCase.Contact.MailingPostalCode;
              }
              
              //System.debug('Address:' +address);
              
              caseDatetimes.put(curCase.Id, new Map<String, String> {
                                            'Status_Date' => CommonUtil.getTimeZoneValue(curCase.LastModifiedDate),
                                              'Created_Date' => CommonUtil.getTimeZoneValue(curCase.CreatedDate),
                                              'Overdue_On' => CommonUtil.getTimeZoneValue(curCase.Incap311__Expected_Date_Time__c),
                                              'Mailing_Address' => address
                                              });
      
      }
      
      //Create a map to store case wise question/answers
      lstQA  =  new List<Incap311__Service_Question__c>();
      lstQA  =  [Select Id, Name, Incap311__Service_Request__c, 
                            Incap311__Answer__c, Incap311__Question__c 
                            From Incap311__Service_Question__c Where Incap311__Service_Request__c IN:SR];
            
            caseQA     =  new Map<Id, List<Incap311__Service_Question__c>>();     
            
            for(Incap311__Service_Question__c QA:lstQA)
            {
              if(caseQA.containsKey(QA.Incap311__Service_Request__c))
                {
                    caseQA.get(QA.Incap311__Service_Request__c).add(QA);
                }
                else
                {
                    List<Incap311__Service_Question__c> lstCaseQA  =  new List<Incap311__Service_Question__c>();  
                    lstCaseQA.add(QA);
                    caseQA.put(QA.Incap311__Service_Request__c,lstCaseQA);
                }
              
            }
            
      lstCase  =  new List<Case>();
      lstCase  =  caseMap.values();
      
      currentDatetime  =  CommonUtil.getCurrentDatetime();
    }
    }
    
}