({
    doInit : function(component, event, helper) {
        var action = component.get("c.getMenteeTasks");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                component.set("v.menteeTaskList",response.getReturnValue());
            }
            else if(state === "ERROR") {
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
    taskDetails : function(component,event,helper){
        var index = event.currentTarget.id;
        var menteeTaskList = component.get('v.menteeTaskList');
        component.set('v.selectedTask',menteeTaskList[index]);
        component.set('v.showDetailModal',true);
    },
    changeStatus : function(component,event,helper){
        var toastEvent = $A.get("e.force:showToast");
        var index = event.currentTarget.id;
        var menteeTaskList = component.get('v.menteeTaskList');
        var taskItem = menteeTaskList[index];
        var action = component.get("c.changeStatusOfTask");
        action.setParams({
            'task' : taskItem
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                component.set('v.menteeTaskList['+index+']',response.getReturnValue());
                toastEvent.setParams({
                    "title": "Status Updated",
                    "message": "Status of the Step is updated",
                    "type": "success"
                });
                toastEvent.fire();
            }
            else if(state === "ERROR") {
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
    onClickModalPrimaryButton : function(c,e,h){
        c.set('v.showDetailModal',false);
    }
})