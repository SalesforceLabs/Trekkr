 /*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 *
 * Controller for Milestone Information Lightning component
 */ 
public with sharing class MilestoneInformationCntr {
    
    /**
* Aura function to retrieve attachments and task contributions for a particular assigned task.
**/    
    @AuraEnabled
    public static Map<String,List<sObject>> getRecordRelateData(String recordId){
        Map<String,List<sObject>> recordRelateData = new Map<String,List<sObject>>();
        List<String> contentDocumentLinkFields = new List<String>();
        contentDocumentLinkFields.add('ContentDocumentId');
        contentDocumentLinkFields.add('LinkedEntityId');
        if(FLSCheck.isAccessible(contentDocumentLinkFields, 'ContentDocumentLink')){
            recordRelateData.put('ATTACHMENTS',[SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId]);
        }
        return recordRelateData;
    }
    
    /** Returns Picklist values for Status field **/
    @AuraEnabled
    public static List<DataUtil.CustomPicklistRecord> getStatuses(String currentStatus){
        List<DataUtil.CustomPicklistRecord> picklistValues = new List<DataUtil.CustomPicklistRecord>();
        List<String> fields_AT = new List<String>();
        fields_AT.add('Status__c');
        if(FLSCheck.isAccessible(fields_AT,'Assigned_Task__c')){
            Schema.DescribeFieldResult fieldResult = Assigned_Task__c.Status__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry f : ple){
                Boolean isSelected = false;
                if(currentStatus == f.getLabel() || currentStatus == f.getValue()){
                    isSelected = true;
                }
                picklistValues.add(new DataUtil.CustomPicklistRecord(f.getLabel(), f.getValue(),isSelected));
            }       
        }
        return picklistValues;
    }
    
    /** Updates the TargetDate of Assigned Task **/
    @AuraEnabled
    public static void updateTargetDate(String assignedTaskId,String targetDateTimeString){
        List<String> fields_AT = new List<String>();
        fields_AT.add('Target_Date_Time__c');
        if(FLSCheck.isUpdateable(fields_AT, 'Assigned_Task__c')){
            update new Assigned_Task__c(Id = assignedTaskId,Target_Date_Time__c  = DataUtil.toDateTime(targetDateTimeString));
        }
    }
    
    /** Changes the status of Assigned Task to In-Progress with Reopen message **/
    @AuraEnabled
    public static void reopenTask(String assignedTaskId, String reopenReason){
        List<String> fields_AT = new List<String>();
        fields_AT.add('Reason_for_Reopen__c');
        fields_AT.add('Status__c');
        if(FLSCheck.isUpdateable(fields_AT,'Assigned_Task__c')){
            List<Assigned_Task__c> listAT = [SELECT Id, Reason_for_Reopen__c, Status__c  FROM 
                                                    Assigned_Task__c WHERE Id = :assignedTaskId];
            List<Assigned_Task__c> listToUpdate = new List<Assigned_Task__c>();
            for(Assigned_Task__c at : listAT){
                at.Status__c = 'In-Progress';
                at.Reason_for_Reopen__c = reopenReason;
                listToUpdate.add(at);
            }
            update listToUpdate;
        }
    }
    
    /** Changes the status of Assigned Task to Closed **/
    @AuraEnabled
    public static void markTaskAsCompleted(String assignedTaskId){
        List<String> fields_AT = new List<String>();
        fields_AT.add('Status__c');
        if(FLSCheck.isUpdateable(fields_AT,'Assigned_Task__c')){
            update new Assigned_Task__c(Id = assignedTaskId, Status__c = 'Closed');
        }
    }
    
    /** Changes the status and current value of Assigned Task **/
    @AuraEnabled
    public static void updateStatusAndCurrentValue(String assignedTaskId,String status,Decimal currentValue){
        try{
            List<String> fields_AT = new List<String>();
            fields_AT.add('Status__c');
            fields_AT.add('Current_Value__c');
            if(FLSCheck.isUpdateable(fields_AT,'Assigned_Task__c')){
                update new Assigned_Task__c(Id = assignedTaskId,Status__c = status,Current_Value__c = currentValue);
            }
            system.debug('NO FLS');
        }catch(Exception e){
            System.debug('error '+e);
        }
    }
    
    /** Adds Feedback to the Assigned Task **/
    @AuraEnabled
    public static void storeFeedback(String assignedProgramId, String feedbackMessage){
        List<String> fields_AT = new List<String>();
        fields_AT.add('Feedback__c');
        if(FLSCheck.isUpdateable(fields_AT,'Assigned_Task__c')){
            update new Assigned_Task__c (Id = assignedProgramId, Feedback__c = feedbackMessage);
        }
    }
    
    
}