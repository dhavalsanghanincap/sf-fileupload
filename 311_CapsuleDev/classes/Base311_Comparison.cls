/**
* @author David Evans
* @date 12/27/2016   
* @group util
* @group-content
* @description Utility class with all comparison logic methods
*/
public class Base311_Comparison
{
    /**
    * @description Method to validate the data type
    * @param String dataType
    * @param String value1
    * @param String value2
    * @param String op
    * @return TRUE or FALSE
    * @example
    */
    public static Boolean isValid(String dataType, String value1 , String value2 ,String op){
        boolean result;
        if (dataType == 'integer' || dataType == 'double'){
                    result = isValid(decimal.valueOf(value1),decimal.valueOf(value2),op);                 
                }else if (dataType == 'date'){
                    result = isValid(Date.valueOf(value1), Date.valueOf(value2),op);                     
                }else if (dataType == 'datetime'){
                    result = isValid(DateTime.valueOfGMT(value1), DateTime.valueOfGMT(value2),op);                 
                }//else if (dataType == 'boolean'){
                    
                //}
                else{
                    result = isValid(value1,value2,op);                 
                }  
        return result;
    }
    
    
    /**
    * @description STRING COMPARISONS
    * @param String value1
    * @param String value2
    * @param String op
    * @return TRUE or FALSE
    * @example
    */
    public static Boolean isValid(String value1 , String value2 ,String op ){
        
        if (value1!=null) value1 = value1 .trim();
        if (value2!=null) value2=   value2 .trim();   
       
        if(op.equalsIgnoreCase('eq')){
            return  value1 == value2;  
        }
        if(op.equalsIgnoreCase('neq')){
            return  value1!= value2;
             
        }      
                    
        if(op.equalsIgnoreCase('gt') ){
             return value1 > value2;
         } 
        
        if(op.equalsIgnoreCase('gte') ){
             return value1 >= value2;
         } 
        
        if(op.equalsIgnoreCase('lt') ){
             return value1 < value2;
         } 
        
        if(op.equalsIgnoreCase('lte') ){
             return value1 <= value2;
         }
         return false;

    }
    
    /**
    * @description DECIMAL/NUMBER COMPARISONS
    * @param Decimal value1
    * @param Decimal value2
    * @param String op
    * @return TRUE or FALSE
    * @example
    */
        public static Boolean isValid(Decimal value1 , Decimal value2 ,String op ){

       
        if(op.equalsIgnoreCase('eq')){
            return  value1 == value2;
            
        }
        if(op.equalsIgnoreCase('neq')){
            return  value1 != value2;
             
        }      
                    
        if(op.equalsIgnoreCase('gt') ){
             return value1 > value2;
         } 
        
        if(op.equalsIgnoreCase('gte') ){
             return value1 >= value2;
         } 
        
        if(op.equalsIgnoreCase('lt') ){
             return value1 < value2;
         } 
        
        if(op.equalsIgnoreCase('lte') ){
             return value1 <= value2;
         }   
               
            //other wise it is an invlaid operator on this datatype:-                   
            return false;
        }
        
    /**
    * @description DATE COMPARISONS
    * @param Datetime value1
    * @param Datetime value2
    * @param String op
    * @return TRUE or FALSE
    * @example
    */
    public static Boolean isValid(Date value1 , Date value2 ,String op ){
      
        if(op.equalsIgnoreCase('Equals'))
            return ( value1 == value2 ) ? true : false;
         
        if(op.equalsIgnoreCase('Not Equal To'))
            return ( value1 != value2 ) ? true : false;
         
        if(op.equalsIgnoreCase('Greater Than'))
            return ( value1 > value2 ) ? true : false;
         
        if(op.equalsIgnoreCase('Less Than'))
            return ( value1 < value2 ) ? true : false;
         
        if(op.equalsIgnoreCase('Greater or Equal'))
            return ( value1 >= value2 ) ? true : false;
             
        if(op.equalsIgnoreCase('Less or Equal'))
            return ( value1 <= value2 ) ? true : false;
        
        if(op.equalsIgnoreCase('Is Null'))
             return ( value1 == null) ? true : false;
         
         if(op.equalsIgnoreCase('Is Not Null'))
             return ( value1 != null) ? true: false;    
             
              
        //other wise it is an invlaid operator on this datatype:-                   
        return false;
    }
    
    /**
    * @description DATETIME COMPARISONS
    * @param Datetime value1
    * @param Datetime value2
    * @param String op
    * @return TRUE or FALSE
    * @example
    */
    public static Boolean isValid(Datetime value1 , Datetime value2 ,String op ){
     
        if(op.equalsIgnoreCase('Equals'))
            return ( value1 == value2 ) ? true : false;
         
        if(op.equalsIgnoreCase('Not Equal To'))
            return ( value1 != value2 ) ? true : false;
         
        if(op.equalsIgnoreCase('Greater Than'))
            return ( value1 > value2 ) ? true : false;
         
        if(op.equalsIgnoreCase('Less Than'))
            return ( value1 < value2 ) ? true : false;
        
        if(op.equalsIgnoreCase('Greater or Equal'))
            return ( value1 >= value2 ) ? true : false;
             
        if(op.equalsIgnoreCase('Less or Equal'))
            return ( value1 <= value2 ) ? true : false;
     
        if(op.equalsIgnoreCase('Is Null'))
             return ( value1 == null) ? true : false;
         
         if(op.equalsIgnoreCase('Is Not Null'))
             return ( value1 != null) ? true: false;              
         
             
        //other wise it is an invlaid operator on this datatype:-                   
        return false;
    }
}