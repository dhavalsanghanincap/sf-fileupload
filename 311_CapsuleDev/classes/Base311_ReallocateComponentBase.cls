/**
* @author 
* @date 
* @group 
* @group-content
* @description 
*/
/*Virtual class to be used in reallocateController
Developer Name : Vrajesh Sheth
Date : 05/01/2017
*/

Global with sharing virtual class Base311_ReallocateComponentBase {
    Global Base311_ReallocatePageCtrlBase ReallocatePageCtrl { 
        get; 
        set {
            if (value != null) {
                ReallocatePageCtrl = value;
                ReallocatePageCtrl.setComponentController(this);
            }
        }
    }
}