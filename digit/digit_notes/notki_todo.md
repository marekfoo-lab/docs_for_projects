FoAnnextIConverterImpl

sa porobione zmiany w xsd - FO-RORM_A.xsd
gdy maxOccurse=unbounded - wtedy nasz mapper tworzy FoAnextType (generowany) to znacza ze ten typ jest generowany u nas jako lista,
co nie jest porzadane. Bo kazda sekcja jest tylko jedna!
dla sekcji e, criminalOffencemaximum... - Offence_Type - podali enumeracje a nam sie wygenerowal enum, co nie jest potrzebne bo my mamy na UI checkboxy.
Dodali IndicatorType ktory jest u nas boolean.  Zamieniony zostal caly enum na obiekt ktory ma pola boolean.
offenceTypeToJaxb - converter w FoAnnexIsectionEConverterImpl. Sprawdza on czy np. participationInACriminalOrganisation
offenceTypeToJaxb -
toJaxb - (z pojo do xml)
toDomain (z xml do naszego pojo)

GroundsForIssuing - ten typ trzyma booleany z offenceTypeToJaxb

FoAnnexIConverterImpl - glowy konwerter dla wszystkich sekcji, oprocz sekcji P (miala pustego endpointa - w pliku fco-public-api.yaml, tam jest info o Mock endpoint, ktorego nie ma).
Nie wszystkie konvertery sa wypelnione, oprocz sekcji C.

Sekcja I na pewno do zrobienia - FoAnnexISectionCConverter
FoAnnexISectionAConverter - niewypelniona - do pogadania z Karolem. Tu sie zapisuje albo 1 albo drugi issuingState (ten co wysyla).

POdaja nam w xsd cos typy issuingAuthority jak string a nie jako id, za pomoca ktorego moglibysmy wyslac zapytanie do CDB. POtrzebowalibysmy jeszcze pole jakie jest id tego issuingState.



Section M:
AuthorityType - zmienic na EioAuthorityType.
AuthorityTechnicalIdentifier - brakuje w sekcji M, za to zostal zmieniony na cos innego.
Pod EioAuthorityType jest przygotowana sekcja M.
FoAnnexISectionConverter - tam sa wszystkie convertory.
Brakuje testow i tego nie zrobi Kamil - to bede ja robil

Sekcja B FoAnnexISectionB -
obiekt UrgencyForExecution, ma obiekty Selectable - ktore mialybyc uzyte przez e-ulise ale stworzyli cos innego, IndicatorType i TextType. Trzebabylo zrobic obejscie. W FoAnnexISectionBCOnverterImpl tam jest zrobione to mapowanie w toJaxb ktore nie mapuje 1:1. Uzywamy tylko selectableString i selectableDate.
Dotyczy stworzenia calego Workflow dla FreezingOrdering.
https://citnet.tech.ec.europa.eu/CITnet/stash/projects/DEVEEV/repos/e-evidence-ri-backend-case-service/pull-requests/1122/diff#adapter%2Fprimary-secondary%2Fworkflow%2Fsrc%2Fmain%2Fjava%2Feu%2Feuropa%2Fec%2Fejustice%2Feevidence%2Fri%2Fadapter%2Fprimarysecondary%2Fworkflow%2Fdef%2Finstrument%2Ffo%2FFoBusinessProcessElementDef.java
Musze zrobic dla CO dokladnie tak samo jak dla FO
Tworze te same klasy - FO zmieniam tylko na CO
Do source zostalo jzu dodane xsd - podobnie jak dla FO.
Pomimo ze sa 2 zadania to i tak bedzie tworzone jako 1 zadanie.

