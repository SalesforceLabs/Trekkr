({
    showSpinner : function(c){
        var ltngSpiner = c.find('ltngSpiner');
        $A.util.removeClass(ltngSpiner,'slds-hide');
        $A.util.addClass(ltngSpiner,'slds-show');
    },
    hideSpinner : function(c){
        var ltngSpiner = c.find('ltngSpiner');
        $A.util.removeClass(ltngSpiner,'slds-show');
        $A.util.addClass(ltngSpiner,'slds-hide');
    },
    getMenteeAssignmentInfo : function(component,event){
        var helper = this;
        helper.showSpinner(component);
        var action = component.get("c.getMenteeDetailAndAssignmentInfo");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var responseMap = response.getReturnValue();
                component.set("v.selectedMentee",response.getReturnValue()['MENTEE_INFO']);
                component.set("v.milestoneInformationBody",[]);
                component.set('v.menteeAssignmentInformation',response.getReturnValue()['ASSIGNMENT_INFO'].menteeMilestones); 
                component.set('v.currentMilestonePos',response.getReturnValue()['ASSIGNMENT_INFO'].currentMilestonePos);
                helper.hideSpinner(component);
                document.getElementById('headerPanel').scrollIntoView();
            }
            else if (state === "INCOMPLETE") {
                helper.hideSpinner(component);
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                            helper.hideSpinner(component);
                        }
                    } else {
                        console.log("Unknown error");
                        helper.hideSpinner(component);
                    }
                }
            
        });
        $A.enqueueAction(action);
    },
    showMilestoneInformation : function(c,e){
        var h = this;
        h.showSpinner(c);
        var existingMilestoneComp = c.find("milestoneInformation"+c.get('v.milestonInformationCompCount'));
        if(existingMilestoneComp != null){
            var existingCountdownComp = existingMilestoneComp.find("countdownComp"+existingMilestoneComp.get('v.countdownCompCount'));
            if(existingCountdownComp !=null){
                var intervalVar = existingCountdownComp.get('v.intervalVar');
                if(intervalVar !=null){
                    clearInterval(intervalVar);
                }
            }
        }
        c.set("v.milestonInformationCompCount",c.get('v.milestonInformationCompCount') + 1);
        c.set('v.selectedMilestoneName',c.find('menteeProgressPathCmp').get('v.selectedMilestoneName'));
        c.set('v.selectedMilestonePrograms',c.find('menteeProgressPathCmp').get('v.selectedMilestonePrograms'));
        var isEditableForMentee = true;
        var currentMilestonePos = c.find('menteeProgressPathCmp').get('v.currentMilestonePos');
        var selectedMilestoneIndex = c.find('menteeProgressPathCmp').get('v.selectedMilestoneIndex');
        isEditableForMentee = selectedMilestoneIndex <= (currentMilestonePos);
        $A.createComponent(
            "c:MilestoneInformation",
            {
                "aura:id" : "milestoneInformation"+c.get('v.milestonInformationCompCount'),
                "selectedMilestoneName": c.get('v.selectedMilestoneName'),
                "milestonePrograms" : c.get('v.selectedMilestonePrograms'),
                "isEditableForUser" : isEditableForMentee,
                "persona" : "MENTEE",
                "onDataChange" : c.getReference("c.onDataChange")
            },
            function(newButton, status, errorMessage){
                if (status === "SUCCESS") {
                    var body = [];
                    body.push(newButton);
                    c.set("v.milestoneInformationBody", body);
                    h.hideSpinner(c);
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.");
                    h.hideSpinner(c);
                }
                    else if (status === "ERROR") {
                        console.log("Error: " + errorMessage);
                        h.hideSpinner(c);
                    }
            }
        );
    }
})