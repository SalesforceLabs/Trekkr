({
   selectRecord : function(component, event, helper){
	   var fieldName = component.get('v.fieldName');
	   //console.log('selected field name : ' + fieldName);
    // get the selected record from list
      var getSelectRecord = component.get("v.oRecord");

	  //console.log('selected object : ' , getSelectRecord);
    // call the event
      var compEvent = component.getEvent("oSelectedRecordEvent");
    // set the Selected sObject Record to the event attribute.
         compEvent.setParams({
             "recordByEvent" : getSelectRecord,
             "lookupUniqueId" : component.get('v.lookupUniqueId')
         });
    // fire the event
         compEvent.fire();
    },
	doInit : function(component, event, helper) {
        var getSelectRecord = component.get("v.oRecord");
        var fieldName = component.get("v.fieldName");
        var SuffixobjectFieldName = component.get("v.SuffixobjectFieldName");
        //console.log('Record : ' , getSelectRecord);
        if(SuffixobjectFieldName != ''){
            var recordName = getSelectRecord[fieldName]+' - '+getSelectRecord[SuffixobjectFieldName];
        }else{
            var recordName = getSelectRecord[fieldName];
        }
		component.set('v.recordName', recordName);
     }
})