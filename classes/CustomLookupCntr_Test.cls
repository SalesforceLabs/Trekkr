/**
 * Test class for CustomLookupCntr
 **/ 
@isTest
public with sharing class CustomLookupCntr_Test {
    
    static testMethod void validateAllFunctions() {
        List<On_boarding_Task__c> lOnboardingTasks = TestDataUtil.getOnboardingTasks(2);
        insert lOnboardingTasks; 
        List<On_boarding_Task__c> fetchedLookupRecords = CustomLookupCntr.fetchLookUpValues('Test Onboarding Task 2','On_boarding_Task__c','Name','','');
        System.assertEquals(1,fetchedLookupRecords.size());
        sObject fetchedSingleRecord = CustomLookupCntr.getMySingleObject('On_boarding_Task__c','Name',lOnboardingTasks.get(0).Id,'');
        System.assert(fetchedSingleRecord != null);
    }
    
}