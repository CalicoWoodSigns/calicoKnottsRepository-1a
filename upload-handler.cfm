<cfscript>
    /*
     * Calico Knotts Remote File Upload Handler
     * Receives files from local development environment
     * Place this file on the remote server to accept uploads
     */
    
    // Security check - restrict access to authorized IPs if needed
    param name="form.action" default="";
    param name="url.action" default="";
    
    // Get action from either form or URL
    action = len(form.action) ? form.action : url.action;
    
    // Initialize response
    response = {
        "success" = false,
        "message" = "",
        "timestamp" = now(),
        "method" = cgi.request_method
    };
    
    try {
        if (action == "sync" && cgi.request_method == "POST") {
            // Handle ZIP package upload
            if (structKeyExists(form, "package") && isStruct(form.package)) {
                packageFile = form.package;
                
                // Create upload directory if it doesn't exist
                uploadDir = expandPath("./uploads/");
                if (!directoryExists(uploadDir)) {
                    directoryCreate(uploadDir);
                }
                
                // Generate unique filename
                timestamp = dateFormat(now(), "yyyymmdd") & "_" & timeFormat(now(), "HHmmss");
                zipFilename = "sync_package_" & timestamp & ".zip";
                zipPath = uploadDir & zipFilename;
                
                // Save uploaded file
                fileMove(packageFile.serverfile, zipPath);
                
                // Extract ZIP contents
                extractDir = uploadDir & "extracted_" & timestamp & "/";
                if (!directoryExists(extractDir)) {
                    directoryCreate(extractDir);
                }
                
                // Use CFZIP to extract
                cfzip(action="unzip", file=zipPath, destination=extractDir, overwrite=true);
                
                // Copy files to web root (be careful with this in production!)
                webRoot = expandPath("./");
                
                // Get list of extracted files
                extractedFiles = directoryList(extractDir, true, "path");
                copiedFiles = [];
                
                for (file in extractedFiles) {
                    if (fileExists(file)) {
                        relativePath = replace(file, extractDir, "");
                        targetPath = webRoot & relativePath;
                        
                        // Create target directory if needed
                        targetDir = getDirectoryFromPath(targetPath);
                        if (!directoryExists(targetDir)) {
                            directoryCreate(targetDir, true);
                        }
                        
                        // Copy file
                        fileCopy(file, targetPath);
                        arrayAppend(copiedFiles, relativePath);
                    }
                }
                
                // Clean up
                if (fileExists(zipPath)) {
                    fileDelete(zipPath);
                }
                if (directoryExists(extractDir)) {
                    directoryDelete(extractDir, true);
                }
                
                response.success = true;
                response.message = "Successfully synced " & arrayLen(copiedFiles) & " files";
                response.files = copiedFiles;
                
            } else {
                response.message = "No package file received";
            }
            
        } else if (action == "upload_file" && cgi.request_method == "GET") {
            // Handle individual file upload via GET
            param name="url.file_path" default="";
            param name="url.content" default="";
            param name="url.encoding" default="";
            
            if (len(url.file_path) && len(url.content)) {
                targetPath = expandPath("./" & url.file_path);
                targetDir = getDirectoryFromPath(targetPath);
                
                // Create directory if needed
                if (!directoryExists(targetDir)) {
                    directoryCreate(targetDir, true);
                }
                
                // Decode content if base64
                if (url.encoding == "base64") {
                    fileContent = toBinary(toBase64(url.content));
                } else {
                    fileContent = url.content;
                }
                
                // Write file
                fileWrite(targetPath, fileContent);
                
                response.success = true;
                response.message = "File uploaded successfully: " & url.file_path;
                response.file_path = url.file_path;
                response.file_size = len(fileContent);
                
            } else {
                response.message = "Missing file_path or content parameters";
            }
            
        } else if (action == "test") {
            // Test endpoint
            response.success = true;
            response.message = "Upload handler is working";
            response.server_info = {
                "cf_version" = server.coldfusion.productversion,
                "server_time" = now(),
                "dsn_available" = false
            };
            
            // Test DSN connection
            try {
                queryExecute("SELECT 1 as test", {}, {datasource="calicoknotts_db_A_DSN"});
                response.server_info.dsn_available = true;
                response.server_info.dsn_name = "calicoknotts_db_A_DSN";
            } catch (any e) {
                response.server_info.dsn_error = e.message;
            }
            
        } else {
            response.message = "Invalid action or method. Supported: sync (POST), upload_file (GET), test";
        }
        
    } catch (any e) {
        response.success = false;
        response.message = "Error: " & e.message;
        response.detail = e.detail;
    }
    
    // Return JSON response
    cfheader(name="Content-Type", value="application/json");
    writeOutput(serializeJSON(response));
</cfscript>
