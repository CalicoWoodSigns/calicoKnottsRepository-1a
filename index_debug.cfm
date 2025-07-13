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
    <title>Index Debug - Real-time Error Tracking</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-5">
        <h1>Index.cfm Debug - Step by Step</h1>
        
        <div class="alert alert-info">
            <h5>Environment Info:</h5>
            <cfoutput>
                <p><strong>Is Remote:</strong> #dbInfo.isRemote#</p>
                <p><strong>Connection Type:</strong> #dbInfo.connectionType#</p>
                <p><strong>Datasource:</strong> #dbInfo.datasourceName#</p>
            </cfoutput>
        </div>

        <!--- Test 1: Today's Sales Query --->
        <div class="card mb-4">
            <div class="card-header">
                <h5>Step 1: Today's Sales Query</h5>
            </div>
            <div class="card-body">
                <cftry>
                    <cfif dbInfo.isRemote>
                        <cfquery name="todaysSales" 
                                 datasource="#dbInfo.datasourceName#"
                                 username="#dbConfig.getAzureConfig().username#"
                                 password="#dbConfig.getAzureConfig().password#">
                            SELECT saleID, EID, firstName, lastName, saleDate, hours, saleAmount, notes
                            FROM employeeSales 
                            WHERE CAST(saleDate AS DATE) = CAST(GETDATE() AS DATE)
                            ORDER BY saleDate DESC
                        </cfquery>
                    <cfelse>
                        <cfset todaysSales = dbConfig.executeQuery("
                            SELECT saleID, EID, firstName, lastName, saleDate, hours, saleAmount, notes
                            FROM employeeSales 
                            WHERE CAST(saleDate AS DATE) = CAST(GETDATE() AS DATE)
                            ORDER BY saleDate DESC
                        ")>
                    </cfif>
                    
                    <div class="alert alert-success">
                        <strong>SUCCESS:</strong> Today's sales query executed
                        <p>Records found: <cfoutput>#todaysSales.recordCount#</cfoutput></p>
                        
                        <!--- Calculate today's total --->
                        <cfset todaysTotal = 0>
                        <cfloop query="todaysSales">
                            <cfset todaysTotal = todaysTotal + todaysSales.saleAmount>
                        </cfloop>
                        <p><strong>Today's Total:</strong> $<cfoutput>#numberFormat(todaysTotal, "0.00")#</cfoutput></p>
                    </div>
                    
                    <cfcatch type="any">
                        <div class="alert alert-danger">
                            <strong>ERROR in Today's Sales:</strong>
                            <p><strong>Message:</strong> <cfoutput>#cfcatch.message#</cfoutput></p>
                            <p><strong>Detail:</strong> <cfoutput>#cfcatch.detail#</cfoutput></p>
                        </div>
                    </cfcatch>
                </cftry>
            </div>
        </div>

        <!--- Test 2: Week Date Calculation --->
        <div class="card mb-4">
            <div class="card-header">
                <h5>Step 2: Week Date Calculation</h5>
            </div>
            <div class="card-body">
                <cftry>
                    <!--- Get this week's date range (needed for leaderboard) --->
                    <!--- Calculate week starting from Monday (dayOfWeek: Sunday=1, Monday=2, ..., Saturday=7) --->
                    <cfset currentDayOfWeek = dayOfWeek(now())>
                    <cfset daysFromMonday = currentDayOfWeek - 2>
                    <cfif currentDayOfWeek EQ 1> <!--- If today is Sunday, go back 6 days to get to Monday --->
                        <cfset daysFromMonday = 6>
                    </cfif>
                    <cfset startOfWeek = dateAdd("d", -daysFromMonday, now())>
                    <cfset endOfWeek = dateAdd("d", 6, startOfWeek)>
                    
                    <div class="alert alert-success">
                        <strong>SUCCESS:</strong> Week dates calculated
                        <p><strong>Start of Week:</strong> <cfoutput>#dateFormat(startOfWeek, "mmm d, yyyy")#</cfoutput></p>
                        <p><strong>End of Week:</strong> <cfoutput>#dateFormat(endOfWeek, "mmm d, yyyy")#</cfoutput></p>
                    </div>
                    
                    <cfcatch type="any">
                        <div class="alert alert-danger">
                            <strong>ERROR in Week Calculation:</strong>
                            <p><strong>Message:</strong> <cfoutput>#cfcatch.message#</cfoutput></p>
                        </div>
                    </cfcatch>
                </cftry>
            </div>
        </div>

        <!--- Test 3: Leaderboard Period Logic --->
        <div class="card mb-4">
            <div class="card-header">
                <h5>Step 3: Leaderboard Period Logic</h5>
            </div>
            <div class="card-body">
                <cftry>
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
                    
                    <div class="alert alert-success">
                        <strong>SUCCESS:</strong> Leaderboard period set
                        <p><strong>Period:</strong> <cfoutput>#leaderboardPeriod#</cfoutput></p>
                        <p><strong>Title:</strong> <cfoutput>#leaderboardTitle#</cfoutput></p>
                        <p><strong>Start Date:</strong> <cfoutput>#dateFormat(leaderboardStartDate, "mmm d, yyyy")#</cfoutput></p>
                        <p><strong>End Date:</strong> <cfoutput>#dateFormat(leaderboardEndDate, "mmm d, yyyy")#</cfoutput></p>
                    </div>
                    
                    <cfcatch type="any">
                        <div class="alert alert-danger">
                            <strong>ERROR in Leaderboard Logic:</strong>
                            <p><strong>Message:</strong> <cfoutput>#cfcatch.message#</cfoutput></p>
                        </div>
                    </cfcatch>
                </cftry>
            </div>
        </div>

        <!--- Test 4: Employee Stats Query --->
        <div class="card mb-4">
            <div class="card-header">
                <h5>Step 4: Employee Stats Query</h5>
            </div>
            <div class="card-body">
                <cftry>
                    <!--- Employee leaderboard with time period filter --->
                    <cfif dbInfo.isRemote>
                        <cfquery name="employeeStats" 
                                 datasource="#dbInfo.datasourceName#"
                                 username="#dbConfig.getAzureConfig().username#"
                                 password="#dbConfig.getAzureConfig().password#">
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
                            <cfif leaderboardPeriod NEQ "alltime">
                                AND CAST(s.saleDate AS DATE) >= <cfqueryparam value="#dateFormat(leaderboardStartDate, 'yyyy-mm-dd')#" cfsqltype="cf_sql_date">
                                AND CAST(s.saleDate AS DATE) <= <cfqueryparam value="#dateFormat(leaderboardEndDate, 'yyyy-mm-dd')#" cfsqltype="cf_sql_date">
                            </cfif>
                            GROUP BY e.EID, e.firstName, e.lastName
                            ORDER BY hourlySalesRate DESC
                        </cfquery>
                    <cfelse>
                        <cfset employeeStats = dbConfig.executeQuery("
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
                    </cfif>
                    
                    <div class="alert alert-success">
                        <strong>SUCCESS:</strong> Employee stats query executed
                        <p><strong>Records found:</strong> <cfoutput>#employeeStats.recordCount#</cfoutput></p>
                        
                        <cfif employeeStats.recordCount GT 0>
                            <div class="table-responsive mt-3">
                                <table class="table table-sm">
                                    <thead>
                                        <tr>
                                            <th>EID</th>
                                            <th>Name</th>
                                            <th>Total Sales</th>
                                            <th>Total Hours</th>
                                            <th>Hourly Rate</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <cfloop query="employeeStats">
                                            <tr>
                                                <td><cfoutput>#employeeStats.EID#</cfoutput></td>
                                                <td><cfoutput>#employeeStats.firstName# #employeeStats.lastName#</cfoutput></td>
                                                <td>$<cfoutput>#numberFormat(employeeStats.totalSales, "0.00")#</cfoutput></td>
                                                <td><cfoutput>#employeeStats.totalHours#</cfoutput></td>
                                                <td>$<cfoutput>#numberFormat(employeeStats.hourlySalesRate, "0.00")#</cfoutput>/hr</td>
                                            </tr>
                                        </cfloop>
                                    </tbody>
                                </table>
                            </div>
                        </cfif>
                    </div>
                    
                    <cfcatch type="any">
                        <div class="alert alert-danger">
                            <strong>ERROR in Employee Stats:</strong>
                            <p><strong>Message:</strong> <cfoutput>#cfcatch.message#</cfoutput></p>
                            <p><strong>Detail:</strong> <cfoutput>#cfcatch.detail#</cfoutput></p>
                        </div>
                    </cfcatch>
                </cftry>
            </div>
        </div>

        <!--- Test 5: Weekly Sales Query --->
        <div class="card mb-4">
            <div class="card-header">
                <h5>Step 5: Weekly Sales Query</h5>
            </div>
            <div class="card-body">
                <cftry>
                    <!--- Get this week's sales by day --->
                    <cfif dbInfo.isRemote>
                        <cfquery name="weeklySales" 
                                 datasource="#dbInfo.datasourceName#"
                                 username="#dbConfig.getAzureConfig().username#"
                                 password="#dbConfig.getAzureConfig().password#">
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
                    <cfelse>
                        <cfset weeklySales = dbConfig.executeQuery("
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
                    </cfif>
                    
                    <div class="alert alert-success">
                        <strong>SUCCESS:</strong> Weekly sales query executed
                        <p><strong>Records found:</strong> <cfoutput>#weeklySales.recordCount#</cfoutput></p>
                        
                        <cfif weeklySales.recordCount GT 0>
                            <div class="table-responsive mt-3">
                                <table class="table table-sm">
                                    <thead>
                                        <tr>
                                            <th>Date</th>
                                            <th>Day Total</th>
                                            <th>Sale Count</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <cfloop query="weeklySales">
                                            <tr>
                                                <td><cfoutput>#dateFormat(weeklySales.saleDay, "mm/dd/yyyy")#</cfoutput></td>
                                                <td>$<cfoutput>#numberFormat(weeklySales.dayTotal, "0.00")#</cfoutput></td>
                                                <td><cfoutput>#weeklySales.saleCount#</cfoutput></td>
                                            </tr>
                                        </cfloop>
                                    </tbody>
                                </table>
                            </div>
                        </cfif>
                    </div>
                    
                    <cfcatch type="any">
                        <div class="alert alert-danger">
                            <strong>ERROR in Weekly Sales:</strong>
                            <p><strong>Message:</strong> <cfoutput>#cfcatch.message#</cfoutput></p>
                            <p><strong>Detail:</strong> <cfoutput>#cfcatch.detail#</cfoutput></p>
                        </div>
                    </cfcatch>
                </cftry>
            </div>
        </div>

        <div class="mt-4">
            <a href="index.cfm" class="btn btn-primary">Back to Dashboard</a>
            <a href="table_access_test.cfm" class="btn btn-secondary">Table Access Test</a>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
