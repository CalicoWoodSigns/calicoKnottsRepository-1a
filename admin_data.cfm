<!--- Disable debug output for this page --->
<cfsetting showdebugoutput="false">

<!--- Handle logout --->
<cfif structKeyExists(url, "logout")>
    <cfset structClear(session)>
    <cflocation url="index.cfm" addtoken="false">
</cfif>

<!--- Check if user is logged in and has proper access level --->
<cftry>
    <cfif NOT (isDefined("session") AND structKeyExists(session, "isLoggedIn") AND session.isLoggedIn)>
        <cflocation url="index.cfm" addtoken="false">
    </cfif>
    
    <!--- Check access level (must be 2 or higher) --->
    <cfif NOT (isDefined("session.accessLevel") AND session.accessLevel GTE 2)>
        <cfset accessError = "Access Denied: You need supervisor or admin privileges to access this page.">
    </cfif>
    
    <cfcatch type="any">
        <cflocation url="index.cfm" addtoken="false">
    </cfcatch>
</cftry>

<!--- Handle Add Employee --->
<cfif structKeyExists(form, "action") AND form.action EQ "addEmployee">
    <cftry>
        <cfquery datasource="calicoknotts_db">
            INSERT INTO employeeInfo (userName, firstName, lastName, password, accessLevel, address1, city, state, phone)
            VALUES (
                <cfqueryparam value="#form.userName#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#form.firstName#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#form.lastName#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#form.password#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#form.accessLevel#" cfsqltype="cf_sql_integer">,
                <cfqueryparam value="#form.address1#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#form.city#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#form.state#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#form.phone#" cfsqltype="cf_sql_varchar">
            )
        </cfquery>
        <cfset successMessage = "Employee added successfully!">
        <cfcatch type="any">
            <cfset errorMessage = "Error adding employee: #cfcatch.message#">
        </cfcatch>
    </cftry>
</cfif>

<!--- Handle Delete Employee --->
<cfif structKeyExists(url, "deleteEmp") AND isNumeric(url.deleteEmp)>
    <cftry>
        <!--- Delete sales records first (foreign key constraint) --->
        <cfquery datasource="calicoknotts_db">
            DELETE FROM employeeSales WHERE EID = <cfqueryparam value="#url.deleteEmp#" cfsqltype="cf_sql_integer">
        </cfquery>
        
        <!--- Delete employee --->
        <cfquery datasource="calicoknotts_db">
            DELETE FROM employeeInfo WHERE EID = <cfqueryparam value="#url.deleteEmp#" cfsqltype="cf_sql_integer">
        </cfquery>
        <cfset successMessage = "Employee and associated sales records deleted successfully!">
        <cfcatch type="any">
            <cfset errorMessage = "Error deleting employee: #cfcatch.message#">
        </cfcatch>
    </cftry>
</cfif>

<!--- Handle Add Sales Record --->
<cfif structKeyExists(form, "action") AND form.action EQ "addSale">
    <cftry>
        <cfquery datasource="calicoknotts_db">
            INSERT INTO employeeSales (EID, firstName, lastName, saleDate, hours, saleAmount, notes)
            VALUES (
                <cfqueryparam value="#form.EID#" cfsqltype="cf_sql_integer">,
                <cfqueryparam value="#form.empFirstName#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#form.empLastName#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#form.saleDate#" cfsqltype="cf_sql_timestamp">,
                <cfqueryparam value="#form.hours#" cfsqltype="cf_sql_decimal">,
                <cfqueryparam value="#form.saleAmount#" cfsqltype="cf_sql_decimal">,
                <cfqueryparam value="#form.notes#" cfsqltype="cf_sql_varchar">
            )
        </cfquery>
        <cfset successMessage = "Sales record added successfully!">
        <cfcatch type="any">
            <cfset errorMessage = "Error adding sales record: #cfcatch.message#">
        </cfcatch>
    </cftry>
</cfif>

