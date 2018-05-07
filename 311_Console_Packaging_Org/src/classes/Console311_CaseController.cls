/**
*  Console311_CaseController
*  @description This controller handles all functionality related to the Case Console page.
*  @author Darkis
*  @created 04/10/2016
*/
global with sharing class Console311_CaseController extends Console311_ControllerBase {
    
    private final String ACTIVITY_TYPE_NEW = 'new';
    public final String ACTIVITY_TYPE_TRANSFER = 'transfer';
    public final String ACTIVITY_TYPE_EDIT = 'edit';
    
    private final String LEVEL_ACTIVITY = 'outcome';
    
    public String SST_SHORT_CODE_EMERGENCY { get { return 'Emergency'; } }
    public String SST_SHORT_CODE_GENERIC { get { return 'Generic'; } }
    
    private final Incap311.Base311_Service_ServiceType restServiceService = new Incap311.Base311_Service_ServiceType();
    public final Incap311.Base311_Service_Request restServiceRequest = new Incap311.Base311_Service_Request();
    private final Incap311.Base311_Service_Contact restServiceContact = new Incap311.Base311_Service_Contact();
    private final Incap311.Base311_Service_SpecialServiceType restServiceSpecialServiceType = new Incap311.Base311_Service_SpecialServiceType();
    private final Incap311.Base311_Service_DistributionList restServiceDistribution = new Incap311.Base311_Service_DistributionList();
    private final Incap311.Base311_Service_Bulk restServiceBulk = new Incap311.Base311_Service_Bulk();
    private final Incap311.Base311_Dependencies restDependancies = new Incap311.Base311_Dependencies();
    private final Incapsulate_Log.Log logger = new Incapsulate_Log.Log();
    
    private Map<String, Incap311__Service_Type_Version__c> mServiceTypesMapByName { get; set; }
    
    public Console311_Page_Layout pageLayout { get; set; }
    
    public List<Incap311Console__Console_311_Layout_Setting__mdt> mConsoleLayoutConfig { get; set; }
    
    // Bulk Collection variables.
    public Integer mBulkItemCount {get; set; }
    private final Integer mMaxBulkItemCount = 60;
    
    // Error Codes
    public String ERROR_TYPE_UNAVAILABLE { get { return 'E01'; } }
    
    
    public Case mOrgTransferCase { get; set; }
    public String mOrgTransferCaseNum { get; set; }
    public String mAction { get; set; }
    public String mLevel { get; set; }
    public String mActParentCaseNum { get; set; }
    public String mErrorCodeActive { get; set; }
    public String mSTId { get; set; }
    public Boolean mSaveEnabled { get; set; }
    public Incap311.Base311_Location mSubLocation { get; set; }
    public Map<Incap311.DISTRIBUTION_LIST_TYPE, List<Contact>> mDistMap { get; set; }
    public String mSelectedDistribution { get; set; }
    
    public Console311_CaseController ctrl { get { return this; } }
    public String mActiveServiceType { 
        get;
        set { 
            System.debug('setting active service type, old value : ' + mActiveServiceType);
            mActiveServiceType = value;
            System.debug('setting active service type, new value : ' + mActiveServiceType);
        }
        
    }
    public String mCaseJson { get; set; }
    public Incap311.Base311_Location mLocation { get; set; }
    public Case mSavedCase { get; set; }
    public String mErrorMsg { get; set; }
    public String mScheduleErrorMsg { get; set; }
    public String mTypeActiveStatus { get; set; }
    public String mActiveOrigin { get; set; }
    public Incap311__Service_Type_Version__c mGenericSRType { get; set; }
    public List<Incap311__Special_Service_Type__mdt> mSpecialServiceTypeList { get; set; }
    public Set<String> mSpecialServiceTypeCodeMap { get; set; }
    public String mDistributionListStr { get; set; }
    public String mCordinatorListStr { get; set; }
    public Incap311__Schedule__c nextAvailableSchedule { get; set; }  
    public List<Incap311__Schedule__c> scheduleToPresentList { get; set; }
    public List<Incap311__Service_Type_Version__c> recommendations { get; set; }
    public Map<String, Console311_Wrap_LayerInformation> mLayerInfoMap { get; set; }
    public String mSstActiveParam { get; set; }
    public String mDistNameVsAccountName { get; set; }
    public Boolean mIsSaving { get; set; }
    
    public Map<String, Object> mAnswerMap { get; set; }  
    
    public Map<String, Incap311.Base311_Location_Basemap> basemapLayers {
        get {
            return Incap311.Base311_LocationSearch.getCustomBasemaps();
        }
    }
    
    public Map<String, String> mapLayers {
        get {
            List<String> layers = Incap311.Base311_LocationSearch.getArcGISLayers();
            
            if(layers.size() > 0) {
                return new Map<String, String>{
                    'Dynamic Layers' => layers[0]
                        };
                            }
            
            return new Map<String, String>{ };
                }
    }
    
    public Integer mapZoom {
        get {
            return mLocation == null ? Incap311.Base311_LocationSearch.getMapZoom() : Incap311.Base311_LocationSearch.getSelectedMapZoom();
        }
    }
    
    public Double mapCenterLongitude {
        get {
            return mLocation != null && mLocation.lng != null ? mLocation.lng : Incap311.Base311_LocationSearch.getMapCenterCoordinates().longitude;
        }
    }
    
    public Double mapCenterLatitude {
        get {
            return mLocation != null && mLocation.lat != null ? mLocation.lat :  Incap311.Base311_LocationSearch.getMapCenterCoordinates().latitude;
        }
    }
    
    
    public Incap311.Base311_Service_CaseEvents sce = new Incap311.Base311_Service_CaseEvents();
    
    // Flexnote Portions.
    public Incap311__Service_Type_Version__c mActiveTypeVersion { get; set; }
    public List<Console311_Wrap_FlexnoteQuestionAnswer> mFNQuestionAnswerList { get; set; }
    public List<Console311_Wrap_FlexnoteQuestionAnswer> mFNQuestionAnswerListBackup { get; set; }
    
    // TODO: Decouple these from the page controller into the respective component Ctrls. 
    public String mKnowledgeKeyword { get; set; }
    public Contact mContactToPass { get; set; }
    public Account mAccountToPass { get; set; }  
    
    public Case getInprogressCase() {
        Incap311.Base311_Location activeLocation = getActiveLocation();
        Boolean locationDefined = activeLocation != null;
        
        
        Case inprogress = new Case(
            Incap311__Location__Latitude__s = !locationDefined ? null : activeLocation.lat,
            Incap311__Location__Longitude__s = !locationDefined ? null : activeLocation.lng,
            Incap311__Address__c = !locationDefined ? null : activeLocation.address,
            Incap311__ZipCode__c = !locationDefined ? null: activeLocation.zipCode,
            Incap311__Neighborhood__c = !locationDefined ? null: activeLocation.neighbourhood,
            ContactId = mContactToPass != null ? mContactToPass.Id : null
        );
        
        inprogress.putSObject('Incap311__Service_Type_Version__r', mActiveTypeVersion);
        
        return inprogress;
    }
    
    public List<Incap311.Base311_ESRI_Layer> getCaseLayers() {
        if(mLocation == null) {
            return null;
        }
        
        if (this.mLocation.layers != null) {
            return this.mLocation.layers;
        }
        
        return mLocation.addLayerInformation().layers;
    }
    
    public Console311_CaseController getThis() {
        return this;
    }
    
    public Incap311__Special_Service_Type__mdt getCurrentCaseSST() {
        System.debug('----> [getCurrentCaseSST] mSavedCase: ' + this.mSavedCase);
        if(mSavedCase != null) {
            for(Incap311__Special_Service_Type__mdt sst : this.mSpecialServiceTypeList) {
                if(sst.Incap311__Related_Service_Type_Code__c == mSavedCase.Incap311__Service_Type_Version__r.Incap311__Service_Type_Code__c) {
                    
                    return sst;
                }
            }
        }
        return null;
    }  
    
    public Console311_Section_ContactCtrl conCtrl { set; get {
        if (getComponentControllerMap() != null) {
            Console311_Section_ContactCtrl conCtrl = (Console311_Section_ContactCtrl) getComponentControllerMap().get('contact');
            
            if (conCtrl != null) {
                return conCtrl;
            }
        }
        return new Console311_Section_ContactCtrl();
    }}
    
    // Bulk Schedule Id for any future verification of Bulk Schedule type.
    public String bulkscheduleTypeId { get; set; }
    public Incap311__Case_Event__c mLatestCaseEvent { get; set; }
    
    public void init() {
        String caseNum = ApexPages.currentPage().getParameters().get('cid');
        String action = ApexPages.currentPage().getParameters().get('activity');
        getpageLayout();
        
        if (String.isNotBlank(caseNum) && String.isNotBlank(action)) {
            Case c = restServiceRequest.getServiceRequest(caseNum);
            if(this.mAction == ACTIVITY_TYPE_EDIT) {
                System.debug('----> INIT: mSavedCase.Parent.Incap311__Service_Request_Number__c [Edit]: ' + this.mSavedCase.Parent.Incap311__Service_Request_Number__c);
                this.mActParentCaseNum = c.Parent.Incap311__Service_Request_Number__c;
            }
        }
    }
    public Console311_CaseController() {
        System.debug('New instance');
        instantiate();
    }
    public void instantiate(){
        this.mSaveEnabled = true;
        this.mIsSaving = false;
        //this.mServiceTypesMapByName = new Map<String, Incap311__Service_Type_Version__c>();
        this.mFNQuestionAnswerList = new List<Console311_Wrap_FlexnoteQuestionAnswer>();
        this.mFNQuestionAnswerListBackup = new List<Console311_Wrap_FlexnoteQuestionAnswer>();
        
        // Get the bulk collection id for comparriosn later to ensure if current type is BC.
        List<Incap311__Service_Type_Version__c> tempSRT = [Select Id, Name, Incap311__Service_Name__c From Incap311__Service_Type_Version__c Where Incap311__Service_Name__c = 'Residential Bulk Collection' Limit 1];
        
        if (tempSrt != null && tempSrt.size() > 0) {
            bulkScheduleTypeId = tempSrt.get(0).Id;
        }
        // Check for an exisiting case and type of activity.
        this.mOrgTransferCaseNum = ApexPages.currentPage().getParameters().get('cid');
        this.mAction = ApexPages.currentPage().getParameters().get('activity');
        this.mLevel = ApexPages.currentPage().getParameters().get('level');
        this.mActParentCaseNum = ApexPages.currentPage().getParameters().get('pid');
        this.mSstActiveParam = ApexPages.currentPage().getParameters().get('sstype');
        this.mBulkItemCount = 0;
        
        this.mConsoleLayoutConfig = [Select QualifiedApiName, Incap311Console__Visible__c, Incap311Console__Header__c, Incap311Console__Collapsible__c, Incap311Console__Title__c, MasterLabel, DeveloperName From Incap311Console__Console_311_Layout_Setting__mdt];
        
        // Special Service Types 
        this.mSpecialServiceTypeList = this.restServiceSpecialServiceType.getSpecialServiceTypes();
        System.debug('----> this.mSpecialServiceTypeList: ' + this.mSpecialServiceTypeList);
        
        this.mSpecialServiceTypeCodeMap = new Set<String>();
        for (Incap311__Special_Service_Type__mdt ssType : this.mSpecialServiceTypeList) {
            this.mSpecialServiceTypeCodeMap.add(ssType.Incap311__Related_Service_Type_Code__c);
        }
        
        if (String.isNotBlank(this.mSstActiveParam)) {
            System.debug('----> SST Present. Finding current SST...');
            Incap311__Special_Service_Type__mdt currentSst;
            for (Incap311__Special_Service_Type__mdt sst : this.mSpecialServiceTypeList) {
                if (this.mSstActiveParam.equalsIgnoreCase(sst.MasterLabel)) {
                    System.debug('----> Found SST: ' + sst);
                    currentSst = sst;
                    break;
                }
            }
            
            if (currentSst != null) {
                this.mGenericSRType = this.restServiceSpecialServiceType.getSpecialServiceTypeRelatedTypeVersion(currentSst.Incap311__Related_Service_Type_Code__c);
                System.debug('---> Special SRType: '  + this.mGenericSRType);
            }
        }
        
        // Set the active service type if available.
        if (String.isNotBlank(ApexPages.currentPage().getParameters().get('stid')) || this.mGenericSRType != null) {
            System.debug('----> Service Type Code Param Detected. Processing...');
            
            if (ApexPages.currentPage().getParameters().get('scode') != null) {
                this.mActiveServiceType = ApexPages.currentPage().getParameters().get('stid');
            } else if (this.mGenericSRType != null) { 
                this.mActiveServiceType = this.mGenericSRType.Name;
            }
            this.setServiceType();
            System.debug('----> Service Type Code has been set.');
        }
        
        if (String.isNotBlank(ApexPages.currentPage().getParameters().get('scode'))) {
            System.debug('----> Service Type Code Param Detected. Processing...');
            String serviceTypeCode = ApexPages.currentPage().getParameters().get('scode');
            
            List<Incap311__Service_Type_Version__c> tempStvList = [
                SELECT
                Name
                FROM
                Incap311__Service_Type_Version__c
                WHERE
                Incap311__Service_Type_Code__c = :serviceTypeCode
            ];
            
            if (tempStvList.size() > 0) {
                this.mActiveServiceType = tempStvList.get(0).Name;
                this.setServiceType();
            }
            System.debug('----> Service Type Code has been set.'); 
        }
        
        String contactIdParam = ApexPages.currentPage().getParameters().get('conid');
        
        System.debug('----> Case Num: ' + this.mOrgTransferCaseNum);
        System.debug('----> mAction: ' + this.mAction);
        
        if (String.isNotBlank(this.mOrgTransferCaseNum) && String.isNotBlank(this.mAction)) {
            // Save the original for use in the save.
            this.mOrgTransferCase = restServiceRequest.getServiceRequest(this.mOrgTransferCaseNum);
            System.debug('----> mOrgTransferCase: ' + mOrgTransferCase);
            // Make a copy for display purposes. 
            this.mSavedCase = this.mOrgTransferCase;
            
            if (this.mOrgTransferCase != null) {
                // Set the location object. 
                this.mLocation = new Incap311.Base311_Location(
                    (mOrgTransferCase.Incap311__Location__Latitude__s != null ? Double.valueOf(mOrgTransferCase.Incap311__Location__Latitude__s) : null), 
                    (mOrgTransferCase.Incap311__Location__Longitude__s != null ? Double.valueOf(mOrgTransferCase.Incap311__Location__Longitude__s) : null), 
                    null,
                    mOrgTransferCase.Incap311__Address__c, 
                    mOrgTransferCase.Incap311__Zipcode__c, 
                    (mOrgTransferCase.Incap311__XCoordinate__c != null ? Double.valueOf(mOrgTransferCase.Incap311__XCoordinate__c) : null), 
                    (mOrgTransferCase.Incap311__YCoordinate__c != null ? Double.valueOf(mOrgTransferCase.Incap311__YCoordinate__c) : null),
                    mOrgTransferCase.Incap311__Neighborhood__c,
                    null, null, null, null, null 
                );
            }
            
            System.debug('Found Case --> ' + this.mSavedCase);
            
            if (this.mOrgTransferCase.ContactId != null) {
                this.mContactToPass = conCtrl.feedContactInformationToPage(this.mOrgTransferCase.ContactId);
            }
            
            this.mTypeActiveStatus = this.mSavedCase.Status;
            this.mActiveOrigin = this.mSavedCase.Origin;
            
            if(this.mAction == ACTIVITY_TYPE_EDIT) {
                System.debug('----> [Edit Mode] mSavedCase.Parent.Incap311__Service_Request_Number__c [Edit]: ' + this.mSavedCase.Parent.Incap311__Service_Request_Number__c);
                this.mActiveServiceType = this.mSavedCase.Incap311__Service_Type_Version__r.Name;
                this.mActParentCaseNum = this.mSavedCase.Parent.Incap311__Service_Request_Number__c;
                System.debug('----> [Edit Mode][Set Service Type] Start');
                this.setServiceType();
                System.debug('----> [Edit Mode][Get Activity Parent Case] Start');
                this.getActivityParentCase();
                
                System.debug('----> [Edit Mode][Case Event] Fetch');
                // Grab the most recent Case Event and set the distribution list. 
                List<Incap311__Case_Event__c> ceList = [
                    Select 
                    Id, 
                    Incap311__Distribution__c,
                    Incap311__Distribution__r.Incap311__Name__c,
                    Incap311__Distribution__r.Incap311__Description__c,
                    Incap311__Distribution_List__c, 
                    Incap311__Event_Type__c,
                    (
                        Select 
                        Incap311__Case_Recipient__r.Id,
                        Incap311__Case_Recipient__r.Incap311__Email__c,
                        Incap311__Case_Recipient__r.Incap311__Case__c,
                        Incap311__Case_Recipient__r.Incap311__Contact__c,
                        Incap311__Case_Recipient__r.Incap311__Is_Member__c
                        From 
                        Incap311__Case_Event_Recipients__r
                    ) 
                    From 
                    Incap311__Case_Event__c 
                    Where 
                    RecordType.Name = 'Distribution' AND
                    Incap311__Service_Request__c = :this.mSavedCase.Id
                    Order By 
                    CreatedDate DESC
                    Limit 1
                ];
                // TODO: Check on this portion: Incap311__Event_Type__c = 'Update'
                System.debug('----> [Edit Mode][Case Event] CE List: ' + ceList);
                if (ceList != null && ceList.size() > 0) {
                    this.mLatestCaseEvent = ceList.get(0);
                    // TODO: Should we split this into an array and compare against the recipients to find who is a coordinator?
                    System.debug('----> [Edit Mode][Case Event] CE Dist List: ' + ceList.get(0).Incap311__Distribution_List__c);
                    System.debug('----> [Edit Mode][Case Event] Dist Name: ' + ceList.get(0).Incap311__Distribution__r.Incap311__Name__c);
                    this.mDistNameVsAccountName = ceList.get(0).Incap311__Distribution__r.Incap311__Name__c;
                    this.mSelectedDistribution = ceList.get(0).Incap311__Distribution__r.Incap311__Name__c;
                    this.mDistributionListStr = ceList.get(0).Incap311__Distribution_List__c;
                }
            }
        }
        
        if (String.isNotBlank(contactIdParam)) {
            this.mContactToPass = conCtrl.feedContactInformationToPage(contactIdParam);
        }
    }
    
    public List<Double> getMapCoords() {
        System.debug('----> Processing Map Coordinates...');
        if (this.mLocation != null) {
            System.debug('----> Map: Successful');
            return new List<Double> { this.mLocation.lat, this.mLocation.lng};
                }
        System.debug('----> Map: Failure');
        return null;
    }
    
    public Console311_Page_Layout getpageLayout(){
        if(pageLayout == null){
            pageLayout = (Console311_Page_Layout)incap311.Base311_Cache.get('311AgentConsolePageLayout');
            if(pageLayout == null){
                pageLayout = new Console311_Page_Layout('311 Agent Console');
                incap311.Base311_Cache.put('311AgentConsolePageLayout',pageLayout);
             }
        }
        return pageLayout;
    }
    
    public String getPageTitle() {
        if (this.ACTIVITY_TYPE_TRANSFER.equalsIgnoreCase(this.mAction)) {
            return this.ACTIVITY_TYPE_TRANSFER;
        } else if (this.ACTIVITY_TYPE_NEW.equalsIgnoreCase(this.mAction)) {
            return 'Creation';
        } else if (this.ACTIVITY_TYPE_EDIT.equalsIgnoreCase(this.mAction) ) {
            return this.ACTIVITY_TYPE_EDIT;
        }
        return 'Creation';
    }
    
    public void refreshPanel() {
        
    }
    
    public void setActiveServiceType() {
        String typeStr = ApexPages.currentPage().getParameters().get('activeServiceType');
        
        if (String.isNotBlank(typeStr)) {
            this.mActiveServiceType = typeStr;
        } else {
            this.mErrorMsg = 'Service type selection unsuccessful. Please try again.';
        }
    }
    
    
    public void clearAndSetServiceType() {
        clearServiceType();
        setServiceType();
    }
    
    public void setServiceType() {
        String typeStr = ApexPages.currentPage().getParameters().get('activeServiceType');
        this.mActiveServiceType = String.isNotBlank(typeStr) ? typeStr : this.mActiveServiceType;
        this.recommendations = null;
        this.mSaveEnabled = true;
        this.mKnowledgeKeyword = this.mActiveTypeVersion.Incap311__Keywords__c;
        
        System.debug('---> activeServiceType set to : ' + this.mActiveServiceType);
        
        if (String.isNotBlank(this.mActiveServiceType)) {
            if(this.mAction == ACTIVITY_TYPE_EDIT) {
                setSericeCodeWithAnswers(this.mActiveServiceType, this.mSavedCase);
                this.mLocation = new Incap311.Base311_Location(
                    Double.valueOf(this.mSavedCase.Incap311__Location__Latitude__s), 
                    Double.valueOf(this.mSavedCase.Incap311__Location__Longitude__s),
                    this.mSavedCase.Incap311__Address_Id__c,
                    this.mSavedCase.Incap311__Address__c
                );
                
                this.mLocation.zipcode = this.mSavedCase.Incap311__Zipcode__c;
                this.mLocation.neighbourhood = this.mSavedCase.Incap311__Neighborhood__c;
                this.mActParentCaseNum = this.mSavedCase.ParentId;
                //mServiceTypesMapByName.put(this.mActiveServiceType, this.mActiveTypeVersion);
            } else {
                retrieveActiveServiceTypeWithFlexNotes(this.mActiveServiceType);
                this.mKnowledgeKeyword = this.mActiveTypeVersion.Incap311__Keywords__c;
                
                //if (!mServiceTypesMapByName.containsKey(this.mActiveServiceType)) {
                //mServiceTypesMapByName.put(this.mActiveServiceType, this.mActiveTypeVersion);
                //}
            }
            
            this.mTypeActiveStatus = (this.ACTIVITY_TYPE_EDIT.equalsIgnoreCase(this.mAction) || this.ACTIVITY_TYPE_TRANSFER.equalsIgnoreCase(this.mAction) ? this.mSavedCase.Status : this.mActiveTypeVersion.Incap311__Default_Status__c);
            this.mActiveOrigin = (this.ACTIVITY_TYPE_EDIT.equalsIgnoreCase(this.mAction) || this.ACTIVITY_TYPE_TRANSFER.equalsIgnoreCase(this.mAction) ? this.mSavedCase.Origin : this.mActiveTypeVersion.Incap311__Default_Method__c);
            System.debug('----> this.mTypeActiveStatus: ' + this.mTypeActiveStatus);
        } else {
            this.mErrorMsg = 'Unable to detect service type selection. Please try again.';
        }
    }
    
    public void refreshFlexnotesWithAnswers() {
        System.debug('----> refreshFlexnotesWithAnswers => Begin');
        this.mErrorCodeActive = '';
        this.recommendations = new List<Incap311__Service_Type_Version__c>();
        
        String wrapperJson = ApexPages.currentPage().getParameters().get('flexnoteAnswersJson');
        System.debug('----> refreshFlexnotesWithAnswers: wrapperJson => ' + wrapperJson);
        
        if (String.isNotBlank(wrapperJson)) {
            ServiceRequestWrapper srWrapper = new ServiceRequestWrapper();
            
            try {
                srWrapper = (ServiceRequestWrapper) JSON.deserialize(wrapperJson, ServiceRequestWrapper.class);
            } catch (Exception e) {
                System.debug('----> Error occured while parsing sent JSON for Flexnote refresh: ' + e.getMessage());
                mErrorMsg = 'Unable to refresh flexnotes.';
            }
            
            if (srWrapper.isValid()) {
                try {
                    Map<String, Object> flexnoteSaveMapping = this.convertFlexnoteAnswersToMap(srWrapper.serviceQuestions, false);
                    
                    mAnswerMap = flexnoteSaveMapping;
                    
                    System.debug('----> refreshFlexnotesWithAnswers: mActiveServiceType => ' + this.mActiveServiceType);
                    System.debug('----> refreshFlexnotesWithAnswers: mActiveTypeVersion => ' + this.mActiveTypeVersion);
                    
                    if (String.isNotBlank(this.mActiveServiceType)) {
                        System.debug('----> refreshFlexnotesWithAnswers: refreshFlexnotesWithUpdates => Called');
                        this.recommendations = Incap311.Base311_Dependencies.getServiceTypeSuggestions(this.mActiveTypeVersion, flexnoteSaveMapping );  
                        refreshFlexnotesWithUpdates(this.mActiveServiceType, flexnoteSaveMapping);
                    } else {
                        this.mErrorCodeActive = this.ERROR_TYPE_UNAVAILABLE;
                    }
                } catch(Exception e){ 
                    System.debug('----> Unable to convert flexnotes into save mapping.'+e);
                    //mErrorMsg = '----> Unable to convert flexnotes into save mapping.'+e.getMessage();
                }
            }
        }
        System.debug('----> refreshFlexnotesWithAnswers => End');
    }
    
    public Boolean getDuplicatesAvailable() {
        System.debug('----> Attempting to detect duplicates for ['+this.mActiveServiceType+']');
        System.debug('----> mLocation: ' + mLocation);
        List<Case> mDuplicateServiceRequests = new List<Case>();
        
        if(!String.isEmpty(this.mAction) && this.mAction.equalsIgnoreCase(ACTIVITY_TYPE_EDIT)) {
            return false;
        }
        
        if (String.isNotBlank(mActiveServiceType) && mLocation != null) {
            //System.debug('----> Type found, checking location at [Sname: ' + this.mServiceTypesMapByName.get(mActiveServiceType) + ', Lat: '+this.mLocation.lat+', Lng: '+this.mLocation.lng+']');      
            mDuplicateServiceRequests = getDuplicateRequests();
            System.debug('----> dupes: ' + mDuplicateServiceRequests);
            return mDuplicateServiceRequests.size() > 0;
        }
        return false;
    }
    
    public List<Case> getDuplicateRequests() {
        
        if(!String.isEmpty(this.mAction) && this.mAction.equalsIgnoreCase(ACTIVITY_TYPE_EDIT)) {
            return new List<Case>();
        }
        
        if(this.mLocation == null) {
            return new List<Case>();
        }  
        
        List<Case> mDuplicateServiceRequests = new List<Case>();
        System.debug('----> [getDuplicateRequests] Retrieveing duoplicates to present...');
        Incap311__Service_Type_Version__c serviceType = getServiceTypeVersionFromMappingUsingName();
        
        if(serviceType != null && this.mLocation != null && this.mLocation.lat != null && this.mLocation.lng != null) {
            System.debug('----> [getDuplicateRequests] mLocation: ' + mLocation);
            mDuplicateServiceRequests = Incap311.Base311_DuplicateRequestsUtil.getDuplicateServiceRequests(null, serviceType, String.valueOf(this.mLocation.lng), String.valueOf(this.mLocation.lat));
        }
        System.debug('----> [getDuplicateRequests] Duplicated Retrieved: ' + mDuplicateServiceRequests);
        System.debug('----> [getDuplicateRequests] Presenting component...');
        return mDuplicateServiceRequests; 
    }
    
    public Id fetchDuplicateParent() {
        // Fetch duplicates.
        /*List<Case> mDuplicateServiceRequests = getDuplicateRequests();

if (mDuplicateServiceRequests != null && mDuplicateServiceRequests.size() > 0) {
for (Case c : mDuplicateServiceRequests) {
if (c.Incap311__Duplicate_Parent__c == null) {
return c.Id;
}
}
}
return null;*/
        
        Case c = fetchDuplicateParentFull();
        if (c != null) {
            return c.Id;
        }
        else {
            return null;
        }
    }
    
    public Case fetchDuplicateParentFull() {
        List<Case> mDuplicateServiceRequests = getDuplicateRequests();
        
        if (mDuplicateServiceRequests != null && mDuplicateServiceRequests.size() > 0) {
            for (Case c : mDuplicateServiceRequests) {
                if (c.Incap311__Duplicate_Parent__c == null) {
                    return c;
                }
            }
        }
        return null;
    }
    
    public void feedContactInformationToPage() {
        try {
            System.debug('----> ContactJson: ' + ApexPages.currentPage().getParameters().get('contactJson'));
            Contact tempCon = (Contact) JSON.deserialize(ApexPages.currentPage().getParameters().get('contactJson'), Contact.class);
            System.debug('----> TempCon: ' + tempCon);
            String contactId = (tempCon != null && tempCon.Id != null? tempCon.Id : '');
            if(contactId != ''){
             this.mContactToPass = conCtrl.feedContactInformationToPage(contactId);
            }else{
                this.mContactToPass = null;
            }
        } catch (Exception e) {
            System.debug('----> Error: ' + e.getMessage());
            this.mContactToPass = null;
            throw e;
            //mErrorMsg = e.getMessage()+ e.getStackTraceString();
        }
    }
    
    public void feedParentInformationToPage() {
        try {
            System.debug('----> Feeding the parent information into the current case.'); 
            Case tempC = (Case) JSON.deserialize(ApexPages.currentPage().getParameters().get('parentJson'), Case.class);
            this.mActParentCaseNum = tempC.CaseNumber;
        } catch (Exception e) {
            System.debug('----> Error: ' + e.getMessage());
           //mErrorMsg = e.getMessage()+ e.getStackTraceString();
            this.mActParentCaseNum = null;
        }
    }
    
    public void feedAccountInformationToPage() {
        try {
            Account tempAcc = (Account) JSON.deserialize(ApexPages.currentPage().getParameters().get('accountJson'), Account.class);
            this.mAccountToPass = tempAcc;
        } catch(Exception e) {
            System.debug('----> Error: ' + e.getMessage());
           // mErrorMsg = e.getMessage()+ e.getStackTraceString();
            this.mAccountToPass = null;
        }
    }
    
    public Boolean getIsActiveSerivceTypeSet() {
        return String.isNotBlank(this.mActiveServiceType);
    }
    
    public List<Incap311__Service_Type_Version__c> getCurrentServiceTypeAsList() {
        if(this.mActiveTypeVersion == null) {
            return new List<Incap311__Service_Type_Version__c>();
        }
        return new List<Incap311__Service_Type_Version__c>{ this.mActiveTypeVersion };
            }  
    
    
    public List<Incap311__Service_Type_Version__c> getServiceRequestItems() {
        Boolean activityTypesOnly = this.mLevel != null && this.mLevel.equalsIgnoreCase(this.LEVEL_ACTIVITY) ? true : false;
        List<Incap311__Service_Type_Version__c> stList = new List<Incap311__Service_Type_Version__c>();
        
        if(!String.isEmpty(this.mAction) && this.mAction.equalsIgnoreCase(ACTIVITY_TYPE_EDIT)) { 
            stList.add(this.mActiveTypeVersion);
            //this.mServiceTypesMapByName.put(this.mActiveTypeVersion.Name, this.mActiveTypeVersion);
            return stList;
        }
        
        if(mGenericSRType != null){
            stList.add(mGenericSRType);
            //this.mServiceTypesMapByName.put(mGenericSRType.Name, mGenericSRType);
            return stList;
        }
        
        List<Incap311__Service_Type_Version__c> tempStvList = new List<Incap311__Service_Type_Version__c>();
        
        tempStvList = this.ACTIVITY_TYPE_TRANSFER.equalsIgnoreCase(this.mAction) || this.ACTIVITY_TYPE_EDIT.equalsIgnoreCase(this.mAction)
            ? Incap311.Base311_Transfer_Case.getActiveServiceTypes(this.mOrgTransferCase.Incap311__Service_Type_Version__r.Incap311__Service_Type__c, activityTypesOnly) 
            : this.restServiceService.getActiveServiceTypesWithoutActivities(True);
        
        System.debug('--> tmpStvLit : ' + tempStvList);
        
        // @REVIEW 
        // Can't we short-circut all of this and simply return an empty list if the current service type is special?   
        
        System.debug(tempStvList);
        // Compile a mapping of the service type version name to it's respective object. 
        for (Incap311__Service_Type_Version__c stv : tempStvList) {
            // Keep Type reference in map for generic requests. 
            //this.mServiceTypesMapByName.put(stv.Name, stv);
            // Remove reference to service type from page. 
            if (this.mSpecialServiceTypeCodeMap.size() == 0 || this.mSpecialServiceTypeCodeMap.size() > 0 && !this.mSpecialServiceTypeCodeMap.contains(stv.Incap311__Service_Type_Code__c)) {
                stList.add(stv);
            }
        }
        System.debug('----> stList: ' + stList);
        //System.debug('----> this.mServiceTypesMapByName' + this.mServiceTypesMapByName);
        
        
        return stList;
    }
    
    public String getServiceRequestNames() {
        //@REVIEW Same comment as line 262
        System.debug('----> ST ID: ' + this.mOrgTransferCase.Incap311__Service_Type_Version__r.Incap311__Service_Type__c);
        System.debug('----> mOrgTransferCase: ' + this.mOrgTransferCase);
        
        List<String> tempStrList = new List<String> ();
        List<Incap311__Service_Type_Version__c> serviceTypes =  getServiceRequestItems();
        
        System.debug('----> Returned list of Types: ' + serviceTypes);
        
        for (Incap311__Service_Type_Version__c type : serviceTypes) {
            if (String.isNotBlank(type.Incap311__Service_Name__c)) {
                if (this.mSpecialServiceTypeCodeMap.size() == 0 || this.mSpecialServiceTypeCodeMap.size() > 0 && !this.mSpecialServiceTypeCodeMap.contains(type.Incap311__Service_Type_Code__c)) {
                    System.debug('----> Adding SRType to list: ' + type);
                    tempStrList.add(type.Incap311__Service_Name__c);
                }
            }
        }
        System.debug('----> tempStrList: ' + tempStrList);
        String serviceRequestNames = JSON.serialize(tempStrList);
        
        return serviceRequestNames;
    }
    
    public String getServiceRequestsMap() {
        
        Map<String, String> srtMap = new Map<String, String>();
        List<Incap311__Service_Type_Version__c> serviceTypes =  getServiceRequestItems();
        
        for (Incap311__Service_Type_Version__c type : serviceTypes) {
            if (String.isNotBlank(type.Incap311__Service_Name__c)) {
                if (this.mSpecialServiceTypeCodeMap.size() == 0 || this.mSpecialServiceTypeCodeMap.size() > 0 && !this.mSpecialServiceTypeCodeMap.contains(type.Incap311__Service_Type_Code__c)) {
                    srtMap.put(type.Incap311__Service_Name__c, type.Incap311__Keywords__c);
                }
            }
        }
        
        String ServiceRequestsMap = JSON.serialize(srtMap);
        return ServiceRequestsMap;
    }
    
    // Get all the origin options.https://na35.salesforce.com/_ui/common/apex/debug/ApexCSIPage#
    public List<SelectOption> getOriginOptions() {
        return Console311_Util.getPicklistValues(new Case(), 'Origin');
    }
    
    // Get all the status options from the picklist.
    public List<SelectOption> getStatusOptions() {
        return Console311_Util.getPicklistValues(new Case(), 'Status');
    }
    
    // Get all the origin options.
    public List<SelectOption> getStateOptions() {
        return Console311_Util.getStatesByCountry('US');
    }
    
    @RemoteAction
    global static List<Incap311.Base311_Location> getAddressAutocomplete(String queryStr) {
        return Incap311.Base311_LocationSearch.getLocationsByAddress(queryStr);
    }
    
    public PageReference storeLocationInformation() {
        // TODO: Callout to grab the schedule information. Check limits and dupes. 
        
        String locationStr = ApexPages.currentPage().getParameters().get('addressStr');
        mLocation = null;
        mSubLocation = null;
        if(!String.isBlank(locationStr))
        {
            List<Incap311.Base311_Location> locationsList = Incap311.Base311_LocationSearch.getLocationsByAddress(locationStr);
            
            if (locationsList.size() > 0) {
                mLocation = locationsList.get(0);
                
                Incap311__Service_Type_Version__c tempStv = getServiceTypeVersionFromMappingUsingName();
                
                if (this.getIsActiveTypeBulkType()) {
                    this.mLayerInfoMap = genScheduleMatching();
                }
                
                // Check the sr type for bulk/schedulable and if "Requests" type then verify limits. Items version handled in component controller.
                if (this.getIsActiveTypeBulkType() && tempStv.Incap311__Service_Type__r.Incap311__Schedule_Type__c == 'Requests') {
                    Console311_Section_BulkDatePicker tempBulkCtrl = new Console311_Section_BulkDatePicker();
                    
                    tempBulkCtrl.stId = getServiceTypeIdFromMappingUsingName();
                    tempBulkCtrl.mStv = tempStv;
                    tempBulkCtrl.zone = getZoneFromAddress();
                    tempBulkCtrl.stSchAfterDays = Integer.valueOf(tempStv != null ? tempStv.Incap311__Service_Type__r.Incap311__Schedule_After_Days__c : 0);
                    tempBulkCtrl.mLat = getCurrentLocationLatitude();
                    tempBulkCtrl.mLng = getCurrentLocationLongitude();
                    tempBulkCtrl.getBulkDateButtons();
                    
                    if (tempBulkCtrl.mErrorCode == tempBulkCtrl.ERROR_LIMIT_EXCEEDED || tempBulkCtrl.mErrorCode == tempBulkCtrl.ERROR_DUPLICATE_DETECTED) {
                        this.mSaveEnabled = false;
                    } 
                }
            } 
        }
        System.debug('----> location: ' + mLocation);
        return null;
    }
    
    public Map<String, Console311_Wrap_LayerInformation> genScheduleMatching() {
        Map<String, Console311_Wrap_LayerInformation> returnMapping = new Map<String, Console311_Wrap_LayerInformation>();
        List<Incap311.Base311_ESRI_Layer> layers;
        
        if (Test.isRunningTest()) {
            layers = TestHelper.genMockLayerInformation();
        } else {
            layers = this.getCaseLayers();
        }
        Incap311__Service_Type_Version__c stv = this.getServiceTypeVersionFromMappingUsingName();
        
        if (layers != null && stv != null) {
            if (stv.Incap311__Service_Type__r.Incap311__Schedule_Matching__c != null) {        
                Map<String, Console311_Wrap_LayerInformation> layerDataList = (Map<String, Console311_Wrap_LayerInformation>) JSON.deserialize((String)stv.Incap311__Service_Type__r.Incap311__Schedule_Matching__c, Map<String, Console311_Wrap_LayerInformation>.class);
                System.debug('----> layerDataList: ' + layerDataList);
                
                for (String key : layerDataList.keySet()) {
                    Console311_Wrap_LayerInformation li = layerDataList.get(key);
                    System.debug('----> [Inside Loop] => Console311_Wrap_LayerInformation: ' + li);
                    for (Incap311.Base311_ESRI_Layer layer : layers) {
                        System.debug('----> [Inside ESRI Loop] => Active LayerName: ' + layer.layerName);
                        if (li.layer_name.equalsIgnoreCase(layer.layerName)) {
                            System.debug('----> Found layer to use. Returning ' + layer.layerName + ': ' + layer.value);              
                            
                            if (li.layer_value.equalsIgnoreCase('value')) {
                                returnMapping.put(key, new Console311_Wrap_LayerInformation(layer.layerName, layer.value, li.layer_title, li.format));  
                            } else if (li.layer_value.contains('attributes.')) {
                                String attrName = (li.layer_value.split('\\.'))[1];
                                
                                if (layer.attributes.containsKey(attrName)) {
                                    returnMapping.put(key, new Console311_Wrap_LayerInformation(layer.layerName, layer.attributes.get(attrName), li.layer_title, li.format));
                                }
                            }
                            break;
                        }
                    }     
                }
            }
        }
        System.debug('----> [genScheduleMatching] returnMapping: ' + returnMapping);
        return returnMapping;
    }
    
    public void storeSubLocation() {
        String locationStr = ApexPages.currentPage().getParameters().get('sublocationJSON');
        if(String.isEmpty(locationStr)) {
            mSubLocation = null;
            return;
        }
        
        Incap311.Base311_Location loc = (Incap311.Base311_Location) JSON.deserialize(locationStr, Incap311.Base311_Location.class);
        mSubLocation = loc;
    }
    
    private Incap311.Base311_Location getActiveLocation() {
        return this.mSubLocation == null ? this.mLocation : this.mSubLocation;
    }
    
    public Boolean getShowSubUnit() {
        return mActiveTypeVersion == null ? false : mActiveTypeVersion.Incap311__Enable_Sub_Units__c;
    }
    
    public ServiceRequestWrapper getServiceRequestWrapper(){
        try {
                System.debug('----> Json Str: ' + mCaseJson);
                ServiceRequestWrapper srWrapper = (ServiceRequestWrapper) JSON.deserialize(mCaseJson, ServiceRequestWrapper.class);
                System.debug('----> srWrapper: ' + srWrapper);
            return srWrapper;
            } catch (Exception e) {
                System.debug('----> Error occured while parsing sent JSON: ' + e.getMessage());
                mErrorMsg = 'Unable to Save the given request data. Please try agaain.';
               
                return null;
            }
    }
    
    public PageReference saveCase() {
        // TODO: Add in address detailing.
        // TODO: Add contact verification and saving.
        System.debug('----> Save: Begining Process...');
        this.mErrorMsg = '';
        this.mIsSaving = true;
        
        Incap311.Base311_Location activeLocation = getActiveLocation(); 
        
        if(activeLocation != null && !Test.isRunningTest()) {
            activeLocation.addLayerInformation();
        }
        
        if (String.isNotBlank(mCaseJson)) {
            ServiceRequestWrapper srWrapper = getServiceRequestWrapper();
            
            
            if (srWrapper.isValid()) {
                Savepoint sp = Database.setSavepoint();
                this.nextAvailableSchedule = new Incap311__Schedule__c();
                
                try {
                    System.debug('----> srWrapper is valid. Continuing saving process...');
                    System.debug('----> srWrapper: ' + srWrapper);
                    
                    Map<String, Object> flexnoteSaveMapping = this.convertFlexnoteAnswersToMap(srWrapper.serviceQuestions, True);
                    System.debug('----> flexnoteSaveMapping: ' + flexnoteSaveMapping);
                    
                    // TODO: Check address validation here
                    System.debug('----> mLocation: ' + activeLocation);
                    
                    Incap311.Base311_Contact rCon = null;
                    system.debug('Contact Map  '+srWrapper.contact.getPopulatedFieldsAsMap());
                    Map<String,Object> contactFields = srWrapper.contact.getPopulatedFieldsAsMap().clone();
                    //contactFields.put('Id',srWrapper.contact.Id);
                    rCon = new Incap311.Base311_Contact(contactFields);
                    rCon.findId();
                    String srVTypeName = String.isNotBlank(srWrapper.c.Incap311__Service_Type_Version__c) ? String.valueOf(srWrapper.c.Incap311__Service_Type_Version__c) : this.mActiveServiceType;
                    
                    System.debug('---> srVTypeName ' + srVTypeName);
                    
                    if (String.isNotBlank(srVTypeName)) {
                        Case newCase;
                        // Verify if the type is a bulk service type and process if so.
                        Incap311__Service_Type_Version__c stv = (this.restServiceService.getServiceType(srVTypeName, true));
                        rCon.setRequired(stv);
                        Id dupParentId = srWrapper.shouldSetDupe ? fetchDuplicateParent() : null;
                        
                        System.debug('---> Transfer Type: ' + this.mAction);
                        System.debug('---> this.ACTIVITY_TYPE_TRANSFER: ' + this.ACTIVITY_TYPE_TRANSFER);
                        System.debug('---> this.ACTIVITY_TYPE_TRANSFER.equalsIgnoreCase(this.mAction): ' + this.ACTIVITY_TYPE_TRANSFER.equalsIgnoreCase(this.mAction));

                        Map<String, Incap311.Base311_Attribute> attrMap = Incap311.Base311_Attribute.fromMap(flexnoteSaveMapping);

                        // Add new attribute to mapping for schedule if present. 
                        if (stv.Incap311__Service_Type__r != null && stv.Incap311__Service_Type__r.Incap311__Is_Bulk_Type__c && srWrapper.schedule != null) {
                          attrMap.put(Incap311.Base311_Service_Bulk.SCHEDULE_ATTRIBUTE_IDENTIFIER, new Incap311.Base311_Attribute(Incap311.Base311_Service_Bulk.SCHEDULE_ATTRIBUTE_IDENTIFIER, srWrapper.schedule.Id));
                        }
                        System.debug('----> attrMap: ' + attrMap);
                        
                        if (this.ACTIVITY_TYPE_TRANSFER.equalsIgnoreCase(this.mAction)) {
                            // Take the copy of the transfer case and modify the fields based on the new input from the wrapper.
                            this.mSavedCase.Status = srWrapper.c.Status;
                            this.mSavedCase.Description = srWrapper.c.Description;
                            this.mSavedCase.Origin = srWrapper.c.Origin;
                            this.mSavedCase.Incap311__Service_Type_Version__c = (stv != null ? stv.Id : mSavedCase.Incap311__Service_Type_Version__c);
                            
                            // Check the location data and see if it needs updating.
                            if (activeLocation != null) {
                                System.debug('----> NEW Location Data: ' + activeLocation);
                                this.mSavedCase.Incap311__Address_Id__c = activeLocation.addressId;
                                this.mSavedCase.Incap311__Location__Latitude__s = activeLocation.lat;
                                this.mSavedCase.Incap311__Location__Longitude__s = activeLocation.lng;
                                this.mSavedCase.Incap311__Address__c = activeLocation.address;
                                this.mSavedCase.Incap311__ZipCode__c = activeLocation.zipCode;
                                this.mSavedCase.Incap311__XCoordinate__c = activeLocation.xCoord;
                                this.mSavedCase.Incap311__YCoordinate__c = activeLocation.yCoord;
                                this.mSavedCase.Incap311__Neighborhood__c = activeLocation.neighbourhood; 
                                this.mSavedCase.Incap311__Parcel__c = activeLocation.parcel;
                                this.mSavedCase.Incap311__Precinct__c = activeLocation.precinctWard; 
                                this.mSavedCase.Incap311__Street_ID__c = activeLocation.streetId;
                                this.mSavedCase.Incap311__Unit__c = activeLocation.unit;
                                this.mSavedCase.Incap311__Ward__c = activeLocation.ward;
                            }
                            
                            this.mSavedCase.Incap311__Duplicate_Parent__c = srWrapper.shouldSetDupe ? fetchDuplicateParent() : null;
                            // Send the updated version, the original version of the case and the new flex note answers. 
                            newCase = Incap311.Base311_Transfer_Case.transferCase(this.mSavedCase, this.mOrgTransferCase, flexnoteSaveMapping);
                            System.debug('----> New Case AFTER Transfer: ' + newCase);
                        } 
                        else if (this.ACTIVITY_TYPE_EDIT.equalsIgnoreCase(this.mAction)) {
                            List<Incap311.Base311_Activity> acts = new List<Incap311.Base311_Activity>();
                            
                            for(Incap311__Service_Activity__c act : mSavedCase.Incap311__Service_Activities__r) {
                                Incap311.Base311_Activity a = new Incap311.Base311_Activity(
                                    act.Name, act.Incap311__Status__c, null, null
                                );
                                
                                acts.add(a);
                            }
                            
                            newCase = restServiceRequest.updateServiceRequest(
                                new Incap311.Base311_Case(
                                    mSavedCase.Id,
                                    srWrapper.c.Description, srWrapper.c.Status, '', 
                                    srVTypeName, srWrapper.c.Origin, 'Agent'
                                ),
                                activeLocation,
                                Incap311.Base311_Attribute.fromMap(flexnoteSaveMapping),
                                rcon,
                                acts
                            );   
                            newCase.Incap311__Location_Details__C = srWrapper.c.Incap311__Location_Details__C;
                            update newCase;
                            
                        }  
                        else {              
                            // Create the case using the REST API methods.
                            newCase = restServiceRequest.createServiceRequest(
                                new Incap311.Base311_Case(srWrapper.c.Description, srWrapper.c.Status, '', srVTypeName, srWrapper.c.Origin, 'Agent'),
                                activeLocation,
                                rcon,
                                attrMap
                            );
                            newCase.Incap311__Location_Details__C = srWrapper.c.Incap311__Location_Details__C;
                            
                            
                            // If a parent id is present then set it.
                            if (srWrapper.c.ParentId != null) {
                                newCase.ParentId = srWrapper.c.ParentId;
                            }
                            
                            // Update Case status to be representative IF a duplicate.
                            if (dupParentId != null) {
                                Case dc = fetchDuplicateParentFull();
                                if (dc != null) {
                                    newCase.Status = dc.Status + ' (Duplicate)';
                                }
                                else {
                                    newCase.Status = 'Open (Duplicate)';
                                }
                                
                            }
                            
                            update newCase;
                        }  
                        
                        newCase.Incap311__Location_Details__C = srWrapper.c.Incap311__Location_Details__C;
                        
                        if (srWrapper.account != null && srWrapper.account.Id != null) {
                            // Add the account id to the case.
                            newCase.AccountId = srWrapper.account.Id;
                            update newCase;
                        } else if (srWrapper.account != null && srWrapper.account.Name != null) {
                            // Insert the new account.
                            insert srWrapper.account;
                            // Attach the new account to the case.
                            newCase.AccountId = srWrapper.account.Id;
                            update newCase;
                        }
                        
                        // Upsert the contact address details.
                        restServiceContact.updateContactAddressInformation(newCase.ContactId, srWrapper.contact.MailingStreet, srWrapper.contact.MailingCity, srWrapper.contact.MailingState, srWrapper.contact.MailingPostalCode);
                        this.mSavedCase = newCase;
                        
                        if (dupParentId != null) {
                            this.mSavedCase.Incap311__Duplicate_Parent__c = dupParentId;
                            update this.mSavedCase;
                        }
                        
                        System.debug('----> stv: ' + stv);
                        //System.debug('----> stv.Incap311__Service_Type__r.Incap311__Is_Bulk_Type__c: ' + stv.Incap311__Service_Type__r.Incap311__Is_Bulk_Type__c);
                        System.debug('----> this.mBulkItemCount: ' + this.mBulkItemCount);
                        
                        // Populate the schedulable.
                        /*srWrapper.populateSchduleable();
                        
                        System.debug('----> Schedule: ' + srWrapper.schedule);
                        System.debug('----> Item Limit: ' + srWrapper.schedule.Incap311__Service_Type__r.Incap311__Item_Limit__c);
                        
                        if (srWrapper.schedule != null && stv.Incap311__Service_Type__r != null && stv.Incap311__Service_Type__r.Incap311__Is_Bulk_Type__c && srWrapper.schedule.Incap311__Service_Type__r.Incap311__Schedule_Type__c != 'Requests' && this.mBulkItemCount == 0) {
                            this.mErrorMsg = 'Unable to save service request. Cannot schedule pickup with 0 items.';
                            Database.rollback(sp);
                        } else if (srWrapper.schedule != null && stv.Incap311__Service_Type__r.Incap311__Is_Bulk_Type__c && srWrapper.schedule.Incap311__Service_Type__r.Incap311__Schedule_Type__c != 'Requests' && this.mBulkItemCount > srWrapper.schedule.Incap311__Service_Type__r.Incap311__Item_Limit__c) {
                            this.mErrorMsg = 'Unable to save service request. Schedule request exceeds accepted pickup limit.';
                            Database.rollback(sp);
                        } else if (srWrapper.schedule != null && stv.Incap311__Service_Type__r.Incap311__Is_Bulk_Type__c) {
                            System.debug('----> Item Count: ' + srWrapper.schedule.Incap311__Item_Count__c);
                            System.debug('----> this.mBulkItemCount: ' + this.mBulkItemCount);
                            
                            if (this.restServiceBulk.verifyAvailablityByScheduleType(srWrapper.schedule, this.mBulkItemCount)) {
                                System.debug('-----> Schedule varified to have room available. Processing...');
                                
                                srWrapper.schedule = this.restServiceBulk.updateScheduleCount(srWrapper.schedule, srWrapper.schedule.Incap311__Service_Type__r.Incap311__Schedule_Type__c == 'Requests' ? 1 : this.mBulkItemCount);
                                // Create the Service_Request_Schedule__c and update the auto close date on the case. 
                                this.restServiceBulk.createServiceRequestSchedule(srWrapper.schedule, this.mSavedCase, srWrapper.schedule.Incap311__Service_Type__r.Incap311__Schedule_Type__c == 'Requests' ? 1 : this.mBulkItemCount);
                            } else {
                                this.mErrorMsg = 'Unable to save service request. Schedule no longer has enough room to handle your request. Please choose another schedule date.';    
                                System.debug('----> Capacity for schedule is too small. Requires new date pick.');
                                Database.rollback(sp); 
                            }
                        }*/
                        System.debug('----> Case: ' + this.mSavedCase);
                        System.debug('----> Case Saved. Sending user to new case tab...'); 

                        // Save any update notes on edit to the case comments. 
                        if(!String.isEmpty(srWrapper.ai.distUpdateNotes)) {
                          CaseComment cc = new CaseComment(
                            ParentId = this.mSavedCase.Id,
                            CommentBody = srWrapper.ai.distUpdateNotes
                          );
                          insert cc;
                        }

                        //If we have a distribution list (or coordinat            
                        String distributionList = '';
                        
                        if(!String.isEmpty(srWrapper.ai.distributionList)) {
                            distributionList = srWrapper.ai.distributionList;
                            
                            if(!String.isEmpty(srWrapper.ai.coordinatorList)) {
                                distributionList = (distributionList + ',');
                            }
                        }
                        
                        if(!String.isEmpty(srWrapper.ai.coordinatorList)) {
                            distributionList = (distributionList + srWrapper.ai.coordinatorList);
                        }
                        
                        if(!String.isEmpty(distributionList)) {
                            Case withEmailFields = restServiceRequest.getServiceRequests(new Set<Id>{ this.mSavedCase.Id })[0];
                            String emailBody = Incap311.Base311_MailMerge.caseNotifyEmail(withEmailFields, true);

                            // Add case comment to email body. 
                            if (this.mAction == ACTIVITY_TYPE_EDIT && String.isNotBlank(srWrapper.ai.distUpdateNotes)) {
                              emailBody += '<br/><br/>';
                              emailBody += 'Service Request Updates:<br/>';
                              emailBody += srWrapper.ai.distUpdateNotes;
                            }
                            
                            System.debug('----> DL: ' + distributionList);
                            System.debug('----> DL-Coordinators: ' + srWrapper.ai.coordinatorList);
                            System.debug('----> DL-Default: ' + srWrapper.ai.distributionList);
                            System.debug('----> Email_Body: ' + emailBody);    
                            
                            // TODO: Add addition of related dist object reference. 
                            Incap311__Case_Event__c ce = sce.notify(
                                this.mSavedCase, 
                                this.mOrgTransferCaseNum == null ? 'Create' : 'Update', 
                                distributionList, 
                                emailBody
                            );
                            
                            List<Incap311__Distributions__c> tempSqList;
                            if (this.mAction == ACTIVITY_TYPE_EDIT) {
                                System.debug('----> Edit Mode - Grabbing queue name from Queue query...');
                                if(mLatestCaseEvent != null){
                                    System.debug('----> Edit Mode - mLatestCaseEvent.Incap311__Service_Queue__c: ' + mLatestCaseEvent.Incap311__Distribution__c);
                                    tempSqList = [Select Id, Incap311__Name__c From Incap311__Distributions__c Where Id = :mLatestCaseEvent.Incap311__Distribution__c];
                                    this.mSelectedDistribution = tempSqList.size() > 0 ? tempSqList.get(0).Incap311__Name__c : this.mSelectedDistribution; 
                                }else{
                                    tempSqList = [Select Id, Incap311__Name__c From Incap311__Distributions__c Where Incap311__Name__c = :mSelectedDistribution];
                                }                                    
                            } else {
                                tempSqList = [Select Id, Incap311__Name__c From Incap311__Distributions__c Where Incap311__Name__c = :mSelectedDistribution];
                            }
                            System.debug('----> tempSqList: ' + tempSqList);
                            
                            if (tempSqList != null && tempSqList.size() > 0) {
                                // Set the service queue id on the Case Event.
                                ce.Incap311__Distribution__c = tempSqList.get(0).Id;
                                update ce;

                                //TODO: UNCOMMENT WITH CORE UPDATE
                                this.mSavedCase.Incap311__Distribution__c = tempSqList.get(0).Id;
                                update this.mSavedCase;
                                
                                // Split the distrution list already saved on the case event to a usable SET.
                                Set<String> distActiveEmailSet = new Set<String>();
                                Map<String, Contact> distActiveContactMap = new Map<String, Contact>();
                                
                                List<String> distSavedEmailList = distributionList.split(',');
                                // Prepare to build the Case Recipient list to save.
                                List<Incap311__Case_Recipient__c> crList = new List<Incap311__Case_Recipient__c>();
                                List<Incap311__Case_Event_Recipient__c> cerList = new List<Incap311__Case_Event_Recipient__c>();
                                // Obtain an updated copy of the distribution mappings in case something changed. 
                                retrieveDistListUsingMatching();
                                System.debug('----> Active Dist Mapping: ' + this.mDistMap);
                                // Loop through the coodinators and general members to create recipients. Flag ones used in the distribution.
                                for (Incap311.DISTRIBUTION_LIST_TYPE key : this.mDistMap.keySet()) {
                                    for (Contact distMember : this.mDistMap.get(key)) {
                                        System.debug('----> Found a distMember: ' + distMember);
                                        distActiveEmailSet.add(distMember.Email);
                                        
                                        if (!distActiveContactMap.containsKey(distMember.Email)) {
                                            distActiveContactMap.put(distMember.Email, distMember);
                                        }
                                    }
                                }
                                System.debug('----> distActiveEmailSet: ' + distActiveEmailSet);
                                System.debug('----> distActiveContactMap: ' + distActiveContactMap);
                                
                                Map<String, Incap311__Case_Event_Recipient__c> updateExisitingCerMap = new Map<String, Incap311__Case_Event_Recipient__c>();
                                if(this.mAction == ACTIVITY_TYPE_EDIT) {
                                    System.debug('----> DETECTED: Edit Event for Distribution Enabled Case! Adjusting to edit mode...');
                                    if(mLatestCaseEvent != null){
                                        for (Incap311__Case_Event_Recipient__c cer : mLatestCaseEvent.Incap311__Case_Event_Recipients__r) {
                                            updateExisitingCerMap.put(cer.Incap311__Case_Recipient__r.Incap311__Email__c, cer);
                                        }
                                    }
                                    System.debug('----> Edit Mode: updateExisitingCerMap: ' + updateExisitingCerMap);
                                    System.debug('----> Edit Mode: Validating email list with exisiting recipients...');
                                }
                                Set<String> updateEmailExistingList = updateExisitingCerMap.keySet();
                                
                                // TODO: EDIT -> Check for existing recipients and do NOT create if already existing.
                                // Loop through the email list saved on the event and create recipients based off it. Mark as default vs manual entry.
                                for (String email : distSavedEmailList) {
                                    // If the current activity IS an edit and we already have an exisiting recipient with the given email, skip.
                                    if(this.mAction != ACTIVITY_TYPE_EDIT && !updateEmailExistingList.contains(email)) {
                                        Incap311__Case_Recipient__c cr = new Incap311__Case_Recipient__c (
                                            Incap311__Case__c = this.mSavedCase.Id,
                                            Incap311__Contact__c = distActiveContactMap.containsKey(email) ? distActiveContactMap.get(email).Id : null,
                                            Incap311__Email__c = email,
                                            Incap311__Is_Member__c = distActiveEmailSet.contains(email) ? true : false
                                        );
                                        crList.add(cr);
                                    } else {  
                                        if (updateExisitingCerMap.containsKey(email)) {
                                            System.debug('----> Edit Mode: Email is existing on previous Case Event. Adding to extended list for Case Recipients to avoid duplication...');
                                            crList.add(updateExisitingCerMap.get(email).Incap311__Case_Recipient__r);
                                        } else {
                                            System.debug('----> Edit Mode: Email does NOT exist from previous Case Event. Creating entry...');
                                            Incap311__Case_Recipient__c cr = new Incap311__Case_Recipient__c (
                                                Incap311__Case__c = this.mSavedCase.Id,
                                                Incap311__Contact__c = distActiveContactMap.containsKey(email) ? distActiveContactMap.get(email).Id : null,
                                                Incap311__Email__c = email,
                                                Incap311__Is_Member__c = distActiveEmailSet.contains(email) ? true : false
                                            );
                                            crList.add(cr);
                                        } 
                                    }
                                }
                                upsert crList;
                                // Loop through the recipients and make the making objects between recipients and events.
                                for (Incap311__Case_Recipient__c cr : crList) {
                                    Incap311__Case_Event_Recipient__c cer = new Incap311__Case_Event_Recipient__c (
                                        Incap311__Case_Event__c = ce.Id,
                                        Incap311__Case_Recipient__c = cr.Id 
                                    );
                                    cerList.add(cer);
                                }
                                insert cerList;
                            }
                        }
                        
                    } else {
                        this.mErrorCodeActive = this.ERROR_TYPE_UNAVAILABLE;
                        this.mErrorMsg = 'Unable to save service request. Service Type may need to be reselected from the dropdown.';
                        System.debug('----> No service type in mActiveServiceType. Cancelling Case creation...');
                        //logger.singleLog('Service Type Version Type Name is blank. Wrapper: ' + srWrapper.c.Incap311__Service_Type_Version__c + ', Class Level: ' + this.mActiveServiceType);
                       
                        Database.rollback(sp);
                    }
                }
                catch (Exception e) {
                    System.debug('----> Exception: ' + e.getMessage());
                    System.debug('----> Exception Type: ' + e.getTypeName());
                    System.debug(e.getStackTraceString());
                    //throw e;
                    if (e.getMessage().contains('INVALID_EMAIL_ADDRESS')) {
                        mErrorMsg = 'Unable to save case due to invalid email address.  Please check contact email address and ensure it is well formed and then try again.';
                    }
                    else {
                        mErrorMsg = 'Unable to save case. ' + e.getMessage() + '. Please try again.';
                    }
                    Database.rollback(sp);
                  }
            }
        }
        this.mIsSaving = false;
        return null;
    }
    
    public void storeNumberOfBulkItems() {
        this.mErrorCodeActive = '';
        System.debug('----> Attempting to store bulk items count...');
        // If we have a service type name.
        if (String.isNotBlank(this.mActiveServiceType)) {
            System.debug('----> Service Type Available to use. Getting service type version...');
            Incap311__Service_Type_Version__c stv = getServiceTypeVersionFromMappingUsingName();
            // Check if bulk type.
            System.debug('----> stv: ' + stv);
            System.debug('----> this.mActiveServiceType: ' + this.mActiveServiceType);
            
            System.debug('----> Checking if the STV is a schedule type...');
            if (stv != null && stv.Incap311__Service_Type__r.Incap311__Is_Bulk_Type__c) {
                System.debug('----> Type is indeed a schedule type. Saving bulk item count to controller...');
                // Save the item total for processing.
                try {
                    this.mBulkItemCount = Integer.valueOf(ApexPages.currentPage().getParameters().get('numberOfBulkItemsToProcess'));
                } catch (Exception e) {
                    this.mBulkItemCount = 0;
                    System.debug('----> Error on Bulk Item Count: ' + e.getMessage());
                }
            }
        } else {
            this.mErrorCodeActive = this.ERROR_TYPE_UNAVAILABLE;
        }
    }
    
    public Map<String, Object> convertFlexnoteAnswersToMap(List<ServiceQuestionWrapper> sqWrapList, Boolean convertCheckboxes) {
        Map<String, Object> flexnoteSaveMapping = new Map<String, Object>();
        Incap311__Service_Type_Version__c stv = getServiceTypeVersionFromMappingUsingName();
        // Loop through all the service questions and generate the flexnote mappings. 
        for (ServiceQuestionWrapper sqw : sqWrapList) {     
            Object tempObj = sqw.question.Incap311__Answer__c;
            System.debug('----> Question Answer: ' + tempObj);
            // If the answer has commas then we know it's a multi picklist. 
            if(sqw.question.Incap311__Answer__c != null){
                System.debug('----> sqw.mDataType: ' + sqw.mDataType);
                if (String.isNotBlank(sqw.mDataType) && sqw.mDataType.equalsIgnoreCase('MultiPicklist') && sqw.question.Incap311__Answer__c.contains(',')) {
                    tempObj = sqw.question.Incap311__Answer__c.split(',');
                }
                
                if (convertCheckboxes && String.isNotBlank(sqw.mDataType) && sqw.mDataType.equalsIgnoreCase('Boolean (checkbox)')) {
                    if (tempObj == true || tempObj == false || tempObj == 'true' || tempObj == 'false') {
                        tempObj = tempObj;
                        System.debug('----> Checkbox was indeed already a boolean.');
                    } else {
                        System.debug('----> Checkbox was not set as a Boolean. Correcting...');
                        tempObj = ((String) tempObj).equalsIgnoreCase('on') ? true : false;
                    }
                }
                
                if (String.isNotBlank(sqw.mDataType) && sqw.mDataType.equalsIgnoreCase('Date')) {
                    System.debug('----> Date Answer: ' + sqw.question.Incap311__Answer__c);
                    //Date tempD = Date.parse(sqw.question.Incap311__Answer__c);
                }
                
                if (String.isNotBlank(sqw.mDataType) && sqw.mDataType.equalsIgnoreCase('Date/Time')) {
                    System.debug('----> Datetime BEFORE conversion: ' + sqw.question.Incap311__Answer__c);
                    //Datetime tempD = Datetime.parse(sqw.question.Incap311__Answer__c);
                    tempObj = Incap311.Base311_Helper.convert12HourTo24Hour(sqw.question.Incap311__Answer__c);
                    System.debug('----> Datetime AFTER conversion: ' + tempObj);
                }

                if (String.isNotBlank(sqw.mDataType) && sqw.mDataType.equalsIgnoreCase('Number') && stv != null && stv.Incap311__Service_Type__r.Incap311__Is_Bulk_Type__c) {
                  tempObj = String.isBlank((String) tempObj) ? '0' : tempObj;
                }
                
                flexnoteSaveMapping.put(sqw.mSRTypeVQuestionName, tempObj);
            }
        }
        System.debug('----> Flexnote mapping created. Processing...');
        System.debug('----> flexnoteSaveMapping: ' + flexnoteSaveMapping);
        return flexnoteSaveMapping;
    }
    
    public void retrieveDistListUsingMatching() {
        this.mDistMap = null;
        this.mSelectedDistribution = !this.mIsSaving ? ApexPages.currentPage().getParameters().get('districtName') : this.mSelectedDistribution;
        this.mDistNameVsAccountName = ApexPages.currentPage().getParameters().get('distRealName');
        System.debug('----> [retrieveDistListUsingMatching] mSelectedDistribution: ' + mSelectedDistribution);
        System.debug('----> [retrieveDistListUsingMatching] mDistNameVsAccountName: ' + mDistNameVsAccountName);

        Incap311__Service_Type_Version__c stv = getServiceTypeVersionFromMappingUsingName();
        System.debug('----> [retrieveDistListUsingMatching] Layers: ' + this.getCaseLayers());
        
        Console311_Section_LayerInfoCtrl liCtrl = new Console311_Section_LayerInfoCtrl('Incap311__Distribution_Matching_del__c');
        liCtrl.mStv = stv;
        liCtrl.mLayers = this.getCaseLayers();
        Map<String, Console311_Wrap_LayerInformation> mMatchingInfoList = liCtrl.getLayerInformationMap();
        
        System.debug('----> [retrieveDistListUsingMatching] Attemping to processing matching for list...');
        System.debug('----> [retrieveDistListUsingMatching] Criteria Provided - [STV]: ' + stv);
        System.debug('----> [retrieveDistListUsingMatching] Criteria Provided - [this.mSelectedDistribution]: ' + this.mSelectedDistribution);
        if (mMatchingInfoList != null && mMatchingInfoList.size() > 0 && mMatchingInfoList.get('zone') != null) {
            System.debug('----> [retrieveDistListUsingMatching] Matching found. Processing using zone attribute...');  
            System.debug('----> [retrieveDistListUsingMatching] Additional Criteria Provided - [mMatchingInfoList.get("zone").layer_value]: ' + mMatchingInfoList.get('zone').layer_value);
            this.mDistMap = restServiceDistribution.getWardDistributionLists(stv, mMatchingInfoList.get('zone').layer_value, this.mSelectedDistribution);
        } else {
            System.debug('----> [retrieveDistListUsingMatching] No matching found valid. Processing without zone argument...');
            this.mDistMap = restServiceDistribution.getDefaultDistributionLists(stv, this.mSelectedDistribution);
        } 
        
        if (this.mDistMap != null) {
            this.mDistributionListStr = restServiceDistribution.stringifyContactDistributionList(this.mDistMap.get(Incap311.DISTRIBUTION_LIST_TYPE.NORMAL));
            this.mCordinatorListStr = restServiceDistribution.stringifyContactDistributionList(this.mDistMap.get(Incap311.DISTRIBUTION_LIST_TYPE.COORDINATOR));
        }
    }
    
    public void retrieveDistributionListFromDistrict() {
        this.mDistributionListStr = '';
        this.mCordinatorListStr = '';
        
        this.mSelectedDistribution = ApexPages.currentPage().getParameters().get('districtName');
        this.mDistNameVsAccountName = ApexPages.currentPage().getParameters().get('distRealName');
        System.debug('----> District Name: ' + this.mSelectedDistribution);
        
        this.mDistMap = restServiceDistribution.getDefaultDistributionLists(this.mGenericSRType, this.mSelectedDistribution);
        
        if (this.mDistMap != null) {
            this.mDistributionListStr = restServiceDistribution.stringifyContactDistributionList(this.mDistMap.get(Incap311.DISTRIBUTION_LIST_TYPE.NORMAL));
            this.mCordinatorListStr = restServiceDistribution.stringifyContactDistributionList(this.mDistMap.get(Incap311.DISTRIBUTION_LIST_TYPE.COORDINATOR));
        }
        System.debug('----> this.mDistMap: ' + this.mDistMap);
    }
    
    public void retrieveDistributionListFromDistrictWithLocation() {
        this.mDistributionListStr = '';
        this.mCordinatorListStr = '';
        this.mSelectedDistribution = ApexPages.currentPage().getParameters().get('districtName');
        this.mDistNameVsAccountName = ApexPages.currentPage().getParameters().get('distRealName');
        
        System.debug('----> this.mSelectedDistribution: ' + this.mSelectedDistribution);
        System.debug('----> this.mLocation: ' + this.mLocation);
        
        if (String.isNotBlank(this.mSelectedDistribution) && this.mLocation != null) {
            
            this.mDistMap = restServiceDistribution.getWardDistributionLists(this.mGenericSRType, this.mLocation.ward, this.mSelectedDistribution);
            System.debug('----> this.mDistMap: ' + this.mDistMap);
            
            if (this.mDistMap != null) {
                this.mDistributionListStr = restServiceDistribution.stringifyContactDistributionList(this.mDistMap.get(Incap311.DISTRIBUTION_LIST_TYPE.NORMAL));
                this.mCordinatorListStr = restServiceDistribution.stringifyContactDistributionList(this.mDistMap.get(Incap311.DISTRIBUTION_LIST_TYPE.COORDINATOR));
            }
        }
    }  
    
    public String getServiceTypeIdFromMappingUsingName() {
        return (this.restServiceService.getServiceType(this.mActiveServiceType, true)).Incap311__Service_Type__c;
    }
    
    public Incap311__Service_Type_Version__c getServiceTypeVersionFromMappingUsingName() {
      try {
        System.debug('----> STV: ' + this.restServiceService.getServiceType(this.mActiveServiceType, true));
        return (this.restServiceService.getServiceType(this.mActiveServiceType, true));
      } catch (Exception e) {
        return null;
      }
    }

    public Boolean getDistributionEnabledForServiceTypeVersion() {
      try {
        Incap311__Service_Type_Version__c tempStv = this.getServiceTypeVersionFromMappingUsingName();
        System.debug('----> [getDistributionEnabledForServiceTypeVersion] tempStv: ' + tempStv);

        if (tempStv.Incap311__Enable_Distribution_del__c) {
          System.debug('----> Distribution is enabled. Checking availablity of distribute for type...');
          System.debug('----> Type: ' + this.mAction);
          System.debug('----> Incap311__Distribute_On__c: ' + tempStv.Incap311__Distribute_On__c);
          if (this.mAction == ACTIVITY_TYPE_EDIT && (tempStv.Incap311__Distribute_On__c == 'All' || tempStv.Incap311__Distribute_On__c == 'Edit')) {
            return true;
          } else if (String.isBlank(this.mAction) && tempStv.Incap311__Distribute_On__c == 'Create') {
            return true;
          } else if (tempStv.Incap311__Distribute_On__c == 'All') {
            return true;
          }
        }
        return false;
      } catch (Exception e) {
          //mErrorMsg = e.getMessage() + e.getStackTraceString();
        return null;
      }
    }
    
    public String getZoneFromAddress() {
        System.debug('----> [getZoneFromAddress] layers: ' + this.mLocation.layers);
        System.debug('----> [getZoneFromAddress] mLayerInfoMap: ' + this.mLayerInfoMap);
        
        if (this.mLocation.layers != null && this.mLayerInfoMap != null) {
            if (this.mLayerInfoMap.get('zone') != null) {
                System.debug('----> Zone: ' + this.mLayerInfoMap.get('zone'));
                return this.mLayerInfoMap.get('zone').layer_value;
            }
            return '';
        } 
        return '';
    }
    
    public String getDotwForLocation() {
        System.debug('----> getDotwForLocation: Start');
        if (this.mLocation != null && this.mLayerInfoMap != null) {
            System.debug('----> layers: ' + this.mLocation.layers);
            System.debug('----> mLayerInfoMap: ' + this.mLayerInfoMap);
            if (this.mLayerInfoMap.get('days_of_week') != null) {
                System.debug('----> [getDotwForLocation] this.mLayerInfoMap.get(days_of_week): ' + this.mLayerInfoMap.get('days_of_week'));
                return Console311_Util.genDayOfWeekFromFormatted(
                    this.mLayerInfoMap.get('days_of_week').layer_value,
                    this.mLayerInfoMap.get('days_of_week').format
                );
            }
            return '';
        }
        return '';
    }
    
    public Boolean getIsActiveTypeBulkType() {
        String stvName = String.isNotBlank(this.mActiveServiceType) ? this.mActiveServiceType : (String.isNotBlank(ApexPages.currentPage().getParameters().get('typeName')) ? ApexPages.currentPage().getParameters().get('typeName') : '');
            
            Incap311__Service_Type_Version__c stv = (this.restServiceService.getServiceType(stvName, true));
        
        if (stv != null) {
            return stv.Incap311__Service_Type__r.Incap311__Is_Bulk_Type__c;
        }
        return false;
    }
    
    private String getFinalAddressName() {
        String aliasFulladdress;
        
        if (this.mLocation.address != null && this.mLocation.zipCode != null) {
            aliasFulladdress = this.mLocation.address;
        }
        
        return aliasFulladdress;
    }
    
    /* --------- FLEXNOTE FUNCTIONS --------- */
    
    public void refreshFlexnotesWithUpdates(String serviceCode, Map<String, Object> answerMap) {
        System.debug('----> refreshFlexnotesWithUpdates => Begin');
        
        try {
            // Make a backup of the current answers list.
            this.mFNQuestionAnswerListBackup = this.mFNQuestionAnswerList;
            // Get the STV to send with the answers to Core.
            Incap311__Service_Type_Version__c stv = restServiceService.getServiceType(serviceCode, true);
            System.debug('---> STV ' + stv);
            this.mActiveTypeVersion = stv;    
            // Get an updated list of the questions with the answers pre-mapped.
            System.debug('----> answerMap ' + answerMap);
            List<Incap311__Service_Type_Version_Question__c> qs = restDependancies.getActiveQuestions(stv, answerMap);
            System.debug('----> Active Questions: ' + qs);
            
            if (qs != null && qs.size() > 0) {
                // Reset the current answer list.
                this.mFNQuestionAnswerList = new List<Console311_Wrap_FlexnoteQuestionAnswer>();
                // Generate a new one using the new values.
                for (Incap311__Service_Type_Version_Question__c vQuestion : qs) {
                    Console311_Wrap_FlexnoteQuestionAnswer fnqaw = new Console311_Wrap_FlexnoteQuestionAnswer(vQuestion,answerMap);   
                    System.debug('----> fnqaw: ' + fnqaw);
                    System.debug('----> Answer Map: ' + answerMap);
                    // Take the answer map and map the answers BACK into the questions.
                    if (answerMap.containsKey(fnqaw.stvQuestion.Incap311__Question__r.Incap311__Flex_Question_Code__c) && fnqaw.sq != null && String.valueOf(answerMap.get(fnqaw.stvQuestion.Incap311__Question__r.Incap311__Flex_Question_Code__c)) != '') {
                        System.debug('answerMap : has key ---> ' + fnqaw.stvQuestion.Incap311__Question__r.Incap311__Flex_Question_Code__c); 
                        if(
                            (fnqaw.stvQuestion.Incap311__Question__r.Incap311__Data_Type__c != 'Picklist' && fnqaw.stvQuestion.Incap311__Question__r.Incap311__Data_Type__c != 'MultiPicklist') ||
                            fnqaw.validatePicklistOption(String.valueOf(answerMap.get(fnqaw.stvQuestion.Incap311__Question__r.Incap311__Flex_Question_Code__c)))
                        ){
                            if (fnqaw.stvQuestion.Incap311__Question__r.Incap311__Data_Type__c == 'Date/Time') {                             Datetime dt = Incap311.Base311_Helper.parseDate(String.valueOf(answerMap.get(fnqaw.stvQuestion.Incap311__Question__r.Incap311__Flex_Question_Code__c)));
                                if(dt != null){
                                fnqaw.sq.Incap311__Answer__c = dt.format('MM/dd/yyyy hh:mm a');
                                }
                            } else {
                                fnqaw.sq.Incap311__Answer__c = String.valueOf(answerMap.get(fnqaw.stvQuestion.Incap311__Question__r.Incap311__Flex_Question_Code__c));
                            }                      
                        }
                    }else{
                        System.debug('answerMap : missing key ---> ' + fnqaw.stvQuestion.Incap311__Question__r.Incap311__Flex_Question_Code__c);
                        fnqaw.sq.Incap311__Answer__c = '';
                    }
                    this.mFNQuestionAnswerList.add(fnqaw);
                }
            }
        } catch (Exception e) {
            System.debug('----> Error: ' + e.getMessage());
            System.debug(e.getStackTraceString());
            //mErrorMsg = e.getMessage() + e.getStackTraceString();
            System.debug('----> Resetting values back to last backup copy...');
            this.mFNQuestionAnswerList = this.mFNQuestionAnswerListBackup;
        }
        System.debug('flexnotes ' + this.mFNQuestionAnswerList);
        System.debug('----> refreshFlexnotesWithUpdates => End ');
    }
    
    public void setSericeCodeWithAnswers(String serviceCode, Case savedCase) {
        Map<String, Object> answers = new Map<String, Object>();
        System.debug('right here'+savedCase.Incap311__Service_Questions__r);
        if (savedCase != null && savedCase.Incap311__Service_Questions__r != null) {
            for(Incap311__Service_Question__c sq : savedCase.Incap311__Service_Questions__r) {
                Incap311.Base311_Attribute attr = Incap311.Base311_Attribute.fromSQ(sq);
                System.debug(attr.value + ' typeof string ? ' + (attr.value instanceof String));
                answers.put(attr.code, attr.value);
            }
        }
        
        System.debug('pre-loaded answers : ' + answers);
        
        refreshFlexnotesWithUpdates(serviceCode, answers);
    }
    
    public void retrieveActiveServiceTypeWithFlexNotes(String serviceCode) {
        refreshFlexnotesWithUpdates(serviceCode,new Map<String, Object>());
    }
    
    public Decimal getCurrentLocationLatitude() {
        return this.mLocation != null ? this.mLocation.lat : 0.00;
    }
    
    public Decimal getCurrentLocationLongitude() {
        return this.mLocation != null ? this.mLocation.lng : 0.00;
    }
    
    // TODO: TEST!
    public void findSchedulableDate() {
        this.mSaveEnabled = true;
        this.mScheduleErrorMsg = '';
        String dotw = ApexPages.currentPage().getParameters().get('recycleDate');
        String numOfItems = ApexPages.currentPage().getParameters().get('numOfItems');
        Incap311__Service_Type_Version__c stv = getServiceTypeVersionFromMappingUsingName();
        System.debug('----> [findSchedulableDate] Attempting to find next available Schedule date for next [' + dotw + '] with capacity for [' + numOfItems + ']');
        
        //TODO: Remove. Tests for Unit Tests.
        System.debug('----> [findSchedulableDate] getServiceTypeIdFromMappingUsingName(): ' + getServiceTypeIdFromMappingUsingName());
        System.debug('----> [findSchedulableDate] getZoneFromAddress(): ' + getZoneFromAddress());
        
        List<Incap311__Schedule__c> listOfSchedules;
        // Get a list of schedules using the day of the week provided on the page. 
        if (String.isNotBlank(dotw)) {
            listOfSchedules = restServiceBulk.getNextAvailableScheduledDates(getServiceTypeIdFromMappingUsingName(), getZoneFromAddress(), 1, false, dotw, new Set<Id>(), Integer.valueOf(stv.Incap311__Service_Type__r.Incap311__Schedule_After_Days__c));
        } else {
            listOfSchedules = restServiceBulk.getNextAvailableScheduledDates(getServiceTypeIdFromMappingUsingName(), getZoneFromAddress(), 1, false, Integer.valueOf(stv.Incap311__Service_Type__r.Incap311__Schedule_After_Days__c));
        }  
        Incap311__Schedule__c baseSchedule;
        Incap311__Schedule__c activeSchedule;
        System.debug('----> [findSchedulableDate] List of schedules: ' + listOfSchedules);
        
        if (listOfSchedules != null && listOfSchedules.size() > 0) {    
            baseSchedule = listOfSchedules.get(0);
            activeSchedule = listOfSchedules.get(0);
            Set<Id> idsToIgnore = new Set<Id>();
            
            Map<String, Boolean> scheduleLimitResults = restServiceBulk.verifyLimitsReachedByLocationIndividually(getServiceTypeVersionFromMappingUsingName(), this.mLocation.lat, this.mLocation.lng);
            
            // Add check for the yearly and monthly limits on the schedules. Call func from Core Service.
            if (scheduleLimitResults != null && !scheduleLimitResults.get('month') && !scheduleLimitResults.get('year')) {
                System.debug('----> [findSchedulableDate] Limits not reached. Continuing...');
                System.debug('----> [findSchedulableDate] stv.Service_Type__r.Dupe_Detection: ' + (getServiceTypeVersionFromMappingUsingName()).Incap311__Service_Type__r.Incap311__Schedule_Duplicate_Detection__c);
                System.debug('----> [findSchedulableDate] Lat and Lng: [' + this.mLocation.lat + ', ' + this.mLocation.lng + ']');
                
                if (restServiceBulk.verifyDuplicateScheduleByLocation(getServiceTypeVersionFromMappingUsingName(), this.mLocation.lat, this.mLocation.lng)) {
                    for (Incap311__Schedule__c sch : listOfSchedules) {
                        idsToIgnore.add(sch.Id);
                    }
                    
                    if(activeSchedule.Incap311__Schedule_Override_Date__c != null) {
                        System.debug('----> [findSchedulableDate] Schedule date override detected. Processing...');
                        // Grab the schedule as per the override date and sr type. 
                        List<Incap311__Schedule__c> asList = restServiceBulk.getScheduleByOverrideDate(activeSchedule);
                        
                        // Only apply the active schedule if there is a override schedule in place for the type and zone. 
                        if (asList.size() > 0) {
                            activeSchedule = asList.get(0);
                        }
                    }
                    
                    System.debug('----> [findSchedulableDate] Obtaining business hours for selected service type...');
                    String busniessLikeQueryStr = stv.Incap311__Service_Type__r.Incap311__Service_Type_Code__c + '-SCH';
                    List<BusinessHours> bhList = [SELECT Id FROM BusinessHours WHERE IsActive = true AND Name = :busniessLikeQueryStr];
                    BusinessHours bh = bhList.size() > 0 ? bhList.get(0) : null;
                    System.debug('----> [findSchedulableDate] Business Hours ' + (bh != null ? 'found' : 'unavailable') + '. Processing...');
                    
                    if (bh != null) {
                      System.debug('----> [findSchedulableDate] Schedue date is within Business Hours: ' + BusinessHours.isWithin(bh.Id, Datetime.now()));
                    }
                    
                    // Check current found schedule capacity AND business hours. If either is triggered then look for next available. 
                    System.debug('----> [findSchedulableDate] Schedule found. Verifying capacity and business hours...');
                    if (!restServiceBulk.verifyAvailablityByScheduleType(activeSchedule, Integer.valueOf(numOfItems)) || (bh != null && stv.Incap311__Service_Type__r.Incap311__Enable_Scheduling_Hours__c && !BusinessHours.isWithin(bh.Id, Datetime.now()))) {
                        activeSchedule = null;
                        System.debug('----> [findSchedulableDate] Active schedule does NOT contain capacity to fill request OR is outside of today\'s business hours. Searching for next available...');
                        // If active schedule doesn't have room then we need to search for one that does. 
                        // This schedule we need to find must be within the original day of the week. NOT THE OVERRIDES!
                        listOfSchedules = restServiceBulk.getNextAvailableScheduledDates(getServiceTypeIdFromMappingUsingName(), getZoneFromAddress(), 50, false, dotw, idsToIgnore, Integer.valueOf(stv.Incap311__Service_Type__r.Incap311__Schedule_After_Days__c));
                        System.debug('----> [findSchedulableDate] Found new schedule dates available. Processing...');
                        System.debug('----> [findSchedulableDate] New potential schedules: ' + listOfSchedules);
                        
                        for (Incap311__Schedule__c sch : listOfSchedules) {
                            Incap311__Schedule__c tempActiveSch = sch;
                            
                            if (sch.Incap311__Schedule_Override_Date__c != null) {
                                System.debug('----> [findSchedulableDate] Schedule override detected. Validating override values...');
                                List<Incap311__Schedule__c> tempActiveSchList = restServiceBulk.getScheduleByOverrideDate(tempActiveSch);
                                
                                // Only apply the active schedule if there is a override schedule in place for the type and zone. 
                                if (tempActiveSchList.size() > 0) {
                                    tempActiveSch = tempActiveSchList.get(0);
                                } else {
                                    idsToIgnore.add(tempActiveSch.Id);
                                    continue;
                                }
                            }
                            System.debug('----> [findSchedulableDate] Checking potential schedule capacity: ' + tempActiveSch);
                            System.debug('----> [findSchedulableDate] Portentail schedule.Service_Type__r.Daily_Request_Limit__c: ' + tempActiveSch.Incap311__Service_Type__r.Incap311__Daily_Request_Limit__c);
                            System.debug('----> [findSchedulableDate] Portentail schedule.Capacity__c: ' + tempActiveSch.Incap311__Capacity__c);
                            System.debug('----> [findSchedulableDate] Number of items to process into schedulable: ' + Integer.valueOf(numOfItems));
                            System.debug('----> [findSchedulableDate] Capacity check result: ' + restServiceBulk.verifyAvailablityByScheduleType(tempActiveSch, Integer.valueOf(numOfItems)));
                            if (restServiceBulk.verifyAvailablityByScheduleType(tempActiveSch, Integer.valueOf(numOfItems))) {
                                System.debug('----> [findSchedulableDate] Found available schedule WITH capacity to spare. Sending to user...');
                                activeSchedule = tempActiveSch;
                                break;
                            }
                            System.debug('----> [findSchedulableDate] Adding current schedule id to the ingore list.');
                            idsToIgnore.add(tempActiveSch.Id);
                        }
                    }
                } else {
                    baseSchedule = null;
                    activeSchedule = null;
                    this.mSaveEnabled = false;
                    System.debug('----> [Console311_Section_BulkDatePicker] Duplicate Detection is active. Duplicate found and not allowed. Denying request. ');
                    this.mScheduleErrorMsg = 'Scheduled request detected for this location. Duplicates are not allowed for address at this time using this service type.';  
                }
            } else {
                baseSchedule = null;
                activeSchedule = null;
                this.mSaveEnabled = false;
                System.debug('----> [findSchedulableDate] Unable to obtain Schedule. Limits for Month or Year have been met.');
                this.mScheduleErrorMsg = 'This location is unable to be serviced at this time. Please try again later.';
                
                if (scheduleLimitResults != null) {
                    String limitReachedStr = scheduleLimitResults.get('month') ? 'monthly' : 'yearly';
                    this.mScheduleErrorMsg = 'This location has reached its ' + limitReachedStr + ' limit and is unable to create further schedules.';
                }
                // Limits reached. Throw error and return.
            }
        } else {
            System.debug('----> [findSchedulableDate] No schedules available for the given zone and/or generic.');
            this.mScheduleErrorMsg = 'No schedules are available at this time for this location.';
        }
        System.debug('----> [findSchedulableDate] Saving active schedule to this.scheduleToPresentList: ' + activeSchedule);
        this.scheduleToPresentList = new List<Incap311__Schedule__c> { activeSchedule };
            }
    
    public Case getActivityParentCase() {
        if (this.mActParentCaseNum != null) {
            return restServiceRequest.getServiceRequest(this.mActParentCaseNum);
        }
        return null;
    }
    
    /* ----------- GETTERS FOR CONSOLE CONFIG --------------- */
    
    public List<Console311_Wrap_Config> getOrganizationConfig() {
        List<Console311_Wrap_Config> configList = new List<Console311_Wrap_Config>();
        
        for (Incap311Console__Console_311_Layout_Setting__mdt config : this.mConsoleLayoutConfig) {
            if (config.DeveloperName.containsIgnoreCase('organization')) {
                configList.add(new Console311_Wrap_Config(config.DeveloperName, JSON.serialize(config), config.QualifiedApiName));
            }
        }
        System.debug('----> ConfigList: ' + configList);
        return configList;
    }
    
    public List<Console311_Wrap_Config> getContactConfigs() {
        List<Console311_Wrap_Config> configList = new List<Console311_Wrap_Config>();
        
        for (Incap311Console__Console_311_Layout_Setting__mdt config : this.mConsoleLayoutConfig) {
            if (config.DeveloperName.containsIgnoreCase('contact')) {
                configList.add(new Console311_Wrap_Config(config.DeveloperName, JSON.serialize(config), config.QualifiedApiName));
            }
        }
        System.debug('----> ConfigList: ' + configList);
        return configList;
    }
    
    public void clearServiceType() {
        this.mActiveServiceType = null;
        //this.mSubLocation = null;
        //this.mLocation = null;
        this.mKnowledgeKeyword = null;            
        this.mTypeActiveStatus = null;
        //this.mActiveOrigin = null;
        this.mActiveTypeVersion = null;         
        this.recommendations = null;
        this.mFNQuestionAnswerListBackup = new List<Console311_Wrap_FlexnoteQuestionAnswer>();
        this.mFNQuestionAnswerList = new List<Console311_Wrap_FlexnoteQuestionAnswer>();
        // Dist variables.
        this.mDistMap = null;
        this.mSelectedDistribution = null;
        this.mDistNameVsAccountName = '';
        this.mDistributionListStr = '';
        this.mCordinatorListStr = '';
    }
    
    /* ----------- CLASSES -------------- */
    
    public class ServiceRequestWrapper {
        public Case c { get; set; }
        public Contact contact { get; set; }
        public List<ServiceQuestionWrapper> serviceQuestions { get; set; }
        public Boolean shouldSetDupe { get; set; } 
        public Incap311__Schedule__c schedule { get; set; }    
        public AdditionalInfo ai { get; set; }
        public Incap311__Service_Type_Version__c stv { get; set;}
        public Account account { get; set; }
        
        
        public ServiceRequestWrapper() {}
        
        public Boolean isValid() {
            return (this.c != null && this.contact != null && this.serviceQuestions != null);
        }
        
        public void populateSchduleable() {
            Incap311.Base311_Service_Bulk restServiceBulk = new Incap311.Base311_Service_Bulk();
            System.debug('----> Attempting to populateSchduleable');
            if (this.schedule != null && this.schedule.Id != null) {
                System.debug('----> Requesting Schedule');
                this.schedule = restServiceBulk.getSchedule(this.schedule.Id);
            }
        }
    }
    
    public class AdditionalInfo {
        public String distributionList { get; set; }
        public String coordinatorList { get; set; } 
        public String distUpdateNotes { get; set; }
    }
    
    public class ServiceQuestionWrapper {
        public String mSRTypeVQuestionName { get; set; }
        public String mDataType { get; set; }
        public Incap311__Service_Question__c question { get; set; }
        
        public ServiceQuestionWrapper() {}
    }
}