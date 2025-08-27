<%@ Page Title="" Language="C#" MasterPageFile="~/Site1.Master" AutoEventWireup="true" CodeBehind="requirementsandprocedure.aspx.cs" Inherits="WebApplication2.requirementsandprocedure" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <div class="d-flex justify-content-center align-items-center min-vh-100 p-3">
        <div class="container p-4 rounded-4 bg-white bg-opacity-25 backdrop-blur shadow-lg text-white">
            
          

            <h5>Before submitting a complaint, please ensure you have the following details ready:</h5>
            
            <h3>Application Procedures</h3>
            <ul>
                <li>Full Name (as per booking)</li>
                <li>Valid Email or ID Number</li>
                <li>Complaint Details (brief but clear description of the issue)</li>
                <li>Submission: Send via mail or email; no hand submissions.</li>
            </ul>
            <p>⚠️ Please note: False, incomplete, or duplicate complaints may not be processed.</p>

            <h3 class="text-center mt-4">Our Values</h3>
            <div class="row text-center g-4 justify-content-center mt-3">
                <div class="col-lg-3 col-md-4 col-sm-6">
                    <div class="p-3 rounded-3 bg-white bg-opacity-50 backdrop-blur h-100 shadow-sm">
                        <h4 class="text-warning fw-bold">Safety First</h4>
                        <p>Your safety is our absolute priority. We meet top safety standards and maintain vigilance.</p>
                    </div>
                </div>
                <div class="col-lg-3 col-md-4 col-sm-6">
                    <div class="p-3 rounded-3 bg-white bg-opacity-50 backdrop-blur h-100 shadow-sm">
                        <h4 class="text-warning fw-bold">Customer-Centric</h4>
                        <p>We exceed passenger needs, offering personalized and seamless service.</p>
                    </div>
                </div>
                <div class="col-lg-3 col-md-4 col-sm-6">
                    <div class="p-3 rounded-3 bg-white bg-opacity-50 backdrop-blur h-100 shadow-sm">
                        <h4 class="text-warning fw-bold">Innovation</h4>
                        <p>We embrace technology for better booking, check-in, and in-flight experiences.</p>
                    </div>
                </div>
                <div class="col-lg-3 col-md-4 col-sm-6">
                    <div class="p-3 rounded-3 bg-white bg-opacity-50 backdrop-blur h-100 shadow-sm">
                        <h4 class="text-warning fw-bold">Sustainability</h4>
                        <p>We reduce environmental impact with fuel-efficient aircraft and green initiatives.</p>
                    </div>
                </div>
            </div>

            <div class="mt-5 p-4 rounded-3 bg-white bg-opacity-50 backdrop-blur shadow-sm">
                <h4 class="text-warning mb-3">Subscribe to Our Updates</h4>
                
                <asp:TextBox ID="txtName" runat="server" placeholder="Your Name" CssClass="form-control mb-2"></asp:TextBox>
                <asp:TextBox ID="txtEmail" runat="server" placeholder="Your Email" CssClass="form-control mb-2" TextMode="Email"></asp:TextBox>

                <asp:Button 
                    ID="btnSubscribe" 
                    runat="server" 
                    Text="Subscribe" 
                    CssClass="btn btn-warning w-100 fw-bold" 
                    OnClick="btnSubscribe_Click" />

                <asp:Label ID="lblMessage" runat="server" CssClass="mt-3 d-block"></asp:Label>
            </div>     
        </div>
    </div>
</asp:Content>
