using System;
using System.Web;
using System.Web.UI;

namespace WebApplication2
{
    public partial class Site1 : MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
          
            if (Session["UserEmail"] == null || Session["UserID"] == null)
            {
                Response.Redirect("Login.aspx");
            }
        }
    }
}