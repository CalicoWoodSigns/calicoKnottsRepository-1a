component displayname="Database Service" hint="Database operations and queries" {
    
    // Initialize the component
    public function init() {
        return this;
    }
    
    /**
     * Gets a database connection (if datasource is configured)
     * @return Query service or null
     */
    private function getConnection() {
        // This would be implemented based on your database setup
        // For now, returning a placeholder
        return null;
    }
    
    /**
     * Executes a safe query with parameter binding
     * @param sql SQL statement
     * @param params Query parameters
     * @return Query result
     */
    public query function executeQuery(required string sql, struct params = {}) {
        try {
            var qry = new Query();
            qry.setSQL(arguments.sql);
            
            // Add parameters
            for (var param in arguments.params) {
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
}
