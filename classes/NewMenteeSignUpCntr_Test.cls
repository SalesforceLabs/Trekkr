 /*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 *
 * Test class for NewMenteeSignUpCntr 
 */
@IsTest
public without sharing class NewMenteeSignUpCntr_Test {
    
    static testMethod void validate_getManagerAndRole() {
        List<User> lUser = [SELECT Id FROM User LIMIT 1];
        if(lUser.size()>0){
            List<String> stringIds = NewMenteeSignUpCntr.getManagerAndRole(''+lUser[0].Id);
            System.assertEquals(null,stringIds[0]);
            System.assertEquals('',stringIds[1]);
        }
    }
    
    static testMethod void validate_saveMenteeDetails(){
        User lUser = [SELECT Id FROM User WHERE Profile.Name ='System Administrator' LIMIT 1];
        List<String> adminUserIds = new List<String>();
        adminUserIds.add(lUser.Id);
        DataUtil.addAdminPermissionSetToUser(adminUserIds);
        System.runAs(lUser){
            lUser.Joining_Date__c = System.today();
            User_Role__c userRole = TestDataUtil.getUserRole('Software Engineer');
            insert userRole;
            Boolean isMenteeDetailSaved = NewMenteeSignUpCntr.saveMenteeDetails(userRole.Id,JSON.serialize(lUser),true);
            System.assertEquals(true, isMenteeDetailSaved);
        }
    }
    
}