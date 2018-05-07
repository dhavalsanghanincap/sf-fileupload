@isTest
public class Test_Base311_PatchValue {

    @isTest
    static void testFromBody() {
        RestContext.request = new RestRequest();
        RestContext.request.requestBody = Blob.valueOf('{ "thing": { "other": 1 } }');
        
        Base311_PatchValue pv = Base311_PatchValue.fromBody('thing', 'other');
        System.assert(pv.isSet);
        System.assertEquals(pv.value, 1);
    }
    @isTest
    static void testFromBodyNoRoot() {
        RestContext.request = new RestRequest();
        RestContext.request.requestBody = Blob.valueOf('{ }');
        
        Base311_PatchValue pv = Base311_PatchValue.fromBody('thing', 'other');
        System.assert(!pv.isSet);
    }
    
    @isTest
    static void testFromBodyNoVal() {
        RestContext.request = new RestRequest();
        RestContext.request.requestBody = Blob.valueOf('{  "thing": { } }');
        
        Base311_PatchValue pv = Base311_PatchValue.fromBody('thing', 'other');
        System.assert(!pv.isSet);
    }
}