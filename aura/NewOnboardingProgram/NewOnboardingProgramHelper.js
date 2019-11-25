({
    createProgramLookup : function(c,e){
        var self = this;
        c.set('v.programCustomLookupCount',c.get('v.programCustomLookupCount') + 1);
        $A.createComponent(
            "c:CustomLookup",
            {
                "aura:id": "programLookup"+c.get('v.programCustomLookupCount'),
                "lookupUniqueId": "programLookup"+c.get('v.programCustomLookupCount'),
                "objectAPIName" : "Onboarding_Program__c",
                "placeholder" : "",
                "objectFieldName" : "Name",
                "IconName" : "",
                "label" : "Trail Name",
                "tooltipText" : "Search to clone an existing Trail or enter name for a new Trail",
                "showLookupPillOnSelection" : "false"
            },
            function(customLookup, status, errorMessage){
                //Add the new button to the body array
                self.hideSpinner(c);
                if (status === "SUCCESS") {
                    var programCustomLookup = [];
                    programCustomLookup.push(customLookup);
                    c.set("v.programCustomLookup",programCustomLookup);
                }
                
            }
        );
    },
    createTaskLookup : function(c,e,defaultRecordId,defaultRecordValue){
        c.set('v.taskCustomLookupCount',c.get('v.taskCustomLookupCount') + 1);
        $A.createComponent(
            "c:CustomLookup",
            {
                "aura:id": "taskLookup"+c.get('v.taskCustomLookupCount'),
                "lookupUniqueId": "taskLookup"+c.get('v.taskCustomLookupCount'),
                "placeholder" : "",
                "objectAPIName" : "On_boarding_Task__c",
                "objectFieldName" : "Name",
                "IconName" : "",
                "label" : "Step Name",
                "tooltipText" : "Search to clone an existing Step or enter name for a new Step",
                "predefinedRecordId" : defaultRecordId,
                "SearchKeyWord" : defaultRecordValue
            },
            function(customLookup, status, errorMessage){
                //Add the new button to the body array
                if (status === "SUCCESS") {
                    var taskCustomLookup = [];
                    taskCustomLookup.push(customLookup);
                    c.set("v.taskCustomLookup",taskCustomLookup);
                }
                
            }
        );
    },
    createAlertMessage : function(component,message,attributeName,parentAttribute){
        component.set(parentAttribute,true);
        $A.createComponent(
            "c:Alert",
            {
                "alertType": "ERROR",
                "message": message,
                "onClickClose" : component.getReference("c.onClickCloseAlert")
            },
            function(alertComponent, status, errorMessage){
                if (status === "SUCCESS") {
                    var alertCmpList = [];
                    alertCmpList.push(alertComponent);
                    component.set(attributeName,alertCmpList);
                }
                
            }
        );
    },
    onchangeTaskType : function(c,e){
        var selectedTaskTypeName = '';
        var taskRecordTypes = c.get('v.taskRecordTypes');
        var selectedTaskRecordTypeId = c.get('v.newEditTaskRecord').RecordTypeId;
        for(var i=0;i<taskRecordTypes.length;i++){
            if(taskRecordTypes[i].Id == selectedTaskRecordTypeId){
                selectedTaskTypeName = taskRecordTypes[i].Name;
                break;
            }
        }
        c.set('v.selectedTaskTypeName',selectedTaskTypeName);
        c.set('v.newEditTaskRecord.taskTypeName',selectedTaskTypeName);
    },
    showToast : function(title,message,type){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message: message,
            duration:' 2000',
            type: type
        });
        toastEvent.fire();
    },
    createProgram : function(c,callback){
        var programDetail = c.get("v.programDetail");
        var programLookupId = "programLookup"+c.get('v.programCustomLookupCount');
        var searchedData = c.find(programLookupId).get("v.SearchKeyWord");
        if($A.util.isEmpty(searchedData)){
            this.createAlertMessage(c,'Please enter Trail name',"v.alertMessageComponent",'v.showAlertMessage');
            this.hideSpinner(c);
            return;
        }
        if($A.util.isEmpty(programDetail.Description__c)){
            console.log("isHEre");
            this.createAlertMessage(c,'Please enter Trail description',"v.alertMessageComponent",'v.showAlertMessage');
            this.hideSpinner(c);
            return;
        }
        var tasksList = c.get('v.tasksList');
        if(tasksList.length == 0){
            this.createAlertMessage(c,'Add atleast one step to this program',"v.alertMessageComponent",'v.showAlertMessage');
            this.hideSpinner(c);
            return;
        }
        var newProgramDetail = {
            'sObjectType':'Onboarding_Program__c',
            'Name' : searchedData,
            'Description__c' : programDetail.Description__c,
            'Public__c' : programDetail.Public__c
        } 
        var action = c.get("c.insertNewOnboardingProgram");
        action.setParams({ 
            onboardingProgramJSON : JSON.stringify(newProgramDetail),
            onboardingTasksJSON : JSON.stringify(tasksList),
            selectedRoles : c.get('v.selectedRoles')
        });
        action.setCallback(this,callback);
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
    createAndAssignProgram : function(c,e){
        c.set('v.showAssignTrailModal',false);
        var h = this;
        h.showSpinner(c);
        h.createProgram(c,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var responseObj = response.getReturnValue();
                if(responseObj!= null){
                    var action = c.get("c.assignProgram");
                    action.setParams({ 
                        programId : responseObj.Id,
                        userId : c.get('v.assignToUserId'),
                        targetDateTime : c.get('v.targetDateTime')+'',
                        selectedMilestone : c.get('v.selectedMilestone')
                    });
                    action.setCallback(this,function(response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            var responseObj = response.getReturnValue();
                            c.set('v.createdProgram',responseObj);
                            c.set('v.createdTaskList',c.get('v.tasksList'));
                            c.set('v.createdUserRoles',c.get('v.selectedRoles'));
                            c.set('v.programDetail',{'sObjectType':'Onboarding_Program__c'});
                            c.set('v.tasksList',[]);
                            c.set('v.selectedRoles','');
                            c.set('v.selectedOptionPills',[]);
                            c.set('v.clearMultipicklist',true);
                            h.createProgramLookup(c,e);
                            h.showToast('Success','A new Trail has been created and assigned successfully','success');
                            if(!$A.util.isEmpty(c.get('v.onProgramCreated'))){
                                $A.enqueueAction(c.get('v.onProgramCreated'));
                            }
                            h.hideSpinner(c);
                            $A.enqueueAction(c.get('v.onDataChange'));
                        }
                    });
                    $A.enqueueAction(action);
                }else{
                    h.showToast('Error','Due to some internal error, we can\'t process your request','error');
                    h.hideSpinner(c);
                }
                
            }
            else if (state === "INCOMPLETE") {
                h.hideSpinner(c);
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
                    h.hideSpinner(c);
                }
        });
    }
})