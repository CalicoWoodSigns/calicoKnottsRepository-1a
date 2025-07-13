component displayname="Database Service" hint="Simplified database operations using dynamic connection" {
    
    /**
     * Constructor
     */
    public DatabaseService function init() {
        // Get the database configuration from application scope
        if (structKeyExists(application, "dbConfig") && isObject(application.dbConfig)) {
            variables.dbConfig = application.dbConfig;
        } else {
            // Create new instance if not available in application
            variables.dbConfig = new DatabaseConfig();
        }
        
        return this;
    }
    
    /**
     * Execute a simple query with dynamic connection
     */
    public query function query(required string sql, struct params = {}) {
        return variables.dbConfig.executeQuery(arguments.sql, arguments.params);
    }
                qry.addParam(
                    name = param,
                    value = arguments.params[param],
                    cfsqltype = "cf_sql_varchar" // Default type, should be dynamic
                );
            }
            
            return qry.execute().getResult();
        } catch (any e) {
            // Log the error
            writeLog(
                text = "Database error: #e.message# - SQL: #arguments.sql#",
                type = "error",
                file = "calicoknotts_database"
            );
            
            // Return empty query
            return queryNew("");
        }
    }
    
    /**
     * Gets all employees from the database
     * @return Query of employees
     */
    public query function getEmployees() {
        try {
            var qry = new Query();
            qry.setSQL("SELECT EID, userName, firstName, lastName, password, accessLevel, address1, city, state, phone FROM employeeInfo ORDER BY lastName, firstName");
            qry.setDatasource("calicoknotts_db");
            return qry.execute().getResult();
        } catch (any e) {
            writeLog(
                text = "Error getting employees: #e.message#",
                type = "error",
                file = "calicoknotts_database"
            );
            return queryNew("EID,userName,firstName,lastName,password,accessLevel,address1,city,state,phone");
        }
    }
    
    /**
     * Gets all sales from the database with employee names
     * @return Query of sales
     */
    public query function getSales() {
        try {
            var qry = new Query();
            qry.setSQL("SELECT saleID, EID, firstName, lastName, saleDate, hours, saleAmount, notes FROM employeeSales ORDER BY saleDate DESC");
            qry.setDatasource("calicoknotts_db");
            return qry.execute().getResult();
        } catch (any e) {
            writeLog(
                text = "Error getting sales: #e.message#",
                type = "error",
                file = "calicoknotts_database"
            );
            return queryNew("saleID,EID,firstName,lastName,saleDate,hours,saleAmount,notes");
        }
    }
    
    /**
     * Adds a new sale record
     * @param employeeID Employee ID
     * @param saleAmount Sale amount
     * @param hours Hours worked
     * @param notes Optional notes
     * @return Boolean success
     */
    public boolean function addSale(required numeric employeeID, required numeric saleAmount, required numeric hours, string notes = "") {
        try {
            // Get employee info first
            var empQry = new Query();
            empQry.setSQL("SELECT firstName, lastName FROM employeeInfo WHERE EID = ?");
            empQry.addParam(value=arguments.employeeID, cfsqltype="cf_sql_integer");
            empQry.setDatasource("calicoknotts_db");
            var employee = empQry.execute().getResult();
            
            if (employee.recordCount eq 0) {
                return false;
            }
            
            // Insert the sale
            var qry = new Query();
            qry.setSQL("INSERT INTO employeeSales (EID, firstName, lastName, saleDate, hours, saleAmount, notes) VALUES (?, ?, ?, GETDATE(), ?, ?, ?)");
            qry.addParam(value=arguments.employeeID, cfsqltype="cf_sql_integer");
            qry.addParam(value=employee.firstName, cfsqltype="cf_sql_varchar");
            qry.addParam(value=employee.lastName, cfsqltype="cf_sql_varchar");
            qry.addParam(value=arguments.hours, cfsqltype="cf_sql_decimal");
            qry.addParam(value=arguments.saleAmount, cfsqltype="cf_sql_decimal");
            qry.addParam(value=arguments.notes, cfsqltype="cf_sql_varchar");
            qry.setDatasource("calicoknotts_db");
            qry.execute();
            
            return true;
        } catch (any e) {
            writeLog(
                text = "Error adding sale: #e.message#",
                type = "error",
                file = "calicoknotts_database"
            );
            return false;
        }
    }

    /**
     * Gets application settings from database or config
     * @return Struct of settings
     */
    public struct function getSettings() {
        // This would typically query a settings table
        // For now, returning default settings
        return {
            "siteName" = "Calico Knotts Wood Signs",
            "siteDescription" = "Custom wood signs and crafts",
            "contactEmail" = "info@calicoknotts.com",
            "phone" = "(555) 123-4567",
            "address" = "123 Workshop Lane, Craftsville, ST 12345"
        };
    }
    
    /**
     * Sample method to get products (placeholder)
     * @return Query of products
     */
    public query function getProducts() {
        // This is a placeholder - would typically query a products table
        var products = queryNew("id,name,price,description", "integer,varchar,decimal,varchar", [
            [1, "Custom House Sign", 45.00, "Personalized wooden house sign"],
            [2, "Wedding Sign", 65.00, "Beautiful wedding ceremony sign"],
            [3, "Business Sign", 125.00, "Professional business signage"]
        ]);
        
        return products;
    }
    
    /**
     * Sample method to get a single product by ID
     * @param productId Product ID
     * @return Query with single product
     */
    public query function getProduct(required numeric productId) {
        var products = getProducts();
        var result = queryNew(products.columnList);
        
        for (var row = 1; row <= products.recordCount; row++) {
            if (products.id[row] == arguments.productId) {
                queryAddRow(result);
                for (var col in listToArray(products.columnList)) {
                    querySetCell(result, col, products[col][row]);
                }
                break;
            }
        }
        
        return result;
    }
    
    /**
     * Get today's sales
     */
    public query function getTodaysSales() {
        var sql = "
            SELECT saleID, EID, firstName, lastName, saleDate, hours, saleAmount, notes
            FROM employeeSales 
            WHERE CAST(saleDate AS DATE) = CAST(GETDATE() AS DATE)
            ORDER BY saleDate DESC
        ";
        return query(sql);
    }
    
    /**
     * Get employee leaderboard with time period filter
     */
    public query function getEmployeeLeaderboard(string period = "week", date startDate = "", date endDate = "") {
        var sql = "
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
        ";
        
        var params = {};
        
        if (arguments.period NEQ "alltime" && isDate(arguments.startDate) && isDate(arguments.endDate)) {
            sql &= " AND CAST(s.saleDate AS DATE) >= ? AND CAST(s.saleDate AS DATE) <= ?";
            params["startDate"] = {value=arguments.startDate, sqltype="cf_sql_date"};
            params["endDate"] = {value=arguments.endDate, sqltype="cf_sql_date"};
        }
        
        sql &= " GROUP BY e.EID, e.firstName, e.lastName ORDER BY hourlySalesRate DESC";
        
        return query(sql, params);
    }
    
    /**
     * Get weekly sales by day
     */
    public query function getWeeklySales(required date startDate, required date endDate) {
        var sql = "
            SELECT 
                CAST(saleDate AS DATE) as saleDay,
                SUM(saleAmount) as dayTotal,
                COUNT(*) as saleCount
            FROM employeeSales 
            WHERE CAST(saleDate AS DATE) >= ? AND CAST(saleDate AS DATE) <= ?
            GROUP BY CAST(saleDate AS DATE)
            ORDER BY CAST(saleDate AS DATE)
        ";
        
        var params = {
            startDate = {value=arguments.startDate, sqltype="cf_sql_date"},
            endDate = {value=arguments.endDate, sqltype="cf_sql_date"}
        };
        
        return query(sql, params);
    }
    
    /**
     * Get detailed weekly sales data
     */
    public query function getWeeklyDetailedSales(required date startDate, required date endDate) {
        var sql = "
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
            WHERE CAST(saleDate AS DATE) >= ? AND CAST(saleDate AS DATE) <= ?
            ORDER BY CAST(saleDate AS DATE), saleDate
        ";
        
        var params = {
            startDate = {value=arguments.startDate, sqltype="cf_sql_date"},
            endDate = {value=arguments.endDate, sqltype="cf_sql_date"}
        };
        
        return query(sql, params);
    }
    
    /**
     * Verify user login
     */
    public query function verifyLogin(required string username, required string password) {
        var sql = "
            SELECT EID, firstName, lastName, userName, accessLevel
            FROM employeeInfo 
            WHERE userName = ? AND password = ?
        ";
        
        var params = {
            username = {value=arguments.username, sqltype="cf_sql_varchar"},
            password = {value=arguments.password, sqltype="cf_sql_varchar"}
        };
        
        return query(sql, params);
    }
    
    /**
     * Get connection info for debugging
     */
    public struct function getConnectionInfo() {
        if (structKeyExists(variables, "dbConfig") && isObject(variables.dbConfig)) {
            return variables.dbConfig.getEnvironmentInfo();
        } else {
            return {error = "Database configuration not available"};
        }
    }
    
    /**
     * Test connection
     */
    public struct function testConnection() {
        if (structKeyExists(variables, "dbConfig") && isObject(variables.dbConfig)) {
            return variables.dbConfig.testConnection();
        } else {
            return {success = false, message = "Database configuration not available"};
        }
    }
}
