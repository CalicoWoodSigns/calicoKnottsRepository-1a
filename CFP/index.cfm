<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Calico Knotts - ColdFusion Project</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-5">
        <div class="row justify-content-center">
            <div class="col-md-8">
                <div class="card">
                    <div class="card-body text-center">
                        <h1 class="text-primary">Calicowood Signs</h1>
                        <p class="lead">ColdFusion Project with Azure Database</p>
                        <p class="text-muted">
                            Current Time: <cfoutput>#dateTimeFormat(now(), "yyyy-mm-dd HH:nn:ss")#</cfoutput>
                        </p>
                        
                        <div class="mt-4">
                            <a href="test_database.cfm" class="btn btn-primary">Test Database Connection</a>
                            <a href="test.cfm" class="btn btn-outline-secondary">View Test Page</a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>