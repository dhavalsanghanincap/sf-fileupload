@isTest
public class Test_Base311_Security {
    
   	/*
   	 *  SF laughably does not allow us to test the fail case for these
   	 *
     */
    @isTest
    static void testAreCreateable() {
        Case c = new Case();
        Boolean result = Base311_Security.areCreateable(c.getSObjectType(), new List<String>{ 'Status' });
        
        System.assert(result);
    }
    
    @isTest
    static void testAreUpdateable() {
        Case c = new Case();
        Boolean result = Base311_Security.areUpdateable(c.getSObjectType(), new List<String>{ 'Status' });
        
        System.assert(result);
    }
    
    @isTest
    static void testAreAccessible() {
        Case c = new Case();
        Boolean result = Base311_Security.areAccessible(c.getSObjectType(), new List<String>{ 'CaseNumber' });
        
        System.assert(result);
    }
}