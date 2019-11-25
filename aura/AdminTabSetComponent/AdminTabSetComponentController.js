({
    /*doInit : function(component, event, helper) {
        var action = component.get("c.checkManageUserPermissionSet");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var booleanResponse = response.getReturnValue();
                console.log("RESP" + response.getReturnValue());
                if( booleanResponse === false ){
                    var tabSet = component.find("tabSet");
                    $A.util.addClass(tabSet,'slds-hide');
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "mode": "sticky",
                        "type" : "warning",
                        "title": "Restricted Access",
                        "message": "Cannot sign up new Explorers. Make sure you have 'Trekkr - Manager Users' Permission set."
                    });
                    toastEvent.fire();
                }
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            
        });
        $A.enqueueAction(action);
    }*/
})