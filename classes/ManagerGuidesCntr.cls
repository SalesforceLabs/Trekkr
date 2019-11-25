/**
*  Controller for Manager Guide lightning component
**/
public with sharing class ManagerGuidesCntr {
    
    
    /** This function return's list of Mentors and their mentees report to logged in Manager **/
    @AuraEnabled
    public static Map<String,Object> getMentorMenteeDetails(){
        Map<String,Object> returnData = new Map<String,Object>();
        List<String> fields_UURJ = new List<String>(); 
        fields_UURJ.add('User_Role__c');
        List<String> fields_UR = new List<String>();
        fields_UR.add('Name');        
        if(FLSCheck.isAccessible(fields_UR,'User_Role__c') && FLSCheck.isAccessible(fields_UURJ,'User_User_Role_Junction__c')){
               Map<Id,UserWrapper> mentorUsersMap = new Map<Id,UserWrapper>();
               Map<String,List<User>> mentorMenteeUsersMap = new Map<String,List<User>>();
               List<User> menteeUsers = [SELECT Id,FirstName,LastName,FullPhotoUrl,MobilePhone,Email,Energizers__c,Medals__c,
                                         Joining_Date__c,On_boarding_End_Date__c,Mentor__r.FirstName,Mentor__r.LastName,
                                         Mentor__r.FullPhotoUrl,Mentor__r.Email,Mentor__r.Id,
                                         (SELECT Id, User_Role__r.Name FROM User_User_Role_Junctions__r)
                                         FROM User WHERE ManagerId = : UserInfo.getUserId() AND Mentor__c != null];
               for(User menteeUser : menteeUsers){
                   mentorUsersMap.put(menteeUser.Mentor__r.Id,new UserWrapper(menteeUser.Mentor__r.Id,menteeUser.Mentor__r.FirstName,
                                                                              menteeUser.Mentor__r.LastName,menteeUser.Mentor__r.FullPhotoUrl,
                                                                              menteeUser.Mentor__r.Email));
                   List<User> menteeUsersForMentor = new List<User>();
                   if(mentorMenteeUsersMap.containsKey(menteeUser.Mentor__r.Id))
                       menteeUsersForMentor = mentorMenteeUsersMap.get(menteeUser.Mentor__r.Id);
                   menteeUsersForMentor.add(menteeUser);
                   mentorMenteeUsersMap.put(menteeUser.Mentor__r.Id,menteeUsersForMentor);
               }
               returnData.put('MENTORS',mentorUsersMap.values());
               returnData.put('MENTEES_MAP',mentorMenteeUsersMap);
           }
        return returnData;
    }
    
    /** Wrapper class of User details **/
    public class UserWrapper{
        @AuraEnabled
        public String Id;
        @AuraEnabled
        public String FirstName;
        @AuraEnabled
        public String LastName;
        @AuraEnabled
        public String FullPhotoUrl;
        @AuraEnabled
        public String Email;
        
        public UserWrapper(String Id,String FirstName,String LastName,String FullPhotoUrl,String Email){
            this.Id = Id;
            this.FirstName = FirstName;
            this.LastName = LastName;
            this.FullPhotoUrl = FullPhotoUrl;
            this.Email = Email;
        }
    }
    
    /**
*  Aura function to return mentor user details along with all mentee users details.
**/
    @AuraEnabled
    public static List<User> getMentorAndBuddiesDetail(String mentorId){
        Map<String,Object> returnData = new Map<String,Object>();
        List<String> fields_UURJ = new List<String>(); 
        fields_UURJ.add('User_Role__c');
        List<String> fields_UR = new List<String>();
        fields_UR.add('Name');        
        if(FLSCheck.isAccessible(fields_UR,'User_Role__c') && FLSCheck.isAccessible(fields_UURJ,'User_User_Role_Junction__c')){
               return [SELECT Id,FirstName,LastName,FullPhotoUrl,MobilePhone,Email,Energizers__c,Medals__c,
                       Joining_Date__c,On_boarding_End_Date__c,
                       (SELECT Id, User_Role__r.Name FROM User_User_Role_Junctions__r)
                       FROM User WHERE Mentor__c = :mentorId];
           }
        return new List<User>();
    }
    
    /**
* Aura function to return all assigned tasks for a user.
**/
    @AuraEnabled
    public static MentorProfileCntr.MenteeAssignmentInfo getMenteeAssignmentInformation(String userId){
        return MentorProfileCntr.getMenteeAssignmentInformation(userId);
    }     
    
}