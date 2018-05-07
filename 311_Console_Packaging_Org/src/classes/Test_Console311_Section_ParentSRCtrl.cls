@isTest
public class Test_Console311_Section_ParentSRCtrl {
	@isTest static void testgetParentPageConfig() {
        Console311_Section_ParentSRCtrl ctrl = new Console311_Section_ParentSRCtrl();
        Incap311Console__Console_311_Layout_Setting__mdt ParentPageConfig = ctrl.getParentPageConfig();
        system.assertNotEquals(null, ParentPageConfig);
    }
}