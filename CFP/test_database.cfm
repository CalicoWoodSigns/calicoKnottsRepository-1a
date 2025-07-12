<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Database Connection Test</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-5">
        <div class="row justify-content-center">
            <div class="col-md-10">
                <div class="card">
                    <div class="card-header">
                        <h3>Azure SQL Database Connection Test</h3>
                    </div>
                    <div class="card-body">
                        
                        <!--- Test the database connection --->
                        <cfset connectionStatus = "">
                        <cfset errorMessage = "">
                        
                        <cftry>
                            <!--- Simple test query --->
                            <cfquery name="testQuery" datasource="calicoknotts_db">
                                SELECT GETDATE() as CurrentDateTime, @@VERSION as ServerVersion
                            </cfquery>
                            
                            <cfset connectionStatus = "SUCCESS">
                            
                            <cfcatch type="any">
                                <cfset connectionStatus = "FAILED">
                                <cfset errorMessage = cfcatch.message & " - " & cfcatch.detail>
                            </cfcatch>
                        </cftry>
                        
                        <!--- Display results --->
                        <cfif connectionStatus eq "SUCCESS">
                            <div class="alert alert-success">
                                <h4>✅ Database Connection Successful!</h4>
                                <p><strong>Server Time:</strong> <cfoutput>#testQuery.CurrentDateTime#</cfoutput></p>
                                <p><strong>Server Version:</strong> <cfoutput>#left(testQuery.ServerVersion, 100)#...</cfoutput></p>
                            </div>
                            
                            <h5>Connection Details:</h5>
                            <ul class="list-group">
                                <li class="list-group-item"><strong>Server:</strong> calicoknottsserver.database.windows.net</li>
                                <li class="list-group-item"><strong>Database:</strong> calicoknotts_db</li>
                                <li class="list-group-item"><strong>User:</strong> Rich</li>
                                <li class="list-group-item"><strong>Datasource:</strong> calicoknotts_db</li>
                            </ul>
                            
                        <cfelse>
                            <div class="alert alert-danger">
                                <h4>❌ Database Connection Failed</h4>
                                <p><strong>Error:</strong> <cfoutput>#errorMessage#</cfoutput></p>
                            </div>
                            
                            <h5>Troubleshooting Tips:</h5>
                            <ul>
                                <li>Verify ColdFusion has the Microsoft SQL Server JDBC driver</li>
                                <li>Check that the Azure SQL firewall allows your IP address</li>
                                <li>Confirm the username and password are correct</li>
                                <li>Ensure the database name exists</li>
                            </ul>
                        </cfif>
                        
                        <div class="mt-4">
                            <a href="index.cfm" class="btn btn-secondary">Back to Home</a>
                            <cfif connectionStatus eq "SUCCESS">
                                <a href="?refresh=true" class="btn btn-primary">Test Again</a>
                            </cfif>
                        </div>
                        
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
