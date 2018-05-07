/*
 * Block comments with details of changes
 */
public class Console311_Page_Layout
{
    public Map<String,Console_311_Layout_Setting__mdt> sectionMap { get; set; }//Section MasterLabel
    public Map<String,Map<String,X311_Page_Field__mdt>> fieldMap { get; set; }//Section MasterLabel then Field MasterLabel

    public Console311_Page_Layout(String MasterLabel)
    {
        sectionMap = new Map<String,Console_311_Layout_Setting__mdt>();//Section MasterLabel
        fieldMap = new  Map<String,Map<String,X311_Page_Field__mdt>>();
        list<Console_311_Layout_Setting__mdt> sections = [SELECT Id,MasterLabel,Title__c,Visible__c,  (select MasterLabel,Read_Only__c,Visible__c from X311_Page_Fields__r ) FROM Console_311_Layout_Setting__mdt where x311_Page_Layout__r.MasterLabel = :MasterLabel];
        for(Console_311_Layout_Setting__mdt section : sections){
            sectionMap.put(section.MasterLabel, section);
            fieldMap.put(section.MasterLabel, new Map<String,X311_Page_Field__mdt>());
            for(X311_Page_Field__mdt field: section.X311_Page_Fields__r){
                fieldMap.get(section.MasterLabel).put(field.MasterLabel,field);
            }
        }
    }

}