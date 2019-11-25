/** Test class for NewOnboardingAdminsCntr **/
@isTest
public class NewOnboardingAdminsCntr_Test {

    static testMethod void test_getUser(){
        List<User> users = NewOnboardingAdminsCntr.getUser();
        System.assert(users.size()>0);
    }
}