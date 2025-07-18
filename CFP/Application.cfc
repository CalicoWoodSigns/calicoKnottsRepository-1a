component {
    // Application settings
    this.name = "CalicoKnottsApp";
    this.applicationTimeout = createTimeSpan(0, 2, 0, 0); // 2 hours
    this.sessionManagement = true;
    this.sessionTimeout = createTimeSpan(0, 0, 30, 0); // 30 minutes
    this.clientManagement = false;
    this.setClientCookies = true;
    this.setDomainCookies = false;
    
    // Datasource settings - Use administrator-configured datasource
    this.datasource = "calicoknotts_db";
    
    // Custom tag paths
    this.customTagPaths = [expandPath("./customtags")];
    
    // Mapping settings
    this.mappings["/components"] = expandPath("./components");
    this.mappings["/includes"] = expandPath("./includes");
    this.mappings["/assets"] = expandPath("./assets");
    
    // Security settings
    this.secureJSON = true;
    this.secureJSONPrefix = "//";
    
    // Error handling
    this.errorTemplate = "/error.cfm";
    this.missingTemplate = "/error.cfm";
    
    // Application initialization
    public boolean function onApplicationStart() {
        // Initialize application variables
        application.appName = "Calico Knotts Wood Signs";
        application.version = "1.0";
        application.startTime = now();
        
        // Initialize any application-wide settings
        application.settings = {
            "enableDebug" = false,
            "emailFrom" = "noreply@calicoknotts.com",
            "timezone" = "America/New_York"
        };
        
        return true;
    }
    
    // Session initialization
    public boolean function onSessionStart() {
        // Initialize session variables
        session.isLoggedIn = false;
        session.userRole = "guest";
        session.lastActivity = now();
        
        return true;
    }
    
    // Request initialization
    public boolean function onRequestStart(string targetPage) {
        // Check for application reload
        if (structKeyExists(url, "reload") && url.reload == "app") {
            applicationStop();
            location(url="#cgi.script_name#", addToken=false);
        }
        
        // Update last activity
        if (structKeyExists(session, "lastActivity")) {
            session.lastActivity = now();
        }
        
        // Set request variables
        request.startTime = getTickCount();
        request.basePath = getDirectoryFromPath(getCurrentTemplatePath());
        
        return true;
    }
    
    // Error handling
    public void function onError(exception, eventName) {
        // Log the error
        writeLog(
            text = "Error in #eventName#: #exception.message# - #exception.detail#",
            type = "error",
            file = "calicoknotts_errors"
        );
        
        // In production, redirect to error page
        if (!application.settings.enableDebug) {
            location(url="/error.cfm?type=general", addToken=false);
        }
    }
    
    // Session end
    public void function onSessionEnd(sessionScope, applicationScope) {
        // Clean up session data if needed
        writeLog(
            text = "Session ended for session ID: #sessionScope.sessionID#",
            type = "information",
            file = "calicoknotts_sessions"
        );
    }
    
    // Application end
    public void function onApplicationEnd(applicationScope) {
        // Clean up application data
        writeLog(
            text = "Application ended: #applicationScope.appName#",
            type = "information",
            file = "calicoknotts_application"
        );
    }
}