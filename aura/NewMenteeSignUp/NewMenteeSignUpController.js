({
    doInit : function(c,e,h){
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        c.set("v.minDate", today);
        h.createNewJoineeLookup(c);
        h.createMentorLookup(c);
        h.createManagerLookup(c,'');
        h.createUserRoleLookup(c);

    },
    onClickSave : function(component, event, helper) {
        var menteeLookupId = 'menteeUser'+component.get('v.newJoineeCustomLookupCount');
        var mentorLookupId = 'mentorUser'+component.get('v.mentorCustomLookupCount');
        var managerLookupId = 'managerUser'+component.get('v.managerCustomLookupCount');
        var menteeName = component.find(menteeLookupId).get("v.selectedRecord").Name;
        var mentorName = component.find(mentorLookupId).get("v.selectedRecord").Name;
        var managerName = component.find(managerLookupId).get("v.selectedRecord").Name;
        component.set(
            'v.ConfirmationDialogMessage',
            'You are enrolling <strong>'+menteeName+
            '</strong> for the onboarding program. Please confirm below details -<br/><br/>'+
            '<strong>Guide</strong> : '+mentorName+'<br/><strong>Trailmaker</strong> : '+managerName+
            '<br/><strong>Joining Date</strong> : '+component.get("v.joiningDate")+'<br/><strong>Onboarding End Date</strong> :'+
            component.get('v.onboardingEndDate')+'<br/><br/>Permissions will be assigned to Explorer, Guide and Trailmaker for accessing Trekkr.'
        );
        component.set('v.showConfirmationDialog',true);
    },
    onClearLookupRecord : function(c,e,h){
        var lookupUniqueId = e.getParam("lookupUniqueId");
        if(lookupUniqueId == 'menteeUser'+c.get('v.newJoineeCustomLookupCount')){
            c.set('v.user.Id',null);
        }else if(lookupUniqueId == 'mentorUser'+c.get('v.mentorCustomLookupCount')){
            c.set('v.user.Mentor__c',null);
        }else if(lookupUniqueId == 'managerUser'+c.get('v.managerCustomLookupCount')){
            c.set('v.user.ManagerId',null);
        }else if(lookupUniqueId == 'userRole'+c.get('v.userRoleCustomLookupCount')){
            c.set('v.selectedUserRole', null);
        }
        h.setSubmitButtonStatus(c);
    },
    handleComponentEvent : function(component, event, helper) {
        var lookupUniqueId = event.getParam("lookupUniqueId");
        var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        if(lookupUniqueId == 'menteeUser'+component.get('v.newJoineeCustomLookupCount')){
            helper.showSpinner(component);
            component.set('v.user.Id',selectedAccountGetFromEvent.Id);
            component.set("v.selectedRecord" , selectedAccountGetFromEvent);
            var action = component.get("c.getManagerAndRole");
            action.setParams({ 
                userId : selectedAccountGetFromEvent.Id
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var responseObj = response.getReturnValue();
                    helper.createManagerLookup(component,responseObj[0]);
                    component.set('v.user.ManagerId',responseObj[0]);
                    helper.createUserRoleLookup(component,responseObj[1]);
                    component.set('v.selectedUserRole',responseObj[1]);
                    helper.hideSpinner(component);
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
        }else if(lookupUniqueId == 'mentorUser'+component.get('v.mentorCustomLookupCount')){
            component.set('v.user.Mentor__c',selectedAccountGetFromEvent.Id);
        }else if(lookupUniqueId == 'managerUser'+component.get('v.managerCustomLookupCount')){
            component.set('v.user.ManagerId',selectedAccountGetFromEvent.Id);
        }else if(lookupUniqueId == 'userRole'+component.get('v.userRoleCustomLookupCount')){
            component.set('v.selectedUserRole', selectedAccountGetFromEvent.Id);
        }
        helper.setSubmitButtonStatus(component);
    },
    onChangeEndDate : function(c,e,h){
        if(c.get('v.joiningDate') && c.get('v.onboardingEndDate') && c.get('v.onboardingEndDate') < c.get('v.joiningDate')){
            c.set("v.onboardingEndDate",null);
            h.showToast('Oops!','Ensure Joining date falls before Onboarding end date','error');
            return;
        }
        c.set('v.user.On_boarding_End_Date__c',c.get("v.onboardingEndDate"));
        h.setSubmitButtonStatus(c);
    },
    onChangeJoiningDate : function(c,e,h){
        if(c.get('v.joiningDate') && c.get('v.onboardingEndDate') && c.get('v.onboardingEndDate') < c.get('v.joiningDate')){
            c.set("v.joiningDate",null);
            h.showToast('Oops!','Ensure Joining date falls before Onboarding end date','error');
            return;
        }
        c.set('v.user.Joining_Date__c',c.get("v.joiningDate"));
        h.setSubmitButtonStatus(c);
    },
    onClickNewUserRole : function(c,e,h){
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({ 
            "entityApiName": "User_Role__c"
        });
        createRecordEvent.fire();
    },
    onClickConfirm_ConfirmationDialog : function(component, event, helper){
        helper.showSpinner(component);
        var selectedUserRole = component.find("userRole"+component.get('v.userRoleCustomLookupCount')).get("v.selectedRecord").Id;
        component.set('v.showConfirmationDialog',false);
        var action = component.get("c.saveMenteeDetails");
        action.setParams({ 
            lUser : JSON.stringify(component.get("v.user")),
            sendWelcomeEmail : component.get("v.sendWelcomeEmail"),
            userRole : selectedUserRole
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if(response.getReturnValue()){
                    helper.createNewJoineeLookup(component);
                    helper.createMentorLookup(component);
                    helper.createManagerLookup(component,'');
                    helper.createUserRoleLookup(component);
                    component.set('v.joiningDate',null);
                    component.set('v.onboardingEndDate',null);
                    component.set("v.user",{'sObjectType':'User'});
                    component.set("v.sendWelcomeEmail",false);
                    helper.showToast('Success','New Joinee Enrollment is completed','success')
                    helper.hideSpinner(component);
                }else{
                    helper.showToast('Error','We are unable to process your request. Please check if you have access or are signing up Explorer again.','error')
                    helper.hideSpinner(component);
                }       
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
    onClickCancel_ConfirmationDialog : function(c,e,h){
        c.set('v.showConfirmationDialog',false);   
    }
})