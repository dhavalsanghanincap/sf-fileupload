/*
 * Block comments with details of changes
 */
public virtual with sharing class Console311_Wrap_QuestionAnswer
{
    public Console311_Wrap_QuestionAnswer()
    {
        
    }

  public Map<String,Object> qAMap = new Map<String,Object>();


  public virtual Object getCurrentAnswer() {
    return null;
  }

  public virtual String getSelectedItemsJSON() {
    Object ans = this.getCurrentAnswer();

    if(ans == null) {
        return '';
    }
    return JSON.serialize(ans);
  }

  public virtual Integer getQuestionOrderRank() {
    return 99;
  }
    
  public virtual List<Incap311.Base311_QuestionAnswer> getActivePicklist(){
      //return  Incap311.Base311_Dependencies.getActivePicklist(this.stvQuestion, qAMap);
      return null;
  }

  public virtual List<Incap311.Base311_QuestionAnswer> getPicklistOptions() {
    List<Incap311.Base311_QuestionAnswer> qaList = getActivePicklist();

    System.debug('getPicklistOptions:qAMap ' + qAMap);
      
    Object ans = getCurrentAnswer();

    if(qaList != null && ans != null && ans instanceof String) {
      for(Incap311.Base311_QuestionAnswer qa : qaList) {
        if(qa.value == ans) {
          qa.isSelected = true;
        }
      }
    }

    if(ans != null && ans instanceof List<Object>) {
      for(Incap311.Base311_QuestionAnswer qa : qaList) {
        for(Object o : (List<Object>) ans) {
          if(qa.value == String.valueOf(o)) {
            qa.isSelected = true;
          }
        }
      }
    }
      
    return qaList;
  }

  public virtual boolean validatePicklistOption(String testValue) {
    List<Incap311.Base311_QuestionAnswer> picklist = this.getPicklistOptions();
    
    if(picklist == null) {
        return true;
    }  
      
    for(Incap311.Base311_QuestionAnswer question : picklist ){
      if(question.value.equals(testValue)){
        return true;
      }
    }
    return false;
  }
    
    public virtual sobject getQuestion(){
        return null;
    }
    
    public virtual String getQuestionCode(){
        return null;
    }
    
   
}