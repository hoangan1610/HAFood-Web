<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="HomePage.aspx.cs" Inherits="HAFoodWeb.HomePage.HomePage" %>
<%@ Register Src="~/Control/Header.ascx" TagPrefix="uc" TagName="Header" %>
<%@ Register Src="~/Control/SlideShow.ascx" TagPrefix="uc" TagName="Slideshow" %>
<%@ Register Src="~/Control/Footer.ascx" TagPrefix="uc" TagName="Footer" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>HAFood</title>
</head>
<body>
    <form runat="server">
        <!--HEADER-->
        <uc:Header ID="Header1" runat="server" />
        
        <!--SLIDESHOW-->
        <uc:Slideshow ID="Slideshow1" runat="server" />
        
        <!--MAIN CONTENT-->
        <div class="container text-center my-5">
            <h2>Welcome to HAFood</h2>
            <p>Fresh food, delivered daily — from our farms to your table.</p>
        </div>
        
        <!--FOOTER-->
        <uc:Footer ID="Footer1" runat="server" />
        
        <!-- BOOTSTRAP JS -->
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    </form>
</body>
</html>