 /*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
public without sharing class ExtendMenteeCntr {
    
    /** Return's list of Mentees whose onboarding is ongoing **/
    @AuraEnabled 
    public static List<UserWrapper> getMenteeUsers(){
        List<UserWrapper> menteeUserWrappers = new List<UserWrapper>();
        List<User> menteeUsers =  [SELECT FirstName,LastName,FullPhotoUrl,On_boarding_End_Date__c,
                                   (SELECT Id, User_Role__r.Name FROM User_User_Role_Junctions__r)
                                   FROM USER WHERE Mentor__c != null AND ManagerId = :UserInfo.getUserId() AND 
                                   On_boarding_End_Date__c >= :System.today() AND Onboarding_Completed__c = false];
        for(User menteeUser : menteeUsers){
            Integer daysLeft = System.today().daysBetween(menteeUser.On_boarding_End_Date__c); 
            menteeUserWrappers.add(new UserWrapper(menteeUser,daysLeft));
        }
        return menteeUserWrappers;
    }
    
    /** This function extend's onboarding date of a mentee along with Reason **/
    @AuraEnabled
    public static Integer extendOnboardingDate(String userId,String onboardingDate,String reasonForExtend){
        Date newOnboardingDate = Date.valueOf(onboardingDate);
        update new User(Id = userId,On_boarding_End_Date__c = newOnboardingDate,Reason_for_Onboarding_Extend__c = reasonForExtend);
        return System.today().daysBetween(newOnboardingDate);
    }
    
    /** This function marks onboarding as completed **/
    @AuraEnabled
    public static void markOnboardingCompleted(String userId){
        update new User(Id = userId,Onboarding_Completed__c = true);
    }
    
    /** Wrapper class for storing User detail and days left for onboarding completion **/
    public class UserWrapper{
        @AuraEnabled
        public User userDetail;
        @AuraEnabled
        public Integer daysLeft;
        
        public UserWrapper(User userDetail,Integer daysLeft){
            this.userDetail = userDetail;
            this.daysLeft = daysLeft;
        }
    }
}