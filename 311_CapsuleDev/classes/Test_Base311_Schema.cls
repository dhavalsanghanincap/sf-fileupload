@isTest
public class Test_Base311_Schema
{
    static testMethod void Test_Base311_Schema()
    {
        System.assert(Base311_Schema.doesFieldExist('Case','Incap311__Service_Type_Version__r.name'));
        System.assert(Base311_Schema.doesFieldExist('Case','SUbject'));
        System.assert(!Base311_Schema.doesFieldExist('Case','asdfasdf'));
    }
}