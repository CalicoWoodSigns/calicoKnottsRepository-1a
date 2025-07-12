    </main>
    <footer class="bg-dark text-light py-4 mt-5">
        <div class="container">
            <div class="row">
                <div class="col-md-6">
                    <h5><cfoutput>#application.appName#</cfoutput></h5>
                    <p>Custom wood signs and crafts</p>
                </div>
                <div class="col-md-6 text-md-end">
                    <p>&copy; <cfoutput>#year(now())#</cfoutput> Calico Knotts. All rights reserved.</p>
                    <small>Version <cfoutput>#application.version#</cfoutput></small>
                </div>
            </div>
        </div>
    </footer>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="/assets/js/main.js"></script>
</body>
</html>
