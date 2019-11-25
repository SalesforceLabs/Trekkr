({
    doInit: function(cmp, evt, helper) {
        var myPageRef = cmp.get("v.pageReference");
        var programId = myPageRef.state.Id;
        var action = cmp.get("c.getProgramDetail");
        action.setParams({ programId : programId });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.milestonInformationCompCount",cmp.get('v.milestonInformationCompCount') + 1);
                $A.createComponent(
                    "c:MilestoneInformation",
                    {
                        "aura:id" : "milestoneInformation"+cmp.get('v.milestonInformationCompCount'),
                        "selectedProgram": response.getReturnValue(),
                        "isNotification" : true
                    },
                    function(newButton, status, errorMessage){
                        if (status === "SUCCESS") {
                            var body = [];
                            body.push(newButton);
                            cmp.set("v.milestoneInformationBody", body);
                        }
                        else if (status === "INCOMPLETE") {
                            console.log("No response from server or client is offline.")
                        }
                            else if (status === "ERROR") {
                                console.log("Error: " + errorMessage);
                            }
                    }
                );
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