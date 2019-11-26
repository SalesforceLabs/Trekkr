 /*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
public with sharing class NotificationsManager {
    
    public static final String NEW_LINE = '\n';
    public static final String WELCOME_NEW_JOINEE = 'Welcome aboard Trekkr. We are happy to have you with us. Hope you are ready to'+
        ' fall in love with the job and kick off your journey with some learning.';
    public static final String COMPLETED_ALL_OPERATIONAL_TASKS = 'Your explorer ';
    public static final String COMPLETED_ALL_OPERATIONAL_TASKS_1 = ' is setting trails ablaze! All the operational steps are done.';
    public static final String RAISED_FIRST_AID = NEW_LINE + 'Attention, please! A First Aid request awaits to be addressed. Click link to view'+NEW_LINE;
    public static final String COMPLETE_PROGRAM = ' has completed the assigned Trail. Click link to view';
    public static final String ONBOARDING_EXTENDED = 'Your trailmaker extended the onboarding by ';
    public static final String ONBOARDING_EXTENDED_1 = 'Your onboarding now ends on ';
    public static final String VISION_VALUES_UPDATED = ' has updated Vision and Values for Onboarding.';
    public static final String SALUTATION = 'Hi ';
    public static final String THANKS = NEW_LINE+NEW_LINE+'Thanks!';
    public static final String ASSIGNED_NEW_TRAIL = ' A new trail \'';
    public static final String ASSIGNED_NEW_TRAIL_1 = '\' has been assigned to you under ';
    public static final String ASSIGNED_NEW_TRAIL_2 = '. Happy learning!';
    public static final String PROGRAM_FEEDBACK = 'You have received feedback on ';
    public static final String PROGRAM_FEEDBACK_1 = ' Trail .';
    public static final String PROGRAM_FEEDBACK_2 = 'Feedback : ';
    public static final String PROGRAM_CLOSED = 'Congrats! Your ';
    public static final String PROGRAM_CLOSED_1 = ' Step has been marked as closed';
    
    public static void notifyMenteeForProgramClose(String menteeId,String programId,String programName){
        List<ConnectApi.MessageSegmentInput> segmentInputs = new List<ConnectApi.MessageSegmentInput>();
        segmentInputs.add(DataUtil.createChatterText(SALUTATION));
        segmentInputs.add(DataUtil.createChatterMention(menteeId));
        segmentInputs.add(DataUtil.createChatterText(NEW_LINE+NEW_LINE));
        segmentInputs.add(DataUtil.createChatterText(PROGRAM_CLOSED));
        segmentInputs.add(DataUtil.createChatterText(programName));
        segmentInputs.add(DataUtil.createChatterText(PROGRAM_CLOSED_1));
        segmentInputs.add(DataUtil.createChatterText(THANKS));
        DataUtil.createChatterpost(programId,segmentInputs);
    }

    public static void notifyMenteeForProgramFeedback(String menteeId,String programId,String programName,String feedback){
        List<ConnectApi.MessageSegmentInput> segmentInputs = new List<ConnectApi.MessageSegmentInput>();
        segmentInputs.add(DataUtil.createChatterText(SALUTATION));
        segmentInputs.add(DataUtil.createChatterMention(menteeId));
        segmentInputs.add(DataUtil.createChatterText(NEW_LINE+NEW_LINE));
        segmentInputs.add(DataUtil.createChatterText(PROGRAM_FEEDBACK));
        segmentInputs.add(DataUtil.createChatterText(programName));
        segmentInputs.add(DataUtil.createChatterText(PROGRAM_FEEDBACK_1));
        segmentInputs.add(DataUtil.createChatterText(NEW_LINE+NEW_LINE));
        segmentInputs.add(DataUtil.createChatterText(PROGRAM_FEEDBACK_2));
        segmentInputs.add(DataUtil.createChatterText(NEW_LINE));
		segmentInputs.add(DataUtil.createChatterText(feedback)); 
        segmentInputs.add(DataUtil.createChatterText(THANKS));
        DataUtil.createChatterpost(programId,segmentInputs);
    }
    
    public static void notifyMenteeForOnboardingStarted(String menteeId,String mentorId,String managerId,String joiningDate){
        List<ConnectApi.MessageSegmentInput> segmentInputs = new List<ConnectApi.MessageSegmentInput>();
        segmentInputs.add(DataUtil.createChatterText('Dear '));
        segmentInputs.add(DataUtil.createChatterMention(menteeId));
        segmentInputs.add(DataUtil.createChatterText(NEW_LINE+NEW_LINE));
        segmentInputs.add(DataUtil.createChatterText(WELCOME_NEW_JOINEE));
        segmentInputs.add(DataUtil.createChatterText(NEW_LINE+'Onboarding Start Date: '+joiningDate));
        if(mentorId != null){
            segmentInputs.add(DataUtil.createChatterText(NEW_LINE+'Guide: '));
            segmentInputs.add(DataUtil.createChatterMention(mentorId));
        }
        if(managerId != null){
            segmentInputs.add(DataUtil.createChatterText(NEW_LINE+'Trailmaker: '));
            segmentInputs.add(DataUtil.createChatterMention(managerId));
        }
        DataUtil.createChatterpost(menteeId,segmentInputs);
    }
    
    public static void notifyForCompletedAllOpTasks(String menteeId,String mentorId){
        List<ConnectApi.MessageSegmentInput> segmentInputs = new List<ConnectApi.MessageSegmentInput>();
        segmentInputs.add(DataUtil.createChatterText(SALUTATION));
        segmentInputs.add(DataUtil.createChatterMention(mentorId));
        segmentInputs.add(DataUtil.createChatterText(NEW_LINE));
        segmentInputs.add(DataUtil.createChatterText(COMPLETED_ALL_OPERATIONAL_TASKS));
        segmentInputs.add(DataUtil.createChatterMention(menteeId));
        segmentInputs.add(DataUtil.createChatterText(COMPLETED_ALL_OPERATIONAL_TASKS_1));
        segmentInputs.add(DataUtil.createChatterText(THANKS));
        DataUtil.createChatterpost(mentorId,segmentInputs);
    }
    
    public static void notifyUserForRaisedFirstAid(String menteeId,String mentorId,String firstAidId){
        List<ConnectApi.MessageSegmentInput> segmentInputs = new List<ConnectApi.MessageSegmentInput>();
        segmentInputs.add(DataUtil.createChatterText(SALUTATION));
        segmentInputs.add(DataUtil.createChatterMention(mentorId));
        segmentInputs.add(DataUtil.createChatterText(RAISED_FIRST_AID));
        segmentInputs.add(DataUtil.createChatterLink(System.Url.getSalesforceBaseUrl().toExternalForm()+'/lightning/r/First_Aid__c/'+firstAidId+'/view'));
        segmentInputs.add(DataUtil.createChatterText(THANKS));
        DataUtil.createChatterpost(mentorId,segmentInputs);
    }
    
    public static void notifyMentorForCompletedProgram(String menteeId,String mentorId,String programId){
        List<ConnectApi.MessageSegmentInput> segmentInputs = new List<ConnectApi.MessageSegmentInput>();
        segmentInputs.add(DataUtil.createChatterText(SALUTATION));
        segmentInputs.add(DataUtil.createChatterMention(mentorId));
        segmentInputs.add(DataUtil.createChatterText(NEW_LINE+NEW_LINE));
        segmentInputs.add(DataUtil.createChatterMention(menteeId));
        segmentInputs.add(DataUtil.createChatterText(COMPLETE_PROGRAM));
        segmentInputs.add(DataUtil.createChatterText(NEW_LINE+NEW_LINE));
        segmentInputs.add(DataUtil.createChatterLink(system.Url.getSalesforceBaseUrl().toExternalForm()+'/lightning/n/Review_Trail?Id='+programId));
        segmentInputs.add(DataUtil.createChatterText(THANKS));
        DataUtil.createChatterpost(programId,segmentInputs);
    }
    
    public static void notifyMenteeForOnboardingExtend(String menteeId,Decimal daysExtended, String onboardingEndDate){
        List<ConnectApi.MessageSegmentInput> segmentInputs = new List<ConnectApi.MessageSegmentInput>();
        segmentInputs.add(DataUtil.createChatterText(SALUTATION));
        segmentInputs.add(DataUtil.createChatterMention(menteeId));
        segmentInputs.add(DataUtil.createChatterText(NEW_LINE+NEW_LINE));
        segmentInputs.add(DataUtil.createChatterText(ONBOARDING_EXTENDED));
        segmentInputs.add(DataUtil.createChatterText(daysExtended+(daysExtended<2?' day. ':' days. ')));
        segmentInputs.add(DataUtil.createChatterText(ONBOARDING_EXTENDED_1));
        segmentInputs.add(DataUtil.createChatterText(onboardingEndDate));
        segmentInputs.add(DataUtil.createChatterText(THANKS));
        DataUtil.createChatterpost(menteeId,segmentInputs);
    }
    
    public static void notifyMentorForVisionValuesUpdate(String menteeId,String mentorId, String vision,String values){
        List<ConnectApi.MessageSegmentInput> segmentInputs = new List<ConnectApi.MessageSegmentInput>();
        segmentInputs.add(DataUtil.createChatterMention(mentorId));
        segmentInputs.add(DataUtil.createChatterText(NEW_LINE+NEW_LINE));
        segmentInputs.add(DataUtil.createChatterMention(menteeId));
        segmentInputs.add(DataUtil.createChatterText(VISION_VALUES_UPDATED));
        segmentInputs.add(DataUtil.createChatterText(NEW_LINE+NEW_LINE));
        segmentInputs.add(DataUtil.createChatterText('Vision :'));
        segmentInputs.add(DataUtil.createChatterText(NEW_LINE));
        segmentInputs.add(DataUtil.createChatterText(vision));
        segmentInputs.add(DataUtil.createChatterText(NEW_LINE+NEW_LINE));
        segmentInputs.add(DataUtil.createChatterText('Values :'));
        segmentInputs.add(DataUtil.createChatterText(NEW_LINE));
        segmentInputs.add(DataUtil.createChatterText(values));
        segmentInputs.add(DataUtil.createChatterText(THANKS));
        DataUtil.createChatterpost(menteeId,segmentInputs);
    }
    
    public static void notifyMenteeForAssignedTrail(String menteeId,String programId,String trailName,String milestoneName){
        List<ConnectApi.MessageSegmentInput> segmentInputs = new List<ConnectApi.MessageSegmentInput>();
        segmentInputs.add(DataUtil.createChatterText(SALUTATION));
        segmentInputs.add(DataUtil.createChatterMention(menteeId));
        segmentInputs.add(DataUtil.createChatterText(NEW_LINE+NEW_LINE));
        segmentInputs.add(DataUtil.createChatterText(ASSIGNED_NEW_TRAIL));
        segmentInputs.add(DataUtil.createChatterText(trailName));
        segmentInputs.add(DataUtil.createChatterText(ASSIGNED_NEW_TRAIL_1));
        segmentInputs.add(DataUtil.createChatterText(milestoneName));
        segmentInputs.add(DataUtil.createChatterText(ASSIGNED_NEW_TRAIL_2));
        DataUtil.createChatterpost(programId,segmentInputs);
    }
}