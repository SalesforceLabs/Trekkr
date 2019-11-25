/**
* Controller for AddFirstAidResponse Lightning component
**/ 
public with sharing class AddFirstAidResponseCntr {
    
    /** Retrieves First Aid Response for a given FirstAid Id **/ 
    @AuraEnabled
    public static String getFirstAidResponse(String firstAidId){
        List<String> fieldNames_FA = new List<String>();
        fieldNames_FA.add('Response__c');
        if(FLSCheck.isAccessible(fieldNames_FA,'First_Aid__c')){
            return [SELECT Id,Response__c FROM First_Aid__c WHERE ID = :firstAidId][0].Response__c;
        }
        return '';
    }
    
    /** Updates Response of given FirstAid Id **/ 
    @AuraEnabled
    public static void saveFirstAidResponse(String firstAidId,String response){
        List<String> fieldNames_FA = new List<String>();
        fieldNames_FA.add('Response__c');
        if(FLSCheck.isUpdateable(fieldNames_FA,'First_Aid__c')){
            update new First_Aid__c(Id = firstAidId,Response__c = response);
        }
    }
}