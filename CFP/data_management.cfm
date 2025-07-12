<!--- Data Management Page --->
<cfset variables.pageTitle = "Data Management">

<!--- Get data directly with queries instead of using DatabaseService --->
<cftry>
    <cfquery name="employees" datasource="calicoknotts_db">
        SELECT EID, userName, firstName, lastName, accessLevel, address1, city, state, phone
        FROM employeeInfo 
        ORDER BY lastName, firstName
    </cfquery>
    
    <cfquery name="sales" datasource="calicoknotts_db">
        SELECT saleID, EID, firstName, lastName, saleDate, hours, saleAmount, notes
        FROM employeeSales 
        ORDER BY saleDate DESC
    </cfquery>
    
    <cfcatch type="any">
        <cfset employees = queryNew("EID,userName,firstName,lastName,accessLevel,address1,city,state,phone")>
        <cfset sales = queryNew("saleID,EID,firstName,lastName,saleDate,hours,saleAmount,notes")>
        <cfset errorMessage = "Database Error: #cfcatch.message#">
    </cfcatch>
</cftry>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Data Management - Calico Knotts</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="/assets/css/main.css" rel="stylesheet">
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
        <div class="container">
            <a class="navbar-brand" href="/">Calico Knotts Data Management</a>
            <div class="navbar-nav ms-auto">
                <a class="nav-link" href="/">Home</a>
            </div>
        </div>
    </nav>

    <div class="container mt-4">
        <!--- Display Messages --->
        <cfif structKeyExists(url, "message")>
            <cfset messageClass = "alert-info">
            <cfif structKeyExists(url, "messageType")>
                <cfswitch expression="#url.messageType#">
                    <cfcase value="success">
                        <cfset messageClass = "alert-success">
                    </cfcase>
                    <cfcase value="error">
                        <cfset messageClass = "alert-danger">
                    </cfcase>
                </cfswitch>
            </cfif>
            <div class="alert #messageClass# alert-dismissible fade show" role="alert">
                <cfoutput>#urlDecode(url.message)#</cfoutput>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </cfif>
        <div class="row">
            <!--- Employees Section --->
            <div class="col-md-6">
                <div class="card shadow-soft mb-4">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <h4 class="mb-0">Employees</h4>
                        <button class="btn btn-primary btn-sm" data-bs-toggle="modal" data-bs-target="#addEmployeeModal">Add Employee</button>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-sm">
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>Name</th>
                                        <th>Username</th>
                                        <th>City</th>
                                        <th>Access</th>
                                        <th>Actions</th>
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
                                            <td>
                                                <button class="btn btn-outline-primary btn-sm" onclick="editEmployee(<cfoutput>#employees.EID#, '#employees.userName#', '#employees.firstName#', '#employees.lastName#', '#employees.accessLevel#', '#employees.address1#', '#employees.city#', '#employees.state#', '#employees.phone#'</cfoutput>)">Edit</button>
                                                <button class="btn btn-outline-danger btn-sm" onclick="deleteEmployee(<cfoutput>#employees.EID#, '#employees.firstName# #employees.lastName#'</cfoutput>)">Delete</button>
                                            </td>
                                        </tr>
                                    </cfloop>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>

            <!--- Sales Section --->
            <div class="col-md-6">
                <div class="card shadow-soft mb-4">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <h4 class="mb-0">Sales Records</h4>
                        <button class="btn btn-primary btn-sm" data-bs-toggle="modal" data-bs-target="#addSaleModal">Add Sale</button>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-sm">
                                <thead>
                                    <tr>
                                        <th>Sale ID</th>
                                        <th>Employee</th>
                                        <th>Date</th>
                                        <th>Amount</th>
                                        <th>Hours</th>
                                        <th>Actions</th>
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
                                            <td>
                                                <button class="btn btn-outline-primary btn-sm" onclick="editSale(<cfoutput>#sales.saleID#, #sales.EID#, '#sales.saleAmount#', '#sales.hours#', '#sales.notes#'</cfoutput>)">Edit</button>
                                                <button class="btn btn-outline-danger btn-sm" onclick="deleteSale(<cfoutput>#sales.saleID#, '#sales.firstName# #sales.lastName#', '#numberFormat(sales.saleAmount, "0.00")#'</cfoutput>)">Delete</button>
                                            </td>
                                        </tr>
                                    </cfloop>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!--- Summary Row --->
        <div class="row">
            <div class="col-md-12">
                <div class="card shadow-soft">
                    <div class="card-body">
                        <div class="row text-center">
                            <div class="col-md-3">
                                <h5 class="text-primary"><cfoutput>#employees.recordCount#</cfoutput></h5>
                                <p class="mb-0">Total Employees</p>
                            </div>
                            <div class="col-md-3">
                                <h5 class="text-success"><cfoutput>#sales.recordCount#</cfoutput></h5>
                                <p class="mb-0">Total Sales</p>
                            </div>
                            <div class="col-md-3">
                                <cfset totalSales = 0>
                                <cfloop query="sales">
                                    <cfset totalSales = totalSales + sales.saleAmount>
                                </cfloop>
                                <h5 class="text-warning">$<cfoutput>#numberFormat(totalSales, "0.00")#</cfoutput></h5>
                                <p class="mb-0">Total Revenue</p>
                            </div>
                            <div class="col-md-3">
                                <h5 class="text-info"><cfoutput>#dateTimeFormat(now(), "mm/dd/yyyy HH:nn")#</cfoutput></h5>
                                <p class="mb-0">Last Updated</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!--- Add Employee Modal --->
    <div class="modal fade" id="addEmployeeModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Add New Employee</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <form method="post" action="process_data.cfm">
                    <div class="modal-body">
                        <input type="hidden" name="action" value="addEmployee">
                        <div class="mb-3">
                            <label class="form-label">Username</label>
                            <input type="text" class="form-control" name="userName" required>
                        </div>
                        <div class="row">
                            <div class="col-md-6">
                                <label class="form-label">First Name</label>
                                <input type="text" class="form-control" name="firstName" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Last Name</label>
                                <input type="text" class="form-control" name="lastName" required>
                            </div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Password</label>
                            <input type="password" class="form-control" name="password">
                        </div>
                        <div class="row">
                            <div class="col-md-6">
                                <label class="form-label">Address</label>
                                <input type="text" class="form-control" name="address1">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">City</label>
                                <input type="text" class="form-control" name="city">
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-6">
                                <label class="form-label">State</label>
                                <input type="text" class="form-control" name="state" maxlength="2" placeholder="TX">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Phone</label>
                                <input type="text" class="form-control" name="phone">
                            </div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Access Level</label>
                            <select class="form-control" name="accessLevel">
                                <option value="1">Level 1</option>
                                <option value="2">Level 2</option>
                                <option value="3">Level 3</option>
                            </select>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary">Add Employee</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!--- Add Sale Modal --->
    <div class="modal fade" id="addSaleModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Add New Sale</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <form method="post" action="process_data.cfm">
                    <div class="modal-body">
                        <input type="hidden" name="action" value="addSale">
                        <div class="mb-3">
                            <label class="form-label">Employee</label>
                            <select class="form-control" name="employeeID" required>
                                <cfloop query="employees">
                                    <option value="<cfoutput>#employees.EID#</cfoutput>">
                                        <cfoutput>#employees.firstName# #employees.lastName#</cfoutput>
                                    </option>
                                </cfloop>
                            </select>
                        </div>
                        <div class="row">
                            <div class="col-md-6">
                                <label class="form-label">Sale Amount</label>
                                <input type="number" step="0.01" class="form-control" name="saleAmount" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Hours</label>
                                <input type="number" step="0.1" class="form-control" name="hours" value="1" required>
                            </div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Notes</label>
                            <textarea class="form-control" name="notes" rows="3"></textarea>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary">Add Sale</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!--- Edit Employee Modal --->
    <div class="modal fade" id="editEmployeeModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Edit Employee</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <form method="post" action="process_data.cfm">
                    <div class="modal-body">
                        <input type="hidden" name="action" value="editEmployee">
                        <input type="hidden" name="employeeID" id="editEmployeeID">
                        <div class="mb-3">
                            <label class="form-label">Username</label>
                            <input type="text" class="form-control" name="userName" id="editUserName" required>
                        </div>
                        <div class="row">
                            <div class="col-md-6">
                                <label class="form-label">First Name</label>
                                <input type="text" class="form-control" name="firstName" id="editFirstName" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Last Name</label>
                                <input type="text" class="form-control" name="lastName" id="editLastName" required>
                            </div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Password</label>
                            <input type="password" class="form-control" name="password" id="editPassword">
                        </div>
                        <div class="row">
                            <div class="col-md-6">
                                <label class="form-label">Address</label>
                                <input type="text" class="form-control" name="address1" id="editAddress1">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">City</label>
                                <input type="text" class="form-control" name="city" id="editCity">
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-6">
                                <label class="form-label">State</label>
                                <input type="text" class="form-control" name="state" id="editState" maxlength="2" placeholder="TX">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Phone</label>
                                <input type="text" class="form-control" name="phone" id="editPhone">
                            </div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Access Level</label>
                            <select class="form-control" name="accessLevel" id="editAccessLevel">
                                <option value="1">Level 1</option>
                                <option value="2">Level 2</option>
                                <option value="3">Level 3</option>
                            </select>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary">Update Employee</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!--- Edit Sale Modal --->
    <div class="modal fade" id="editSaleModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Edit Sale</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <form method="post" action="process_data.cfm">
                    <div class="modal-body">
                        <input type="hidden" name="action" value="editSale">
                        <input type="hidden" name="saleID" id="editSaleID">
                        <div class="mb-3">
                            <label class="form-label">Employee</label>
                            <select class="form-control" name="employeeID" id="editSaleEmployeeID" required>
                                <cfloop query="employees">
                                    <option value="<cfoutput>#employees.EID#</cfoutput>">
                                        <cfoutput>#employees.firstName# #employees.lastName#</cfoutput>
                                    </option>
                                </cfloop>
                            </select>
                        </div>
                        <div class="row">
                            <div class="col-md-6">
                                <label class="form-label">Sale Amount</label>
                                <input type="number" step="0.01" class="form-control" name="saleAmount" id="editSaleAmount" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Hours</label>
                                <input type="number" step="0.1" class="form-control" name="hours" id="editSaleHours" required>
                            </div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Notes</label>
                            <textarea class="form-control" name="notes" id="editSaleNotes" rows="3"></textarea>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary">Update Sale</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function editEmployee(eid, userName, firstName, lastName, accessLevel, address, city, state, phone) {
            // Set the values in the edit form
            document.getElementById('editEmployeeID').value = eid;
            document.getElementById('editUserName').value = userName;
            document.getElementById('editFirstName').value = firstName;
            document.getElementById('editLastName').value = lastName;
            document.getElementById('editAccessLevel').value = accessLevel;
            document.getElementById('editAddress1').value = address;
            document.getElementById('editCity').value = city;
            document.getElementById('editState').value = state;
            document.getElementById('editPhone').value = phone;
            
            // Show the modal
            var myModal = new bootstrap.Modal(document.getElementById('editEmployeeModal'));
            myModal.show();
        }
        
        function editSale(saleID, eid, saleAmount, hours, notes) {
            // Set the values in the edit form
            document.getElementById('editSaleID').value = saleID;
            document.getElementById('editSaleAmount').value = saleAmount;
            document.getElementById('editSaleHours').value = hours;
            document.getElementById('editSaleNotes').value = notes;
            document.getElementById('editSaleEmployeeID').value = eid;
            
            // Show the modal
            var myModal = new bootstrap.Modal(document.getElementById('editSaleModal'));
            myModal.show();
        }
        
        function deleteEmployee(eid, employeeName) {
            if (confirm('Are you sure you want to delete employee "' + employeeName + '"?\n\nThis action cannot be undone.')) {
                // Create a form and submit it
                var form = document.createElement('form');
                form.method = 'POST';
                form.action = 'process_data.cfm';
                
                var actionInput = document.createElement('input');
                actionInput.type = 'hidden';
                actionInput.name = 'action';
                actionInput.value = 'deleteEmployee';
                form.appendChild(actionInput);
                
                var idInput = document.createElement('input');
                idInput.type = 'hidden';
                idInput.name = 'employeeID';
                idInput.value = eid;
                form.appendChild(idInput);
                
                document.body.appendChild(form);
                form.submit();
            }
        }
        
        function deleteSale(saleId, employeeName, saleAmount) {
            if (confirm('Are you sure you want to delete the $' + saleAmount + ' sale for ' + employeeName + '?\n\nThis action cannot be undone.')) {
                // Create a form and submit it
                var form = document.createElement('form');
                form.method = 'POST';
                form.action = 'process_data.cfm';
                
                var actionInput = document.createElement('input');
                actionInput.type = 'hidden';
                actionInput.name = 'action';
                actionInput.value = 'deleteSale';
                form.appendChild(actionInput);
                
                var idInput = document.createElement('input');
                idInput.type = 'hidden';
                idInput.name = 'saleID';
                idInput.value = saleId;
                form.appendChild(idInput);
                
                document.body.appendChild(form);
                form.submit();
            }
        }
    </script>
</body>
</html>
