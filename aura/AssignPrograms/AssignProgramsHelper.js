({
    getMilestonesList : function(c) {
        var action = c.get("c.getMilestones");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var allMilestones = response.getReturnValue();
                var currentMilestone = c.get('v.currentMilestonePos');
                for(var i =0;i<allMilestones.length;i++){
                    if(allMilestones[i].label.split(' ')[1] < currentMilestone){
                        allMilestones.splice(i,1);
                    }
                }
                c.set('v.milestones',allMilestones);
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
    }
})