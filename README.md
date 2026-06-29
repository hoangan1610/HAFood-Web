# HAFood-Web

A full-stack food ordering and e-commerce application built with ASP.NET and modern web technologies.

## Features

### Customer
- Authentication & Authorization (JWT)
- Browse products by category
- Search and filter products
- Shopping cart
- Checkout and order tracking
- Product reviews and ratings
- Wishlist
- User profile management
- Notifications

### Admin
- Dashboard and statistics
- Product management
- Category management
- Order management
- Promotion management
- User and role management

## Tech Stack

### Frontend
- HTML
- CSS
- JavaScript
- Bootstrap

### Backend
- ASP.NET Core Web API
- Entity Framework Core
- SQL Server
- JWT Authentication

## Architecture

```text
Client
   ↓
ASP.NET MVC / Frontend
   ↓
REST API
   ↓
SQL Server
```

## Project Structure

```text
HAFood-Web
├── Controllers
├── Models
├── Views
├── Services
├── ViewModels
├── wwwroot
└── Areas/Admin
```

## Getting Started

### Clone repository

```bash
git clone https://github.com/hoangan1610/HAFood-Web.git
```

### Configure appsettings.json

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "YOUR_CONNECTION_STRING"
  }
}
```

### Run migrations

```bash
Update-Database
```

### Start application

```bash
dotnet run
```

## Future Improvements

- Docker support
- CI/CD with GitHub Actions
- Unit Testing
- SignalR notifications
- Redis caching
- Elasticsearch product search

## Related Projects

- HAFood-API:
  https://github.com/hoangan1610/HAFood-API

## Author

Ngô Hoàng Ân

- GitHub: https://github.com/hoangan1610
- Email: hoanganngo469@gmail.com
- LinkedIn: linkedin.com/in/ngohoangan
