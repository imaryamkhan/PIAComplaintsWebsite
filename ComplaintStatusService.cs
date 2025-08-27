using System;
using System.Configuration;
using System.Data.SqlClient;

namespace WebApplication2
{
    /// <summary>
    /// Service class to handle automated complaint status updates
    /// Can be called from Global.asax Application_Start or as a scheduled task
    /// </summary>
    public class ComplaintStatusService
    {
        private static readonly object lockObject = new object();
        private static DateTime lastUpdateTime = DateTime.MinValue;

        /// <summary>
        /// Updates complaint statuses based on time elapsed
        /// Thread-safe implementation
        /// </summary>
        public static void UpdateComplaintStatuses()
        {
            lock (lockObject)
            {
                // Prevent multiple simultaneous updates
                if (DateTime.Now.Subtract(lastUpdateTime).TotalMinutes < 5)
                {
                    return; // Skip if updated recently (within 5 minutes)
                }

                try
                {
                    string cs = ConfigurationManager.ConnectionStrings["piaConnectionString"].ConnectionString;

                    using (SqlConnection con = new SqlConnection(cs))
                    {
                        con.Open();

                        // Count of updates made
                        int completedUpdates = 0;
                        int pendingUpdates = 0;

                        // Update complaints older than 24 hours to "Completed"
                        string completeQuery = @"
                            UPDATE dbo.Complaints 
                            SET Status = 'Completed',
                                ResponseMessage = CASE 
                                    WHEN ResponseMessage IS NULL OR ResponseMessage = ''
                                    THEN 'Thank you for your complaint. This matter has been reviewed and resolved by our team. If you need further assistance, please submit a new complaint.'
                                    ELSE ResponseMessage
                                END,
                                LastUpdated = GETDATE()
                            WHERE DateSubmitted <= DATEADD(HOUR, -24, GETDATE()) 
                            AND Status IN ('Open', 'Pending')";

                        using (SqlCommand cmd = new SqlCommand(completeQuery, con))
                        {
                            completedUpdates = cmd.ExecuteNonQuery();
                        }

                        // Update complaints between 1-24 hours to "Pending"
                        string pendingQuery = @"
                            UPDATE dbo.Complaints 
                            SET Status = 'Pending',
                                ResponseMessage = CASE 
                                    WHEN ResponseMessage IS NULL OR ResponseMessage = ''
                                    THEN 'Your complaint is being reviewed by our team. We will provide a resolution soon.'
                                    ELSE ResponseMessage
                                END,
                                LastUpdated = GETDATE()
                            WHERE DateSubmitted > DATEADD(HOUR, -24, GETDATE()) 
                            AND DateSubmitted <= DATEADD(HOUR, -1, GETDATE())
                            AND Status = 'Open'";

                        using (SqlCommand cmd = new SqlCommand(pendingQuery, con))
                        {
                            pendingUpdates = cmd.ExecuteNonQuery();
                        }

                        lastUpdateTime = DateTime.Now;

                        // Log the update results
                        System.Diagnostics.Debug.WriteLine($"Complaint Status Update: {completedUpdates} completed, {pendingUpdates} pending at {DateTime.Now}");

                        // Optional: Write to event log or application log
                        LogStatusUpdate(completedUpdates, pendingUpdates);
                    }
                }
                catch (Exception ex)
                {
                    // Log error but don't throw - we don't want to break the application
                    System.Diagnostics.Debug.WriteLine($"Error updating complaint statuses: {ex.Message}");
                    LogError(ex);
                }
            }
        }

