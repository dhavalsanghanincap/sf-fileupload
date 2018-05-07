/**
* @author 
* @date 
* @group 
* @group-content
* @description 
*/
public class Base311_Service_Knowledge {

    private static final String ONLINE_STATUS = 'Online';
    
    /**
    * @description 
    * @param 
    * @param 
    * @return 
    * @example
    */
    public List<KnowledgeArticleVersion> searchArticles(String terms) {
        String lang = UserInfo.getLanguage();
        
        String findTerms = String.join(Base311_Helper.csvToList(terms), ' OR ');
        
        String searchString = 'FIND :findTerms ' +
            'IN ALL FIELDS ' +
            'RETURNING KnowledgeArticleVersion ' +
            '(Id, ArticleNumber, Title, LastPublishedDate, UrlName, Summary ' +
            'WHERE PublishStatus = :ONLINE_STATUS ' +
            'AND Language = :lang)';
        
        System.debug(String.escapeSingleQuotes(searchString));
        
        List<List<sObject>> searchList = Search.query(String.escapeSingleQuotes(searchString));
        
        List<SObject> results = new List<SObject>();
        
        for(List<Sobject> items : searchList) {
            results.addAll(items);
        }
        
        return (List<KnowledgeArticleVersion>) results;
    }
    
}