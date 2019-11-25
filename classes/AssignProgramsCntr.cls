/**
* Controller for AssignProgram Lightning component
**/ 
public with sharing class AssignProgramsCntr {
    
    /** Returns list of all programs and suggested programs based on user **/
    @AuraEnabled
    public static Map<String,List<Onboarding_Program__c>> getPrograms(String userId){
        Map<String,List<Onboarding_Program__c>> programsMap = new Map<String,List<Onboarding_Program__c>>();
        List<Assigned_Task__c> assignedProgramsToUser = new List<Assigned_Task__c>();
        List<String> fields_AP = new List<String>();
        fields_AP.add('Onboarding_Program__c');
        fields_AP.add('Assign_To__c');
        if(FLSCheck.isAccessible(fields_AP, 'Assigned_Task__c')){
            assignedProgramsToUser = [SELECT Id,Onboarding_Program__c FROM Assigned_Task__c 
                                      WHERE Assign_To__c = :userId AND 
                                      Onboarding_Program__c != ''];
        }
        List<Id> programsAlreadyAssignedToUser = new List<Id>();
        for(Assigned_Task__c assignedProgramToUser : assignedProgramsToUser){
            programsAlreadyAssignedToUser.add(assignedProgramToUser.Onboarding_Program__c);
        }
        List<User_User_Role_Junction__c> userRoleJunctions = new List<User_User_Role_Junction__c>();
        List<String> fields_UURJ = new List<String>();
        fields_UURJ.add('User_Role__c');
        fields_UURJ.add('User__c');
        if(FLSCheck.isAccessible(fields_UURJ,'User_User_Role_Junction__c')){
            userRoleJunctions  = [SELECT Id,User_Role__c FROM User_User_Role_Junction__c WHERE User__c = :userId];
        }
        List<Onboarding_Program__c> allOnboardingPrograms = new List<Onboarding_Program__c>();
        List<String> fields_OP = new List<String>();
        fields_OP.add('Duration__c');
        fields_OP.add('Duration_Type__c');
        fields_OP.add('Description__c');
        fields_OP.add('Name');
        fields_OP.add('Public__c');
        List<String> fields_OT = new List<String>();
        fields_OT.add('Name');
        fields_OT.add('Duration__c');
        fields_OT.add('Duration_Type__c');
        fields_OT.add('Description__c');
        List<String> fields_PURJ = new List<String>();
        fields_PURJ.add('User_Role__c');
        if(FLSCheck.isAccessible(fields_OP,'Onboarding_Program__c') && 
           FLSCheck.isAccessible(fields_PURJ,'Onboarding_Program_User_Role_Junction__c') &&
           FLSCheck.isAccessible(fields_OT, 'On_boarding_Task__c') ){
               allOnboardingPrograms = [SELECT Id,Duration__c,Duration_Type__c,
                                        Name,Description__c,
                                        (SELECT Id,User_Role__c FROM Program_User_Role_Junctions__r),
                                        (SELECT Id,Onboarding_Task__r.Name,Onboarding_Task__r.Duration__c,
                                         Onboarding_Task__r.Duration_Type__c,Onboarding_Task__r.Description__c 
                                         FROM Onboarding_Program_Task_Junctions__r)
                                        FROM Onboarding_Program__c WHERE Public__c = true 
                                        AND Id NOT IN :programsAlreadyAssignedToUser];
           }
        
        programsMap.put('ALL',allOnboardingPrograms);
        Map<Id,Onboarding_Program__c> recommendedProgramsMap = new Map<Id,Onboarding_Program__c>();
        for(Onboarding_Program__c onboardingProgram : allOnboardingPrograms){
            for(Onboarding_Program_User_Role_Junction__c programUserRoleJunction : onboardingProgram.Program_User_Role_Junctions__r){
                for(User_User_Role_Junction__c userRoleJunction : userRoleJunctions){
                    if(userRoleJunction.User_Role__c == programUserRoleJunction.User_Role__c){
                        if(!recommendedProgramsMap.containsKey(onboardingProgram.Id))
                            recommendedProgramsMap.put(onboardingProgram.Id,onboardingProgram);
                    }
                }
            }
        }
        programsMap.put('RECOMMENDED',recommendedProgramsMap.values());
        return programsMap;
    }
    
    @AuraEnabled
    public static List<DataUtil.CustomPicklistRecord> getMilestones(){
        List<String> fields_AT = new List<String>();
        fields_AT.add('Milestone__c');
        if(FLSCheck.isAccessible(fields_AT,'Assigned_Task__c')){
            return DataUtil.getPicklistValues(Assigned_Task__c.Milestone__c.getDescribe());
        }
        return new List<DataUtil.CustomPicklistRecord>();
    }
    
    /** Assigns progam(s) to a user **/
    @AuraEnabled
    public static void assignPrograms(String assignProgramsListJSON){
        List<Assigned_Task__c> programsToAssigns = (List<Assigned_Task__c>)JSON.deserialize(assignProgramsListJSON,List<Assigned_Task__c>.class);
        List<String> fields_AT = new List<String>();
        fields_AT.add('Assign_To__c');
        fields_AT.add('Onboarding_Program__c');
        fields_AT.add('Status__c');
        if(FLSCheck.isCreateable(fields_AT,'Assigned_Task__c')){
            insert programsToAssigns;
           /** for( Assigned_Task__c program : programsToAssigns){
                NotificationsManager.notifyMenteeForAssignedTrail(program.Assign_To__c);
            } **/ 
        }
        
    }
}