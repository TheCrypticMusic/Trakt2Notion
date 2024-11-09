Class Trakt2Notion.NotionAPI Extends %RegisteredObject
{

Property APISecret As %String [ InitialExpression = {^ENV("API","NOTION","SECRET")} ];

Property APIBaseURL As %String [ InitialExpression = {^ENV("API","NOTION","BASEURL")} ];

Property HttpRequest As %Net.HttpRequest [ Private ];

Method %OnNew() As %Status
{



    Set ..HttpRequest = ##class(%Net.HttpRequest).%New()
    Set ..HttpRequest.SSLConfiguration="ISC.FeatureTracker.SSL.Config"
    Set ..HttpRequest.Https=1
    Do ..HttpRequest.SetHeader("Content-Type", "application/json")
    Do ..HttpRequest.SetHeader("Notion-Version", "2022-06-28")
    Set ..HttpRequest.Authorization = "Bearer "_..APISecret
    Quit $$$OK
}

ClassMethod MakeSingleRequest(URL As %String, HttpRequest As %Net.HttpRequest, TypeOfRequest As %String, DataObj As %DynamicObject = "") As %DynamicObject
{
    Set jsonObject = ##class(%Library.DynamicObject).%New()
    Try {
        If (TypeOfRequest="Patch")||(TypeOfRequest="Post")
        {
     
            Do DataObj.%ToJSON(HttpRequest.EntityBody)
        }
        Set status=$METHOD(HttpRequest, TypeOfRequest, URL)
      
        Set jsonString=HttpRequest.HttpResponse.Data.Read(HttpRequest.HttpResponse.Data.Size,.sc)
        zw jsonString
        Set jsonObject={}.%FromJSON(jsonString)
      
    } Catch {
        Set jsonObject.Err="Service Unavailable"
    }
  
    Quit jsonObject
}

Method GetSingleDatabase(DBId As %String) As %DynamicObject
{

    Set URL=..APIBaseURL_"databases/"_DBId

    
    Set userdatabase = ##class(Trakt2Notion.NotionAPI).MakeSingleRequest(URL, ..HttpRequest, "Get")

    Quit userdatabase
}

Method GetSinglePage(PageID As %String) As %DynamicObject
{

    Set URL=..APIBaseURL_"v1/pages/"_PageID

    
    Set userdatabase = ##class(Trakt2Notion.NotionAPI).MakeSingleRequest(URL, ..HttpRequest, "Get")
    Quit userdatabase
}

Method UpdateSinglePage(PageID As %String, PatchObj As %DynamicObject)
{
    Set URL=..APIBaseURL_"v1/pages/"_PageID

    Set userdatabase = ##class(Trakt2Notion.NotionAPI).MakeSingleRequest(URL, ..HttpRequest, "Patch", PatchObj)

    Quit userdatabase
}

Method QueryDatabase(DBId As %String, DataObj As %DynamicObject) As %DynamicObject
{
   

    Set URL=..APIBaseURL_"v1/databases/"_DBId_"/query"
    Set userdatabase = ##class(Trakt2Notion.NotionAPI).MakeSingleRequest(URL, ..HttpRequest, "Post", DataObj)
    Quit userdatabase
}

Method InitaliseHTTPRequest()
{
    Set ..HttpRequest = ##class(%Net.HttpRequest).%New()
    Set ..HttpRequest.SSLConfiguration="ISC.FeatureTracker.SSL.Config"
    Set ..HttpRequest.Https=1
    Do ..HttpRequest.SetHeader("Content-Type", "application/json") 
    Do ..HttpRequest.SetHeader("Notion-Version", "2022-06-28")
    Set ..HttpRequest.Authorization = "Bearer "_..APISecret
}

Method DatabaseToArray(DynObj As %DynamicObject, ByRef tArr)
{
    Set iter=DynObj.results.%GetIterator()

    
    While iter.%GetNext(.key, .value, .type ) 
    {
        
        Set tArr(value.properties.TraktID."rich_text".%Get(0).text.content,"PAGE ID")=value.id
        Set tArr(value.properties.TraktID."rich_text".%Get(0).text.content,"RATING")=value.properties.Rating.number 
    }
}

Method SaveToNotion()
{
    Do ..InitaliseHTTPRequest()
    Set tArr=""
    Set userdatabase=..QueryDatabase(,{})
    Do ..DatabaseToArray(userdatabase, .tArr)
    Do ..InitaliseHTTPRequest()
    While userdatabase."has_more" 
    {
        Set userdatabase=..QueryDatabase(,{"start_cursor": (userdatabase."next_cursor")})
        Do ..DatabaseToArray(userdatabase, .tArr)
        Do ..InitaliseHTTPRequest()
    }
    
    
    Set rs=##class(%ResultSet).%New()
  	Set rs.ClassName="Trakt2Notion.List"
  	Set rs.QueryName="QueryListIds"

  	Set sc=rs.Execute()  If $$$ISERR(sc) Do DisplayError^%apiOBJ(sc) Quit

  	While rs.%Next() 
    { 

        Set list=##class(Trakt2Notion.List).%OpenId(rs.%Get("ID"))
        For show=1:1:list.Shows.Count() 
        {   
          
            Set data={}
            Set databaseID = "***"
            Set URL = "https://api.notion.com/v1/pages"
            Set data={"parent": {"database_id": (databaseID)}}
     
            Set listShowObj=list.Shows.GetAt(show)
            Set TITLE=listShowObj.Title
            Set YEAR=listShowObj.Year
            Set TRAKTID=listShowObj.TraktID
            Set IMDBID=listShowObj.IMDBID
            Set TMDBID=listShowObj.TMDBID

            Set RATING=0
            Set reviewObj=##class(Trakt2Notion.TraktReviews).%OpenId(TRAKTID)
            If $ISOBJECT(reviewObj)
            {
                Set RATING=reviewObj.Rating
            }


            Do ..InitaliseHTTPRequest()
            
            

            If $DATA(tArr(TRAKTID)) 
            {
            
                If RATING'=tArr(TRAKTID,"RATING") 
                {
                    Do ..UpdateSinglePage(tArr(TRAKTID,"PAGE ID"), {"properties": {"Rating": {"number": (RATING)}}})
                }
                Write TITLE_" already exists in database",!
            } Else {
                Write TITLE_"New Record",!
                Set data.properties={"Title": {"title": [{"text": {"content": (TITLE)}}]},"TraktID": {"rich_text": [{"type": "text", "text": {"content": (TRAKTID)}}]},"IMDBDB": {"rich_text": [{"type": "text", "text": {"content": (IMDBID)}}]},"Rating": {"number": (RATING)},"Type": {"rich_text": [{"type": "text", "text": {"content": "Show"}}]},"Release Date": {"number": (YEAR)},"List": {"rich_text": [{"type": "text", "text": {"content": (list.ListName)}}]}}

                Set userdatabase = ##class(Trakt2Notion.NotionAPI).MakeSingleRequest(URL, ..HttpRequest, "Post", data)
            
              
            }
        }
        For movie=1:1:list.Movies.Count()
        {

            Set data={}
            Set databaseID = "***"
            Set URL = "https://api.notion.com/v1/pages"
            Set data={"parent": {"database_id": (databaseID)}}
     
            Set listShowObj=list.Movies.GetAt(movie)

            Set TITLE=listShowObj.Title
            Set YEAR=listShowObj.Year
            Set TRAKTID=listShowObj.TraktID
            Set IMDBID=listShowObj.IMDBID
            Set TMDBID=listShowObj.TMDBID
            Set RATING=0
            Set reviewObj=##class(Trakt2Notion.TraktReviews).%OpenId(TRAKTID)
            If $ISOBJECT(reviewObj)
            {
                Set RATING=reviewObj.Rating
            }
            Do ..InitaliseHTTPRequest()
   
            If $DATA(tArr(TRAKTID)) 
            {
                If RATING'=tArr(TRAKTID,"RATING") 
                {
                    Do ..UpdateSinglePage(tArr(TRAKTID,"PAGE ID"), {"properties": {"Rating": {"number": (RATING)}}})
                }
                Write TITLE_" already exists in database",!
            
            } Else {
                Write TITLE_"New Record",!

                Set data.properties={"Title": {"title": [{"text": {"content": (TITLE)}}]},"TraktID": {"rich_text": [{"type": "text", "text": {"content": (TRAKTID)}}]},"IMDBDB": {"rich_text": [{"type": "text", "text": {"content": (IMDBID)}}]},"Rating": {"number": (RATING)},"Type": {"rich_text": [{"type": "text", "text": {"content": "Movie"}}]},"Release Date": {"number": (YEAR)},"List": {"rich_text": [{"type": "text", "text": {"content": (list.ListName)}}]}}
                Set userdatabase = ##class(Trakt2Notion.NotionAPI).MakeSingleRequest(URL, ..HttpRequest, "Post", data)
            }

        }   

    }
}

Method UpdateNotionDatabase()
{
    Set databaseID = "***"
    Set url = "https://api.notion.com/v1/databases/"_databaseID_"/query"
   
    Set httpRequest = ##class(%Net.HttpRequest).%New()
    Set httpRequest.Https = 1 
    Set httpRequest.Server = "api.notion.com"
    Set httpRequest.SSLConfiguration = "ISC.FeatureTracker.SSL.Config"

    Set httpRequest.Authorization = "Bearer "_..APISecret
    Do httpRequest.SetHeader("Content-Type", "application/json")
    Do httpRequest.SetHeader("Notion-Version", "2022-06-28")

    Set status = httpRequest.Post(url)
    
    If $$$ISERR(status) {
        Write "Request failed with status: ", status, !
        Quit
    }

    Set responseData = httpRequest.HttpResponse.Data.Read()
    Write "Response Data: ", responseData, !
}

}
