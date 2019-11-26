 /*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 *
 * Test class for RaiseAndCloseProgramCntr 
 */
@isTest
public with sharing class RaiseAndCloseProgramCntr_Test {

    static testMethod void test_getProgramDetail(){
        List<Onboarding_Program__c> onboardingPrograms = TestDataUtil.getOnboardingPrograms(2);
        insert onboardingPrograms;
        User menteeUser = [SELECT Id FROM USER LIMIT 1];
        Assigned_Task__c assignedProgram = TestDataUtil.assignProgramToUser(onboardingPrograms.get(0).Id, menteeUser.Id);
        insert assignedProgram;
        Assigned_Task__c assignedProgramDetail = RaiseAndCloseProgramCntr.getProgramDetail(assignedProgram.Id);
        System.assertEquals(assignedProgram.Id, assignedProgramDetail.Id);
    }
}