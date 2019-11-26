 /*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 *
 * Controller for New Mentees Sign up
 */
public without sharing class NewMenteeSignUpCntr {
    
    /**
* Returns ManagerId and RoleId for the user 
**/ 
    @AuraEnabled
    public static List<String> getManagerAndRole(String userId){
        List<String> managerAndRole = new List<String>();        
        //List<String> fields_U = new List<String>();
        //fields_U.add('ManagerId');
        //if(FLSCheck.isAccessible(fields_U,'User')){
        List<User> listManager = [SELECT Id,ManagerId FROM User WHERE Id = :userId];
        if(listManager.size() > 0){
            managerAndRole.add(listManager[0].ManagerId);
        }
        List<String> fields_UURJ = new List<String>();
        fields_UURJ.add('User__c');
        fields_UURJ.add('User_Role__c');
        if(FLSCheck.isAccessible(fields_UURJ,'User_User_Role_Junction__c')){
            List<User_User_Role_Junction__c> uurj = [SELECT Id, User_Role__c FROM User_User_Role_Junction__c WHERE 
                                                            User__c = :userId LIMIT 1];
            if(uurj.size () > 0){
                managerAndRole.add(uurj[0].User_Role__c);
            }else{
                managerAndRole.add('');
            }
        }
        return managerAndRole;
    }
    
    /**
* Aura function to update Mentee's user record with the manager detail, mentee detail and other onboarding details. 
* Also this function sends a welcome email if sendWelcomeEmail is true
*/ 
    @AuraEnabled
    public static Boolean saveMenteeDetails(String userRole,String lUser,Boolean sendWelcomeEmail){
        try{
            User userObj = (User)JSON.deserialize(lUser,User.class);
            userObj.Energizers__c = GamificationManager.addEnergizersForSignUp();
            update userObj;
            List<String> fields_UURJ = new List<String>();
            fields_UURJ.add('User__c');
            fields_UURJ.add('User_Role__c');
            if(FLSCheck.isAccessible(fields_UURJ,'User_User_Role_Junction__c')){
                List<User_User_Role_Junction__c> uurj = [SELECT Id, User_Role__c FROM User_User_Role_Junction__c WHERE 
                                                                User__c = :userObj.Id LIMIT 1];
                if(uurj.size() > 0){
                    return false;
                }else{
                    if(FLSCheck.isCreateable(fields_UURJ,'User_User_Role_Junction__c')){
                        User_User_Role_Junction__c userRole_User_Junction = new User_User_Role_Junction__c();
                        userRole_User_Junction.User__c = userObj.Id;
                        userRole_User_Junction.User_Role__c = userRole;
                        insert userRole_User_Junction;
                    }else{
                        return false;
                    }
                    Date joiningDate = userObj.Joining_Date__c;
                    if(joiningDate != null)
                        NotificationsManager.notifyMenteeForOnboardingStarted(userObj.Id,userObj.Mentor__c,userObj.ManagerId,joiningDate.format());
                    if(sendWelcomeEmail){
                        User lMenteeUser = [SELECT Id,Name,Mentor__r.Name,Manager.Name,Email FROM USER WHERE ID = :userObj.Id];
                        DataUtil.sendEmail('Trekkr | Welcome Onboard',
                                           DataUtil.getNewMenteeSignupEmailBody(lMenteeUser.Name,
                                                                                lMenteeUser.Mentor__r.Name, 
                                                                                lMenteeUser.Manager.Name, joiningDate.format()),
                                           lMenteeUser.Email);
                    }
                    addPermissionSets(userObj.Id, userObj.Mentor__c,userObj.ManagerId);
                    return true;
                }
            }else{
                return false;
            }
        }catch(Exception e){
            System.debug(e);
            return false;
        }
    }
    
    /** Future function to add permission set to Mentee, Mentor and Manager **/
    @future
    public static void addPermissionSets(Id menteeId, Id mentorId, Id managerId){
        DataUtil.addMenteePermissionSetToUser(menteeId);
        if(mentorId != null)
            DataUtil.addMentorPermissionSetToUser(mentorId);
        if(managerId != null)
            DataUtil.addManagerPermissionSetToUser(managerId);
        /* adding new Permission set from DataUtil. Check IDs not null */
        if(managerId != null && mentorId != null && menteeId != null){
            List<Id> userIds = new List<Id>();
            userIds.add(managerId);
            userIds.add(mentorId);
            userIds.add(menteeId);
            DataUtil.addMiscellaneousPermissionSetToUser(userIds);
        }
        
    }
}