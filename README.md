# Calico Knotts Wood Signs - ColdFusion Application

A custom ColdFusion application for Calico Knotts Wood Signs business.

## Project Structure

```
calicoknotts/
├── Application.cfc          # Main application configuration
├── index.cfm               # Homepage
├── error.cfm               # Error handling page
├── test.cfm                # Test page
├── components/             # CFC components
│   ├── Utils.cfc          # Utility functions
│   └── DatabaseService.cfc # Database operations
├── includes/               # Reusable includes
│   ├── header.cfm         # Page header
│   └── footer.cfm         # Page footer
├── assets/                 # Static assets
│   ├── css/
│   │   └── main.css       # Main stylesheet
│   ├── js/
│   │   └── main.js        # Main JavaScript
│   └── images/            # Image files
└── api/                   # API endpoints
```

## Features

- Complete Application.cfc with session management
- Error handling and logging
- Responsive Bootstrap UI
- Utility components for common functions
- Database service layer (ready for configuration)
- Modern CSS with custom wood-themed styling

## Configuration

1. Configure your datasource in `Application.cfc` if using a database
2. Update email settings in the application settings
3. Customize the company information in the components

## Version

Current version: 1.0