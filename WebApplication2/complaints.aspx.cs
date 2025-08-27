using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Web.UI.WebControls;

namespace WebApplication2
{
    public partial class complaints : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Session["UserEmail"] == null || Session["UserID"] == null)
                {
                    lblComplaintMessage.Text = "DEBUG: Session expired. Please login again.";
                    lblComplaintMessage.ForeColor = System.Drawing.Color.Red;
                    lblComplaintMessage.Visible = true;

                    System.Diagnostics.Debug.WriteLine("DEBUG: User session is null - redirecting to login");
                    Response.Redirect("Login.aspx");
                    return;
                }

                System.Diagnostics.Debug.WriteLine($"DEBUG: UserID = {Session["UserID"]}");
                System.Diagnostics.Debug.WriteLine($"DEBUG: UserEmail = {Session["UserEmail"]}");

                lblUserEmail.Text = Session["UserEmail"].ToString();
                lblMessage.Text = "";
                lblComplaintMessage.Text = "";

                // Set default tab to new complaint
                hfActiveTab.Value = "newComplaintTab";

                try
                {
                    string cs = ConfigurationManager.ConnectionStrings["piaConnectionString"]?.ConnectionString;
                    if (string.IsNullOrEmpty(cs))
                    {
                        lblComplaintMessage.Text = "DEBUG: Database connection string is missing!";
                        lblComplaintMessage.ForeColor = System.Drawing.Color.Red;
                        lblComplaintMessage.Visible = true;
                        System.Diagnostics.Debug.WriteLine("DEBUG: Connection string is null or empty");
                        return;
                    }

                    System.Diagnostics.Debug.WriteLine("DEBUG: Connection string found, testing database...");

                    using (SqlConnection testCon = new SqlConnection(cs))
                    {
                        testCon.Open();
                        System.Diagnostics.Debug.WriteLine("DEBUG: Database connection successful");

                        string testQuery = "SELECT COUNT(*) FROM dbo.Complaints";
                        using (SqlCommand testCmd = new SqlCommand(testQuery, testCon))
                        {
                            int count = (int)testCmd.ExecuteScalar();
                            System.Diagnostics.Debug.WriteLine($"DEBUG: Found {count} total complaints in database");
                        }
                    }
                }
                catch (Exception ex)
                {
                    lblComplaintMessage.Text = $"DEBUG: Database error - {ex.Message}";
                    lblComplaintMessage.ForeColor = System.Drawing.Color.Red;
                    lblComplaintMessage.Visible = true;
                    System.Diagnostics.Debug.WriteLine($"DEBUG: Database connection failed - {ex.Message}");
                }

                System.Diagnostics.Debug.WriteLine("DEBUG: About to update complaint statuses...");
                UpdateComplaintStatuses();

                System.Diagnostics.Debug.WriteLine("DEBUG: About to load user complaints...");
                LoadUserComplaints();

                System.Diagnostics.Debug.WriteLine("DEBUG: Page_Load completed successfully");
            }
        }

        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            // Keep the new complaint tab active after submit
            hfActiveTab.Value = "newComplaintTab";

            if (Session["UserID"] == null)
            {
                ShowMessage("Error: You must be logged in to submit a complaint.", Color.Red);
                Response.Redirect("Login.aspx");
                return;
            }

            int userId;
            if (!int.TryParse(Session["UserID"].ToString(), out userId))
            {
                ShowMessage("Error: Invalid user session. Please login again.", Color.Red);
                Response.Redirect("Login.aspx");
                return;
            }

            string subject = txtSubject.Text.Trim();
            string message = txtMessage.Text.Trim();

            if (string.IsNullOrEmpty(subject) || string.IsNullOrEmpty(message))
            {
                ShowMessage("Please fill in both subject and message fields.", Color.Red);
                return;
            }

            if (subject.Length < 5)
            {
                ShowMessage("Subject must be at least 5 characters long.", Color.Red);
                return;
            }

            if (message.Length < 10)
            {
                ShowMessage("Message must be at least 10 characters long.", Color.Red);
                return;
            }

            try
            {
                string cs = ConfigurationManager.ConnectionStrings["piaConnectionString"].ConnectionString;

                if (string.IsNullOrEmpty(cs))
                {
                    ShowMessage("Database connection not configured properly.", Color.Red);
                    return;
                }

                using (SqlConnection con = new SqlConnection(cs))
                {
                    con.Open();

                    string userCheckQuery = "SELECT COUNT(*) FROM dbo.Users WHERE UserID = @UserID";
                    using (SqlCommand userCheck = new SqlCommand(userCheckQuery, con))
                    {
                        userCheck.Parameters.AddWithValue("@UserID", userId);
                        int userExists = (int)userCheck.ExecuteScalar();

                        if (userExists == 0)
                        {
                            ShowMessage("User not found. Please login again.", Color.Red);
                            Response.Redirect("Login.aspx");
                            return;
                        }
                    }

                    string insertQuery = @"INSERT INTO dbo.Complaints (UserID, Subject, Message, DateSubmitted, Status) 
                                         VALUES (@UserID, @Subject, @Message, @DateSubmitted, @Status)";

                    using (SqlCommand cmd = new SqlCommand(insertQuery, con))
                    {
                        cmd.Parameters.AddWithValue("@UserID", userId);
                        cmd.Parameters.AddWithValue("@Subject", subject);
                        cmd.Parameters.AddWithValue("@Message", message);
                        cmd.Parameters.AddWithValue("@DateSubmitted", DateTime.Now);
                        cmd.Parameters.AddWithValue("@Status", "Open");

                        int result = cmd.ExecuteNonQuery();

                        if (result > 0)
                        {
                            ShowMessage("Complaint submitted successfully! You can view its status in the 'View My Complaints' tab.", Color.Green);

                            txtSubject.Text = "";
                            txtMessage.Text = "";

                            // Refresh the complaints data
                            LoadUserComplaints();
                        }
                        else
                        {
                            ShowMessage("Failed to submit complaint. Please try again.", Color.Red);
                        }
                    }
                }
            }
            catch (SqlException sqlEx)
            {
                string errorMsg = GetSqlErrorMessage(sqlEx);
                ShowMessage(errorMsg, Color.Red);
                System.Diagnostics.Debug.WriteLine($"SQL Error in Complaints: {sqlEx.ToString()}");
            }
            catch (Exception ex)
            {
                ShowMessage($"Unexpected Error: {ex.Message}", Color.Red);
                System.Diagnostics.Debug.WriteLine($"General Error in Complaints: {ex.ToString()}");
            }
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            // Keep the view complaints tab active after refresh
            hfActiveTab.Value = "viewComplaintsTab";

            UpdateComplaintStatuses();
            LoadUserComplaints();
            ShowComplaintMessage("Complaint statuses refreshed!", Color.Green);
        }

        private void LoadUserComplaints()
        {
            if (Session["UserID"] == null) return;

            int userId = Convert.ToInt32(Session["UserID"]);

            try
            {
                string cs = ConfigurationManager.ConnectionStrings["piaConnectionString"].ConnectionString;

                using (SqlConnection con = new SqlConnection(cs))
                {
                    con.Open();

                    string query = @"SELECT 
                                        ComplaintID,
                                        Subject,
                                        CASE 
                                            WHEN LEN(Message) > 100 THEN SUBSTRING(Message, 1, 100) + '...'
                                            ELSE Message
                                        END as Message,
                                        DateSubmitted,
                                        Status,
                                        ISNULL(ResponseMessage, 'No response yet') as ResponseMessage
                                    FROM dbo.Complaints 
                                    WHERE UserID = @UserID 
                                    ORDER BY DateSubmitted DESC";

                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@UserID", userId);

                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        gvComplaints.DataSource = dt;
                        gvComplaints.DataBind();

                        UpdateSummaryStats(dt);

                        System.Diagnostics.Debug.WriteLine($"DEBUG: Loaded {dt.Rows.Count} complaints for user {userId}");
                    }
                }
            }
            catch (Exception ex)
            {
                ShowComplaintMessage($"Error loading complaints: {ex.Message}", Color.Red);
                System.Diagnostics.Debug.WriteLine($"Error in LoadUserComplaints: {ex.ToString()}");
            }
        }

        private void UpdateComplaintStatuses()
        {
            try
            {
                string cs = ConfigurationManager.ConnectionStrings["piaConnectionString"].ConnectionString;

                using (SqlConnection con = new SqlConnection(cs))
                {
                    con.Open();

                    // Auto-complete complaints older than 24 hours
                    string updateQuery = @"UPDATE dbo.Complaints 
                                          SET Status = 'Completed',
                                              ResponseMessage = 'Thank you for your complaint. This matter has been reviewed and resolved by our team.'
                                          WHERE DateSubmitted <= DATEADD(HOUR, -24, GETDATE()) 
                                          AND Status IN ('Open', 'Pending')";

                    using (SqlCommand cmd = new SqlCommand(updateQuery, con))
                    {
                        int updatedRows = cmd.ExecuteNonQuery();

                        if (updatedRows > 0)
                        {
                            System.Diagnostics.Debug.WriteLine($"Updated {updatedRows} complaints to Completed status");
                        }
                    }

                    // Set pending status for complaints between 1-24 hours old
                    string pendingQuery = @"UPDATE dbo.Complaints 
                                           SET Status = 'Pending'
                                           WHERE DateSubmitted > DATEADD(HOUR, -24, GETDATE()) 
                                           AND DateSubmitted <= DATEADD(HOUR, -1, GETDATE())
                                           AND Status = 'Open'";

                    using (SqlCommand cmd2 = new SqlCommand(pendingQuery, con))
                    {
                        int pendingRows = cmd2.ExecuteNonQuery();

                        if (pendingRows > 0)
                        {
                            System.Diagnostics.Debug.WriteLine($"Updated {pendingRows} complaints to Pending status");
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error updating complaint statuses: {ex.ToString()}");
            }
        }

        private void UpdateSummaryStats(DataTable dt)
        {
            if (dt != null)
            {
                lblTotalComplaints.Text = dt.Rows.Count.ToString();

                int pendingCount = 0;
                int completedCount = 0;

                foreach (DataRow row in dt.Rows)
                {
                    string status = row["Status"].ToString();
                    if (status == "Pending" || status == "Open")
                        pendingCount++;
                    else if (status == "Completed")
                        completedCount++;
                }

                lblPendingComplaints.Text = pendingCount.ToString();
                lblCompletedComplaints.Text = completedCount.ToString();
            }
            else
            {
                lblTotalComplaints.Text = "0";
                lblPendingComplaints.Text = "0";
                lblCompletedComplaints.Text = "0";
            }
        }

        protected string GetStatusClass(string status)
        {
            switch (status.ToLower())
            {
                case "open":
                    return "status-open";
                case "pending":
                    return "status-pending";
                case "completed":
                    return "status-completed";
                default:
                    return "status-open";
            }
        }

        private void ShowMessage(string message, Color color)
        {
            lblMessage.Text = message;
            lblMessage.ForeColor = color;
            lblMessage.Visible = true;
        }

        private void ShowComplaintMessage(string message, Color color)
        {
            lblComplaintMessage.Text = message;
            lblComplaintMessage.ForeColor = color;
            lblComplaintMessage.Visible = true;
        }

        private string GetSqlErrorMessage(SqlException sqlEx)
        {
            if (sqlEx.Message.Contains("Invalid object name"))
            {
                return "Database tables not found. Please contact administrator.";
            }
            else if (sqlEx.Message.Contains("connection"))
            {
                return "Cannot connect to database. Please check connection.";
            }
            else
            {
                return $"Database Error: {sqlEx.Message}";
            }
        }
    }
}