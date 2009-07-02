<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	04/12/2009
Description :
	A simple Scope Logger that logs to a specified scope.
	
Properties:
- scope : the scope to persist to, defaults to request
- key   : the key to use in the scope, it defaults to the name of the logger
- limit : a limit to the amount of logs to rotate. Defaults to 0, unlimited
----------------------------------------------------------------------->
<cfcomponent name="ScopeLogger" 
			 extends="coldbox.system.logging.AbstractLogger" 
			 output="false"
			 hint="A simple CF Logger">
	
	<!--- Init --->
	<cffunction name="init" access="public" returntype="ScopeLogger" hint="Constructor" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="name" 		type="string"  required="true" hint="The unique name for this logger."/>
		<cfargument name="level" 		type="numeric" required="false" default="-1" hint="The default log level for this logger. If not passed, then it will use the highest logging level available."/>
		<cfargument name="properties" 	type="struct"  required="false" default="#structnew()#" hint="A map of configuration properties for the logger"/>
		<!--- ************************************************************* --->
		<cfscript>
			// Init supertype
			super.init(argumentCollection=arguments);
			
			// Verify properties
			if( NOT propertyExists('scope') ){
				setProperty("scope","request");
			}
			if( NOT propertyExists('key') ){
				setProperty("key",getName());
			}
			if( NOT propertyExists('limit') OR NOT isNumeric(getProperty("limit"))){
				setProperty("limit",0);
			}
			
			// Scope storage
			instance.scopeStorage = createObject("component","coldbox.system.util.collections.ScopeStorage").init();
			// Scope Checks
			instance.scopeStorage.scopeCheck(getproperty('scope'));
						
			return this;
		</cfscript>
	</cffunction>	
	
	<!--- Log Message --->
	<cffunction name="logMessage" access="public" output="true" returntype="void" hint="Write an entry into the logger.">
		<!--- ************************************************************* --->
		<cfargument name="message" 	 type="string"   required="true"   hint="The message to log.">
		<cfargument name="severity"  type="numeric"  required="true"   hint="The severity level to log.">
		<cfargument name="extraInfo" type="any"      required="no" default="" hint="Extra information to send to the loggers.">
		<!--- ************************************************************* --->
		<cfscript>
			var logStack = "";
			var entry = structnew();
			var limit = getProperty('limit');
			
			// Verify storage
			ensureStorage();
			
			// Check Limits
			logStack = getStorage();
			
			if( limit GT 0 and arrayLen(logStack) GTE limit ){
				// pop one out, the oldest
				arrayDeleteAt(logStack,1);
			}
			
			// Log Away
			entry.id = createUUID();
			entry.logDate = now();
			entry.loggerName = getName();
			entry.severity = this.logLevels.lookup(arguments.severity);
			entry.message = arguments.message;
			entry.extraInfo = arguments.extraInfo.toString();
			
			// Save Storage
			arrayAppend(logStack, entry);
			saveStorage(logStack);		
		</cfscript>	   
	</cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------>

	<!--- getStorage --->
	<cffunction name="getStorage" output="false" access="private" returntype="any" hint="Get the storage">
		<cflock name="#getname()#.scopeoperation" type="exclusive" timeout="20" throwOnTimeout="true">
			<cfreturn instance.scopeStorage.get(getProperty('key'), getProperty('scope'))>
		</cflock>
	</cffunction>
	
	<!--- saveStorage --->
	<cffunction name="saveStorage" output="false" access="private" returntype="void" hint="Save Storage">
		<cfargument name="data" type="any" required="true" hint="Data to save"/>
		<cflock name="#getname()#.scopeoperation" type="exclusive" timeout="20" throwOnTimeout="true">
			<cfset instance.scopeStorage.put(getProperty('key'), arguments.data, getProperty('scope'))>
		</cflock>
	</cffunction>

	<!--- ensureStorage --->
	<cffunction name="ensureStorage" output="false" access="private" returntype="void" hint="Ensure the first storage in the scope">
		<cfscript>
			if( NOT instance.scopeStorage.exists(getProperty('key'),getproperty('scope')) ){
				instance.scopeStorage.put(getProperty('key'), arrayNew(1), getProperty('scope'));
			}
		</cfscript>
	</cffunction>
	
	
</cfcomponent>