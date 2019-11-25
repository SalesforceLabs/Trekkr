({
    init : function(component,event,helper){
        var action = component.get('c.getFirstAidResponse'); 
        action.setParams({
            "firstAidId" : component.get('v.recordId')
        });
        action.setCallback(this, function(a){
            var state = a.getState(); 
            if(state == 'SUCCESS') {
                component.set('v.response', a.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    onClickCancel : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    onClickSave : function(component,event,helper){
        var action = component.get('c.saveFirstAidResponse'); 
        action.setParams({
            "firstAidId" : component.get('v.recordId'),
            "response" : component.get('v.response')
        });
        action.setCallback(this, function(a){
            var state = a.getState(); 
            if(state == 'SUCCESS') {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'Your response has been captured',
                    type: 'success'
                });
                toastEvent.fire();
                $A.get("e.force:refreshView").fire();
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(action);
    }
})