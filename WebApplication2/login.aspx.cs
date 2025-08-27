using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.Security;

namespace WebApplication2
{
    public partial class Login : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (User.Identity.IsAuthenticated)
                {
                    Response.Redirect("home.aspx");
                }
            }
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            string email = txtEmail.Text.Trim();
            string password = txtPassword.Text.Trim();

            if (string.IsNullOrEmpty(email) || string.IsNullOrEmpty(password))
            {
                lblMessage.Text = "Please enter both email and password.";
                return;
            }

            try
            {
                string cs = ConfigurationManager.ConnectionStrings["piaConnectionString"].ConnectionString;

                using (SqlConnection con = new SqlConnection(cs))
                {
                    con.Open();
                    string query = "SELECT UserID, Password, FullName FROM Users WHERE Email = @Email";

                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@Email", email);

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                string dbPassword = reader["Password"].ToString();
                                int userId = Convert.ToInt32(reader["UserID"]);
                                string fullName = reader["FullName"].ToString();

                                if (dbPassword == password)
                                {
                                    Session["UserID"] = userId;
                                    Session["UserEmail"] = email;
                                    Session["FullName"] = fullName;

                                    FormsAuthentication.SetAuthCookie(email, false);

                                    Response.Redirect("home.aspx");
                                }
                                else
                                {
                                    lblMessage.Text = "Invalid password. Please try again.";
                                }
                            }
                            else
                            {
                                lblMessage.Text = "Email not found. Please check your email or sign up.";
                            }
                        }
                    }
                }
            }
            catch (SqlException ex)
            {
                lblMessage.Text = "Database connection error. Please try again later.";
            }
            catch (Exception ex)
            {
                lblMessage.Text = "An error occurred. Please try again.";
            }
        }
    }
}