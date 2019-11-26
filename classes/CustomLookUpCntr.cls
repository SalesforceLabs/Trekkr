 /*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 *
 *  Controller for Custom lookup component
 *  Author : Installed package
 */
public with sharing class CustomLookUpCntr {
    
    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName, String fieldName,String whereClause,String SuffixobjectFieldName) {
        List<String> fieldsList = new List<String>();
        fieldsList.add(fieldName);
        List < sObject > returnList = new List < sObject > ();
        if(FLSCheck.isAccessible(fieldsList,ObjectName)){
            String searchKey = searchKeyWord + '%';
            String sQuery =  'select id, ' + fieldName +(SuffixobjectFieldName == '' ? '': ','+SuffixobjectFieldName) +' from ' +ObjectName + ' where ' + fieldName + ' LIKE: searchKey '+(whereClause != '' ? 'AND '+whereClause :'')+' order by createdDate DESC limit 5';
            List < sObject > lstOfRecords = Database.query(sQuery);
            for (sObject obj: lstOfRecords) {
                returnList.add(obj);
            }
        }
        return returnList;
    }
    
    @AuraEnabled
    public static sObject getMySingleObject(String objectName, String fieldName, String recordId,String SuffixobjectFieldName) {
        List<String> fieldsList = new List<String>();
        fieldsList.add(fieldName);
        if(FLSCheck.isAccessible(fieldsList,objectName)){
            String sQuery =  'select Id, ' + fieldName + (SuffixobjectFieldName == '' ? '': ','+SuffixobjectFieldName)+' from ' +ObjectName + ' where id =\'' + recordId + '\' limit 1';
            sObject returnValue = Database.query(sQuery);
            return returnValue;
        }
        return null;
    }
}