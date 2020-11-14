# This script file creates reports for all modules
echo "***********************************************************************"
echo "                            ${design}                                  "
echo "                         report_pass.tcl                               "
echo "                                                                       "
echo "***********************************************************************"

set status "pass/"

# report all design objects (including compare points) matched
report_matched_points > "${log_path}${dir}${t_w_path}${status}${design}_report_matched_points.rpt"

# report info about compare points that passed the most recent verification
report_passing_points > "${log_path}${dir}${t_w_path}${status}${design}_report_passing_points.rpt"
