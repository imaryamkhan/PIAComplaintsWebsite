using System;
using System.Data.SqlClient;
using System.Configuration;
using System.Drawing;

namespace WebApplication2
{
    public partial class requirementsandprocedure : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                lblMessage.Text = "";
            }
        }

        protected void btnSubscribe_Click(object sender, EventArgs e)
        {
            string name = txtName.Text.Trim();
            string email = txtEmail.Text.Trim();

            if (string.IsNullOrEmpty(name) || string.IsNullOrEmpty(email))
            {
                ShowMessage("Please fill in all fields.", Color.Red);
                return;
            }

            if (name.Length < 2)
            {
                ShowMessage("Name must be at least 2 characters long.", Color.Red);
                return;
            }

            if (!IsValidEmail(email))
            {
                ShowMessage("Please enter a valid email address.", Color.Red);
                return;
            }

            try
            {
                string connectionString = ConfigurationManager.ConnectionStrings["piaConnectionString"].ConnectionString;

                if (string.IsNullOrEmpty(connectionString))
                {
                    ShowMessage("Database connection not configured properly.", Color.Red);
                    return;
                }

                using (SqlConnection con = new SqlConnection(connectionString))
                {
                    con.Open();

                    string checkQuery = "SELECT COUNT(*) FROM dbo.Subscribers WHERE Email = @Email";
                    using (SqlCommand checkCmd = new SqlCommand(checkQuery, con))
                    {
                        checkCmd.Parameters.AddWithValue("@Email", email);
                        int exists = (int)checkCmd.ExecuteScalar();

                        if (exists > 0)
                        {
                            ShowMessage("This email is already subscribed to our updates!", Color.Orange);
                            return;
                        }
                    }

                    string insertQuery = "INSERT INTO dbo.Subscribers (Name, Email, SubscribedDate, IsActive) VALUES (@Name, @Email, @SubscribedDate, @IsActive)";
                    using (SqlCommand cmd = new SqlCommand(insertQuery, con))
                    {
                        cmd.Parameters.AddWithValue("@Name", name);
                        cmd.Parameters.AddWithValue("@Email", email);
                        cmd.Parameters.AddWithValue("@SubscribedDate", DateTime.Now);
                        cmd.Parameters.AddWithValue("@IsActive", true);

                        int result = cmd.ExecuteNonQuery();

                        if (result > 0)
                        {
                            ShowMessage("Thank you for subscribing! You'll receive updates about our internship programs.", Color.Green);

                            txtName.Text = "";
                            txtEmail.Text = "";
                        }
                        else
                        {
                            ShowMessage("Failed to subscribe. Please try again.", Color.Red);
                        }
                    }
                }
            }
            catch (SqlException sqlEx)
            {
                string errorMsg = $"Database Error: {sqlEx.Message}";
                if (sqlEx.Message.Contains("Invalid object name"))
                {
                    errorMsg = "Database tables not found. Please contact administrator.";
                }
                else if (sqlEx.Message.Contains("connection"))
                {
                    errorMsg = "Cannot connect to database. Please check connection.";
                }
                else if (sqlEx.Message.Contains("duplicate key"))
                {
                    errorMsg = "This email is already subscribed.";
                }

                ShowMessage(errorMsg, Color.Red);

                System.Diagnostics.Debug.WriteLine($"SQL Error in Subscribe: {sqlEx.ToString()}");
            }
            catch (Exception ex)
            {
                ShowMessage($"Unexpected Error: {ex.Message}", Color.Red);
                System.Diagnostics.Debug.WriteLine($"General Error in Subscribe: {ex.ToString()}");
            }
        }

        private void ShowMessage(string message, Color color)
        {
            lblMessage.Text = message;
            lblMessage.ForeColor = color;
            lblMessage.Visible = true;
        }

        private bool IsValidEmail(string email)
        {
            try
            {
                var mailAddress = new System.Net.Mail.MailAddress(email);
                return mailAddress.Address == email;
            }
            catch (FormatException)
            {
                return false;
            }
        }
    }
}