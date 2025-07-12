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
            qry.setDatasource("calicoknotts_db");
            
            // Add parameters
            for (var param in arguments.params) {
                qry.addParam(
                    name = param,
                    value = arguments.params[param],
                    cfsqltype = "cf_sql_varchar" // Default type, should be dynamic based on data
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
            
            // Return empty query on error
            return queryNew("");
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
     * Gets all employees from the database
     * @return Query of employees
     */
    public query function getEmployees() {
        return executeQuery("SELECT EID, firstName, lastName, userName, address1, city, state, phone, accessLevel FROM employeeInfo ORDER BY lastName, firstName");
    }
    
    /**
     * Gets a single employee by ID
     * @param employeeID Employee ID
     * @return Query with single employee
     */
    public query function getEmployee(required numeric employeeID) {
        return executeQuery(
            "SELECT EID, firstName, lastName, userName, address1, address2, city, state, zipCode, phone, accessLevel FROM employeeInfo WHERE EID = :eid",
            {eid = arguments.employeeID}
        );
    }
    
    /**
     * Gets sales records for an employee
     * @param employeeID Employee ID (optional)
     * @return Query of sales records
     */
    public query function getSales(numeric employeeID = 0) {
        if (arguments.employeeID > 0) {
            return executeQuery(
                "SELECT saleID, EID, firstName, lastName, saleDate, hours, saleAmount, notes FROM employeeSales WHERE EID = :eid ORDER BY saleDate DESC",
                {eid = arguments.employeeID}
            );
        } else {
            return executeQuery("SELECT saleID, EID, firstName, lastName, saleDate, hours, saleAmount, notes FROM employeeSales ORDER BY saleDate DESC");
        }
    }
    
    /**
     * Adds a new sale record
     * @param employeeID Employee ID
     * @param firstName Employee first name
     * @param lastName Employee last name
     * @param hours Hours worked
     * @param saleAmount Sale amount
     * @param notes Optional notes
     * @return Boolean success
     */
    public boolean function addSale(
        required numeric employeeID,
        required string firstName,
        required string lastName,
        required numeric hours,
        required numeric saleAmount,
        string notes = ""
    ) {
        try {
            executeQuery(
                "INSERT INTO employeeSales (EID, firstName, lastName, saleDate, hours, saleAmount, notes) VALUES (:eid, :fname, :lname, GETDATE(), :hours, :amount, :notes)",
                {
                    eid = arguments.employeeID,
                    fname = arguments.firstName,
                    lname = arguments.lastName,
                    hours = arguments.hours,
                    amount = arguments.saleAmount,
                    notes = arguments.notes
                }
            );
            return true;
        } catch (any e) {
            writeLog(text="Error adding sale: #e.message#", type="error", file="calicoknotts_database");
            return false;
        }
    }
}