<!--- Handle Delete Sales Record --->
<cfif structKeyExists(url, "deleteSale") AND isNumeric(url.deleteSale)>
    <cftry>
        <cfquery datasource="calicoknotts_db">
            DELETE FROM employeeSales WHERE saleID = <cfqueryparam value="#url.deleteSale#" cfsqltype="cf_sql_integer">
        </cfquery>
        <cfset successMessage = "Sales record deleted successfully!">
        <cfcatch type="any">
            <cfset errorMessage = "Error deleting sales record: #cfcatch.message#">
        </cfcatch>
    </cftry>
</cfif>

<!--- Handle Edit Employee --->
<cfif structKeyExists(form, "action") AND form.action EQ "editEmployee">
    <cftry>
        <cfquery datasource="calicoknotts_db">
            UPDATE employeeInfo 
            SET firstName = <cfqueryparam value="#form.firstName#" cfsqltype="cf_sql_varchar">,
                lastName = <cfqueryparam value="#form.lastName#" cfsqltype="cf_sql_varchar">,
                userName = <cfqueryparam value="#form.userName#" cfsqltype="cf_sql_varchar">,
                <cfif structKeyExists(form, "password") AND len(trim(form.password)) GT 0>
                    password = <cfqueryparam value="#form.password#" cfsqltype="cf_sql_varchar">,
                </cfif>
                accessLevel = <cfqueryparam value="#form.accessLevel#" cfsqltype="cf_sql_integer">,
                address1 = <cfqueryparam value="#form.address1#" cfsqltype="cf_sql_varchar">,
                city = <cfqueryparam value="#form.city#" cfsqltype="cf_sql_varchar">,
                state = <cfqueryparam value="#form.state#" cfsqltype="cf_sql_varchar">,
                phone = <cfqueryparam value="#form.phone#" cfsqltype="cf_sql_varchar">
            WHERE EID = <cfqueryparam value="#form.editEID#" cfsqltype="cf_sql_integer">
        </cfquery>
        <cfset successMessage = "Employee updated successfully!">
        <cfcatch type="any">
            <cfset errorMessage = "Error updating employee: #cfcatch.message#">
        </cfcatch>
    </cftry>
</cfif>

<!--- Handle Edit Sales Record --->
<cfif structKeyExists(form, "action") AND form.action EQ "editSale">
    <cftry>
        <cfquery datasource="calicoknotts_db">
            UPDATE employeeSales 
            SET EID = <cfqueryparam value="#form.EID#" cfsqltype="cf_sql_integer">,
                firstName = <cfqueryparam value="#form.empFirstName#" cfsqltype="cf_sql_varchar">,
                lastName = <cfqueryparam value="#form.empLastName#" cfsqltype="cf_sql_varchar">,
                saleDate = <cfqueryparam value="#form.saleDate#" cfsqltype="cf_sql_timestamp">,
                hours = <cfqueryparam value="#form.hours#" cfsqltype="cf_sql_decimal">,
                saleAmount = <cfqueryparam value="#form.saleAmount#" cfsqltype="cf_sql_decimal">,
                notes = <cfqueryparam value="#form.notes#" cfsqltype="cf_sql_varchar">
            WHERE saleID = <cfqueryparam value="#form.editSaleID#" cfsqltype="cf_sql_integer">
        </cfquery>
        <cfset successMessage = "Sales record updated successfully!">
        <cfcatch type="any">
            <cfset errorMessage = "Error updating sales record: #cfcatch.message#">
        </cfcatch>
    </cftry>
</cfif>

