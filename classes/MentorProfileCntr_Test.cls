 /*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 *
 * Test class for the MentorProfileCntr apex class
 */ 
@isTest
public with sharing class MentorProfileCntr_Test {
    
    static testMethod void validate_getMentorAndBuddiesDetail(){
        User menteeUser = TestDataUtil.getUser();
        insert menteeUser;
        System.runAs(menteeUser){
            List<User> menteesList = MentorProfileCntr.getMentorAndBuddiesDetail();
            System.assertEquals(0,menteesList.size());
        }
    }
    
    static testMethod void validate_getMenteeAssignmentInformation(){
        User menteeUser = [SELECT Id FROM User LIMIT 1];
        List<Onboarding_Program__c> onboardingPrograms = TestDataUtil.getOnboardingPrograms(3);
        insert onboardingPrograms;
        List<Assigned_Task__c> assignedPrograms = new List<Assigned_Task__c>();
        for(Onboarding_Program__c onboardingProgram : onboardingPrograms){
            assignedPrograms.add(TestDataUtil.assignProgramToUser(onboardingPrograms.get(0).Id,menteeUser.Id));
        } 
        insert assignedPrograms;
        MentorProfileCntr.MenteeAssignmentInfo menteeAssignmentInfo = MentorProfileCntr.getMenteeAssignmentInformation(menteeUser.Id);
        System.assertEquals(1,menteeAssignmentInfo.menteeMilestones.size());
    }
}