<%@ Page Title="" Language="C#" MasterPageFile="~/Site1.Master" AutoEventWireup="true" CodeBehind="about.aspx.cs" Inherits="WebApplication2.aboutaspx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .center-container {
            min-height: calc(100vh - 140px);
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }

        .glass-box {
            background: rgba(255, 255, 255, 0.15);
            backdrop-filter: blur(12px);
            -webkit-backdrop-filter: blur(12px);
            padding: 30px;
            border-radius: 15px;
            max-width: 900px;
            width: 100%;
            color: white;
            box-shadow: 0 4px 30px rgba(0, 0, 0, 0.3);
            line-height: 1.6;
            font-size: 1.1rem;
        }

        .glass-box p {
            margin: 0;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="center-container">
        <div class="glass-box">
            <p>
                <strong>PIA</strong><br> Connecting the World with Unrivaled Service and Care.  
                At PIA, our mission is to connect people and cultures, creating memorable journeys that go beyond the destination.
                <br><br>
                The PIA Complaint Portal is designed to improve communication between passengers and the airline.
                We believe that your voice matters. Every complaint helps us enhance service quality, improve operations, and create a better travel experience for all passengers.
                <br><br>
                <strong>Our mission is simple: </strong>
                <ul>
                    <li>Listen to passengers</li>
                    <li>Resolve issues quickly</li>
                    <li>Improve overall customer satisfaction</li>                  
            </p>
        </div>
    </div>
</asp:Content>
