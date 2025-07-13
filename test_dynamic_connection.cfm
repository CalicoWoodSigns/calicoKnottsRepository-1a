<!--- Dynamic Database Connection Test --->
<cfsetting showdebugoutput="false">

<!--- Initialize database service --->
<cfset dbService = new components.DatabaseService()>

<!DOCTYPE html>
<html>
<head>
    <title>Dynamic Database Connection Test</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-5">
        <div class="row justify-content-center">
            <div class="col-md-10">
                <div class="card">
                    <div class="card-header bg-success text-white">
                        <h3 class="mb-0">🔄 Dynamic Database Connection Test</h3>
                        <small>Testing automatic environment detection and Azure SQL connection</small>
                    </div>
                    <div class="card-body">
                        
                        <!--- Environment Detection --->
                        <h5>🔍 Environment Detection</h5>
                        <cfset connectionInfo = dbService.getConnectionInfo()>
                        <div class="alert alert-info">
                            <div class="row">
                                <div class="col-md-6">
                                    <strong>Environment:</strong> <cfoutput>#connectionInfo.isRemote ? "Remote Server" : "Local Development"#</cfoutput><br>
                                    <strong>Connection Type:</strong> <cfoutput>#connectionInfo.connectionType#</cfoutput><br>
                                    <strong>Server Name:</strong> <cfoutput>#connectionInfo.serverName#</cfoutput>
                                </div>
                                <div class="col-md-6">
                                    <strong>HTTP Host:</strong> <cfoutput>#connectionInfo.httpHost#</cfoutput><br>
                                    <strong>Server Software:</strong> <cfoutput>#connectionInfo.serverSoftware#</cfoutput><br>
                                    <strong>Azure Server:</strong> <cfoutput>#connectionInfo.azureServer#</cfoutput>
                                </div>
                            </div>
                        </div>

                        <!--- Connection Test --->
                        <h5>🔧 Connection Test</h5>
                        <cfset testResult = dbService.testConnection()>
                        <cfif testResult.success>
                            <div class="alert alert-success">
                                ✅ <strong>SUCCESS!</strong> <cfoutput>#testResult.message#</cfoutput><br>
                                <small>
                                    <strong>Environment:</strong> <cfoutput>#testResult.environment#</cfoutput> | 
                                    <strong>Connection:</strong> <cfoutput>#testResult.connectionType#</cfoutput> | 
                                    <strong>Server Time:</strong> <cfoutput>#testResult.serverTime#</cfoutput>
                                </small>
                            </div>
                        <cfelse>
                            <div class="alert alert-danger">
                                ❌ <strong>FAILED!</strong> <cfoutput>#testResult.message#</cfoutput><br>
                                <cfif len(testResult.errorDetail)>
                                    <small><strong>Error:</strong> <cfoutput>#testResult.errorDetail#</cfoutput></small>
                                </cfif>
                            </div>
                        </cfif>

                        <!--- Data Access Test --->
                        <h5>📊 Data Access Test</h5>
                        <cftry>
                            <cfset todaysSales = dbService.getTodaysSales()>
                            <cfset todaysTotal = 0>
                            <cfloop query="todaysSales">
                                <cfset todaysTotal = todaysTotal + todaysSales.saleAmount>
                            </cfloop>
                            
                            <div class="alert alert-success">
                                ✅ <strong>Data Access Working!</strong><br>
                                <small>
                                    <strong>Today's Sales:</strong> <cfoutput>#todaysSales.recordCount#</cfoutput> records | 
                                    <strong>Total Amount:</strong> $<cfoutput>#numberFormat(todaysTotal, "0.00")#</cfoutput>
                                </small>
                            </div>
                            
                            <!--- Show recent sales --->
                            <cfif todaysSales.recordCount GT 0>
                                <div class="mt-3">
                                    <h6>Recent Sales:</h6>
                                    <div class="table-responsive">
                                        <table class="table table-sm">
                                            <thead>
                                                <tr>
                                                    <th>Employee</th>
                                                    <th>Amount</th>
                                                    <th>Time</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <cfloop query="todaysSales" endrow="5">
                                                    <tr>
                                                        <td><cfoutput>#todaysSales.firstName# #todaysSales.lastName#</cfoutput></td>
                                                        <td>$<cfoutput>#numberFormat(todaysSales.saleAmount, "0.00")#</cfoutput></td>
                                                        <td><cfoutput>#timeFormat(todaysSales.saleDate, "h:mm tt")#</cfoutput></td>
                                                    </tr>
                                                </cfloop>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </cfif>
                            
                            <cfcatch type="any">
                                <div class="alert alert-warning">
                                    ⚠️ <strong>Data Access Issue</strong><br>
                                    <small><strong>Error:</strong> <cfoutput>#cfcatch.message#</cfoutput></small>
                                </div>
                            </cfcatch>
                        </cftry>

                        <!--- Summary --->
                        <div class="mt-4">
                            <h5>📋 Summary</h5>
                            <div class="alert alert-primary">
                                <h6>Dynamic Connection Status:</h6>
                                <ul class="mb-0">
                                    <li><strong>Environment Detection:</strong> <cfoutput>#connectionInfo.isRemote ? "✅ Remote server detected" : "✅ Local development detected"#</cfoutput></li>
                                    <li><strong>Connection Method:</strong> <cfoutput>#connectionInfo.isRemote ? "✅ Using DSN (calicoknotts_db_A_DSN)" : "✅ Using direct JDBC connection"#</cfoutput></li>
                                    <li><strong>Azure Database:</strong> <cfoutput>#testResult.success ? "✅ Connected successfully" : "❌ Connection failed"#</cfoutput></li>
                                    <li><strong>Data Access:</strong> <cfoutput>#isDefined("todaysSales") ? "✅ Working correctly" : "❌ Not working"#</cfoutput></li>
                                </ul>
                            </div>
                        </div>

                        <div class="mt-3 text-center">
                            <button onclick="location.reload()" class="btn btn-primary">🔄 Refresh Test</button>
                            <a href="index.cfm" class="btn btn-outline-secondary">🏠 Back to Dashboard</a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
