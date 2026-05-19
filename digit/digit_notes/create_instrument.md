# Instrument

## Create Instrument

POST FCO/AnnexI/FC new 
Potem: 
POST get all 
-> zwraca id instrumentu, potrzebnego do dalszych requestow
Issuing Authority - ContexI - tworca formularza
GET FC A 
-> zwraca issue authority -> pokazuje ze to ja, ja stworzylem formularz itp. Executing authority - adresat fromularza

PATCH FC A Update
-> dodaje executing authority - kraj i executor/id -> ca-cri-2@cz

Teraz jak to uruchomie to zwroci executingEntity - czyli czechy.
GET FC A 
-> zwraca issue authority -> pokazuje ze to ja, stworzylem formularz itp.

## Workflow

Case 
Sa taski jak FO_ANNEX_I_COMPLETE 
potem przesyla UI do nas FO_ANNEX_I_REVIEW 
i na podstawie tego co z UI przyjdzie np. Completed to idziemy do przodu ale tez mozemy sie cofnac.  


1. Draft -> Complete -> Validation OK (all required fields)
2. complete 
/fco-pl/case-service/cases/90ed8493-87ea-49bd-b414-f99df72adfa7/tasks/FO_ANNEX_I_COMPLETE/execute
3. review
/fco-pl/case-service/cases/90ed8493-87ea-49bd-b414-f99df72adfa7/tasks/FO_ANNEX_I_REVIEW/execute


PUT: 
https://www.development.ec.europa.eu/fco-pl/case-service/forms/fo/annexI/9fe41e06-105c-4e0f-b301-cad6cc4a1ed2/sectionB?ctx=ca-cri-1


## Database

t_co_annex_ii
t_co_annex_ii_a
t_co_annex_ii_b

## Send Receive

p-mode.xml
Definiuje akcje dla operacji z domnibus, musza tu byc dodane.

==============
Gdzie znajde REST API?
