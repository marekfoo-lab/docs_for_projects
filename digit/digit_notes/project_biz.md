
==== TODO ===========

Model architektury - podobny dokument od eufg i dom.


Access to Intranet - DONE
Review - DONE


primar - core of core
secondary - dodatkowe rzeczy
Marshalers


European Payment Order - EPO

CO Confiscation Order
EIO and EPOC - been took

FCO RI - Spring 9 - March 11 - 3 week.

## Workflow

TASK != STAN - TO NIE JEST STAN!
JAKE SA MOZLIWE STANY TO MOZNA WYJAC Z DANEGO TASKA
STAN MOZE WYNIKAC Z WYKONANIA TASKA
STAN: DRAFT, COMPLETED, POSITIVELY REVIEWD...

CoBusinessProcessElementDef - opisuje workflow.
Taski do wykonania przez uzytkownika
Taski operuja na zadaniach

aby przejsc do kolejnego stepu - (get all - daje info w ktory stanie jestesmy)
Draft  -> REVIEW_READY ->
wspoldzielny link do przechodzienia przez taski, rozni sie tylko nazwa taska (FoTask enum - tam sa wartosic taskow)
oraz body w ktorym jest tez wartosc ->  FoAnnexITask.
POST COMPLETED -

Do przechodzenia pomiedzy taskami sluzyc generyczny POST:
{{protocol}}://{{host}}:{{port}}/case-service/cases/{{caseId}}/tasks/CO_ANNEX_II_COMPLETE/execute

{{protocol}}://{{host}}:{{port}}/case-service/cases/{{caseId}}/tasks/CO_ANNEX_II_REVIEW/execute

{{protocol}}://{{host}}:{{port}}/case-service/cases/{{caseId}}/tasks/CO_ANNEX_II_PREPARE_FOR_SIGNATURE/execute


CO_MSG_COMPLETE - action
TaskOutput - COMPLETED - stan/status a dokladnie case status.

TODO: Stan czego Form czy Case?
Mamy taski: CO_ANNEX_II_COMPLETE (completed), CO_ANNEX_II_REVIEW (rejected, accepted, requires_amendment))
Task (COMPLETED, ACCEPTED, REQUIRES_AMENDMENT, ) przesuwa z 1 stan do drugiego stanu


Mamy definicje Glownego formularza, za nim podaza LegalCase.
Jest glowny formularz ktory jest zwiazany z LegalCase i dla FO to Annex I. Oba musza istniec dla siebie. Nie istnieja bez siebie inaczej.
Dla Sod glowny formularz to SodForL.

Co moze wykonac dany user? wykonac task -> nastepnie pojawia sie lista kolejnych mozliwych taskow do wykonania przez usera.
User wykonuje taski, a to czesto ale nie zawsze prowadzi do wynikowego stanu na formularzu glownym oraz na LegalCase (to taka grupa ktora zawiera formularze, uzytkownikow, akta/pliki, ).

Task jest zwiazany z Formularzem
Task leci do glownego formularza

CoWorkflowState (core/shared-kernel) — CO czym jest formularz (stan biznesowy)
Opisuje w jakim stanie jest cały instrument CO z perspektywy domeny. zawiera pełny cykl życia instrumentu CO, włącznie ze stanami po stronie odbierającej i stanami końcowymi.
Stany: DRAFT → REVIEW_READY → REVIEWED → SIGN_READY → SIGNED → ISSUED → RECEIVED → CLOSED / REJECTED / WITHDRAWN / DELETED
Używa wzorca Visitor — wymusza obsługę każdego stanu w kodzie domenowym
Jest w shared-kernel — widoczny dla całej aplikacji (core, adaptery, REST)

CoBusinessProcessElementDef (adapter/workflow) — JAK przechodzić między stanami (definicja procesu)
Opisuje kroki workflow engine (taski, przejścia, role)
Definiuje kto może co zrobić: AUTHOR wypełnia, REVIEWER recenzuje, SENDER wysyła
Jest w adapterze — to szczegół implementacyjny silnika workflow.
Definiuje tylko flow tworzenia i wysyłania ANNEX II (COMPLETE → REVIEW → PREPARE_FOR_SIGNATURE)


Krótko:
CoWorkflowState = co (stan formularza widoczny w UI i domenie). Info o wszystkich stanach (11 stanów)
CoBusinessProcessElementDef = jak - definiuje tylko taski workflow dla flow ANNEX II (COMPLETE → REVIEW → PREPARE_FOR_SIGNATURE → END) (i przejść w silniku workflow)
CoAnnexIIWorkflowState = podzbiór 7 stanów CO (mapowany na CoWorkflowState) specyficzny dla formularza ANNEX II (bez RECEIVED, CLOSED, WITHDRAWN, DELETED — bo te dotyczą strony odbierającej), używany przez silnik workflow
Co.java (encja domenowa) — bezpośrednio ustawia stany "pozaprocesowe" (RECEIVED, CLOSED, WITHDRAWN, DELETED) w swoich metodach

Silnik workflow wykonuje taski z CoBusinessProcessElementDef, a po każdym przejściu aktualizuje CoWorkflowState / CoAnnexIIWorkflowState na encji domenowej.




