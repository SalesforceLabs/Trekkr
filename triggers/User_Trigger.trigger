trigger User_Trigger on User (after update) {
    
    for(User lUser : Trigger.New){
        if(lUser.Mentor__c!=null && lUser.On_boarding_End_Date__c!=null &&
           lUser.On_boarding_End_Date__c > Trigger.oldMap.get(lUser.Id).On_boarding_End_Date__c){
               System.debug('inside');
               Decimal daysExtended = Trigger.oldMap.get(lUser.Id).On_boarding_End_Date__c.daysBetween(lUser.On_boarding_End_Date__c);
               Date newOnboardingEndDate = lUser.On_boarding_End_Date__c;
               NotificationsManager.notifyMenteeForOnboardingExtend(lUser.Id,daysExtended,newOnboardingEndDate.format());
           }
        else if(lUser.Mentor__c !=null && lUser.Vision__c!=null && lUser.Values__c  !=null && 
                ( (Trigger.oldMap.get(lUser.Id).Vision__c == null || 
                 !TriggerUtil.isSame(Trigger.oldMap.get(lUser.Id).Vision__c,lUser.Vision__c)) || 
               	 (Trigger.oldMap.get(lUser.Id).Values__c == null || 
                  !TriggerUtil.isSame(Trigger.oldMap.get(lUser.Id).Values__c ,lUser.Values__c )))){
            NotificationsManager.notifyMentorForVisionValuesUpdate(lUser.Id,lUser.Mentor__c, lUser.Vision__c,lUser.Values__c);
        }
    }
    
}