({
    createNewJoineeLookup : function(c) {
        c.set('v.newJoineeCustomLookupCount',c.get('v.newJoineeCustomLookupCount') + 1);
        $A.createComponent(
            "c:CustomLookup",
            {
                "aura:id": "menteeUser"+c.get('v.newJoineeCustomLookupCount'),
                "lookupUniqueId": "menteeUser"+c.get('v.newJoineeCustomLookupCount'),
                "objectAPIName" : "User",
                "objectFieldName" : "Name",
                "IconName" : "standard:user",
                "label" : "Explorer",
                "tooltipText" : "Explorer is the employee who is being onboarded"
            },
            function(customLookup, status, errorMessage){
                //Add the new button to the body array
                if (status === "SUCCESS") {
                    var newJoineeCustomLookup = [];
                    newJoineeCustomLookup.push(customLookup);
                    c.set("v.newJoineeCustomLookup",newJoineeCustomLookup);
                }
                
            }
        );
    },
    createMentorLookup : function(c) {
        c.set('v.mentorCustomLookupCount',c.get('v.mentorCustomLookupCount') + 1);
        $A.createComponent(
            "c:CustomLookup",
            {
                "aura:id": "mentorUser"+c.get('v.mentorCustomLookupCount'),
                "lookupUniqueId": "mentorUser"+c.get('v.mentorCustomLookupCount'),
                "objectAPIName" : "User",
                "objectFieldName" : "Name",
                "IconName" : "standard:user",
                "label" : "Guide",
                "tooltipText" : "Guide is a Mentor who will guide the Explorer"
            },
            function(customLookup, status, errorMessage){
                //Add the new button to the body array
                if (status === "SUCCESS") {
                    var mentorCustomLookup = [];
                    mentorCustomLookup.push(customLookup);
                    c.set("v.mentorCustomLookup",mentorCustomLookup);
                }
                
            }
        );
    },
    createManagerLookup : function(c,defaultValue) {
        c.set('v.managerCustomLookupCount',c.get('v.managerCustomLookupCount') + 1);
        $A.createComponent(
            "c:CustomLookup",
            {
                "aura:id": "managerUser"+c.get('v.managerCustomLookupCount'),
                "lookupUniqueId": "managerUser"+c.get('v.managerCustomLookupCount'),
                "objectAPIName" : "User",
                "objectFieldName" : "Name",
                "IconName" : "standard:user",
                "label" : "Trailmaker",
                "predefinedRecordId" : defaultValue,
                "tooltipText" : "Trailmaker is the Manager of the Explorer"
            },
            function(customLookup, status, errorMessage){
                //Add the new button to the body array
                if (status === "SUCCESS") {
                    var managerCustomLookup = [];
                    managerCustomLookup.push(customLookup);
                    c.set("v.managerCustomLookup",managerCustomLookup);
                }
                
            }
        );
    },
    createUserRoleLookup : function(c, defaultValue) {
        console.log("USER ROLE LOOKUP");
        c.set('v.userRoleCustomLookupCount',c.get('v.userRoleCustomLookupCount') + 1);
        $A.createComponent(
            "c:CustomLookup",
            {
                "aura:id": "userRole"+c.get('v.userRoleCustomLookupCount'),
                "lookupUniqueId": "userRole"+c.get('v.userRoleCustomLookupCount'),
                "objectAPIName" : "User_Role__c",
                "objectFieldName" : "Name",
                "IconName" : "standard:user_role",
                "predefinedRecordId" : defaultValue,
                "label" : "Role",
                "tooltipText" : "The function assumed by the Explorer"
            },
            function(customLookup, status, errorMessage){
                //Add the new button to the body array
                if (status === "SUCCESS") {
                    var userRoleCustomLookup = [];
                    userRoleCustomLookup.push(customLookup);
                    c.set("v.userRoleCustomLookup",userRoleCustomLookup);
                }
                
            }
        );
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
    setSubmitButtonStatus : function(c){
        var lUser = c.get("v.user");
        console.log("USER ROLE SEL"+c.get("v.selectedUserRole"));
        if(!$A.util.isEmpty(lUser.Id) && !$A.util.isEmpty(lUser.Mentor__c) &&
           !$A.util.isEmpty(lUser.ManagerId) && !$A.util.isEmpty(lUser.On_boarding_End_Date__c) && 
           !$A.util.isEmpty(lUser.Joining_Date__c) && 
           !(c.get("v.selectedUserRole") === undefined || c.get("v.selectedUserRole") === null)){
            c.find('submitBtn').set('v.disabled',false);
        }else{
            c.find('submitBtn').set('v.disabled',true);
        }
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