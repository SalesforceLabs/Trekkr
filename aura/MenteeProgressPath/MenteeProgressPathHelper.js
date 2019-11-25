({
	showSpinner : function(c){
        var ltngSpiner = c.find('ltngSpiner');
        $A.util.removeClass(ltngSpiner,'slds-hide');
        $A.util.addClass(ltngSpiner,'slds-show');
    },
    hideSpinner : function(c){
        var ltngSpiner = c.find('ltngSpiner');
        $A.util.removeClass(ltngSpiner,'slds-show');
        $A.util.addClass(ltngSpiner,'slds-hide');
    }
})