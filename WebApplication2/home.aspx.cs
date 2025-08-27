using System;
using System.Web.UI;
using System.Web.Security;

namespace WebApplication2
{
    public partial class homeaspx : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Session["UserEmail"] == null || Session["UserID"] == null)
                {
                    Response.Redirect("Login.aspx");
                    return;
                }

                string userEmail = Session["UserEmail"].ToString();
                string fullName = Session["FullName"] != null ? Session["FullName"].ToString() : userEmail;

                lblUser.Text = fullName;
            }
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();

            FormsAuthentication.SignOut();

            Response.Redirect("Login.aspx");
        }
    }
}