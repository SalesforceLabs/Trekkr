({
    doInit : function(component, event, helper) {
        var action = component.get("c.getMentorDetails");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.mentee",response.getReturnValue());
                
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
    onClickCall : function(c,e,h){
        var phoneNo = c.get('v.mentee').Mentor__r.MobilePhone;
        window.location.href = 'tel:'+phoneNo;
    },
    onClickEmail : function(c,e,h){
        var email = c.get('v.mentee').Mentor__r.Email;
        window.location.href = 'mailto:'+email;        
    },
    hideValueEditSection : function(c,e,h){
        var valueEditSection = c.find('valueEditSection');
        $A.util.addClass(valueEditSection,'slds-hide');
        $A.util.removeClass(valueEditSection,'slds-show');
        var saveBtnDiv = c.find('saveBtnDiv');
        $A.util.addClass(saveBtnDiv,'slds-show');
        $A.util.removeClass(saveBtnDiv,'slds-hide');
    },
    showValueEditSection : function(c,e,h){
        var valueEditSection = c.find('valueEditSection');
        $A.util.addClass(valueEditSection,'slds-show');
        $A.util.removeClass(valueEditSection,'slds-hide');
    },
    hideVisionEditSection : function(c,e,h){
        var visionEditSection = c.find('visionEditSection');
        $A.util.addClass(visionEditSection,'slds-hide');
        $A.util.removeClass(visionEditSection,'slds-show');
        var saveBtnDiv = c.find('saveBtnDiv');
        $A.util.addClass(saveBtnDiv,'slds-show');
        $A.util.removeClass(saveBtnDiv,'slds-hide');
    },
    showVisionEditSection : function(c,e,h){
        var visionEditSection = c.find('visionEditSection');
        $A.util.addClass(visionEditSection,'slds-show');
        $A.util.removeClass(visionEditSection,'slds-hide');
    },
    onClickSave : function(c,e,h){
        var action = c.get("c.updateVisionAndValues");
        action.setParams({ 
            values : c.get("v.mentee").Values__c,
            vision : c.get("v.mentee").Vision__c,
            userId : c.get("v.mentee").Id 
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if(response.getReturnValue() == true){
                    var saveBtnDiv = c.find('saveBtnDiv');
                    $A.util.removeClass(saveBtnDiv,'slds-show');
                    $A.util.addClass(saveBtnDiv,'slds-hide');
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "type" : "success",
                        "message": "Your Vision and Values has been updated"
                    });
                    toastEvent.fire();
                }else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Oops!",
                        "type" : "error",
                        "message": "Due to some issue, we can\'t process your request."
                    });
                    toastEvent.fire();
                }
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
    }
})