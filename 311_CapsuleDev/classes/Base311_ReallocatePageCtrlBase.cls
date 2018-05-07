/**
*@author Vrajesh Sheth
*@description Virtual class which will be used with pagecontroller where you want to use reallocate component
*@group
*@date 05/01/2017
**/
Global with sharing virtual class Base311_ReallocatePageCtrlBase {
    
    private Base311_ReallocateComponentBase ReallocateComponentCtrl;
    
    /**
    * @description virtual gettter method to get Base311_ReallocateComponentBase
    * @return Base311_ReallocateComponentBase
    * @example
    */
    Global virtual Base311_ReallocateComponentBase getreallocateComponentCtrl() {
        return ReallocateComponentCtrl;
    }
    
    /**
    * @description virtual setter method 
    * @param Base311_ReallocateComponentBase compController
    * @example
    */
    Global virtual void setComponentController(Base311_ReallocateComponentBase compController) {
        ReallocateComponentCtrl = compController;
    }
    
    /**
    * @description 
    * @param 
    * @return current Base311_ReallocatePageCtrlBase
    * @example
    */
    Global Base311_ReallocatePageCtrlBase getThis() {
        return this;
    }
}