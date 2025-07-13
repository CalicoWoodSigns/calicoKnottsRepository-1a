<cfscript>
    /*
     * Calico Knotts Sync Status Checker
     * Compares local and remote file versions
     */
    
    // Get file information
    function getFileInfo(filePath) {
        if (fileExists(filePath)) {
            fileInfo = getFileInfo(filePath);
            content = fileRead(filePath);
            
            return {
                "exists" = true,
                "size" = fileInfo.size,
                "modified" = fileInfo.lastmodified,
                "checksum" = hash(content, "MD5")
            };
        } else {
            return {
                "exists" = false,
                "size" = 0,
                "modified" = "",
                "checksum" = ""
            };
        }
    }
    
    // Files to check
    filesToCheck = [
        "Application.cfc",
        "index.cfm",
        "employee_profile.cfm", 
        "admin_data.cfm",
        "error.cfm",
        "remote_dsn_test.cfm",
        "components/DatabaseConfig.cfc",
        "components/DatabaseService.cfc",
        "components/Utils.cfc",
        "includes/header.cfm",
        "includes/footer.cfm",
        "includes/navbar.cfm",
        "assets/css/main.css",
        "assets/js/main.js",
        "web.config"
    ];
    
    response = {
        "timestamp" = now(),
        "server_info" = {
            "cf_version" = server.coldfusion.productversion,
            "server_name" = cgi.server_name,
            "environment" = (findNoCase("localhost", cgi.server_name) ? "local" : "remote")
        },
        "files" = {}
    };
    
    // Check each file
    for (file in filesToCheck) {
        response.files[file] = getFileInfo(expandPath("./" & file));
    }
    
    // Test database connection
    try {
        // Try dynamic connection first
        if (application.keyExists("dbConfig")) {
            testQuery = application.dbConfig.executeQuery("SELECT 1 as test_connection", {});
            response.database = {
                "connection" = "dynamic",
                "status" = "connected",
                "method" = "DatabaseConfig component"
            };
        } else {
            // Fallback to direct DSN
            queryExecute("SELECT 1 as test", {}, {datasource="calicoknotts_db_A_DSN"});
            response.database = {
                "connection" = "direct_dsn", 
                "status" = "connected",
                "dsn" = "calicoknotts_db_A_DSN"
            };
        }
    } catch (any e) {
        response.database = {
            "status" = "error",
            "error" = e.message
        };
    }
    
    // Return JSON response
    cfheader(name="Content-Type", value="application/json");
    writeOutput(serializeJSON(response, "struct"));
</cfscript>
