/**
* @author 
* @date 
* @group 
* @group-content
* @description 
*/
public abstract class Base311_Object {

    public List<String> errors = new List<String>();
    
    protected abstract void validation();

    public Boolean isValid() {
        this.validate();
        
        return this.errors.size() == 0;
    }

    public Base311_Object validate() {
        this.validation();
        
        return this;
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    public void throwErrors() {
        if(this.errors.size() > 0) { 
            Base311_Exceptions.UnsupportedException e = new Base311_Exceptions.UnsupportedException(this.errors);
            e.setMessage(String.join(errors, ', '));
            throw e;
        }
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    protected void addError(String message) {
        this.errors.add(message);
    }
}