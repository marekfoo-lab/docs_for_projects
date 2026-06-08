select lc.lcas_id, lc.lcas_urgency, lc.lcas_deadline_overdue
     , lcd.lcdl_deadline, lcd.lcdl_deadline_type, lcd.lcdl_next_notification_on
from t_legal_case lc
         left join t_legal_case_deadline lcd on lcd.lcdl_case_id = lc.lcas_id
where lcas_id = "8ca4c1f4-8c01-41d8-b02f-0823395c1e67";

select * from t_legal_case_deadline;
select * from t_legal_case;
select * from t_form_data;