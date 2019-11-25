({
    doInit : function(component, event, helper) {
        var parentClass = 'slds-notify slds-notify_alert slds-theme_alert-texture ';
        var iconName = '';
        var alertType = component.get('v.alertType');
        switch(alertType){
            case 'WARNING':
                parentClass+= 'slds-theme_warning';
                iconName = 'utility:warning';
                break;
            case 'ERROR':
                parentClass+= 'slds-theme_error';
                iconName = 'utility:error';
                break;
            case 'OFFLINE':
                parentClass+= 'slds-theme_offline';
                iconName = 'utility:offline';
                break;
            default :
                parentClass+= 'slds-theme_info';
                iconName = 'utility:user';
                break;
        }
        component.set('v.parentClass',parentClass);
        component.set('v.iconName',iconName);
        if(!$A.util.isEmpty(component.get('v.onClickClose'))){
            setTimeout(function() {
                $A.enqueueAction(component.get('v.onClickClose'));
            }, 1500);
        }
    }
})