/**
* Controller for New Onboarding Program component
**/ 
public with sharing class NewOnboardingProgramCntr {
    
    /**
* Aura controller for returning the due date picklist schema details
**/ 
    @AuraEnabled(cacheable=true)
    public static Map<String,List<Object>> getInit(){
        Map<String,List<Object>> initData = new Map<String,List<Object>>();
        try{
            List<String> fields_UR = new List<String>();
            fields_UR.add('Name');
            if(FLSCheck.isAccessible(fields_UR,'User_Role__c')){
                initData.put('userRoles',[SELECT Id,Name FROM User_Role__c]);
            }
            List<String> fields_RT = new List<String>();
            fields_RT.add('Name');
            fields_RT.add('DeveloperName');
            fields_RT.add('SobjectType');
            if(FLSCheck.isAccessible(fields_RT,'RecordType')){
                initData.put('taskRecordTypes',[SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType =:'On_boarding_Task__c']);
            }
            List<String> fields_OT = new List<String>();
            fields_OT.add('Duration_Type__c');
            fields_OT.add('Level__c');
            if(FLSCheck.isAccessible(fields_OT,'On_boarding_Task__c')){
                initData.put('taskDurationTypes',DataUtil.getPicklistValues(On_boarding_Task__c.Duration_Type__c.getDescribe()));
                initData.put('taskDifficulties',DataUtil.getPicklistValues(On_boarding_Task__c.Level__c.getDescribe()));
            }
            initData.put('milestones',AssignProgramsCntr.getMilestones());
        }
        catch(Exception e){
            System.debug(e);
        }
        return initData;
    }
    
    /** This method creates new onboarding program and maps Onboarding Tasks and Roles **/
    @AuraEnabled
    public static Onboarding_Program__c insertNewOnboardingProgram(String onboardingProgramJSON,String onboardingTasksJSON,String selectedRoles){
        try{
            if(onboardingProgramJSON == null || onboardingProgramJSON == ''){
                return null;
            }
            Onboarding_Program__c newOnboardingProgram = (Onboarding_Program__c)JSON.deserialize(onboardingProgramJSON,Onboarding_Program__c.class);
            List<String> fields_OP = new List<String>();
            fields_OP.add('Name');
            fields_OP.add('Description__c');
            fields_OP.add('Public__c');
            if(FLSCheck.isCreateable(fields_OP,'Onboarding_Program__c')){
                insert newOnboardingProgram;
                if(onboardingTasksJSON!=null && onboardingTasksJSON!=''){
                    List<On_boarding_Task__c> onboardingTasks = (List<On_boarding_Task__c>)JSON.deserialize(onboardingTasksJSON,List<On_boarding_Task__c>.class);
                    if(onboardingTasks.size() > 0){
                        List<String> fields_OT = new List<String>();
                        fields_OT.add('Name');
                        fields_OT.add('Description__c');
                        fields_OT.add('Duration__c');
                        fields_OT.add('Duration_Type__c');
                        fields_OT.add('Level__c');
                        fields_OT.add('Link__c');
                        fields_OT.add('Mandatory__c');
                        fields_OT.add('Quantifiable__c');
                        fields_OT.add('RecordTypeId');
                        fields_OT.add('Target_Value__c');
                        if(FLSCheck.isCreateable(fields_OT,'On_boarding_Task__c') && 
                           FLSCheck.isUpdateable(fields_OT,'On_boarding_Task__c')){
                               upsert onboardingTasks;
                           }
                    }
                    List<Onboarding_Program_Task_Junction__c> onboardingProgramTaskJunctions = new List<Onboarding_Program_Task_Junction__c>();
                    for(On_boarding_Task__c onboardingTask : onboardingTasks){
                        onboardingProgramTaskJunctions.add(new Onboarding_Program_Task_Junction__c(Onboarding_Program__c = newOnboardingProgram.Id, Onboarding_Task__c = onboardingTask.Id));
                    }
                    if(onboardingProgramTaskJunctions.size() >0){
                        List<String> fields_OPTJ = new List<String>();
                        fields_OPTJ.add('Onboarding_Program__c');
                        fields_OPTJ.add('Onboarding_Task__c');
                        if(FLSCheck.isCreateable(fields_OPTJ,'Onboarding_Program_Task_Junction__c') && 
                           FLSCheck.isUpdateable(fields_OPTJ,'Onboarding_Program_Task_Junction__c')){
                               upsert onboardingProgramTaskJunctions;
                           }
                    }
                }
                if(selectedRoles != null && selectedRoles!= ''){
                    List<Onboarding_Program_User_Role_Junction__c> onboardingProgramUserRoleJunctions = new List<Onboarding_Program_User_Role_Junction__c>();
                    List<String> selectedRolesList = selectedRoles.split(';');
                    for(String selectedRole : selectedRolesList){
                        onboardingProgramUserRoleJunctions.add(new Onboarding_Program_User_Role_Junction__c(Onboarding_Program__c = newOnboardingProgram.Id, User_Role__c = selectedRole));
                    }
                    List<String> fields_OPURJ = new List<String>();
                    fields_OPURJ.add('Onboarding_Program__c');
                    fields_OPURJ.add('User_Role__c');
                    if(FLSCheck.isCreateable(fields_OPURJ,'Onboarding_Program_User_Role_Junction__c') && 
                       FLSCheck.isUpdateable(fields_OPURJ,'Onboarding_Program_User_Role_Junction__c')){
                           upsert onboardingProgramUserRoleJunctions;
                       }
                }
                return newOnboardingProgram;
            }
            return null;
        }catch(Exception e){
            System.debug(e);
            return null;
        }
    }
    
    /** This methods returns Program details by Program Id **/
    @AuraEnabled(cacheable=true)
    public static Onboarding_Program__c getProgramDetails(String programId){
        List<String> fields_OP = new List<String>();
        fields_OP.add('Name');
        fields_OP.add('Description__c');
        List<String> fields_OPURJ = new List<String>();
        fields_OPURJ.add('User_Role__c');
        List<string> fields_UR = new List<String>();
        fields_UR.add('Name');
        List<String> fields_OT = new List<String>();
        fields_OT.add('Name');
        fields_OT.add('Duration__c');
        fields_OT.add('Duration_Type__c');
        fields_OT.add('Level__c');
        fields_OT.add('Link__c');
        fields_OT.add('Mandatory__c');
        fields_OT.add('Quantifiable__c');
        fields_OT.add('RecordTypeId');
        fields_OT.add('Record_Type__c');
        fields_OT.add('Target_Value__c');
        fields_OT.add('Description__c');
        List<String> fields_OPTJ = new List<String>();
        fields_OPTJ.add('Onboarding_Task__c');
        if(FLSCheck.isAccessible(fields_OP,'Onboarding_Program__c') && 
           FLSCheck.isAccessible(fields_OPURJ,'Onboarding_Program_User_Role_Junction__c') && 
           FLSCheck.isAccessible(fields_UR,'User_Role__c') && FLSCheck.isAccessible(fields_OT,'On_boarding_Task__c') &&
           FLSCheck.isAccessible(fields_OPTJ, 'Onboarding_Program_Task_Junction__c')){
               return [SELECT Id,Name, Description__c,
                       (SELECT Id,Onboarding_Task__r.Id,Onboarding_Task__r.Name,Onboarding_Task__r.Duration__c,Onboarding_Task__r.Duration_Type__c,
                        Onboarding_Task__r.Level__c,Onboarding_Task__r.Link__c,Onboarding_Task__r.Mandatory__c,
                        Onboarding_Task__r.Quantifiable__c,Onboarding_Task__r.RecordTypeId,Onboarding_Task__r.Record_Type__c, 
                        Onboarding_Task__r.Target_Value__c, Onboarding_Task__r.Description__c 
                        FROM Onboarding_Program_Task_Junctions__r),
                       (SELECT Id,User_Role__r.Name,User_Role__r.Id FROM Program_User_Role_Junctions__r) 
                       FROM Onboarding_Program__c WHERE Id = :programId];
           }
        return null;
    }
    
    /** This methods assigns program to a user **/
    @AuraEnabled
    public static void assignProgram(String programId, String userId,String targetDateTime, String selectedMilestone){
        List<String> fields_AT = new List<String>();
        fields_AT.add('Assign_To__c');
        fields_AT.add('Onboarding_Program__c');
        fields_AT.add('Status__c');
        if(FLSCheck.isCreateable(fields_AT,'Assigned_Task__c')){
            insert new Assigned_Task__c(
                Assign_To__c = userId,
                Onboarding_Program__c = programId,
                Status__c  = 'New',
                Milestone__c = selectedMilestone,
                Target_Date_Time__c = DataUtil.toDateTime(targetDateTime)
            );
            //NotificationsManager.notifyMenteeForAssignedTrail(userId);
        }
    }
    
    /** This methods returns the task information by TaskId **/
    @AuraEnabled(cacheable=true)
    public static On_boarding_Task__c getTaskDetails(String taskId){
        List<String> fields_OT = new List<String>();
        fields_OT.add('recordTypeId');
        fields_OT.add('Name');
        fields_OT.add('Description__c');
        fields_OT.add('Duration__c');
        fields_OT.add('Duration_Type__c');
        fields_OT.add('Level__c');
        fields_OT.add('Link__c');
        fields_OT.add('Mandatory__c');
        fields_OT.add('Quantifiable__c');
        fields_OT.add('Target_Value__c');
        if(FLSCheck.isAccessible(fields_OT,'On_boarding_Task__c')){
            return [SELECT Id,recordTypeId,Name,Description__c,Duration__c,Duration_Type__c,
                    Level__c,Link__c,Mandatory__c, Quantifiable__c ,Target_Value__c  
                    FROM On_boarding_Task__c WHERE Id = :taskId];
        }
        return null;
    }
}