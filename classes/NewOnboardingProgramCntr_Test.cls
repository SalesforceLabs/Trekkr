/**
 * Test class for NewOnboardingProgramCntr
 **/
@IsTest(SeeAllData=true)
public with sharing class NewOnboardingProgramCntr_Test {
    
    static testMethod void validate_getInit(){
        User_Role__c userRole = TestDataUtil.getUserRole('Software Engineer');
        insert userRole;
        Map<String,List<Object>> initMap = NewOnboardingProgramCntr.getInit();
        System.assertEquals(initMap.get('userRoles').size(),13);
    }
    
    static testMethod void validate_OnboardingnProgramFunctions(){
        List<User> users = [SELECT Id FROM USER WHERE Profile.Name = 'System Administrator' LIMIT 1];
        List<Onboarding_Program__c> onboardingPrograms = TestDataUtil.getOnboardingPrograms(1);
        List<On_boarding_Task__c> onboardingTasks = TestDataUtil.getOnboardingTasks(2);
        insert onboardingTasks;
        User_Role__c userRole1 = TestDataUtil.getUserRole('Software Engineer');
        insert userRole1;
        User_Role__c userRole2 = TestDataUtil.getUserRole('Software Engineer II');
        insert userRole2;
        String selectedRoles = userRole1.Id+';'+userRole2.Id; 
        Onboarding_Program__c insertedProgram = NewOnboardingProgramCntr.insertNewOnboardingProgram(
            JSON.serialize(onboardingPrograms.get(0)),JSON.serialize(onboardingTasks), selectedRoles);
        Onboarding_Program__c retrievedProgram = NewOnboardingProgramCntr.getProgramDetails(insertedProgram.Id);
        System.assertEquals(retrievedProgram.Id, insertedProgram.Id);
        DateTime nowDateTime = DateTime.now();
        NewOnboardingProgramCntr.assignProgram(retrievedProgram.Id,users.get(0).Id,nowDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''),'Milestone 1');
        List<Assigned_Task__c> assignedTasks = [SELECT Id,Assign_To__c FROM Assigned_Task__c 
                                                       WHERE Onboarding_Program__c = :retrievedProgram.Id];
        for(Assigned_Task__c assignedTask : assignedTasks){
            System.assertEquals(assignedTask.Assign_To__c, users.get(0).Id);
        }
        On_boarding_Task__c onboardingTaskDetail = NewOnboardingProgramCntr.getTaskDetails(onboardingTasks.get(0).Id);
    }
    
}