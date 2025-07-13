<!--- Azure SQL Connection Diagnostics --->
<cfsetting showdebugoutput="false">

<!DOCTYPE html>
<html>
<head>
    <title>Azure SQL Connection Diagnostics</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
</head>
<body>
    <div class="container mt-4">
        <div class="row">
            <div class="col-12">
                <h1><i class="bi bi-wrench-adjustable"></i> Azure SQL Connection Diagnostics</h1>
                <p class="text-muted">Advanced troubleshooting for Azure SQL connectivity issues</p>
                
                <div class="row">
                    <!-- Server Environment Info -->
                    <div class="col-md-6 mb-4">
                        <div class="card">
                            <div class="card-header">
                                <h5><i class="bi bi-server"></i> Server Environment</h5>
                            </div>
                            <div class="card-body">
                                <cfoutput>
                                    <table class="table table-sm">
                                        <tr><td><strong>Server Name:</strong></td><td>#cgi.server_name#</td></tr>
                                        <tr><td><strong>HTTP Host:</strong></td><td>#cgi.http_host#</td></tr>
                                        <tr><td><strong>Remote Address:</strong></td><td>#cgi.remote_addr#</td></tr>
                                        <tr><td><strong>Server Software:</strong></td><td>#cgi.server_software#</td></tr>
                                        <tr><td><strong>CF Version:</strong></td><td>#server.coldfusion.productversion#</td></tr>
                                        <tr><td><strong>OS:</strong></td><td>#server.os.name#</td></tr>
                                        <tr><td><strong>Current Time:</strong></td><td>#now()#</td></tr>
                                    </table>
                                </cfoutput>
                            </div>
                        </div>
                    </div>
                    
                    <!-- DSN Configuration Test -->
                    <div class="col-md-6 mb-4">
                        <div class="card">
                            <div class="card-header">
                                <h5><i class="bi bi-database"></i> DSN Configuration</h5>
                            </div>
                            <div class="card-body">
                                <cfoutput>
                                    <cftry>
                                        <!--- Test if DSN exists at all --->
                                        <cfobject name="adminAPI" type="JAVA" class="coldfusion.server.ServiceFactory">
                                        <cfset datasourceService = adminAPI.getDataSourceService()>
                                        <cfset dsNames = datasourceService.getNames()>
                                        
                                        <div class="alert alert-info">
                                            <strong>Available DSNs:</strong><br>
                                            <cfloop array="#dsNames#" index="dsn">
                                                <span class="badge bg-secondary me-1">#dsn#</span>
                                            </cfloop>
                                        </div>
                                        
                                        <cfif arrayFind(dsNames, "calicoknotts_db_A_DSN")>
                                            <div class="alert alert-success">
                                                ✅ DSN 'calicoknotts_db_A_DSN' exists
                                            </div>
                                        <cfelse>
                                            <div class="alert alert-danger">
                                                ❌ DSN 'calicoknotts_db_A_DSN' not found
                                            </div>
                                        </cfif>
                                        
                                        <cfcatch type="any">
                                            <div class="alert alert-warning">
                                                ⚠️ Cannot access DSN service: #cfcatch.message#
                                            </div>
                                        </cfcatch>
                                    </cftry>
                                </cfoutput>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Network Connectivity Tests -->
                <div class="row">
                    <div class="col-12 mb-4">
                        <div class="card">
                            <div class="card-header">
                                <h5><i class="bi bi-wifi"></i> Network Connectivity Tests</h5>
                            </div>
                            <div class="card-body">
                                <cfoutput>
                                    <h6>DNS Resolution Test:</h6>
                                    <cftry>
                                        <cfhttp url="https://calicoknottsserver.database.windows.net" method="head" timeout="10" result="dnsTest">
                                        <div class="alert alert-success">
                                            ✅ DNS resolves - can reach calicoknottsserver.database.windows.net
                                        </div>
                                        <cfcatch type="any">
                                            <div class="alert alert-danger">
                                                ❌ DNS/Network issue: #cfcatch.message#
                                            </div>
                                        </cfcatch>
                                    </cftry>
                                    
                                    <h6>Azure SQL Firewall Test:</h6>
                                    <div class="alert alert-info">
                                        <strong>Likely Issue:</strong> Azure SQL Database firewall may be blocking this server's IP address.<br>
                                        <strong>Server IP:</strong> #cgi.remote_addr#<br>
                                        <strong>Action Required:</strong> Add this IP to Azure SQL firewall rules.
                                    </div>
                                </cfoutput>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Simple Connection Test -->
                <div class="row">
                    <div class="col-12 mb-4">
                        <div class="card">
                            <div class="card-header">
                                <h5><i class="bi bi-plug"></i> Simple Connection Test</h5>
                            </div>
                            <div class="card-body">
                                <cfoutput>
                                    <cftry>
                                        <cfquery name="simpleTest" 
                                                 datasource="calicoknotts_db_A_DSN" 
                                                 username="Rich" 
                                                 password="Tripp@2005"
                                                 timeout="30">
                                            SELECT 1 as test_value
                                        </cfquery>
                                        
                                        <div class="alert alert-success">
                                            🎉 <strong>CONNECTION SUCCESSFUL!</strong><br>
                                            Test completed successfully. Database is accessible.
                                        </div>
                                        
                                        <cfcatch type="database">
                                            <div class="alert alert-danger">
                                                ❌ <strong>Database Error:</strong><br>
                                                <strong>Type:</strong> #cfcatch.type#<br>
                                                <strong>Message:</strong> #cfcatch.message#<br>
                                                <strong>Detail:</strong> #cfcatch.detail#<br>
                                                <strong>SQL State:</strong> #cfcatch.sqlstate#<br>
                                                <strong>Error Code:</strong> #cfcatch.errorcode#<br>
                                                <cfif isDefined("cfcatch.nativeerrorcode")>
                                                    <strong>Native Error:</strong> #cfcatch.nativeerrorcode#<br>
                                                </cfif>
                                            </div>
                                        </cfcatch>
                                        <cfcatch type="any">
                                            <div class="alert alert-warning">
                                                ⚠️ <strong>General Error:</strong><br>
                                                <strong>Type:</strong> #cfcatch.type#<br>
                                                <strong>Message:</strong> #cfcatch.message#<br>
                                                <strong>Detail:</strong> #cfcatch.detail#
                                            </div>
                                        </cfcatch>
                                    </cftry>
                                </cfoutput>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Firewall Configuration Guide -->
                <div class="row">
                    <div class="col-12 mb-4">
                        <div class="card border-warning">
                            <div class="card-header bg-warning text-dark">
                                <h5><i class="bi bi-shield-exclamation"></i> Azure SQL Firewall Configuration</h5>
                            </div>
                            <div class="card-body">
                                <cfoutput>
                                    <p><strong>Most likely cause:</strong> The server IP address needs to be added to Azure SQL Database firewall rules.</p>
                                    
                                    <h6>Steps to fix:</h6>
                                    <ol>
                                        <li>Log into Azure Portal: <a href="https://portal.azure.com" target="_blank">https://portal.azure.com</a></li>
                                        <li>Navigate to: SQL databases → calicoknotts_db → Set server firewall</li>
                                        <li>Add a new rule:
                                            <ul>
                                                <li><strong>Rule name:</strong> CalicoKnotts-WebServer</li>
                                                <li><strong>Start IP:</strong> #cgi.remote_addr#</li>
                                                <li><strong>End IP:</strong> #cgi.remote_addr#</li>
                                            </ul>
                                        </li>
                                        <li>Click "Save" and wait 2-3 minutes for changes to take effect</li>
                                        <li>Refresh this page to test again</li>
                                    </ol>
                                    
                                    <div class="alert alert-info mt-3">
                                        <strong>Alternative:</strong> If you need temporary access for testing, you can enable "Allow Azure services and resources to access this server" in the firewall settings, but this is less secure for production.
                                    </div>
                                </cfoutput>
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="mt-3">
                    <a href="?refresh=true" class="btn btn-primary">
                        <i class="bi bi-arrow-clockwise"></i> Refresh Test
                    </a>
                    <a href="index.cfm" class="btn btn-outline-secondary">
                        <i class="bi bi-house"></i> Back to Dashboard
                    </a>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
