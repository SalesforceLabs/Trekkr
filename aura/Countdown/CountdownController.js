({
	doInit : function(component, event, helper) {
        var targetDateTime = component.get('v.targetDateTime');
        if(targetDateTime != null && targetDateTime != '')
            helper.setupCountdown(component,new Date(targetDateTime).getTime());
	}
})