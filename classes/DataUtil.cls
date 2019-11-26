 /*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 *
 *  Utility class for commonly used functions
 */
public with sharing class DataUtil {
    
    /**
*  Utility function to send emails
**/
    public static void sendEmail(String subject,String htmlBody,String toAddress){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[]{toAddress});
        mail.setHtmlBody(htmlBody);
        mail.setSubject(subject);
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setSaveAsActivity(false);
        mail.setSenderDisplayName(UserInfo.getOrganizationName());
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    /** Creates HTML body of New Mentee Signup Email **/
    public static String getNewMenteeSignupEmailBody(String menteeName,String mentorName,String managerName,String joiningDate){
        String emailBody = '<html><body>';
        emailBody+= 'Hi '+menteeName+',<br/><br/>';
        emailBody+= 'Welcome aboard Trekkr. We are happy to have you with us. Hope you are ready to fall in ';
        emailBody+=  'love with the job and kick off your journey with some learning. Here are the important details :<br/><br/>';
        emailBody+= '<bold>Onboarding Start Date:</bold> '+joiningDate+'<br/>';
        emailBody+= '<bold>Guide:</bold> '+mentorName+'<br/>';
        emailBody+= '<bold>Trailmaker:</bold> '+managerName+'<br/><br/>';
        emailBody+= 'To get started with your onboarding, login to Salesforce and go to Trekkr app.<br/><br/>';
        emailBody+= 'Thanks<br/>';
        emailBody+= 'Trekkr<br/>';
        emailBody+= UserInfo.getOrganizationName();
        emailBody+= '</body></html>';
        return emailBody;
    }
    
    /**
*  Set collection to stop recursive trigger calls.
**/ 
    public static Set<String> triggerMonitor = new Set<String>();   
    
    /**
* Wrapper class for Picklist records to capture label and value 
**/ 
    public class CustomPicklistRecord{
        
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
        @AuraEnabled
        public boolean isSelected;
        
        public CustomPicklistRecord(String label, String value){
            this.label = label;
            this.value = value;
        }
        
        public CustomPicklistRecord(String label, String value,boolean isSelected){
            this.label = label;
            this.value = value;
            this.isSelected = isSelected;
        }
    }
    
    /**
*  Utility function to assign Mentee permission set to an internal user or community user
**/
    public static void addMenteePermissionSetToUser(Id userId){
        User userObj =[Select ContactId From User Where Id=:userId];
        List<String> fieldNames_PS = new List<String>();
        fieldNames_PS.add('Name');
        List<String> fieldNames_PSA = new List<String>();
        fieldNames_PSA.add('PermissionSetId');
        fieldNames_PSA.add('AssigneeId');
        if(FLSCheck.isAccessible(fieldNames_PS, 'PermissionSet') && FLSCheck.isAccessible(fieldNames_PSA, 'PermissionSetAssignment') && 
           FLSCheck.isCreateable(fieldNames_PSA, 'PermissionSetAssignment')){
               if(userObj.ContactId == NULL)
               {
                   PermissionSet menteePermissionSet = [SELECT Id,Name FROM PermissionSet Where Name = 'Trekkr_Explorer'];
                   List<PermissionSetAssignment> assignedPermissionSetForUser = [SELECT Id FROM PermissionSetAssignment WHERE PermissionSetId = :menteePermissionSet.Id AND AssigneeId = :userId];
                   if(assignedPermissionSetForUser.size() == 0){
                       PermissionSetAssignment menteePermissionSetAssignment = new PermissionSetAssignment (PermissionSetId = menteePermissionSet.Id, AssigneeId = userId);
                       insert menteePermissionSetAssignment;
                       
                   }
               }
               else
               {
                   PermissionSet menteePermissionSet = [SELECT Id,Name FROM PermissionSet Where Name = 'Trekkr_Explorer_Community'];
                   List<PermissionSetAssignment> assignedPermissionSetForUser = [SELECT Id FROM PermissionSetAssignment WHERE PermissionSetId = :menteePermissionSet.Id AND AssigneeId = :userId];
                   if(assignedPermissionSetForUser.size() == 0){
                       PermissionSetAssignment menteePermissionSetAssignment = new PermissionSetAssignment (PermissionSetId = menteePermissionSet.Id, AssigneeId = userId);
                       insert menteePermissionSetAssignment;
                       
                   }
               }
               
           }
    }
    
    /**
*  Utility function to assign Mentor permission set to an user
**///Trekkr_Guide_Community-API NAME GUIDE PT
    public static void addMentorPermissionSetToUser(Id userId){
        User userObj =[Select ContactId From User Where Id=:userId];
        List<String> fieldNames_PS = new List<String>();
        fieldNames_PS.add('Name');
        List<String> fieldNames_PSA = new List<String>();
        fieldNames_PSA.add('PermissionSetId');
        fieldNames_PSA.add('AssigneeId');
        if(FLSCheck.isAccessible(fieldNames_PS, 'PermissionSet') && FLSCheck.isAccessible(fieldNames_PSA, 'PermissionSetAssignment') && 
           FLSCheck.isCreateable(fieldNames_PSA, 'PermissionSetAssignment')){
               if(userObj.ContactId == NULL)
               {
                   PermissionSet mentorPermissionSet = [SELECT Id,Name FROM PermissionSet Where Name = 'Trekkr_Guide'];
                   List<PermissionSetAssignment> assignedPermissionSetForUser = [SELECT Id FROM PermissionSetAssignment WHERE PermissionSetId = :mentorPermissionSet.Id AND AssigneeId = :userId];
                   if(assignedPermissionSetForUser.size() == 0){
                       PermissionSetAssignment mentorPermissionSetAssignment = new PermissionSetAssignment (PermissionSetId = mentorPermissionSet.Id, AssigneeId = userId);
                       insert mentorPermissionSetAssignment;
                   }
               }
               else
               {
                   PermissionSet mentorPermissionSet = [SELECT Id,Name FROM PermissionSet Where Name = 'Trekkr_Guide_Community'];
                   List<PermissionSetAssignment> assignedPermissionSetForUser = [SELECT Id FROM PermissionSetAssignment WHERE PermissionSetId = :mentorPermissionSet.Id AND AssigneeId = :userId];
                   if(assignedPermissionSetForUser.size() == 0){
                       PermissionSetAssignment mentorPermissionSetAssignment = new PermissionSetAssignment (PermissionSetId = mentorPermissionSet.Id, AssigneeId = userId);
                       insert mentorPermissionSetAssignment;
                   }
               }
           }
    }
    
    /**
*  Utility function to assign Manager permission set to an user
**/
    public static void addManagerPermissionSetToUser(Id userId){
        User userObj =[Select ContactId From User Where Id=:userId];
        List<String> fieldNames_PS = new List<String>();
        fieldNames_PS.add('Name');
        List<String> fieldNames_PSA = new List<String>();
        fieldNames_PSA.add('PermissionSetId');
        fieldNames_PSA.add('AssigneeId');
        if(FLSCheck.isAccessible(fieldNames_PS, 'PermissionSet') && FLSCheck.isAccessible(fieldNames_PSA, 'PermissionSetAssignment') && 
           FLSCheck.isCreateable(fieldNames_PSA, 'PermissionSetAssignment')){
               if(userObj.ContactId == NULL)
               {
                   PermissionSet managerPermissionSet = [SELECT Id,Name FROM PermissionSet Where Name = 'Trekkr_Trailmaker'];
                   List<PermissionSetAssignment> assignedPermissionSetForUser = [SELECT Id FROM PermissionSetAssignment WHERE PermissionSetId = :managerPermissionSet.Id AND AssigneeId = :userId];
                   if(assignedPermissionSetForUser.size() == 0){
                       PermissionSetAssignment managerPermissionSetAssignment = new PermissionSetAssignment (PermissionSetId = managerPermissionSet.Id, AssigneeId = userId);
                       insert managerPermissionSetAssignment;
                   }
               }
               else{
                   PermissionSet managerPermissionSet = [SELECT Id,Name FROM PermissionSet Where Name = 'Trekkr_Trailmaker_Community'];
                   List<PermissionSetAssignment> assignedPermissionSetForUser = [SELECT Id FROM PermissionSetAssignment WHERE PermissionSetId = :managerPermissionSet.Id AND AssigneeId = :userId];
                   if(assignedPermissionSetForUser.size() == 0){
                       PermissionSetAssignment managerPermissionSetAssignment = new PermissionSetAssignment (PermissionSetId = managerPermissionSet.Id, AssigneeId = userId);
                       insert managerPermissionSetAssignment;
                   }
               }
           }
    }
    
    /**
*  Utility function to assign Admin permission set to users
**///Trekkr_Trailmaker_Community-APIName
    public static void addAdminPermissionSetToUser(List<Id> userIds){
        List<String> fieldNames_PS = new List<String>();
        fieldNames_PS.add('Name');
        List<String> fieldNames_PSA = new List<String>();
        fieldNames_PSA.add('PermissionSetId');
        fieldNames_PSA.add('AssigneeId');
        if(FLSCheck.isAccessible(fieldNames_PS, 'PermissionSet') && FLSCheck.isAccessible(fieldNames_PSA, 'PermissionSetAssignment') && 
           FLSCheck.isCreateable(fieldNames_PSA, 'PermissionSetAssignment')){
               PermissionSet adminPermissionSet = [SELECT Id,Name FROM PermissionSet Where Name = 'Trekkr_Admin'];
               List<PermissionSetAssignment> assignedPermissionSetForUsers = [SELECT Id,AssigneeId FROM PermissionSetAssignment 
                                                                              WHERE PermissionSetId = :adminPermissionSet.Id 
                                                                              AND AssigneeId IN :userIds];
               Set<Id> usersWithAssignedPermission = new Set<Id>();
               for(PermissionSetAssignment assignedPermissionSetForUser : assignedPermissionSetForUsers){
                   usersWithAssignedPermission.add(assignedPermissionSetForUser.AssigneeId);
               }
               List<PermissionSetAssignment> permissionSetAssignmentToInsert = new List<PermissionSetAssignment>();
               for(Id userId : userIds){
                   if(!usersWithAssignedPermission.contains(userId)){
                       permissionSetAssignmentToInsert.add(new PermissionSetAssignment
                                                           (PermissionSetId = adminPermissionSet.Id, 
                                                            AssigneeId = userId));
                   }
               }
               if(permissionSetAssignmentToInsert.size() > 0){
                   insert permissionSetAssignmentToInsert;
               }
           }
    }
    
    /**
*  Utility function to add Business/Operational Record Types & Report permissions
**/
    public static void addMiscellaneousPermissionSetToUser(List<Id> userIds){
        List<String> fieldNames_PS = new List<String>();
        fieldNames_PS.add('Name');
        List<String> fieldNames_PSA = new List<String>();
        fieldNames_PSA.add('PermissionSetId');
        fieldNames_PSA.add('AssigneeId');
        if(FLSCheck.isAccessible(fieldNames_PS, 'PermissionSet') && FLSCheck.isAccessible(fieldNames_PSA, 'PermissionSetAssignment') && 
           FLSCheck.isCreateable(fieldNames_PSA, 'PermissionSetAssignment')){
               //get permission set details
               PermissionSet adminPermissionSet = [SELECT Id,Name FROM PermissionSet Where Name = 'Trekkr_OtherPermissions'];
               //get already assigned users from the user Ids for the permission set
               List<PermissionSetAssignment> assignedPermissionSetForUsers = [SELECT Id,AssigneeId FROM PermissionSetAssignment 
                                                                              WHERE PermissionSetId = :adminPermissionSet.Id 
                                                                              AND AssigneeId IN :userIds];
               //add already assigned users to a list
               Set<Id> usersWithAssignedPermission = new Set<Id>();
               for(PermissionSetAssignment assignedPermissionSetForUser : assignedPermissionSetForUsers){
                   usersWithAssignedPermission.add(assignedPermissionSetForUser.AssigneeId);
               }
               List<PermissionSetAssignment> permissionSetAssignmentToInsert = new List<PermissionSetAssignment>();
               for(Id userId : userIds){
                   //check if user is NOT in already assigned users
                   if(!usersWithAssignedPermission.contains(userId) && userId != null){
                       permissionSetAssignmentToInsert.add(new PermissionSetAssignment
                                                           (PermissionSetId = adminPermissionSet.Id, 
                                                            AssigneeId = userId));
                   }
               }
               //assign permission set if list has values
               if(permissionSetAssignmentToInsert.size() > 0){
                   insert permissionSetAssignmentToInsert;
               }
           }
    }
    
    /**
* Returns picklist values from a field in sObject
**/
    public static List<CustomPicklistRecord> getPicklistValues(Schema.DescribeFieldResult fieldResult){
        List<CustomPicklistRecord> options = new List<CustomPicklistRecord>();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new CustomPicklistRecord(f.getLabel(), f.getValue()));
        }       
        return options;
    }
    
    /**
* Creates a @mention for chatter post
**/ 
    public static ConnectApi.MentionSegmentInput createChatterMention(String objectId){
        ConnectApi.MentionSegmentInput mentionSegment = new ConnectApi.MentionSegmentInput();
        mentionSegment.id = objectId;
        return mentionSegment;
    }
    
    /**
* Creates a text message for chatter post
**/
    public static ConnectApi.TextSegmentInput createChatterText(String text){
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
        textSegmentInput.text = text;
        return textSegmentInput;
    }
    
    /**
* Creates a link message for chatter post
**/
    public static ConnectApi.LinkSegmentinput createChatterLink(String url){
        ConnectApi.LinkSegmentinput linksegment = new ConnectApi.LinkSegmentinput();
        linksegment.url = url;
        return linksegment;
    }
    
    /**
* Creates and posts a chatter post.
**/
    public static void createChatterpost(String subjectId, List<ConnectApi.MessageSegmentInput> segmentInputs){
        if(!Test.isRunningTest()){
            ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
            feedItemInput.subjectId = subjectId;
            ConnectApi.FeedItemVisibilityType feedVisibility = ConnectApi.FeedItemVisibilityType.AllUsers;
            feedItemInput.visibility = feedVisibility;
            ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
            messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
            for(ConnectApi.MessageSegmentInput segmentInput : segmentInputs){
                messageBodyInput.messageSegments.add(segmentInput);
            }
            feedItemInput.body = messageBodyInput;
            if(Network.getNetworkId() != NULL){
                ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
            }
            
            //ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement('0DB0o000000NvolGAC',feedItemInput);
        }
    }
    
    /**
* Converts DateTime String to DateTime object
**/
    public static DateTime toDateTime(String DateTimevalue) {
        List<String> DateAndTimeList = DateTimevalue.split('T');
        List<String> dayList = DateAndTimeList[0].split('-');
        List<string> timeList = DateAndTimeList[1].split(':');
        DateTime dt = DateTime.newInstance(Integer.valueOf(dayList[0]), Integer.valueOf(dayList[1]),Integer.valueOf(dayList[2]),Integer.valueOf(timeList[0]), Integer.valueOf(timeList[1]), Integer.valueOf(timeList[2].split('\\.')[0]));
        return dt;
    }
}