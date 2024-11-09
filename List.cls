Class Trakt2Notion.List Extends %Persistent
{

Property ListID As %Integer;

Index ListiIDIDX On ListID [ IdKey, Unique ];

Property ListName As %String;

Property Shows As list Of Trakt2Notion.Show;

Property Movies As list Of Trakt2Notion.Movie;

Query QueryListIds() As %SQLQuery [ SqlProc ]
{
    SELECT ID
    FROM Trakt2Notion.List
}

Storage Default
{
<Data name="ListDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Shows</Value>
</Value>
<Value name="3">
<Value>Movies</Value>
</Value>
<Value name="4">
<Value>ListName</Value>
</Value>
</Data>
<DataLocation>^Trakt2Notion.ListD</DataLocation>
<DefaultData>ListDefaultData</DefaultData>
<IdLocation>^Trakt2Notion.ListD</IdLocation>
<IndexLocation>^Trakt2Notion.ListI</IndexLocation>
<StreamLocation>^Trakt2Notion.ListS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
