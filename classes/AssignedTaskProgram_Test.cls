 /*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 *
 * Test class for AssignedTaskProgram_Trigger 
 */
@isTest
public without sharing class AssignedTaskProgram_Test {

    static testMethod void validate_AssignTaskProgram(){
        User lUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' LIMIT 1];
        List<On_boarding_Task__c> onboardingTask = TestDataUtil.getOnboardingTasks(1);
        onboardingTask.get(0).RecordTypeId = Schema.SObjectType.On_boarding_Task__c.getRecordTypeInfosByName().get('Operational').getRecordTypeId();
        insert onboardingTask;
        List<Onboarding_Program__c> onboardingProgram = TestDataUtil.getOnboardingPrograms(1);
        insert onboardingProgram;
        Assigned_Task__c assignedProgram = TestDataUtil.assignProgramToUser(onboardingProgram.get(0).Id,lUser.Id);
        insert assignedProgram;
        List<Assigned_Task__c> assignedTasks = TestDataUtil.getAssignedTask(onboardingTask);
        assignedTasks.get(0).Status__c = 'New';
        assignedTasks.get(0).Parent_Assigned_Task__c = assignedProgram.Id;
        insert assignedTasks;
        assignedTasks.get(0).Status__c = 'Completed';  
        update assignedTasks.get(0);
        Assigned_Task__c assignedProgram_1 = TestDataUtil.assignProgramToUser(onboardingProgram.get(0).Id,lUser.Id);
        assignedProgram_1.Status__c = 'New';
        insert assignedProgram_1;
        assignedProgram_1.Status__c = 'Completed';
        update assignedProgram_1;
        assignedProgram_1.Feedback__c = 'Test Feedback';
        update assignedProgram_1;
        List<On_boarding_Task__c> onboardingTask_1 = TestDataUtil.getOnboardingTasks(1);
        insert onboardingTask_1;
        List<Assigned_Task__c> assignedTasks_1 = TestDataUtil.getAssignedTask(onboardingTask_1);
        assignedTasks_1.get(0).Status__c = 'New';
        insert assignedTasks_1.get(0);
        assignedTasks_1.get(0).Status__c = 'Completed';
        update assignedTasks_1.get(0); 
        assignedTasks_1.get(0).Status__c = 'In-Progress';
        assignedTasks_1.get(0).Reason_for_Reopen__c = 'Reopened the task';
        update assignedTasks_1.get(0);
        assignedTasks_1.get(0).Status__c = 'Closed';
        update assignedTasks_1.get(0);
        User updatedUser = [SELECT Id, Energizers__c FROM User WHERE Id = :lUser.Id];
        System.assertEquals(100, updatedUser.Energizers__c);
    }
}