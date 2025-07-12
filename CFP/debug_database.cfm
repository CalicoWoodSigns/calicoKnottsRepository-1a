<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Direct Database Query Test</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-4">
        <h2>Direct Database Query Test</h2>
        
        <div class="row">
            <div class="col-md-6">
                <h4>Employee Data</h4>
                <cftry>
                    <cfquery name="employees" datasource="calicoknotts_db">
                        SELECT EID, userName, firstName, lastName, accessLevel, city, state, phone
                        FROM employeeInfo 
                        ORDER BY lastName, firstName
                    </cfquery>
                    
                    <div class="alert alert-success">
                        Found <cfoutput>#employees.recordCount#</cfoutput> employees
                    </div>
                    
                    <table class="table table-striped">
                        <thead>
                            <tr>
                                <th>EID</th>
                                <th>Name</th>
                                <th>Username</th>
                                <th>City</th>
                                <th>Access</th>
                            </tr>
                        </thead>
                        <tbody>
                            <cfloop query="employees">
                                <tr>
                                    <td><cfoutput>#employees.EID#</cfoutput></td>
                                    <td><cfoutput>#employees.firstName# #employees.lastName#</cfoutput></td>
                                    <td><cfoutput>#employees.userName#</cfoutput></td>
                                    <td><cfoutput>#employees.city#</cfoutput></td>
                                    <td><cfoutput>#employees.accessLevel#</cfoutput></td>
                                </tr>
                            </cfloop>
                        </tbody>
                    </table>
                    
                    <cfcatch type="any">
                        <div class="alert alert-danger">
                            <strong>Employee Query Error:</strong><br>
                            <cfoutput>#cfcatch.message#</cfoutput><br>
                            <cfoutput>#cfcatch.detail#</cfoutput>
                        </div>
                    </cfcatch>
                </cftry>
            </div>
            
            <div class="col-md-6">
                <h4>Sales Data</h4>
                <cftry>
                    <cfquery name="sales" datasource="calicoknotts_db">
                        SELECT saleID, EID, firstName, lastName, saleDate, hours, saleAmount, notes
                        FROM employeeSales 
                        ORDER BY saleDate DESC
                    </cfquery>
                    
                    <div class="alert alert-success">
                        Found <cfoutput>#sales.recordCount#</cfoutput> sales records
                    </div>
                    
                    <table class="table table-striped">
                        <thead>
                            <tr>
                                <th>Sale ID</th>
                                <th>Employee</th>
                                <th>Date</th>
                                <th>Amount</th>
                                <th>Hours</th>
                            </tr>
                        </thead>
                        <tbody>
                            <cfloop query="sales">
                                <tr>
                                    <td><cfoutput>#sales.saleID#</cfoutput></td>
                                    <td><cfoutput>#sales.firstName# #sales.lastName#</cfoutput></td>
                                    <td><cfoutput>#dateFormat(sales.saleDate, "mm/dd/yyyy")#</cfoutput></td>
                                    <td>$<cfoutput>#numberFormat(sales.saleAmount, "0.00")#</cfoutput></td>
                                    <td><cfoutput>#sales.hours#</cfoutput></td>
                                </tr>
                            </cfloop>
                        </tbody>
                    </table>
                    
                    <cfcatch type="any">
                        <div class="alert alert-danger">
                            <strong>Sales Query Error:</strong><br>
                            <cfoutput>#cfcatch.message#</cfoutput><br>
                            <cfoutput>#cfcatch.detail#</cfoutput>
                        </div>
                    </cfcatch>
                </cftry>
            </div>
        </div>
        
        <div class="row mt-4">
            <div class="col-12">
                <h4>Database Connection Test</h4>
                <cftry>
                    <cfquery name="testConnection" datasource="calicoknotts_db">
                        SELECT GETDATE() as CurrentTime, @@VERSION as DatabaseVersion
                    </cfquery>
                    
                    <div class="alert alert-success">
                        <strong>Connection Successful!</strong><br>
                        Current Time: <cfoutput>#testConnection.CurrentTime#</cfoutput><br>
                        Database: <cfoutput>#left(testConnection.DatabaseVersion, 50)#</cfoutput>...
                    </div>
                    
                    <cfcatch type="any">
                        <div class="alert alert-danger">
                            <strong>Connection Error:</strong><br>
                            <cfoutput>#cfcatch.message#</cfoutput><br>
                            <cfoutput>#cfcatch.detail#</cfoutput>
                        </div>
                    </cfcatch>
                </cftry>
            </div>
        </div>
        
        <div class="mt-3">
            <a href="data_management.cfm" class="btn btn-primary">Back to Data Management</a>
            <a href="../index.cfm" class="btn btn-secondary">Back to Home</a>
        </div>
    </div>
</body>
</html>
