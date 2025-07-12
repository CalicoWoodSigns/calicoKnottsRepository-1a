<!--- Disable debug output for this page --->
<cfsetting showdebugoutput="false">

<!--- Handle logout --->
<cfif structKeyExists(url, "logout")>
    <cfset structClear(session)>
    <cflocation url="index.cfm" addtoken="false">
</cfif>

<!--- Debug session check --->
<cfif structKeyExists(url, "debug")>
    <cfdump var="#session#" label="Session Debug">
    <cfabort>
</cfif>

<!--- Check if user is logged in --->
<cftry>
    <cfif NOT (isDefined("session") AND structKeyExists(session, "isLoggedIn") AND session.isLoggedIn)>
        <cflocation url="index.cfm" addtoken="false">
    </cfif>
    <cfcatch type="any">
        <!--- If there's an error with session check, redirect to login --->
        <cflocation url="index.cfm" addtoken="false">
    </cfcatch>
</cftry>

<!--- Handle profile update --->
<cfif structKeyExists(form, "action") AND form.action EQ "updateProfile">
    <cftry>
        <cfquery datasource="calicoknotts_db">
            UPDATE employeeInfo 
            SET firstName = <cfqueryparam value="#form.firstName#" cfsqltype="cf_sql_varchar">,
                lastName = <cfqueryparam value="#form.lastName#" cfsqltype="cf_sql_varchar">,
                userName = <cfqueryparam value="#form.userName#" cfsqltype="cf_sql_varchar">,
                <cfif structKeyExists(form, "password") AND len(trim(form.password)) GT 0>
                    password = <cfqueryparam value="#form.password#" cfsqltype="cf_sql_varchar">,
                </cfif>
                address1 = <cfqueryparam value="#form.address1#" cfsqltype="cf_sql_varchar">,
                city = <cfqueryparam value="#form.city#" cfsqltype="cf_sql_varchar">,
                state = <cfqueryparam value="#form.state#" cfsqltype="cf_sql_varchar">,
                phone = <cfqueryparam value="#form.phone#" cfsqltype="cf_sql_varchar">
            WHERE EID = <cfqueryparam value="#session.userID#" cfsqltype="cf_sql_integer">
        </cfquery>
        
        <!--- Update session variables --->
        <cfset session.userFirstName = form.firstName>
        <cfset session.userLastName = form.lastName>
        <cfset session.userName = form.userName>
        <cfset updateMessage = "Profile updated successfully!">
        
        <cfcatch type="any">
            <cfset updateError = "Error updating profile: #cfcatch.message#">
        </cfcatch>
    </cftry>
</cfif>

<!--- Get employee information --->
<cftry>
    <cfquery name="employeeInfo" datasource="calicoknotts_db">
        SELECT EID, userName, firstName, lastName, accessLevel, address1, city, state, phone
        FROM employeeInfo 
        WHERE EID = <cfqueryparam value="#session.userID#" cfsqltype="cf_sql_integer">
    </cfquery>
    
    <cfcatch type="any">
        <cfset employeeInfo = queryNew("EID,userName,firstName,lastName,accessLevel,address1,city,state,phone")>
    </cfcatch>
</cftry>

<!--- Set date range defaults --->
<cfset today = now()>
<cfset startOfWeek = dateAdd("d", -(dayOfWeek(today) - 1), today)>
<cfset startOfMonth = createDate(year(today), month(today), 1)>
<cfset startOfYear = createDate(year(today), 1, 1)>

<!--- Handle date range selection --->
<cfparam name="dateRange" default="today">
<cfparam name="customStartDate" default="#dateFormat(today, 'yyyy-mm-dd')#">
<cfparam name="customEndDate" default="#dateFormat(today, 'yyyy-mm-dd')#">

<cfif structKeyExists(form, "dateRange")>
    <cfset dateRange = form.dateRange>
</cfif>
<cfif structKeyExists(form, "customStartDate")>
    <cfset customStartDate = form.customStartDate>
</cfif>
<cfif structKeyExists(form, "customEndDate")>
    <cfset customEndDate = form.customEndDate>
</cfif>

<!--- Set date range based on selection --->
<cfswitch expression="#dateRange#">
    <cfcase value="today">
        <cfset startDate = today>
        <cfset endDate = today>
    </cfcase>
    <cfcase value="week">
        <cfset startDate = startOfWeek>
        <cfset endDate = today>
    </cfcase>
    <cfcase value="month">
        <cfset startDate = startOfMonth>
        <cfset endDate = today>
    </cfcase>
    <cfcase value="year">
        <cfset startDate = startOfYear>
        <cfset endDate = today>
    </cfcase>
    <cfcase value="custom">
        <cfset startDate = parseDateTime(customStartDate)>
        <cfset endDate = parseDateTime(customEndDate)>
    </cfcase>
