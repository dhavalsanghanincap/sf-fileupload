/**
* @author John Benson 
* @date  10/3/2016
* @group 
* @group-content
* @description 
*/
global class Base311_Exceptions {
    global class NotFoundException extends Exception {}
    global class ServerException extends Exception {}
    global class SecurityException extends Exception {}
    global class ValidationException extends Exception {}
    
    global class UnsupportedException extends Exception {
        public List<String> errors = null;
        
        global UnsupportedException(List<String> errors) {
            this.errors = errors;
            this.setMessage(null);
        }
    }
}