 /*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
public class MentorViewAssignedTaskCntr {
    
    @AuraEnabled
    public static Map<String,List<sObject>> getInitData(){
        Map<String,List<sObject>> initData = new Map<String,List<sObject>>();
        List<User> mentees = getMentees();
        initData.put('MENTEES',mentees);
        if(mentees.size() > 0){
            initData.put('MENTEES_CONT',getMenteeCont(mentees.get(0).Id));
        }
        return initData;
    }
    
    private static List<User> getMentees(){
        List<String> fieldNames = new List<String>();
        fieldNames.add('FirstName');
        fieldNames.add('LastName');
        fieldNames.add('Title');
        fieldNames.add('FullPhotoUrl');
        fieldNames.add('MobilePhone');
        fieldNames.add('Email');
        if(FLSCheck.isAccessible(fieldNames,'User')){
            List<User> users = [SELECT Id,FirstName,LastName,Title,FullPhotoUrl,MobilePhone,Email FROM User WHERE Mentor__c = :UserInfo.getUserId()];
            return users;
        }
        return new List<User>();
    }
    
    @AuraEnabled
    public static List<Assigned_Task__c> getMenteeCont(Id menteeUser){
        RecordTypeInfo  businessRecordTypeInfo = Schema.SObjectType.On_boarding_Task__c.getRecordTypeInfosByName().get('Business');
        if(businessRecordTypeInfo.isAvailable()){
            Id businessRecordTypeId = businessRecordTypeInfo.getRecordTypeId();
            List<String> fieldNames_AT = new List<String>();
            fieldNames_AT.add('Due_Today__c');
            fieldNames_AT.add('Target_Date_Time__c');
            //fieldNames_AT.add('Task__c');
            fieldNames_AT.add('Status__c');
            fieldNames_AT.add('Assign_To__c');
            fieldNames_AT.add('Overdue__c');
            List<String> fieldNameTK = new List<String>();
            fieldNameTK.add('Name');
            fieldNameTK.add('Link__c');
            fieldNameTK.add('Task_Due_Date__c');
            fieldNameTK.add('Description__c');
            if(FLSCheck.isAccessible(fieldNames_AT,'Assigned_Task__c') && FLSCheck.isAccessible(fieldNameTK,'On_boarding_Task__c')){
                List<Assigned_Task__c> atc = [SELECT Id,Overdue__c,Due_Today__c,Target_Date_Time__c , 
                                                    Task__r.Name,Task__r.Link__c,Task__r.Description__c ,Status__c,(SELECT Id FROM Child_Assigned_Tasks__r) 
                                                    FROM Assigned_Task__c WHERE Status__c != 'Cancelled' AND Assign_To__c = :menteeUser 
                                                    AND (Task__c =null OR Task__r.RecordTypeId =  :businessRecordTypeId) AND Parent_Assigned_Task__c = null];
                return atc;
            }
        }        
        return new List<Assigned_Task__c>();
    }
    
    @AuraEnabled
    public static Map<String,List<sObject>> getRecordRelateData(String recordId){
        Map<String,List<sObject>> recordRelateData = new Map<String,List<sObject>>();
        List<String> contentDocumentLinkFields = new List<String>();
        contentDocumentLinkFields.add('ContentDocumentId');
        contentDocumentLinkFields.add('LinkedEntityId');
        if(FLSCheck.isAccessible(contentDocumentLinkFields, 'ContentDocumentLink')){
            recordRelateData.put('ATTACHMENTS',[SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId]);
        }
        List<String> assignedTaskContributionFields = new List<String>();
        assignedTaskContributionFields.add('Date__c');
        assignedTaskContributionFields.add('Comments__c');
        //assignedTaskContributionFields.add('Task__c');
        if(FLSCheck.isAccessible(assignedTaskContributionFields, 'Assigned_Task_Contribution__c')){
            recordRelateData.put('TASKCONTRIBUTION',[SELECT Id,Date__c,Comments__c FROM Assigned_Task_Contribution__c]);
        }
        return recordRelateData;
    }
}