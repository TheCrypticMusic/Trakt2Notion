Class Trakt2Notion.TraktAPI Extends %RegisteredObject
{

Property APIKey As %String [ InitialExpression = {^ENV("API","TRAKT","ID")} ];

Property APISecret As %String [ InitialExpression = {^ENV("API","TRAKT","SECRET")} ];

Property APIUsername As %String [ InitialExpression = {^ENV("API","TRAKT","USERNAME")} ];

Property APIBaseURL As %String [ InitialExpression = {^ENV("API","TRAKT","BASEURL")} ];

Property OAuthRedirect As %String [ InitialExpression = {^ENV("API","TRAKT","OAUTH","REDIRECT")} ];

Property HttpRequest As %Net.HttpRequest [ Private ];

Method %OnNew() As %Status
{

    Set ..HttpRequest = ##class(%Net.HttpRequest).%New()
    Set ..HttpRequest.SSLConfiguration="ISC.FeatureTracker.SSL.Config"
    Set ..HttpRequest.Https=1
    Do ..HttpRequest.SetHeader("Content-Type","application/json")
    Do ..HttpRequest.SetHeader("trakt-api-version", "2")
    Do ..HttpRequest.SetHeader("trakt-api-key", ..APIKey)
    
    Quit $$$OK
}

Method InitaliseHTTPRequest()
{
    Set ..HttpRequest = ##class(%Net.HttpRequest).%New()
    Set ..HttpRequest.SSLConfiguration="ISC.FeatureTracker.SSL.Config"
    Set ..HttpRequest.Https=1
    Do ..HttpRequest.SetHeader("Content-Type","application/json")
    Do ..HttpRequest.SetHeader("trakt-api-version", "2")
    Do ..HttpRequest.SetHeader("trakt-api-key", ..APIKey)
}

Method GetAPIKey() As %String
{
    Quit ..APIKey
}

ClassMethod MakeSingleRequest(URL As %String, HttpRequest As %Net.HttpRequest, TypeOfRequest As %String = "Get", DataObj As %DynamicObject = "") As %DynamicObject
{
    Set jsonObject = ##class(%Library.DynamicObject).%New()
    Try {
        W TypeOfRequest,!
        If (TypeOfRequest="Patch")||(TypeOfRequest="Post")
        {
     
            Do DataObj.%ToJSON(HttpRequest.EntityBody)
        }
        W URL,!
        Set status=$METHOD(HttpRequest, TypeOfRequest, URL)
        Set jsonString=HttpRequest.HttpResponse.Data.Read(HttpRequest.HttpResponse.Data.Size,.sc)
        w HttpRequest.HttpResponse.StatusCode,!
        Set jsonObject={}.%FromJSON(jsonString)
      
    } Catch {
        Set jsonObject.Err="Service Unavailable"
    }
   // zw jsonObject
    Quit jsonObject
}

// State which records you want to fetch. Options include:

// Ratings

// Watchlist

Method GetSingleUserRecord(UserRecord As %String) As %DynamicObject
{

    Set URL=..APIBaseURL_"users/"_..APIUsername_"/"_UserRecord
    Set userrecord = ##class(Trakt2Notion.TraktAPI).MakeSingleRequest(URL, ..HttpRequest)
    Quit userrecord
}

Method GetSingleUserListRecord(UserListRecord As %String) As %DynamicObject
{

    Set URL=..APIBaseURL_"users/"_..APIUsername_"/lists/"_UserListRecord_"/items/"
    Set userrecord = ##class(Trakt2Notion.TraktAPI).MakeSingleRequest(URL, ..HttpRequest)
    Quit userrecord
}

Method UpdateUserList(UserListRecord As %String, UpdateObj As %DynamicObject) As %DynamicObject
{
    do ..InitaliseHTTPRequest()
    Do ..HttpRequest.SetHeader("Authorization", "Bearer "_^ENV("API","TRAKT","ACCESS TOKEN"))
    Set URL=..APIBaseURL_"users/"_..APIUsername_"/lists/"_UserListRecord_"/items/"
    
    Set userrecord = ##class(Trakt2Notion.TraktAPI).MakeSingleRequest(URL, ..HttpRequest, "Post", UpdateObj)
    
    Quit userrecord
}

Method AuthoriseApplication()
{
    // https://api.trakt.tv/oauth/authorize?response_type=code&client_id=9b36d8c0db59eff5038aea7a417d73e69aea75b41aac771816d2ef1b3109cc2f&redirect_uri=urn:ietf:wg:oauth:2.0:oob

    
    Set URL=..APIBaseURL_"oauth/device/code"
    Set res=##class(Trakt2Notion.TraktAPI).MakeSingleRequest(URL, ..HttpRequest, "Post", {"client_id": (..APIKey)})
    Set URL=..APIBaseURL_"oauth/device/token"

    Set counter=0
    For {
        Do ..InitaliseHTTPRequest()
        If counter=600 Quit
        HANG 5
        Set newres=##class(Trakt2Notion.TraktAPI).MakeSingleRequest(URL, ..HttpRequest, "Post", {"code": (res."device_code"), "client_id": (..APIKey), "client_secret": (..APISecret), "expires_in": (res."expires_in"), "interval": (res."interval")})
        zw newres
        Set counter=counter+5
    }
    Quit
}

ClassMethod OpenMedia(TypeOfMedia As %String, TraktId As %String) As Trakt2Notion.Media
{
    Set media=$S(TypeOfMedia="show": ##class(Trakt2Notion.Show).%OpenId(TraktId),1: ##class(Trakt2Notion.Movie).%OpenId(TraktId))
    Quit media
}

ClassMethod NewMedia(TypeOfMedia As %String, Title As %String, Year As %String, TraktID As %String, Slug As %String, IMDBID As %String, TMDBID As %String) As Trakt2Notion.Media
{
    Set media=$S(TypeOfMedia="show": ##class(Trakt2Notion.Show).%New(),1: ##class(Trakt2Notion.Movie).%New())
    Set media.Type=TypeOfMedia
    Set media.Title=Title
    Set media.Year=Year
    Set media.TraktID=TraktID
    Set media.Slug=Slug
    Set media.IMDBID=IMDBID
    Set media.TMDBID=TMDBID
    Quit media
}

Method SaveToDB(DynObj As %DynamicObject, RecordName As %String, ListObj As %DynamicObject = "") As %Status
{
    If RecordName'="Rating" {
        Set list=##class(Trakt2Notion.List).%OpenId(ListObj.ID)
        
        If '$IsObject(list) 
        {
            Set list=##class(Trakt2Notion.List).%New()
            Set list.ListID=ListObj.ID
                
            Set list.ListName=ListObj.Name

        }
    }
    Set iter = DynObj.%GetIterator()
    While iter.%GetNext(.key, .value, .type ) 
    {
        Set TYPE=value."type"
        Set TRAKTID=value.%Get(TYPE).%Get("ids").trakt
        Set TITLE=value.%Get(TYPE).title
        Set YEAR=value.%Get(TYPE).year
        Set TRAKTID=value.%Get(TYPE).%Get("ids").trakt
        Set SLUG=value.%Get(TYPE).%Get("ids").slug
        Set IMDB=value.%Get(TYPE).%Get("ids").imdb
        Set TMDB=value.%Get(TYPE).%Get("ids").tmdb
        If (TYPE="episode")||(TYPE="season") Continue
        Set media=##class(Trakt2Notion.TraktAPI).OpenMedia(TYPE, TRAKTID)
        If '$ISOBJECT(media) 
        {
            Set media=##class(Trakt2Notion.TraktAPI).NewMedia(TYPE,TITLE,YEAR,TRAKTID,SLUG,IMDB,TMDB) 
        }
        Set sc=media.%Save()

        Set TTYPE=$ZCVT(TYPE, "W")
        If RecordName="Rating" 
        {
            Set RATEDDATE=value."rated_at"
            Set RATING=value."rating"
         
            Set rating=##class(Trakt2Notion.TraktReviews).%OpenId(TRAKTID)
            If '$ISOBJECT(rating) {
                W "CREATING NEW RATING RECORD FOR "_TITLE,!
                Set rating=##class(Trakt2Notion.TraktReviews).%New()
                Set rating.TraktID=TRAKTID
            
                
                Set $PROPERTY(rating,TTYPE)=media
                
            }
            Set rating.Rating=RATING
            Set rating.RatedAt=RATEDDATE
            Set rsc=rating.%Save()
            
        }
        Else 
        {
        
            Set media=##class(Trakt2Notion.TraktAPI).OpenMedia(TYPE, TRAKTID)
    
            If '$PROPERTY(list, TTYPE_"s").FindOref(media)>0 {
                Write "INSERTING NEW MEDIA RECORD FOR "_TITLE,!
                Set sc=$PROPERTY(list, TTYPE_"s").InsertObject(media.%Oid())
            }   

            do list.%Save()

   
        }
    }
    Quit $$$OK
}

}
