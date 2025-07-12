<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Error - Calico Wood Signs</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-5">
        <div class="row justify-content-center">
            <div class="col-md-8">
                <div class="alert alert-danger" role="alert">
                    <h4 class="alert-heading">Oops! Something went wrong</h4>
                    <p>We're sorry, but an error has occurred while processing your request.</p>
                    <hr>
                    <p class="mb-0">
                        <a href="index.cfm" class="btn btn-primary">Return to Home</a>
                        <a href="mailto:support@calicoknotts.com" class="btn btn-outline-secondary">Contact Support</a>
                    </p>
                </div>
                
                <cfif isDefined("url.debug") and url.debug eq "true">
                    <div class="alert alert-warning">
                        <h5>Debug Information:</h5>
                        <cfif isDefined("cfcatch")>
                            <p><strong>Error:</strong> <cfoutput>#cfcatch.message#</cfoutput></p>
                            <p><strong>Detail:</strong> <cfoutput>#cfcatch.detail#</cfoutput></p>
                            <p><strong>Template:</strong> <cfoutput>#cfcatch.template#</cfoutput></p>
                        </cfif>
                    </div>
                </cfif>
            </div>
        </div>
    </div>
</body>
</html>
