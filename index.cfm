<!--- Disable debug output for this page --->
<cfsetting showdebugoutput="false">

<!--- Handle Login --->
<cfset isLoggedIn = false>
<cfset loggedInUser = "">

<cfif structKeyExists(form, "action") AND form.action EQ "login">
    <cftry>
        <cfquery name="checkUser" datasource="calicoknotts_db">
            SELECT EID, firstName, lastName, userName, accessLevel
            FROM employeeInfo 
            WHERE userName = <cfqueryparam value="#form.username#" cfsqltype="cf_sql_varchar">
            AND password = <cfqueryparam value="#form.password#" cfsqltype="cf_sql_varchar">
        </cfquery>
        
        <cfif checkUser.recordCount GT 0>
            <cfset session.userID = checkUser.EID>
            <cfset session.userName = checkUser.userName>
            <cfset session.userFirstName = checkUser.firstName>
            <cfset session.userLastName = checkUser.lastName>
            <cfset session.accessLevel = checkUser.accessLevel>
            <cfset session.isLoggedIn = true>
        <cfelse>
            <cfset loginError = "Invalid username or password">
        </cfif>
        
        <cfcatch type="any">
            <cfset loginError = "Database connection error">
        </cfcatch>
    </cftry>
</cfif>

<!--- Check if user is logged in (with session safety check) --->
<cfif isDefined("session") AND structKeyExists(session, "isLoggedIn") AND session.isLoggedIn>
    <cfset isLoggedIn = true>
    <cfset loggedInUser = session.userFirstName & " " & session.userLastName>
</cfif>

<!--- Get today's data --->
<cftry>
    <!--- Today's sales --->
    <cfquery name="todaysSales" datasource="calicoknotts_db">
        SELECT saleID, EID, firstName, lastName, saleDate, hours, saleAmount, notes
        FROM employeeSales 
        WHERE CAST(saleDate AS DATE) = CAST(GETDATE() AS DATE)
        ORDER BY saleDate DESC
    </cfquery>
    
    <!--- Calculate today's total --->
    <cfset todaysTotal = 0>
    <cfloop query="todaysSales">
        <cfset todaysTotal = todaysTotal + todaysSales.saleAmount>
    </cfloop>
    
    <!--- Employee leaderboard (hourly sales rate) --->
    <cfquery name="employeeStats" datasource="calicoknotts_db">
        SELECT 
            e.EID,
            e.firstName,
            e.lastName,
            COALESCE(SUM(s.saleAmount), 0) as totalSales,
            COALESCE(SUM(s.hours), 0) as totalHours,
            CASE 
                WHEN COALESCE(SUM(s.hours), 0) > 0 
                THEN COALESCE(SUM(s.saleAmount), 0) / COALESCE(SUM(s.hours), 1)
                ELSE 0 
            END as hourlySalesRate
        FROM employeeInfo e
        LEFT JOIN employeeSales s ON e.EID = s.EID
        GROUP BY e.EID, e.firstName, e.lastName
        ORDER BY hourlySalesRate DESC
    </cfquery>
    
    <!--- Get this week's sales by day --->
    <cfset startOfWeek = dateAdd("d", -(dayOfWeek(now()) - 2), now())>
    <cfif dayOfWeek(startOfWeek) EQ 1>
        <cfset startOfWeek = dateAdd("d", -6, startOfWeek)>
    </cfif>
    <cfset endOfWeek = dateAdd("d", 6, startOfWeek)>
    
    <cfquery name="weeklySales" datasource="calicoknotts_db">
        SELECT 
            CAST(saleDate AS DATE) as saleDay,
            SUM(saleAmount) as dayTotal,
            COUNT(*) as saleCount
        FROM employeeSales 
        WHERE CAST(saleDate AS DATE) >= <cfqueryparam value="#dateFormat(startOfWeek, 'yyyy-mm-dd')#" cfsqltype="cf_sql_date">
        AND CAST(saleDate AS DATE) <= <cfqueryparam value="#dateFormat(endOfWeek, 'yyyy-mm-dd')#" cfsqltype="cf_sql_date">
        GROUP BY CAST(saleDate AS DATE)
        ORDER BY CAST(saleDate AS DATE)
    </cfquery>
    
    <!--- Create array for days of the week --->
    <cfset weekDays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]>
    <cfset dailySales = structNew()>
    <cfset weeklyTotal = 0>
    
    <!--- Initialize daily sales structure --->
    <cfloop from="1" to="7" index="i">
        <cfset currentDay = dateAdd("d", i-1, startOfWeek)>
        <cfset dayKey = dateFormat(currentDay, "yyyy-mm-dd")>
        <cfset dailySales[dayKey] = {
            "dayName" = weekDays[i],
            "date" = currentDay,
            "total" = 0,
            "count" = 0
        }>
    </cfloop>
    
    <!--- Populate with actual sales data --->
    <cfloop query="weeklySales">
        <cfset dayKey = dateFormat(weeklySales.saleDay, "yyyy-mm-dd")>
        <cfif structKeyExists(dailySales, dayKey)>
            <cfset dailySales[dayKey].total = weeklySales.dayTotal>
            <cfset dailySales[dayKey].count = weeklySales.saleCount>
            <cfset weeklyTotal = weeklyTotal + weeklySales.dayTotal>
        </cfif>
    </cfloop>
    
    <cfcatch type="any">
        <cfset todaysSales = queryNew("saleID,EID,firstName,lastName,saleDate,hours,saleAmount,notes")>
        <cfset employeeStats = queryNew("EID,firstName,lastName,totalSales,totalHours,hourlySalesRate")>
        <cfset weeklySales = queryNew("saleDay,dayTotal,saleCount")>
        <cfset todaysTotal = 0>
        <cfset weeklyTotal = 0>
        <cfset dailySales = structNew()>
        <cfset startOfWeek = now()>
        <cfset endOfWeek = now()>
        <!--- Initialize empty daily sales for error case --->
        <cfset weekDays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]>
        <cfloop from="1" to="7" index="i">
            <cfset currentDay = dateAdd("d", i-1, startOfWeek)>
            <cfset dayKey = dateFormat(currentDay, "yyyy-mm-dd")>
            <cfset dailySales[dayKey] = {
                "dayName" = weekDays[i],
                "date" = currentDay,
                "total" = 0,
                "count" = 0
            }>
        </cfloop>
    </cfcatch>
