/**
* @author David Evans 
* @date 6/2/2017
* @group 
* @group-content
* @description Class to have methods related to Salesforce schema
*/

public class Base311_Schema
{   
    Static String[] specailRelationships = new String[]{'Contact'};
    Static set<String> specailRelationshipsset = new Set<String>(specailRelationships);
    /**
    * @description Method to know if the field exists on sObject
    * @param objName string sObjectName
    * @param fieldName API field name
    * @return True or False boolean
    * @example
    */
    public static boolean doesFieldExist(String objName, string fieldName)
    {
        SObject so = getSobject(objName);
        return  doesFieldExist(so, fieldName);
    }

    /**
    * @description Method to know if the field exists on sObject
    * @param so is Sobject
    * @param fieldName API field name
    * @return True or False boolean
    * @example
    */
    public static boolean doesFieldExist(Sobject so, string fieldName)
    {
       try {  
            List<String> parts = fieldName.split('\\.');

            if(parts.size() == 1) {
                return so.getSobjectType().getDescribe().fields.getMap().containsKey(fieldName.toLowerCase()) || so.getSobjectType().getDescribe().fields.getMap().containsKey('Incap311__'+fieldName.toLowerCase());
            }

            String objName = parts[0];

            parts.remove(0);
           
           if(specailRelationshipsset.contains(objName)){
               return true;
           }

            return doesFieldExist(getReferenceTo(so,objName) , String.join(parts, '.'));
        }
       catch(Exception ex) {}

        return false;
    }
    
    
    public static Sobject getReferenceTo(Sobject so, String fieldName){
        Map<String, Schema.SObjectField> fieldMap= so.getSobjectType().getDescribe().fields.getMap();
        for(Schema.SObjectField fields : fieldMap.Values()){
            SYstem.debug(fields.getDescribe().getName());
        }
        
        System.debug('FIELDNAME    '+fieldName.replace('__r','__c'));
        Schema.SObjectField sobjectField = fieldMap.get(fieldName.replace('__r','__c'));
        if(sobjectField == null){
            sobjectField = fieldMap.get('Incap311__'+fieldName.replace('__r','__c'));
        }
        Schema.DescribeFieldResult describeFIeld = sobjectField.getDescribe();
        list<Schema.sObjectType> refrenceTos = describeFIeld.getReferenceTo();
        
        return refrenceTos[0].newSObject();
    }

    /**
    * @description Method to get sobject from objectname
    * @param objectName string objectname
    * @return sObject
    * @example
    */
    public static Sobject getSobject(String objectName){
        System.debug('object Name '+objectName);
        return Schema.getGlobalDescribe().get(objectName).newSObject();
    }
}