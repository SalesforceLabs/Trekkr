({
    showToast : function(title,message,type){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message: message,
            duration:' 2000',
            type: type
        });
        toastEvent.fire();
    },
})