({
    searchHelper : function(component,event,getInputkeyWord) {
        // call the apex class method
        var action = component.get("c.fetchLookUpValues");
        // set param to method
        action.setParams({
            'searchKeyWord': getInputkeyWord,
            'ObjectName' : component.get("v.objectAPIName"),
            'fieldName' : component.get("v.objectFieldName"),
            'whereClause' : component.get("v.whereClause"),
            "SuffixobjectFieldName" : component.get("v.SuffixobjectFieldName")
        });
        // set a callBack
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No results');
                } else {
                    component.set("v.Message", '');
                }
                // set searchResult list with return value from server.
                component.set("v.listOfSearchRecords", storeResponse);
            }
            
        });
        // enqueue the Action
        $A.enqueueAction(action);
        
    },
    predefinedValue : function(component,event) {
        var predefinedRecordId = component.get('v.predefinedRecordId');
        if(predefinedRecordId) {
            console.log('predefined value found');
            console.log(component.get("v.objectAPIName"));
            var action = component.get("c.getMySingleObject");
            action.setParams({
                'objectName' : component.get("v.objectAPIName"),
                'fieldName' : component.get("v.objectFieldName"),
                'recordId' : predefinedRecordId,
                "SuffixobjectFieldName" : component.get("v.SuffixobjectFieldName")
            });
            action.setCallback(this, function(a) {
                //component.set("v.myAttribute", a.getReturnValue());
                var selectedAccountGetFromEvent = a.getReturnValue();
                component.set("v.selectedRecord" , selectedAccountGetFromEvent);
                
                console.log('selectedRecord : ' , component.get("v.selectedRecord"));
                
                var selectedRecordName = selectedAccountGetFromEvent[component.get('v.objectFieldName')];
                component.set('v.selectedRecordName', selectedRecordName);
                
                var forclose = component.find("lookup-pill");
                $A.util.addClass(forclose, 'slds-show');
                $A.util.removeClass(forclose, 'slds-hide');
                
                if(component.get("v.objectAPIName") === 'User' || component.get("v.objectAPIName") === 'User_Role__c'){
                   var disableRemove= component.find("removePill");
                   $A.util.addClass(disableRemove, 'slds-hide');
                }
                
                var lookupIcon = component.find("lookupIcon");
                $A.util.addClass(lookupIcon, 'slds-hide');
                $A.util.removeClass(lookupIcon, 'slds-show');
                
                var forclose = component.find("searchRes");
                $A.util.addClass(forclose, 'slds-is-close');
                $A.util.removeClass(forclose, 'slds-is-open');
                
                var lookUpTarget = component.find("lookupField");
                $A.util.addClass(lookUpTarget, 'slds-hide');
                $A.util.removeClass(lookUpTarget, 'slds-show');
            });
            $A.enqueueAction(action);
        }
    }
})