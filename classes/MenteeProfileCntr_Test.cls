 /*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
@isTest
public with sharing class MenteeProfileCntr_Test {
    
    static testMethod void validate_getMenteeDetailAndAssignmentInfo(){
        User lUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator'];
        DataUtil.addMenteePermissionSetToUser(lUser.Id);
        System.runAs(lUser){
            List<Onboarding_Program__c> onboardingPrograms = TestDataUtil.getOnboardingPrograms(3);
            insert onboardingPrograms;
            List<Assigned_Task__c> assignedPrograms = new List<Assigned_Task__c>();
            for(Onboarding_Program__c onboardingProgram : onboardingPrograms){
                assignedPrograms.add(TestDataUtil.assignProgramToUser(onboardingPrograms.get(0).Id,lUser.Id));
            }
            insert assignedPrograms;
            Map<String,Object> menteeDetailAndAssignmentInfo = MenteeProfileCntr.getMenteeDetailAndAssignmentInfo();
            System.assertEquals(1, ((MentorProfileCntr.MenteeAssignmentInfo)menteeDetailAndAssignmentInfo.get('ASSIGNMENT_INFO')).menteeMilestones.size());
            System.assertEquals(lUser.Id, ((User)menteeDetailAndAssignmentInfo.get('MENTEE_INFO')).Id);
        }
     }
}