Stworzenie:
- workflow
- mapery
- wysylanie i odbieranie formularzy
  https://citnet.tech.ec.europa.eu/CITnet/jira/browse/DEVEEV-4702
  https://citnet.tech.ec.europa.eu/CITnet/jira/browse/DEVEEV-4701
  Tu jest PR ze zmianami dla FO: https://citnet.tech.ec.europa.eu/CITnet/stash/projects/DEVEEV/repos/e-evidence-ri-backend-case-service/pull-requests/1122/diff#adapter%2Fprimary-secondary%2Fworkflow%2Fsrc%2Fmain%2Fjava%2Feu%2Feuropa%2Fec%2Fejustice%2Feevidence%2Fri%2Fadapter%2Fprimarysecondary%2Fworkflow%2Fdef%2Finstrument%2Ffo%2FFoBusinessProcessElementDef.java

1. Zajac sie zrobic tym internal workflow.
   Kamil tworzy subtaski - prior Major - component FCO - sprint inherited.:
   Tworzenie CO workflow na podstawie FO
   Moj task: https://citnet.tech.ec.europa.eu/CITnet/jira/browse/DEVEEV-7680
   Jak to przetestowac?
   W bruno:
   Testowanie workflow:
   zawsze trzeba dodac sekcje A - bo tam jest ustawiony executing coutnry - executor
   nastepnie trzeba dodac sekcje ktore sa required - czyli ktore maja validacje niepustego pola

aby przejsc do kolejnego stepu - (get all - daje info w ktory stanie jestesmy)
Draft  -> REVIEW_READY ->
wspoldzielny link do przechodzienia przez taski, rozni sie tylko nazwa taska (FoTask enum - tam sa wartosic taskow)
oraz body w ktorym jest tez wartosc ->  FoAnnexITask.
POST COMPLETED -
{{protocol}}://{{host}}:{{port}}/case-service/cases/{{caseId}}/tasks/FO_ANNEX_I_COMPLETE/execute


W taskach sa linki do dokumentacji:
dla FO draft case: https://citnet.tech.ec.europa.eu/CITnet/jira/browse/DEVEEV-6009?filter=365472 - male info o workflow
https://eceuropaeu.sharepoint.com/:u:/r/teams/GRP-eEDESEG-DGJUSTdocumentation_procedures/_layouts/15/Doc.aspx?sourcedoc=%7B93E91507-5A00-410C-8E97-9C20EDEDC324%7D&file=FCO%20-%20Case%20lifecycle%20workflows.vsdx&action=default&mobileredirect=true&CID=bdcee96d-1afe-45a7-99bf-a7403cba40d1 - cos wiecej, opis workflow

Prepare for signature -> tu sie to konczy, bo kamil musi zaimplementowac xsd, konversje z xml do java i odwrotnie (EdsForm).

2. Stworzenie translacji do PDF - moge to przejac. -> https://citnet.tech.ec.europa.eu/CITnet/jira/browse/DEVEEV-7314
w pliku i18n.properties - plikow jest duzo. Spytac sie Patryka Mierunskiego - jest w dev4 - Gealle musi napsiac do scrummustear dev4 czy patryk bedzie mial czas pogadac albo pogadac z Karolem. 
Wszystkie wartosci dla labeli trzeba przepisac, Aileen Hickey poda link gdzie sa pdf'y w ktorych sa translacje ktore trzeba skopiowac.  (2dni roboty).



===========
https://citnet.tech.ec.europa.eu/CITnet/jira/browse/DEVEEV-6009?filter=365472
https://citnet.tech.ec.europa.eu/CITnet/jira/browse/DEVEEV-7680
https://citnet.tech.ec.europa.eu/CITnet/jira/browse/DEVEEV-4701
https://citnet.tech.ec.europa.eu/CITnet/jira/browse/DEVEEV-4702
https://citnet.tech.ec.europa.eu/CITnet/stash/projects/DEVEEV/repos/e-evidence-ri-backend-case-service/pull-requests/1122/diff#adapter%2Fprimary-secondary%2Fworkflow%2Fsrc%2Fmain%2Fjava%2Feu%2Feuropa%2Fec%2Fejustice%2Feevidence%2Fri%2Fadapter%2Fprimarysecondary%2Fworkflow%2Fdef%2Finstrument%2Ffo%2FFoBusinessProcessElementDef.java


