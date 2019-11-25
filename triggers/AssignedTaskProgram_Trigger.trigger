trigger AssignedTaskProgram_Trigger on Assigned_Task__c (after update,after insert) {
    if(Trigger.isAfter){
        if(Trigger.isUpdate){
            List<Id> recalculateAssignedProgramIds = new List<Id>();
            Set<Id> updateEnergizersAndMedalsForUser = new Set<Id>();
            List<Id> verifyUsersAllOpsTaskCompleted = new List<Id>();
            Id opTaskRecordTypeId = null;
            RecordTypeInfo opRecordTypeInfo = Schema.SObjectType.On_boarding_Task__c.getRecordTypeInfosByName().get('Operational');
            if(opRecordTypeInfo.isAvailable()){
                opTaskRecordTypeId = opRecordTypeInfo.getRecordTypeId();
            }
            List<String> fields_AT = new List<String>();
            fields_AT.add('Status__c');
            fields_AT.add('Assign_To__c');
            fields_AT.add('Onboarding_Program__c');
            fields_AT.add('Energizers__c');
            fields_AT.add('Task__c');
            fields_AT.add('Medals__c');
            fields_AT.add('Overdue__c');
            fields_AT.add('Parent_Assigned_Task__c');
            fields_AT.add('Reason_for_Reopen__c');
            fields_AT.add('Feedback__c');
            List<String> fields_OT = new List<String>();
            fields_OT.add('RecordTypeId');
            fields_OT.add('Level__c');
            fields_OT.add('Name');
            List<String> fields_OP = new List<String>();
            fields_OP.add('Name');
            if(FLSCheck.isAccessible(fields_AT,'Assigned_Task__c') && FLSCheck.isAccessible(fields_OT, 'On_boarding_Task__c') && 
               FLSCheck.isAccessible(fields_OP,'Onboarding_Program__c')){
                   List<Assigned_Task__c> assignedTaskPrograms = [SELECT Id,Status__c,Assign_To__c,Onboarding_Program__c,Energizers__c, 
                                                                         Task__c,Assign_To__r.Mentor__c, Overdue__c,Task__r.RecordTypeId,
                                                                         Task__r.Level__c,Medals__c, Parent_Assigned_Task__c,
                                                                         Parent_Assigned_Task__r.Medals__c,Reason_for_Reopen__c,
                                                                         Feedback__c,Onboarding_Program__r.Name,Task__r.Name
                                                                         FROM Assigned_Task__c WHERE Id IN :Trigger.New];
                   Map<Id,Assigned_Task__c> assignedTaskProgramsToUpdate = new Map<Id,Assigned_Task__c>();
                   for(Assigned_Task__c assignedTaskProgram : assignedTaskPrograms){
                       if(assignedTaskProgram.Task__c !=null && assignedTaskProgram.Task__r.RecordTypeId == opTaskRecordTypeId){
                           if((assignedTaskProgram.Status__c == 'Completed' && Trigger.oldMap.get(assignedTaskProgram.Id).Status__c != 'Completed') ||
                              (assignedTaskProgram.Status__c == 'Closed' && Trigger.oldMap.get(assignedTaskProgram.Id).Status__c != 'Closed')){
                                  if(assignedTaskProgram.Parent_Assigned_Task__c != null)
                                      recalculateAssignedProgramIds.add(assignedTaskProgram.Parent_Assigned_Task__c);
                                  verifyUsersAllOpsTaskCompleted.add(assignedTaskProgram.Assign_To__c);
                              }
                       }else{
                           if(assignedTaskProgram.Status__c == 'Completed' && Trigger.oldMap.get(assignedTaskProgram.Id).Status__c != 'Completed'){
                               //Notifying Mentor and add Medals for completed Program 
                               if(assignedTaskProgram.Onboarding_Program__c != null){
                                   NotificationsManager.notifyMentorForCompletedProgram(assignedTaskProgram.Assign_To__c,
                                                                                        assignedTaskProgram.Assign_To__r.Mentor__c,assignedTaskProgram.Id);
                                   Integer earnedMedals = GamificationManager.getEarnedMedals();
                                   assignedTaskProgram.Medals__c = earnedMedals;
                                   assignedTaskProgramsToUpdate.put(assignedTaskProgram.Id,assignedTaskProgram);
                                   updateEnergizersAndMedalsForUser.add(assignedTaskProgram.Assign_To__c);
                               }
                               // Add Energizers for Completed Task when task status is changed to Complete but not after Reopen
                               else if(assignedTaskProgram.Task__c != null){
                                   if(assignedTaskProgram.Reason_for_Reopen__c == '' || assignedTaskProgram.Reason_for_Reopen__c == null){
                                       Integer earnedEnergizers = GamificationManager.getEarnedEnergizers(assignedTaskProgram.Task__r.Level__c,
                                                                                                          false,assignedTaskProgram.Overdue__c);
                                       assignedTaskProgram.Energizers__c =  earnedEnergizers;
                                       assignedTaskProgramsToUpdate.put(assignedTaskProgram.Id,assignedTaskProgram);
                                   }
                                   if(assignedTaskProgram.Parent_Assigned_Task__c != null)
                                       recalculateAssignedProgramIds.add(assignedTaskProgram.Parent_Assigned_Task__c);
                               }
                           }else if(assignedTaskProgram.Task__c != null && assignedTaskProgram.Status__c == 'In-Progress' &&
                                    assignedTaskProgram.Reason_for_Reopen__c != '' &&
                                    (Trigger.oldMap.get(assignedTaskProgram.Id).Status__c == 'Completed' || 
                                     Trigger.oldMap.get(assignedTaskProgram.Id).Status__c == 'Closed')){
                                         Integer updatedEnergizers = GamificationManager.deductEnergizersForReopen(assignedTaskProgram.Task__r.Level__c,
                                                                                                                   Integer.valueOf(assignedTaskProgram.Energizers__c));
                                         assignedTaskProgram.Energizers__c =  updatedEnergizers;
                                         assignedTaskProgramsToUpdate.put(assignedTaskProgram.Id,assignedTaskProgram);
                                         if(assignedTaskProgram.Parent_Assigned_Task__c != null)
                                             recalculateAssignedProgramIds.add(assignedTaskProgram.Parent_Assigned_Task__c);
                                     }
                           else if(assignedTaskProgram.Onboarding_Program__c != null && assignedTaskProgram.Feedback__c != null && 
                                   assignedTaskProgram.Feedback__c != '' && 
                                   assignedTaskProgram.Feedback__c != Trigger.oldMap.get(assignedTaskProgram.Id).Feedback__c){
                                       //Notify Mentee when feedback has been given by Mentor
                                       NotificationsManager.notifyMenteeForProgramFeedback(assignedTaskProgram.Assign_To__c,
                                                                                           assignedTaskProgram.Id,
                                                                                           assignedTaskProgram.Onboarding_Program__r.Name,
                                                                                           assignedTaskProgram.Feedback__c); 
                                   }
                           else if(assignedTaskProgram.Status__c == 'Closed' && Trigger.oldMap.get(assignedTaskProgram.Id).Status__c != 'Closed' && 
                                   assignedTaskProgram.Task__c != null){
                                       //Notify Mentee when task has been marked as closed
                                       NotificationsManager.notifyMenteeForProgramClose(assignedTaskProgram.Assign_To__c,assignedTaskProgram.Id,
                                                                                        assignedTaskProgram.Task__r.Name);
                                   }
                       }
                   }
                   if(verifyUsersAllOpsTaskCompleted.size()>0){
                       TriggerUtil.verifyAndNotifyAllOpTaskCompleted(verifyUsersAllOpsTaskCompleted,opTaskRecordTypeId);
                   }
                   if(recalculateAssignedProgramIds.size()>0){
                       List<Assigned_Task__c> recalculateAssignedPrograms = [SELECT Id,Status__c,Energizers__c,Assign_To__c,
                                                                                    (SELECT Id,Status__c,Energizers__c 
                                                                                     FROM Child_Assigned_Tasks__r) FROM Assigned_Task__c 
                                                                                    WHERE Id IN :recalculateAssignedProgramIds];
                       for(Assigned_Task__c recalculateAssignedProgram : recalculateAssignedPrograms){
                           Boolean allTasksCompleted = true;
                           Decimal totalEnergizers = 0;
                           for(Assigned_Task__c childAssignedTask : recalculateAssignedProgram.Child_Assigned_Tasks__r){
                               Assigned_Task__c assignedTaskToUse;
                               if(assignedTaskProgramsToUpdate.containsKey(childAssignedTask.Id)){
                                   assignedTaskToUse = assignedTaskProgramsToUpdate.get(childAssignedTask.Id);
                               }else{
                                   assignedTaskToUse = childAssignedTask;
                               }
                               if(assignedTaskToUse.Status__c != 'Completed' && assignedTaskToUse.Status__c != 'Closed'){
                                   allTasksCompleted = false;
                               }   
                               if(assignedTaskToUse.Energizers__c != null)
                                   totalEnergizers += assignedTaskToUse.Energizers__c;
                           }
                           if(recalculateAssignedProgram.Status__c != 'Completed' && recalculateAssignedProgram.Status__c != 'Closed' 
                              && allTasksCompleted){
                                  recalculateAssignedProgram.Status__c = 'Completed';               
                              }
                           recalculateAssignedProgram.Energizers__c = totalEnergizers;
                           assignedTaskProgramsToUpdate.put(recalculateAssignedProgram.Id,recalculateAssignedProgram);
                           updateEnergizersAndMedalsForUser.add(recalculateAssignedProgram.Assign_To__c);
                       }
                   }
                   if(assignedTaskProgramsToUpdate.size()>0 && FLSCheck.isUpdateable(fields_AT,'Assigned_Task__c'))
                       update assignedTaskProgramsToUpdate.values();
                   if(updateEnergizersAndMedalsForUser.size()>0){
                       TriggerUtil.updateEnergizersAndMedalsOnUser(new List<Id>(updateEnergizersAndMedalsForUser));
                   }
               }
        }
        if(Trigger.isInsert){
            Map<Id,List<Assigned_Task__c>> assignedProgramsMap = new Map<Id,List<Assigned_Task__c>>();
            List<String> fields_AT = new List<String>();
            fields_AT.add('Assign_To__c');
            fields_AT.add('Onboarding_Program__c');
            fields_AT.add('Milestone__c');
            List<String> fields_OP = new List<String>();
            fields_OP.add('Name');
            if(FLSCheck.isAccessible(fields_AT,'Assigned_Task__c') && FLSCheck.isAccessible(fields_OP,'Onboarding_Program__c')){
                List<Assigned_Task__c> assignedTaskPrograms = [SELECT Id,Assign_To__c,Onboarding_Program__c,
                                                                      Onboarding_Program__r.Name,Milestone__c 
                                                                      FROM Assigned_Task__c WHERE Id IN: Trigger.New];
                for(Assigned_Task__c assignedTaskProgram : assignedTaskPrograms){
                    if(assignedTaskProgram.Onboarding_Program__c != null){
                        List<Assigned_Task__c> lAssignedPrograms = new List<Assigned_Task__c>();          
                        if(assignedProgramsMap.containsKey(assignedTaskProgram.Onboarding_Program__c)){
                            lAssignedPrograms = assignedProgramsMap.get(assignedTaskProgram.Onboarding_Program__c);
                        }
                        lAssignedPrograms.add(assignedTaskProgram);
                        assignedProgramsMap.put(assignedTaskProgram.Onboarding_Program__c,lAssignedPrograms);
                        NotificationsManager.notifyMenteeForAssignedTrail(assignedTaskProgram.Assign_To__c,
                                                                          assignedTaskProgram.Id,
                                                                          assignedTaskProgram.Onboarding_Program__r.Name,
                                                                          assignedTaskProgram.Milestone__c);
                    }
                }
                if(assignedProgramsMap.size()>0){
                    //Programs are inserted
                    List<Assigned_Task__c> assignedTasksForProgram = new List<Assigned_Task__c>();
                    Map<Id,List<Id>> programTasksMap = new Map<Id,List<Id>>();
                    List<String> fields_OPTJ = new List<String>();
                    fields_OPTJ.add('Onboarding_Program__c');
                    fields_OPTJ.add('Onboarding_Task__c');
                    if(FLSCheck.isAccessible(fields_OPTJ, 'Onboarding_Program_Task_Junction__c')){                    
                        List<Onboarding_Program_Task_Junction__c> programTaskJunctions = [SELECT Id,Onboarding_Program__c,
                                                                                                 Onboarding_Task__c 
                                                                                                 FROM Onboarding_Program_Task_Junction__c 
                                                                                                 WHERE Onboarding_Program__c IN :assignedProgramsMap.keySet()];
                        for(Onboarding_Program_Task_Junction__c programTaskJunction : programTaskJunctions){
                            List<Id> lTaskIds = new List<Id>();
                            if(programTasksMap.containsKey(programTaskJunction.Onboarding_Program__c)){
                                lTaskIds = programTasksMap.get(programTaskJunction.Onboarding_Program__c);
                            }
                            lTaskIds.add(programTaskJunction.Onboarding_Task__c);
                            programTasksMap.put(programTaskJunction.Onboarding_Program__c,lTaskIds);
                        }
                        for(Id programId : programTasksMap.keySet()){
                            List<Assigned_Task__c> assignedProgramsDetails = assignedProgramsMap.get(programId);
                            List<Id> tasksToAssign = programTasksMap.get(programId);
                            for(Assigned_Task__c assignedProgramsDetail : assignedProgramsDetails){
                                for(Id taskToAssign : tasksToAssign){
                                    assignedTasksForProgram.add(new Assigned_Task__c(
                                        Assign_To__c = assignedProgramsDetail.Assign_To__c,
                                        Parent_Assigned_Task__c = assignedProgramsDetail.Id,
                                        Task__c  = taskToAssign,
                                        Status__c = 'New'
                                    ));
                                }   
                            }
                        }
                        List<String> fields_AT_C = new List<String>();
                        fields_AT_C.add('Assign_To__c');
                        fields_AT_C.add('Parent_Assigned_Task__c');
                        fields_AT_C.add('Task__c');
                        fields_AT_C.add('Status__c');
                        if(assignedTasksForProgram.size()>0 && FLSCheck.isCreateable(fields_AT,'Assigned_Task__c'))
                            insert assignedTasksForProgram;
                    }
                }
            }
        }
    }
}