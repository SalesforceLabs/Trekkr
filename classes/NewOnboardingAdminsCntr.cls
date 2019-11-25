public with sharing class NewOnboardingAdminsCntr {
    
    /** This function return's list of all users **/
    @AuraEnabled
    public static List<User> getUser(){
        return [SELECT Id,FirstName,LastName FROM User];
    }
    
    /** This function assigns Admin permission set to users **/
    @AuraEnabled
    public static void assignAdminRole(String userIds){
        addPermissionSets(userIds);
        addOtherPermissionSets(userIds);
    }
    
    /** Future method to assign Admin permission set **/
    @future
    public static void addPermissionSets(String userIds){
        DataUtil.addAdminPermissionSetToUser(userIds.split(';'));
    }
    @future
    public static void addOtherPermissionSets(String userIds){
        System.debug('HERE ----------------------->'+ userIds);
        DataUtil.addMiscellaneousPermissionSetToUser(userIds.split(';'));
    }
}