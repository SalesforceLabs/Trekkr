/** Test class for DataUtil **/
@isTest
public with sharing class DataUtil_Test {

    static testMethod void validate_toDateTime(){
        new DataUtil.CustomPicklistRecord('Test Label','Test value');
        new DataUtil.CustomPicklistRecord('Test Label','Test value',true);
        DateTime dateTimeObj = DataUtil.toDateTime('2011-08-12T20:17:46.384Z');
        System.assertEquals(8, dateTimeObj.date().month());
        DataUtil.createChatterLink('https://salesforce.com');
        Schema.DescribeFieldResult fieldResult = Assigned_Task__c.Milestone__c.getDescribe();
        DataUtil.getPicklistValues(fieldResult);
        User lUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator'];
        DataUtil.addManagerPermissionSetToUser(lUser.Id);
        PermissionSet managerPermissionSet = [SELECT Id,Name FROM PermissionSet Where Name = 'Trekkr_Trailmaker'];
        List<PermissionSetAssignment> assignedPermissionSetForUser = [SELECT Id FROM PermissionSetAssignment 
                                                                      WHERE PermissionSetId = :managerPermissionSet.Id AND AssigneeId = :lUser.Id];
        System.assertEquals(1,assignedPermissionSetForUser.size());
        DataUtil.addMentorPermissionSetToUser(lUser.Id);
        PermissionSet mentorPermissionSet = [SELECT Id,Name FROM PermissionSet Where Name = 'Trekkr_Guide'];
        List<PermissionSetAssignment> assignedPermissionSetForUser_1 = [SELECT Id FROM PermissionSetAssignment 
                                                                      WHERE PermissionSetId = :mentorPermissionSet.Id AND AssigneeId = :lUser.Id];
        System.assertEquals(1,assignedPermissionSetForUser.size());
    }
    
}