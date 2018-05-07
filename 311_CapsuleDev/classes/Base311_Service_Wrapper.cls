/**
* @author 
* @date 
* @group 
* @group-content
* @description 
*/
@RestResource(urlMapping= '/services') 
global class Base311_Service_Wrapper {
   
    private static Base311_Service_Request bsr = new Base311_Service_Request();
    private static Base311_Service_ServiceType bsst = new Base311_Service_ServiceType();
    private static Base311_Service_Knowledge sk = new Base311_Service_Knowledge();
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    private static Object serializeParam(Object item, Type t) {
        try {
            return JSON.deserialize(JSON.serialize(item), t);
        }
        catch (Exception e) {
            System.debug(e);
            return e;
        }
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */ 
    @RemoteAction
    global static Object handleRemote(String service, String method, String params) { 
        List<Object> finalParams = (List<Object>) JSON.deserializeUntyped(params);
        return Base311_Service_Wrapper.mapServiceMethod(service, method, finalParams);
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    @HttpPost
    global static void handleRest() {
        String service = Base311_Helper.getStringBodyParam('service');
        String method = Base311_Helper.getStringBodyParam('method');
        List<Object> params = (List<Object>) JSON.deserializeUntyped(Base311_Helper.getStringBodyParam('data'));
        Object res = Base311_Service_Wrapper.mapServiceMethod(service, method, params);
        
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(res));
        RestContext.response.headers.put('Content-Type', 'application/json');
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    private static Object mapServiceMethod(String service, String method, List<Object> params) {
        if(service == 'Base311_LocationSearch') {
            return mapLocationMethod(method, params);
        }
        
        if(service == 'Base311_Service_ServiceType') {
            return mapServiceTypeMethod(method, params);
        }
        
        if(service == 'Base311_Service_Request') {
            return mapRequestMethod(method, params);
        }
        
        if(service == 'Base311_DuplicateRequestsUtil') {
            return mapDuplicateMethod(method, params);
        }
        
        if(service == 'Base311_AccountAndContactUtils') {
            return mapContactMethod(method, params);
        }
        
        if(service == 'Base311_Service_Knowledge') {
            return mapKnowledgeMethod(method, params);
        }
        
        if(service == 'Base311_Transfer_Case') {
            return mapTransferMethod(method, params);
        }
        
        throw new Base311_Exceptions.UnsupportedException('Unknown service ' + service);
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    private static Object mapKnowledgeMethod(String method, List<Object> params) {
        
        if(method == 'searchArticles') {
            return sk.searchArticles((String) params[0]);
        }
        
        throw new Base311_Exceptions.UnsupportedException('Unknown Base311_Service_Knowledge method ' + method);
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    private static Object mapServiceTypeMethod(String method, List<Object> params) {
        
        if(method == 'getActiveServiceTypes') {
            return bsst.getActiveServiceTypes(Boolean.valueOf(params[0]));
        }
        
        if(method == 'getServiceType') {
            return bsst.getServiceType((String) params[0], Boolean.valueOf(params[1]))  ;
        }
        
        if(method == 'getServiceTypeByCode') {
            return bsst.getActiveServiceType((String) params[0], Boolean.valueOf(params[1]))  ;
        }
        
        throw new Base311_Exceptions.UnsupportedException('Unknown Base311_Service_ServiceType method ' + method);
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    private static Object mapDuplicateMethod(String method, List<Object> params) {
        if(method == 'getDuplicateServiceRequests') {
            return Base311_DuplicateRequestsUtil.getDuplicateServiceRequests(
                (String) params[0], (String) params[1], (String) params[2], (String) params[3]
            );
        }
        
        if (method == 'getDuplicateServiceRequestsByServiceCode') {
            return Base311_DuplicateRequestsUtil.getDuplicateServiceRequestsByServiceCode(
                (String) params[0], (String) params[1], (String) params[2], (String) params[3]
            );
        }
        
        throw new Base311_Exceptions.UnsupportedException('Unknown Base311_DuplicateRequestsUtil method ' + method);
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    private static Object mapRequestMethod(String method, List<Object> params) { 
        if(method == 'createServiceRequest') {
            Base311_Case ca = (Base311_Case) serializeParam(params[0], Base311_Case.class);
            Base311_Location loc = (Base311_Location) serializeParam(params[1], Base311_Location.class);
            Base311_Contact con = (Base311_Contact) serializeParam(params[2], Base311_Contact.class);
            Account acc = params.size() >= 5 ? (Account) serializeParam(params[4], Account.class) : null;
            return bsr.createServiceRequest(ca.fetchServiceType(), loc, con, acc, Base311_Attribute.fromMap((Map<String, Object>) params[3]));
        }
        
        if(method == 'getContactRequests') {
            return bsr.getContactRequests(String.valueOf(params[0]));
        }
        
        if(method == 'getSimilarCases') {
            return bsr.getSimilarCases(String.valueOf(params[0]));
        }
        
        if(method == 'getServiceRequest') {
            return bsr.getServiceRequest(String.valueOf(params[0]));
        }

        if (method == 'searchServiceRequests') {
            return bsr.searchServiceRequests(String.valueOf(params[0]));
        }
        
        if(method == 'updateServiceRequest') {
            Base311_Case ca = (Base311_Case) serializeParam(params[0], Base311_Case.class);
            Base311_Location loc = (Base311_Location) serializeParam(params[1], Base311_Location.class);
            Base311_Contact con = (Base311_Contact) serializeParam(params[2], Base311_Contact.class);
            Account acc = params.size() >= 6 ? (Account) serializeParam(params[5], Account.class) : null;
            return bsr.updateServiceRequest(ca, loc, Base311_Attribute.fromMap((Map<String, Object>) params[3]), con, acc, Base311_Activity.fromList((List<Object>) params[4]));
        }
        
        throw new Base311_Exceptions.UnsupportedException('Unknown Base311_Service_Request method ' + method);
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    private static Object mapContactMethod(String method, List<Object> params) {
        if(method == 'findAccountByName') {
            return Base311_AccountAndContactUtils.findAccountByName((String) params[0]);
        }

        if (method == 'searchAccounts') {
            return Base311_AccountAndContactUtils.searchAccounts((String) params[0]);
        }
        
        if(method == 'findContact') {
            return Base311_AccountAndContactUtils.findContact(
                (String) params[0], (String) params[1], (String) params[2], (String) params[3]
            );
        }
        
        if(method == 'searchContacts') {
            return Base311_AccountAndContactUtils.searchContacts(
                (String) params[0]
            );
        }
        
        throw new Base311_Exceptions.UnsupportedException('Unknown Base311_AccountAndContactUtils method ' + method);
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    private static Object mapLocationMethod(String method, List<Object> params) {
        if(method == 'getLocationsByAddress') {
            return Base311_LocationSearch.getLocationsByAddress((String) params[0]);
        }
    
        if(method == 'getLocationsByLatLng') {
            return Base311_LocationSearch.getLocationsByLatLng(Double.valueOf(params[0]), Double.valueOf(params[1]));
        }
    
    
        throw new Base311_Exceptions.UnsupportedException('Unknown Base311_LocationSearch method ' + method);
    }
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    private static Object mapTransferMethod(String method, List<Object> params) {
        if(method == 'transferCase') {
            Case updatedCase = (Case) serializeParam(params[0], Case.class);
            Case originalCase = (Case) serializeParam(params[1], Case.class);
            Map<String, Object> answers = (Map<String, Object>) params[2];
            
            System.Debug('updatedCase' + updatedCase);
            System.Debug('originalCase' + originalCase);
            System.Debug('answers' + answers);
            return Base311_Transfer_Case.transferCase(updatedCase, originalCase, answers);
        }
        
        if (method == 'getTransferTypes') {
            return Base311_Transfer_Case.getActiveServiceTypes(Id.valueOf((String) params[0]));
        }
    
    
        throw new Base311_Exceptions.UnsupportedException('Unknown Base311_Transfer_Case method ' + method);
    }
}