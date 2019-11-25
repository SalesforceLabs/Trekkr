/**
*  Controller for custom Tasklists lightning component
**/
public with sharing class NewAssignedTaskCntr {
    
    /**
*  This funtion is to  Create assigned tasks for the logged in user
**/    
    @AuraEnabled
    public static Boolean savetasks(String ltask){ 
        try{
            List<String> fieldNames_AT = new List<String>();
            fieldNames_AT.add('Mandatory__c');
            fieldNames_AT.add('Task_Description__c');
            fieldNames_AT.add('Task_Name__c');
            fieldNames_AT.add('Estimated_Efforts_in_count__c');
            fieldNames_AT.add('Estimated_Efforts_in_hrs__c');
            fieldNames_AT.add('Target_Date_Time__c');
            fieldNames_AT.add('Task__c');
            fieldNames_AT.add('Status__c');
            fieldNames_AT.add('Assign_To__c');
            fieldNames_AT.add('Link__c');
            fieldNames_AT.add('Mandatory__c');
            Assigned_Task__c  userObj = (Assigned_Task__c)JSON.deserialize(ltask,Assigned_Task__c.class);
            if(FLSCheck.isCreateable(fieldNames_AT,'Assigned_Task__c')){
                insert userObj; 
                return true;
            }
            System.debug(FLSCheck.isCreateable(fieldNames_AT,'Assigned_Task__c'));
            return false;
        }catch(Exception e){
            System.debug(e.getCause()+' '+e.getLineNumber()+' '+e.getMessage()+' '+e.getTypeName());
            return false;
        }
    }
    
}