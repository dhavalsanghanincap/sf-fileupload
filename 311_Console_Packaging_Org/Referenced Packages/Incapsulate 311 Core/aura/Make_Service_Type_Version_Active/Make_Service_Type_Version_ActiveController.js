({
	makeActive : function(component, event, helper) {
        var action = component.get("c.markSTVAsActive");
        action.setParams({"stvId": component.get("v.recordId") });
        
        action.setCallback(this, function(res) {
            var toastEvent = $A.get("e.force:showToast");
            var result = res.getReturnValue();
            
            toastEvent.setParams({
                "message": (result != null && result.length > 0 ? result : "An unexpected error has occurred")
            });
            
            $A.get("e.force:closeQuickAction").fire();
            toastEvent.fire();
            return; 
        });
        
        $A.enqueueAction(action);
	}
})