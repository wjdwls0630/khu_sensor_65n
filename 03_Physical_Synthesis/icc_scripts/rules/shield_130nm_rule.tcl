#remove_routing_rules shield_130nm_rule
#ekyoo revision
#Jung Jin Park revision DATE : 2020.08.27

define_routing_rule shield_130nm_rule -default_reference_rule \
-widths          {MET1 0.16 MET2 0.2 MET3 0.2 MET4 0.2 MET5 0.2 MET6 0.44} \
-spacings        {MET1 0.16 MET2 0.2 MET3 0.2 MET4 0.2 MET5 0.2 MET6 0.44} \
-shield_widths   {MET1 0 MET2 0 MET3 0.2 MET4 0.2 MET5 0.2 MET6 0.44} \
-shield_spacings {MET1 0 MET2 0 MET3 0.2 MET4 0.2 MET5 0.4 MET6 0.8}

report_routing_rules shield_130nm_rule
