using System;
using System.Web;
using System.Web.Security;

namespace WebApplication2
{
    public partial class Logout : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            try
            {
                Session.Clear();
                Session.Abandon();

                FormsAuthentication.SignOut();

                if (Request.Cookies[FormsAuthentication.FormsCookieName] != null)
                {
                    HttpCookie authCookie = new HttpCookie(FormsAuthentication.FormsCookieName, "");
                    authCookie.Expires = DateTime.Now.AddYears(-1);
                    Response.Cookies.Add(authCookie);
                }

                Response.Redirect("Login.aspx");
            }
            catch (Exception ex)
            {
                Response.Redirect("Login.aspx");
            }
        }
    }
}