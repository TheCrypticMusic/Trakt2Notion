Class Trakt2Notion.Media Extends %Persistent [ Abstract ]
{

Property Title As %String(MAXLEN = "");

Property Year As %Integer;

Property TraktID As %String;

Property Slug As %String(MAXLEN = "");

Property IMDBID As %String;

Property TMDBID As %String;

Index TraktIDX On TraktID [ IdKey, Unique ];

Storage Default
{
<Data name="MediaDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Title</Value>
</Value>
<Value name="3">
<Value>Year</Value>
</Value>
<Value name="4">
<Value>Slug</Value>
</Value>
<Value name="5">
<Value>IMDBID</Value>
</Value>
<Value name="6">
<Value>TMDBID</Value>
</Value>
</Data>
<DataLocation>^Trakt2Notion.MediaD</DataLocation>
<DefaultData>MediaDefaultData</DefaultData>
<IdLocation>^Trakt2Notion.MediaD</IdLocation>
<IndexLocation>^Trakt2Notion.MediaI</IndexLocation>
<StreamLocation>^Trakt2Notion.MediaS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
