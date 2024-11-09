Class Trakt2Notion.TraktUser Extends %Persistent
{

Property Username As %String;

Property Reviews As list Of Trakt2Notion.TraktReviews;

Storage Default
{
<Data name="TraktUserDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Username</Value>
</Value>
<Value name="3">
<Value>Reviews</Value>
</Value>
</Data>
<DataLocation>^Trakt2Notion.TraktUserD</DataLocation>
<DefaultData>TraktUserDefaultData</DefaultData>
<IdLocation>^Trakt2Notion.TraktUserD</IdLocation>
<IndexLocation>^Trakt2Notion.TraktUserI</IndexLocation>
<StreamLocation>^Trakt2Notion.TraktUserS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
