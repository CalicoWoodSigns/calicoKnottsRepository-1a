<!--- Process Data - Handle form submissions for employee and sales data --->

<!--- Initialize database service --->
<cfset dbService = createObject("component", "components.DatabaseService")>
<cfset message = "">
<cfset messageType = "">

<!--- Process form submissions --->
<cfif structKeyExists(form, "action")>
    
    <cfswitch expression="#form.action#">
        
        <!--- Add Employee --->
        <cfcase value="addEmployee">
            <cftry>
                <cfquery datasource="calicoknotts_db">
                    INSERT INTO employeeInfo (userName, firstName, lastName, password, accessLevel)
                    VALUES (
                        <cfqueryparam value="#form.userName#" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#form.firstName#" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#form.lastName#" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#form.password#" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#form.accessLevel#" cfsqltype="cf_sql_integer">
                    )
                </cfquery>
                
                <cfset message = "Employee '#form.firstName# #form.lastName#' added successfully!">
                <cfset messageType = "success">
                
                <cfcatch type="any">
                    <cfset message = "Error adding employee: #cfcatch.message#">
                    <cfset messageType = "error">
                    
                    <!--- Log the error --->
                    <cflog text="Error adding employee: #cfcatch.message# - #cfcatch.detail#" type="error" file="calicoknotts_data">
                </cfcatch>
            </cftry>
        </cfcase>
        
        <!--- Add Sale --->
        <cfcase value="addSale">
            <cftry>
                <!--- Get employee info first --->
                <cfquery name="getEmployee" datasource="calicoknotts_db">
                    SELECT firstName, lastName 
                    FROM employeeInfo 
                    WHERE EID = <cfqueryparam value="#form.employeeID#" cfsqltype="cf_sql_integer">
                </cfquery>
                
                <!--- Insert the sale --->
                <cfquery datasource="calicoknotts_db">
                    INSERT INTO employeeSales (EID, firstName, lastName, saleDate, hours, saleAmount, notes)
                    VALUES (
                        <cfqueryparam value="#form.employeeID#" cfsqltype="cf_sql_integer">,
                        <cfqueryparam value="#getEmployee.firstName#" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#getEmployee.lastName#" cfsqltype="cf_sql_varchar">,
                        GETDATE(),
                        <cfqueryparam value="#form.hours#" cfsqltype="cf_sql_decimal">,
                        <cfqueryparam value="#form.saleAmount#" cfsqltype="cf_sql_decimal">,
                        <cfqueryparam value="#form.notes#" cfsqltype="cf_sql_varchar">
                    )
                </cfquery>
                
                <cfset message = "Sale of $#numberFormat(form.saleAmount, '0.00')# for #getEmployee.firstName# #getEmployee.lastName# added successfully!">
                <cfset messageType = "success">
                
                <cfcatch type="any">
                    <cfset message = "Error adding sale: #cfcatch.message#">
                    <cfset messageType = "error">
                    
                    <!--- Log the error --->
                    <cflog text="Error adding sale: #cfcatch.message# - #cfcatch.detail#" type="error" file="calicoknotts_data">
                </cfcatch>
            </cftry>
        </cfcase>
        
        <!--- Edit Employee --->
        <cfcase value="editEmployee">
            <cftry>
                <cfquery datasource="calicoknotts_db">
                    UPDATE employeeInfo 
                    SET 
                        userName = <cfqueryparam value="#form.userName#" cfsqltype="cf_sql_varchar">,
                        firstName = <cfqueryparam value="#form.firstName#" cfsqltype="cf_sql_varchar">,
                        lastName = <cfqueryparam value="#form.lastName#" cfsqltype="cf_sql_varchar">,
                        password = <cfqueryparam value="#form.password#" cfsqltype="cf_sql_varchar">,
                        accessLevel = <cfqueryparam value="#form.accessLevel#" cfsqltype="cf_sql_integer">,
                        address1 = <cfqueryparam value="#form.address1#" cfsqltype="cf_sql_varchar">,
                        city = <cfqueryparam value="#form.city#" cfsqltype="cf_sql_varchar">,
                        state = <cfqueryparam value="#form.state#" cfsqltype="cf_sql_varchar">,
                        phone = <cfqueryparam value="#form.phone#" cfsqltype="cf_sql_varchar">
                    WHERE EID = <cfqueryparam value="#form.employeeID#" cfsqltype="cf_sql_integer">
                </cfquery>
                
                <cfset message = "Employee '#form.firstName# #form.lastName#' updated successfully!">
                <cfset messageType = "success">
                
                <cfcatch type="any">
                    <cfset message = "Error updating employee: #cfcatch.message#">
                    <cfset messageType = "error">
                    
                    <!--- Log the error --->
                    <cflog text="Error updating employee: #cfcatch.message# - #cfcatch.detail#" type="error" file="calicoknotts_data">
                </cfcatch>
            </cftry>
        </cfcase>
        
        <!--- Edit Sale --->
        <cfcase value="editSale">
            <cftry>
                <!--- Get employee info first --->
                <cfquery name="getEmployee" datasource="calicoknotts_db">
                    SELECT firstName, lastName 
                    FROM employeeInfo 
                    WHERE EID = <cfqueryparam value="#form.employeeID#" cfsqltype="cf_sql_integer">
                </cfquery>
                
                <cfquery datasource="calicoknotts_db">
                    UPDATE employeeSales 
                    SET 
                        EID = <cfqueryparam value="#form.employeeID#" cfsqltype="cf_sql_integer">,
                        firstName = <cfqueryparam value="#getEmployee.firstName#" cfsqltype="cf_sql_varchar">,
                        lastName = <cfqueryparam value="#getEmployee.lastName#" cfsqltype="cf_sql_varchar">,
                        hours = <cfqueryparam value="#form.hours#" cfsqltype="cf_sql_decimal">,
                        saleAmount = <cfqueryparam value="#form.saleAmount#" cfsqltype="cf_sql_decimal">,
                        notes = <cfqueryparam value="#form.notes#" cfsqltype="cf_sql_varchar">
                    WHERE saleID = <cfqueryparam value="#form.saleID#" cfsqltype="cf_sql_integer">
                </cfquery>
                
                <cfset message = "Sale updated successfully!">
                <cfset messageType = "success">
                
                <cfcatch type="any">
                    <cfset message = "Error updating sale: #cfcatch.message#">
                    <cfset messageType = "error">
                    
                    <!--- Log the error --->
                    <cflog text="Error updating sale: #cfcatch.message# - #cfcatch.detail#" type="error" file="calicoknotts_data">
                </cfcatch>
            </cftry>
        </cfcase>
        
        <!--- Delete Employee --->
        <cfcase value="deleteEmployee">
            <cftry>
                <!--- Check if employee has sales records --->
                <cfquery name="checkSales" datasource="calicoknotts_db">
                    SELECT COUNT(*) as saleCount 
                    FROM employeeSales 
                    WHERE EID = <cfqueryparam value="#form.employeeID#" cfsqltype="cf_sql_integer">
                </cfquery>
                
                <cfif checkSales.saleCount gt 0>
                    <cfset message = "Cannot delete employee - they have #checkSales.saleCount# sales records. Delete sales first.">
                    <cfset messageType = "error">
                <cfelse>
                    <cfquery datasource="calicoknotts_db">
                        DELETE FROM employeeInfo 
                        WHERE EID = <cfqueryparam value="#form.employeeID#" cfsqltype="cf_sql_integer">
                    </cfquery>
                    
                    <cfset message = "Employee deleted successfully!">
                    <cfset messageType = "success">
                </cfif>
                
                <cfcatch type="any">
                    <cfset message = "Error deleting employee: #cfcatch.message#">
                    <cfset messageType = "error">
                    
                    <!--- Log the error --->
                    <cflog text="Error deleting employee: #cfcatch.message# - #cfcatch.detail#" type="error" file="calicoknotts_data">
                </cfcatch>
            </cftry>
        </cfcase>
        
        <!--- Delete Sale --->
        <cfcase value="deleteSale">
            <cftry>
                <cfquery datasource="calicoknotts_db">
                    DELETE FROM employeeSales 
                    WHERE saleID = <cfqueryparam value="#form.saleID#" cfsqltype="cf_sql_integer">
                </cfquery>
                
                <cfset message = "Sale deleted successfully!">
                <cfset messageType = "success">
                
                <cfcatch type="any">
                    <cfset message = "Error deleting sale: #cfcatch.message#">
                    <cfset messageType = "error">
                    
                    <!--- Log the error --->
                    <cflog text="Error deleting sale: #cfcatch.message# - #cfcatch.detail#" type="error" file="calicoknotts_data">
                </cfcatch>
            </cftry>
        </cfcase>
        
        <cfdefaultcase>
            <cfset message = "Invalid action specified.">
            <cfset messageType = "error">
        </cfdefaultcase>
        
    </cfswitch>
    
    <!--- Redirect back to data management page with message --->
    <cfset redirectUrl = "data_management.cfm">
    <cfif len(message) gt 0>
        <cfset redirectUrl = redirectUrl & "?message=" & urlEncodedFormat(message) & "&messageType=" & messageType>
    </cfif>
    
    <cflocation url="#redirectUrl#" addToken="false">
    
<cfelse>
    <!--- No form submission, redirect to data management --->
    <cflocation url="data_management.cfm" addToken="false">
</cfif>
