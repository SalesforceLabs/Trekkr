/** Test class for ExtendMenteeCntr **/
@isTest
public with sharing class ExtendMenteeCntr_Test {
    
    static testMethod void validate_getMenteeUsers(){
        List<ExtendMenteeCntr.UserWrapper> menteeUsers = ExtendMenteeCntr.getMenteeUsers();
        User lUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' LIMIT 1];
        User mentorUser = [SELECT Id FROM User WHERE Id != :lUser.Id LIMIT 1];
        lUser.Mentor__c = mentorUser.Id;
        lUser.On_boarding_End_Date__c = System.today();
        update lUser;
        new ExtendMenteeCntr.UserWrapper(lUser,10);
        Date onboardingEndDate = System.today()+10;
        ExtendMenteeCntr.extendOnboardingDate(lUser.Id,String.valueOf(onboardingEndDate), 'You need to learn more');
        ExtendMenteeCntr.markOnboardingCompleted(lUser.Id);
        User updatedUser = [SELECT Id, Onboarding_Completed__c, On_boarding_End_Date__c,
                      Reason_for_Onboarding_Extend__c FROM USER WHERE Id = :lUser.Id];
        System.assertEquals(true, updatedUser.Onboarding_Completed__c);
        System.assertEquals('You need to learn more', updatedUser.Reason_for_Onboarding_Extend__c);
        System.assertEquals(onboardingEndDate, updatedUser.On_boarding_End_Date__c);
    }
}