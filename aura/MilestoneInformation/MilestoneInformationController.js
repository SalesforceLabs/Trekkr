({
    onclickTab : function(component, event, helper) {
        var position = event.currentTarget.id;
        var milestonePrograms = component.get('v.milestonePrograms');
        var selectedProgram = milestonePrograms[position];
        component.set('v.selectedProgram',selectedProgram);
        helper.newCountdownComp(component,selectedProgram.Target_Date_Time__c);        
        helper.setActiveProgram(component,milestonePrograms,position);
    },
    doInit : function(component,event,helper){
        console.log("HERE COUNTDOWN12");
        var dateTimeNow = $A.localizationService.formatDate(new Date(), "yyyy-MM-ddTHH:mm:ss");
        component.set("v.minDateTime", dateTimeNow);
        var milestonePrograms = component.get('v.milestonePrograms');
        if(milestonePrograms.length > 0){
            var selectedProgram = milestonePrograms[0];
            component.set('v.selectedProgram',selectedProgram);
            helper.newCountdownComp(component,selectedProgram.Target_Date_Time__c); 
            helper.setActiveProgram(component,milestonePrograms,0);
        }
    },
    onAttachmentUploadFinish : function(c,e,h){
        var uploadedFiles = e.getParam("files");
        var existingAttachments = c.get('v.selectedTaskAttachments');
        for(var i=0;i<uploadedFiles.length;i++){
            existingAttachments.push({'sObjectType':'ContentDocumentLink', 'ContentDocumentId' : uploadedFiles[i].documentId });
        }
        c.set('v.selectedTaskAttachments',existingAttachments);
    },
    onClickTaskName : function(c,e,h){
        c.set('v.selectedIdForMoreInformation',e.currentTarget.id);
        h.getMoreInformation(c,e,h);
    },
    onClickProgramName : function(c,e,h){
        c.set('v.selectedIdForMoreInformation',c.get('v.selectedProgram').Id);
        h.getMoreInformation(c,e,h);
    },
    handleTabActive : function(c,e,h){
        var tab = e.getSource();
        c.set('v.newTaskContribution',false);
        switch (tab.get('v.id')) {
            case 'discussionTab' :
                var taskId = c.get('v.selectedIdForMoreInformation');
                c.set("v.body",[]);
                $A.createComponent(
                    "forceChatter:publisher", {
                        "context": "RECORD",
                        "recordId": taskId
                    },
                    function(recordFeed) {
                        if (c.isValid()) {
                            var body = c.get("v.body");
                            body.push(recordFeed);
                            c.set("v.body", body);
                            $A.createComponent(
                                "forceChatter:feed", {
                                    "type": "Record",
                                    "feedDesign" : "DEFAULT",
                                    "subjectId": taskId
                                },
                                function(recordFeed1) {
                                    if (c.isValid()) {
                                        var body1 = c.get("v.body");
                                        body1.push(recordFeed1);
                                        c.set("v.body", body1);
                                    }
                                });
                        }
                    });   
        }
    },
    onClickCloseTaskModal:function(c,e,h){
        h.hideComponent(c,'taskDetailModal');  
    },
    toggleSideView : function(c,e,h){
        c.set('v.showSideView',!c.get('v.showSideView'));
    },
    onClickModalPrimaryButton : function(c,e,h){
        var modalName = e.getSource().getLocalId();
        if(modalName == 'feedbackModal'){
            if(c.get('v.persona') == 'MENTOR'){
                var action = c.get('c.storeFeedback');
                action.setParams({
                    assignedProgramId : c.get('v.selectedProgram.Id'),
                    feedbackMessage : c.get('v.selectedProgram.Feedback__c')
                });
                action.setCallback(this, function(resp){
                    if(resp.getState() === 'SUCCESS'){
                        var responseData = resp.getReturnValue();
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "message": "Your feedback for the Trail has been shared with the Explorer.",
                            "type" : 'success'
                        });
                        toastEvent.fire();
                        c.set('v.showFeedbackModal',false);
                    }
                });
                $A.enqueueAction(action);
            }else{
                c.set('v.showFeedbackModal',false);
            }
        }else if(modalName == 'reopenModal'){
            var action = c.get("c.reopenTask");
            var taskId = c.get("v.reopenTaskId");
            var reason = c.get("v.reopenReason");
            action.setParams({
                assignedTaskId : taskId,
                reopenReason : reason
            });
            action.setCallback(this, function(resp){
                if(resp.getState() === 'SUCCESS'){
                    //var responseData = resp.getReturnValue();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "The step has been reponed and Explorer is notified.",
                        "type" : 'success'
                    });
                    toastEvent.fire();
                    c.set('v.showReopenModal',false);
                    var reopenedTask = c.get('v.selectedProgram.Child_Assigned_Tasks__r['+c.get('v.reopenTaskIndex')+']');
                    reopenedTask.Status__c = 'In-Progress';
                    c.set('v.selectedProgram.Child_Assigned_Tasks__r['+c.get('v.reopenTaskIndex')+']',reopenedTask);
                    //$A.enqueueAction(c.get('v.onStepReopen'));
                    $A.enqueueAction(c.get('v.onDataChange'));
                }else if (state === "ERROR") {
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
        }else if(modalName == 'editStepModal'){
            if(c.get('v.persona') == 'MENTOR'){
                var action = c.get('c.updateTargetDate');
                action.setParams({
                    assignedTaskId : c.get('v.editTaskDetail').Id,
                    targetDateTimeString : c.get('v.editTaskDetail.Target_Date_Time__c').toString()
                });
                action.setCallback(this, function(resp){
                    if(resp.getState() === 'SUCCESS'){
                        var responseData = resp.getReturnValue();
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "message": "The step has been update successfully",
                            "type" : 'success'
                        });
                        toastEvent.fire();
                        c.set('v.showEditModal',false);
                        var reopenedTask = c.get('v.selectedProgram.Child_Assigned_Tasks__r['+c.get('v.reopenTaskIndex')+']');
                        reopenedTask.Target_Date_Time__c = c.get('v.editTaskDetail.Target_Date_Time__c');
                        c.set('v.selectedProgram.Child_Assigned_Tasks__r['+c.get('v.reopenTaskIndex')+']',reopenedTask);
                    }
                });
                $A.enqueueAction(action);
            }else{
                var action = c.get('c.updateStatusAndCurrentValue');
                action.setParams({
                    assignedTaskId : c.get('v.editTaskDetail').Id,
                    status : c.get('v.editTaskDetail.Status__c'),
                    currentValue : c.get('v.editTaskDetail.Current_Value__c')
                });
                action.setCallback(this, function(resp){
                    if(resp.getState() === 'SUCCESS'){
                        var responseData = resp.getReturnValue();
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "message": "The step has been update successfully",
                            "type" : 'success'
                        });
                        toastEvent.fire();
                        c.set('v.showEditModal',false);
                        /**var reopenedTask = c.get('v.selectedProgram.Child_Assigned_Tasks__r['+c.get('v.reopenTaskIndex')+']');
                        reopenedTask.Status__c = c.get('v.editTaskDetail.Status__c');
                        reopenedTask.Current_Value__c = c.get('v.editTaskDetail.Current_Value__c');
                        c.set('v.selectedProgram.Child_Assigned_Tasks__r['+c.get('v.reopenTaskIndex')+']',reopenedTask);**/
                        $A.enqueueAction(c.get('v.onDataChange'));
                    }
                });
                $A.enqueueAction(action);
            }
        }
    },
    onEditStep : function(c,e,h){
        var buttonId = e.currentTarget.id;
        var taskId = buttonId.split('~')[1];
        var taskIndex = buttonId.split('~')[0];
        if(c.get('v.persona') == 'MENTOR'){
            c.set('v.showEditModal',true);
            c.set('v.reopenTaskIndex',taskIndex);
            c.set('v.editTaskDetail',c.get('v.selectedProgram.Child_Assigned_Tasks__r['+taskIndex+']'));
        }else{
            if(c.get('v.statuses') || c.get('v.statuses').length === 0){
                var action = c.get('c.getStatuses');
                action.setParams({ 
                    currentStatus : c.get('v.selectedProgram.Child_Assigned_Tasks__r['+taskIndex+']').Status__c
                });
                action.setCallback(this, function(resp){
                    if(resp.getState() === 'SUCCESS'){
                        var responseData = resp.getReturnValue();
                        c.set('v.statuses',responseData);
                        c.set('v.showEditModal',true);
                        c.set('v.reopenTaskIndex',taskIndex);
                        c.set('v.editTaskDetail',c.get('v.selectedProgram.Child_Assigned_Tasks__r['+taskIndex+']'));
                    }
                });
                $A.enqueueAction(action);
            }else{
                c.set('v.showEditModal',true);
                c.set('v.reopenTaskIndex',taskIndex);
                c.set('v.editTaskDetail',c.get('v.selectedProgram.Child_Assigned_Tasks__r['+taskIndex+']'));
            }
        }
    },
    onClickFeedbackButton : function(c,e,h){
        c.set('v.showFeedbackModal',true);
    },
    onClickReopenButton : function(c,e,h){
        var buttonId = e.currentTarget.id;
        c.set('v.reopenTaskId',buttonId.split('~')[1]);
        c.set('v.reopenTaskIndex',buttonId.split('~')[0]);
        c.set('v.showReopenModal',true);
        c.set('v.reopenReason','');
    },
    onClickMarkAsCompleted : function(c,e,h){
        var buttonId = e.currentTarget.id;
        var taskId = buttonId.split('~')[1];
        var taskIndex = buttonId.split('~')[0];
        var action = c.get('c.markTaskAsCompleted');
        action.setParams({
            assignedTaskId : taskId
        });
        action.setCallback(this, function(resp){
            if(resp.getState() === 'SUCCESS'){
                var responseData = resp.getReturnValue();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "The step has been closed successfully",
                    "type" : 'success'
                });
                toastEvent.fire();
                /**var completeTask = c.get('v.selectedProgram.Child_Assigned_Tasks__r['+taskIndex+']');
                completeTask.Status__c = 'Closed';
                c.set('v.selectedProgram.Child_Assigned_Tasks__r['+taskIndex+']',completeTask);**/
                $A.enqueueAction(c.get('v.onDataChange'));
            }
        });
        $A.enqueueAction(action);
        
    },
    checkIfValidValue : function(component,event,helper){
        if(component.get('v.persona') == 'MENTEE'){
            var achieved = component.find("achieved").get("v.value");
            if(achieved.toString().includes("-")){
                component.find("editStepModal").set("v.disablePrimaryButton", true);
            } else{
                component.find("editStepModal").set("v.disablePrimaryButton", false);
            }  
        }
    }
})