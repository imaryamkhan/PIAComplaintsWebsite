<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Signup.aspx.cs" Inherits="WebApplication2.Signup" %>
<!DOCTYPE html>
<html>
<head runat="server">
    <title>PIA - Signup</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        html, body {
            height: 100%;
            margin: 0;
            font-family: Arial, sans-serif;
        }
        .bg-image {
            background-image: url('/images/IMAGE.png');
            filter: blur(8px);
            height: 100%;
            background-position: center;
            background-size: cover;
            position: fixed;
            width: 100%;
            z-index: -1;
        }
        .signup-container {
            height: 100%;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }
        .signup-box {
            background-color: rgba(0,0,0,0.7);
            padding: 40px;
            border-radius: 15px;
            color: white;
            width: 100%;
            max-width: 450px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.5);
        }
        .signup-box h2 {
            text-align: center;
            margin-bottom: 30px;
            color: white;
        }
        .signup-box a {
            color: #ffd700;
            text-decoration: none;
        }
        .signup-box .btn {
            width: 100%;
            margin-bottom: 10px;
        }
        .form-control {
            margin-bottom: 15px;
            background: rgba(255,255,255,0.9);
        }
    </style>
</head>
<body>
    <div class="bg-image"></div>
    <div class="signup-container">
        <form id="form1" runat="server" class="signup-box">
            <h2>Create Account</h2>
            
            <asp:Label ID="lblMessage" runat="server" CssClass="d-block mb-3"></asp:Label>
            
            <div class="mb-3">
                <asp:TextBox ID="txtFullName" runat="server" CssClass="form-control" placeholder="Full Name"></asp:TextBox>
            </div>
            
            <div class="mb-3">
                <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" placeholder="Email Address" TextMode="Email"></asp:TextBox>
            </div>
            
            <div class="mb-3">
                <asp:TextBox ID="txtPassword" runat="server" CssClass="form-control" placeholder="Password" TextMode="Password"></asp:TextBox>
            </div>
            
            <div class="mb-3">
                <asp:Button ID="btnSignup" runat="server" Text="Create Account" OnClick="btnSignup_Click" CssClass="btn btn-success" />
                <asp:Button ID="btnGoLogin" runat="server" Text="Back to Login" OnClick="btnGoLogin_Click" CssClass="btn btn-secondary" CausesValidation="false" />
            </div>
            
            <div class="text-center">
                Already have an account? <a href="Login.aspx">Login here</a>
            </div>
        </form>
    </div>
</body>
</html>