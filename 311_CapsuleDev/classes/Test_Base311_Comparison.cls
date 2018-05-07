@IsTest
public class Test_Base311_Comparison {  

    //updated by SH
    static testmethod void testStringComparsionMethod(){
        Boolean result ;       
        Test.startTest();

        result= Base311_comparison.isValid('test','test', 'eq');                    
        system.assertEquals(true, result); 

        result= Base311_comparison.isValid('test','test', 'neq');                      
        system.assertEquals(false, result);

        result= Base311_comparison.isValid('b','a', 'gt');                    
        system.assertEquals(true, result); 

        result= Base311_comparison.isValid('b','a', 'gte');                   
        system.assertEquals(true, result); 

        result= Base311_comparison.isValid('a','b', 'lt');                    
        system.assertEquals(true, result); 

        result= Base311_comparison.isValid('a','b', 'lte');                   
        system.assertEquals(true, result); 


        Test.stopTest();   
    }

    static testmethod void testNumberComparsionMethod(){
        Boolean result ;       
        Test.startTest();

        result= Base311_comparison.isValid(10.0,10.0, 'eq');                  
        system.assertEquals(true, result); 

        result= Base311_comparison.isValid(10.0,10.0, 'neq');                        
        system.assertEquals(false, result);

        result= Base311_comparison.isValid(14.0,10.0, 'gt');                    
        system.assertEquals(true, result); 

        result= Base311_comparison.isValid(10.0,14.0, 'lt');                   
        system.assertEquals(true, result);

        result= Base311_comparison.isValid(15.0,14.0, 'gte');                    
        system.assertEquals(true, result); 

        result= Base311_comparison.isValid(14.0,14.0, 'lte');                   
        system.assertEquals(true, result); 




        Test.stopTest();   
    }

    static testmethod void testDateComparsionMethod(){
        Boolean result ;

        Date d = date.today();


        Test.startTest();           
        result= Base311_comparison.isValid(d,d, 'equals');                   
        system.assertEquals(true, result); 

        result= Base311_comparison.isValid(d,d, 'not equal to');                     
        system.assertEquals(false, result);

        result= Base311_comparison.isValid(d,date.parse('12/27/2009'), 'Greater Than');                  
        system.assertEquals(true, result); 

        result= Base311_comparison.isValid(d,date.parse('12/27/2009'), 'Less Than');                 
        system.assertEquals(false, result);

        result= Base311_comparison.isValid(d,date.parse('12/27/2009'), 'Greater or Equal');                  
        system.assertEquals(true, result); 

        result= Base311_comparison.isValid(d,date.parse('12/27/2009'), 'Less or Equal');                 
        system.assertEquals(false, result);



        Test.stopTest();    
    }

    static testmethod void testDateTimeComparsionMethod(){
        Boolean result ;

        Contact a = new Contact(LastName='test');
        insert a;

        a =[Select Id,CreatedDate FROM Contact WHERE Id =:a.Id];

        // Datetime d = Datetime.valueOf(string.valueof(a.get('CreatedDate')));
        Datetime d  = DateTime.parse('10/15/2012 11:46 AM');  
        Datetime dt = DateTime.parse('10/15/2011 11:46 AM'); 

        Test.startTest();           
        result= Base311_comparison.isValid(d,d, 'equals');                   
        system.assertEquals(true, result); 

        result= Base311_comparison.isValid(d,d, 'not equal to');                     
        system.assertEquals(false, result);

        result= Base311_comparison.isValid(d,dt, 'Greater Than');                    
        system.assertEquals(true, result); 

        result= Base311_comparison.isValid(d,dt, 'Less Than');                   
        system.assertEquals(false, result);

        result= Base311_comparison.isValid(d,dt, 'Greater or Equal');                    
        system.assertEquals(true, result); 

        result= Base311_comparison.isValid(d,dt, 'Less or Equal');                   
        system.assertEquals(false, result);

        Test.stopTest();    
    }
    static testmethod void testvalidMethod(){
        Boolean result ;
        Test.startTest();  

        result= Base311_comparison.isValid('string','test', 'test','eq');                    
        system.assertEquals(true, result);  


    }

}