({
    onClickAssignPrograms : function(component, event, helper) {
        var assignProgramsList = [];
        var selectedPrograms = component.get('v.selectedPrograms');
        for(var i=0;i<selectedPrograms.length;i++){
            assignProgramsList.push({
                'sobjectType': 'Assigned_Task__c',
                'Onboarding_Program__c' : selectedPrograms[i].Id,
                'Target_Date_Time__c' : selectedPrograms[i].Target_Date_Time__c,
                'Milestone__c' : selectedPrograms[i].Milestone__c,
                'Assign_To__c' : component.get("v.menteeDetail.Id"),
                'Status__c' : 'New'
            });
        }
        var action = component.get("c.assignPrograms");
        action.setParams({
            assignProgramsListJSON : JSON.stringify(assignProgramsList)
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var response = response.getReturnValue();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Trails has been assigned to Explorer",
                    "type" : 'success'
                });
                toastEvent.fire();
                component.set('v.selectedPrograms',[]);
                $A.enqueueAction(component.get('v.onDataChange'));
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
    onSelectProgram : function(c,e,h){
        var checkboxId = e.currentTarget.id;
        var checked = e.currentTarget.checked;
        var selectedProgram;
        if(c.get('v.programsType') == 'allPrograms'){
            selectedProgram = c.get('v.allPrograms['+checkboxId+']');
            selectedProgram.checked = checked;
            c.set('v.allPrograms['+checkboxId+']',selectedProgram);
        }else{
            selectedProgram = c.get('v.recommendedPrograms['+checkboxId+']');
            selectedProgram.checked = checked;
            c.set('v.recommendedPrograms['+checkboxId+']',selectedProgram);
        }
        var selectedPrograms = c.get('v.selectedPrograms');
        if(checked == true){
            selectedPrograms.push(selectedProgram);
        }else{
            for(var i =0;i<selectedPrograms.length;i++){
                if(selectedPrograms[i].Id == selectedProgram.Id){
                    selectedPrograms.splice(i, 1);
                }
            }
        }
        c.set('v.selectedPrograms',selectedPrograms);
    },
    onClickModalPrimaryButton : function(c,e,h){
        var modalName = e.getSource().getLocalId();
        if(modalName == 'viewProgramDetails'){
            c.set('v.showProgramDetailModal',false);
        }
    },
    doInit : function(c,e,h){
        var dateTimeNow = $A.localizationService.formatDate(new Date(), "yyyy-MM-ddTHH:mm:ss");
        c.set("v.minDateTime", dateTimeNow);
        var action = c.get("c.getPrograms");
        action.setParams({ userId : c.get("v.menteeDetail.Id") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var programsMap = response.getReturnValue();
                c.set('v.allPrograms',programsMap['ALL']);
                c.set('v.recommendedPrograms',programsMap['RECOMMENDED']);
                h.getMilestonesList(c);
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
    onSearch : function(c,e,h){
        var isEnterKey = e.keyCode === 13;
        if (isEnterKey) {
            var textToSearch = c.get('v.searchedText');
            if(c.get('v.backupPrograms') && c.get('v.backupPrograms').length >0){
                if(c.get('v.programsType') == 'suggestedPrograms'){
                    c.set('v.recommendedPrograms',c.get('v.backupPrograms'));
                }else{
                    c.set('v.allPrograms',c.get('v.backupPrograms'));
                }
            }
            var programsToSearch = [];
            if(c.get('v.programsType') == 'suggestedPrograms'){
                programsToSearch = c.get('v.recommendedPrograms');
            }else{
                programsToSearch = c.get('v.allPrograms');
            }
            c.set('v.backupPrograms',programsToSearch);
            var filteredPrograms = [];
            for(var i=0;i<programsToSearch.length;i++){
                var programToSearch = programsToSearch[i];
                if((programToSearch.Name && programToSearch.Name.toUpperCase().includes(textToSearch.toUpperCase())) || 
                   (programToSearch.Description__c && programToSearch.Description__c.toUpperCase().includes(textToSearch.toUpperCase()))){
                    filteredPrograms.push(programToSearch);
                }
            }
            if(c.get('v.programsType') == 'suggestedPrograms'){
                c.set('v.recommendedPrograms',filteredPrograms);
            }else{
                c.set('v.allPrograms',filteredPrograms);
            }
        }
    },
    onChangeSearch : function(c,e,h){
        if(c.get('v.searchedText') == ''){
            if(c.get('v.programsType') == 'suggestedPrograms'){
                c.set('v.recommendedPrograms',c.get('v.backupPrograms'));
            }else{
                c.set('v.allPrograms',c.get('v.backupPrograms'));
            }
        }
    },
    onClickNewProgram : function(c,e,h){
        if(c.get('v.selectedPrograms').length > 0){
            c.set('v.showConfirmationDialog',true);
        }else{
            $A.enqueueAction(c.get('v.onClickNewProgram'));
        }
    },
    onClickCancel_ConfirmationDialog : function(c,e,h){
        c.set('v.showConfirmationDialog',false);
    },
    onClickConfirm_ConfirmationDialog : function(c,e,h){
        c.set('v.showConfirmationDialog',false);
        $A.enqueueAction(c.get('v.onClickNewProgram'));
    },
    onClickDetails : function(c,e,h){
        var buttonId = e.currentTarget.id;
        var viewTaskForProgram;
        if(c.get('v.programsType') == 'allPrograms'){
            viewTaskForProgram = c.get('v.allPrograms['+buttonId+']');
        }else{
            viewTaskForProgram = c.get('v.recommendedPrograms['+buttonId+']');
        }
        c.set('v.viewDetailsForProgram',viewTaskForProgram);
        c.set('v.showProgramDetailModal',true);
    },
    onClickNext : function(c,e,h){
        c.set('v.pageNo',c.get('v.pageNo') + 1);
    },
    onClickBack : function(c,e,h){
        c.set('v.pageNo',c.get('v.pageNo') - 1);
    }
})