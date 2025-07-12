<cfparam name="url.type" default="general">

<cfinclude template="/includes/header.cfm">

<div class="row justify-content-center">
    <div class="col-md-8">
        <div class="card">
            <div class="card-body text-center">
                <h1 class="text-danger mb-4">
                    <i class="fas fa-exclamation-triangle"></i>
                    Oops! Something went wrong
                </h1>
                
                <cfswitch expression="#url.type#">
                    <cfcase value="404">
                        <h3>Page Not Found</h3>
                        <p class="lead">The page you're looking for doesn't exist.</p>
                    </cfcase>
                    <cfcase value="general">
                        <h3>Application Error</h3>
                        <p class="lead">We're sorry, but something unexpected happened.</p>
                    </cfcase>
                    <cfdefaultcase>
                        <h3>Error</h3>
                        <p class="lead">An error occurred while processing your request.</p>
                    </cfdefaultcase>
                </cfswitch>
                
                <div class="mt-4">
                    <a href="/" class="btn btn-primary">Return Home</a>
                    <a href="javascript:history.back()" class="btn btn-outline-secondary">Go Back</a>
                </div>
                
                <div class="mt-4">
                    <p class="text-muted">
                        If this problem persists, please contact us at 
                        <a href="mailto:<cfoutput>#application.settings.emailFrom#</cfoutput>">
                            <cfoutput>#application.settings.emailFrom#</cfoutput>
                        </a>
                    </p>
                </div>
            </div>
        </div>
    </div>
</div>

<cfinclude template="/includes/footer.cfm">