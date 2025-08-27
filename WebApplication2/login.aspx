<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="WebApplication2.Login" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
        <link rel="icon" href="images/icon.png" >
    <title>PIA - Login</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <style>
        body {
            background-image: url('/images/IMAGE.png');
            background-size: cover;
            background-position: center;
            background-attachment: fixed;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .login-container {
            background: rgba(0,0,0,0.7);
            backdrop-filter: blur(10px);
            border-radius: 15px;
            padding: 40px;
            width: 100%;
            max-width: 400px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.5);
        }
        .login-container h3 {
            color: white;
            text-align: center;
            margin-bottom: 30px;
        }
        .form-control {
            margin-bottom: 15px;
            background: rgba(255,255,255,0.9);
        }
        .btn-primary {
            width: 100%;
            background: #007bff;
            border: none;
            padding: 12px;
        }
        .signup-link {
            text-align: center;
            margin-top: 20px;
        }
        .signup-link a {
            color: #ffd700;
            text-decoration: none;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="login-container">
            <h3>PIA Login</h3>
            
            <div class="mb-3">
                <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" placeholder="Enter Email" TextMode="Email"></asp:TextBox>
            </div>
            
            <div class="mb-3">
                <asp:TextBox ID="txtPassword" runat="server" CssClass="form-control" placeholder="Enter Password" TextMode="Password"></asp:TextBox>
            </div>
            
            <div class="mb-3">
                <asp:Button ID="btnLogin" runat="server" Text="Login" CssClass="btn btn-primary" OnClick="btnLogin_Click" />
            </div>
            
            <asp:Label ID="lblMessage" runat="server" CssClass="text-danger d-block text-center"></asp:Label>
            
            <div class="signup-link">
                <span style="color: white;">Don't have an account? </span>
                <a href="Signup.aspx">Sign up here</a>
            </div>
        </div>
    </form>
</body>
</html>