# This script file creates reports for all modules
echo "***********************************************************************"
echo "                            ${design}                                  "
echo "                         report_fail.tcl                               "
echo "                                                                       "
echo "***********************************************************************"
set status "fail/"
# report info about compare points not verified
report_aborted_points > "${log_path}${dir}${t_w_path}${status}${design}_report_aborted_points.rpt"

# report info about matching region for the most recent diagnosis
report_diagnosed_matching_region > "${log_path}${dir}${t_w_path}${status}${design}_report_diagnose.rpt"

# report about error candidates for most recent verification
report_error_candidates > "${log_path}${dir}${t_w_path}${status}${design}_report_error_candidates.rpt"

# report info about compare points that fail verification
report_failing_points > "${log_path}${dir}${t_w_path}${status}${design}_report_failing_points.rpt"

# report and summarizes th rtl and synthesis mismatches during design linking
report_hdlin_mismatches > "${log_path}${dir}${t_w_path}${status}${design}_report_hdlin_mismatches.rpt"

# report points that have not been matched
report_unmatched_points > "${log_path}${dir}${t_w_path}${status}${design}_report_unmatched_points.rpt"

# report info about compare points that you have verified
report_unverified_points > "${log_path}${dir}${t_w_path}${status}${design}_report_unverified_points.rpt"