## Stworzenie Instrumentu

### Terminy

Case - to sprawa sadow, cos o charakterze prawnym, ktory musi przejsc przez workflow.
Moze reporezentowac 1 i tylko 1 z instrumentow. Czyli np. Co - confiscate order
LegalCase - glowna klasa po ktorej korzysta/dziedzicza wszystkie Instrumenty
caseid - klucz biznesowy/techniczny (UID) - po stworzeniu instrumentu, uzywany glownie w requestach i w DB
globalCaseId - klucz unikalny, w skali globalnej, (Klasa LegalCase), mniej uzywany,

Formularze - np. AnnnexII dla CO, ktory zawiera Sekcje A,B,C,D. Case (LegalCase) moze zawierac wiele formularzy.
formId  - klucz formularza (format jak caseid) - w JSON: currentForm/formid


Task - stany przez ktore przechodzi kazdy formularz.

Message - powstaje przy kazdym formularzu, (ma swoja tabelke), przechowuje stan formularza, i odpowiada za jego wysylke.  
Jak ucieknie caseid to trzeb uzyc Globals i tam sobie nadpisac


Completed  - gdy validacja OK
Kolejne staty sie hardcoduje

CoMessageBusinessProcessElementDef
CO_MSG_REVIEW - definiuje krok/CO_MSG_REVIEW/stan, ktory defniniuje zbior mozliwych kolejnych krokow ze
new TransitionDef(TaskOutput.ACCEPTED, CO_MSG_PREPARE_FOR_SIGNATURE.getTaskCode()),

Token - zawiera usera i jego role

state -> draft

workflowState -> DRAFT

"subject": "Confiscation order 01"

===========

Import globals - bruno

Formulaz -> case id
user kryminalny: cri1_all_1
kontext aplikacji: authorityCtx - ca-cri-1

Stworzenie sekcji/fromularza:+1:
FCO/AnnexI/Post FC new - nowy instrument

PUT:
https://www.development.ec.europa.eu/fco-pl/case-service/forms/fo/annexI/9fe41e06-105c-4e0f-b301-cad6cc4a1ed2/sectionB?ctx=ca-cri-1


CDB - baza danych dla kryminalnych i cywilnych - jedna baza dla wszystkich krajow.

Authorities And Countries - wazne
eedesId	"ca-cri-1" - ID ministerstwa sprawiedliwosci.
URL do sys. zewn.:
https://webgate.test.ec.europa.eu/cdb/ri/cc/eCodexPartyId/countryCode/PL/eedesId/ca-cri-1

Create Instrument:
POST FCO/AnnexI/FC new
subject - nie istotniy tylko tech id.
{
"id": "0b273784-c0d7-443f-a45c-27cb79c40775"
}
jest pryzpisany do glogalnego zmiennej caseId

Potem:
W legal Case
POST get all
-> to trzeba puscic aby po stworzeniu instrumetu przypisac jego id
Issuing Authority - ContexI - tworca formularza

"formId": {
"id": "f18f7cbf-bcf2-43a7-8acb-e57f3f844c1d"
},

	  fd8bd020-4e82-485b-b537-3f1c53d776c8
GET FC A
-> zwraca issue authority -> pokazuje ze to ja, ja stworzylem formularz itp. Executing authority - adresat fromularza
Tutuaj zostanie przypisany od razu id z kroku poprzedniego do Path pod foAnnexOneId

Formularz to np. Annex I

PATCH FC A Update
-> dodaje executing authority - kraj i executor/id -> ca-cri-2@cz

Teraz jak to uruchomie to zwroci executingEntity - czyli czechy.
GET FC A
-> zwraca issue authority -> pokazuje ze to ja, stworzylem formularz itp.
Aby poprawnie ustawic executing Authority. Tu sie podaje caseId (zamiast id formularza) bo zapisuje sie tez dla calego Legal Case, zapisuje sie w sekcji A i w core formularza.
Formularz musi wiedziec do kogo jest zapisywany.
GET FC B - zwraca sekcje b
PUT FC B Update -> tutaj mozna zaakutalizowac sekcje B - tu sie po kazdym run tworzy sie versjaa. Ona musi byc zaaktualizowana po kazdym run w Body na kolejna wersje


1. Start New request -> FO Freezing -> Subject
   Ustawic Issuing State i Issuing Authority

AnexI -> Section A -> Section A dla konkretne Authority
Formularz - > Review -> Signed -> To Send

2. Najpierw tworzy formularz, przechodzi review, jest podpisywany i dopiero moze byc wyslany
   Zwrocic uwage na validation check -> czyli pola ktore nalezy wypelnic aby przejsc dalej

## Problems

- skonfrontowac to co zaimplementowalem z tym co mialobyc zaimplementowane
- Postawienie srodowiska testowego:
  Jak zrobic prawdziwy setup z testowaniem:
    - devopps
    - container

## Terms to know

Poznac appke bo inaczej nie bede wiedzial co robie!

Protokul e-codex
Klucze biznesowe
Instrument
Formularz
Protokoly
ERAI
Slownik


