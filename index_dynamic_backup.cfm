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
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><cfoutput>#pageTitle#</cfoutput></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link rel="stylesheet" href="assets/css/main.css">
    <style>
        .stat-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 15px;
            padding: 1.5rem;
            margin-bottom: 1rem;
            box-shadow: 0 8px 25px rgba(0,0,0,0.1);
            transition: transform 0.3s ease;
        }
        .stat-card:hover {
            transform: translateY(-5px);
        }
        .stat-number {
            font-size: 2.5rem;
            font-weight: bold;
            margin-bottom: 0.5rem;
        }
        .filter-buttons .btn {
            margin-right: 0.5rem;
            margin-bottom: 0.5rem;
        }
        .daily-entry {
            background-color: #f8f9fa;
            border-left: 4px solid #007bff;
            padding: 0.75rem;
            margin-bottom: 0.5rem;
            border-radius: 0.25rem;
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
<body class="bg-light">
    <div class="container-fluid mt-4">
        <cfoutput>
        <div class="row">
            <div class="col-12">
                <h1 class="text-center mb-4">
                    <i class="bi bi-graph-up-arrow"></i> #pageTitle#
                </h1>
                
                <!--- Connection Status Information --->
                <cfif hasConnectionError>
                    <div class="error-alert">
                        <h5><i class="bi bi-exclamation-triangle"></i> Database Connection Error</h5>
                        <p>Unable to connect to the database. Error: #connectionError#</p>
                        <p><a href="test_dynamic_connection_simple.cfm" class="btn btn-sm btn-primary">Test Connection</a></p>
                    </div>
                <cfelse>
                    <div class="alert alert-success" role="alert">
                        <i class="bi bi-check-circle"></i> Connected to database using dynamic connection system
                        <a href="test_dynamic_connection_simple.cfm" class="btn btn-sm btn-outline-success ms-2">View Connection Details</a>
                    </div>
                </cfif>
                
                <!--- Dashboard Statistics --->
                <div class="row mb-4">
                    <div class="col-md-3">
                        <div class="stat-card">
                            <div class="stat-number">$#numberFormat(dashboardStats.todaysSales, "999,999.99")#</div>
                            <div class="stat-label">Today's Sales</div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card">
                            <div class="stat-number">$#numberFormat(dashboardStats.weeklyTotal, "999,999.99")#</div>
                            <div class="stat-label">This Week</div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card">
                            <div class="stat-number">$#numberFormat(dashboardStats.monthlyTotal, "999,999.99")#</div>
                            <div class="stat-label">This Month</div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card">
                            <div class="stat-number">#dashboardStats.totalEmployees#</div>
                            <div class="stat-label">Total Employees</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="row">
            <!--- Employee Leaderboard --->
            <div class="col-md-6">
                <div class="card h-100">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <h5 class="mb-0"><i class="bi bi-trophy"></i> Employee Leaderboard</h5>
                        <div class="filter-buttons">
                            <a href="?timeFilter=week" class="btn btn-sm #url.timeFilter eq 'week' ? 'btn-primary' : 'btn-outline-primary'#">This Week</a>
                            <a href="?timeFilter=month" class="btn btn-sm #url.timeFilter eq 'month' ? 'btn-primary' : 'btn-outline-primary'#">This Month</a>
                            <a href="?timeFilter=all" class="btn btn-sm #url.timeFilter eq 'all' ? 'btn-primary' : 'btn-outline-primary'#">All Time</a>
                        </div>
                    </div>
                    <div class="card-body">
                        <cfif employeeLeaderboard.recordCount GT 0>
                            <div class="table-responsive">
                                <table class="table table-hover">
                                    <thead>
                                        <tr>
                                            <th>Rank</th>
                                            <th>Employee</th>
                                            <th>Sales</th>
                                            <th>Total</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <cfloop query="employeeLeaderboard">
                                            <tr>
                                                <td>
                                                    <cfif currentRow eq 1>
                                                        <i class="bi bi-trophy-fill text-warning"></i>
                                                    <cfelseif currentRow eq 2>
                                                        <i class="bi bi-award-fill text-secondary"></i>
                                                    <cfelseif currentRow eq 3>
                                                        <i class="bi bi-award text-info"></i>
                                                    <cfelse>
                                                        #currentRow#
                                                    </cfif>
                                                </td>
                                                <td>#name#</td>
                                                <td><span class="badge bg-primary">#total_sales#</span></td>
                                                <td><strong>$#numberFormat(total_amount, "999,999.99")#</strong></td>
                                            </tr>
                                        </cfloop>
                                    </tbody>
                                </table>
                            </div>
                        <cfelse>
                            <div class="text-center text-muted">
                                <i class="bi bi-inbox display-4"></i>
                                <p>No sales data available for the selected time period.</p>
                            </div>
                        </cfif>
                    </div>
                </div>
            </div>
            
            <!--- Weekly Sales Breakdown --->
            <div class="col-md-6">
                <div class="card h-100">
                    <div class="card-header">
                        <h5 class="mb-0"><i class="bi bi-calendar-week"></i> Weekly Sales Breakdown</h5>
                    </div>
                    <div class="card-body">
                        <cfif weeklySalesData.recordCount GT 0>
                            <cfloop query="weeklySalesData">
                                <div class="daily-entry">
                                    <div class="row align-items-center">
                                        <div class="col-md-4">
                                            <strong>#day_name#</strong><br>
                                            <small class="text-muted">#dateFormat(sale_date, "mm/dd/yyyy")#</small>
                                        </div>
                                        <div class="col-md-4 text-center">
                                            <span class="badge bg-info">#transaction_count# sales</span>
                                        </div>
                                        <div class="col-md-4 text-end">
                                            <strong>$#numberFormat(daily_total, "999,999.99")#</strong>
                                        </div>
                                    </div>
                                </div>
                            </cfloop>
                            
                            <!--- Weekly Total --->
                            <div class="mt-3 p-3 bg-primary text-white rounded">
                                <div class="row">
                                    <div class="col-6">
                                        <strong>Weekly Total:</strong>
                                    </div>
                                    <div class="col-6 text-end">
                                        <strong>$#numberFormat(dashboardStats.weeklyTotal, "999,999.99")#</strong>
                                    </div>
                                </div>
                            </div>
                        <cfelse>
                            <div class="text-center text-muted">
                                <i class="bi bi-calendar-x display-4"></i>
                                <p>No sales data available for the past week.</p>
                            </div>
                        </cfif>
                    </div>
                </div>
            </div>
        </div>
        
        <!--- Additional Actions --->
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
        </cfoutput>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="assets/js/main.js"></script>
</body>
</html>
