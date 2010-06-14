<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Date        :	May 8, 2009
Description :
	The ColdBox Mail Service used to send emails in an oo fashion


----------------------------------------------------------------------->
<cfcomponent output="false" hint="The ColdBox Mail Service used to send emails in an oo fashion" extends="coldbox.system.core.mail.MailService">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" output="false" returntype="MailService" hint="Constructor">
		<cfscript>
			var args = {};
			
			// Plugin Properties
			setPluginName("MailService");
			setPluginDescription("This is a mail service used to send mails in an OO fashion");
			setPluginVersion("1.0");
			setPluginAuthor("Luis Majano");
			setPluginAuthorURL("http://www.coldbox.org");
			
			// Setting Override
			if( settingExists("mailservice_tokenMarker") ){
				args.tokenMarker = getSetting("mailservice_tokenMarker"); 
			}
			// Mail Settings
			args.mailSettings = getMailSettings();
			
			super.init(argumentCollection=args);
			
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<cffunction name="send" access="public" returntype="struct" output="false" hint="Send an email payload. Returns a struct: [error:boolean,errorArray:array]">
		<cfargument name="mail" required="true" type="coldbox.system.core.mail.Mail" hint="The mail payload to send." />
		<cfscript>
			// Proxy in the send call and monitor it.
			var results = super.send(argumentCollection=arguments);
			
			if( results.error ){
				// Log it
				log.error("Error sending mail: #arrayToList(results.errorArray)#",arguments.mail.getMemento());
			}
			
			return results;
		</cfscript>
	</cffunction>

</cfcomponent>