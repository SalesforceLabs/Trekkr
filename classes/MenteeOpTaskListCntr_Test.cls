 /*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 *
 * Test class for the MenteeOpTaskListCntr controller
 */
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