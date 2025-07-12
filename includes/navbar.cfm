<!--- Navigation Map - Include at top of pages --->
<cfparam name="currentPage" default="">

<!--- Check if user is logged in (with session safety check) --->
<cfset isLoggedIn = false>
<cfif isDefined("session") AND structKeyExists(session, "isLoggedIn") AND session.isLoggedIn>
    <cfset isLoggedIn = true>
</cfif>

<nav class="navbar navbar-expand-lg navbar-dark bg-primary">
    <div class="container">
        <!--- Brand/Home Link --->
        <a class="navbar-brand" href="index.cfm">
            <i class="bi bi-house-door-fill"></i>
            Calico Wood Signs
        </a>
        
        <!--- Mobile toggle button --->
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
            <span class="navbar-toggler-icon"></span>
        </button>
        
        <!--- Navigation items --->
        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav me-auto">
                <!--- Home Link --->
                <li class="nav-item">
                    <a class="nav-link <cfif currentPage EQ 'home'>active</cfif>" href="index.cfm">
                        <i class="bi bi-speedometer2"></i> Dashboard
                    </a>
                </li>
                
                <cfif isLoggedIn>
                    <!--- Admin Panel (if user has access) --->
                    <cfif isDefined("session.accessLevel") AND session.accessLevel GTE 2>
                        <li class="nav-item">
                            <a class="nav-link <cfif currentPage EQ 'admin_data'>active</cfif>" href="admin_data.cfm">
                                <i class="bi bi-database-gear"></i> Admin Panel
                            </a>
                        </li>
                    </cfif>
                    
                    <!--- Employee Profile --->
                    <li class="nav-item">
                        <a class="nav-link <cfif currentPage EQ 'employee_profile'>active</cfif>" href="employee_profile.cfm">
                            <i class="bi bi-person-circle"></i> My Profile
                        </a>
                    </li>
                </cfif>
            </ul>
            
            <!--- Right side navigation --->
            <ul class="navbar-nav">
                <cfif isLoggedIn>
                    <!--- Welcome message --->
                    <li class="navbar-text text-light me-3">
                        Welcome, <cfoutput>#session.userFirstName# #session.userLastName#</cfoutput>
                    </li>
                    
                    <!--- Logout --->
                    <li class="nav-item">
                        <a class="nav-link" href="?logout=true">
                            <i class="bi bi-box-arrow-right"></i> Logout
                        </a>
                    </li>
                <cfelse>
                    <!--- Login link if not logged in --->
                    <li class="nav-item">
                        <a class="nav-link" href="index.cfm">
                            <i class="bi bi-box-arrow-in-right"></i> Login
                        </a>
                    </li>
                </cfif>
            </ul>
        </div>
    </div>
</nav>

<!--- Add some styling --->
<style>
    .navbar-brand {
        font-weight: 600;
        font-size: 1.2rem;
    }
    
    .nav-link.active {
        background-color: rgba(255, 255, 255, 0.2);
        border-radius: 0.375rem;
    }
    
    .nav-link:hover {
        background-color: rgba(255, 255, 255, 0.1);
        border-radius: 0.375rem;
        transition: all 0.3s ease;
    }
    
    .navbar-text {
        font-weight: 500;
    }
</style>
