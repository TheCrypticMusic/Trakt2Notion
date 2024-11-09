Class Trakt2Notion.API Extends %RegisteredObject [ Abstract ]
{

Property APIKey As %String;

Property APISecret As %String;

ClassMethod MakeSingleRequest(HttpObj As %Net.HttpRequest) As %Status [ Abstract ]
{
}

ClassMethod Initialise() As %Net.HttpRequest [ Abstract ]
{
}

}
