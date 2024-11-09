Class Trakt2Notion.Movie Extends Trakt2Notion.Media
{

Property Type As %String;

Storage Default
{
<Data name="MovieDefaultData">
<Subscript>"Movie"</Subscript>
<Value name="1">
<Value>Type</Value>
</Value>
</Data>
<DefaultData>MovieDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
