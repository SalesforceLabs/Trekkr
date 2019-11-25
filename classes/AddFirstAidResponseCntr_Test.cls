/**
 * Test class for AddFirstAidResponseCntr
 **/ 
@isTest
public with sharing class AddFirstAidResponseCntr_Test {

    static testMethod void validate_getFirstAidResponse(){
        First_Aid__c firstAid = TestDataUtil.getFirstAid();
        insert firstAid;
        String firstAidResponse = AddFirstAidResponseCntr.getFirstAidResponse(firstAid.Id);
        System.assertEquals(firstAidResponse,'Test Response');
    }
    
    static testMethod void validate_saveFirstAidResponse(){
        First_Aid__c firstAid = TestDataUtil.getFirstAid();
        insert firstAid;
        AddFirstAidResponseCntr.saveFirstAidResponse(firstAid.Id,'Update First Aid Response');
        List<First_Aid__c> firstAids = [SELECT Id,Response__c FROM First_Aid__c WHERE Id = :firstAid.Id];
        System.assertEquals(firstAids.get(0).Response__c,'Update First Aid Response');
    }
    
}