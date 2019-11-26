 /*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 *
 * Test class for Mentee Bib Comp Controller
 */
@isTest
public with sharing class MenteeBibCompCntr_Test {
    
    static testMethod void validateAllFunctions() {
        User lMenteeUser = TestDataUtil.getUser();
        User lMentorUser = TestDataUtil.getUser();
        insert lMentorUser;
        lMenteeUser.Mentor__c = lMentorUser.Id;
        insert lMenteeUser;
        DataUtil.addMenteePermissionSetToUser(lMenteeUser.Id);
        System.runAs(lMenteeUser){
            User returnUser = MenteeBibCompCntr.getMentorDetails();
            System.assertEquals(lMentorUser.Id, returnUser.Mentor__c);
			MenteeBibCompCntr.updateVisionAndValues('Test values', 'Test Vision', lMenteeUser.Id);
            User retrieveUser = [SELECT Id, Vision__c,Values__c FROM User WHERE Id = :lMenteeUser.Id];
            System.assertEquals('Test values', retrieveUser.Values__c);
            System.assertEquals('Test Vision', retrieveUser.Vision__c);
        }
    }
    
}