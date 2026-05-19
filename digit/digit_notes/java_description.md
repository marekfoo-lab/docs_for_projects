# Java components

## Architecture


- Adapter - primary - rest - > Warstwa zewnetrzna - Controller + InterfaceAPI — (PropertiesApiController) + Converter - REST ↔ DTO(PropertiesConverter)
- core - port - primary -> Interface (GetProperty) - Interface use-caseow - query/execute - Kontrakt pomiedzy warstwa adapter primary a warstwa application.
- core - application -> Service/Handlery/Usecase - implementacja portow primary (PropertyServiceImpl). Brak requl biznesowych - tylko orkiestracja wywolan do domey i portow secondary. Rowniez konwertery domenowe, fasady instrumentow.
- core - port - secondary -> Interface do infrastructure takiej jak:repository, file-store, email-sender, message-sender, workflow. Application zna tylko te interface. (InstrumentPropertiesProvider) ?
- core - domain - Domena - encje domenowe z logika biznesowa/metodami biznesowymi (FOAnnexI) oraz ich Factory i value objects. Nie zalezy od niczego zewnetrznego!
- adapter - secondary - Adaptery wyjsciowe - Implementacja repository-jpa, file-store, email-sender, domibus.

Dodatkowo:
- core- shared-kernel - wspoldzielone value objects (FormId, MessageType)
- adapter - primary-secondary - adaptery pelniace obie role jednoczesnie - workflow, domibus. 
- integration - service-starter - Springboot laczacy wszystko w runtime.

Zależności wskazują zawsze do środka:
- adapter/primary → zależy od core/port/primary
- core/application → zależy od core/port/primary + core/port/secondary + core/domain
- adapter/secondary → zależy od core/port/secondary
- core/domain → nie zależy od niczego (czysta Java)

## Java types

FoOutTest extends LegalCaseOutAbstractTest

Przechowuje sciezki do wszystkic xsd:
C:\git\e-evidence-ri-backend-case-service\integration\service-starter\src\main\resources\application.yml

Przechowuje xsd:
C:\git\e-evidence-ri-backend-case-service\core\schema\src\main\resources\xsd\FCO

application.xsd.eio.annexA


## Raporty

FoAnnexISectionBRestConverter - to mapery dla restow ale tez sa dla soap bez converter w nazwie. One sa robione recznie oraz recznie jest robiona implementacja.


FoValidatingAuthorityDetails - przechowuje dane
FoValidatingAuthorityDetailsParameterBuilderImpl - mapuje dane dla kontrolki z jasper uzywajac mapy i zdefiniowanych stalych dla kluczy a dane sa brane z bazy z np. FoValidatingAuthorityDetails

## Workflow

Do czego sluza:
CoBusinessProcessElementDef vs CoMessageBusinessProcessElementDef

FoMessageActivity - missing
FoMessageWorkflowState


Kluczowa zasada: InstrumentCaseFacade to warstwa aplikacji (orkiestracja), Fo/FoAnnexI to warstwa domeny (logika biznesowa), a Direction + MessageType + FormType to shared kernel (wspólny język między warstwami).

Workflow FO Annex I wygląda tak:
DRAFT → COMPLETED → REVIEWED → SIGN_READY → SIGNED → ISSUED

### FoMessageActivity — Aktywności workflow wiadomości FO

To enum definiujący kroki (aktywności) w procesie workflow wiadomości dla instrumentu Freezing Order. Nie dotyczy samego formularza Annex I (to robi FoAnnexITask), ale wiadomości wysyłanej z tym formularzem — czyli procesu od momentu gdy użytkownik klika "Send" do momentu dostarczenia wiadomości do odbiorcy.

FoMessageActivity to definicja procesu BPMN dla wiadomości FO, wyrażona jako enum. Silnik workflow (adapter workflow) odczytuje te aktywności i na ich podstawie:
- tworzy zadania (tasks) dla użytkowników
- waliduje przejścia stanów
- kontroluje kto co może robić w danym momencie
To jest warstwa pomiędzy użytkownikiem a domeną — orkiestruje cały flow od "chcę wysłać" do "dostarczono"


### FoAnnexISectionType

FoAnnexISectionType (enum) to identyfikator sekcji formularza, używany do:
- kontroli dostępu (kto może edytować - getEditableRole(workflowState)) 
- routingu (który handler obsługuje zapis/odczyt - handler do zapisu (UpdateFoAnnexISectionBHandler, UpdateFoAnnexISectionCHandler, ...) i odczytu (GetFoAnnexISectionBHandler)) 
- walidacja edycji — w FoAnnexI.isEditable(FoAnnexISectionType) system sprawdza czy dana sekcja może być edytowana w aktualnym stanie formularza


