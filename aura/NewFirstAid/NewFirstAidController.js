({
	handleLoad: function(cmp, event, helper) {
        cmp.set('v.disabled', false);
    },
    handleSubmit: function(cmp, event, helper) {
        cmp.set('v.disabled', true);
    },
    handleError: function(cmp, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error",
            "message": "Please try again.",
            "type": "error"
        });
        toastEvent.fire();
    },
    handleSuccess: function(cmp, event, helper) {
        cmp.set('v.showSpinner', false);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "First Aid Requested",
            "message": "Your First Aid request has been successfully raised.",
            "type": "success"
        });
        toastEvent.fire();
        cmp.set('v.disabled', false);
        cmp.set('v.bodyVisible', false);
        $A.get('e.force:refreshView').fire();
    }
})