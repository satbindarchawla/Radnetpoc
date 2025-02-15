/******************************************************************************************************************************************************
 * 
 * @Created Date      :  05/02/24
 * 
 * @description       :  This class serves to obtain the data for Search functionality in Knowledge Article LWC component
 * 
 * @JIRA Id           :  CC-331
 * */ 
public with sharing class DH_knowledgeSearchFuncController {
    public static List<List<Knowledge__kav>> trackingDetailsList;
    public static List<DH_knowledgeSearchWrapper> resultCase = new List<DH_knowledgeSearchWrapper>();
    public static Boolean isGuestUser = (System.UserInfo.getUserType() == 'Guest')?true:false;
    public static List<String> selectedCoastType = new List<String>();
    /**************************************************************************************************************************************************
     * 
     * @description this method is used to get the recently viewed published articles for the logged in User
     * 
     * @return list of recently viewed articles 
     * 
     * */
    
    @AuraEnabled
    public static List<RecentlyViewed> getRecentlyViewedKnowledgeArticles(){
        
        return [SELECT Id, Name, LastViewedDate FROM RecentlyViewed  WHERE Type =: DH_KMConstants.RECENTLY_VIEWED_TYPE WITH SECURITY_ENFORCED order by LastViewedDate desc LIMIT 5];
    }

	 /**************************************************************************************************************************************************
     * 
     * @description this method is used to get the most viewed articles from all the published knowledge Articles
     * 
     * @param selectedCoast coast selected by the user in knowledge article component in community site
     * 
     * @return list of most viewed articles by checking the ArticleTotalViewCount field which stores the view count for Articles
     * 
     * */
    @AuraEnabled (cacheable=true) 
    public static List<Knowledge__kav> getMostViewedKnowledgeArticles(String selectedCoast){ 
        List<Knowledge__kav> mostViewedArticleList = new List<Knowledge__kav>();
        try{
            selectedCoastType= DH_KMUtility.coastType(selectedCoast);
            mostViewedArticleList=DH_KMQueryManager.getMostViewedKnowledgeArticlesRecordsList(selectedCoastType,isGuestUser);
           
        }
        catch (exception e) {
            System.debug(LoggingLevel.ERROR,'Error while fetching Top 5 Knowledge Articles for DH_knowledgeSearchFuncController : ' + e.getMessage()+e.getLineNumber());
        }
       
       return mostViewedArticleList;
       
    }

     /**************************************************************************************************************************************************
     * 
     * @description this method is used to get knowledge articles for typeahead with most viewed articles on top containing the search key
     * 
     * @param trackingNumber search value entered by the user in knowledge article component
     * 
     * @param selectedCoast coast selected by the user in knowledge article component in community site
     * 
     * @return list of knowledge articles wrapper 
     * 
     * */
    
    @AuraEnabled
    public static List<DH_knowledgeSearchWrapper> getTrackingDetails(String trackingNumber,String selectedCoast){
    	try{
            if(trackingNumber.length()>0) {
                String querySearchKey = '';
                //splitting all the words in the search key by space
                List<String> wordList  = trackingNumber.split(' ', -1);
                // creating string to search for individual words in knowledge articles
                for(String word : wordList){
                    querySearchKey += ('*' + word + '* OR ');
                }
                querySearchKey = querySearchKey.removeEnd('* OR ');
                querySearchKey = querySearchKey+'*';
                
                //Fetching coast types depending on the selected coast 
                selectedCoastType= DH_KMUtility.coastType(selectedCoast);
                //Querying all the knowledge articles containing the search key based on guest user and coast selected  
                List<List<Knowledge__kav>> trackingDetailsList = DH_KMQueryManager.getTrackingDetailsRecordsList(querySearchKey,selectedCoastType,isGuestUser); 
                
                for(List<Knowledge__kav> slist : trackingDetailsList){
                    for(Knowledge__kav cList : slist){
                        //forming list of knowledge article wrapper
                        //checking if the details__c field is empty then adding the empty string else stripHtmlTags is used to remove all the html tags and add only the text
                        resultCase.add(new DH_knowledgeSearchWrapper(Id.valueOf(cList.Id), cList.Title, cList.Details__c!= null ? cList.Details__c?.stripHtmlTags().mid(0, 250) : '', cList.Details__c != null ? cList.Details__c?.stripHtmlTags() : '', cList.Details__c!= null ? cList.Details__c : '', cList.ArticleTotalViewCount));
                    } 
                  }    
            } 
        }
        catch (exception e) {
            System.debug(LoggingLevel.ERROR,'Error while fetching Knowledge Articles for DH_knowledgeSearchFuncController : ' + e.getMessage()+e.getLineNumber());
        }
        return resultCase;
    }

     /**************************************************************************************************************************************************
     * 
     * @description this method is used to get all the knowledge articles containing the search key 
     * 
     * @param  searchKey search value entered by the user in knowledge article component
     * 
     * @param selectedCoast coast selected by the user in knowledge article component in community site
     *  
     * @return list of knowledge articles wrapper 
     * 
     * */
    
    @AuraEnabled
    public static List<DH_knowledgeSearchWrapper> getAllTrackingDetails(String searchKey,String selectedCoast){
        List<DH_knowledgeSearchWrapper> knowledgeSearchWrapper = new List<DH_knowledgeSearchWrapper>();
        try {
            if(searchKey.length()>0){
                String querySearchKey = '';
                //splitting all the words in the search key by space
               for(String word : searchKey.split(' ', -1)){
                // creating string to search for individual words in knowledge articles
                   querySearchKey += ('*' + word + '* OR ');
               } 
               querySearchKey = querySearchKey.removeEnd('* OR ');
               querySearchKey = querySearchKey+'*';
             
                //Fetching coast types depending on the selected coast 
                selectedCoastType= DH_KMUtility.coastType(selectedCoast);
                //Querying all the knowledge articles containing the search key based on guest user and coast selected  
               List<List<Knowledge__kav>> trackingDetailsList = DH_KMQueryManager.getAllTrackingDetailsRecordsList(querySearchKey,selectedCoastType,isGuestUser); 
               for(List<Knowledge__kav> slist : trackingDetailsList){
                   for(Knowledge__kav cList:slist){ 
                        //forming list of knowledge article wrapper
                       //checking if the details__c field is empty then adding the empty string else stripHtmlTags is used to remove all the html tags and add only the text
                       DH_knowledgeSearchWrapper ksw = new DH_knowledgeSearchWrapper(Id.valueOf(cList.Id), cList.Title, cList.Details__c!= null ? cList.Details__c?.stripHtmlTags().mid(0, 250) : '', cList.Details__c != null ? cList.Details__c?.stripHtmlTags() : '', cList.Details__c!= null ? cList.Details__c : '', cList.ArticleTotalViewCount);
                       knowledgeSearchWrapper.add(ksw);
                   }   
               }
            }
           
        }
        catch (exception e) {
            System.debug(LoggingLevel.ERROR, 'Error while fetching knowledge Articles for DH_knowledgeSearchFuncController : ' + e.getMessage()+e.getLineNumber());
        }
        return knowledgeSearchWrapper;
    }


     /**************************************************************************************************************************************************
     * 
     * @description this method is used to get the sub categories and their respective knowledge articles containing the search key 
     * 
     * @param  searchKey search value entered by the user in knowledge article component
     * 
     * @param selectedCoast coast selected by the user in knowledge article component in community site
     *  
     * @return list of wrapper containing subcategories and corresponding Knowledge Articles 
     * 
     * */
    
    @AuraEnabled
    public static List<DH_knowledgeSearchFuncControllerWrapper> getCategoryName(String searchKey,String selectedCoast){
        List<DH_knowledgeSearchFuncControllerWrapper> kaWrapList = new List<DH_knowledgeSearchFuncControllerWrapper>();
       
        try {
            if(searchKey.length()>0)
            {
                String querySearchKey = '';
                //splitting all the words in the search key by space
			    for(String word : searchKey.split(' ', -1))
                {
                    // creating string to search for individual words in knowledge articles
				    querySearchKey += ('*' + word + '* OR ');
			    }
			    querySearchKey = querySearchKey.removeEnd('* OR ');
                querySearchKey = querySearchKey+'*';
              
                //Fetching coast types depending on the selected coast 
                selectedCoastType= DH_KMUtility.coastType(selectedCoast);
                //Querying all the knowledge articles containing the search key based on guest user and coast selected  
                List<List<Knowledge__kav>> searchKeyList = DH_KMQueryManager.getCategoryNameRecords(querySearchKey,selectedCoastType,isGuestUser);
                Set<String> searchKeyKnowledgeArticleSet = new Set<String>(); 
                for(List<Knowledge__kav> searchKeyResultList : searchKeyList)
                {
                    for(Knowledge__kav searchKeyKnowledgeArticle:searchKeyResultList)
                    { 
                        //forming list of knowledge article wrapper
                        //checking if the details__c field is empty then adding the empty string else stripHtmlTags is used to remove all the html tags and add only the text
                        DH_knowledgeSearchWrapper ksw = new DH_knowledgeSearchWrapper(Id.valueOf(searchKeyKnowledgeArticle.Id), searchKeyKnowledgeArticle.Title, searchKeyKnowledgeArticle.Details__c!= null ? searchKeyKnowledgeArticle.Details__c?.stripHtmlTags().mid(0, 250) : '', searchKeyKnowledgeArticle.Details__c != null ? searchKeyKnowledgeArticle.Details__c?.stripHtmlTags() : '', searchKeyKnowledgeArticle.Details__c!= null ? searchKeyKnowledgeArticle.Details__c : '', searchKeyKnowledgeArticle.ArticleTotalViewCount);                    
                        searchKeyKnowledgeArticleSet.add(JSON.serialize(ksw));
                    }   
                }

                List<Id> searchKeyKnowledgeArticleIds = new List<Id>();
                for(String s : searchKeyKnowledgeArticleSet)
                {
                    //deserializing the String to wrapper
                    DH_knowledgeSearchWrapper ksw = (DH_knowledgeSearchWrapper) JSON.deserialize(s, DH_knowledgeSearchWrapper.class);
                    searchKeyKnowledgeArticleIds.add(ksw.id);
                }

                List<Knowledge__DataCategorySelection> getGroupDataCategoryName = new List<Knowledge__DataCategorySelection>();
                //get sub-categories present in the queried knowledge articles
                getGroupDataCategoryName = [SELECT  id,DataCategoryName,ParentId,DataCategoryGroupName from Knowledge__DataCategorySelection WHERE ParentId IN:searchKeyKnowledgeArticleIds WITH SECURITY_ENFORCED];
                DH_knowledgeSearchController.DH_knowledgeSearchControllerWrapper searchControllerWrapper = DH_knowledgeSearchController.getCategoryList(getGroupDataCategoryName,true,selectedCoast);
                Map<String,Set<String>> catgLabelVsId = new Map<String,Set<String>>() ;
                Map<String,List<String>> subCatgLabelVsName = searchControllerWrapper.subcategLabelVsNames;
                
                

                for(String s:searchKeyKnowledgeArticleSet) 
                {
                    for(Knowledge__DataCategorySelection dataCatg :getGroupDataCategoryName) 
                    {
                        //deserializing the String to wrapper
                        DH_knowledgeSearchWrapper kav = (DH_knowledgeSearchWrapper)JSON.deserialize(s, DH_knowledgeSearchWrapper.class);
                        //checking for knowledge articles which are mapped to sub-categories
                        if(kav.id==dataCatg.ParentId)
                        {
                            //iterating over the sub-categories API vs Label map
                            for(String val : subCatgLabelVsName.keyset())
                            {   
                                //storing the api names of sub categories              
                                List<string> subCatgApiName = subCatgLabelVsName.get(val);   
                                //checking if the sub-category is present in the queried sub-categories list
                                if(subCatgApiName.contains(dataCatg.DataCategoryName)) 
                                {            
                                    //if the key does not exist then create a new key value pair for sub-categories Vs Knowledge article wrapper        
                                    if(!catgLabelVsId.containsKey(val))
                                    {
                                        catgLabelVsId.put(String.valueOf(val),new Set<String>{s});
                                    }
                                    //add the knowledge article wrapper in the existing key
                                    else 
                                    {
                                        catgLabelVsId.get(val).add(s);
                                    }
                                }
                            }
                        }
                    }
                }
		        //iterate over the map for sub-category and knowledge article wrapper
                for (String catLabel : catgLabelVsId.keySet()) 
                {
                    //get the serialized knowledge article string for its respective sub-categories
                    Set<String> knowledgeSearchSerializedSet = catgLabelVsId.get(catLabel);
                    List<DH_knowledgeSearchWrapper> knowledgeSearchDeserializedList = new List<DH_knowledgeSearchWrapper>();
                    for(String s : knowledgeSearchSerializedSet)
                    {
                        //add it to the knowledge search wrapper 
                        knowledgeSearchDeserializedList.add((DH_knowledgeSearchWrapper)JSON.deserialize(s, DH_knowledgeSearchWrapper.class));
                    }
                    //add it to the knowledge search func wrapper containing sub-categories Vs knowledge article wrapper
                    kaWrapList.add(new DH_knowledgeSearchFuncControllerWrapper(catLabel, knowledgeSearchDeserializedList));
                }
            }
        }
        catch (exception e) {
            System.debug(LoggingLevel.ERROR, 'Error while fetching categoryDetails for DH_knowledgeSearchFuncController : ' + e.getMessage()+e.getLineNumber());
        }
        
        return kaWrapList;
    }
    
   
     /**************************************************************************************************************************************************
     * 
     * @description this wrapper is used to transfer the category name and their respective knowledge article wrapper in proper manner to LWC component
     * */

     public class DH_knowledgeSearchFuncControllerWrapper{
        @AuraEnabled public String catgName{get;set;}
        @AuraEnabled public List<DH_knowledgeSearchWrapper> knowledgeSearchWrapper{get;set;}
         
        /**************************************************************************************************************************************************
         * 
         * @description : DH_knowledgeSearchFuncControllerWrapper constructor 
         *  
         * @param catgName String of category names
         * 
         * @param knowledgeSearchWrapper list of knowledge search wrapper
         * 
         * */
        public DH_knowledgeSearchFuncControllerWrapper( String catgName,List<DH_knowledgeSearchWrapper> knowledgeSearchWrapper){
            this.catgName = catgName;
            this.knowledgeSearchWrapper = knowledgeSearchWrapper;
        }
    }

          
     /**************************************************************************************************************************************************
     * 
     * @description this wrapper is used to transfer the knowledge Article data in proper manner to LWC component 
     * */

    public class DH_knowledgeSearchWrapper{
        @AuraEnabled public String id{get;set;}
        @AuraEnabled public String title{get;set;}
        @AuraEnabled public String detailsTrimmed{get;set;}
        @AuraEnabled public String strippedDetails{get;set;}
        @AuraEnabled public String richTextDetails{get;set;}
        @AuraEnabled public Integer totalViewCount{get;set;}
        
             
        /**************************************************************************************************************************************************
         * 
         * @description : DH_knowledgeSearchFuncControllerWrapper constructor 
         *  
         * @param id  knowledge article Id
         * 
         * @param title title of knowledge article 
         * 
         * @param detailsTrimmed knowledge article details which are trimmed
         * 
         * @param strippedDetails knowledge article details without the html tags
         * 
         * @param richTextDetails knowledge article details in rich text format
         * 
         * @param totalViewCount stores view count of each knowledge article
         * 
         * */
        public DH_knowledgeSearchWrapper(String id, String title, String detailsTrimmed, String strippedDetails, String richTextDetails, Integer totalViewCount){
            this.id = id;
            this.title = title;
            this.detailsTrimmed = detailsTrimmed;
            this.strippedDetails = strippedDetails;
            this.richTextDetails = richTextDetails;
            this.totalViewCount = totalViewCount;
        }
    }
}