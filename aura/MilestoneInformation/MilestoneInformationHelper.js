({
    setActiveProgram : function(component,milestonePrograms,position) {
        var updatedMilestonePrograms = [];
        for(var i=0;i<milestonePrograms.length;i++){
            var milestoneProgram = milestonePrograms[i];
            if(i == position){
                milestoneProgram.active = true;
            }else{
                milestoneProgram.active = false;
            }
            updatedMilestonePrograms.push(milestoneProgram);
        }
        component.set('v.milestonePrograms',updatedMilestonePrograms);	
    },
    showComponent : function (component, divId) {
        $A.util.removeClass(component.find(divId), "slds-hide");
    },
    hideComponent : function (component, divId) {
        $A.util.addClass(component.find(divId), "slds-hide");
    },
    getMoreInformation : function(c,e,h){
        c.find("taskDetailTabset").set("v.selectedTabId","attachments");
        var action = c.get('c.getRecordRelateData');
        action.setParams({ 
            recordId : c.get('v.selectedIdForMoreInformation')
        });
        action.setCallback(this, function(resp){
            if(resp.getState() === 'SUCCESS'){
                var responseData = resp.getReturnValue();
                c.set('v.selectedTaskAttachments',responseData['ATTACHMENTS']);
                c.set('v.assignedTaskContributions',responseData['TASKCONTRIBUTION']);
                h.showComponent(c,'taskDetailModal');
            }
        });
        $A.enqueueAction(action);
    },
    newCountdownComp : function(c,targetDateTime){
        var existingCountdownComp = c.find('countdownComp'+c.get('v.countdownCompCount'));
        if(existingCountdownComp != null){
            var intervalVar = existingCountdownComp.get('v.intervalVar');
            if(intervalVar !=null){
                clearInterval(intervalVar);
            }
        }
        c.set('v.countdownCompCount',c.get('v.countdownCompCount')+1);
        $A.createComponent(
            "c:Countdown", {
                "aura:id" : "countdownComp"+c.get('v.countdownCompCount'),
                "targetDateTime": targetDateTime
            },
            function(countdownCustomComp) {
                if (c.isValid()) {
                    var countdownComp = [];
                    countdownComp.push(countdownCustomComp);
                    c.set("v.countdownComp", countdownComp);
                }
            });   
    }
})