</cftry>

<!--- Set today's budget (you can modify this value) --->
<cfset todaysBudget = 1500.00>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Calico Wood Signs - Data Portal</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        .dashboard-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 2rem 0;
        }
        .stat-card {
            transition: transform 0.2s;
            border: none;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .stat-card:hover {
            transform: translateY(-2px);
        }
        .leaderboard-item {
            padding: 0.75rem;
            margin-bottom: 0.5rem;
            border-radius: 0.5rem;
            background: #f8f9fa;
            border-left: 4px solid #007bff;
        }
        .leaderboard-item:first-child {
            background: #fff3cd;
            border-left-color: #ffc107;
        }
        .login-form {
            background: rgba(255,255,255,0.95);
            border-radius: 0.5rem;
            padding: 1.5rem;
        }
        .weekly-day-card {
            transition: transform 0.2s;
            border: 1px solid #dee2e6;
        }
        .weekly-day-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }
        .today-highlight {
            border-color: #007bff !important;
            background-color: #f8f9ff !important;
        }
    </style>
</head>
<body>
    <!--- Include Navigation Bar --->
    <cfset currentPage = "home">
    <cfinclude template="includes/navbar.cfm">
    
    <!-- Header -->
    <div class="dashboard-header">
        <div class="container">
            <div class="row align-items-center">
                <div class="col-md-6">
                    <h1 class="display-5 fw-bold mb-0">Welcome to Calico Wood Signs Data Portal</h1>
                </div>
                <div class="col-md-6">
                    <div class="d-flex justify-content-between align-items-center">
                        <div class="text-end">
                            <h4 class="mb-0">
                                <i class="bi bi-calendar-date"></i> 
                                <cfoutput>#dateFormat(now(), "dddd, mmmm d, yyyy")#</cfoutput>
                            </h4>
                            <p class="mb-0">
                                <i class="bi bi-clock"></i> 
                                <cfoutput>#timeFormat(now(), "h:mm tt")#</cfoutput>
                            </p>
                        </div>
                        
                        <!-- Login/User Area -->
                        <div class="ms-4">
                            <cfif NOT isLoggedIn>
                                <form method="post" class="login-form">
                                    <input type="hidden" name="action" value="login">
                                    <div class="mb-2">
                                        <input type="text" class="form-control form-control-sm" name="username" placeholder="Username" required>
                                    </div>
                                    <div class="mb-2">
                                        <input type="password" class="form-control form-control-sm" name="password" placeholder="Password" required>
                                    </div>
                                    <button type="submit" class="btn btn-primary btn-sm w-100">Login</button>
                                    <cfif structKeyExists(variables, "loginError")>
                                        <div class="text-danger small mt-1"><cfoutput>#loginError#</cfoutput></div>
                                    </cfif>
                                </form>
                            <cfelse>
                                <div class="login-form text-center">
                                    <h5 class="text-primary mb-1">
                                        <i class="bi bi-person-circle"></i> 
                                        <cfoutput>#loggedInUser#</cfoutput>
                                    </h5>
                                    <small class="text-muted">Logged In</small>
                                </div>
                            </cfif>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Dashboard Content -->
    <div class="container mt-4">
        <!-- Stats Row -->
        <div class="row mb-4">
            <div class="col-md-6">
                <div class="card stat-card text-center">
                    <div class="card-body">
                        <h5 class="card-title text-primary">
                            <i class="bi bi-target"></i> Today's Budget
                        </h5>
                        <h2 class="text-primary">$<cfoutput>#numberFormat(todaysBudget, "0.00")#</cfoutput></h2>
                    </div>
                </div>
            </div>
            <div class="col-md-6">
                <div class="card stat-card text-center">
                    <div class="card-body">
                        <h5 class="card-title text-success">
                            <i class="bi bi-graph-up"></i> Sales So Far Today
                        </h5>
                        <h2 class="text-success">$<cfoutput>#numberFormat(todaysTotal, "0.00")#</cfoutput></h2>
                        <cfset percentOfBudget = (todaysTotal / todaysBudget) * 100>
                        <small class="text-muted">
                            <cfoutput>#numberFormat(percentOfBudget, "0.0")#%</cfoutput> of budget
                        </small>
                    </div>
                </div>
            </div>
        </div>

        <!-- Weekly Sales Row -->
        <div class="row mb-4">
            <div class="col-12">
                <div class="card">
                    <div class="card-header">
                        <h5 class="mb-0">
                            <i class="bi bi-calendar-week"></i> This Week's Sales
                        </h5>
                        <small class="text-muted">
                            Week of <cfoutput>#dateFormat(startOfWeek, "mmmm d")#</cfoutput> - <cfoutput>#dateFormat(endOfWeek, "mmmm d, yyyy")#</cfoutput>
                        </small>
                    </div>
                    <div class="card-body">
                        <div class="row text-center">
                            <cfloop from="1" to="7" index="i">
                                <cfset currentDay = dateAdd("d", i-1, startOfWeek)>
                                <cfset dayKey = dateFormat(currentDay, "yyyy-mm-dd")>
                                <cfset dayData = dailySales[dayKey]>
                                <cfset isToday = dateFormat(currentDay, "yyyy-mm-dd") EQ dateFormat(now(), "yyyy-mm-dd")>
                                
                                <div class="col">
                                    <div class="card weekly-day-card h-100 <cfif isToday>today-highlight</cfif>">
                                        <div class="card-body p-2">
                                            <h6 class="card-title mb-1 <cfif isToday>text-primary fw-bold</cfif>">
                                                <cfoutput>#dayData.dayName#</cfoutput>
                                                <cfif isToday><br><small class="badge bg-primary">Today</small></cfif>
                                            </h6>
                                            <small class="text-muted d-block mb-2">
                                                <cfoutput>#dateFormat(currentDay, "m/d")#</cfoutput>
                                            </small>
                                            <h5 class="mb-1 <cfif isToday>text-primary<cfelse>text-success</cfif>">
                                                $<cfoutput>#numberFormat(dayData.total, "0.00")#</cfoutput>
                                            </h5>
                                            <small class="text-muted">
                                                <cfoutput>#dayData.count#</cfoutput> sales
                                            </small>
                                        </div>
                                    </div>
                                </div>
                            </cfloop>
                            
                            <!-- Weekly Total -->
                            <div class="col-md-12 mt-3">
                                <div class="card bg-primary text-white">
                                    <div class="card-body text-center p-3">
                                        <h5 class="card-title mb-0">
                                            <i class="bi bi-calculator"></i> Weekly Total
                                        </h5>
                                        <h2 class="mb-0">$<cfoutput>#numberFormat(weeklyTotal, "0.00")#</cfoutput></h2>
                                        <small>
                                            <cfloop query="weeklySales">
                                                <cfset weeklyCount = 0>
                                                <cfloop query="weeklySales">
                                                    <cfset weeklyCount = weeklyCount + weeklySales.saleCount>
                                                </cfloop>
                                            </cfloop>
                                            <cfset totalSalesCount = 0>
                                            <cfloop from="1" to="7" index="i">
                                                <cfset currentDay = dateAdd("d", i-1, startOfWeek)>
                                                <cfset dayKey = dateFormat(currentDay, "yyyy-mm-dd")>
                                                <cfset totalSalesCount = totalSalesCount + dailySales[dayKey].count>
                                            </cfloop>
                                            <cfoutput>#totalSalesCount#</cfoutput> total sales this week
                                        </small>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Main Content Row -->
        <div class="row">
            <!-- Employee Leaderboard -->
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h5 class="mb-0">
                            <i class="bi bi-trophy"></i> Employee Leaderboard
                        </h5>
                        <small class="text-muted">Ranked by hourly sales rate</small>
                    </div>
                    <div class="card-body">
                        <cfif employeeStats.recordCount GT 0>
                            <cfloop query="employeeStats">
                                <div class="leaderboard-item">
                                    <div class="d-flex justify-content-between align-items-center">
                                        <div>
                                            <strong><a href="employee_profile.cfm?emp=<cfoutput>#employeeStats.EID#</cfoutput>" class="text-decoration-none"><cfoutput>#employeeStats.firstName# #employeeStats.lastName#</cfoutput></a></strong>
                                            <br>
                                            <small class="text-muted">
                                                Total: $<cfoutput>#numberFormat(employeeStats.totalSales, "0.00")#</cfoutput> 
                                                in <cfoutput>#employeeStats.totalHours#</cfoutput> hours
                                            </small>
                                        </div>
                                        <div class="text-end">
                                            <h6 class="mb-0 text-primary">
                                                $<cfoutput>#numberFormat(employeeStats.hourlySalesRate, "0.00")#</cfoutput>/hr
                                            </h6>
                                        </div>
                                    </div>
                                </div>
                            </cfloop>
                        <cfelse>
                            <p class="text-muted">No employee data available</p>
                        </cfif>
                    </div>
                </div>
            </div>

            <!-- Today's Sales -->
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h5 class="mb-0">
                            <i class="bi bi-list-check"></i> Today's Sales
                        </h5>
                    </div>
                    <div class="card-body">
                        <cfif todaysSales.recordCount GT 0>
                            <div class="table-responsive" style="max-height: 400px; overflow-y: auto;">
                                <table class="table table-sm">
                                    <thead class="table-light">
                                        <tr>
                                            <th>Employee</th>
                                            <th>Time</th>
                                            <th>Amount</th>
                                            <th>Hours</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <cfloop query="todaysSales">
                                            <tr>
                                                <td><a href="employee_profile.cfm?emp=<cfoutput>#todaysSales.EID#</cfoutput>" class="text-decoration-none"><cfoutput>#todaysSales.firstName# #todaysSales.lastName#</cfoutput></a></td>
                                                <td><cfoutput>#timeFormat(todaysSales.saleDate, "h:mm tt")#</cfoutput></td>
                                                <td>$<cfoutput>#numberFormat(todaysSales.saleAmount, "0.00")#</cfoutput></td>
                                                <td><cfoutput>#todaysSales.hours#</cfoutput></td>
                                            </tr>
                                        </cfloop>
                                    </tbody>
                                </table>
                            </div>
                        <cfelse>
                            <p class="text-muted">No sales recorded today</p>
                        </cfif>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
