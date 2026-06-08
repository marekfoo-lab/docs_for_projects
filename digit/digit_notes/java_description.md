# Java components

## Architecture

- Adapter - primary - rest - > Warstwa zewnetrzna - Controller + InterfaceAPI — (PropertiesApiController) + Converter - REST ↔ DTO(PropertiesConverter)
- core - port - primary -> Interface (GetProperty) - Interface use-caseow - query/execute - Kontrakt pomiedzy warstwa adapter primary a warstwa application.  Kontroler wywołuje te interfejsy, nie zna implementacji.
- core - application -> Warstwa aplikacji (handlery/use-case'y) (PropertyServiceImpl) - implementacje portow (CreateFoDecisionHandler), handlery (logika orkiestracji), konwertery domenowe, fasady instrumentów (FoCaseFacade), wywołania do domeny i portów secondary. Nie ma tu reguł biznesowych — tylko orkiestracja. Orkiestracja w core/application oznacza koordynowanie wywołań między różnymi komponentami (domena, porty secondary, inne serwisy) w celu realizacji jednego use-case'u. Handler w warstwie application nie zawiera logiki biznesowej — on jedynie:
    - Pobiera dane (z repozytorium)
    - Wywołuje logikę na encji domenowej
    - Zapisuje wynik
    - Ewentualnie wywołuje efekty uboczne (wysyłka wiadomości, notyfikacje)
    
- core - port - secondary ->  Porty wyjściowe (interfejsy do infrastruktury) - interfejsy repozytoriów (FoDecisionRepository), interfejsy do wysyłki maili, plików, tłumaczeń. Application zna tylko te interfejsy.
- core - domain - Domena (rdzeń) - Encje domenowe z logiką biznesową: FoAnnexI, value objects, factory. Od niczego nie zalezy.
- core/shared-kernel — współdzielone value objects (np. FormId, MessageType)
- adapter/secondary - Adaptery wyjściowe (implementacje portów secondary) - Implementacje portów secondary: repository-jpa (JPA/Hibernate), file-store, email-sender. Tu sa klasy JPA (repozytoria Spring Data), klienty HTTP do zewnętrznych serwisów, implementacje wysyłki maili.
- adapter/primary-secondary (np. workflow, domibus) — adaptery pełniące obie role jednocześnie
- integration - service-starter - adapter -> Spring Boot starter łączący wszystko w runtime - Impl (InstrumentPropertiesProviderImpl)

Dodatkowo:
- core- shared-kernel - wspoldzielone value objects (FormId, MessageType)
- adapter - primary-secondary - adaptery pelniace obie role jednoczesnie - workflow, domibus. 
- integration - service-starter - Springboot laczacy wszystko w runtime.

ZASADA ZALEZNOSCI: Zależności wskazują zawsze do środka:
- adapter/primary → zależy od core/port/primary
- core/application → zależy od core/port/primary + core/port/secondary + core/domain
- adapter/secondary → zależy od core/port/secondary
- core/domain → nie zależy od niczego (czysta Java)

## FoCaseFacade

Fasada instrumentu pełni rolę centralnego punktu koordynacji dla danego instrumentu prawnego. Jest to implementacja wzorca Facade w warstwie application, która:

1. Agreguje operacje specyficzne dla instrumentu
2. Rejestruje się w Registry (Strategy pattern) -> registry.register(getInstrument(), this);
3. Definiuje kontrakt "co instrument potrafi"
4. Waliduje kompletność przy starcie

Fasada jest więc adapterem wewnętrznym — pozwala generycznej logice (wysyłanie wiadomości, tworzenie spraw) działać polimorficznie bez znajomości szczegółów konkretnego instrumentu.

## Java Main types

FormType 

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
