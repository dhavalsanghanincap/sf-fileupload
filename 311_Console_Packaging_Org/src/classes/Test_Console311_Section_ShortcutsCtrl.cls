@isTest
public class Test_Console311_Section_ShortcutsCtrl {

    @isTest static void testConstructor() {
    	Console311_Section_ShortcutsCtrl ctrl = new Console311_Section_ShortcutsCtrl();
        system.assertEquals(1, (ctrl.mShortcuts).size());
    }
}