global with sharing virtual class Console311_ControllerBase {
  private Console311_ComponentControllerBase compCtrl;
  private Map<String, Console311_ComponentControllerBase> componentControllerMap = new Map<String, Console311_ComponentControllerBase>();

  public Console311_ControllerBase() {

  }

  public virtual Console311_ComponentControllerBase getComponentController() {
    return compCtrl;
  }

  public virtual Map<String, Console311_ComponentControllerBase> getComponentControllerMap(){
      System.debug('component map ' + componentControllerMap);
    return componentControllerMap;
  }

  public virtual void setComponentControllerMap(String key, Console311_ComponentControllerBase compController){
    componentControllerMap.put(key,compController);
  }

  public virtual void setComponentController(Console311_ComponentControllerBase compController) {
    compCtrl = compController;
  }
}