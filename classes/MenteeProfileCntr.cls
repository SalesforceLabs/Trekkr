 /*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
public with sharing class MenteeProfileCntr {
    
    /**
*  Aura function to return mentee user details
**/
    @AuraEnabled
    public static Map<String,Object> getMenteeDetailAndAssignmentInfo(){
        Map<String,Object> returnData = new Map<String,Object>();
        List<String> fields_UURJ = new List<String>(); 
        fields_UURJ.add('User_Role__c');
        List<String> fields_UR = new List<String>();
        fields_UR.add('Name');        
        if(FLSCheck.isAccessible(fields_UR,'User_Role__c') && FLSCheck.isAccessible(fields_UURJ,'User_User_Role_Junction__c')){
               List<User> menteeUsers = [SELECT Id,FirstName,LastName,FullPhotoUrl,MobilePhone,Email,Energizers__c,Medals__c,
                                         Joining_Date__c,On_boarding_End_Date__c,
                                         (SELECT Id, User_Role__r.Name FROM User_User_Role_Junctions__r)
                                         FROM User WHERE Id = : UserInfo.getUserId() LIMIT 1];
               if(menteeUsers.size()>0)
                   returnData.put('MENTEE_INFO',menteeUsers.get(0)); 
               MentorProfileCntr.MenteeAssignmentInfo menteeAssignmentInfo = MentorProfileCntr.getMenteeAssignmentInformation(UserInfo.getUserId());
            returnData.put('ASSIGNMENT_INFO',menteeAssignmentInfo);
           }
        return returnData;
    }
    
}