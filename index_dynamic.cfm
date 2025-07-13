<!--- Calico Knotts Sales Dashboard - Enhanced with Dynamic Database Connection --->
<cfset pageTitle = "Calico Knotts Sales Dashboard">

<!--- Initialize the database service --->
<cftry>
    <cfset dbService = createObject("component", "components.DatabaseService").init()>
    <cfset dashboardStats = dbService.getDashboardStats()>
    <cfset hasConnectionError = false>
    
    <cfcatch type="any">
        <cfset hasConnectionError = true>
        <cfset connectionError = cfcatch.message>
        <!--- Set default values for display --->
        <cfset dashboardStats = {
            todaysSales = 0,
            totalEmployees = 0,
            weeklyTotal = 0,
            monthlyTotal = 0
        }>
    </cfcatch>
</cftry>

<!--- Handle time filter for leaderboard --->
<cfparam name="url.timeFilter" default="all">
<cfset validFilters = "all,week,month">
<cfif NOT listFindNoCase(validFilters, url.timeFilter)>
    <cfset url.timeFilter = "all">
</cfif>

<!--- Get employee leaderboard with time filter --->
<cfif NOT hasConnectionError>
    <cftry>
        <cfset employeeLeaderboard = dbService.getEmployeeLeaderboard(url.timeFilter)>
        <cfset weeklySalesData = dbService.getWeeklySales()>
        
        <cfcatch type="any">
            <cfset hasQueryError = true>
            <cfset queryError = cfcatch.message>
            <!--- Create empty queries for display --->
            <cfset employeeLeaderboard = queryNew("name,total_sales,total_amount", "varchar,integer,decimal")>
            <cfset weeklySalesData = queryNew("day_name,sale_date,transaction_count,daily_total", "varchar,date,integer,decimal")>
        </cfcatch>
    </cftry>
<cfelse>
    <!--- Create empty queries when there's a connection error --->
    <cfset employeeLeaderboard = queryNew("name,total_sales,total_amount", "varchar,integer,decimal")>
    <cfset weeklySalesData = queryNew("day_name,sale_date,transaction_count,daily_total", "varchar,date,integer,decimal")>
</cfif>

<!DOCTYPE html>
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
