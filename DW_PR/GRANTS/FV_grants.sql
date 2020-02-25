--DW Policy Grants
GRANT SELECT ON insis_gen_v10.policy_agents TO insis_cust_addon;
GRANT SELECT ON insis_gen_v10.hst_payment_type TO insis_cust_addon;
GRANT SELECT ON insis_gen_v10.policy_conditions TO insis_cust_addon;
GRANT SELECT ON insis_gen_v10.POLICY_NAMES TO insis_cust_addon;
GRANT SELECT ON insis_gen_v10.gen_annex_reason TO insis_cust_addon;
GRANT SELECT ON insis_gen_v10.ht_annex_reason TO insis_cust_addon;

--Create Event
GRANT EXECUTE ON INSIS_CUST_ADDON.MANAGER_CREATE_EVENT TO insis_sys_v10;
GRANT EXECUTE ON INSIS_CUST_ADDON.CUST_EVENTS TO insis_sys_v10;

--DW Policy Grants
GRANT SELECT ON insis_people_v10.hst_people_man_comp TO insis_cust_addon;
GRANT SELECT ON insis_people_v10.hst_people_sex TO insis_cust_addon;
