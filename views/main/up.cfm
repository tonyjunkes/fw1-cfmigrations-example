<cfparam name="rc.message" type="string" default="">

<cfoutput>
    <h1>#rc.message#</h1>
    <div><a href="/">Back</a></div>
</cfoutput>

<cfquery name="test">
    SELECT * FROM users
</cfquery>
<cfdump var="#test#">