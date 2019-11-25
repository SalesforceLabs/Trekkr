({
    doInit : function(component, event, helper) {
        component.set('v.noOfMilestones',component.get('v.menteeAssignmentInformation').length);
    },
    onClickCheckpoint : function(c,e,h){
        var selectedCheckpointId = e.currentTarget.id;
        c.set('v.selectedMilestoneName',selectedCheckpointId.split('~')[0]);
        c.set('v.selectedMilestoneIndex',selectedCheckpointId.split('~')[1]);
        var menteeAssignmentInformation = c.get('v.menteeAssignmentInformation');
        var selectedMenteeAssignmentInformation = menteeAssignmentInformation[selectedCheckpointId.split('~')[1]];
        c.set('v.selectedMilestonePrograms',selectedMenteeAssignmentInformation.programs);
        var action = c.get('v.onClickMilestone');
        action.setCallback(this, function(response){
            
        });
        $A.enqueueAction(action);
    }
})