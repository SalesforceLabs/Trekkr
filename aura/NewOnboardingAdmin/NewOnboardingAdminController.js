({
    doInit : function(c) {
        var action = c.get("c.getUser");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                c.set('v.users',response.getReturnValue());
            }
            else if (state === "INCOMPLETE") {
                
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
    },
    assignAdminRoleToUsers : function(c,e,h){
        c.set('v.showConfirmationDialog',true); 
        c.set('v.ConfirmationDialogMessage',
              'You are adding selected users as Trekkr admins which will assign Permission to the users. '+
              'Please confirm if you want to proceed.'
             );
    },
    onClickConfirm_ConfirmationDialog : function(component, event, helper){
        component.set('v.showConfirmationDialog',false);   
        var action = component.get("c.assignAdminRole");
        action.setParams({ userIds : component.get("v.selectedUsers") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.clearMultipicklist',true);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Users has been added as Trekkr app admins",
                    "type" : "success"
                });
                toastEvent.fire();
            }
            else if (state === "INCOMPLETE") {
                
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
    },
    onClickCancel_ConfirmationDialog : function(c,e,h){
        c.set('v.showConfirmationDialog',false);   
    }
})