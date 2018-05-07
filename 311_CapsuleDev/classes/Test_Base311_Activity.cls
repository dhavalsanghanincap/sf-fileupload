@isTest
public class Test_Base311_Activity {

    @isTest
    static void testThrowErrors() {
        
        Base311_Activity ra = new Base311_Activity('123', 'status', '123', '123');
        ra.errors.add('test');
        try{ 
            ra.throwErrors();
            System.assert(false);
        } catch(Base311_Exceptions.UnsupportedException e) {
            System.assert(true);
        }
    }

    @isTest
    static void testValidate() {
        Base311_Activity ra = new Base311_Activity('123', 'status', '123', '123');
        ra.validate();
        System.assertEquals(ra.errors.size(), 2);
    }
    
    @isTest
    static void TestConstructor() {
        Base311_Activity ra = new Base311_Activity('123', 'status', '123', '123');
        System.assertEquals(ra.code, '123');
    }
    
    @isTest
    static void testFromMap() {
        Map<String, String> m = new Map<String, String>{
          'code' => 'STQ-123',
          'status' => 'Open',
          'comment' => 'test'
        };
        
        Base311_Activity ra = Base311_Activity.fromMap(m);
        System.assertEquals(ra.code, 'STQ-123');
        System.assertEquals(ra.status, 'Open');
        System.assertEquals(ra.comment, 'test');
    }

    @isTest
    static void testFromList() {
        List<Map<String, String>> m = new List<Map<String, String>>();
        m.add(new Map<String, String>{
          'code' => 'STQ-123',
          'status' => 'Open',
          'comment' => 'test'
        });
        
        List<Base311_Activity> ras = Base311_Activity.fromList(m);
        Base311_Activity ra = ras[0];
        System.assertEquals(ra.code, 'STQ-123');
        System.assertEquals(ra.status, 'Open');
        System.assertEquals(ra.comment, 'test');
    }
}