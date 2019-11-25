/** Controller for Raise and Close Program component **/
public with sharing class RaiseAndCloseProgramCntr {
    
    /** Returns assigned program details **/
    @AuraEnabled
    public static Assigned_Task__c getProgramDetail(String programId){
        List<String> fields_AT = new List<String>();
        fields_AT.add('Energizers__c');
        fields_AT.add('Feedback__c');
        fields_AT.add('Medals__c');
        fields_AT.add('Current_Value__c');
        fields_AT.add('Milestone__c');
        fields_AT.add('Onboarding_Program__c');
        fields_AT.add('Percentage_Completed__c');
        fields_AT.add('Overdue__c');
        fields_AT.add('Status__c');
        fields_AT.add('Target_Date_Time__c');
        fields_AT.add('Type__c');
        fields_AT.add('Reason_for_Reopen__c');
        fields_AT.add('Assign_To__c');
        List<String> fields_OP = new List<String>();
        fields_OP.add('Name');
        fields_OP.add('Description__c');
        fields_OP.add('Duration__c');
        fields_OP.add('Duration_Type__c');
        fields_OP.add('Duration__c');
        List<String> fields_OT = new List<String>();
        fields_OT.add('Duration__c');
        fields_OT.add('Duration_Type__c');
        fields_OT.add('Name');
        fields_OT.add('Description__c');
        fields_OT.add('Target_Value__c');
        if(FLSCheck.isAccessible(fields_AT,'Assigned_Task__c') && FLSCheck.isAccessible(fields_OP,'Onboarding_Program__c') &&
           FLSCheck.isAccessible(fields_OT,'On_boarding_Task__c')){
               return [SELECT Id,Energizers__c,Feedback__c,Medals__c,
                       Current_Value__c, Milestone__c, Onboarding_Program__r.Name,
                       Onboarding_Program__r.Description__c , Onboarding_Program__r.Duration__c,
                       Onboarding_Program__r.Duration_Type__c,Percentage_Completed__c,
                       Overdue__c,Status__c,Target_Date_Time__c,
                       (SELECT Id,Energizers__c,Medals__c,Reason_for_Reopen__c,
                        Task__r.Duration__c,Task__r.Duration_Type__c,
                        Current_Value__c,Milestone__c,Task__r.Name,
                        Task__r.Description__c,Task__r.Target_Value__c, 
                        Overdue__c,Status__c,Target_Date_Time__c,Task__r.Quantifiable__c 
                        FROM Child_Assigned_Tasks__r)
                       FROM Assigned_Task__c 
                       WHERE Id = :programId 
                       ORDER BY Milestone__c ASC];
           }
        else{
            return null;
        }
    }
}