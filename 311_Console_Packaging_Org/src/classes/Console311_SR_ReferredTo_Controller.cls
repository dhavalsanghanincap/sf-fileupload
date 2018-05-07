public class Console311_SR_ReferredTo_Controller {

  private final String RECORD_TYPE_DISTRIBUTION = 'Distribution List';
  private final Incap311.Base311_Service_DistributionList restServiceDist = new Incap311.Base311_Service_DistributionList();
  private final Incap311.Base311_Service_Request restServiceReq = new Incap311.Base311_Service_Request();

  public Case mActivityParentCase { get; set; }
  public List<Incap311__Distributions__c> mDistPicklists { get; set; }
  public Map<String, Incap311__Distributions__c> mDistPicklistByNameMap { get; set; }
  public String mDistPicklistSelected { get; set; }
  public String mActiveDistEmailList { get; set; }
  public String mUpdateText { get; set; }
  public Boolean mCaseEventCreated { get; set; }

  public Console311_SR_ReferredTo_Controller() {
    String cid = ApexPages.currentPage().getParameters().get('cid');
    this.mActivityParentCase = restServiceReq.getServiceRequest(cid);

    this.mDistPicklistByNameMap = new Map<String, Incap311__Distributions__c>();
  }

  public void feedParentInformationToPage() {
    try {
      System.debug('----> Feeding the parent information into the current case.'); 
      Case tempC = (Case) JSON.deserialize(ApexPages.currentPage().getParameters().get('parentJson'), Case.class);
      this.mActivityParentCase = restServiceReq.getServiceRequest(tempC.CaseNumber);
    } catch (Exception e) {
      System.debug('----> Error: ' + e.getMessage());
      this.mActivityParentCase = null;
    }
  }

  public List<SelectOption> getDistributionPicklist() {
    this.mDistPicklists = [
      SELECT
        Id, Name, Incap311__Name__c, RecordType.Name,
        (
          SELECT
            Id, Incap311__Distribution_Member__r.Incap311__Contact__r.Email, Incap311__Distribution_Member__r.Incap311__Contact__r.LastName
          FROM 
            Incap311__Distribution_Member_Zone_Type__r
        ) 
      FROM
        Incap311__Distributions__c
      WHERE
        RecordType.Name = :this.RECORD_TYPE_DISTRIBUTION
      ORDER BY
        Name DESC
    ];

    List<SelectOption> tSelectDistList = new List<SelectOption>();
    tSelectDistList.add(new SelectOption('', 'Select an Option'));

    for (Incap311__Distributions__c sq : this.mDistPicklists) {
      tSelectDistList.add(new SelectOption(sq.Id, sq.Incap311__Name__c));
      mDistPicklistByNameMap.put(sq.Id, sq);
    }
    return tSelectDistList;
  }

  public void retrieveDistrubutionEmailList() {
    List<Contact> distContactList = new List<Contact>();
    this.mActiveDistEmailList = '';
    
    if (String.isNotBlank(this.mDistPicklistSelected)) {
      Incap311__Distributions__c sq = mDistPicklistByNameMap.get(this.mDistPicklistSelected);
      
      if (sq.Incap311__Distribution_Member_Zone_Type__r != null && sq.Incap311__Distribution_Member_Zone_Type__r.size() > 0) {
        for(Incap311__Distribution_Member_Zone_Type__c sqm : sq.Incap311__Distribution_Member_Zone_Type__r) {
          distContactList.add(sqm.Incap311__Distribution_Member__r.Incap311__Contact__r);
        }
      }
      this.mActiveDistEmailList = restServiceDist.stringifyContactDistributionList(distContactList);
    }
  }

  public void SaveEvent() {
    Id recordTypeId = Schema.SObjectType.Incap311__Case_Event__c.getRecordTypeInfosByName().get('Distribution').getRecordTypeId();
    Incap311__Case_Event__c ce = new Incap311__Case_Event__c(
      Incap311__Event_Type__c = 'Update',
      Incap311__Distribution_List__c = this.mActiveDistEmailList,
      Incap311__Service_Request__c = this.mActivityParentCase.Id,
      Incap311__Rich_Email_Body__c = this.mUpdateText,
      RecordTypeId = recordTypeId
    ); 
    insert ce;

    this.mCaseEventCreated = true;
  }
}