</cfswitch>

<!--- Get employee sales data for the selected period --->
<cftry>
    <cfquery name="employeeSales" datasource="calicoknotts_db">
        SELECT saleID, saleDate, hours, saleAmount, notes
        FROM employeeSales 
        WHERE EID = <cfqueryparam value="#session.userID#" cfsqltype="cf_sql_integer">
        AND CAST(saleDate AS DATE) >= <cfqueryparam value="#dateFormat(startDate, 'yyyy-mm-dd')#" cfsqltype="cf_sql_date">
        AND CAST(saleDate AS DATE) <= <cfqueryparam value="#dateFormat(endDate, 'yyyy-mm-dd')#" cfsqltype="cf_sql_date">
        ORDER BY saleDate DESC
    </cfquery>
    
    <!--- Calculate totals --->
    <cfset totalHours = 0>
    <cfset totalSales = 0>
    <cfloop query="employeeSales">
        <cfset totalHours = totalHours + employeeSales.hours>
        <cfset totalSales = totalSales + employeeSales.saleAmount>
    </cfloop>
    
    <cfcatch type="any">
        <cfset employeeSales = queryNew("saleID,saleDate,hours,saleAmount,notes")>
        <cfset totalHours = 0>
        <cfset totalSales = 0>
    </cfcatch>
