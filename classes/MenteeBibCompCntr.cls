 /*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
public with sharing class MenteeBibCompCntr {
    
    /**
*  Aura function to get Mentor details of the logged in Mentee
**/ 
    @AuraEnabled
    public static User getMentorDetails(){
        List<User> users = [SELECT Id,FirstName,LastName,FullPhotoUrl,Mentor__c,Mentor__r.FirstName,Mentor__r.LastName,
                            Mentor__r.FullPhotoUrl ,Mentor__r.MobilePhone,Mentor__r.Email,
                            Energizers__c,Medals__c,Vision__c,Values__c,
                            (SELECT Id,User_Role__r.Name FROM User_User_Role_Junctions__r)
                            FROM User WHERE Id = : UserInfo.getUserId() LIMIT 1];
        for(User lUser : users){
            return lUser;
        }
        return null;
    }
    
    /** Aura function to update vision and value of Mentee user **/
    @AuraEnabled
    public static Boolean updateVisionAndValues(String values, String vision,String userId){
        try{
            update new User(Id = userId, Vision__c = vision, Values__c = values);
            return true;
        }catch(Exception e){
            return false;
        }
    }
    
}