 /*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 *
 * Test class for ManagerGuidesCntr 
 */
@isTest
public with sharing class ManagerGuidesCntr_Test {
    
    static testMethod void validate_getMentorMenteeDetails(){
        User lMentorUser = TestDataUtil.getUser();
        insert lMentorUser;
        DataUtil.addMenteePermissionSetToUser(lMentorUser.Id);
        User lManagerUser = TestDataUtil.getUser();
        insert lManagerUser;
        DataUtil.addManagerPermissionSetToUser(lManagerUser.Id);
        User lMenteeUser = TestDataUtil.getUser();
        lMenteeUser.Mentor__c = lMentorUser.Id;
        lMenteeUser.ManagerId = lManagerUser.Id;
        insert lMenteeUser;
        DataUtil.addMenteePermissionSetToUser(lMenteeUser.Id);
        System.runAs(lManagerUser){
            Map<String,Object> mentorMenteeDetails = ManagerGuidesCntr.getMentorMenteeDetails();
            List<ManagerGuidesCntr.UserWrapper> mentorIds = (List<ManagerGuidesCntr.UserWrapper>)mentorMenteeDetails.get('MENTORS');
            System.assertEquals(1,mentorIds.size());
            List<User> mentorAndBuddiesDetail = ManagerGuidesCntr.getMentorAndBuddiesDetail(mentorIds.get(0).Id);
            System.assertEquals(1, mentorAndBuddiesDetail.size());
            ManagerGuidesCntr.getMenteeAssignmentInformation(mentorAndBuddiesDetail.get(0).Id);
        }
    }
    
}