<cfcomponent displayname="Database Service" hint="Handles database operations using dynamic connection">
    
    <cffunction name="init" access="public" returntype="DatabaseService" hint="Constructor">
        <!--- Use application-scoped dbConfig if available, otherwise create new instance --->
        <cfif structKeyExists(application, "dbConfig")>
            <cfset variables.dbConfig = application.dbConfig>
        <cfelse>
            <cfset variables.dbConfig = createObject("component", "DatabaseConfig").init()>
        </cfif>
        <cfreturn this>
    </cffunction>
    
    <cffunction name="getTodaysSales" access="public" returntype="numeric" hint="Get today's total sales">
        <cfset var sql = "
            SELECT ISNULL(SUM(amount), 0) as total_sales 
            FROM sales 
            WHERE CAST(sale_date AS DATE) = CAST(GETDATE() AS DATE)
        ">
        
        <cftry>
            <cfset var result = variables.dbConfig.executeQuery(sql)>
            <cfreturn result.total_sales>
            
            <cfcatch type="any">
                <cflog file="database_service" text="getTodaysSales error: #cfcatch.message#" type="error">
                <cfreturn 0>
            </cfcatch>
        </cftry>
    </cffunction>
    
    <cffunction name="getEmployeeLeaderboard" access="public" returntype="query" hint="Get employee leaderboard with time filter">
        <cfargument name="timeFilter" type="string" required="false" default="all">
        
        <cfset var whereClause = "">
        <cfswitch expression="#arguments.timeFilter#">
            <cfcase value="week">
                <cfset whereClause = "AND sale_date >= DATEADD(day, -7, GETDATE())">
            </cfcase>
            <cfcase value="month">
                <cfset whereClause = "AND sale_date >= DATEADD(month, -1, GETDATE())">
            </cfcase>
            <cfdefaultcase>
                <cfset whereClause = "">
            </cfdefaultcase>
        </cfswitch>
        
        <cfset var sql = "
            SELECT 
                e.name,
                COUNT(s.id) as total_sales,
                ISNULL(SUM(s.amount), 0) as total_amount
            FROM employees e
            LEFT JOIN sales s ON e.id = s.employee_id #whereClause#
            GROUP BY e.id, e.name
            ORDER BY total_amount DESC
        ">
        
        <cftry>
            <cfreturn variables.dbConfig.executeQuery(sql)>
            
            <cfcatch type="any">
                <cflog file="database_service" text="getEmployeeLeaderboard error: #cfcatch.message#" type="error">
                <!--- Return empty query on error --->
                <cfset var emptyQuery = queryNew("name,total_sales,total_amount", "varchar,integer,decimal")>
                <cfreturn emptyQuery>
            </cfcatch>
        </cftry>
    </cffunction>
    
    <cffunction name="getWeeklySales" access="public" returntype="query" hint="Get detailed weekly sales breakdown">
        <cfset var sql = "
            SELECT 
                DATENAME(weekday, sale_date) as day_name,
                CAST(sale_date AS DATE) as sale_date,
                COUNT(*) as transaction_count,
                ISNULL(SUM(amount), 0) as daily_total
            FROM sales 
            WHERE sale_date >= DATEADD(day, -7, GETDATE())
            GROUP BY CAST(sale_date AS DATE), DATENAME(weekday, sale_date), DATEPART(weekday, sale_date)
            ORDER BY CAST(sale_date AS DATE) DESC
        ">
        
        <cftry>
            <cfreturn variables.dbConfig.executeQuery(sql)>
            
            <cfcatch type="any">
                <cflog file="database_service" text="getWeeklySales error: #cfcatch.message#" type="error">
                <!--- Return empty query on error --->
                <cfset var emptyQuery = queryNew("day_name,sale_date,transaction_count,daily_total", "varchar,date,integer,decimal")>
                <cfreturn emptyQuery>
            </cfcatch>
        </cftry>
    </cffunction>
    
    <!--- Additional method to get basic stats for dashboard --->
    <cffunction name="getDashboardStats" access="public" returntype="struct" hint="Get comprehensive dashboard statistics">
        <cfset var stats = {
            todaysSales = 0,
            totalEmployees = 0,
            weeklyTotal = 0,
            monthlyTotal = 0
        }>
        
        <cftry>
            <!--- Today's sales --->
            <cfset stats.todaysSales = getTodaysSales()>
            
            <!--- Total employees --->
            <cfset var empQuery = variables.dbConfig.executeQuery("SELECT COUNT(*) as emp_count FROM employees")>
            <cfset stats.totalEmployees = empQuery.emp_count>
            
            <!--- Weekly total --->
            <cfset var weeklyQuery = variables.dbConfig.executeQuery("
                SELECT ISNULL(SUM(amount), 0) as weekly_total 
                FROM sales 
                WHERE sale_date >= DATEADD(day, -7, GETDATE())
            ")>
            <cfset stats.weeklyTotal = weeklyQuery.weekly_total>
            
            <!--- Monthly total --->
            <cfset var monthlyQuery = variables.dbConfig.executeQuery("
                SELECT ISNULL(SUM(amount), 0) as monthly_total 
                FROM sales 
                WHERE sale_date >= DATEADD(month, -1, GETDATE())
            ")>
            <cfset stats.monthlyTotal = monthlyQuery.monthly_total>
            
            <cfcatch type="any">
                <cflog file="database_service" text="getDashboardStats error: #cfcatch.message#" type="error">
                <!--- Return default stats on error --->
            </cfcatch>
        </cftry>
        
        <cfreturn stats>
    </cffunction>
    
    <!--- Legacy method for compatibility --->
    <cffunction name="query" access="public" returntype="query" hint="Execute a simple query with dynamic connection">
        <cfargument name="sql" type="string" required="true">
        <cfargument name="params" type="struct" required="false" default="#structNew()#">
        
        <cfreturn variables.dbConfig.executeQuery(arguments.sql, arguments.params)>
    </cffunction>
    
</cfcomponent>
