public with sharing class BulkCloseController {
  
  //temp case record to show case related field
  public Case caseRecord{get;set;}
  //Comment text
  public String commentText{get;set;} 

  //Caselist
  public list<case> caseList{get;set;}
  List<Id> lstCaseIds = null;
  public BulkCloseController() {
    caseRecord = new Case(); 
    caseList = new list<case>();
    String cases  =  ApexPages.currentPage().getParameters().get('selectedId'); 
    //Create a set of case Ids
       Set<Id> SR  =  new Set<Id>();
       lstCaseIds  =  cases.split(',');
        SR.addAll(lstCaseIds);
        caseList = querySelectedCases(lstCaseIds);
  }

  //Method to query all the selected service request
  public list<Case> querySelectedCases(list<id> caseIdList){
    return [Select id
            ,CaseNumber
            ,Reason
            ,Subject
            ,Status
            ,isClosed
        FROM Case
        WHERE id in :caseIdList];
        
  }

  //Method to Close the case
  public pageReference closeCase(){
    list<CaseComment> caseCommentList = new list<CaseComment>();
    for(Case c : caseList){
      c.Status = 'Closed';
      c.Reason = caseRecord.Reason;
      caseCommentList.add(new CaseComment(ParentId = c.id,CommentBody = commentText));
    }

    //Update the case recrods
    Database.update(caseList,false);
    //Insert the case Comment
    Database.insert(caseCommentList,false);
    caseList = querySelectedCases(lstCaseIds);
    return null;
  }

  
}