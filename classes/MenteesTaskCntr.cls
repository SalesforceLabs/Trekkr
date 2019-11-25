/**
* Controller for Mentees Task Lightning Component
**/
public with sharing class MenteesTaskCntr {
    
    /**
* Aura function to return all assigned tasks for the logged in user (Mentee) categorized with Status 
**/
    @AuraEnabled
    public static Map<String,List<object>> getInitData(){
        Map<String,List<object>> initDataMap = new Map<String,List<object>>();
        List<AssignedTasksWrapper> assignedTasksWrappers = new List<AssignedTasksWrapper>();
        String userId = UserInfo.getUserId();
        List<Assigned_Task__c> thisMonthDue = new List<Assigned_Task__c>();
        List<Assigned_Task__c> inProgress = new List<Assigned_Task__c>();
        List<Assigned_Task__c> completed = new List<Assigned_Task__c>();
        RecordTypeInfo  businessRecordTypeInfo = Schema.SObjectType.On_boarding_Task__c.getRecordTypeInfosByName().get('Business');
        if(businessRecordTypeInfo.isAvailable()){
            Id businessRecordTypeId = businessRecordTypeInfo.getRecordTypeId();
            List<String> fieldNames_AT = new List<String>();
            fieldNames_AT.add('Due_Today__c');
            fieldNames_AT.add('Target_Date_Time__c');
            fieldNames_AT.add('Task__c');
            fieldNames_AT.add('Status__c');
            fieldNames_AT.add('Assign_To__c');
            List<String> fieldNameTK = new List<String>();
            fieldNameTK.add('Name');
            fieldNameTK.add('Link__c');
            fieldNameTK.add('Task_Due_Date__c');
            fieldNameTK.add('Description__c');
            if(FLSCheck.isAccessible(fieldNames_AT,'Assigned_Task__c') && FLSCheck.isAccessible(fieldNameTK,'On_boarding_Task__c')){
                List<Assigned_Task__c> assignedTasks = [SELECT Id
                                                             ,Due_Today__c,Target_Date_Time__c , 
                                                              Task__r.Name,Task__r.Link__c,Task__r.Description__c ,Status__c,(SELECT Id FROM Child_Assigned_Tasks__r) 
                                                              FROM Assigned_Task__c WHERE Status__c != 'Cancelled' AND Assign_To__c = :userId AND (Task__c =null OR Task__r.RecordTypeId =  :businessRecordTypeId)];
                for(Assigned_Task__c assignedTask : assignedTasks){
                    if(assignedTask.Child_Assigned_Tasks__r.size() == 0){
                        if(assignedTask.Target_Date_Time__c!=null && assignedTask.Target_Date_Time__c.month() == System.today().month() && assignedTask.Status__c == 'New'){
                            thisMonthDue.add(assignedTask);
                        }else if(assignedTask.Status__c == 'In-Progress'){
                            inProgress.add(assignedTask);
                        }else if(assignedTask.Status__c == 'Completed' || assignedTask.Status__c == 'Closed'){
                            completed.add(assignedTask);
                        }
                    }
                }
                assignedTasksWrappers.add(new AssignedTasksWrapper('This Month\'s Tasks',thisMonthDue,'#e99f63'));
                assignedTasksWrappers.add(new AssignedTasksWrapper('In Progress',inProgress,'#f6ce6f'));
                assignedTasksWrappers.add(new AssignedTasksWrapper('Completed',completed,'#77c8cc'));
            }
            initDataMap.put('KANBAN_DATA',assignedTasksWrappers);
        }
        return initDataMap;
    }
    
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
        List<String> assignedTaskContributionFields = new List<String>();
        assignedTaskContributionFields.add('Date__c');
        assignedTaskContributionFields.add('Comments__c');
        //assignedTaskContributionFields.add('Task__c');
        if(FLSCheck.isAccessible(assignedTaskContributionFields, 'Assigned_Task_Contribution__c')){
            recordRelateData.put('TASKCONTRIBUTION',[SELECT Id,Date__c,Comments__c FROM Assigned_Task_Contribution__c ]);
        }
        return recordRelateData;
    }
    
    /**
*  Wrapper class for storing assigned tasks along with the task type (status) and the header color
**/ 
    public class AssignedTasksWrapper{
        @AuraEnabled
        public String taskType {get; set;}
        @AuraEnabled
        public List<Assigned_Task__c> records {get; set;}
        @AuraEnabled
        public String headingColor{get;set;}
        
        public AssignedTasksWrapper(string taskType,List<sobject> recs,String headingColor){
            this.records = recs;
            this.taskType = taskType;
            this.headingColor = headingColor;
        }
    }
    
    /**
* Aura function to update the status of a particular assigned tasks when user drags and drops the task from the kanban.
**/
    @AuraEnabled
    public static List<AssignedTasksWrapper> updateAssignedTask(String kanbanRecords, String recordToUpdate,String dragCategory, String dropCategory){
        try{
            List<AssignedTasksWrapper> assignedTasks = (List<AssignedTasksWrapper>) JSON.deserialize(kanbanRecords,List<AssignedTasksWrapper>.class);
            Assigned_Task__c draggedTask = (Assigned_Task__c) JSON.deserialize(recordToUpdate,Assigned_Task__c.class);
            if(dropCategory == 'In Progress'){
                draggedTask.Status__c = 'In-Progress';
            }else if(dropCategory == 'Completed'){
                draggedTask.Status__c = 'Completed';
            }
            List<String> fieldNames = new List<String>();
            fieldNames.add('Status__c');
            if(FLSCheck.isUpdateable(fieldNames, 'Assigned_Task__c')){
                update new Assigned_Task__c(Id = draggedTask.Id, Status__c = draggedTask.Status__c);
            }
            for(AssignedTasksWrapper assignedTask : assignedTasks){
                if(assignedTask.taskType == dragCategory){
                    for(Integer i=0;i<assignedTask.records.size();i++){
                        Assigned_Task__c lTaskRecord = assignedTask.records[i];
                        if(lTaskRecord.Id == draggedTask.Id){
                            assignedTask.records.remove(i);
                        }
                    }
                }else if(assignedTask.taskType == dropCategory){
                    assignedTask.records.add(draggedTask);
                }
            }
            return assignedTasks;
        }
        catch(exception e){
            return null;
        }
    }
}