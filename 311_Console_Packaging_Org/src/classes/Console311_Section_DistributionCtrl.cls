public with sharing class Console311_Section_DistributionCtrl {

  private final String RECORD_TYPE_DISTRIBUTION = 'Distribution List';
  private final Incap311.Base311_Service_ServiceType restServiceService = new Incap311.Base311_Service_ServiceType();
  private final Incap311.Base311_Service_DistributionList restServiceDist = new Incap311.Base311_Service_DistributionList();

  public String mSrTypeCode { get; set; }
  public Incap311__Service_Type_Version__c mStv { get; set; }
  public List<Incap311__Distribution_Member_Zone_Type__c> mDistPicklists { get; set; }
  public Map<String, Incap311__Distribution_Member_Zone_Type__c > mDistPicklistByNameMap { get; set; }
  public List<Console311_Wrap_LayerInformation> mMatchingInfoList { get; set; }
  public String mActiveDistEmailList { get; set; }
  public String mCoordinatorEmailList { get; set; }
  public String mDistPicklistSelected { get; set; }

  public Console311_Section_DistributionCtrl() {
    this.mStv = null;
    if (String.isNotBlank(this.mSrTypeCode)) {
      // Verify if the type is a bulk service type and process if so.
      this.mStv = (this.restServiceService.getServiceType(this.mSrTypeCode, true));
    }
    this.mDistPicklistByNameMap = new Map<String, Incap311__Distribution_Member_Zone_Type__c >(); 
    this.mDistPicklists = new List<Incap311__Distribution_Member_Zone_Type__c>();    
  }

  public String getDistDescription() {
    String descriptionStr = '';
    System.debug('----> Attempting to find description...');
    if (String.isNotBlank(this.mDistPicklistSelected)) {
      List<Incap311__Distributions__c> activeDistList = [Select Id, Incap311__Description__c From Incap311__Distributions__c Where Incap311__Name__c = :this.mDistPicklistSelected];
      descriptionStr = activeDistList.size() > 0 ? activeDistList.get(0).Incap311__Description__c : '';
    }
    return descriptionStr;
  }

  public List<SelectOption> getDistributionPicklist() {
    List<Incap311__Distributions__c> defaultDistPicklists = new List<Incap311__Distributions__c>();
    this.mDistPicklistByNameMap = new Map<String, Incap311__Distribution_Member_Zone_Type__c >(); 
    this.mDistPicklists = new List<Incap311__Distribution_Member_Zone_Type__c>();

    if (String.isNotBlank(this.mSrTypeCode)) {
      // Verify if the type is a bulk service type and process if so.
      this.mStv = (this.restServiceService.getServiceType(this.mSrTypeCode, true));
    }
    this.mDistPicklists = restServiceDist.getDistributionListByServiceType(this.mStv, this.RECORD_TYPE_DISTRIBUTION);

    List<SelectOption> tSelectDistList = new List<SelectOption>();
    System.debug('----> mStv: ' + mStv);
    System.debug('----> this.mDistPicklists: ' + this.mDistPicklists);
    for (Incap311__Distribution_Member_Zone_Type__c  sqz : this.mDistPicklists) {
      System.debug('----> sqz.Incap311__Distribution__r.Incap311__Name__c: ' + sqz.Incap311__Distribution__r.Incap311__Name__c);
      System.debug('----> Map Does NOT Contain Key: ' + mDistPicklistByNameMap.containsKey(sqz.Incap311__Distribution__r.Incap311__Name__c));
      if (!mDistPicklistByNameMap.containsKey(sqz.Incap311__Distribution__r.Incap311__Name__c)) {
        System.debug('----> Adding dist to mapping...');
        tSelectDistList.add(new SelectOption(sqz.Incap311__Distribution__r.Incap311__Name__c, sqz.Incap311__Distribution__r.Incap311__Name__c));
        mDistPicklistByNameMap.put(sqz.Incap311__Distribution__r.Incap311__Name__c, sqz);
      }
    }
    System.debug('----> tSelectDistList: ' + tSelectDistList);
    return tSelectDistList;
  }
}