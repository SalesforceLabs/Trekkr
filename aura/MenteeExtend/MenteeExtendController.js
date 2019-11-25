({
    doInit : function(component, event, helper) {
        var action = component.get("c.getMenteeUsers");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.menteeUsers",response.getReturnValue());
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
    onClickExtend : function(c,e,h){
        var index = e.currentTarget.id;
        c.set('v.showExtendModal',true);
        var selectedMentee = c.get('v.menteeUsers['+index+']');
        c.set('v.selectedMentee',selectedMentee.userDetail);
        c.set('v.selectedMenteeOnboardingDate',selectedMentee.userDetail.On_boarding_End_Date__c);
    },
    onChangeDate : function(c,e,h){
        var oldOnboardingEndnDate = c.get('v.selectedMenteeOnboardingDate');
        var selectedMentee = c.get('v.selectedMentee');
        var currentValue = selectedMentee.On_boarding_End_Date__c
        if(currentValue < oldOnboardingEndnDate){
            selectedMentee.On_boarding_End_Date__c = oldOnboardingEndnDate;
            c.set('v.selectedMentee',selectedMentee);
            h.showToast('Oops!','Ensure extended Onnboarding date falls after current Onboarding end date','error');
        }
    },
    onClickClose : function(component,event,helper){
        var index = event.currentTarget.id;
        var selectedMentee = component.get('v.menteeUsers['+index+']').userDetail;
        var action = component.get("c.markOnboardingCompleted");
        action.setParams({ 
            userId: selectedMentee.Id
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Onboarding has been marked completed",
                    "type":"success"
                });
                toastEvent.fire();
                component.set('v.showExtendModal',false);
                var menteeUsers = component.get('v.menteeUsers');
                for(var i=0;i<menteeUsers.length;i++){
                    if(menteeUsers[i].userDetail.Id == selectedMentee.Id){
                        menteeUsers.splice(i,1);
                    }
                }
                component.set('v.menteeUsers',menteeUsers);
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
    onClickModalPrimaryButton :function(component,event,helper){
        var selectedMentee = component.get('v.selectedMentee');
        var action = component.get("c.extendOnboardingDate");
        action.setParams({ 
            userId:selectedMentee.Id,
            onboardingDate:selectedMentee.On_boarding_End_Date__c,
            reasonForExtend : component.get('v.extendReason')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var response = response.getReturnValue();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Onboarding has been extended successfully",
                    "type":"success"
                });
                toastEvent.fire();
                component.set('v.showExtendModal',false);
                if(response != null){
                    var menteeUsers = component.get('v.menteeUsers');
                    for(var i=0;i<menteeUsers.length;i++){
                        if(menteeUsers[i].userDetail.Id == selectedMentee.Id){
							menteeUsers[i].daysLeft = response;
                        }
                    }
                    component.set('v.menteeUsers',menteeUsers);
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