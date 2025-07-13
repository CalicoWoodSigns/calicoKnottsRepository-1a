<!--- Test Azure SQL Database Connection --->
<cfsetting showdebugoutput="false">

<!DOCTYPE html>
<html>
<head>
    <title>Azure Database Connection Test</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-5">
        <div class="row justify-content-center">
            <div class="col-md-8">
                <div class="card">
                    <div class="card-header">
                        <h3 class="mb-0">Azure SQL Database Connection Test</h3>
                        <small class="text-muted">Testing connection to: calicoknottsserver.database.windows.net</small>
                    </div>
                    <div class="card-body">
                        
                        <h5>Connection Details:</h5>
                        <ul class="list-group list-group-flush mb-4">
                            <li class="list-group-item"><strong>Server:</strong> calicoknottsserver.database.windows.net</li>
                            <li class="list-group-item"><strong>Database:</strong> calicoknotts_db</li>
                            <li class="list-group-item"><strong>Username:</strong> Rich</li>
                            <li class="list-group-item"><strong>DSN Name:</strong> calicoknotts_db_A_DSN</li>
                        </ul>

                        <h5>Test Results:</h5>
                        
                        <!--- Test 1: Direct connection with connection string --->
                        <div class="alert alert-info">
                            <h6>Test 1: Direct Connection String (No Local DSN Required)</h6>
                            <cftry>
                                <cfquery name="testConnection1" 
                                    driver="MSSQLServer"
                                    url="jdbc:sqlserver://calicoknottsserver.database.windows.net:1433;databaseName=calicoknotts_db;encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30"
                                    username="Rich"
                                    password="Tripp@2005">
                                    SELECT 1 as test_value, GETDATE() as current_time
                                </cfquery>
                                
                                <div class="alert alert-success">
                                    ✅ <strong>SUCCESS!</strong> Connected directly to Azure SQL without local DSN!<br>
                                    <small>Test Value: <cfoutput>#testConnection1.test_value#</cfoutput> | Server Time: <cfoutput>#testConnection1.current_time#</cfoutput></small>
                                </div>
                                
                                <cfcatch type="any">
                                    <div class="alert alert-danger">
                                        ❌ <strong>FAILED!</strong> Azure Connection Error<br>
                                        <small><strong>Error:</strong> <cfoutput>#cfcatch.message#</cfoutput></small><br>
                                        <small><strong>Detail:</strong> <cfoutput>#cfcatch.detail#</cfoutput></small>
                                    </div>
                                </cfcatch>
                            </cftry>
                        </div>

                        <!--- Test 2: Try original DSN if exists --->
                        <div class="alert alert-info">
                            <h6>Test 2: Original DSN (calicoknotts_db)</h6>
                            <cftry>
                                <cfquery name="testConnection2" datasource="calicoknotts_db">
                                    SELECT 1 as test_value, GETDATE() as current_time
                                </cfquery>
                                
                                <div class="alert alert-success">
                                    ✅ <strong>SUCCESS!</strong> Original DSN still works<br>
                                    <small>Test Value: <cfoutput>#testConnection2.test_value#</cfoutput> | Server Time: <cfoutput>#testConnection2.current_time#</cfoutput></small>
                                </div>
                                
                                <cfcatch type="any">
                                    <div class="alert alert-warning">
                                        ⚠️ <strong>Original DSN Not Available</strong><br>
                                        <small><strong>Error:</strong> <cfoutput>#cfcatch.message#</cfoutput></small>
                                    </div>
                                </cfcatch>
                            </cftry>
                        </div>

                        <!--- Test 3: Check database tables if connection works --->
                        <cftry>
                            <cfquery name="checkTables" 
                                driver="MSSQLServer"
                                url="jdbc:sqlserver://calicoknottsserver.database.windows.net:1433;databaseName=calicoknotts_db;encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30"
                                username="Rich"
                                password="Tripp@2005">
                                SELECT TABLE_NAME 
                                FROM INFORMATION_SCHEMA.TABLES 
                                WHERE TABLE_TYPE = 'BASE TABLE'
                                ORDER BY TABLE_NAME
                            </cfquery>
                            
                            <div class="alert alert-info">
                                <h6>Test 3: Database Tables Found</h6>
                                <div class="alert alert-success">
                                    ✅ <strong>Tables accessible!</strong> Found <cfoutput>#checkTables.recordCount#</cfoutput> tables:<br>
                                    <small>
                                        <cfloop query="checkTables">
                                            <span class="badge bg-primary me-1"><cfoutput>#checkTables.TABLE_NAME#</cfoutput></span>
                                        </cfloop>
                                    </small>
                                </div>
                            </div>
                            
                            <!--- Test 4: Check specific application tables --->
                            <cfquery name="checkEmployeeInfo" 
                                driver="MSSQLServer"
                                url="jdbc:sqlserver://calicoknottsserver.database.windows.net:1433;databaseName=calicoknotts_db;encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30"
                                username="Rich"
                                password="Tripp@2005">
                                SELECT COUNT(*) as employee_count FROM employeeInfo
                            </cfquery>
                            
                            <cfquery name="checkEmployeeSales" 
                                driver="MSSQLServer"
                                url="jdbc:sqlserver://calicoknottsserver.database.windows.net:1433;databaseName=calicoknotts_db;encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30"
                                username="Rich"
                                password="Tripp@2005">
                                SELECT COUNT(*) as sales_count FROM employeeSales
                            </cfquery>
                            
                            <div class="alert alert-info">
                                <h6>Test 4: Application Data Check</h6>
                                <div class="alert alert-success">
                                    ✅ <strong>Application tables accessible!</strong><br>
                                    <small>
                                        Employee Records: <cfoutput>#checkEmployeeInfo.employee_count#</cfoutput> | 
                                        Sales Records: <cfoutput>#checkEmployeeSales.sales_count#</cfoutput>
                                    </small>
                                </div>
                            </div>
                            
                            <cfcatch type="any">
                                <div class="alert alert-warning">
                                    ⚠️ <strong>Cannot access database structure</strong><br>
                                    <small><strong>Error:</strong> <cfoutput>#cfcatch.message#</cfoutput></small>
                                </div>
                            </cfcatch>
                        </cftry>

                        <!--- Recommendations --->
                        <div class="mt-4">
                            <h5>Recommendations:</h5>
                            <div class="alert alert-primary">
                                <h6>Next Steps:</h6>
                                <ol>
                                    <li>If Test 1 succeeded, update your application to use the new DSN: <code>calicoknotts_db_A_DSN</code></li>
                                    <li>Update connection strings in your ColdFusion application files</li>
                                    <li>Consider storing database credentials securely (environment variables or encrypted config)</li>
                                    <li>Test all application functionality with the new connection</li>
                                </ol>
                            </div>
                        </div>

                        <div class="mt-3">
                            <a href="index.cfm" class="btn btn-primary">Back to Dashboard</a>
                            <a href="?refresh=true" class="btn btn-outline-secondary">Refresh Test</a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
