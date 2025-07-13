<!--- Disable debug output for this page --->
<cfsetting showdebugoutput="false">

<!--- Initialize Database Configuration --->
<cfset dbConfig = createObject("component", "components.DatabaseConfig").init()>
<cfset dbInfo = dbConfig.getEnvironmentInfo()>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Table Access Diagnostics</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-5">
        <h1>Table Access Diagnostics</h1>
        
        <div class="alert alert-info">
            <h5>Environment Info:</h5>
            <cfoutput>
                <p><strong>Is Remote:</strong> #dbInfo.isRemote#</p>
                <p><strong>Connection Type:</strong> #dbInfo.connectionType#</p>
                <p><strong>Datasource:</strong> #dbInfo.datasourceName#</p>
                <p><strong>Server:</strong> #dbInfo.serverName#</p>
            </cfoutput>
        </div>

        <!--- Test employeeInfo table --->
        <div class="card mb-4">
            <div class="card-header">
                <h5>Test 1: employeeInfo Table Access</h5>
            </div>
            <div class="card-body">
                <cftry>
                    <cfif dbInfo.isRemote>
                        <cfquery name="testEmployeeInfo" 
                                 datasource="#dbInfo.datasourceName#"
                                 username="#dbConfig.getAzureConfig().username#"
                                 password="#dbConfig.getAzureConfig().password#">
                            SELECT TOP 5 EID, firstName, lastName, userName, accessLevel 
                            FROM employeeInfo
                        </cfquery>
                    <cfelse>
                        <cfset testEmployeeInfo = dbConfig.executeQuery("
                            SELECT TOP 5 EID, firstName, lastName, userName, accessLevel 
                            FROM employeeInfo
                        ")>
                    </cfif>
                    
                    <div class="alert alert-success">
                        <strong>SUCCESS:</strong> employeeInfo table accessible
                        <p>Records found: <cfoutput>#testEmployeeInfo.recordCount#</cfoutput></p>
                        <cfif testEmployeeInfo.recordCount GT 0>
                            <div class="table-responsive mt-3">
                                <table class="table table-sm">
                                    <thead>
                                        <tr>
                                            <th>EID</th>
                                            <th>First Name</th>
                                            <th>Last Name</th>
                                            <th>Username</th>
                                            <th>Access Level</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <cfloop query="testEmployeeInfo">
                                            <tr>
                                                <td><cfoutput>#testEmployeeInfo.EID#</cfoutput></td>
                                                <td><cfoutput>#testEmployeeInfo.firstName#</cfoutput></td>
                                                <td><cfoutput>#testEmployeeInfo.lastName#</cfoutput></td>
                                                <td><cfoutput>#testEmployeeInfo.userName#</cfoutput></td>
                                                <td><cfoutput>#testEmployeeInfo.accessLevel#</cfoutput></td>
                                            </tr>
                                        </cfloop>
                                    </tbody>
                                </table>
                            </div>
                        </cfif>
                    </div>
                    
                    <cfcatch type="any">
                        <div class="alert alert-danger">
                            <strong>ERROR:</strong> Failed to access employeeInfo table
                            <p><strong>Message:</strong> <cfoutput>#cfcatch.message#</cfoutput></p>
                            <p><strong>Detail:</strong> <cfoutput>#cfcatch.detail#</cfoutput></p>
                        </div>
                    </cfcatch>
                </cftry>
            </div>
        </div>

        <!--- Test employeeSales table --->
        <div class="card mb-4">
            <div class="card-header">
                <h5>Test 2: employeeSales Table Access</h5>
            </div>
            <div class="card-body">
                <cftry>
                    <cfif dbInfo.isRemote>
                        <cfquery name="testEmployeeSales" 
                                 datasource="#dbInfo.datasourceName#"
                                 username="#dbConfig.getAzureConfig().username#"
                                 password="#dbConfig.getAzureConfig().password#">
                            SELECT TOP 5 saleID, EID, firstName, lastName, saleDate, hours, saleAmount 
                            FROM employeeSales
                            ORDER BY saleDate DESC
                        </cfquery>
                    <cfelse>
                        <cfset testEmployeeSales = dbConfig.executeQuery("
                            SELECT TOP 5 saleID, EID, firstName, lastName, saleDate, hours, saleAmount 
                            FROM employeeSales
                            ORDER BY saleDate DESC
                        ")>
                    </cfif>
                    
                    <div class="alert alert-success">
                        <strong>SUCCESS:</strong> employeeSales table accessible
                        <p>Records found: <cfoutput>#testEmployeeSales.recordCount#</cfoutput></p>
                        <cfif testEmployeeSales.recordCount GT 0>
                            <div class="table-responsive mt-3">
                                <table class="table table-sm">
                                    <thead>
                                        <tr>
                                            <th>Sale ID</th>
                                            <th>EID</th>
                                            <th>Name</th>
                                            <th>Sale Date</th>
                                            <th>Hours</th>
                                            <th>Amount</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <cfloop query="testEmployeeSales">
                                            <tr>
                                                <td><cfoutput>#testEmployeeSales.saleID#</cfoutput></td>
                                                <td><cfoutput>#testEmployeeSales.EID#</cfoutput></td>
                                                <td><cfoutput>#testEmployeeSales.firstName# #testEmployeeSales.lastName#</cfoutput></td>
                                                <td><cfoutput>#dateFormat(testEmployeeSales.saleDate, "mm/dd/yyyy")#</cfoutput></td>
                                                <td><cfoutput>#testEmployeeSales.hours#</cfoutput></td>
                                                <td>$<cfoutput>#numberFormat(testEmployeeSales.saleAmount, "0.00")#</cfoutput></td>
                                            </tr>
                                        </cfloop>
                                    </tbody>
                                </table>
                            </div>
                        </cfif>
                    </div>
                    
                    <cfcatch type="any">
                        <div class="alert alert-danger">
                            <strong>ERROR:</strong> Failed to access employeeSales table
                            <p><strong>Message:</strong> <cfoutput>#cfcatch.message#</cfoutput></p>
                            <p><strong>Detail:</strong> <cfoutput>#cfcatch.detail#</cfoutput></p>
                        </div>
                    </cfcatch>
                </cftry>
            </div>
        </div>

        <!--- Test JOIN query --->
        <div class="card mb-4">
            <div class="card-header">
                <h5>Test 3: JOIN Query (employeeInfo + employeeSales)</h5>
            </div>
            <div class="card-body">
                <cftry>
                    <cfif dbInfo.isRemote>
                        <cfquery name="testJoin" 
                                 datasource="#dbInfo.datasourceName#"
                                 username="#dbConfig.getAzureConfig().username#"
                                 password="#dbConfig.getAzureConfig().password#">
                            SELECT TOP 5 
                                e.EID,
                                e.firstName,
                                e.lastName,
                                s.saleAmount,
                                s.saleDate
                            FROM employeeInfo e
                            LEFT JOIN employeeSales s ON e.EID = s.EID
                            WHERE s.saleAmount IS NOT NULL
                            ORDER BY s.saleDate DESC
                        </cfquery>
                    <cfelse>
                        <cfset testJoin = dbConfig.executeQuery("
                            SELECT TOP 5 
                                e.EID,
                                e.firstName,
                                e.lastName,
                                s.saleAmount,
                                s.saleDate
                            FROM employeeInfo e
                            LEFT JOIN employeeSales s ON e.EID = s.EID
                            WHERE s.saleAmount IS NOT NULL
                            ORDER BY s.saleDate DESC
                        ")>
                    </cfif>
                    
                    <div class="alert alert-success">
                        <strong>SUCCESS:</strong> JOIN query works
                        <p>Records found: <cfoutput>#testJoin.recordCount#</cfoutput></p>
                        <cfif testJoin.recordCount GT 0>
                            <div class="table-responsive mt-3">
                                <table class="table table-sm">
                                    <thead>
                                        <tr>
                                            <th>EID</th>
                                            <th>Name</th>
                                            <th>Sale Amount</th>
                                            <th>Sale Date</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <cfloop query="testJoin">
                                            <tr>
                                                <td><cfoutput>#testJoin.EID#</cfoutput></td>
                                                <td><cfoutput>#testJoin.firstName# #testJoin.lastName#</cfoutput></td>
                                                <td>$<cfoutput>#numberFormat(testJoin.saleAmount, "0.00")#</cfoutput></td>
                                                <td><cfoutput>#dateFormat(testJoin.saleDate, "mm/dd/yyyy")#</cfoutput></td>
                                            </tr>
                                        </cfloop>
                                    </tbody>
                                </table>
                            </div>
                        </cfif>
                    </div>
                    
                    <cfcatch type="any">
                        <div class="alert alert-danger">
                            <strong>ERROR:</strong> JOIN query failed
                            <p><strong>Message:</strong> <cfoutput>#cfcatch.message#</cfoutput></p>
                            <p><strong>Detail:</strong> <cfoutput>#cfcatch.detail#</cfoutput></p>
                        </div>
                    </cfcatch>
                </cftry>
            </div>
        </div>

        <!--- Test Today's Sales --->
        <div class="card mb-4">
            <div class="card-header">
                <h5>Test 4: Today's Sales Query</h5>
            </div>
            <div class="card-body">
                <cftry>
                    <cfif dbInfo.isRemote>
                        <cfquery name="testTodaysSales" 
                                 datasource="#dbInfo.datasourceName#"
                                 username="#dbConfig.getAzureConfig().username#"
                                 password="#dbConfig.getAzureConfig().password#">
                            SELECT saleID, EID, firstName, lastName, saleDate, hours, saleAmount, notes
                            FROM employeeSales 
                            WHERE CAST(saleDate AS DATE) = CAST(GETDATE() AS DATE)
                            ORDER BY saleDate DESC
                        </cfquery>
                    <cfelse>
                        <cfset testTodaysSales = dbConfig.executeQuery("
                            SELECT saleID, EID, firstName, lastName, saleDate, hours, saleAmount, notes
                            FROM employeeSales 
                            WHERE CAST(saleDate AS DATE) = CAST(GETDATE() AS DATE)
                            ORDER BY saleDate DESC
                        ")>
                    </cfif>
                    
                    <div class="alert alert-success">
                        <strong>SUCCESS:</strong> Today's sales query works
                        <p>Records found: <cfoutput>#testTodaysSales.recordCount#</cfoutput></p>
                        <cfif testTodaysSales.recordCount EQ 0>
                            <p class="text-muted">No sales recorded for today</p>
                        <cfelse>
                            <div class="table-responsive mt-3">
                                <table class="table table-sm">
                                    <thead>
                                        <tr>
                                            <th>Sale ID</th>
                                            <th>Name</th>
                                            <th>Date/Time</th>
                                            <th>Hours</th>
                                            <th>Amount</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <cfloop query="testTodaysSales">
                                            <tr>
                                                <td><cfoutput>#testTodaysSales.saleID#</cfoutput></td>
                                                <td><cfoutput>#testTodaysSales.firstName# #testTodaysSales.lastName#</cfoutput></td>
                                                <td><cfoutput>#dateFormat(testTodaysSales.saleDate, "mm/dd/yyyy")# #timeFormat(testTodaysSales.saleDate, "h:mm tt")#</cfoutput></td>
                                                <td><cfoutput>#testTodaysSales.hours#</cfoutput></td>
                                                <td>$<cfoutput>#numberFormat(testTodaysSales.saleAmount, "0.00")#</cfoutput></td>
                                            </tr>
                                        </cfloop>
                                    </tbody>
                                </table>
                            </div>
                        </cfif>
                    </div>
                    
                    <cfcatch type="any">
                        <div class="alert alert-danger">
                            <strong>ERROR:</strong> Today's sales query failed
                            <p><strong>Message:</strong> <cfoutput>#cfcatch.message#</cfoutput></p>
                            <p><strong>Detail:</strong> <cfoutput>#cfcatch.detail#</cfoutput></p>
                        </div>
                    </cfcatch>
                </cftry>
            </div>
        </div>

        <!--- Test Database Schema --->
        <div class="card mb-4">
            <div class="card-header">
                <h5>Test 5: Database Schema Information</h5>
            </div>
            <div class="card-body">
                <cftry>
                    <cfif dbInfo.isRemote>
                        <cfquery name="testSchema" 
                                 datasource="#dbInfo.datasourceName#"
                                 username="#dbConfig.getAzureConfig().username#"
                                 password="#dbConfig.getAzureConfig().password#">
                            SELECT TABLE_NAME, TABLE_TYPE
                            FROM INFORMATION_SCHEMA.TABLES
                            WHERE TABLE_TYPE = 'BASE TABLE'
                            ORDER BY TABLE_NAME
                        </cfquery>
                    <cfelse>
                        <cfset testSchema = dbConfig.executeQuery("
                            SELECT TABLE_NAME, TABLE_TYPE
                            FROM INFORMATION_SCHEMA.TABLES
                            WHERE TABLE_TYPE = 'BASE TABLE'
                            ORDER BY TABLE_NAME
                        ")>
                    </cfif>
                    
                    <div class="alert alert-success">
                        <strong>SUCCESS:</strong> Database schema accessible
                        <p>Tables found: <cfoutput>#testSchema.recordCount#</cfoutput></p>
                        <div class="mt-3">
                            <h6>Available Tables:</h6>
                            <ul>
                                <cfloop query="testSchema">
                                    <li><cfoutput>#testSchema.TABLE_NAME#</cfoutput></li>
                                </cfloop>
                            </ul>
                        </div>
                    </div>
                    
                    <cfcatch type="any">
                        <div class="alert alert-danger">
                            <strong>ERROR:</strong> Schema query failed
                            <p><strong>Message:</strong> <cfoutput>#cfcatch.message#</cfoutput></p>
                            <p><strong>Detail:</strong> <cfoutput>#cfcatch.detail#</cfoutput></p>
                        </div>
                    </cfcatch>
                </cftry>
            </div>
        </div>

        <div class="mt-4">
            <a href="index.cfm" class="btn btn-primary">Back to Dashboard</a>
            <a href="azure_sql_diagnostics.cfm" class="btn btn-secondary">Azure SQL Diagnostics</a>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
