<!--- Remote Server DSN Test Page --->
<!--- Upload this file to your remote server to test the calicoknotts_db_A_DSN connection --->
<cfsetting showdebugoutput="false">

<!DOCTYPE html>
<html>
<head>
    <title>Remote Server - Azure DSN Test</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        .server-info { background: #f8f9fa; padding: 15px; border-radius: 5px; margin-bottom: 20px; }
        .test-result { margin: 10px 0; }
    </style>
</head>
<body>
    <div class="container mt-5">
        <div class="row justify-content-center">
            <div class="col-md-10">
                <div class="card">
                    <div class="card-header bg-primary text-white">
                        <h3 class="mb-0">🌐 Remote Server - Azure SQL DSN Test</h3>
                        <small>Testing DSN: calicoknotts_db_A_DSN on Remote Server</small>
                    </div>
                    <div class="card-body">
                        
                        <!--- Server Environment Info --->
                        <div class="server-info">
                            <h5>📊 Server Environment Information</h5>
                            <div class="row">
                                <div class="col-md-6">
                                    <strong>Server Name:</strong> <cfoutput>#cgi.server_name#</cfoutput><br>
                                    <strong>Server Software:</strong> <cfoutput>#cgi.server_software#</cfoutput><br>
                                    <strong>ColdFusion Version:</strong> <cfoutput>#server.coldfusion.productversion#</cfoutput>
                                </div>
                                <div class="col-md-6">
                                    <strong>Remote Address:</strong> <cfoutput>#cgi.remote_addr#</cfoutput><br>
                                    <strong>HTTP Host:</strong> <cfoutput>#cgi.http_host#</cfoutput><br>
                                    <strong>Test Time:</strong> <cfoutput>#dateFormat(now(), "yyyy-mm-dd")# #timeFormat(now(), "HH:mm:ss")#</cfoutput>
                                </div>
                            </div>
                        </div>

                        <h5>🔧 DSN Connection Tests</h5>
                        
                        <!--- Test 1: Basic DSN Connection --->
                        <div class="test-result">
                            <h6>Test 1: Basic DSN Connection</h6>
                            <cftry>
                                <cfquery name="basicTest" datasource="calicoknotts_db_A_DSN">
                                    SELECT 1 as test_value, GETDATE() as server_time, @@VERSION as sql_version
                                </cfquery>
                                
                                <div class="alert alert-success">
                                    ✅ <strong>SUCCESS!</strong> DSN Connection Working<br>
                                    <small>
                                        <strong>Test Value:</strong> <cfoutput>#basicTest.test_value#</cfoutput> | 
                                        <strong>Azure Server Time:</strong> <cfoutput>#basicTest.server_time#</cfoutput><br>
                                        <strong>SQL Server:</strong> <cfoutput>#left(basicTest.sql_version, 50)#</cfoutput>...
                                    </small>
                                </div>
                                
                                <cfcatch type="any">
                                    <div class="alert alert-danger">
                                        ❌ <strong>FAILED!</strong> DSN Connection Error<br>
                                        <small>
                                            <strong>Error Type:</strong> <cfoutput>#cfcatch.type#</cfoutput><br>
                                            <strong>Message:</strong> <cfoutput>#cfcatch.message#</cfoutput><br>
                                            <strong>Detail:</strong> <cfoutput>#cfcatch.detail#</cfoutput>
                                        </small>
                                    </div>
                                </cfcatch>
                            </cftry>
                        </div>

                        <!--- Test 2: Database Structure Check --->
                        <div class="test-result">
                            <h6>Test 2: Database Structure Check</h6>
                            <cftry>
                                <cfquery name="tableCheck" datasource="calicoknotts_db_A_DSN">
                                    SELECT TABLE_NAME, TABLE_TYPE
                                    FROM INFORMATION_SCHEMA.TABLES 
                                    WHERE TABLE_TYPE = 'BASE TABLE'
                                    ORDER BY TABLE_NAME
                                </cfquery>
                                
                                <div class="alert alert-success">
                                    ✅ <strong>SUCCESS!</strong> Found <cfoutput>#tableCheck.recordCount#</cfoutput> tables in database<br>
                                    <small>
                                        <strong>Tables:</strong> 
                                        <cfloop query="tableCheck">
                                            <span class="badge bg-secondary me-1"><cfoutput>#tableCheck.TABLE_NAME#</cfoutput></span>
                                        </cfloop>
                                    </small>
                                </div>
                                
                                <cfcatch type="any">
                                    <div class="alert alert-warning">
                                        ⚠️ <strong>Cannot access database structure</strong><br>
                                        <small><strong>Error:</strong> <cfoutput>#cfcatch.message#</cfoutput></small>
                                    </div>
                                </cfcatch>
                            </cftry>
                        </div>

                        <!--- Test 3: Application Tables Check --->
                        <div class="test-result">
                            <h6>Test 3: Application Tables Data Check</h6>
                            <cftry>
                                <cfquery name="employeeCount" datasource="calicoknotts_db_A_DSN">
                                    SELECT COUNT(*) as emp_count FROM employeeInfo
                                </cfquery>
                                
                                <cfquery name="salesCount" datasource="calicoknotts_db_A_DSN">
                                    SELECT COUNT(*) as sales_count FROM employeeSales
                                </cfquery>
                                
                                <cfquery name="recentSales" datasource="calicoknotts_db_A_DSN">
                                    SELECT TOP 3 firstName, lastName, saleAmount, saleDate
                                    FROM employeeSales
                                    ORDER BY saleDate DESC
                                </cfquery>
                                
                                <div class="alert alert-success">
                                    ✅ <strong>SUCCESS!</strong> Application data accessible<br>
                                    <small>
                                        <strong>Employees:</strong> <cfoutput>#employeeCount.emp_count#</cfoutput> records | 
                                        <strong>Sales:</strong> <cfoutput>#salesCount.sales_count#</cfoutput> records<br>
                                        <strong>Recent Sales:</strong> 
                                        <cfloop query="recentSales">
                                            <cfoutput>#recentSales.firstName# #recentSales.lastName# ($#numberFormat(recentSales.saleAmount, "0.00")#)</cfoutput><cfif recentSales.currentRow LT recentSales.recordCount>, </cfif>
                                        </cfloop>
                                    </small>
                                </div>
                                
                                <cfcatch type="any">
                                    <div class="alert alert-warning">
                                        ⚠️ <strong>Cannot access application tables</strong><br>
                                        <small><strong>Error:</strong> <cfoutput>#cfcatch.message#</cfoutput></small>
                                    </div>
                                </cfcatch>
                            </cftry>
                        </div>

                        <!--- Test 4: Write Test (Insert/Delete) --->
                        <div class="test-result">
                            <h6>Test 4: Database Write Permissions Test</h6>
                            <cftry>
                                <!--- Try to create a test table --->
                                <cfquery name="writeTest" datasource="calicoknotts_db_A_DSN">
                                    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'connection_test')
                                    BEGIN
                                        CREATE TABLE connection_test (
                                            test_id INT IDENTITY(1,1) PRIMARY KEY,
                                            test_message NVARCHAR(100),
                                            test_date DATETIME DEFAULT GETDATE()
                                        )
                                    END
                                    
                                    INSERT INTO connection_test (test_message) 
                                    VALUES ('Remote server connection test - <cfoutput>#dateFormat(now(), "yyyy-mm-dd HH:mm:ss")#</cfoutput>')
                                    
                                    SELECT COUNT(*) as test_count FROM connection_test WHERE test_message LIKE '%Remote server%'
                                </cfquery>
                                
                                <div class="alert alert-success">
                                    ✅ <strong>SUCCESS!</strong> Database write permissions working<br>
                                    <small>
                                        <strong>Test records created:</strong> <cfoutput>#writeTest.test_count#</cfoutput>
                                    </small>
                                </div>
                                
                                <cfcatch type="any">
                                    <div class="alert alert-warning">
                                        ⚠️ <strong>Write permissions limited</strong><br>
                                        <small><strong>Error:</strong> <cfoutput>#cfcatch.message#</cfoutput></small>
                                    </div>
                                </cfcatch>
                            </cftry>
                        </div>

                        <!--- Overall Status --->
                        <div class="mt-4">
                            <h5>📋 Test Summary</h5>
                            <div class="alert alert-info">
                                <h6>Next Steps:</h6>
                                <ul class="mb-0">
                                    <li><strong>If all tests passed:</strong> Your DSN is working correctly on the remote server!</li>
                                    <li><strong>If tests failed:</strong> Check the DSN configuration in your remote ColdFusion Administrator</li>
                                    <li><strong>DSN Settings should be:</strong>
                                        <ul>
                                            <li>DSN Name: <code>calicoknotts_db_A_DSN</code></li>
                                            <li>Server: <code>calicoknottsserver.database.windows.net</code></li>
                                            <li>Database: <code>calicoknotts_db</code></li>
                                            <li>Username: <code>Rich</code></li>
                                            <li>Password: <code>Tripp@2005</code></li>
                                        </ul>
                                    </li>
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
