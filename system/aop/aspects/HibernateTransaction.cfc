/**
<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

@Author Luis Majano
@Description A cool annotation based Transaction Aspect for WireBox
	This interceptor will inspect objects for the 'transactional' annotation and if found,
	it will wrap it in a transaction safe hibernate transaction.  This aspect is a self binding
	aspect for WireBox that registers itself using the two annotations below
@classMatcher any
@methodMatcher annotatedWith:transactional
**/
component implements="coldbox.system.aop.MethodInterceptor" accessors="true" {
	
	// Dependencies
	property name="log" inject="logbox:logger:{this}";
	
	/**
	* Constructor
	*/
	function init(){
		return this;		
	}
	
	/**
	* The AOP around advice for hibernate transactions
	*/
	any function invokeMethod(invocation) output=false{
		
		// Are we already in a transaction?
		if( structKeyExists(request,"cbox_aop_transaction") ){
			// debug?
			if( log.canDebug() ){ log.debug("Call to '#arguments.invocation.getTargetName()#.#arguments.invocation.getMethod()#()' already transactioned, just executing it"); }
			// Just execute and return;
			return arguments.invocation.proceed();
		}
		
		// Else, transaction safe call
		var tx = ORMGetSession().beginTransaction();
		try{
			
			// mark transaction began
			request["cbox_aop_transaction"] = true;
			
			// debug?
			if( log.canDebug() ){ log.debug("Call to '#arguments.invocation.getTargetName()#.#arguments.invocation.getMethod()#()' is now transactioned and begins execution"); }
			
			// Proceed
			var results = arguments.invocation.proceed();
			
			// commit transaction
			tx.commit();
		}
		catch(Any e){
			// remove pointer
			structDelete(request,"cbox_aop_transaction");
			// Log Error
			log.error("An exception ocurred in the AOPed transactio for target: #arguments.invocation.getTargetName()#, method: #arguments.invocation.getMethod()#: #e.message# #e.detail#",e);
			// rollback
			try{
				tx.rollback();
			}
			catch(any e){
				// silent rollback as something really went wrong
			}
			//throw it
			rethrow;
		}
		
		// remove pointer, out of transaction now.
		structDelete(request,"cbox_aop_transaction");
		
		// Results? If found, return them.
		if( NOT isNull(results) ){ return results; }
	}
    	
}