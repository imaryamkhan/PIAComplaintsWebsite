<%@ Page Title="" Language="C#" MasterPageFile="~/Site1.Master" AutoEventWireup="true" CodeBehind="home.aspx.cs" Inherits="WebApplication2.homeaspx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .center-container { min-height: calc(100vh - 140px); display: flex; justify-content: center; align-items: center; padding: 20px; }
        .glass-box { backdrop-filter: blur(10px); -webkit-backdrop-filter: blur(10px); padding: 20px; border-radius: 15px; max-width: 800px; color: white; box-shadow: 0 4px 30px rgba(0,0,0,0.3); line-height: 1.6; font-size: 1.1rem; background-color: rgba(0,0,0,0.6); }
        .glass-box p { margin: 0; }
        .logout-btn { display: block; margin-top: 20px; padding: 8px 16px; background-color: #ff4d4d; color: white; border: none; border-radius: 5px; cursor: pointer; text-decoration: none; }
        .logout-btn:hover { background-color: #e60000; }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="center-container">
        <div class="glass-box">
            <p>
                Welcome, <strong><asp:Label ID="lblUser" runat="server"></asp:Label></strong>!<br /><br />
Welcome to the PIA Complaint Portal – your official platform to share feedback, report issues, and track your complaints regarding Pakistan International Airlines (PIA).
Our goal is to provide passengers with a transparent, quick, and reliable way to register concerns and ensure timely resolution. Whether it’s about booking, baggage, staff behavior, flight delays, or any service-related matter – we’re here to listen.        </div>
    </div>
</asp:Content>
