public without sharing class TriggerUtil {
    
    /** Function to share the First Aid record with the Submitted To User and notifying user on chatter  **/
    public static void shareFirstAidRecord(List<First_Aid__c> firstAids,Boolean notifyUsers){
        try{
            List<First_Aid__Share> fistAidShares  = new List<First_Aid__Share>();
            for(First_Aid__c firstAid : firstAids){
                First_Aid__Share assignedToShare = new First_Aid__Share();
                assignedToShare.ParentId = firstAid.Id;
                assignedToShare.UserOrGroupId = firstAid.Submit_To__c;
                assignedToShare.AccessLevel = 'Edit';
                assignedToShare.RowCause = Schema.First_Aid__Share.RowCause.First_Aid_Assigned__c;
                fistAidShares.add(assignedToShare);
                if(notifyUsers){
                    NotificationsManager.notifyUserForRaisedFirstAid(firstAid.OwnerId,firstAid.Submit_To__c,firstAid.Id);
                }
            }
            insert fistAidShares;
        }catch(Exception e){
            System.debug('ERROR'+e);
        }
    }
    
    /** Function to update Energizers and Medals on User record **/
    public static void updateEnergizersAndMedalsOnUser(List<Id> assignedToUsers){
        List<String> fields_AT = new List<String>(); 
        fields_AT.add('Medals__c');
        fields_AT.add('Energizers__c');
        fields_AT.add('Onboarding_Program__c');
        fields_AT.add('Assign_To__c');
        if(FLSCheck.isAccessible(fields_AT,'Assigned_Task__c')){
            List<Assigned_Task__c> assignedPrograms = [SELECT Id,Medals__c,Energizers__c,Onboarding_Program__c,Assign_To__c 
                                                              FROM Assigned_Task__c WHERE (Assign_To__c IN :assignedToUsers
                                                                                                  AND Onboarding_Program__c != null)];
            Map<Id,List<Assigned_Task__c>> assignedProgramsToUserMap = new Map<Id,List<Assigned_Task__c>>();
            for(Assigned_Task__c assignedProgram : assignedPrograms){
                List<Assigned_Task__c> lAssignedTasks = new List<Assigned_Task__c>();
                if(assignedProgramsToUserMap.containsKey(assignedProgram.Assign_To__c)){
                    lAssignedTasks = assignedProgramsToUserMap.get(assignedProgram.Assign_To__c);
                }
                lAssignedTasks.add(assignedProgram);
                assignedProgramsToUserMap.put(assignedProgram.Assign_To__c,lAssignedTasks);
            }
            List<User> usersToUpdate = new List<User>();
            for(Id userId : assignedProgramsToUserMap.keySet()){
                Decimal totalEnergizers = 0,totalMedals=0;
                for(Assigned_Task__c assignedTaskToUser : assignedProgramsToUserMap.get(userId)){
                    if(assignedTaskToUser.Energizers__c !=null)
                        totalEnergizers += assignedTaskToUser.Energizers__c;
                    if(assignedTaskToUser.Medals__c !=null)
                        totalMedals += assignedTaskToUser.Medals__c;
                }
                usersToUpdate.add(new User(Id= userId));
            }
            update usersToUpdate;
        }
    }
    
    /** Check's if old value is equal to new value **/
    public static Boolean isSame(String oldValue, String newValue){
        return oldValue.equals(newValue);
    }
    
    /** Function verify the completion of all the Operational tasks of users  **/
    public static void verifyAndNotifyAllOpTaskCompleted(List<Id> assignedToUsers,String opTaskRecordTypeId){
        List<String> fields_AT = new List<String>(); 
        fields_AT.add('Status__c');
        fields_AT.add('Assign_To__c');
        fields_AT.add('Task__c');
        if(FLSCheck.isAccessible(fields_AT,'Assigned_Task__c')){
            List<Assigned_Task__c> assignedOpTasks = [SELECT Id,Status__c,Assign_To__c,Assign_To__r.Mentor__c 
                                                             FROM Assigned_Task__c WHERE Assign_To__c IN :assignedToUsers 
                                                             AND Task__c != null AND Task__r.RecordTypeId = :opTaskRecordTypeId];
            Map<Id,List<Assigned_Task__c>> assignedOpTasksToUserMap = new Map<Id,List<Assigned_Task__c>>();
            for(Assigned_Task__c assignedOpTask : assignedOpTasks){
                List<Assigned_Task__c> lAssignedTasks = new List<Assigned_Task__c>();
                if(assignedOpTasksToUserMap.containsKey(assignedOpTask.Assign_To__c)){
                    lAssignedTasks = assignedOpTasksToUserMap.get(assignedOpTask.Assign_To__c);
                }
                lAssignedTasks.add(assignedOpTask);
                assignedOpTasksToUserMap.put(assignedOpTask.Assign_To__c,lAssignedTasks);
            }
            for(Id userId :assignedOpTasksToUserMap.keySet()){
                Boolean allOpTaskCompleted = true;
                Id menteeId, mentorId;
                for(Assigned_Task__c assignedTaskToUser : assignedOpTasksToUserMap.get(userId)){
                    menteeId = assignedTaskToUser.Assign_To__c;
                    mentorId = assignedTaskToUser.Assign_To__r.Mentor__c;
                    if(assignedTaskToUser.Status__c != 'Completed' && assignedTaskToUser.Status__c != 'Closed'){
                        allOpTaskCompleted = false;
                        break;
                    }
                }
                if(allOpTaskCompleted)
                    NotificationsManager.notifyForCompletedAllOpTasks(menteeId,mentorId);
            }
        }
    }
}