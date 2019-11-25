/**
*  Test class for the MenteeOpTaskListCntr controller
**/
@isTest
public with sharing class MenteeOpTaskListCntr_Test {
    
	static testMethod void validate_changeStatusOfTask() {
		Assigned_Task__c assignedTask = TestDataUtil.getAssignedTask();
        insert assignedTask;
        Assigned_Task__c aTask = MenteeOpTaskListCntr.changeStatusOfTask(assignedTask);
        System.assertEquals('Completed', aTask.Status__c);
        Assigned_Task__c progTask = MenteeOpTaskListCntr.changeStatusOfTask(aTask);
        System.assertEquals('In-Progress', progTask.Status__c);
    }
    
    static testMethod void validate_getMenteeTasks(){
        List<Assigned_Task__c> aTasks = MenteeOpTaskListCntr.getMenteeTasks();
        System.assertEquals(0, aTasks.size());
    }
}