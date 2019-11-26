 /*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
global class TrekkrPostInstall implements InstallHandler {
    
    global void onInstall(InstallContext context) {
        List<Id> userIds = new List<Id>();
        userIds.add(context.installerID());
        DataUtil.addAdminPermissionSetToUser(userIds);
    }
}