<!--- Simple Test for Dynamic Database Connection --->
<cfset pageTitle = "Dynamic Connection Test">
<cfset hasError = false>
<cfset errorMessage = "">

<!--- Initialize the dynamic database configuration --->
<cftry>
    <cfset dbConfig = createObject("component", "components.DatabaseConfig")>
    <cfset dbConfig = dbConfig.init()>
    <cfset connectionTest = dbConfig.testConnection()>
    <cfset envInfo = dbConfig.getEnvironmentInfo()>
    
    <cfcatch type="any">
        <cfset hasError = true>
        <cfset errorMessage = cfcatch.message>
        <cfset errorDetail = cfcatch.detail>
    </cfcatch>
</cftry>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><cfoutput>#pageTitle#</cfoutput></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        .connection-status {
            padding: 1rem;
            border-radius: 0.5rem;
            margin: 1rem 0;
        }
        .status-success { background-color: #d1edff; border: 2px solid #0d6efd; }
        .status-error { background-color: #f8d7da; border: 2px solid #dc3545; }
        .info-table { font-family: monospace; font-size: 0.9rem; }
    </style>
</head>
<body class="bg-light">
    <div class="container mt-4">
        <div class="row">
            <div class="col-12">
                <h1 class="text-center mb-4"><cfoutput>#pageTitle#</cfoutput></h1>
                
                <cfif hasError>
                    <!--- Show initialization error --->
                    <div class="connection-status status-error">
                        <h3>Initialization Error</h3>
                        <p><strong>Error:</strong> <cfoutput>#errorMessage#</cfoutput></p>
                        <cfif isDefined("errorDetail")>
                            <p><strong>Detail:</strong> <cfoutput>#errorDetail#</cfoutput></p>
                        </cfif>
                    </div>
                <cfelse>
                    <!--- Show connection test results --->
                    <cfoutput>
                    <div class="connection-status #connectionTest.success ? 'status-success' : 'status-error'#">
                        <h3>Connection Test Results</h3>
                        <p><strong>Status:</strong> #connectionTest.message#</p>
                        <p><strong>Environment:</strong> #connectionTest.environment#</p>
                        <p><strong>Connection Type:</strong> #connectionTest.connectionType#</p>
                        <cfif len(connectionTest.datasource)>
                            <p><strong>Datasource:</strong> #connectionTest.datasource#</p>
                        </cfif>
                        <cfif connectionTest.success AND len(connectionTest.serverTime)>
                            <p><strong>Server Time:</strong> #connectionTest.serverTime#</p>
                        </cfif>
                        <cfif NOT connectionTest.success AND len(connectionTest.errorDetail)>
                            <p><strong>Error Details:</strong> #connectionTest.errorDetail#</p>
                        </cfif>
                    </div>
                    </cfoutput>
                    
                    <!--- Show environment information --->
                    <div class="card mt-4">
                        <div class="card-header">
                            <h4>Environment Information</h4>
                        </div>
                        <div class="card-body">
                            <table class="table table-striped info-table">
                                <tbody>
                                    <cfoutput>
                                    <tr><td><strong>Is Remote Server:</strong></td><td>#envInfo.isRemote ? 'Yes' : 'No'#</td></tr>
                                    <tr><td><strong>Connection Type:</strong></td><td>#envInfo.connectionType#</td></tr>
                                    <tr><td><strong>Datasource Name:</strong></td><td>#len(envInfo.datasourceName) ? envInfo.datasourceName : 'None (Direct Connection)'#</td></tr>
                                    <tr><td><strong>Server Name:</strong></td><td>#envInfo.serverName#</td></tr>
                                    <tr><td><strong>HTTP Host:</strong></td><td>#envInfo.httpHost#</td></tr>
                                    <tr><td><strong>Server Software:</strong></td><td>#envInfo.serverSoftware#</td></tr>
                                    <tr><td><strong>Remote Address:</strong></td><td>#envInfo.remoteAddr#</td></tr>
                                    <tr><td><strong>Azure Server:</strong></td><td>#envInfo.azureServer#</td></tr>
                                    <tr><td><strong>Azure Database:</strong></td><td>#envInfo.azureDatabase#</td></tr>
                                    </cfoutput>
                                </tbody>
                            </table>
                        </div>
                    </div>
                    
                    <!--- Test a simple query if connection is successful --->
                    <cfif connectionTest.success>
                        <div class="card mt-4">
                            <div class="card-header">
                                <h4>Sample Query Test</h4>
                            </div>
                            <div class="card-body">
                                <cftry>
                                    <cfset sampleQuery = dbConfig.executeQuery("SELECT COUNT(*) as employee_count FROM employees")>
                                    <p class="text-success"><strong>✓ Sample query successful!</strong></p>
                                    <p>Employee count: <strong><cfoutput>#sampleQuery.employee_count#</cfoutput></strong></p>
                                    
                                    <cfcatch type="any">
                                        <p class="text-danger"><strong>✗ Sample query failed:</strong> <cfoutput>#cfcatch.message#</cfoutput></p>
                                    </cfcatch>
                                </cftry>
                            </div>
                        </div>
                    </cfif>
                </cfif>
                
                <div class="mt-4">
                    <a href="index.cfm" class="btn btn-primary">Back to Dashboard</a>
                    <a href="remote_dsn_test.cfm" class="btn btn-secondary">Remote DSN Test</a>
                </div>
            </div>
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
