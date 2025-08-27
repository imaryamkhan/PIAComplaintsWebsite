<%@ Page Title="" Language="C#" MasterPageFile="~/Site1.Master" AutoEventWireup="true" CodeBehind="contact.aspx.cs" Inherits="WebApplication2.contact" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        body {
            background: url('your-background.jpg') no-repeat center center fixed;
            background-size: cover;
        }

        .center-container {
            min-height: 100vh; 
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .blur-box {
            background: rgba(255, 255, 255, 0.2); 
            backdrop-filter: blur(10px); 
            -webkit-backdrop-filter: blur(10px); 
            padding: 20px;
            border-radius: 15px;
            max-width: 800px;
            color: #fff;
            font-size: 16px;
            box-shadow: 0px 4px 20px rgba(0,0,0,0.3);
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="container center-container">
        <div class="blur-box">
            <p>
               Have a query or need support? We’re here to help.
                <br>
               📧 Email: support@piacomplaints.com
                <br>
               ☎️ Helpline: +92-21-111-786-786
                <br>
               📍 Address: Pakistan International Airlines, Karachi, Pakistan
                <br>
               You can also reach out to us through the Contact Form available on this website for quick assistance.            </p>
        </div>
    </div>
</asp:Content>
