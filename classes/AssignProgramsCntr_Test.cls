 /*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 *
 * Test class for AssignProgramCntr
 */ 
@IsTest
public with sharing class AssignProgramsCntr_Test {
    
    static testMethod void validate_getPrograms(){
        User_Role__c lUserRole = TestDataUtil.getUserRole('Software Engineer');
        insert lUserRole;
        List<Onboarding_Program__c> onboardingPrograms = TestDataUtil.getOnboardingPrograms(3);
        insert onboardingPrograms;
        User luser = [SELECT Id FROM User LIMIT 1];
        if(onboardingPrograms.size()>0){ 
            User_User_Role_Junction__c userUserRoleJunction = TestDataUtil.assignUserRoleToUser(lUser.Id,lUserRole.Id);
            insert userUserRoleJunction;
            Assigned_Task__c assignedProgram = TestDataUtil.assignProgramToUser(onboardingPrograms.get(0).Id,lUser.Id);
            insert assignedProgram;
            Onboarding_Program_User_Role_Junction__c userRoleProgramJunction = 
                TestDataUtil.assignUserRoleToProgram(lUserRole.Id,onboardingPrograms.get(1).Id);   
            insert userRoleProgramJunction;
        }
        Map<String,List<Onboarding_Program__c>> programsMap = AssignProgramsCntr.getPrograms(lUser.Id);
        System.assertEquals(2,programsMap.get('ALL').size());
        System.assertEquals(1,programsMap.get('RECOMMENDED').size());
    }
    
    static testMethod void validate_assignPrograms(){
        List<String> programIds = new List<String>();
        List<Onboarding_Program__c> onboardingPrograms = TestDataUtil.getOnboardingPrograms(3);
        insert onboardingPrograms;
        for(Onboarding_Program__c onboardingProgram : onboardingPrograms){
            programIds.add(onboardingProgram.Id);
        }
        User luser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' LIMIT 1];
        List<Assigned_Task__c> programsToAssign = new List<Assigned_Task__c>();
        for(String programId : programIds){
            programsToAssign.add(new Assigned_Task__c(
                Onboarding_Program__c  = programId,
                Assign_To__c  = luser.Id,
                Milestone__c = 'Milestone 1'
            ));
        }
        AssignProgramsCntr.assignPrograms(JSON.serialize(programsToAssign));
        List<Assigned_Task__c> assignedPrograms = [SELECT Id FROM Assigned_Task__c WHERE Onboarding_Program__c IN :programIds];
        System.assertEquals(3,assignedPrograms.size());
    }
    
    static testMethod void validate_getMilestones(){
        List<DataUtil.CustomPicklistRecord> milestones = AssignProgramsCntr.getMilestones();
        System.assert(milestones.size()>0);
        
    }
}