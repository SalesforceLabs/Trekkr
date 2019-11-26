 /*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 *
 * Controller for Onboarding_Tabs component to Raise A Concern
 */
public with sharing class RaiseAConcernCntr {
    
    /**
*  This funtion saves the concerns raise by mentor, mentee or manager

    @AuraEnabled
    public static Boolean saveConcernDetails(Concern__c concern){
        try{
            List<String> fieldNames = new List<String>();
            fieldNames.add('Concern_Description__c');
            fieldNames.add('Submit_To__c');
            if(FLSCheck.isCreateable(fieldNames,'Concern__c')){
                insert concern;
                return true;
            }
            return false;            
        }catch(Exception e){
            return false;
        }
    }**/
}