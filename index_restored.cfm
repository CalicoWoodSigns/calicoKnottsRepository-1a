<!--- Disable debug output for this page --->
<cfsetting showdebugoutput="false">

<!--- Handle Login --->
<cfset isLoggedIn = false>
<cfset loggedInUser = "">

<!--- Initialize the database service with error handling --->
<cftry>
    <cfset dbService = createObject("component", "components.DatabaseService").init()>
    <cfset hasConnectionError = false>
    
    <cfcatch type="any">
        <cfset hasConnectionError = true>
        <cfset connectionError = cfcatch.message>
    </cfcatch>
</cftry>

<cfif structKeyExists(form, "action") AND form.action EQ "login" AND NOT hasConnectionError>
    <cftry>
        <cfset checkUserQuery = dbService.query("
            SELECT EID, firstName, lastName, userName, accessLevel
            FROM employeeInfo 
            WHERE userName = '#form.username#' AND password = '#form.password#'
        ")>
        
        <cfif checkUserQuery.recordCount GT 0>
            <cfset session.userID = checkUserQuery.EID>
            <cfset session.userName = checkUserQuery.userName>
            <cfset session.userFirstName = checkUserQuery.firstName>
            <cfset session.userLastName = checkUserQuery.lastName>
            <cfset session.accessLevel = checkUserQuery.accessLevel>
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
    <cfif NOT hasConnectionError>
        <!--- Today's sales --->
        <cfset todaysSales = dbService.query("
            SELECT saleID, EID, firstName, lastName, saleDate, hours, saleAmount, notes
            FROM employeeSales 
            WHERE CAST(saleDate AS DATE) = CAST(GETDATE() AS DATE)
            ORDER BY saleDate DESC
        ")>
        
        <!--- Calculate today's total --->
        <cfset todaysTotal = 0>
        <cfloop query="todaysSales">
            <cfset todaysTotal = todaysTotal + todaysSales.saleAmount>
        </cfloop>
        
        <!--- Get this week's date range (needed for leaderboard) --->
        <cfset startOfWeek = dateAdd("d", -(dayOfWeek(now()) - 2), now())>
        <cfif dayOfWeek(startOfWeek) EQ 1>
            <cfset startOfWeek = dateAdd("d", -6, startOfWeek)>
        </cfif>
        <cfset endOfWeek = dateAdd("d", 6, startOfWeek)>
        
        <!--- Handle leaderboard time period selection --->
        <cfparam name="leaderboardPeriod" default="week">
        <cfif structKeyExists(url, "period")>
            <cfset leaderboardPeriod = url.period>
        </cfif>
        
        <!--- Set date range for leaderboard --->
        <cfswitch expression="#leaderboardPeriod#">
            <cfcase value="week">
                <cfset leaderboardStartDate = startOfWeek>
                <cfset leaderboardEndDate = endOfWeek>
                <cfset leaderboardTitle = "This Week">
            </cfcase>
            <cfcase value="month">
                <cfset leaderboardStartDate = createDate(year(now()), month(now()), 1)>
                <cfset leaderboardEndDate = now()>
                <cfset leaderboardTitle = "This Month">
            </cfcase>
            <cfcase value="alltime">
                <cfset leaderboardStartDate = createDate(2020, 1, 1)>
                <cfset leaderboardEndDate = now()>
                <cfset leaderboardTitle = "All Time">
            </cfcase>
        </cfswitch>
        
        <!--- Employee leaderboard with time period filter --->
        <cfset employeeStats = dbService.query("
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
            " & (leaderboardPeriod NEQ "alltime" ? "AND CAST(s.saleDate AS DATE) >= '" & dateFormat(leaderboardStartDate, 'yyyy-mm-dd') & "' AND CAST(s.saleDate AS DATE) <= '" & dateFormat(leaderboardEndDate, 'yyyy-mm-dd') & "'" : "") & "
            GROUP BY e.EID, e.firstName, e.lastName
            ORDER BY hourlySalesRate DESC
        ")>
        
        <!--- Get this week's sales by day --->
        <cfset weeklySales = dbService.query("
            SELECT 
                CAST(saleDate AS DATE) as saleDay,
                SUM(saleAmount) as dayTotal,
                COUNT(*) as saleCount
            FROM employeeSales 
            WHERE CAST(saleDate AS DATE) >= '" & dateFormat(startOfWeek, 'yyyy-mm-dd') & "'
            AND CAST(saleDate AS DATE) <= '" & dateFormat(endOfWeek, 'yyyy-mm-dd') & "'
            GROUP BY CAST(saleDate AS DATE)
            ORDER BY CAST(saleDate AS DATE)
        ")>
        
        <!--- Get detailed sales data for each day of the week --->
        <cfset weeklyDetailedSales = dbService.query("
            SELECT 
                saleID,
                EID,
                firstName,
                lastName,
                saleDate,
                hours,
                saleAmount,
                notes,
                CAST(saleDate AS DATE) as saleDay
            FROM employeeSales 
            WHERE CAST(saleDate AS DATE) >= '" & dateFormat(startOfWeek, 'yyyy-mm-dd') & "'
            AND CAST(saleDate AS DATE) <= '" & dateFormat(endOfWeek, 'yyyy-mm-dd') & "'
            ORDER BY CAST(saleDate AS DATE), saleDate
        ")>
        
    <cfelse>
        <!--- Create empty queries when there's a connection error --->
        <cfset todaysSales = queryNew("saleID,EID,firstName,lastName,saleDate,hours,saleAmount,notes")>
        <cfset employeeStats = queryNew("EID,firstName,lastName,totalSales,totalHours,hourlySalesRate")>
        <cfset weeklySales = queryNew("saleDay,dayTotal,saleCount")>
        <cfset weeklyDetailedSales = queryNew("saleID,EID,firstName,lastName,saleDate,hours,saleAmount,notes,saleDay")>
        <cfset todaysTotal = 0>
        <cfset weeklyTotal = 0>
        <cfset startOfWeek = now()>
        <cfset endOfWeek = now()>
        <cfset leaderboardPeriod = "week">
        <cfset leaderboardTitle = "This Week">
        <cfset leaderboardStartDate = now()>
        <cfset leaderboardEndDate = now()>
    </cfif>
    
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
            "count" = 0,
            "sales" = arrayNew(1)
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
    
    <!--- Populate detailed sales entries for each day --->
    <cfloop query="weeklyDetailedSales">
        <cfset dayKey = dateFormat(weeklyDetailedSales.saleDay, "yyyy-mm-dd")>
        <cfif structKeyExists(dailySales, dayKey)>
            <cfset saleEntry = {
                "saleID" = weeklyDetailedSales.saleID,
                "EID" = weeklyDetailedSales.EID,
                "firstName" = weeklyDetailedSales.firstName,
                "lastName" = weeklyDetailedSales.lastName,
                "saleDate" = weeklyDetailedSales.saleDate,
                "hours" = weeklyDetailedSales.hours,
                "saleAmount" = weeklyDetailedSales.saleAmount,
                "notes" = weeklyDetailedSales.notes
            }>
            <cfset arrayAppend(dailySales[dayKey].sales, saleEntry)>
        </cfif>
    </cfloop>
    
    <cfcatch type="any">
        <cfset todaysSales = queryNew("saleID,EID,firstName,lastName,saleDate,hours,saleAmount,notes")>
        <cfset employeeStats = queryNew("EID,firstName,lastName,totalSales,totalHours,hourlySalesRate")>
        <cfset weeklySales = queryNew("saleDay,dayTotal,saleCount")>
        <cfset weeklyDetailedSales = queryNew("saleID,EID,firstName,lastName,saleDate,hours,saleAmount,notes,saleDay")>
        <cfset todaysTotal = 0>
        <cfset weeklyTotal = 0>
        <cfset dailySales = structNew()>
        <cfset startOfWeek = now()>
        <cfset endOfWeek = now()>
        <cfset leaderboardPeriod = "week">
        <cfset leaderboardTitle = "This Week">
        <cfset leaderboardStartDate = now()>
        <cfset leaderboardEndDate = now()>
        <!--- Initialize empty daily sales for error case --->
        <cfset weekDays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]>
        <cfloop from="1" to="7" index="i">
            <cfset currentDay = dateAdd("d", i-1, startOfWeek)>
            <cfset dayKey = dateFormat(currentDay, "yyyy-mm-dd")>
            <cfset dailySales[dayKey] = {
                "dayName" = weekDays[i],
                "date" = currentDay,
                "total" = 0,
                "count" = 0,
                "sales" = arrayNew(1)
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
        .sales-detail {
            font-size: 0.8rem;
            max-height: 150px;
            overflow-y: auto;
        }
        .sale-item {
            background: rgba(255,255,255,0.7);
            border-radius: 3px;
            padding: 2px 5px;
            margin: 1px 0;
            border-left: 2px solid #28a745;
        }
        .leaderboard-filter {
            margin-bottom: 1rem;
        }
        .filter-btn {
            margin-right: 0.5rem;
        }
        .error-alert {
            background-color: #f8d7da;
            border: 1px solid #f5c6cb;
            color: #721c24;
            padding: 1rem;
            border-radius: 0.5rem;
            margin-bottom: 1rem;
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
                    <h1 class="mb-0">
                        <i class="bi bi-graph-up-arrow"></i> Data Portal
                    </h1>
                    <p class="mb-0 opacity-75">Real-time sales dashboard and analytics</p>
                </div>
                <div class="col-md-6 text-end">
                    <cfif isLoggedIn>
                        <span class="h5">Welcome, <cfoutput>#loggedInUser#</cfoutput>!</span>
                    <cfelse>
                        <span class="h5">Guest Access</span>
                    </cfif>
                </div>
            </div>
            
            <!--- Connection Status Information --->
            <cfif hasConnectionError>
                <div class="error-alert mt-3">
                    <h6><i class="bi bi-exclamation-triangle"></i> Database Connection Error</h6>
                    <p class="mb-0">Unable to connect to the database. Error: <cfoutput>#connectionError#</cfoutput></p>
                </div>
            <cfelse>
                <div class="alert alert-info mt-3 mb-0" role="alert">
                    <i class="bi bi-check-circle"></i> Connected using dynamic connection system
                    <a href="test_dynamic_connection_simple.cfm" class="btn btn-sm btn-outline-light ms-2">Connection Details</a>
                </div>
            </cfif>
        </div>
    </div>

    <!-- Main Content -->
    <div class="container my-4">
        <!-- Quick Stats Row -->
        <div class="row mb-4">
            <div class="col-md-3">
                <div class="card stat-card">
                    <div class="card-body text-center">
                        <h3 class="text-primary"><cfoutput>$#numberFormat(todaysTotal, "999,999.99")#</cfoutput></h3>
                        <p class="mb-0">Today's Sales</p>
                        <small class="text-muted">
                            <cfif todaysTotal >= todaysBudget>
                                <i class="bi bi-check-circle-fill text-success"></i> Budget Met!
                            <cfelse>
                                <cfoutput>$#numberFormat(todaysBudget - todaysTotal, "999,999.99")# to goal</cfoutput>
                            </cfif>
                        </small>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card stat-card">
                    <div class="card-body text-center">
                        <h3 class="text-success"><cfoutput>$#numberFormat(weeklyTotal, "999,999.99")#</cfoutput></h3>
                        <p class="mb-0">This Week</p>
                        <small class="text-muted"><cfoutput>#dateFormat(startOfWeek, "m/d")# - #dateFormat(endOfWeek, "m/d")#</cfoutput></small>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card stat-card">
                    <div class="card-body text-center">
                        <h3 class="text-info"><cfoutput>#todaysSales.recordCount#</cfoutput></h3>
                        <p class="mb-0">Today's Transactions</p>
                        <small class="text-muted">Individual sales logged</small>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card stat-card">
                    <div class="card-body text-center">
                        <h3 class="text-warning"><cfoutput>#employeeStats.recordCount#</cfoutput></h3>
                        <p class="mb-0">Active Employees</p>
                        <small class="text-muted">Contributing to sales</small>
                    </div>
                </div>
            </div>
        </div>

        <div class="row">
            <!-- Employee Leaderboard -->
            <div class="col-lg-6 mb-4">
                <div class="card h-100">
                    <div class="card-header">
                        <div class="d-flex justify-content-between align-items-center">
                            <h5 class="mb-0"><i class="bi bi-trophy"></i> Employee Leaderboard</h5>
                            <small class="text-muted"><cfoutput>#leaderboardTitle#</cfoutput></small>
                        </div>
                        <div class="leaderboard-filter">
                            <a href="?period=week" class="btn btn-sm filter-btn <cfif leaderboardPeriod EQ 'week'>btn-primary<cfelse>btn-outline-primary</cfif>">This Week</a>
                            <a href="?period=month" class="btn btn-sm filter-btn <cfif leaderboardPeriod EQ 'month'>btn-primary<cfelse>btn-outline-primary</cfif>">This Month</a>
                            <a href="?period=alltime" class="btn btn-sm filter-btn <cfif leaderboardPeriod EQ 'alltime'>btn-primary<cfelse>btn-outline-primary</cfif>">All Time</a>
                        </div>
                    </div>
                    <div class="card-body">
                        <cfif employeeStats.recordCount GT 0>
                            <cfloop query="employeeStats">
                                <div class="leaderboard-item">
                                    <div class="d-flex justify-content-between align-items-center">
                                        <div>
                                            <cfif currentRow LTE 3>
                                                <cfif currentRow EQ 1><i class="bi bi-trophy-fill text-warning"></i>
                                                <cfelseif currentRow EQ 2><i class="bi bi-award-fill text-secondary"></i>
                                                <cfelse><i class="bi bi-award text-info"></i></cfif>
                                            <cfelse>
                                                <span class="badge bg-light text-dark">#currentRow#</span>
                                            </cfif>
                                            <strong><cfoutput>#firstName# #lastName#</cfoutput></strong>
                                        </div>
                                        <div class="text-end">
                                            <div><strong><cfoutput>$#numberFormat(hourlySalesRate, "999.99")#/hr</cfoutput></strong></div>
                                            <small class="text-muted">
                                                <cfoutput>$#numberFormat(totalSales, "999,999.99")# total (#numberFormat(totalHours, "999.9")#h)</cfoutput>
                                            </small>
                                        </div>
                                    </div>
                                </div>
                            </cfloop>
                        <cfelse>
                            <div class="text-center text-muted">
                                <i class="bi bi-people display-4"></i>
                                <p>No employee data available for the selected period.</p>
                            </div>
                        </cfif>
                    </div>
                </div>
            </div>

            <!-- Weekly Sales Breakdown -->
            <div class="col-lg-6 mb-4">
                <div class="card h-100">
                    <div class="card-header">
                        <h5 class="mb-0"><i class="bi bi-calendar-week"></i> Weekly Sales Breakdown</h5>
                        <small class="text-muted">Detailed daily analysis</small>
                    </div>
                    <div class="card-body">
                        <cfloop from="1" to="7" index="i">
                            <cfset currentDay = dateAdd("d", i-1, startOfWeek)>
                            <cfset dayKey = dateFormat(currentDay, "yyyy-mm-dd")>
                            <cfset isToday = dateFormat(currentDay, "yyyy-mm-dd") EQ dateFormat(now(), "yyyy-mm-dd")>
                            
                            <div class="card weekly-day-card mb-2 <cfif isToday>today-highlight</cfif>">
                                <div class="card-body py-2">
                                    <div class="row align-items-center">
                                        <div class="col-3">
                                            <strong><cfoutput>#dailySales[dayKey].dayName#</cfoutput></strong>
                                            <cfif isToday><br><small class="text-primary"><strong>TODAY</strong></small></cfif>
                                            <br><small class="text-muted"><cfoutput>#dateFormat(currentDay, "m/d")#</cfoutput></small>
                                        </div>
                                        <div class="col-3 text-center">
                                            <span class="badge bg-info"><cfoutput>#dailySales[dayKey].count#</cfoutput> sales</span>
                                        </div>
                                        <div class="col-3 text-end">
                                            <strong><cfoutput>$#numberFormat(dailySales[dayKey].total, "999,999.99")#</cfoutput></strong>
                                        </div>
                                        <div class="col-3">
                                            <cfif arrayLen(dailySales[dayKey].sales) GT 0>
                                                <button class="btn btn-sm btn-outline-primary" type="button" data-bs-toggle="collapse" data-bs-target="#day-<cfoutput>#i#</cfoutput>-details">
                                                    <i class="bi bi-chevron-down"></i>
                                                </button>
                                            </cfif>
                                        </div>
                                    </div>
                                    
                                    <cfif arrayLen(dailySales[dayKey].sales) GT 0>
                                        <div class="collapse mt-2" id="day-<cfoutput>#i#</cfoutput>-details">
                                            <div class="sales-detail">
                                                <cfloop from="1" to="#arrayLen(dailySales[dayKey].sales)#" index="j">
                                                    <cfset sale = dailySales[dayKey].sales[j]>
                                                    <div class="sale-item">
                                                        <cfoutput>
                                                        <strong>#sale.firstName# #sale.lastName#</strong> - 
                                                        $#numberFormat(sale.saleAmount, "999.99")# 
                                                        (#numberFormat(sale.hours, "999.9")#h)
                                                        <cfif len(sale.notes)><br><small class="text-muted">#sale.notes#</small></cfif>
                                                        </cfoutput>
                                                    </div>
                                                </cfloop>
                                            </div>
                                        </div>
                                    </cfif>
                                </div>
                            </div>
                        </cfloop>
                        
                        <!-- Weekly Total Summary -->
                        <div class="card bg-primary text-white mt-3">
                            <div class="card-body py-2">
                                <div class="d-flex justify-content-between align-items-center">
                                    <strong>Weekly Total:</strong>
                                    <strong><cfoutput>$#numberFormat(weeklyTotal, "999,999.99")#</cfoutput></strong>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Login Form (if not logged in) -->
        <cfif NOT isLoggedIn>
            <div class="row mt-4">
                <div class="col-md-6 mx-auto">
                    <div class="card">
                        <div class="card-header">
                            <h5 class="mb-0"><i class="bi bi-person-lock"></i> Employee Login</h5>
                        </div>
                        <div class="card-body">
                            <cfif isDefined("loginError")>
                                <div class="alert alert-danger">
                                    <cfoutput>#loginError#</cfoutput>
                                </div>
                            </cfif>
                            
                            <form method="post">
                                <input type="hidden" name="action" value="login">
                                <div class="mb-3">
                                    <label for="username" class="form-label">Username</label>
                                    <input type="text" class="form-control" id="username" name="username" required>
                                </div>
                                <div class="mb-3">
                                    <label for="password" class="form-label">Password</label>
                                    <input type="password" class="form-control" id="password" name="password" required>
                                </div>
                                <button type="submit" class="btn btn-primary w-100">Login</button>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </cfif>

        <!-- Additional Navigation -->
        <div class="row mt-4">
            <div class="col-12 text-center">
                <div class="btn-group" role="group">
                    <a href="employee_profile.cfm" class="btn btn-outline-primary">
                        <i class="bi bi-person-circle"></i> View Employees
                    </a>
                    <a href="admin_data.cfm" class="btn btn-outline-secondary">
                        <i class="bi bi-gear"></i> Admin Panel
                    </a>
                    <a href="test_dynamic_connection_simple.cfm" class="btn btn-outline-info">
                        <i class="bi bi-plugin"></i> Test Connections
                    </a>
                    <a href="remote_dsn_test.cfm" class="btn btn-outline-success">
                        <i class="bi bi-cloud-check"></i> Remote DSN Test
                    </a>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
