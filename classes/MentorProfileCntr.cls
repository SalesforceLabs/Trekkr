 /*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 *
 *  Controller for Mentor Profile lightning component
 */
public with sharing class MentorProfileCntr {
    
    /**
*  Aura function to return mentor user details along with all mentee users details.
**/
    @AuraEnabled
    public static List<User> getMentorAndBuddiesDetail(){
        List<String> fields_UURJ = new List<String>(); 
        fields_UURJ.add('User_Role__c');
        List<String> fields_UR = new List<String>();
        fields_UR.add('Name');        
        if(FLSCheck.isAccessible(fields_UR,'User_Role__c') && FLSCheck.isAccessible(fields_UURJ,'User_User_Role_Junction__c')){
               return [SELECT Id,FirstName,LastName,FullPhotoUrl,MobilePhone,Email,Energizers__c,Medals__c,
                       Joining_Date__c,On_boarding_End_Date__c,
                       (SELECT Id, User_Role__r.Name FROM User_User_Role_Junctions__r)
                       FROM User WHERE Mentor__c = : UserInfo.getUserId()];
           }
        return new List<User>();
    }
    
    /**
* Wrapper class for Mentee Milestone Information
**/ 
    public class MenteeMilestone{
        @AuraEnabled
        public String milestoneName;
        @AuraEnabled
        public List<Assigned_Task__c> programs;
        @AuraEnabled
        public Boolean milestoneComplete;
        @AuraEnabled
        public Boolean currentMilestone;
        
        public MenteeMilestone(String milestoneName,List<Assigned_Task__c> programs){
            this.milestoneName = milestoneName;
            this.programs = programs;
            this.milestoneComplete = true;
            for(Assigned_Task__c program : programs){
                if(program.Status__c != 'Completed' && program.Status__c != 'Closed'){
                    this.milestoneComplete = false;
                    break;
                }
            }
        }
    }
    
    /** Wrapper class for storing list of Milestones along with current milestone position  **/
    public class MenteeAssignmentInfo{
        @AuraEnabled
        public List<MenteeMilestone> menteeMilestones;
        @AuraEnabled
        public Integer currentMilestonePos = 0;
        
        public MenteeAssignmentInfo(List<MenteeMilestone> menteeMilestones){
            this.menteeMilestones = menteeMilestones;
            for(Integer i=menteeMilestones.size()-1;i>=0;i--){
                if(menteeMilestones[i].milestoneComplete){
                    currentMilestonePos = i+1;
                    menteeMilestones[i].currentMilestone = true;
                    break;
                }
            }
        }
    }
    
    
    /**
* Aura function to return all assigned tasks for a user.
**/
    @AuraEnabled
    public static MenteeAssignmentInfo getMenteeAssignmentInformation(String userId){
        Id businessTaskRecordTypeId = Schema.SObjectType.On_boarding_Task__c.getRecordTypeInfosByName().get('Business').getRecordTypeId();
        List<MenteeMilestone> menteeMilestons = new List<MenteeMilestone>();
        Map<String,List<Assigned_Task__c>> menteeMilestonesMap = new Map<String,List<Assigned_Task__c>>();
        List<Assigned_Task__c> assignedPrograms = new List<Assigned_Task__c>();
        List<String> fields_AT = new List<String>();
        fields_AT.add('Energizers__c');
        fields_AT.add('Feedback__c');
        fields_AT.add('Medals__c');
        fields_AT.add('Current_Value__c');
        fields_AT.add('Milestone__c');
        fields_AT.add('Onboarding_Program__c');
        fields_AT.add('Percentage_Completed__c');
        fields_AT.add('Overdue__c');
        fields_AT.add('Status__c');
        fields_AT.add('Target_Date_Time__c');
        fields_AT.add('Type__c');
        fields_AT.add('Reason_for_Reopen__c');
        fields_AT.add('Assign_To__c');
        List<String> fields_OP = new List<String>();
        fields_OP.add('Name');
        fields_OP.add('Description__c');
        fields_OP.add('Duration__c');
        fields_OP.add('Duration_Type__c');
        fields_OP.add('Duration__c');
        List<String> fields_OT = new List<String>();
        fields_OT.add('Duration__c');
        fields_OT.add('Duration_Type__c');
        fields_OT.add('Name');
        fields_OT.add('Description__c');
        fields_OT.add('Target_Value__c');
        fields_OT.add('Link__c');
        if(FLSCheck.isAccessible(fields_AT,'Assigned_Task__c') && FLSCheck.isAccessible(fields_OP,'Onboarding_Program__c') &&
           FLSCheck.isAccessible(fields_OT,'On_boarding_Task__c')){
               assignedPrograms = [SELECT Id,Energizers__c,Feedback__c,Medals__c,
                                   Current_Value__c, Milestone__c, Onboarding_Program__r.Name,
                                   Onboarding_Program__r.Description__c , Onboarding_Program__r.Duration__c,
                                   Onboarding_Program__r.Duration_Type__c,Percentage_Completed__c,
                                   Overdue__c,Status__c,Target_Date_Time__c,
                                   (SELECT Id,Energizers__c,Medals__c,Reason_for_Reopen__c,
                                    Task__r.Duration__c,Task__r.Duration_Type__c,
                                    Current_Value__c,Milestone__c,Task__r.Name,
                                    Task__r.Description__c,Task__r.Target_Value__c, 
                                    Overdue__c,Status__c,Target_Date_Time__c,Task__r.Quantifiable__c, 
                                    Task__r.Link__c 
                                    FROM Child_Assigned_Tasks__r WHERE Task__r.RecordTypeId = :businessTaskRecordTypeId)
                                   FROM Assigned_Task__c 
                                   WHERE Assign_To__c  = :userId AND Onboarding_Program__c != null 
                                   ORDER BY Milestone__c ASC];
           }
        for(Assigned_Task__c assignedProgram : assignedPrograms){
            if(assignedProgram.Milestone__c != '' && assignedProgram.Milestone__c != null){
                List<Assigned_Task__c> menteePrograms = new List<Assigned_Task__c>();
                if(menteeMilestonesMap.containsKey(assignedProgram.Milestone__c))
                    menteePrograms = menteeMilestonesMap.get(assignedProgram.Milestone__c);
                menteePrograms.add(assignedProgram);
                menteeMilestonesMap.put(assignedProgram.Milestone__c,menteePrograms);
            }
        }
        for(String milestoneName : menteeMilestonesMap.keySet()){
            menteeMilestons.add(new MenteeMilestone(milestoneName,menteeMilestonesMap.get(milestoneName)));
        }
        
        return new MenteeAssignmentInfo(menteeMilestons);
    }     
    
}