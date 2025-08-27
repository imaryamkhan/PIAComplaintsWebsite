using System;
using System.Web;
using System.Threading;

namespace WebApplication2
{
    public class Global : HttpApplication
    {
        private static Timer statusUpdateTimer;
        
        protected void Application_Start(object sender, EventArgs e)
        {
            // Initialize the complaint status update timer
            InitializeComplaintStatusUpdater();
        }
        
        protected void Application_End(object sender, EventArgs e)
        {
            // Clean up the timer when application ends
            if (statusUpdateTimer != null)
            {
                statusUpdateTimer.Dispose();
                statusUpdateTimer = null;
            }
        }
        
        protected void Session_Start(object sender, EventArgs e)
        {
            // Trigger status update when a new session starts
            // This ensures statuses are updated when users visit the site
            ThreadPool.QueueUserWorkItem(state => 
            {
                ComplaintStatusService.UpdateComplaintStatuses();
            });
        }
        
        private void InitializeComplaintStatusUpdater()
        {
            try
            {
                // Run initial update
                ComplaintStatusService.UpdateComplaintStatuses();
                
                // Set up timer to run every 30 minutes
                TimeSpan interval = TimeSpan.FromMinutes(30);
                
                statusUpdateTimer = new Timer(
                    callback: TimerCallback,
                    state: null,
                    dueTime: interval,
                    period: interval
                );
                
                System.Diagnostics.Debug.WriteLine("Complaint status updater initialized successfully");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error initializing complaint status updater: {ex.Message}");
            }
        }
        
        private void TimerCallback(object state)
        {
            try
            {
                // Update complaint statuses
                ComplaintStatusService.UpdateComplaintStatuses();
                
                // Optional: Archive old complaints once a day
                if (DateTime.Now.Hour == 2) // Run at 2 AM
                {
                    int archivedCount = ComplaintStatusService.ArchiveOldComplaints();
                    if (archivedCount > 0)
                    {
                        System.Diagnostics.Debug.WriteLine($"Archived {archivedCount} old complaints");
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error in timer callback: {ex.Message}");
            }
        }
        
        protected void Application_Error(object sender, EventArgs e)
        {
            // Handle application errors
            Exception ex = Server.GetLastError();
            if (ex != null)
            {
                System.Diagnostics.Debug.WriteLine($"Application Error: {ex.Message}");
                
                // Optional: Log to file or database
                try
                {
                    string logPath = Server.MapPath("~/App_Data/ApplicationErrors.txt");
                    string errorMessage = $"[{DateTime.Now}] {ex.ToString()}{Environment.NewLine}";
                    System.IO.File.AppendAllText(logPath, errorMessage);
                }
                catch
                {
                    // Ignore logging errors
                }
            }
        }
    }
}