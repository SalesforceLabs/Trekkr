 /*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 *
 * Test class for NewOnboardingAdminsCntr *
 */
@isTest
public class NewOnboardingAdminsCntr_Test {

    static testMethod void test_getUser(){
        List<User> users = NewOnboardingAdminsCntr.getUser();
        System.assert(users.size()>0);
    }
}