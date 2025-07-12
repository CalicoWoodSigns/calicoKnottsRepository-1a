<!--- Header include for all pages --->
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><cfoutput>#application.appName#<cfif structKeyExists(variables, "pageTitle")> - #variables.pageTitle#</cfif></cfoutput></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="/assets/css/main.css" rel="stylesheet">
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
        <div class="container">
            <a class="navbar-brand" href="/"><cfoutput>#application.appName#</cfoutput></a>
            <div class="navbar-nav ms-auto">
                <a class="nav-link" href="/">Home</a>
                <a class="nav-link" href="/products.cfm">Products</a>
                <a class="nav-link" href="/contact.cfm">Contact</a>
            </div>
        </div>
    </nav>
    <main class="container mt-4">
