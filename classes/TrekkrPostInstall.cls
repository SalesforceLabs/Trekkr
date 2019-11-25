global class TrekkrPostInstall implements InstallHandler {
    
    global void onInstall(InstallContext context) {
        List<Id> userIds = new List<Id>();
        userIds.add(context.installerID());
        DataUtil.addAdminPermissionSetToUser(userIds);
    }
}