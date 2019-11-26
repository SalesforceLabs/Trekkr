 /*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 *
 * Controller for MenteeOpTaskList lightning component
 */
public with sharing class MenteeOpTaskListCntr {
    
    /**
*  This function returns all assigned operational tasks for the mentee
**/
    @AuraEnabled
    public static List<Assigned_Task__c> getMenteeTasks(){
        RecordTypeInfo opRecordTypeInfo = Schema.SObjectType.On_boarding_Task__c.getRecordTypeInfosByName().get('Operational');
        if(opRecordTypeInfo.isAvailable()){
            Id opRecordTypeId = opRecordTypeInfo.getRecordTypeId();
            List<String> fieldNames_AT = new List<String>();
            fieldNames_AT.add('Due_Today__c');
            fieldNames_AT.add('Target_Date_Time__c');
            fieldNames_AT.add('Task__c');
            fieldNames_AT.add('Status__c');
            fieldNames_AT.add('Assign_To__c');
            List<String> fieldName_TK = new List<String>();
            fieldName_TK.add('Name');
            fieldName_TK.add('Link__c');
            //fieldName_TK.add('Task_Due_Date__c');
            fieldName_TK.add('Description__c');
            if(FLSCheck.isAccessible(fieldNames_AT,'Assigned_Task__c') && FLSCheck.isAccessible(fieldName_TK,'On_boarding_Task__c')){
                return [SELECT Id,Due_Today__c,Target_Date_Time__c , 
                        Task__r.Name,Task__r.Link__c,
                        Task__r.Description__c ,Status__c
                        FROM Assigned_Task__c WHERE Assign_To__c = :UserInfo.getUserId() 
                        AND Task__c!= null AND Task__r.RecordTypeId =  :opRecordTypeId ORDER BY Status__c ASC];
            }
            else{
                System.debug('ot acceesbile');
            }
        }
        return new List<Assigned_Task__c>();
    }
    
    /**
*  This function updates the status of the task
**/
    @AuraEnabled
    public static Assigned_Task__c changeStatusOfTask(Assigned_Task__c task){
        if(task.Status__c == 'Completed'){
            task.Status__c = 'In-Progress';
        } else if(task.Status__c == 'In-Progress' || task.Status__c == 'New'){
            task.Status__c = 'Completed';
        }
        List<String> fieldNames = new List<String>();
        fieldNames.add('Status__c');
        if(FLSCheck.isUpdateable(fieldNames, 'Assigned_Task__c')){
            update new Assigned_Task__c(Id = task.Id, Status__c = task.Status__c);
        }
        return task;
    }
}