<!--- Get all data --->
<cftry>
    <!--- Get all employees --->
    <cfquery name="allEmployees" datasource="calicoknotts_db">
        SELECT EID, userName, firstName, lastName, accessLevel, address1, city, state, phone
        FROM employeeInfo
        ORDER BY lastName, firstName
    </cfquery>
    
    <!--- Get all sales records --->
    <cfquery name="allSales" datasource="calicoknotts_db">
        SELECT s.saleID, s.EID, s.firstName, s.lastName, s.saleDate, s.hours, s.saleAmount, s.notes,
               e.firstName as empFirstName, e.lastName as empLastName
        FROM employeeSales s
        LEFT JOIN employeeInfo e ON s.EID = e.EID
        ORDER BY s.saleDate DESC
    </cfquery>
    
    <cfcatch type="any">
        <cfset allEmployees = queryNew("EID,userName,firstName,lastName,accessLevel,address1,city,state,phone")>
        <cfset allSales = queryNew("saleID,EID,firstName,lastName,saleDate,hours,saleAmount,notes")>
        <cfset errorMessage = "Error loading data: #cfcatch.message#">
    </cfcatch>
</cftry>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Data Management - Calico Wood Signs</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <link href="assets/css/style.css" rel="stylesheet">
</head>
<body>
    <!--- Include Navigation Bar --->
    <cfset currentPage = "admin_data">
    <cfinclude template="includes/navbar.cfm">
    
    <div class="container-fluid mt-4">
        <cfif structKeyExists(variables, "accessError")>
            <!--- Access Denied --->
            <div class="row justify-content-center">
                <div class="col-md-6">
                    <div class="alert alert-danger text-center">
                        <i class="bi bi-shield-exclamation fs-1"></i>
                        <h4 class="mt-3">Access Denied</h4>
                        <p><cfoutput>#accessError#</cfoutput></p>
                        <a href="index.cfm" class="btn btn-primary">
                            <i class="bi bi-arrow-left"></i> Back to Dashboard
                        </a>
                    </div>
                </div>
            </div>
        <cfelse>
            <!--- Admin Interface --->
            <div class="row">
                <div class="col-12">
                    <h1 class="display-6 fw-bold mb-4">
                        <i class="bi bi-gear-fill"></i> Admin Data Management
                    </h1>
                </div>
            </div>

            <!--- Success/Error Messages --->
            <cfif structKeyExists(variables, "successMessage")>
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <i class="bi bi-check-circle"></i> <cfoutput>#successMessage#</cfoutput>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </cfif>
            <cfif structKeyExists(variables, "errorMessage")>
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <i class="bi bi-exclamation-triangle"></i> <cfoutput>#errorMessage#</cfoutput>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </cfif>

            <!--- Tabs for different sections --->
            <ul class="nav nav-tabs mb-4" id="adminTabs" role="tablist">
                <li class="nav-item" role="presentation">
                    <button class="nav-link active" id="employees-tab" data-bs-toggle="tab" data-bs-target="#employees" type="button" role="tab">
                        <i class="bi bi-people-fill"></i> Employees
                    </button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link" id="sales-tab" data-bs-toggle="tab" data-bs-target="#sales" type="button" role="tab">
                        <i class="bi bi-currency-dollar"></i> Sales Records
                    </button>
                </li>
            </ul>

            <div class="tab-content" id="adminTabContent">
                <!--- Employees Tab --->
                <div class="tab-pane fade show active" id="employees" role="tabpanel">
                    <div class="row">
                        <div class="col-lg-8">
                            <div class="card">
                                <div class="card-header d-flex justify-content-between align-items-center">
                                    <h5 class="mb-0">
                                        <i class="bi bi-people"></i> All Employees
                                    </h5>
                                    <span class="badge bg-primary">
                                        <cfoutput>#allEmployees.recordCount#</cfoutput> employees
                                    </span>
                                </div>
                                <div class="card-body">
                                    <cfif allEmployees.recordCount GT 0>
                                        <div class="table-responsive">
                                            <table class="table table-hover">
                                                <thead class="table-light">
                                                    <tr>
                                                        <th>ID</th>
                                                        <th>Name</th>
                                                        <th>Username</th>
                                                        <th>Access Level</th>
                                                        <th>Contact</th>
                                                        <th>Actions</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <cfloop query="allEmployees">
                                                        <tr>
                                                            <td><cfoutput>#allEmployees.EID#</cfoutput></td>
                                                            <td>
                                                                <a href="employee_profile.cfm?emp=<cfoutput>#allEmployees.EID#</cfoutput>" class="text-decoration-none">
                                                                    <strong><cfoutput>#allEmployees.firstName# #allEmployees.lastName#</cfoutput></strong>
                                                                </a>
                                                            </td>
                                                            <td><cfoutput>#allEmployees.userName#</cfoutput></td>
                                                            <td>
                                                                <cfswitch expression="#allEmployees.accessLevel#">
                                                                    <cfcase value="1">
                                                                        <span class="badge bg-secondary">Basic User</span>
                                                                    </cfcase>
                                                                    <cfcase value="2">
                                                                        <span class="badge bg-warning">Supervisor</span>
                                                                    </cfcase>
                                                                    <cfcase value="3">
                                                                        <span class="badge bg-danger">Admin</span>
                                                                    </cfcase>
                                                                    <cfdefaultcase>
                                                                        <span class="badge bg-light text-dark"><cfoutput>#allEmployees.accessLevel#</cfoutput></span>
                                                                    </cfdefaultcase>
                                                                </cfswitch>
                                                            </td>
                                                            <td>
                                                                <small>
                                                                    <cfoutput>#allEmployees.city#, #allEmployees.state#</cfoutput><br>
                                                                    <cfoutput>#allEmployees.phone#</cfoutput>
                                                                </small>
                                                            </td>
                                                            <td>
                                                                <div class="btn-group" role="group">
                                                                    <button class="btn btn-sm btn-outline-primary" 
                                                                            onclick="editEmployee('<cfoutput>#allEmployees.EID#</cfoutput>', '<cfoutput>#allEmployees.firstName#</cfoutput>', '<cfoutput>#allEmployees.lastName#</cfoutput>', '<cfoutput>#allEmployees.userName#</cfoutput>', '<cfoutput>#allEmployees.accessLevel#</cfoutput>', '<cfoutput>#allEmployees.address1#</cfoutput>', '<cfoutput>#allEmployees.city#</cfoutput>', '<cfoutput>#allEmployees.state#</cfoutput>', '<cfoutput>#allEmployees.phone#</cfoutput>')">
                                                                        <i class="bi bi-pencil"></i>
                                                                    </button>
                                                                    <cfif allEmployees.EID NEQ session.userID>
                                                                        <a href="?deleteEmp=<cfoutput>#allEmployees.EID#</cfoutput>" 
                                                                           class="btn btn-sm btn-outline-danger" 
                                                                           onclick="return confirm('Are you sure you want to delete this employee and all their sales records?')">
                                                                            <i class="bi bi-trash"></i>
                                                                        </a>
                                                                    <cfelse>
                                                                        <span class="btn btn-sm btn-outline-secondary disabled">
                                                                            <i class="bi bi-person-check"></i>
                                                                        </span>
                                                                    </cfif>
                                                                </div>
                                                            </td>
                                                        </tr>
                                                    </cfloop>
                                                </tbody>
                                            </table>
                                        </div>
                                    <cfelse>
                                        <div class="alert alert-info">
                                            <i class="bi bi-info-circle"></i> No employees found.
                                        </div>
                                    </cfif>
                                </div>
                            </div>
                        </div>
                        
                        <div class="col-lg-4">
                            <div class="card">
                                <div class="card-header">
                                    <h5 class="mb-0">
                                        <i class="bi bi-person-plus"></i> Add New Employee
                                    </h5>
                                </div>
                                <div class="card-body">
                                    <form method="post">
                                        <input type="hidden" name="action" value="addEmployee">
                                        
                                        <div class="row">
                                            <div class="col-6">
                                                <div class="form-floating mb-3">
                                                    <input type="text" class="form-control" id="firstName" name="firstName" required>
                                                    <label for="firstName">First Name</label>
                                                </div>
                                            </div>
                                            <div class="col-6">
                                                <div class="form-floating mb-3">
                                                    <input type="text" class="form-control" id="lastName" name="lastName" required>
                                                    <label for="lastName">Last Name</label>
                                                </div>
                                            </div>
                                        </div>
                                        
                                        <div class="form-floating mb-3">
                                            <input type="text" class="form-control" id="userName" name="userName" required>
                                            <label for="userName">Username</label>
                                        </div>
                                        
                                        <div class="form-floating mb-3">
                                            <input type="password" class="form-control" id="password" name="password" required>
                                            <label for="password">Password</label>
                                        </div>
                                        
                                        <div class="form-floating mb-3">
                                            <select class="form-select" id="accessLevel" name="accessLevel" required>
                                                <option value="1">Basic User</option>
                                                <option value="2">Supervisor</option>
                                                <option value="3">Admin</option>
                                            </select>
                                            <label for="accessLevel">Access Level</label>
                                        </div>
                                        
                                        <div class="form-floating mb-3">
                                            <input type="text" class="form-control" id="address1" name="address1">
                                            <label for="address1">Address</label>
                                        </div>
                                        
                                        <div class="row">
                                            <div class="col-8">
                                                <div class="form-floating mb-3">
                                                    <input type="text" class="form-control" id="city" name="city">
                                                    <label for="city">City</label>
                                                </div>
                                            </div>
                                            <div class="col-4">
                                                <div class="form-floating mb-3">
                                                    <input type="text" class="form-control" id="state" name="state">
                                                    <label for="state">State</label>
                                                </div>
                                            </div>
                                        </div>
                                        
                                        <div class="form-floating mb-3">
                                            <input type="tel" class="form-control" id="phone" name="phone">
                                            <label for="phone">Phone</label>
                                        </div>
                                        
                                        <div class="d-grid">
                                            <button type="submit" class="btn btn-primary">
                                                <i class="bi bi-plus-circle"></i> Add Employee
                                            </button>
                                        </div>
                                    </form>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!--- Sales Records Tab --->
                <div class="tab-pane fade" id="sales" role="tabpanel">
                    <div class="row">
                        <div class="col-lg-8">
                            <div class="card">
                                <div class="card-header d-flex justify-content-between align-items-center">
                                    <h5 class="mb-0">
                                        <i class="bi bi-currency-dollar"></i> All Sales Records
                                    </h5>
                                    <span class="badge bg-success">
                                        <cfoutput>#allSales.recordCount#</cfoutput> records
                                    </span>
                                </div>
                                <div class="card-body">
                                    <cfif allSales.recordCount GT 0>
                                        <div class="table-responsive">
                                            <table class="table table-hover">
                                                <thead class="table-light">
                                                    <tr>
                                                        <th>ID</th>
                                                        <th>Employee</th>
                                                        <th>Date/Time</th>
                                                        <th>Hours</th>
                                                        <th>Amount</th>
                                                        <th>Rate</th>
                                                        <th>Notes</th>
                                                        <th>Actions</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <cfloop query="allSales">
                                                        <tr>
                                                            <td><cfoutput>#allSales.saleID#</cfoutput></td>
                                                            <td>
                                                                <a href="employee_profile.cfm?emp=<cfoutput>#allSales.EID#</cfoutput>" class="text-decoration-none">
                                                                    <cfoutput>#allSales.empFirstName# #allSales.empLastName#</cfoutput>
                                                                </a>
                                                            </td>
                                                            <td>
                                                                <cfoutput>#dateFormat(allSales.saleDate, "mm/dd/yy")#</cfoutput><br>
                                                                <small class="text-muted"><cfoutput>#timeFormat(allSales.saleDate, "h:mm tt")#</cfoutput></small>
                                                            </td>
                                                            <td><cfoutput>#allSales.hours#</cfoutput></td>
                                                            <td class="text-success">$<cfoutput>#numberFormat(allSales.saleAmount, "0.00")#</cfoutput></td>
                                                            <td class="text-primary">
                                                                <cfif allSales.hours GT 0>
                                                                    $<cfoutput>#numberFormat(allSales.saleAmount / allSales.hours, "0.00")#</cfoutput>/hr
                                                                <cfelse>
                                                                    $0.00/hr
                                                                </cfif>
                                                            </td>
                                                            <td><small><cfoutput>#left(allSales.notes, 30)#<cfif len(allSales.notes) GT 30>...</cfif></cfoutput></small></td>
                                                            <td>
                                                                <div class="btn-group" role="group">
                                                                    <button class="btn btn-sm btn-outline-primary" 
                                                                            onclick="editSale('<cfoutput>#allSales.saleID#</cfoutput>', '<cfoutput>#allSales.EID#</cfoutput>', '<cfoutput>#dateFormat(allSales.saleDate, 'yyyy-mm-dd')#T#timeFormat(allSales.saleDate, 'HH:mm')#</cfoutput>', '<cfoutput>#allSales.hours#</cfoutput>', '<cfoutput>#allSales.saleAmount#</cfoutput>', '<cfoutput>#JSStringFormat(allSales.notes)#</cfoutput>')">
                                                                        <i class="bi bi-pencil"></i>
                                                                    </button>
                                                                    <a href="?deleteSale=<cfoutput>#allSales.saleID#</cfoutput>" 
                                                                       class="btn btn-sm btn-outline-danger" 
                                                                       onclick="return confirm('Are you sure you want to delete this sales record?')">
                                                                        <i class="bi bi-trash"></i>
                                                                    </a>
                                                                </div>
                                                            </td>
                                                        </tr>
                                                    </cfloop>
                                                </tbody>
                                            </table>
                                        </div>
                                    <cfelse>
                                        <div class="alert alert-info">
                                            <i class="bi bi-info-circle"></i> No sales records found.
                                        </div>
                                    </cfif>
                                </div>
                            </div>
                        </div>
                        
                        <div class="col-lg-4">
                            <div class="card">
                                <div class="card-header">
                                    <h5 class="mb-0">
                                        <i class="bi bi-plus-circle"></i> Add Sales Record
                                    </h5>
                                </div>
                                <div class="card-body">
                                    <form method="post">
                                        <input type="hidden" name="action" value="addSale">
                                        
                                        <div class="form-floating mb-3">
                                            <select class="form-select" id="EID" name="EID" required onchange="updateEmployeeNames()">
                                                <option value="">Select Employee</option>
                                                <cfloop query="allEmployees">
                                                    <option value="<cfoutput>#allEmployees.EID#</cfoutput>" 
                                                            data-firstname="<cfoutput>#allEmployees.firstName#</cfoutput>" 
                                                            data-lastname="<cfoutput>#allEmployees.lastName#</cfoutput>">
                                                        <cfoutput>#allEmployees.firstName# #allEmployees.lastName#</cfoutput>
                                                    </option>
                                                </cfloop>
                                            </select>
                                            <label for="EID">Employee</label>
                                        </div>
                                        
                                        <input type="hidden" id="empFirstName" name="empFirstName">
                                        <input type="hidden" id="empLastName" name="empLastName">
                                        
                                        <div class="form-floating mb-3">
                                            <input type="datetime-local" class="form-control" id="saleDate" name="saleDate" required>
                                            <label for="saleDate">Date & Time</label>
                                        </div>
                                        
                                        <div class="form-floating mb-3">
                                            <input type="number" class="form-control" id="hours" name="hours" step="0.25" min="0" required>
                                            <label for="hours">Hours Worked</label>
                                        </div>
                                        
                                        <div class="form-floating mb-3">
                                            <input type="number" class="form-control" id="saleAmount" name="saleAmount" step="0.01" min="0" required>
                                            <label for="saleAmount">Sale Amount ($)</label>
                                        </div>
                                        
                                        <div class="form-floating mb-3">
                                            <textarea class="form-control" id="notes" name="notes" style="height: 80px"></textarea>
                                            <label for="notes">Notes</label>
                                        </div>
                                        
                                        <div class="d-grid">
                                            <button type="submit" class="btn btn-success">
                                                <i class="bi bi-plus-circle"></i> Add Sales Record
                                            </button>
                                        </div>
                                    </form>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </cfif>
    </div>

    <!-- Edit Employee Modal -->
    <div class="modal fade" id="editEmployeeModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">
                        <i class="bi bi-pencil-square"></i> Edit Employee
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <form method="post">
                    <input type="hidden" name="action" value="editEmployee">
                    <input type="hidden" id="editEID" name="editEID">
                    
                    <div class="modal-body">
                        <div class="row">
                            <div class="col-6">
                                <div class="form-floating mb-3">
                                    <input type="text" class="form-control" id="editFirstName" name="firstName" required>
                                    <label for="editFirstName">First Name</label>
                                </div>
                            </div>
                            <div class="col-6">
                                <div class="form-floating mb-3">
                                    <input type="text" class="form-control" id="editLastName" name="lastName" required>
                                    <label for="editLastName">Last Name</label>
                                </div>
                            </div>
                        </div>
                        
                        <div class="form-floating mb-3">
                            <input type="text" class="form-control" id="editUserName" name="userName" required>
                            <label for="editUserName">Username</label>
                        </div>
                        
                        <div class="form-floating mb-3">
                            <input type="password" class="form-control" id="editPassword" name="password" placeholder="Leave blank to keep current password">
                            <label for="editPassword">New Password</label>
                            <div class="form-text">Leave blank to keep current password</div>
                        </div>
                        
                        <div class="form-floating mb-3">
                            <select class="form-select" id="editAccessLevel" name="accessLevel" required>
                                <option value="1">Basic User</option>
                                <option value="2">Supervisor</option>
                                <option value="3">Admin</option>
                            </select>
                            <label for="editAccessLevel">Access Level</label>
                        </div>
                        
                        <div class="form-floating mb-3">
                            <input type="text" class="form-control" id="editAddress1" name="address1">
                            <label for="editAddress1">Address</label>
                        </div>
                        
                        <div class="row">
                            <div class="col-8">
                                <div class="form-floating mb-3">
                                    <input type="text" class="form-control" id="editCity" name="city">
                                    <label for="editCity">City</label>
                                </div>
                            </div>
                            <div class="col-4">
                                <div class="form-floating mb-3">
                                    <input type="text" class="form-control" id="editState" name="state">
                                    <label for="editState">State</label>
                                </div>
                            </div>
                        </div>
                        
                        <div class="form-floating mb-3">
                            <input type="tel" class="form-control" id="editPhone" name="phone">
                            <label for="editPhone">Phone</label>
                        </div>
                    </div>
                    
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary">
                            <i class="bi bi-check-circle"></i> Update Employee
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Edit Sales Record Modal -->
    <div class="modal fade" id="editSaleModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">
                        <i class="bi bi-pencil-square"></i> Edit Sales Record
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <form method="post">
                    <input type="hidden" name="action" value="editSale">
                    <input type="hidden" id="editSaleID" name="editSaleID">
                    <input type="hidden" id="editEmpFirstName" name="empFirstName">
                    <input type="hidden" id="editEmpLastName" name="empLastName">
                    
                    <div class="modal-body">
                        <div class="form-floating mb-3">
                            <select class="form-select" id="editSaleEID" name="EID" required onchange="updateEditEmployeeNames()">
                                <option value="">Select Employee</option>
                                <cfloop query="allEmployees">
                                    <option value="<cfoutput>#allEmployees.EID#</cfoutput>" 
                                            data-firstname="<cfoutput>#allEmployees.firstName#</cfoutput>" 
                                            data-lastname="<cfoutput>#allEmployees.lastName#</cfoutput>">
                                        <cfoutput>#allEmployees.firstName# #allEmployees.lastName#</cfoutput>
                                    </option>
                                </cfloop>
                            </select>
                            <label for="editSaleEID">Employee</label>
                        </div>
                        
                        <div class="form-floating mb-3">
                            <input type="datetime-local" class="form-control" id="editSaleDate" name="saleDate" required>
                            <label for="editSaleDate">Date & Time</label>
                        </div>
                        
                        <div class="form-floating mb-3">
                            <input type="number" class="form-control" id="editSaleHours" name="hours" step="0.25" min="0" required>
                            <label for="editSaleHours">Hours Worked</label>
                        </div>
                        
                        <div class="form-floating mb-3">
                            <input type="number" class="form-control" id="editSaleAmount" name="saleAmount" step="0.01" min="0" required>
                            <label for="editSaleAmount">Sale Amount ($)</label>
                        </div>
                        
                        <div class="form-floating mb-3">
                            <textarea class="form-control" id="editSaleNotes" name="notes" style="height: 80px"></textarea>
                            <label for="editSaleNotes">Notes</label>
                        </div>
                    </div>
                    
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-success">
                            <i class="bi bi-check-circle"></i> Update Sales Record
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Set current date/time for new sales record
        document.addEventListener('DOMContentLoaded', function() {
            const now = new Date();
            const offsetMs = now.getTimezoneOffset() * 60 * 1000;
            const localISOTime = (new Date(now.getTime() - offsetMs)).toISOString().slice(0, 16);
            document.getElementById('saleDate').value = localISOTime;
        });
        
        // Update employee names when employee is selected
        function updateEmployeeNames() {
            const select = document.getElementById('EID');
            const selectedOption = select.options[select.selectedIndex];
            
            if (selectedOption.value) {
                document.getElementById('empFirstName').value = selectedOption.getAttribute('data-firstname');
                document.getElementById('empLastName').value = selectedOption.getAttribute('data-lastname');
            } else {
                document.getElementById('empFirstName').value = '';
                document.getElementById('empLastName').value = '';
            }
        }
        
        // Edit Employee Function
        function editEmployee(eid, firstName, lastName, userName, accessLevel, address1, city, state, phone) {
            document.getElementById('editEID').value = eid;
            document.getElementById('editFirstName').value = firstName;
            document.getElementById('editLastName').value = lastName;
            document.getElementById('editUserName').value = userName;
            document.getElementById('editAccessLevel').value = accessLevel;
            document.getElementById('editAddress1').value = address1 || '';
            document.getElementById('editCity').value = city || '';
            document.getElementById('editState').value = state || '';
            document.getElementById('editPhone').value = phone || '';
            
            // Clear password field (leave blank to keep current password)
            document.getElementById('editPassword').value = '';
            
            var editModal = new bootstrap.Modal(document.getElementById('editEmployeeModal'));
            editModal.show();
        }
        
        // Edit Sales Function
        function editSale(saleID, eid, saleDate, hours, saleAmount, notes) {
            document.getElementById('editSaleID').value = saleID;
            document.getElementById('editSaleEID').value = eid;
            
            // Convert the sale date to proper datetime-local format
            if (saleDate) {
                // Remove any milliseconds and format for datetime-local input
                var cleanDate = saleDate.replace(/\.\d{3}/, '').replace(' ', 'T');
                if (cleanDate.length === 16) {
                    cleanDate += ':00'; // Add seconds if missing
                }
                document.getElementById('editSaleDate').value = cleanDate;
            }
            
            document.getElementById('editSaleHours').value = hours || 0;
            document.getElementById('editSaleAmount').value = saleAmount || 0;
            document.getElementById('editSaleNotes').value = notes || '';
            
            // Update employee names for the edit form
            updateEditEmployeeNames();
            
            var editModal = new bootstrap.Modal(document.getElementById('editSaleModal'));
            editModal.show();
        }
        
        // Update Employee Names for Edit Sales Form
        function updateEditEmployeeNames() {
            const select = document.getElementById('editSaleEID');
            const selectedOption = select.options[select.selectedIndex];
            if (selectedOption && selectedOption.value) {
                document.getElementById('editEmpFirstName').value = selectedOption.getAttribute('data-firstname') || '';
                document.getElementById('editEmpLastName').value = selectedOption.getAttribute('data-lastname') || '';
            } else {
                document.getElementById('editEmpFirstName').value = '';
                document.getElementById('editEmpLastName').value = '';
            }
        }
        
    </script>
</body>
</html>
