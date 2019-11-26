 /*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 *
 * Test class for MilestoneInformationCntr
 */ 
@isTest
public with sharing class MilestoneInformationCntr_Test {
    
    static testMethod void validate_getRecordRelateData(){
        List<On_boarding_Task__c> onboardingTasks = TestDataUtil.getOnboardingTasks(2);
        insert onboardingTasks;
        List<Assigned_Task__c> assignedTasks = TestDataUtil.getAssignedTask(onboardingTasks);
        insert assignedTasks;
        Map<String,List<sObject>> recordRelatedData = MilestoneInformationCntr.getRecordRelateData(assignedTasks.get(0).Id);
        System.assertEquals(0,recordRelatedData.get('ATTACHMENTS').size());
    }
    
    static testMethod void validate_getStatuses(){
        List<DataUtil.CustomPicklistRecord> statuses = MilestoneInformationCntr.getStatuses('In-Progress');
        System.assert(statuses.size()>0);
    }
    
    static testMethod void validate_updateTargetDate(){
        List<On_boarding_Task__c> onboardingTasks = TestDataUtil.getOnboardingTasks(2);
        insert onboardingTasks;
        List<Assigned_Task__c> assignedTasks = TestDataUtil.getAssignedTask(onboardingTasks);
        insert assignedTasks;
        String targetDateTime = '2019-02-21T12:30:02';
        MilestoneInformationCntr.updateTargetDate(assignedTasks.get(0).Id,targetDateTime);
        Assigned_Task__c assignedTask = [SELECT Id,Target_Date_Time__c 
                                                FROM Assigned_Task__c WHERE Id = :assignedTasks.get(0).Id];
        System.assertEquals(21,assignedTask.Target_Date_Time__c.day());
        System.assertEquals(02,assignedTask.Target_Date_Time__c.month());
        System.assertEquals(2019,assignedTask.Target_Date_Time__c.year());
        System.assertEquals(12,assignedTask.Target_Date_Time__c.hour());
        System.assertEquals(30,assignedTask.Target_Date_Time__c.minute());
        System.assertEquals(02,assignedTask.Target_Date_Time__c.second());
    }
    
    static testMethod void validate_updateStatusAndCurrentValue(){
        List<On_boarding_Task__c> onboardingTasks = TestDataUtil.getOnboardingTasks(2);
        insert onboardingTasks;
        List<Assigned_Task__c> assignedTasks = TestDataUtil.getAssignedTask(onboardingTasks);
        insert assignedTasks;        
        MilestoneInformationCntr.updateStatusAndCurrentValue(assignedTasks.get(0).Id,'Completed',100);
        Assigned_Task__c assignedTask = [SELECT Id,Current_Value__c,Status__c 
                                                FROM Assigned_Task__c WHERE Id = :assignedTasks.get(0).Id];
        System.assertEquals(100, assignedTask.Current_Value__c);
        System.assertEquals('Completed', assignedTask.Status__c);
    }
    
    static testMethod void validate_reopenTask(){
        List<On_boarding_Task__c> onboardingTasks = TestDataUtil.getOnboardingTasks(2);
        insert onboardingTasks;
        List<Assigned_Task__c> assignedTasks = TestDataUtil.getAssignedTask(onboardingTasks);
        insert assignedTasks;
        MilestoneInformationCntr.reopenTask(assignedTasks.get(0).Id,'There is some missing work to complete');
        Assigned_Task__c assignedTask = [SELECT Id,Reason_for_Reopen__c,Status__c 
                                                FROM Assigned_Task__c WHERE ID = :assignedTasks.get(0).Id LIMIT 1];
        System.assertEquals('There is some missing work to complete',assignedTask.Reason_for_Reopen__c);
        System.assertEquals('In-Progress',assignedTask.Status__c);
        
    }
    
    static testMethod void validate_markTaskAsCompleted(){
        User lUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' LIMIT 1];
        List<On_boarding_Task__c> onboardingTasks = TestDataUtil.getOnboardingTasks(2);
        insert onboardingTasks;
        List<Assigned_Task__c> assignedTasks = TestDataUtil.getAssignedTask(onboardingTasks);
        for(Assigned_Task__c assignedTask : assignedTasks){
            assignedTask.Assign_To__c = lUser.Id;
        }
        insert assignedTasks;
        MilestoneInformationCntr.markTaskAsCompleted(assignedTasks.get(0).Id);
        Assigned_Task__c assignedTask = [SELECT Id,Status__c 
                                                FROM Assigned_Task__c WHERE ID = :assignedTasks.get(0).Id LIMIT 1];
        System.assertEquals('Closed',assignedTask.Status__c);
    }
    
    static testMethod void validate_storeFeedback(){
        List<On_boarding_Task__c> onboardingTasks = TestDataUtil.getOnboardingTasks(2);
        insert onboardingTasks;
        List<Assigned_Task__c> assignedTasks = TestDataUtil.getAssignedTask(onboardingTasks);
        insert assignedTasks;
        MilestoneInformationCntr.storeFeedback(assignedTasks.get(0).Id,'Good Job!');
        Assigned_Task__c assignedTask = [SELECT Id,Feedback__c 
                                                FROM Assigned_Task__c WHERE ID = :assignedTasks.get(0).Id LIMIT 1];
        System.assertEquals('Good Job!',assignedTask.Feedback__c);
    }
    
}