FormType.FO_ANNEX_I          ← "typ formularza"
    │
    └── FoAnnexI (encja)     ← "instancja formularza w DB"
            │
            ├── FoAnnexISectionType.SECTION_A → FoAnnexISectionA (dane sekcji A)
            ├── FoAnnexISectionType.SECTION_B → FoAnnexISectionB (dane sekcji B)
            │                                      └── UrgencyForExecution
            │                                           ├── grounds (checkbox)
            │                                           ├── needs (checkbox)
            │                                           └── specificDate (data)
            ├── FoAnnexISectionType.SECTION_C → FoAnnexISectionC
            ├── ...
            └── FoAnnexISectionType.SECTION_O → FoAnnexISectionO



### Diagram przeplywu - ISSUING AUTHORITY (IA) — Direction.OUT 

1. Użytkownik tworzy sprawę FO                                       
    └─ CaseFactory → Fo (direction=OUT, state=DRAFT)                 
    └─ FoCaseFacade.createInitialOutgoingForm()                      
       └─ tworzy FoAnnexI (FormType.FO_ANNEX_I, state=DRAFT) 
2. Użytkownik wypełnia sekcje A-O formularza                          
    └─ FoAnnexI.sectionEdited(...)  
3. Workflow: COMPLETE task                                             
    └─ FoCaseFacade.onTaskCompleted(FO_ANNEX_I_COMPLETE, COMPLETED)    
    └─ FoAnnexI: DRAFT → COMPLETED                                    
    └─ Fo case: DRAFT → COMPLETED 
4. Workflow: REVIEW task                                               
    └─ FoAnnexI: COMPLETED → REVIEWED                                 
    └─ Fo case: COMPLETED → REVIEWED 
5. Workflow: PREPARE_FOR_SIGNATURE task                               
    └─ FoAnnexI: REVIEWED → SIGN_READY                                
    └─ Fo case: REVIEWED → SIGN_READY
6. Workflow: SIGN task (upload signed PDF)                  
    └─ FoAnnexI: SIGN_READY → SIGNED                         
    └─ Fo case: SIGN_READY → SIGNED 	
7. Workflow: SEND task  ← [TU JEST TWOJE WYMAGANIE] 
    └─ FoCaseFacade.onTaskCompleted(FO_ANNEX_I_SEND, COMPLETED)
    └─ FoAnnexI: SIGNED → ISSUED                                      
    └─ Fo case: SIGNED → ISSUED                                       
    └─ LegalCase.issue() → CaseState = ISSUED                         
    └─ Message(MessageType.FO_ANNEX_I) wysyłany do EA	
	
 ->>   [Domibus/eDelivery] <<-
 
EXECUTING AUTHORITY (EA) — Direction.IN    
8. System odbiera wiadomość                                           
    └─ MessageType.FO_ANNEX_I rozpoznany                              
    └─ FoCaseFacade.processIncomingForm() → odtwarza FoAnnexI         
    └─ CaseFactory → Fo (direction=IN, state=RECEIVED)
9. LegalCase.onBusinessMessageReceived(...)                           
     └─ Fo.createInitialDeadlinesForIncomingCase(...)                 
     └─ handleDeadlinesForSectionB(UrgencyForExecution):                
                                                                         
        ┌─ grounds/needs zaznaczone, BEZ daty?                        
        │  → Deadline(FO_IMMEDIATE_FREEZING_DECISION, offset=2 dni)   
        │                                                             
        └─ grounds/needs zaznaczone, Z datą?                          
           → Deadline(FO_IMMEDIATE_FREEZING_EXECUTION, offset=data)
		   
10. Deadline widoczny w Overview:                                      
     - authorityId = EA (owningAuthority)                              
     - deadlineType = FO_IMMEDIATE_FREEZING_DECISION                   
     - deadlineDate = deliveryDate + 2 dni                             
     - deadlineFulfilledOn = null                                      
     - cancelled = false 		


### Relacje między typami   

Instrument.FO
    │
    ├── FormType.FO_ANNEX_I  ← "jaki formularz"
    │       │
    │       └── MessageType.FO_ANNEX_I  ← "w jakim celu wysyłany"
    │
    ├── FoCaseFacade (implements InstrumentCaseFacade)  ← "jak obsługiwać"
    │       │
    │       ├── createInitialOutgoingForm()
    │       ├── processIncomingForm()
    │       ├── onTaskCompleted() → deleguje do CompleteFoAnnexIWorkflowTaskHandler
    │       └── getSubsequentIncomingMessageTypesForCaseDirection()
    │
    ├── Fo extends LegalCase  ←── "encja domeny (sprawa)"
    │       │
    │       ├── direction: Direction.OUT lub Direction.IN
    │       ├── workflowState: FoWorkflowState (DRAFT→...→ISSUED/RECEIVED)
    │       └── deadlines: Set<Deadline>
    │
    └── FoAnnexI  ←── "encja domeny (formularz)"
            │
            ├── workflowState: FoAnnexIWorkflowState (DRAFT→...→ISSUED)
            └── taskCompleted(FoAnnexITask, TaskOutput)
