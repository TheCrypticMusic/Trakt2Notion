Class Trakt2Notion.TraktReviews Extends %Persistent
{

Property TraktID As %String;

Index TraktIDX On TraktID [ IdKey, Unique ];

Property Movie As Trakt2Notion.Movie;

Property Show As Trakt2Notion.Show;

Property Rating As %Integer;

Property RatedAt As %String;

Storage Default
{
<Data name="TraktReviewsDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Movie</Value>
</Value>
<Value name="3">
<Value>Show</Value>
</Value>
<Value name="4">
<Value>Rating</Value>
</Value>
<Value name="5">
<Value>RatedAt</Value>
</Value>
</Data>
<DataLocation>^Trakt2Notion.TraktReviewsD</DataLocation>
<DefaultData>TraktReviewsDefaultData</DefaultData>
<IdLocation>^Trakt2Notion.TraktReviewsD</IdLocation>
<IndexLocation>^Trakt2Notion.TraktReviewsI</IndexLocation>
<StreamLocation>^Trakt2Notion.TraktReviewsS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
