component displayname="Utility Functions" hint="Common utility functions for the application" {
    
    /**
     * Formats a date in a user-friendly way
     * @param dateValue The date to format
     * @param format The format string (optional)
     * @return Formatted date string
     */
    public string function formatDate(required date dateValue, string format = "mmmm d, yyyy") {
        try {
            return dateFormat(arguments.dateValue, arguments.format);
        } catch (any e) {
            return "Invalid Date";
        }
    }
    
    /**
     * Formats a date and time in a user-friendly way
     * @param dateTimeValue The datetime to format
     * @return Formatted datetime string
     */
    public string function formatDateTime(required date dateTimeValue) {
        try {
            return dateTimeFormat(arguments.dateTimeValue, "mmmm d, yyyy 'at' h:nn tt");
        } catch (any e) {
            return "Invalid DateTime";
        }
    }
    
    /**
     * Sanitizes HTML input to prevent XSS attacks
     * @param input The input string to sanitize
     * @return Sanitized string
     */
    public string function sanitizeHTML(required string input) {
        var cleanInput = htmlEditFormat(arguments.input);
        // Additional sanitization can be added here
        return cleanInput;
    }
    
    /**
     * Validates email format
     * @param email Email address to validate
     * @return Boolean indicating if email is valid
     */
    public boolean function isValidEmail(required string email) {
        var emailPattern = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$";
        return reFind(emailPattern, arguments.email) > 0;
    }
    
    /**
     * Generates a random string of specified length
     * @param length Length of the random string
     * @param includeNumbers Include numbers in the string
     * @param includeSpecial Include special characters
     * @return Random string
     */
    public string function generateRandomString(
        numeric length = 10,
        boolean includeNumbers = true,
        boolean includeSpecial = false
    ) {
        var chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
        
        if (arguments.includeNumbers) {
            chars &= "0123456789";
        }
        
        if (arguments.includeSpecial) {
            chars &= "!@#$%^&*";
        }
        
        var result = "";
        for (var i = 1; i <= arguments.length; i++) {
            var randomIndex = randRange(1, len(chars));
            result &= mid(chars, randomIndex, 1);
        }
        
        return result;
    }
    
    /**
     * Converts a struct to JSON with error handling
     * @param data The data to convert
     * @return JSON string or error message
     */
    public string function toJSON(required any data) {
        try {
            return serializeJSON(arguments.data);
        } catch (any e) {
            return '{"error": "Unable to serialize data"}';
        }
    }
    
    /**
     * Logs application events
     * @param message Log message
     * @param type Log type (info, warning, error)
     * @param category Log category
     */
    public void function logEvent(
        required string message,
        string type = "info",
        string category = "application"
    ) {
        writeLog(
            text = arguments.message,
            type = arguments.type,
            file = "calicoknotts_#arguments.category#"
        );
    }
}
