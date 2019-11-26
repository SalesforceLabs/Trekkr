 /*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 *
 * Utility class for test data creation
 */
public with sharing class TestDataUtil {
    
    /**
*  Test utility function for returning n number of onboarding tasks
**/
    public static List<On_boarding_Task__c> getOnboardingTasks(Integer count){
        return getAutoAssignOnboardingTasks(count,false);
    }
    
    /**
*  Test utility function for creating n number of onboarding tasks that maybe auto-assigned
**/
    public static List<On_boarding_Task__c> getAutoAssignOnboardingTasks(Integer count,boolean autoAssign){
        List<On_boarding_Task__c> onboardingTasks = new List<On_boarding_Task__c>();
        for(Integer i=1;i<=count;i++){
            On_boarding_Task__c onboardingTask = new On_boarding_Task__c(
                Name = 'Test Onboarding Task '+i, 
                Description__c = 'Test onboarding Description '+i,
                //Task_Due_Date__c = System.today(),
                Auto_Assign_del__c = autoAssign
            );
            onboardingTasks.add(onboardingTask); 
        }
        return onboardingTasks;
    }
    
    /** Test utility function to get creates a User Role record **/
    public static User_Role__c getUserRole(String name){
        return new User_Role__c(Name = name);
    }
    
    /** Test utility function to assign a User Role to a User **/
    public static User_User_Role_Junction__c assignUserRoleToUser(Id userId,Id userRoleId){
        return new User_User_Role_Junction__c(User__c = userId, User_Role__c = userRoleId);
    }
    
    /** Test utility function to assign Program to a User **/
    public static Assigned_Task__c assignProgramToUser(Id programId, Id userId){
        return new Assigned_Task__c(Assign_To__c = userId, Onboarding_Program__c = programId,Milestone__c = 'Milestone 1');
    }
    
    /** Test utility function to assign User Role to a Program **/ 
    public static Onboarding_Program_User_Role_Junction__c assignUserRoleToProgram(Id userRoleId, Id onboardingProgramId){
        return new Onboarding_Program_User_Role_Junction__c (
            Onboarding_Program__c  = onboardingProgramId,
            User_Role__c	 = userRoleId
        );
    }
    
    /** Test utility function to creates @count number of Onboarding Programs  **/
    public static List<Onboarding_Program__c> getOnboardingPrograms(Integer count){
        List<Onboarding_Program__c> onboardingPrograms = new List<Onboarding_Program__c>();
        for(Integer i=1;i<=count;i++){
            Onboarding_Program__c program = new Onboarding_Program__c(
                Name = 'Test Program '+i,
                Description__c = 'Test Program Description '+i
            );
            onboardingPrograms.add(program);
        }
        return onboardingPrograms;
    }
    
    /**
*  Test utility function for returning Assigned Tasks
**/
    public static List<Assigned_Task__c> getAssignedTask(List<On_boarding_Task__c> onboardingTasksToAssign){
        List<Assigned_Task__c> assignedTasks = new List<Assigned_Task__c>();
        for(On_boarding_Task__c onboardingTaskToAssign : onboardingTasksToAssign){
            Assigned_Task__c lAssignedTask = new Assigned_Task__c(
                Task__c  = onboardingTaskToAssign.Id
            );
            assignedTasks.add(lAssignedTask);
        }
        return assignedTasks;
    }
    
    /**
*  Test utility function for returning Assigned Task contributions
**/
    public static List<Assigned_Task_Contribution__c> getAssignedContribution(List<Assigned_Task__c> assignedTasks){
        List<Assigned_Task_Contribution__c> assignedTaskContributions = new List<Assigned_Task_Contribution__c>();
        for(Assigned_Task__c assignedTask : assignedTasks){
            Assigned_Task_Contribution__c contribution = new Assigned_Task_Contribution__c(
                //Task__c = assignedTask.Id,
                Date__c = System.today(),
                Comments__c = 'Test Contribution Comments'
            );
            assignedTaskContributions.add(contribution);
        }
        return assignedTaskContributions;        
    }
    
    /** Test utility function to creates First Aid record **/
    public static First_Aid__c getFirstAid(){
        return new First_Aid__c(First_Aid_Description__c = 'Test First Aid', Response__c = 'Test Response');
    }
    
    /**
*  Test utility function for craeting and returning Assigned Tasks
**/
    public static User getUser(){
        UserRole r ;
        User u = new User(
            ProfileId = [SELECT Id FROM Profile LIMIT 1].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            UserRoleId = [SELECT Id FROM UserRole LIMIT 1].Id
        );
        return u;
    }
    
    /**
*  Test utility function for creating and returning Assigned Tasks
**/
    public static Assigned_Task__c getAssignedTask(){
        Assigned_Task__c aTask = new Assigned_Task__c(Status__c  = 'New');
        return aTask;
    }
}