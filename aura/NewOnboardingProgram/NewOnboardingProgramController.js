({
    doInit : function(component,event,helper){
        var dateTimeNow = $A.localizationService.formatDate(new Date(), "yyyy-MM-ddTHH:mm:ss");
        component.set("v.minDateTime", dateTimeNow);
        var action = component.get("c.getInit");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var responseObj = response.getReturnValue();
                component.set('v.userRoles',responseObj['userRoles']);
                component.set('v.taskRecordTypes',responseObj['taskRecordTypes']);
                component.set('v.taskDurationTypes',responseObj['taskDurationTypes']);
                component.set('v.taskDifficulties',responseObj['taskDifficulties']);
                var allMilestones = responseObj['milestones'];
                var currentMilestone = component.get('v.currentMilestonePos');
                for(var i =0;i<allMilestones.length;i++){
                    if(allMilestones[i].label.split(' ')[1] < currentMilestone){
                        allMilestones.splice(i,1); 
                    }
                }
                component.set('v.milestones',allMilestones);
                helper.createProgramLookup(component,event);
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
                        }
                    } else {
                        console.log("Unknown error");
                    }
                    helper.hideSpinner(component);
                }
        });
        $A.enqueueAction(action);
    },
    onClickCreateAndAssignProgram : function(c,e,h){
        c.set('v.showAssignTrailModal',true);
    },
    onClickCreateProgram : function(c,e,h){
        h.showSpinner(c);
        h.createProgram(c,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var responseObj = response.getReturnValue();
                if(responseObj != null){
                    c.set('v.createdProgram',responseObj);
                    c.set('v.createdTaskList',c.get('v.tasksList'));
                    c.set('v.createdUserRoles',c.get('v.selectedRoles'));
                    c.set('v.programDetail',{'sObjectType':'Onboarding_Program__c'});
                    c.set('v.tasksList',[]);
                    c.set('v.selectedRoles','');
                    c.set('v.selectedOptionPills',[]);
                    c.set('v.clearMultipicklist',true);
                    h.createProgramLookup(c,e);
                    if(!$A.util.isEmpty(c.get('v.onProgramCreated'))){
                        $A.enqueueAction(c.get('v.onProgramCreated'));
                    }
                    h.showToast('Success','A new Trail has been created successfully','success');
                }else{
                    h.showToast('Error','Due to some internal error, we can\'t process your request','error');
                }
                h.hideSpinner(c);
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
        })
    },
    onClickNewTask : function(c,e,h){
        c.set('v.modalTitle','New Step');
        c.set('v.showAddTaskModal',true);
        c.set('v.newEditTaskRecord',{'sObjectType':'On_boarding_Task__c','Link__c':''});
        c.set('v.taskCustomLookupCount',c.get('v.taskCustomLookupCount') + 1);
        c.set('v.taskModalSaveButtonTitle','Save');
        c.set('v.selectedTaskTypeName','');
        c.set('v.isCurrentTaskEditable',true);
        c.set('v.editStepRowNo',-1);
        h.createTaskLookup(c,e,'','');
    },
    onClickDelete : function(c,e,h){
        var deleteButtonId = e.currentTarget.id;
        var tasksList = c.get('v.tasksList');
        tasksList.splice(deleteButtonId,1);
        c.set('v.tasksList',tasksList);
    },
    onClickEdit : function(c,e,h){
        var editButtonId = e.currentTarget.id;
        var taskToEdit = c.get('v.tasksList['+editButtonId+']');
        c.set('v.editStepRowNo',editButtonId);
        c.set('v.newEditTaskRecord',taskToEdit);
        c.set('v.showAddTaskModal',true);
        c.set('v.modalTitle','Edit Step');
        c.set('v.isCurrentTaskEditable',true);
        h.onchangeTaskType(c,e);
        if(taskToEdit.Id !=null && taskToEdit.Id != undefined && taskToEdit.Id != ''){
            h.createTaskLookup(c,e,taskToEdit.Id,'');
        }else if(taskToEdit.Name !=null && taskToEdit.Name != undefined && taskToEdit.Name != ''){
            h.createTaskLookup(c,e,'',taskToEdit.Name);
        }
        
    },
    onClickEditTaskDetail : function(c,e,h){
        c.set('v.isCurrentTaskEditable',true);
        c.set('v.taskModalSaveButtonTitle','Save');
        c.set('v.newEditTaskRecord.Id','');
    },
    handleComponentEvent : function(component, event, helper) {
        var lookupUniqueId = event.getParam("lookupUniqueId");
        var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        if(lookupUniqueId == 'programLookup'+component.get('v.programCustomLookupCount')){
            component.set("v.selectedRecord" , selectedAccountGetFromEvent);
            var action = component.get("c.getProgramDetails");
            action.setParams({ 
                programId : selectedAccountGetFromEvent.Id
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var responseObj = response.getReturnValue();
                    component.set('v.programDetail',responseObj);
                    var programUserRoles = responseObj.Program_User_Role_Junctions__r;
                    var selectedOptionPills = [];
                    for(var i=0;i<programUserRoles.length;i++){
                        selectedOptionPills.push({
                            "label": programUserRoles[i].User_Role__r.Name,
                            "value": programUserRoles[i].User_Role__r.Id,
                            "iconName": '',
                            "customIcon": '',
                            "destroyable": true
                        });
                    }
                    component.set("v.selectedOptionPills",selectedOptionPills);
                    var taskList = [];
                    var programTaskJunctions = responseObj.Onboarding_Program_Task_Junctions__r;
                    for(var i=0;i<programTaskJunctions.length;i++){
                        var onboardingTask = programTaskJunctions[i].Onboarding_Task__r;
                        taskList.push({
                            'sObjectType':'On_boarding_Task__c',
                            'Id' : onboardingTask.Id,
                            'Name' : onboardingTask.Name,
                            'Description__c' : onboardingTask.Description__c,
                            'Duration__c' : onboardingTask.Duration__c,
                            'Duration_Type__c' : onboardingTask.Duration_Type__c,
                            'Level__c' : onboardingTask.Level__c,
                            'Link__c' : onboardingTask.Link__c,
                            'Mandatory__c' : onboardingTask.Mandatory__c,
                            'Quantifiable__c' : onboardingTask.Quantifiable__c,
                            'RecordTypeId' : onboardingTask.RecordTypeId,
                            'Target_Value__c' : onboardingTask.Target_Value__c,
                            'taskTypeName' : onboardingTask.Record_Type__c
                        });
                    }
                    component.set("v.tasksList",taskList);
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
        }else if(lookupUniqueId == "taskLookup"+component.get('v.taskCustomLookupCount')){
            var action = component.get("c.getTaskDetails");
            action.setParams({ 
                taskId : selectedAccountGetFromEvent.Id
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var responseObj = response.getReturnValue();
                    component.set('v.newEditTaskRecord',responseObj);
                    component.set('v.isCurrentTaskEditable',false);
                    component.set('v.taskModalSaveButtonTitle','Select');
                    helper.onchangeTaskType(component,event);
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
    },
    onChangeTypeOfTask : function(c,e,h){
        h.onchangeTaskType(c,e);
    },
    onClickModalPrimaryButton : function(c,e,h){
        var modalName = e.getSource().getLocalId();
        if(modalName == 'newEditStepModal'){
            var taskLookupId = "taskLookup"+c.get('v.taskCustomLookupCount');
            var taskToAdd = c.get('v.newEditTaskRecord');
            var selectedRecord = c.find(taskLookupId).get('v.selectedRecord');
            var searchedData = c.find(taskLookupId).get("v.SearchKeyWord");
            if(selectedRecord !=null && selectedRecord != undefined && selectedRecord.Id != null && selectedRecord.Id!=''){
                taskToAdd.Name = selectedRecord.Name;
                taskToAdd.Id = selectedRecord.Id;
            }else if(searchedData != null && searchedData!= ''){
                taskToAdd.Name = searchedData;
            }
            if($A.util.isEmpty(taskToAdd.Name)){
                h.createAlertMessage(c,'Please enter Step name',"v.taskAlertMessageComponent",'v.showTaskAlertMessage');
                return;
            }
            if($A.util.isEmpty(taskToAdd.RecordTypeId)){
                h.createAlertMessage(c,'Please select Step type',"v.taskAlertMessageComponent",'v.showTaskAlertMessage');
                return;
            }
            var tasksList = c.get('v.tasksList');
            if(c.get('v.editStepRowNo') != -1)
                tasksList.splice(c.get('v.editStepRowNo'),1);
            tasksList.push(taskToAdd);
            c.set('v.tasksList',tasksList);
            c.set('v.showAddTaskModal',false);
        }else if(modalName == 'assignTrailModal'){
            h.createAndAssignProgram(c,e);
        }
    },
    onClickCloseAlert : function(c){
        c.set('v.showAlertMessage',false);
        c.set('v.showTaskAlertMessage',false);
    }
})