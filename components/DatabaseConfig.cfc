<cfcomponent displayname="Database Configuration" hint="Handles dynamic database connections for local and remote environments">
    
    <cffunction name="init" access="public" returntype="DatabaseConfig" hint="Constructor - Initialize the database configuration">
        <!--- Set up configuration properties --->
        <cfset variables.isRemote = false>
        <cfset variables.datasourceName = "">
        <cfset variables.connectionType = "">
        <cfset variables.azureConfig = {
            server = "calicoknottsserver.database.windows.net",
            database = "calicoknotts_db",
            username = "Rich",
            password = "Tripp@2005",
            port = 1433
        }>
        
        <!--- Detect environment and configure accordingly --->
        <cfset detectEnvironment()>
        
        <cfreturn this>
    </cffunction>
    
    <cffunction name="detectEnvironment" access="private" returntype="void" hint="Detect if we're running on local or remote server">
        <cftry>
            <!--- Check server indicators --->
            <cfset var serverName = cgi.server_name>
            <cfset var httpHost = cgi.http_host>
            <cfset var serverSoftware = cgi.server_software>
            
            <!--- Determine if we're on the remote server --->
            <cfif findNoCase("calicoknotts.com", serverName) OR 
                  findNoCase("calicoknotts.com", httpHost) OR
                  findNoCase("IIS", serverSoftware)>
                
                <cfset variables.isRemote = true>
                <cfset variables.connectionType = "remote_dsn">
                <cfset variables.datasourceName = "calicoknotts_db_A_DSN">
                
            <cfelse>
                <!--- Local development environment --->
                <cfset variables.isRemote = false>
                <cfset variables.connectionType = "direct_connection">
                <cfset variables.datasourceName = ""> <!--- Will use direct connection --->
            </cfif>
            
            <cfcatch type="any">
                <!--- Default to local if detection fails --->
                <cfset variables.isRemote = false>
                <cfset variables.connectionType = "direct_connection">
                <cfset variables.datasourceName = "">
            </cfcatch>
        </cftry>
    </cffunction>
    
    <cffunction name="getDatasourceName" access="public" returntype="string" hint="Get the appropriate datasource name">
        <cfreturn variables.datasourceName>
    </cffunction>
    
    <cffunction name="isRemoteServer" access="public" returntype="boolean" hint="Check if we're on remote server">
        <cfreturn variables.isRemote>
    </cffunction>
    
    <cffunction name="getConnectionType" access="public" returntype="string" hint="Get connection type">
        <cfreturn variables.connectionType>
    </cffunction>
    
    <cffunction name="getAzureConfig" access="public" returntype="struct" hint="Get Azure configuration for direct connections">
        <cfreturn variables.azureConfig>
    </cffunction>
    
    <cffunction name="executeQuery" access="public" returntype="query" hint="Execute a query with dynamic connection">
        <cfargument name="sql" type="string" required="true">
        <cfargument name="params" type="struct" required="false" default="#structNew()#">
        
        <cfset var result = "">
        
        <cftry>
            <cfif variables.isRemote>
                <!--- Use DSN on remote server with credentials (DSN configured for "Login in Code") --->
                <cfquery name="result" 
                         datasource="#variables.datasourceName#"
                         username="#variables.azureConfig.username#"
                         password="#variables.azureConfig.password#">
                    #preserveSingleQuotes(arguments.sql)#
                </cfquery>
                
            <cfelse>
                <!--- Use direct connection on local --->
                <cfset var qryService = new Query()>
                <cfset qryService.setAttributes({
                    driver = "MSSQLServer",
                    url = "jdbc:sqlserver://#variables.azureConfig.server#:#variables.azureConfig.port#;databaseName=#variables.azureConfig.database#;encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30",
                    username = variables.azureConfig.username,
                    password = variables.azureConfig.password
                })>
                <cfset qryService.setSQL(arguments.sql)>
                <cfset result = qryService.execute().getResult()>
            </cfif>
            
            <cfcatch type="any">
                <!--- Log error and rethrow --->
                <cflog file="database_config" text="Database connection error: #cfcatch.message# - #cfcatch.detail#" type="error">
                <cfrethrow>
            </cfcatch>
        </cftry>
        
        <cfreturn result>
    </cffunction>
    
    <cffunction name="executeParameterizedQuery" access="public" returntype="query" hint="Execute a parameterized query">
        <cfargument name="sql" type="string" required="true">
        <cfargument name="params" type="struct" required="false" default="#structNew()#">
        
        <cfset var result = "">
        
        <cftry>
            <cfif variables.isRemote>
                <!--- Use DSN on remote server with credentials --->
                <cfquery name="result" 
                         datasource="#variables.datasourceName#"
                         username="#variables.azureConfig.username#"
                         password="#variables.azureConfig.password#">
                    #preserveSingleQuotes(arguments.sql)#
                    <!--- Add parameters --->
                    <cfloop collection="#arguments.params#" item="paramName">
                        <cfqueryparam value="#arguments.params[paramName]#" cfsqltype="cf_sql_varchar">
                    </cfloop>
                </cfquery>
                
            <cfelse>
                <!--- Use Query object for local development --->
                <cfset var qryService = new Query()>
                <cfset qryService.setAttributes({
                    driver = "MSSQLServer",
                    url = "jdbc:sqlserver://#variables.azureConfig.server#:#variables.azureConfig.port#;databaseName=#variables.azureConfig.database#;encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30",
                    username = variables.azureConfig.username,
                    password = variables.azureConfig.password
                })>
                <cfset qryService.setSQL(arguments.sql)>
                <!--- Add parameters to Query object --->
                <cfloop collection="#arguments.params#" item="paramName">
                    <cfset qryService.addParam(name=paramName, value=arguments.params[paramName], cfsqltype="cf_sql_varchar")>
                </cfloop>
                <cfset result = qryService.execute().getResult()>
            </cfif>
            
            <cfcatch type="any">
                <cflog file="database_config" text="Parameterized query error: #cfcatch.message# - #cfcatch.detail#" type="error">
                <cfrethrow>
            </cfcatch>
        </cftry>
        
        <cfreturn result>
    </cffunction>
    
    <cffunction name="testConnection" access="public" returntype="struct" hint="Test the current connection">
        <cfset var testResult = {
            success = false,
            message = "",
            environment = variables.isRemote ? "Remote" : "Local",
            connectionType = variables.connectionType,
            datasource = variables.datasourceName,
            serverTime = "",
            errorDetail = ""
        }>
        
        <cftry>
            <cfset var testQuery = executeQuery("SELECT 1 as test_value, GETDATE() as server_time")>
            
            <cfif testQuery.recordCount GT 0>
                <cfset testResult.success = true>
                <cfset testResult.message = "Connection successful">
                <cfset testResult.serverTime = testQuery.server_time>
            <cfelse>
                <cfset testResult.message = "Query executed but no results returned">
            </cfif>
            
            <cfcatch type="any">
                <cfset testResult.message = "Connection failed">
                <cfset testResult.errorDetail = cfcatch.message & " - " & cfcatch.detail>
            </cfcatch>
        </cftry>
        
        <cfreturn testResult>
    </cffunction>
    
    <cffunction name="getEnvironmentInfo" access="public" returntype="struct" hint="Get environment information for debugging">
        <cfreturn {
            isRemote = variables.isRemote,
            connectionType = variables.connectionType,
            datasourceName = variables.datasourceName,
            serverName = cgi.server_name,
            httpHost = cgi.http_host,
            serverSoftware = cgi.server_software,
            remoteAddr = cgi.remote_addr,
            azureServer = variables.azureConfig.server,
            azureDatabase = variables.azureConfig.database
        }>
    </cffunction>
    
</cfcomponent>
