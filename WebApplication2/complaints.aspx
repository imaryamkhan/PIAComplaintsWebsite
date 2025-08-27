<%@ Page Title="Complaints" Language="C#" MasterPageFile="~/Site1.Master" AutoEventWireup="true" CodeBehind="complaints.aspx.cs" Inherits="WebApplication2.complaints" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .complaints-container {
            max-width: 1000px;
            margin: 20px auto;
            padding: 20px;
        }
        
        .tab-buttons {
            display: flex;
            margin-bottom: 20px;
            border-bottom: 2px solid #007bff;
        }
        
        .tab-button {
            padding: 12px 24px;
            background: rgba(255,255,255,0.8);
            border: none;
            cursor: pointer;
            font-weight: bold;
            border-radius: 8px 8px 0 0;
            margin-right: 5px;
            transition: all 0.3s;
        }
        
        .tab-button.active {
            background: #007bff;
            color: white;
        }
        
        .tab-button:hover {
            background: #0056b3;
            color: white;
        }
        
        .tab-content {
            display: none;
            background: rgba(255, 255, 255, 0.95);
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
            backdrop-filter: blur(10px);
        }
        
        .tab-content.active {
            display: block;
        }
        
        .form-container h2 {
            text-align: center;
            margin-bottom: 30px;
            color: #007bff;
            font-weight: bold;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: bold;
            color: #333;
        }
        
        .form-control {
            width: 100%;
            padding: 12px;
            border: 2px solid #ddd;
            border-radius: 8px;
            font-size: 14px;
            transition: border-color 0.3s;
        }
        
        .form-control:focus {
            border-color: #007bff;
            outline: none;
            box-shadow: 0 0 5px rgba(0,123,255,0.3);
        }
        
        .btn-submit {
            width: 100%;
            padding: 15px;
            border: none;
            background: #007bff;
            color: white;
            font-weight: bold;
            font-size: 16px;
            border-radius: 8px;
            cursor: pointer;
            transition: background-color 0.3s;
        }
        
        .btn-submit:hover {
            background: #0056b3;
        }
        
        .btn-refresh {
            background: #28a745;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            margin-bottom: 20px;
            font-weight: bold;
        }
        
        .btn-refresh:hover {
            background: #218838;
        }
        
        .message-label {
            display: block;
            margin-top: 15px;
            padding: 10px;
            border-radius: 5px;
            text-align: center;
            font-weight: bold;
        }
        
        .user-info {
            background: #e7f3ff;
            padding: 10px;
            border-radius: 5px;
            border: 1px solid #007bff;
            color: #0066cc;
            font-weight: bold;
        }
        
        .complaints-grid {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        
        .complaints-grid th {
            background: #007bff;
            color: white;
            padding: 12px;
            text-align: left;
            font-weight: bold;
        }
        
        .complaints-grid td {
            padding: 12px;
            border-bottom: 1px solid #ddd;
            vertical-align: top;
        }
        
        .complaints-grid tr:nth-child(even) {
            background: #f8f9fa;
        }
        
        .complaints-grid tr:hover {
            background: #e3f2fd;
        }
        
        .status-pending {
            background: #ffc107;
            color: #000;
            padding: 4px 8px;
            border-radius: 15px;
            font-size: 12px;
            font-weight: bold;
        }
        
        .status-completed {
            background: #28a745;
            color: white;
            padding: 4px 8px;
            border-radius: 15px;
            font-size: 12px;
            font-weight: bold;
        }
        
        .status-open {
            background: #dc3545;
            color: white;
            padding: 4px 8px;
            border-radius: 15px;
            font-size: 12px;
            font-weight: bold;
        }
        
        .no-complaints {
            text-align: center;
            color: #666;
            font-style: italic;
            padding: 40px;
        }
        
        .summary-stats {
            display: flex;
            justify-content: space-around;
            margin-bottom: 20px;
        }
        
        .stat-box {
            background: linear-gradient(135deg, #007bff, #0056b3);
            color: white;
            padding: 15px;
            border-radius: 10px;
            text-align: center;
            min-width: 120px;
        }
        
        .stat-number {
            font-size: 24px;
            font-weight: bold;
            display: block;
        }
        
        .stat-label {
            font-size: 12px;
            opacity: 0.9;
        }
    </style>
 
    <script type="text/javascript">
        function showTab(tabName) {
            // Hide all tabs
            var tabs = document.getElementsByClassName('tab-content');
            for (var i = 0; i < tabs.length; i++) {
                tabs[i].classList.remove('active');
            }

            // Remove active class from all buttons
            var buttons = document.getElementsByClassName('tab-button');
            for (var i = 0; i < buttons.length; i++) {
                buttons[i].classList.remove('active');
            }

            // Show selected tab and activate button
            document.getElementById(tabName).classList.add('active');
            event.target.classList.add('active');

            // Store the active tab in a hidden field for postback persistence
            document.getElementById('<%= hfActiveTab.ClientID %>').value = tabName;
        }
        
        function initializeTabs() {
            // Get the active tab from server-side (hidden field)
            var activeTab = document.getElementById('<%= hfActiveTab.ClientID %>').value;

            // Default to new complaint tab if no active tab is set
            if (!activeTab || activeTab === '') {
                activeTab = 'newComplaintTab';
            }

            // Hide all tabs first
            var tabs = document.getElementsByClassName('tab-content');
            for (var i = 0; i < tabs.length; i++) {
                tabs[i].classList.remove('active');
            }

            // Remove active class from all buttons
            var buttons = document.getElementsByClassName('tab-button');
            for (var i = 0; i < buttons.length; i++) {
                buttons[i].classList.remove('active');
            }

            // Show the active tab
            var activeTabElement = document.getElementById(activeTab);
            if (activeTabElement) {
                activeTabElement.classList.add('active');
            }

            // Activate the corresponding button
            if (activeTab === 'newComplaintTab') {
                document.getElementsByClassName('tab-button')[0].classList.add('active');
            } else if (activeTab === 'viewComplaintsTab') {
                document.getElementsByClassName('tab-button')[1].classList.add('active');
            }
        }

        // Initialize tabs when page loads
        window.onload = function () {
            initializeTabs();
        }

        // Also initialize after postbacks
        function pageLoad() {
            initializeTabs();
        }
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <!-- Hidden field to maintain active tab state across postbacks -->
    <asp:HiddenField ID="hfActiveTab" runat="server" Value="newComplaintTab" />
    
    <div class="complaints-container">
        
        <!-- Tab Navigation -->
        <div class="tab-buttons">
            <button type="button" class="tab-button" onclick="showTab('newComplaintTab')">Submit New Complaint</button>
            <button type="button" class="tab-button" onclick="showTab('viewComplaintsTab')">View My Complaints</button>
        </div>
        
        <!-- New Complaint Tab -->
        <div id="newComplaintTab" class="tab-content">
            <div class="form-container">
                <h2>Submit a New Complaint</h2>
                
                <div class="form-group">
                    <label>Logged in as:</label>
                    <div class="user-info">
                        <asp:Label ID="lblUserEmail" runat="server"></asp:Label>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="txtSubject">Subject *</label>
                    <asp:TextBox ID="txtSubject" runat="server" CssClass="form-control" placeholder="Enter complaint subject" MaxLength="200"></asp:TextBox>
                </div>
                
                <div class="form-group">
                    <label for="txtMessage">Message *</label>
                    <asp:TextBox ID="txtMessage" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="6" placeholder="Describe your complaint in detail" MaxLength="1000"></asp:TextBox>
                </div>
                
                <div class="form-group">
                    <asp:Button ID="btnSubmit" runat="server" Text="Submit Complaint" CssClass="btn-submit" OnClick="btnSubmit_Click" />
                </div>
                
                <asp:Label ID="lblMessage" runat="server" CssClass="message-label"></asp:Label>
            </div>
        </div>
        
        <!-- View Complaints Tab -->
        <div id="viewComplaintsTab" class="tab-content">
            <h2>My Complaint History</h2>
            
            <asp:Button ID="btnRefresh" runat="server" Text="🔄 Refresh Status" CssClass="btn-refresh" OnClick="btnRefresh_Click" />
            
            <!-- Summary Statistics -->
            <div class="summary-stats">
                <div class="stat-box">
                    <span class="stat-number"><asp:Label ID="lblTotalComplaints" runat="server" Text="0"></asp:Label></span>
                    <span class="stat-label">Total</span>
                </div>
                <div class="stat-box">
                    <span class="stat-number"><asp:Label ID="lblPendingComplaints" runat="server" Text="0"></asp:Label></span>
                    <span class="stat-label">Pending</span>
                </div>
                <div class="stat-box">
                    <span class="stat-number"><asp:Label ID="lblCompletedComplaints" runat="server" Text="0"></asp:Label></span>
                    <span class="stat-label">Completed</span>
                </div>
            </div>
            
            <!-- Complaints Grid -->
            <asp:GridView ID="gvComplaints" runat="server" CssClass="complaints-grid" AutoGenerateColumns="false" 
                EmptyDataText="No complaints found." EmptyDataRowStyle-CssClass="no-complaints">
                <Columns>
                    <asp:BoundField DataField="ComplaintID" HeaderText="ID" ItemStyle-Width="50px" />
                    <asp:BoundField DataField="Subject" HeaderText="Subject" ItemStyle-Width="200px" />
                    <asp:BoundField DataField="Message" HeaderText="Message" ItemStyle-Width="300px" />
                    <asp:BoundField DataField="DateSubmitted" HeaderText="Date Submitted" DataFormatString="{0:dd/MM/yyyy HH:mm}" ItemStyle-Width="120px" />
                    <asp:TemplateField HeaderText="Status" ItemStyle-Width="100px">
                        <ItemTemplate>
                            <span class='<%# GetStatusClass(Eval("Status").ToString()) %>'>
                                <%# Eval("Status") %>
                            </span>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField DataField="ResponseMessage" HeaderText="Response" ItemStyle-Width="200px" />
                </Columns>
            </asp:GridView>
            
            <asp:Label ID="lblComplaintMessage" runat="server" CssClass="message-label"></asp:Label>
        </div>
    </div>
</asp:Content>