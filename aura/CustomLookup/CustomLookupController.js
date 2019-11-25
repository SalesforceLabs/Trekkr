({
    onChangeShowError : function(c,e,h){
        if(c.get('v.showError')){
            $A.util.addClass(c.find('customLookupIT'), 'slds-has-error');
            c.find('customLookupIT').set("v.errors", [{message: c.get('v.errorMessage') }]);  
        }else{
            $A.util.removeClass(c.find('customLookupIT'), 'slds-has-error');
            c.find('customLookupIT').set("v.errors",null);  
        }
    },
    doInit : function(component,event,helper){
        helper.predefinedValue(component,event);
    },
    onfocus : function(component,event,helper){
        console.log('coshea : onFocus');
        var forOpen = component.find("searchRes");
        $A.util.addClass(forOpen, 'slds-is-close');
        // Get Default 5 Records order by createdDate DESC
        var getInputkeyWord = '';
        //Not showing the search results
        //helper.searchHelper(component,event,getInputkeyWord);
    },
    onfocusOut : function(component,event,helper){
        console.log('coshea : onFocusOut');
        var forOpen = component.find("searchRes");
        $A.util.removeClass(forOpen, 'slds-is-open');
        $A.util.addClass(forOpen, 'slds-is-close');
        //Get Default 5 Records order by createdDate DESC
        // var getInputkeyWord = '';
        // helper.searchHelper(component,event,getInputkeyWord);
    },
    keyPressController : function(component, event, helper) {
        // get the search Input keyword
        var getInputkeyWord = component.get("v.SearchKeyWord");
        // check if getInputKeyWord size id more then 0 then open the lookup result List and
        // call the helper
        // else close the lookup result List part.
        if( getInputkeyWord.length > 0 ){
            var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchHelper(component,event,getInputkeyWord);
        }
        else{
            component.set("v.listOfSearchRecords", null );
            var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
        }
        
    },
    
    // function for clear the Record Selaction
    clear :function(component,event,helper){
        
        var pillTarget = component.find("lookup-pill");
        var lookUpTarget = component.find("lookupField");
        var lookupIcon = component.find("lookupIcon");
        
        $A.util.addClass(pillTarget, 'slds-hide');
        $A.util.removeClass(pillTarget, 'slds-show');
        
        $A.util.addClass(lookupIcon, 'slds-show');
        $A.util.removeClass(lookupIcon, 'slds-hide');
        
        $A.util.addClass(lookUpTarget, 'slds-show');
        $A.util.removeClass(lookUpTarget, 'slds-hide');
        
        component.set("v.SearchKeyWord",null);
        component.set("v.listOfSearchRecords", null );
        component.set("v.selectedRecord", {} );
        
        var compEvent = component.getEvent("oUnSelectRecordEvent");
        // set the Selected sObject Record to the event attribute.
        compEvent.setParams({
            "lookupUniqueId" : component.get('v.lookupUniqueId')
        });
        // fire the event
        compEvent.fire();
    },
    
    // This function call when the end User Select any record from the result list.
    handleComponentEvent : function(component, event, helper) {
        // get the selected Account record from the COMPONETN event
        var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        component.set("v.selectedRecord" , selectedAccountGetFromEvent);
        if(component.get('v.showLookupPillOnSelection') == true){
            var selectedRecordName = selectedAccountGetFromEvent[component.get('v.objectFieldName')];
            component.set('v.selectedRecordName', selectedRecordName);
            
            var forclose = component.find("lookup-pill");
            $A.util.addClass(forclose, 'slds-show');
            $A.util.removeClass(forclose, 'slds-hide');
            
            var lookupIcon = component.find("lookupIcon");
            $A.util.addClass(lookupIcon, 'slds-hide');
            $A.util.removeClass(lookupIcon, 'slds-show');
            
            var lookUpTarget = component.find("lookupField");
            $A.util.addClass(lookUpTarget, 'slds-hide');
            $A.util.removeClass(lookUpTarget, 'slds-show');
            
        }else{
            var selectedRecordName = selectedAccountGetFromEvent[component.get('v.objectFieldName')];
            component.set('v.SearchKeyWord', selectedRecordName);
        }
        
        var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
    },
    // automatically call when the component is done waiting for a response to a server request.
    hideSpinner : function (component, event, helper) {
        // var spinner = component.find('spinner');
        // var evt = spinner.get("e.toggle");
        // evt.setParams({ isVisible : false });
        // evt.fire();
        var spinner = component.find("spinner");
        // $A.util.toggleClass(spinner, "slds-hide");
        $A.util.addClass(spinner, 'slds-hide');
    },
    // automatically call when the component is waiting for a response to a server request.
    showSpinner : function (component, event, helper) {
        // var spinner = component.find('spinner');
        // var evt = spinner.get("e.toggle");
        // evt.setParams({ isVisible : true });
        // evt.fire();
        var spinner = component.find("spinner");
        // $A.util.toggleClass(spinner, "slds-hide");
        $A.util.removeClass(spinner, 'slds-hide');
        // $A.util.addClass(forOpen, 'slds-is-close');
    },
    myMouseOver : function (component, event, helper) {
        //console.log('mouse over list');
        component.set('v.mouseOverList', true);
    },
    myMouseOut : function (component, event, helper) {
        //console.log('mouse left list');
        component.set('v.mouseOverList', false);
        window.setTimeout(
            $A.getCallback(function() {
                // cmp.set("v.visible", true);
                var mouseBoolean = component.get('v.mouseOverList');
                if(mouseBoolean == false) {
                    //console.log('CLOSING THE LIST');
                    var forOpen = component.find("searchRes");
                    $A.util.removeClass(forOpen, 'slds-is-open');
                    $A.util.addClass(forOpen, 'slds-is-close');
                }
            }), 100
        );
    },
    createNewRecord : function (component, event, helper) {
        if(component.get('v.createRecordType')) {
            var createRecordEvent = $A.get("e.force:createRecord");
            var apiName = component.get('v.objectAPIName');
            createRecordEvent.setParams({
                "entityApiName": apiName,
                "recordTypeId": component.get('v.createRecordType')
            });
            createRecordEvent.fire();
        } else {
            var createRecordEvent = $A.get("e.force:createRecord");
            var apiName = component.get('v.objectAPIName');
            createRecordEvent.setParams({
                "entityApiName": apiName
            });
            createRecordEvent.fire();
        }
    }
    
})