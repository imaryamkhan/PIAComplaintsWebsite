using System;
using System.Data.SqlClient;
using System.Configuration;
using System.Drawing;

namespace WebApplication2
{
    public partial class Signup : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                lblMessage.Text = "";
            }
        }

        protected void btnSignup_Click(object sender, EventArgs e)
        {
            string fullName = txtFullName.Text.Trim();
            string email = txtEmail.Text.Trim();
            string password = txtPassword.Text.Trim();

            // Input validation
            if (string.IsNullOrEmpty(fullName) || string.IsNullOrEmpty(email) || string.IsNullOrEmpty(password))
            {
                ShowMessage("Please fill in all fields.", Color.Red);
                return;
            }

            if (fullName.Length < 2)
            {
                ShowMessage("Full name must be at least 2 characters long.", Color.Red);
                return;
            }

            if (password.Length < 6)
            {
                ShowMessage("Password must be at least 6 characters long.", Color.Red);
                return;
            }

            if (!IsValidEmail(email))
            {
                ShowMessage("Please enter a valid email address.", Color.Red);
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

                    string checkQuery = "SELECT COUNT(*) FROM dbo.Users WHERE Email = @Email";
                    using (SqlCommand checkCmd = new SqlCommand(checkQuery, con))
                    {
                        checkCmd.Parameters.AddWithValue("@Email", email);
                        int exists = (int)checkCmd.ExecuteScalar();

                        if (exists > 0)
                        {
                            ShowMessage("Email already registered! Please use a different email.", Color.Red);
                            return;
                        }
                    }

                    string insertQuery = "INSERT INTO dbo.Users (FullName, Email, Password, DateCreated, IsActive) VALUES (@FullName, @Email, @Password, @DateCreated, @IsActive)";
                    using (SqlCommand cmd = new SqlCommand(insertQuery, con))
                    {
                        cmd.Parameters.AddWithValue("@FullName", fullName);
                        cmd.Parameters.AddWithValue("@Email", email);
                        cmd.Parameters.AddWithValue("@Password", password);
                        cmd.Parameters.AddWithValue("@DateCreated", DateTime.Now);
                        cmd.Parameters.AddWithValue("@IsActive", true);

                        int result = cmd.ExecuteNonQuery();

                        if (result > 0)
                        {
                            ShowMessage("Account created successfully! You can now login.", Color.Green);

                            txtFullName.Text = "";
                            txtEmail.Text = "";
                            txtPassword.Text = "";

                            ClientScript.RegisterStartupScript(this.GetType(), "Redirect",
                                "setTimeout(function(){ window.location.href='Login.aspx'; }, 3000);", true);
                        }
                        else
                        {
                            ShowMessage("Failed to create account. Please try again.", Color.Red);
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
                else if (sqlEx.Message.Contains("duplicate key") || sqlEx.Message.Contains("UNIQUE constraint"))
                {
                    errorMsg = "This email is already registered.";
                }

                ShowMessage(errorMsg, Color.Red);

                System.Diagnostics.Debug.WriteLine($"SQL Error in Signup: {sqlEx.ToString()}");
            }
            catch (Exception ex)
            {
                ShowMessage($"Unexpected Error: {ex.Message}", Color.Red);
                System.Diagnostics.Debug.WriteLine($"General Error in Signup: {ex.ToString()}");
            }
        }

        protected void btnGoLogin_Click(object sender, EventArgs e)
        {
            Response.Redirect("Login.aspx");
        }

        private void ShowMessage(string message, Color color)
        {
            lblMessage.Text = message;
            lblMessage.ForeColor = color;
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