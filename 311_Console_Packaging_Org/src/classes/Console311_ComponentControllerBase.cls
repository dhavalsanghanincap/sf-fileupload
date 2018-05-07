public with sharing virtual class Console311_ComponentControllerBase {

    public String IndexValue { get; set; }

  public String key { get;
    set{
      if(value != null){
         Key  = value;
         if(pageController != null)
            pageController.setComponentControllerMap(Key, this);
      }
    }
  }

  public Console311_CaseController pageController { get;
    set {
      if (value != null) {
        pageController = value;
        pageController.setComponentController(this);
      }
    }
  }
}