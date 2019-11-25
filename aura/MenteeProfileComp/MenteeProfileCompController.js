({
    doInit : function(component, event, helper) {
        helper.getMenteeAssignmentInfo(component,event);
    },
    onDataChange : function(c,e,h){
        h.getMenteeAssignmentInfo(c,e);
    },
    onClickMilestone : function(c,e,h){
        var scrollOptions = {
            top: 500,
            behavior: 'smooth'
        };
        window.scrollTo(scrollOptions);
        h.showMilestoneInformation(c,e);
    }
})