# This script file creates reports for all modules
echo "***********************************************************************"
echo "                            ${design}                                  "
echo "                       report_default.tcl                              "
echo "                                                                       "
echo "***********************************************************************"

# report about lists all the black boxes in a design
report_black_boxes > "${log_path}${dir}${t_w_path}${design}_report_black_boxes.rpt"

# report user-defined constants
report_constants > "${log_path}${dir}${t_w_path}${design}_report_constants.rpt"

# report constraint
report_constraint > "${log_path}${dir}${t_w_path}${design}_report_constraints.rpt"

# report constraint type
report_constraint_type >> "${log_path}${dir}${t_w_path}${design}_report_constraints.rpt"

# report a list of containers
report_containers > "${log_path}${dir}${t_w_path}${design}_report_containers.rpt"

# report all user-defined cutpoints
report_cutpoints > "${log_path}${dir}${t_w_path}${design}_report_cutpoints.rpt"

# report about design libraries
report_design_libraries > "${log_path}${dir}${t_w_path}${design}_report_design_libraries.rpt"

# report about designs
report_designs > "${log_path}${dir}${t_w_path}${design}_report_designs.rpt"

# report compare points disabled by the set_dont_verify_points
report_dont_verify_points > "${log_path}${dir}${t_w_path}${design}_report_dont_verify_points.rpt"

# report .svf info
# 2 path
report_guidance -to ${log_path}${dir}${t_w_path}${design}_report_guidance
report_guidance -to ${svf_path}${dir}${t_w_path}${design}_report_guidance

# report info about technology libraries
report_libraries > "${log_path}${dir}${t_w_path}${design}_report_libraries.rpt"

# report loops or portions of loops
report_loops > "${log_path}${dir}${t_w_path}${design}_report_loops.rpt"

# report the current status of verification
report_status > "${log_path}${dir}${t_w_path}${design}_report_status.rpt"

# report a list of points matched byt the set_user_match command
report_user_matches > "${log_path}${dir}${t_w_path}${design}_report_user_matches.rpt"

# save the current Formality session including a design matched state.
save_session -replace "${log_path}${dir}${t_w_path}${design}_session"
