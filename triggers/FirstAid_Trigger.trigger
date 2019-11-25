trigger FirstAid_Trigger on First_Aid__c (after insert) {

    if(Trigger.isAfter && Trigger.isInsert){
        TriggerUtil.shareFirstAidRecord(Trigger.New,true);
    }
}