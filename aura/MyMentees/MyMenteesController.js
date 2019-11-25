({
    onClickMentee : function(component, event, helper) {
        helper.showSpinner(component);
        component.set('v.selectedMentee',component.get('v.menteesList['+event.currentTarget.id+']'));
        helper.hideSpinner(component);
        $A.enqueueAction(component.get('v.onClickViewProfile'));
    }
})