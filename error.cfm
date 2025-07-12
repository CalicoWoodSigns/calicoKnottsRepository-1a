<!--- Disable debug output for this page --->
<cfsetting showdebugoutput="false">

<cfparam name="url.type" default="general">

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Error - Calico Wood Signs at Knotts</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <link href="assets/css/style.css" rel="stylesheet">
</head>
<body>
    <!--- Include Navigation Bar --->
    <cfset currentPage = "error">
    <cfinclude template="includes/navbar.cfm">

    <div class="container mt-5">
        <div class="row justify-content-center">
            <div class="col-md-8">
                <div class="card shadow">
                    <div class="card-body text-center p-5">
                        <h1 class="text-danger mb-4">
                            <i class="bi bi-exclamation-triangle-fill" style="font-size: 3rem;"></i>
                        </h1>
                        <h2 class="mb-3">Oops! Something went wrong</h2>
                        
                        <cfswitch expression="#url.type#">
                            <cfcase value="404">
                                <h4 class="text-warning">Page Not Found</h4>
                                <p class="lead">The page you're looking for doesn't exist.</p>
                            </cfcase>
                            <cfcase value="database">
                                <h4 class="text-danger">Database Error</h4>
                                <p class="lead">We're having trouble connecting to our database.</p>
                            </cfcase>
                            <cfcase value="general">
                                <h4 class="text-primary">Application Error</h4>
                                <p class="lead">We're sorry, but something unexpected happened.</p>
                            </cfcase>
                            <cfdefaultcase>
                                <h4 class="text-secondary">Error</h4>
                                <p class="lead">An error occurred while processing your request.</p>
                            </cfdefaultcase>
                        </cfswitch>
                        
                        <div class="mt-4">
                            <a href="index.cfm" class="btn btn-primary me-3">
                                <i class="bi bi-house-door"></i> Return Home
                            </a>
                            <a href="javascript:history.back()" class="btn btn-outline-secondary">
                                <i class="bi bi-arrow-left"></i> Go Back
                            </a>
                        </div>
                        
                        <div class="mt-4">
                            <p class="text-muted">
                                If this problem persists, please contact support.
                            </p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>