        /// <summary>
        /// Gets complaint statistics
        /// </summary>
        public static ComplaintStats GetComplaintStatistics()
        {
            try
            {
                string cs = ConfigurationManager.ConnectionStrings["piaConnectionString"].ConnectionString;

                using (SqlConnection con = new SqlConnection(cs))
                {
                    con.Open();

                    string query = @"
                        SELECT 
                            COUNT(*) as Total,
                            SUM(CASE WHEN Status = 'Open' THEN 1 ELSE 0 END) as OpenCount,
                            SUM(CASE WHEN Status = 'Pending' THEN 1 ELSE 0 END) as PendingCount,
                            SUM(CASE WHEN Status = 'Completed' THEN 1 ELSE 0 END) as CompletedCount
                        FROM dbo.Complaints";

                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                return new ComplaintStats
                                {
                                    Total = Convert.ToInt32(reader["Total"]),
                                    Open = Convert.ToInt32(reader["OpenCount"]),
                                    Pending = Convert.ToInt32(reader["PendingCount"]),
                                    Completed = Convert.ToInt32(reader["CompletedCount"])
                                };
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting complaint statistics: {ex.Message}");
            }

            return new ComplaintStats(); // Return empty stats if error
        }

        /// <summary>
        /// Manually resolve a specific complaint
        /// </summary>
        public static bool ResolveComplaint(int complaintId, string responseMessage = null)
        {
            try
            {
                string cs = ConfigurationManager.ConnectionStrings["piaConnectionString"].ConnectionString;

                using (SqlConnection con = new SqlConnection(cs))
                {
                    con.Open();

                    string defaultResponse = "Your complaint has been reviewed and resolved by our support team.";
                    string finalResponse = string.IsNullOrEmpty(responseMessage) ? defaultResponse : responseMessage;

                    string updateQuery = @"
                        UPDATE dbo.Complaints 
                        SET Status = 'Completed',
                            ResponseMessage = @ResponseMessage,
                            LastUpdated = GETDATE()
                        WHERE ComplaintID = @ComplaintID";

                    using (SqlCommand cmd = new SqlCommand(updateQuery, con))
                    {
                        cmd.Parameters.AddWithValue("@ComplaintID", complaintId);
                        cmd.Parameters.AddWithValue("@ResponseMessage", finalResponse);

                        return cmd.ExecuteNonQuery() > 0;
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error resolving complaint {complaintId}: {ex.Message}");
                return false;
            }
        }

        /// <summary>
        /// Clean up old completed complaints (older than 90 days)
        /// </summary>
        public static int ArchiveOldComplaints()
        {
            try
            {
                string cs = ConfigurationManager.ConnectionStrings["piaConnectionString"].ConnectionString;

                using (SqlConnection con = new SqlConnection(cs))
                {
                    con.Open();

                    // Archive complaints older than 90 days
                    string archiveQuery = @"
                        DELETE FROM dbo.Complaints 
                        WHERE Status = 'Completed' 
                        AND DateSubmitted <= DATEADD(DAY, -90, GETDATE())";

                    using (SqlCommand cmd = new SqlCommand(archiveQuery, con))
                    {
                        return cmd.ExecuteNonQuery();
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error archiving old complaints: {ex.Message}");
                return 0;
            }
        }

        private static void LogStatusUpdate(int completed, int pending)
        {
            // You can implement logging to file, database, or event log here
            string logMessage = $"[{DateTime.Now}] Complaint Status Update: {completed} completed, {pending} pending";

            // Example: Write to a log file
            try
            {
                string logPath = System.Web.HttpContext.Current.Server.MapPath("~/App_Data/ComplaintLogs.txt");
                System.IO.File.AppendAllText(logPath, logMessage + Environment.NewLine);
            }
            catch
            {
                // Ignore file logging errors
            }
        }

        private static void LogError(Exception ex)
        {
            // You can implement error logging here
            string errorMessage = $"[{DateTime.Now}] ERROR in ComplaintStatusService: {ex.Message}";

            try
            {
                string logPath = System.Web.HttpContext.Current.Server.MapPath("~/App_Data/ErrorLogs.txt");
                System.IO.File.AppendAllText(logPath, errorMessage + Environment.NewLine);
            }
            catch
            {
                // Ignore file logging errors
            }
        }
    }

    /// <summary>
    /// Data structure to hold complaint statistics
    /// </summary>
    public class ComplaintStats
    {
        public int Total { get; set; }
        public int Open { get; set; }
        public int Pending { get; set; }
        public int Completed { get; set; }
    }
}