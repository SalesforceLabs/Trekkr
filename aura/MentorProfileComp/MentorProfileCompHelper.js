({
    next : function(comp,event, helper) {
        var position = comp.get('v.page');
        var newPosition;
        if(position == 'YOURBUDDIES')
            newPosition = 'PROFILE_INFORMATION';
        else if(position == 'PROFILE_INFORMATION')
            newPosition = 'ASSIGNPROGRAMS';
            else if(position == 'ASSIGNPROGRAMS')
                newPosition = 'NEWPROGRAM';
        comp.set('v.page',newPosition);
        
    },
    previous : function(comp,event, helper){
        var position = comp.get('v.page');
        var newPosition;
        if(position == 'PROFILE_INFORMATION')
            newPosition = 'YOURBUDDIES';
        else if(position == 'ASSIGNPROGRAMS')
            newPosition = 'PROFILE_INFORMATION';
            else if(position == 'NEWPROGRAM')
                newPosition = 'ASSIGNPROGRAMS';
        comp.set('v.page',newPosition);
    },
    getMentorAndMenteeInformation : function(component,event,onCallback){
        var action = component.get("c.getMentorAndBuddiesDetail");
        action.setCallback(this, onCallback);
        $A.enqueueAction(action);
    },
    getMenteeAssigmentInfo : function(c,e,scrollToTop){
        this.showSpinner(c);
        c.set('v.menteeAssignmentInformation',[]);
        c.set("v.milestoneInformationBody",[]);
        var selectedMentee = c.get('v.selectedMentee');
        var action = c.get("c.getMenteeAssignmentInformation");
        action.setParams({ userId : selectedMentee.Id});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var response = response.getReturnValue();
                c.set('v.menteeAssignmentInformation',response.menteeMilestones);
                c.set('v.currentMilestonePos',response.currentMilestonePos);
                c.set('v.page','PROFILE_INFORMATION');
                this.hideSpinner(c);
                if(scrollToTop)
                    document.getElementById('headerPanel').scrollIntoView();
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
    refreshCountdownComp : function(c,e){
        var existingMilestoneComp = c.find("milestoneInformation"+c.get('v.milestonInformationCompCount'));
        if(existingMilestoneComp !=null){
            var existingCountdownComp = existingMilestoneComp.find("countdownComp"+existingMilestoneComp.get('v.countdownCompCount'));
            if(existingCountdownComp !=null){
                var intervalVar = existingCountdownComp.get('v.intervalVar');
                if(intervalVar !=null){
                    clearInterval(intervalVar);
                }
            }
        }
    }
})