</cftry>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Employee Profile - Calico Wood Signs at Knotts</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <link href="assets/css/style.css" rel="stylesheet">
</head>
<body>
    <!--- Include Navigation Bar --->
    <cfset currentPage = "employee_profile">
    <cfinclude template="includes/navbar.cfm">
    
    <!-- Header -->
    <div class="profile-header">
        <div class="container">
            <div class="row align-items-center">
                <div class="col-md-8">
                    <h1 class="display-6 fw-bold mb-0">
                        <i class="bi bi-person-circle"></i> 
                        <cfoutput>#session.userFirstName# #session.userLastName#</cfoutput>
                    </h1>
                    <p class="mb-0 fs-5">Employee Profile & Performance</p>
                </div>
                <div class="col-md-4 text-end">
                    <a href="index.cfm" class="btn btn-outline-light">
                        <i class="bi bi-arrow-left"></i> Back to Dashboard
                    </a>
                </div>
            </div>
        </div>
    </div>

    <div class="container mt-4">
        <!--- Success/Error Messages --->
        <cfif structKeyExists(variables, "updateMessage")>
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <cfoutput>#updateMessage#</cfoutput>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </cfif>
        <cfif structKeyExists(variables, "updateError")>
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <cfoutput>#updateError#</cfoutput>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </cfif>

        <div class="row">
            <!-- Profile Information -->
            <div class="col-md-6">
                <div class="card profile-card mb-4">
                    <div class="card-header">
                        <h5 class="mb-0">
                            <i class="bi bi-person-gear"></i> Profile Information
                        </h5>
                    </div>
                    <div class="card-body">
                        <cfif employeeInfo.recordCount GT 0>
                            <form method="post">
                                <input type="hidden" name="action" value="updateProfile">
                                
                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="form-floating mb-3">
                                            <input type="text" class="form-control" id="firstName" name="firstName" 
                                                   value="<cfoutput>#employeeInfo.firstName#</cfoutput>" required>
                                            <label for="firstName">First Name</label>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="form-floating mb-3">
                                            <input type="text" class="form-control" id="lastName" name="lastName" 
                                                   value="<cfoutput>#employeeInfo.lastName#</cfoutput>" required>
                                            <label for="lastName">Last Name</label>
                                        </div>
                                    </div>
                                </div>
                                
                                <div class="form-floating mb-3">
                                    <input type="text" class="form-control" id="username" name="userName" 
                                           value="<cfoutput>#employeeInfo.userName#</cfoutput>" required>
                                    <label for="username">Username</label>
                                    <div class="form-text">
                                        <i class="bi bi-info-circle"></i> 
                                        Your username for logging into the system
                                    </div>
                                </div>
                                
                                <div class="form-floating mb-3">
                                    <input type="password" class="form-control" id="password" name="password" 
                                           placeholder="Leave blank to keep current password">
                                    <label for="password">New Password</label>
                                    <div class="form-text">
                                        <i class="bi bi-shield-lock"></i> 
                                        Leave blank to keep your current password
                                    </div>
                                </div>
                                
                                <div class="form-floating mb-3">
                                    <input type="password" class="form-control" id="confirmPassword" name="confirmPassword" 
                                           placeholder="Confirm new password">
                                    <label for="confirmPassword">Confirm New Password</label>
                                    <div class="form-text">
                                        <i class="bi bi-shield-check"></i> 
                                        Re-enter your new password to confirm
                                    </div>
                                </div>
                                
                                <div class="form-floating mb-3">
                                    <input type="text" class="form-control" id="address1" name="address1" 
                                           value="<cfoutput>#employeeInfo.address1#</cfoutput>">
                                    <label for="address1">Address</label>
                                </div>
                                
                                <div class="row">
                                    <div class="col-md-8">
                                        <div class="form-floating mb-3">
                                            <input type="text" class="form-control" id="city" name="city" 
                                                   value="<cfoutput>#employeeInfo.city#</cfoutput>">
                                            <label for="city">City</label>
                                        </div>
                                    </div>
                                    <div class="col-md-4">
                                        <div class="form-floating mb-3">
                                            <input type="text" class="form-control" id="state" name="state" 
                                                   value="<cfoutput>#employeeInfo.state#</cfoutput>">
                                            <label for="state">State</label>
                                        </div>
                                    </div>
                                </div>
                                
                                <div class="form-floating mb-3">
                                    <input type="tel" class="form-control" id="phone" name="phone" 
                                           value="<cfoutput>#employeeInfo.phone#</cfoutput>">
                                    <label for="phone">Phone</label>
                                </div>
                                
                                <div class="d-grid">
                                    <button type="submit" class="btn btn-primary">
                                        <i class="bi bi-check-circle"></i> Update Profile
                                    </button>
                                </div>
                            </form>
                        <cfelse>
                            <div class="alert alert-warning">
                                <i class="bi bi-exclamation-triangle"></i>
                                Unable to load profile information.
                            </div>
                        </cfif>
                    </div>
                </div>
            </div>

            <!-- Performance Summary -->
            <div class="col-md-6">
                <div class="stats-summary">
                    <h5 class="text-primary mb-3">
                        <i class="bi bi-graph-up"></i> Performance Summary
                    </h5>
                    <div class="row text-center">
                        <div class="col-6">
                            <div class="border-end">
                                <h3 class="text-primary mb-0"><cfoutput>#totalHours#</cfoutput></h3>
                                <small class="text-muted">Total Hours</small>
                            </div>
                        </div>
                        <div class="col-6">
                            <h3 class="text-success mb-0">$<cfoutput>#numberFormat(totalSales, "0.00")#</cfoutput></h3>
                            <small class="text-muted">Total Sales</small>
                        </div>
                    </div>
                    <hr>
                    <div class="text-center">
                        <h4 class="text-warning mb-0">
                            <cfif totalHours GT 0>
                                $<cfoutput>#numberFormat(totalSales / totalHours, "0.00")#</cfoutput>/hr
                            <cfelse>
                                $0.00/hr
                            </cfif>
                        </h4>
                        <small class="text-muted">Average Hourly Rate</small>
                    </div>
                </div>
            </div>
        </div>

        <!-- Date Range Selection -->
        <div class="date-range-card">
            <h5 class="text-primary mb-3">
                <i class="bi bi-calendar-range"></i> Select Date Range
            </h5>
            
            <form method="post" class="row align-items-end">
                <div class="col-md-8">
                    <div class="btn-group flex-wrap" role="group">
                        <input type="radio" class="btn-check" name="dateRange" id="today" value="today" 
                               <cfif dateRange EQ "today">checked</cfif>>
                        <label class="btn btn-outline-primary period-btn" for="today">Today</label>

                        <input type="radio" class="btn-check" name="dateRange" id="week" value="week" 
                               <cfif dateRange EQ "week">checked</cfif>>
                        <label class="btn btn-outline-primary period-btn" for="week">This Week</label>

                        <input type="radio" class="btn-check" name="dateRange" id="month" value="month" 
                               <cfif dateRange EQ "month">checked</cfif>>
                        <label class="btn btn-outline-primary period-btn" for="month">This Month</label>

                        <input type="radio" class="btn-check" name="dateRange" id="year" value="year" 
                               <cfif dateRange EQ "year">checked</cfif>>
                        <label class="btn btn-outline-primary period-btn" for="year">Year to Date</label>

                        <input type="radio" class="btn-check" name="dateRange" id="custom" value="custom" 
                               <cfif dateRange EQ "custom">checked</cfif>>
                        <label class="btn btn-outline-primary period-btn" for="custom">Custom</label>
                    </div>
                </div>
                <div class="col-md-4">
                    <button type="submit" class="btn btn-primary w-100">
                        <i class="bi bi-search"></i> Update View
                    </button>
                </div>
                
                <!-- Custom Date Range -->
                <div class="col-12 mt-3" id="customDates" style="display: none;">
                    <div class="row">
                        <div class="col-md-6">
                            <div class="form-floating">
                                <input type="date" class="form-control" id="customStartDate" name="customStartDate" 
                                       value="<cfoutput>#customStartDate#</cfoutput>">
                                <label for="customStartDate">Start Date</label>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="form-floating">
                                <input type="date" class="form-control" id="customEndDate" name="customEndDate" 
                                       value="<cfoutput>#customEndDate#</cfoutput>">
                                <label for="customEndDate">End Date</label>
                            </div>
                        </div>
                    </div>
                </div>
            </form>
        </div>

        <!-- Sales Data Table -->
        <div class="card">
            <div class="card-header d-flex justify-content-between align-items-center">
                <h5 class="mb-0">
                    <i class="bi bi-table"></i> Sales History
                </h5>
                <span class="badge badge-primary">
                    <cfoutput>#employeeSales.recordCount#</cfoutput> records
                </span>
            </div>
            <div class="card-body">
                <cfif employeeSales.recordCount GT 0>
                    <div class="table-responsive">
                        <table class="table table-hover">
                            <thead class="table-light">
                                <tr>
                                    <th>Date</th>
                                    <th>Time</th>
                                    <th>Hours</th>
                                    <th>Sales Amount</th>
                                    <th>Hourly Rate</th>
                                    <th>Notes</th>
                                </tr>
                            </thead>
                            <tbody>
                                <cfloop query="employeeSales">
                                    <tr>
                                        <td><cfoutput>#dateFormat(employeeSales.saleDate, "mm/dd/yyyy")#</cfoutput></td>
                                        <td><cfoutput>#timeFormat(employeeSales.saleDate, "h:mm tt")#</cfoutput></td>
                                        <td><cfoutput>#employeeSales.hours#</cfoutput></td>
                                        <td class="text-success">$<cfoutput>#numberFormat(employeeSales.saleAmount, "0.00")#</cfoutput></td>
                                        <td class="text-primary">
                                            <cfif employeeSales.hours GT 0>
                                                $<cfoutput>#numberFormat(employeeSales.saleAmount / employeeSales.hours, "0.00")#</cfoutput>/hr
                                            <cfelse>
                                                $0.00/hr
                                            </cfif>
                                        </td>
                                        <td><cfoutput>#employeeSales.notes#</cfoutput></td>
                                    </tr>
                                </cfloop>
                            </tbody>
                        </table>
                    </div>
                <cfelse>
                    <div class="alert alert-info text-center">
                        <i class="bi bi-info-circle"></i>
                        No sales data found for the selected date range.
                    </div>
                </cfif>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Show/hide custom date inputs
        document.addEventListener('DOMContentLoaded', function() {
            const customRadio = document.getElementById('custom');
            const customDates = document.getElementById('customDates');
            const allRadios = document.querySelectorAll('input[name="dateRange"]');
            
            function toggleCustomDates() {
                if (customRadio.checked) {
                    customDates.style.display = 'block';
                } else {
                    customDates.style.display = 'none';
                }
            }
            
            allRadios.forEach(radio => {
                radio.addEventListener('change', toggleCustomDates);
            });
            
            // Initial check
            toggleCustomDates();
            
            // Password validation
            const profileForm = document.querySelector('form[method="post"]');
            const passwordField = document.getElementById('password');
            const confirmPasswordField = document.getElementById('confirmPassword');
            
            function validatePasswords() {
                const password = passwordField.value;
                const confirmPassword = confirmPasswordField.value;
                
                if (password !== '' && confirmPassword !== '') {
                    if (password !== confirmPassword) {
                        confirmPasswordField.setCustomValidity('Passwords do not match');
                        confirmPasswordField.classList.add('is-invalid');
                    } else {
                        confirmPasswordField.setCustomValidity('');
                        confirmPasswordField.classList.remove('is-invalid');
                        confirmPasswordField.classList.add('is-valid');
                    }
                } else {
                    confirmPasswordField.setCustomValidity('');
                    confirmPasswordField.classList.remove('is-invalid', 'is-valid');
                }
            }
            
            passwordField.addEventListener('input', validatePasswords);
            confirmPasswordField.addEventListener('input', validatePasswords);
            
            // Form submission validation
            profileForm.addEventListener('submit', function(e) {
                const password = passwordField.value;
                const confirmPassword = confirmPasswordField.value;
                
                // If password is entered, confirm password must match
                if (password !== '' && password !== confirmPassword) {
                    e.preventDefault();
                    alert('Passwords do not match. Please check and try again.');
                    confirmPasswordField.focus();
                    return false;
                }
                
                // If confirm password is entered but password is empty
                if (confirmPassword !== '' && password === '') {
                    e.preventDefault();
                    alert('Please enter a new password first.');
                    passwordField.focus();
                    return false;
                }
            });
        });
    </script>
</body>
</html>
