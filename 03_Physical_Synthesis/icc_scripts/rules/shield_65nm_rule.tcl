#remove_routing_rules shield_65nm_rule
#ekyoo revision

define_routing_rule shield_65nm_rule -default_reference_rule \
-widths          {M1 0.1 M2 0.1 M3 0.1 M4 0.1 B1 0.2 B2 0.2 EA 0.4 OA 1.2} \
-spacings        {M1 0.1 M2 0.1 M3 0.1 M4 0.1 B1 0.2 B2 0.2 EA 0.4 OA 1.2 } \
-shield_widths   {M1 0 M2 0 M3 0.1 M4 0.1 B1 0.2 B2 0.2 EA 0.4 OA 1.2 } \
-shield_spacings {M1 0 M2 0 M3 0.2 M4 0.2 B1 0.4 B2 0.4 EA 0.8 OA 2.4}

report_routing_rules shield_65nm_rule
