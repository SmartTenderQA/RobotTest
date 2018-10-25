*** Settings ***
Library           String
Library           DateTime
Library           smarttender_service.py
Library           op_robot_tests.tests_files.service_keywords
Library	          Collections


*** Variables ***
${tender_href}                          None
${browserAlias}                         'main_browser'
${second browser}                       'tender page'
${synchronization}                      http://test.smarttender.biz/ws/webservice.asmx/ExecuteEx?calcId=_SYNCANDMOVE&args=&ticket=&pureJson=
${path to find tender}                  http://test.smarttender.biz/test-tenders/
${find tender field}                    xpath=//input[@placeholder="Введіть запит для пошуку або номер тендеру"]
${tender found}                         xpath=//*[@id="tenders"]/tbody//a[@class="linkSubjTrading"]
${wait}                                 120
${iframe}                               jquery=iframe:eq(0)
${expand list}                          css=label.tooltip-label

#login
${open login button}                    //*[@id='LoginAnchor']
${login field}                          xpath=(//*[@id="LoginBlock_LoginTb"])[2]
${password field}                       xpath=(//*[@id="LoginBlock_PasswordTb"])[2]
${remember me}                          xpath=(//*[@id="LoginBlock_RememberMe"])[2]
${login button}                         xpath=(//*[@id="LoginBlock_LogInBtn"])[2]
${prompt window}                        xpath=//*[contains(@class,'notification-popover')]
${close promt}                          xpath=//*[contains(@class, 'notification-prompt') and text()='Запретить']

#open procedure
${question_button}                      xpath=//a[@id="question"]

#make proposal
${block}                                xpath=.//*[@class='ivu-card ivu-card-bordered']
${cancellation offers button}           ${block}[last()]//div[@class="ivu-poptip-rel"]/button
${cancel. offers confirm button}        ${block}[last()]//div[@class="ivu-poptip-footer"]/button[2]
${ok button}                            xpath=.//div[@class="ivu-modal-body"]/div[@class="ivu-modal-confirm"]//button
${loading}                              css=div.smt-load
${your request is sending}              css=.ivu-message-notice-content-textddd
${wraploading}                          css=#wrapLoading .load-icon-div i
${send offer button}                    css=button#submitBidPlease
${checkbox1}                            xpath=//*[@id="SelfEligible"]//input
${checkbox2}                            xpath=//*[@id="SelfQualified"]//input

${succeed}                              Пропозицію прийнято
${succeed2}                             Не вдалося зчитати пропозицію з ЦБД!
${empty error}                          ValueError: Element locator
${error1}                               Не вдалося подати пропозицію
${error2}                               Виникла помилка при збереженні пропозиції.
${error3}                               Непередбачувана ситуація
${cancellation succeed}                 Пропозиція анульована.
${cancellation error1}                  Не вдалося анулювати пропозицію.

${button add file}                      //input[@type="file"][1]
${file container}                       //div[@class="file-container"]/div
${choice file list}                     //div[@class="dropdown open"]//li
${choice file button}                   //button[@data-toggle="dropdown"]
${confidentiality switch}               xpath=//*[@class="ivu-switch"]
${confidentiality switch field}         xpath=//*[@class="ivu-input-wrapper ivu-input-type"]/input
${validation message}                   //*[@class="ivu-modal-content"]//*[@class="ivu-modal-confirm-body"]//div[text()]
${torgy top/bottom tab}                 css=#MainMenuTenders ul:nth-child   #up-1 bottom-2
${torgy count tab}                      li:nth-child
${change language}                      css=div:nth-child(2) .dropdown img

#claims
${link to claims}                       xpath=//*[@data-qa='tabs']//span[contains(text(),'Вимоги')]
${claims tab active}                    xpath=//*[@data-qa='tabs']//span[contains(text(),'Вимоги')]/ancestor::div[contains(@class,'active')]
${claim collapse button}                xpath=//span[@class='appeal-expander']

#webclient
${owner change}                         css=[data-name="TBCASE____F4"]
${ok add file}                          jquery=span:Contains('ОК'):eq(0)
${webClient loading}                    //*[contains(@class, 'LoadingPanel')]
${orenda}                               css=[data-itemkey='438']
${create tender}                        css=[data-name="TBCASE____F7"]
${add file button}                      css=#cpModalMode div[data-name='BTADDATTACHMENT']
${choice file path}                     xpath=//*[@type='file'][1]
${add files tab}                        xpath=//li[contains(@class, 'dxtc-tab')]//span[text()='Завантаження документації']
${add item btn}                         xpath=//*[@data-name="GRID_ITEMS_HIERARCHY"]//*[@title="Додати"]
${delete item btn}                      xpath=//*[@data-name="GRID_ITEMS_HIERARCHY"]//*[@title="Видалити"]
${delete feature btn}                   xpath=//*[@data-name="GRID_CRITERIA"]//*[@title='Видалити']



*** Keywords ***
####################################
#        Операції з лотом          #
####################################
Підготувати клієнт для користувача
  [Arguments]  ${username}
  [Documentation]  Відкриває переглядач на потрібній сторінці, готує api wrapper, тощо для користувача username.
  Open Browser  ${USERS.users['${username}'].homepage}  ${USERS.users['${username}'].browser}  alias=${browserAlias}
  Set Window Size  1280  1024
  Run Keyword If  '${username}' != 'SmartTender_Viewer'  Login_  ${username}
  Run Keyword If  '${username}' == 'SmartTender_Owner'  Відкрити Додаткове Вікно Браузера  ${username}


Відкрити Додаткове Вікно Браузера
  [Arguments]  ${username}
  [Documentation]  Відриваеться додаткове вікно браузера з аліасом tender page, після чого йде переключення на основне вікно браузера.
  ...  Використовується наприклад, для паралельної роботи у веб-клієнті та на сторінці з тендером
  Open Browser  ${USERS.users['${username}'].homepage}  ${USERS.users['${username}'].browser}  alias=${second browser}
  Set Window Size  1280  1024
  Switch Browser  ${browserAlias}


Перейти в особистий кабінет
  ${href}  Get Element Attribute  ${open login button}@href
  Go To  ${href}
  Дочекатись загрузки сторінки (webclient)
  Wait Until Keyword Succeeds  120  3  Location Should Contain  /webclient/


Дочекатись загрузки сторінки (webclient)
  ${status}  ${message}  Run Keyword And Ignore Error  Wait Until Element Is Visible  ${webClient loading}  3
  Run Keyword If  "${status}" == "PASS"  Run Keyword And Ignore Error  Wait Until Element Is Not Visible  ${webClient loading}  120


Підготувати дані для оголошення тендера
  [Arguments]  ${username}  ${tender_data}  ${role_name}
  [Documentation]  Адаптує початкові дані для створення лоту. Наприклад, змінити дані про procuringEntity на дані про користувача tender_owner на майданчику.
  ...  Перевіряючи значення аргументу role_name, можна адаптувати різні дані для різних ролей
  ...  (наприклад, необхідно тільки для ролі tender_owner забрати з початкових даних поле mode: test, а для інших ролей не потрібно робити нічого).
  ...  Це ключове слово викликається в циклі для кожної ролі, яка бере участь в поточному сценарії.
  ...  З ключового слова потрібно повернути адаптовані дані tender_data. Різниця між початковими даними і кінцевими буде виведена в консоль під час запуску тесту.
  ${tender_data}=  smarttender_service.adapt_data  ${tender_data}
  [Return]  ${tender_data}


Створити тендер
  [Arguments]  ${username}  ${tender_data}
  [Documentation]  Створює лот з початковими даними tender_data.
  Відкрити бланк для створення тендера
  Вибрати тип торгів (процедура)             ${tender_data.data.procurementMethodType}
  Заповнити legalName для tender             ${tender_data.data.procuringEntity.identifier.legalName}
  Заповнити title для tender                 ${tender_data.data.title}
  Заповнити description для tender           ${tender_data.data.description}
  Заповнити amount для tender                ${tender_data.data.value.amount}
  Заповнити minimalStep для tender           ${tender_data.data.minimalStep.amount}
  Заповнити valueTAX для tender              ${tender_data.data.value.valueAddedTaxIncluded}
  Заповнити endDate для tender               ${tender_data.data.tenderPeriod.endDate}
  Заповнити lots для tender                  ${tender_data.data['lots']}
  Заповнити items для tender                 ${tender_data.data['items']}
  Заповнити features для tender              ${tender_data.data['features']}
  Додати документ до тендара власником (webclient)
  Натиснути додати тендер
  Оголосити закупівлю
  [Return]  ${tender_uaid}


Додати лот до тендера
  [Arguments]  ${lot}
  Заповнити title для lot                    ${lot.title}
  Заповнити description для lot              ${lot.description}
  Заповнити amount для lot                   ${lot.value.amount}
  Заповнити minimalStep для lot              ${lot.minimalStep.amount}


Додати предмет в тендер_
  [Arguments]  ${item}
  Заповнити description для item             ${item.description}
  Заповнити quantity для item                ${item.quantity}
  Заповнити id для item                      ${item.classification.id}
  Заповнити scheme для item                  ${item.classification.scheme}
  Заповнити unit.name для item               ${item.unit.name}
  Заповнити postalCode для item              ${item.deliveryAddress.postalCode}
  Заповнити streetAddress для item           ${item.deliveryAddress.streetAddress}
  Заповнити locality для item                ${item.deliveryAddress.locality}
  Заповнити endDate для item                 ${item.deliveryDate.endDate}
  Заповнити startDate для item               ${item.deliveryDate.startDate}


Додати неціновий показник
  [Arguments]  ${feature}
  Заповнити title для feature                ${feature.title}
  Заповнити description для feature          ${feature.description}
  Заповнити featureOf для feature            ${feature.featureOf}
  Заповнити enum для featureOf               ${feature['enum']}


Додати Значення Критерію
  [Arguments]  ${enum}  ${index}
  Заповнити title для enum                   ${enum.title}  ${index}
  Заповнити value для enum                   ${enum.value}  ${index}


Заповнити description для item
  [Arguments]  ${value}
  Заповнити Поле  xpath=(//*[@data-name='KMAT']//input)[1]  ${value}


Заповнити quantity для item
  [Arguments]  ${value}
  ${value}  Convert To String  ${value}
  Заповнити Поле  xpath=//*[@data-name='QUANTITY']//input  ${value}


Заповнити id для item
  [Arguments]  ${value}
  Заповнити Поле  xpath=//*[@data-name='MAINCLASSIFICATION']//input[not(contains(@type,'hidden'))]  ${value}


Заповнити scheme для item
  [Arguments]  ${value}
  Run Keyword If  '${value}' == 'ДК021'  No Operation
  ...  ELSE  Run Keywords
  ...  Log To Console  'Заповнити scheme для item'
  ...  AND  debug
  Вибрати пусте поле для доп. scheme


Вибрати пусте поле для доп. scheme
  Click Element  xpath=//*[@data-name="CLASSIFICATIONSCHEME"]//td[2]
  Sleep  1
  Click Element  xpath=//*[contains(@id,"DDD_L_LBT")]//td[not(contains(text(),' '))]


Заповнити unit.name для item
  [Arguments]  ${value}
  ${value}  smarttender_service.convert_unit_to_smarttender_format  ${value}
  Log  ${value}
  Заповнити Поле  xpath=//*[@data-name='EDI']//input[not(contains(@type,'hidden'))]  ${value}


Заповнити postalCode для item
  [Arguments]  ${value}
  Заповнити Поле  xpath=//*[@data-name='POSTALCODE']//input  ${value}


Заповнити streetAddress для item
  [Arguments]  ${value}
  Заповнити Поле  xpath=//*[@data-name='STREETADDR']//input  ${value}


Заповнити locality для item
  [Arguments]  ${value}
  Заповнити Поле  xpath=//*[@data-name='CITY_KOD']//input[not(contains(@type,'hidden'))]  ${value}


Заповнити endDate для item
  [Arguments]  ${value}
  ${value}  smarttender_service.convert_datetime_to_smarttender_form  ${value}
  Заповнити Поле  xpath=//*[@data-name="DDATETO"]//input  ${value}


Заповнити startDate для item
  [Arguments]  ${value}
  ${value}  smarttender_service.convert_datetime_to_smarttender_form  ${value}
  Заповнити Поле  xpath=//*[@data-name="DDATEFROM"]//input  ${value}


Додати документ до тендара власником (webclient)
  Перейти на вкладку документи (webclient)
  Додати документ власником


Натиснути додати тендер
  Click Element  xpath=//*[@data-name="OkButton"]
  Дочекатись Загрузки Сторінки (webclient)


Оголосити закупівлю
  Wait Until Page Contains  Оголосити закупівлю
  Click Element  xpath=//*[@class="message-box"]//*[.='Так']
  Дочекатись Загрузки Сторінки (webclient)
  Підтвердити повідомлення про перевищення бюджету за необхідністю
  Підтвердити повідомлення про перевірку публікації документу за необхідністю
  Відмовитись у повідомленні про накладання ЕЦП на тендер
  Пошук тендеру по title (webclient)  ${tender title}
  Отримати tender_uaid щойно стореного тендера
  Switch Browser  ${second browser}


Пошук тендеру по title (webclient)
  [Arguments]  ${tender title}
  ${find tender field}  Set Variable  xpath=(//tr[@class=' has-system-column'])[1]/td[count(//div[contains(text(), 'Узагальнена назва закупівлі')]/ancestor::td[@draggable]/preceding-sibling::*)+1]//input
  Scroll Page To Element XPATH  ${find tender field}
  Click Element  ${find tender field}
  Input Text  ${find tender field}  ${tender title}
  ${get}  Get Element Attribute  ${find tender field}@value
  ${status}  Run Keyword And Return Status  Should Be Equal  ${get}  ${tender title}
  Run Keyword If  '${status}' == 'False'  Пошук тендеру по title у webclient  ${tender title}
  Press Key  ${find tender field}  \\13
  Дочекатись Загрузки Сторінки (webclient)
  ${count tenders}  Get Matching Xpath Count  xpath=//div[contains(@class,'selectable')]/table//tr[contains(@class,'Row')]
  Run Keyword And Ignore Error  Should Be Equal  ${count tenders}  1


Отримати tender_uaid щойно стореного тендера
  ${find tender field}  Set Variable  xpath=(//tr[@class='evenRow rowselected'])[1]/td[count(//div[contains(text(), 'Номер тендеру')]/ancestor::td[@draggable]/preceding-sibling::*)+1]
  Scroll Page To Element XPATH  ${find tender field}
  ${uaid}  Get Text  ${find tender field}/a
  Set Global Variable  ${tender_uaid}  ${uaid}


Підтвердити повідомлення про перевищення бюджету за необхідністю
  ${status}  Run Keyword And Return Status  Wait Until Page Contains  Увага! Бюджет перевищує
  Run Keyword If  '${status}' == 'True'  Run Keywords
  ...  Click Element  xpath=//*[@class="message-box"]//*[.='Так']
  ...  AND  Дочекатись Загрузки Сторінки (webclient)


Підтвердити повідомлення про перевірку публікації документу за необхідністю
  ${status}  Run Keyword And Return Status  Wait Until Page Contains  перевірте публікацію Вашого документу
  Run Keyword If  '${status}' == 'True'  Run Keywords
  ...  Click Element  xpath=//*[@title="OK"]
  ...  AND  Дочекатись Загрузки Сторінки (webclient)

Відмовитись у повідомленні про накладання ЕЦП на тендер
  ${status}  Run Keyword And Return Status  Wait Until Page Contains  Накласти ЕЦП на тендер?  3
  Run Keyword If  '${status}' == 'True'  Run Keywords
  ...  Click Element  xpath=//*[@id="IMMessageBoxBtnNo"]
  ...  AND  Дочекатись Загрузки Сторінки (webclient)


Продовжити Період Подачі Пропозицій За Необхідністью
  ${status}  Run Keyword And Return Status
  ...  Wait Until Page Contains  необхідно подовжити період прийому пропозицій  3
  Run Keyword If  '${status}' == 'True'  Run Keywords
  ...  Click Element  xpath=//*[@id="IMMessageBoxBtnOK"]
  ...  AND  Дочекатись Загрузки Сторінки (webclient)
  ...  AND  Змінити хвилини в періоді падачі пропозицій  59


Змінити хвилини в періоді падачі пропозицій
  [Arguments]  ${min}
  ${new date}  Evaluate  '${tender end date[:14]}' + '${min}'
  Заповнити endDate для tender  ${new date}


Перейти на вкладку документи (webclient)
  Click Element  xpath=//*[contains(@id,'TabControl_T4T')]//*[contains(text(),'Документи')]
  Wait Until Page Contains Element  xpath=//*[@data-name="ADDATTACHMENT_L"]


Додати документ власником
  Click Element  xpath=//*[@data-name="BTADDATTACHMENT"]/div
  Дочекатись Загрузки Сторінки (webclient)
  Wait Until Page Contains Element  xpath=//*[@type='file'][1]
  ${doc}=  create_fake_doc
  ${path}  Set Variable  ${doc[0]}
  ${name}  Set Variable  ${doc[1]}
  Choose File  xpath=//*[@type='file'][1]  ${path}
  Click Element  xpath=(//span[.='ОК'])[1]
  Дочекатись Загрузки Сторінки (webclient)
  Page Should Contain  ${name}


Відкрити бланк для створення тендера
  Перейти у розділ публічні закупівлі (тестові)
  Натиснути пункт додати тендер


Вибрати тип торгів (процедура)
  [Arguments]  ${value}
  log  ${value}
  ${value}  method_type_info  ${value}
  ${selector}  Set Variable  xpath=//td[contains(@class,'Box') and .='${value}']
  Click Element  xpath=(//*[@data-name="KDM2"]//input)[2]
  Wait Until Element Is Visible  ${selector}
  Click Element  ${selector}
  Sleep  1


Перейти у розділ публічні закупівлі (тестові)
  Click Element  xpath=(//*[@title="Публичные закупки (тестовые)"])[1]
  Дочекатись Загрузки Сторінки (webclient)


Натиснути пункт додати тендер
  Click Element  xpath=//*[contains(@title, 'Додати')]
  Дочекатись Загрузки Сторінки (webclient)
  Wait Until Element Is Visible  //*[contains(@class, 'activeTab')]//*[contains(text(),'Тестовий тендер')]


Заповнити legalName для tender
  [Arguments]  ${value}
  ${selector}  Set Variable  xpath=//*[@data-name="ORG_GPO_2"]
  Вибрати значення поля у довіднику F10  ${selector}  ${value}  2


Вибрати значення поля у довіднику F10
  [Arguments]  ${field selector}  ${value}  ${result}=1
  [Documentation]  Приймає локатор поля в якому треба вибрати значення з довідника та значення для пошуку.
  ...  Виконує пошук в довіднику та вибирає перше знайдене значення
  ...  Аргумент ${result} визначає який із знайдених значень вибрати
  Click Element  ${field selector}//input[not(contains(@type,'hidden'))]
  Click Element  ${field selector}//*[@title="Вибір з довідника (F10)"]
  Дочекатись Загрузки Сторінки (webclient)
  Заповнити Поле  xpath=//*[@data-name="ORG"]//input[not(contains(@type,'hidden'))]  ${value}
  Sleep  1
  Click Element  xpath=//*[@data-name="OkButton"]//span[text()="OK"]
  Дочекатись Загрузки Сторінки (webclient)
  Click Element  xpath=(//*[@data-placeid="PLACE1"]//td[text()="${value}"])[${result}]
  Sleep  .5
  Click Element  xpath=//*[@title="Вибрати"]
  Дочекатись Загрузки Сторінки (webclient)


Заповнити title для tender
  [Arguments]  ${value}
  Set Global Variable  ${tender title}  ${value}
  Заповнити Поле  xpath=//*[@data-name="TITLE"]//input  ${tender title}


Заповнити description для tender
  [Arguments]  ${value}
  Sleep  1
  Заповнити Поле  xpath=//*[@data-name="DESCRIPT"]//textarea  ${value}


Заповнити amount для tender
  [Arguments]  ${value}
  ${value}  Convert To String  ${value}
  Заповнити Поле  xpath=//*[@data-name="INITAMOUNT"]//input  ${value}

Заповнити minimalStep для tender
  [Arguments]  ${value}
  ${step_rate}  Convert To String  ${value}
  Заповнити Поле  xpath=//*[@data-name="MINSTEP"]//input   ${step_rate}
  Set Global Variable   ${step_rate}


Заповнити valueTAX для tender
  [Arguments]  ${value}
  Run Keyword If  '${value}' == 'True'  Wait Until Keyword Succeeds  10  2  Click Element  xpath=(//*[@data-name="WITHVAT"]//span)[1]


Заповнити endDate для tender
  [Arguments]  ${value}
  ${value}  smarttender_service.convert_datetime_to_smarttender_format  ${value}
  Set Global Variable  ${tender end date}  ${value}
  Заповнити Поле  xpath=//*[@data-name="D_SROK"]//input  ${value}


Заповнити lots для tender
  [Arguments]  ${lots}
  Включити чек-бокс мультилот
  :FOR  ${lot}  in  @{lots}
  \  Додати лот до тендера  ${lot}


Заповнити title для lot
  [Arguments]  ${value}
  Заповнити Поле  xpath=//*[@data-name="LOT_TITLE"]//input  ${value}


Заповнити description для lot
  [Arguments]  ${value}
  Заповнити Поле  xpath=//*[@data-name="LOT_DESCRIPTION"]//textarea  ${value}


Заповнити amount для lot
  [Arguments]  ${value}
  ${value}  Convert To String  ${value}
  Заповнити Поле  xpath=//*[@data-name="LOT_INITAMOUNT"]//input  ${value}


Заповнити minimalStep для lot
  [Arguments]  ${value}
  ${step_rate}  Convert To String  ${value}
  Заповнити Поле  xpath=//*[@data-name="LOT_MINSTEP"]//input   ${step_rate}
  Set Global Variable   ${step_rate}


Заповнити items для tender
  [Arguments]  ${items}
  log  ${items}
  :FOR  ${item}  in  @{items}
  \  Click Element  ${add item btn}
  \  smarttender.Додати предмет в тендер_  ${item}


Заповнити features для tender
  [Arguments]  ${features}
  log  ${features}
  :FOR  ${feature}  in  @{features}
  \  Перейти на вкладку якісних показників
  \  Exit For Loop
  :FOR  ${feature}  in  @{features}
  \  Відкрити бланк для додавання якісних показників
  \  Sleep  1
  \  Додати неціновий показник  ${feature}


Включити чек-бокс мультилот
  Scroll Page To Element XPATH  xpath=(//*[@data-name="ISMULTYLOT"]//span)[1]
  Click Element  xpath=(//*[@data-name="ISMULTYLOT"]//span)[1]
  ${status}  Run Keyword And Return Status  Page Should Contain Element  xpath=(//*[@data-name="ISMULTYLOT"]//span[contains(@class,'Checked')])[1]
  Run Keyword If  '${status}' == 'False'  Включити чек-бокс мультилот
  Дочекатись Загрузки Сторінки (webclient)


Заповнити title для feature
  [Arguments]  ${value}
  Заповнити Поле  xpath=//*[@data-name="CRITERIONNAME"]//input  ${value}


Заповнити description для feature
  [Arguments]  ${value}
  Заповнити Поле  xpath=//*[@data-name="CRITERIONDESCRIPTION"]//textarea  ${value}


Заповнити featureOf для feature
  [Arguments]  ${featureOf}
  log  ${featureOf}
  Run Keyword If  '${featureOf}' == 'lot'  Заповнити рівень привязки  Лот
  Run Keyword If  '${featureOf}' == 'tenderer'  Заповнити рівень привязки  Учасник тендеру
  Run Keyword If  '${featureOf}' == 'item'  Заповнити рівень привязки  Номенклатура


Заповнити рівень привязки
  [Arguments]  ${value}
  Заповнити Поле  xpath=(//*[@data-name="CRITERIONBINDINGLEVEL"]//td)[2]/input  ${value}


Заповнити enum для featureOf
  [Arguments]  ${enums}
  log  ${enums}
  ${index}  Set Variable  ${1}
  :FOR  ${enum}  in  @{enums}
  \  Відкрити бланк для додавання значення критерію
  \  Додати значення критерію  ${enum}  ${index}
  \  ${index}  Set Variable  ${index + 1}


Заповнити title для enum
  [Arguments]  ${value}  ${index}
  ${selector}  Set Variable  xpath=(//*[@data-name="GRID_CRITERIONVALUES"]//table[contains(@class,'obj')]//td[2])[${index}]
  Click Element  ${selector}
  Sleep  .3
  Click Element  ${selector}
  Заповнити Поле  ${selector}/input  ${value}


Заповнити value для enum
  [Arguments]  ${value}  ${index}
  ${value}  Convert To String  ${value}
  ${selector}  Set Variable  xpath=(//*[@data-name="GRID_CRITERIONVALUES"]//table[contains(@class,'obj')]//td[4])[${index}]
  Click Element  ${selector}
  Sleep  .3
  Click Element  ${selector}
  Заповнити Поле  ${selector}/input  ${value}


Відкрити бланк для додавання значення критерію
  Wait Until Keyword Succeeds  10  2  Click Element  xpath=//*[@data-name="GRID_CRITERIONVALUES"]//*[@title='Додати']
  Wait Until Page Contains Element  xpath=//*[@data-name="GRID_CRITERIONVALUES"]//td[@class="cellselected"]  20


Перейти на вкладку якісних показників
  ${status}  Run Keyword And Return Status  Page Should Contain Element  xpath=(//*[@data-name="ISCRITERIA"]//span[contains(@class,'Checked')])[1]
  Run Keyword If  '${status}' == 'False'  Run Keywords
  ...  Scroll Page To Element XPATH  xpath=(//*[@data-name="ISCRITERIA"]//span)[1]
  ...  AND  Click Element  xpath=(//*[@data-name="ISCRITERIA"]//span)[1]
  Wait Until Keyword Succeeds  10  2  Click Element  xpath=//*[contains(@id,'TabControl_T1')]//*[contains(text(),'Якісні показники')]
  Дочекатись Загрузки Сторінки (webclient)


Відкрити бланк для додавання якісних показників
  Wait Until Keyword Succeeds  10  2  Click Element  xpath=//*[@data-name="GRID_CRITERIA"]//*[@title="Додати"]
  Wait Until Page Contains Element  xpath=//*[@data-name="GRID_CRITERIA"]//tr[contains(@class,'selected')]
  Sleep  1


Заповнити Поле
  [Arguments]  ${selector}  ${value}
  Wait Until Page Contains Element  ${selector}
  Sleep  .5
  Input Text  ${selector}  ${value}
  Sleep  .5
  Press Key  ${selector}  \\09
  Sleep  1


Завантажити документ в лот
  [Arguments]  ${username}  ${filepath}  ${tender_uaid}  ${lot_id}
  Підготуватися до редагування тендеру (webclient)
  Перейти на вкладку документи (webclient)
  Додати документ до лоту (webclient)  ${filepath}  ${lot_id}
  Закрити вікно редагування (webclient)
  Підтвердити повідомлення про перевірку публікації документу за необхідністю


Додати документ до лоту (webclient)
  [Arguments]   ${filepath}  ${lot_id}
  Click Element  xpath=//*[@data-name="TREEDOCS"]//td[contains(text(),'${lot_id}')]
  Sleep  .5
  Wait Until Keyword Succeeds  10  2  Click Element  xpath=//*[@data-name="BTADDATTACHMENT"]/div
  Дочекатись Загрузки Сторінки (webclient)
  Wait Until Page Contains Element  xpath=//*[@type='file'][1]
  Choose File  xpath=//*[@type='file'][1]  ${filepath}
  Click Element  xpath=(//span[.='ОК'])[1]
  Дочекатись Загрузки Сторінки (webclient)
  ${name}  Set Variable  ${filepath[5:]}
  Page Should Contain  ${name}


Змінити лот
  [Arguments]  ${username}  ${tender_uaid}  ${lot_id}  ${field}  ${value}
  Підготуватися до редагування тендеру (webclient)
  Click Element  xpath=//*[@data-name="GRID_ITEMS_HIERARCHY"]//td[5][contains(text(),'${lot_id}')]
  Sleep  .5
  ${value}  convert to string  ${value}
  Run Keyword if  '${field}' == 'value.amount'        Run Keywords  Заповнити amount для lot  ${value}  AND  Заповнити minimalStep для lot  ${step_rate}
  ...  ELSE IF    '${field}' == 'minimalStep.amount'  Заповнити minimalStep для lot  ${value}
  ...  ELSE IF    '${field}' == 'description'  Заповнити description для lot  ${value}
  Закрити вікно редагування (webclient)


Створити лот із предметом закупівлі
  [Arguments]  ${username}  ${tender_uaid}  ${lot}  ${item}
  Підготуватися до редагування тендеру (webclient)
  Створити додатковий лот (webclient)
  ${new_lot}  Get From Dictionary  ${lot}  data
  Додати лот до тендера  ${new_lot}
  Click Element  ${add item btn}
  Sleep  1
  Додати предмет в тендер_  ${item}
  Закрити вікно редагування (webclient)


Створити додатковий лот (webclient)
  Click Element  ${add item btn}
  Sleep  .5
  Wait Until Keyword Succeeds  10  2  Click Element  xpath=(//*[@data-name="GRID_ITEMS_HIERARCHY"]//td[contains(text(),'Номенклатура')])[last()]
  Sleep  .5
  Click Element  xpath=(//*[@data-name="GRID_ITEMS_HIERARCHY"]//td[contains(text(),'Номенклатура')])[last()]
  Sleep  .5
  Click Element  xpath=//*[@class="dhxcombo_option_text" and contains(text(),'Лот')]


Додати предмет закупівлі в лот
  [Arguments]  ${username}  ${tender_uaid}  ${lot_id}  ${item}
  Підготуватися до редагування тендеру (webclient)
  Click Element  xpath=//*[@data-name="GRID_ITEMS_HIERARCHY"]//td[5][contains(text(),'${lot_id}')]
  Sleep  .5
  Click Element  ${add item btn}
  Sleep  .5
  Додати предмет в тендер_  ${item}
  Закрити вікно редагування (webclient)


Видалити лот
  [Arguments]  ${username}  ${tender_uaid}  ${lot_id}
  Run Keyword And Ignore Error  Switch browser  ${browserAlias}
  log  ${lot_id}
  Скасувати лот (webclient)  ${lot_id}



Скасувати лот (webclient)
  [Arguments]  ${lot_id}
  Click Element  xpath=//*[@data-placeid="LOTS"]//td[contains(text(),'${lot_id}')]
  Sleep  .5
  Click Element  xpath=//*[@title="Отмена лота"]
  Sleep  .5
  Click Element  xpath=//*[@id="IMMessageBoxBtnOK"]
  Sleep  .5
  Click Element  xpath=//*[@id="IMMessageBoxBtnOK"]
  Заповнити Поле  xpath=//*[@data-type="ComboBox"]//input[@type="text"]  Торги відмінені
  Заповнити Поле  xpath=//*[@data-name="reason"]//textarea  Скасовано за ініціативою організатора
  Click Element  xpath=//*[@title="Додати" and contains(@class,'Button')]
  Sleep  1
  Додати файл  1
  Click Element  xpath=(//span[.='ОК'])[1]
  Sleep  2
  Click Element  xpath=//*[@title="OK"]
  Run Keyword And Ignore Error  Погодитись скасувати лот
  Click Element  xpath=//td[text()='Тестові публічні закупівлі']
  Дочекатись Загрузки Сторінки (webclient)


Погодитись скасувати лот
  Wait Until Page Contains  відмінити лот
  Click Element  xpath=//*[@id="IMMessageBoxBtnYes"]
  Дочекатись загрузки сторінки (webclient)


Додати неціновий показник на тендер
  [Arguments]  ${username}  ${tender_uaid}  ${feature}
  Підготуватися до редагування тендеру (webclient)
  Перейти на вкладку якісних показників
  Відкрити бланк для додавання якісних показників
  Додати неціновий показник  ${feature}
  Закрити вікно редагування (webclient)


Додати неціновий показник на лот
  [Arguments]  ${username}  ${tender_uaid}  ${feature}  ${lot_id}
  Підготуватися до редагування тендеру (webclient)
  Перейти на вкладку якісних показників
  Відкрити бланк для додавання якісних показників
  Додати неціновий показник  ${feature}
  Заповнити Поле  xpath=//*[@data-name="CRITERIONBINDING"]//input[not(contains(@type,'hidden'))]  ${lot_id}
  Закрити вікно редагування (webclient)


Видалити неціновий показник
  [Arguments]  ${username}  ${tender_uaid}  ${feature_id}
  Підготуватися до редагування тендеру (webclient)
  Перейти на вкладку якісних показників
  Click Element  xpath=//*[@data-name="GRID_CRITERIA"]//td[3][contains(text(),'${feature_id}')]
  Sleep  .5
  Click Element  ${delete feature btn}
  Run Keyword And Ignore Error  Wait Until Page Does Not Contain Element  xpath=//*[@data-name="GRID_CRITERIA"]//td[3][contains(text(),'${feature_id}')]
  Закрити вікно редагування (webclient)


Видалити предмет закупівлі
  [Arguments]  ${user}  ${tenderId}  ${item_id}  ${lot_id}
  Підготуватися До Редагування Тендеру (webclient)
  Click Element  xpath=//*[@data-name="GRID_ITEMS_HIERARCHY"]//td[5][contains(text(),'${item_id}')]
  Sleep  .5
  Click Element  ${delete item btn}
  Run Keyword And Ignore Error  Wait Until Page Does Not Contain Element  xpath=//*[@data-name="GRID_ITEMS_HIERARCHY"]//td[5][contains(text(),'${item_id}')]
  Закрити Вікно Редагування (webclient)


Додати неціновий показник на предмет
  [Arguments]  ${username}  ${tender_uaid}  ${feature}  ${item_id}
  Підготуватися до редагування тендеру (webclient)
  Перейти на вкладку якісних показників
  Відкрити бланк для додавання якісних показників
  Додати неціновий показник  ${feature}
  Заповнити Поле  xpath=//*[@data-name="CRITERIONBINDING"]//input[not(contains(@type,'hidden'))]  ${item_id}
  Закрити вікно редагування (webclient)


Пошук тендера по ідентифікатору
  [Arguments]  ${username}  ${tender_uaid}
  [Documentation]  Шукає лот з uaid = tender_uaid. [Повертає] tender (словник з інформацією про лот)
  Відкрити сторінку  tender  ${tender_uaid}


Оновити сторінку з тендером
  [Arguments]  ${username}=NONE  ${tender_uaid}=NONE
  [Documentation]  Оновлює сторінку з лотом для отримання потенційно оновлених даних.
  log  ${mode}
  Виконати синхронізацію з майданчиком


Виконати синхронізацію з майданчиком
  ${last_modification_date}  convert_datetime_to_kot_format  ${TENDER.LAST_MODIFICATION_DATE}
  Open Browser  http://test.smarttender.biz/ws/webservice.asmx/Execute?calcId=_QA.GET.LAST.SYNCHRONIZATION&args={"SEGMENT":3}  chrome
  Wait Until Keyword Succeeds  20 min  10 sec  waiting_for_synch  ${last_modification_date}


waiting_for_synch
  [Arguments]  ${last_modification_date}
  ${synch dict}  Get Text  css=.text
  ${dict}  synchronization  ${synch dict}
  ${DateStart}  Set Variable  ${dict[0]}
  ${DateEnd}  Set Variable  ${dict[1]}
  ${WorkStatus}  Set Variable  ${dict[2]}
  ${Success}  Set Variable  ${dict[3]}
  ${status}  Run Keyword if  '${last_modification_date}' < '${DateStart}' and '${DateEnd}' != '${EMPTY}' and '${WorkStatus}' != 'working' and '${Success}' == 'true'
  ...  Set Variable  Pass
  ...  ELSE  Reload Page
  Should Be Equal  ${status}  Pass
  Close Browser
  Run Keyword If  '${role}' == 'tender_owner'  Run Keyword And Ignore Error
  ...  Switch Browser  ${second browser}
  ...  ELSE  Switch Browser  ${browserAlias}
  Reload Page


Отримати інформацію із тендера
  [Arguments]  ${username}  ${tender_uaid}  ${field_name}
  [Documentation]  Отримує значення поля field_name для лоту tender_uaid. [Повертає] tender['field_name'] (значення поля).
  Run Keyword If  '${role}' == 'tender_owner'  Switch Browser  ${second browser}
  Відкрити сторінку  ${field_name}  ${tender_uaid}
  ${need sync}  get_need_sync_status  ${field_name}  ${TEST_NAME}
  Run Keyword if  '${need sync}' == 'True'  smarttender.Оновити сторінку з тендером  ${username}  ${tender_uaid}
  ${response}=  Отримати та обробити дані із тендера_  ${field_name}
  [Return]  ${response}


Отримати інформацію із лоту
  [Arguments]  ${username}  ${tender_uaid}  ${lot_id}  ${field_name}
  [Documentation]  Отримати значення поля field_name з лоту з lot_id в описі для тендера tender_uaid.
  ...  [Повертає] lot['field_name']
  Відкрити сторінку  ${field_name}  ${tender_uaid}
  Відкрити сторінку с потрібним лотом за необхідністю  ${lot_id}
  ${response}=  Отримати та обробити дані із лоту_  ${field_name}  ${lot_id}
  Повернутися до тендеру від лоту за необхідністю
  [Return]  ${response}


Внести зміни в тендер
  [Arguments]  ${user}  ${tenderId}  ${field}  ${value}
  [Documentation]  Змінює значення поля fieldname на fieldvalue для лоту tender_uaid.
  Pass Execution If  '${role}'=='provider' or '${role}'=='viewer'  Данний користувач не може вносити зміни в аукціон
  Підготуватися до редагування тендеру (webclient)
  Змінити дані тендера  ${field}  ${value}
  Закрити вікно редагування (webclient)


Отримати кількість документів в тендері
  [Arguments]  ${user}  ${tenderId}
  [Documentation]  Отримує кількість документів до лоту tender_uaid. [Повертає] number_of_documents (кількість доданих документів).
  Run Keyword  smarttender.Пошук тендера по ідентифікатору  ${user}  ${tenderId}
  ${documentNumber}=  Execute JavaScript  return (function(){return $("div.row.document").length-1;})()
  ${documentNumber}=  Convert To Integer  ${documentNumber}
  [Return]  ${documentNumber}


Скасувати закупівлю
  [Arguments]  ${user}  ${tenderId}  ${reason}  ${file}  ${descript}
  [Documentation]  Створює запит для скасування лоту tender_uaid, додає до цього запиту документ, який знаходиться по шляху document,
  ...  змінює опис завантаженого документа на new_description і переводить скасування закупівлі в статус active.
  ...  Цей ківорд реалізовуємо лише для процедур на цбд1.
  Pass Execution If  '${role}' == 'provider' or '${role}' == 'viewer'  Даний учасник не може скасувати тендер
  ${documents}=  create_fake_doc
  Log To Console  Скасувати закупівлю
  debug
  Підготуватися до редагування  ${user}     ${tenderId}
  Click Element  jquery=a[data-name='F2_________GPCANCEL']
  Wait Until Page Contains  Протоколи скасування
  Set Focus To Element  jquery=#cpModalMode table[data-name='reason'] input:eq(1)
  Execute JavaScript  (function(){$("#cpModalMode table[data-name='reason'] input:eq(1)").val('');})()
  Input Text  jquery=#cpModalMode table[data-name='reason'] input:eq(1)    ${reason}
  Press Key  jquery=#cpModalMode table[data-name='reason'] input:eq(1)         \\13
  click element  xpath=//div[@title="Додати"]
  Choose File  id=fileUpload  ${file}
  Click Element  xpath=//*[@class="dxr-group mygroup"][1]
  click element  xpath=.//*[@data-type="TreeView"]//tbody/tr[2]
  click element  xpath=.//*[@data-type="TreeView"]//tbody/tr[2]
  Set Focus To Element  jquery=table[data-name='DocumentDescription'] input:eq(0)
  Input Text  jquery=table[data-name='DocumentDescription'] input:eq(0)    ${descript}
  Press Key  jquery=table[data-name='DocumentDescription'] input:eq(0)  \\13
  Click Element  jquery=a[title='OK']
  Wait Until Page Contains  аукціон буде
  Click Element  jquery=#IMMessageBoxBtnYes


Отримати посилання на аукціон для глядача
  [Arguments]  @{ARGUMENTS}
  [Documentation]  Отримує посилання на аукціон для лоту tender_uaid. [Повертає] auctionUrl (посилання).
  ...  ${username}  ${tender_uaid}  ${zero}
  smarttender.Пошук тендера по ідентифікатору  ${ARGUMENTS[0]}  ${ARGUMENTS[1]}
  ${status}=  Run Keyword and Return Status  Wait Until Element Is Visible  css=#view-auction
  Run Keyword If  '${status}' == "False"  Reload Page
  Click Element  xpath=(//*[@data-qa='auction-link-button']//span)[1]
  Wait Until Keyword Succeeds  30  3  Click Element  xpath=(//*[@data-qa='auction-link-button']//span)[2]
  ${href}  Get Element Attribute  xpath=//*[@data-qa='auction-link-button']//a@href
  [Return]  ${href}

####################################
#        Нецінові показники        #
####################################
Отримати інформацію із нецінового показника
  [Arguments]  ${username}  ${tender_uaid}  ${feature_id}  ${field_name}
  [Documentation]  Отримати значення поля field_name з нецінового показника з feature_id в описі для тендера tender_uaid.
  ...  [Повертає] feature['field_name']
  Відкрити сторінку с потрібним лотом за необхідністю  ${feature_id}
  ${response}=  Отримати та обробити дані нецінового показника  ${field_name}  ${feature_id}
  Повернутися до тендеру від лоту за необхідністю
  [Return]  ${response}


Отримати та обробити дані нецінового показника
  [Arguments]  ${field_name}  ${feature_id}
  ${selector}  non_price_field_info  ${field_name}  ${feature_id}
  Scroll Page To Element XPATH  ${selector}
  ${value}=  Get Text  ${selector}
  ${ret}  convert_result  ${field_name}  ${value}
  [Return]  ${ret}


Відкрити сторінку с потрібним лотом за необхідністю
  [Arguments]  ${id}
  ${data}  get_tender_data  ${API_HOST_URL}/api/${API_VERSION}/tenders/${info_idcbd}
  ${data}  evaluate  json.loads($data)  json
  ${status}  ${number_of_lots}  Run Keyword And Ignore Error  Get Length  ${data['data']['lots']}
  ${number_of_lots}  Run Keyword If  '${status}' == 'FAIL'  Set Variable  1
  ...  ELSE  Set Variable   ${number_of_lots}
  ${title}  Run Keyword If  '${number_of_lots}' > '1'  Отримати title лоту  ${id}  ${data}
  Run Keyword If  '${number_of_lots}' > '1'  Відкрити сторінку multiple_items  ${title}  ${title}


Отримати title лоту
  [Arguments]  ${id}  ${data}
  ${first letter}  Set Variable  ${id[0]}
  ${title}  Run Keyword if  "${first letter}" == "i"  Get title from items  ${id}  ${data}
  ...  ELSE IF  "${first letter}" == "l"  Set Variable  ${id}
  ...  ELSE IF  "${first letter}" == "f"  Get title from feature  ${id}  ${data}
  [Return]  ${title}


Get title from items
  [Arguments]  ${id}  ${data}
  ${n}  get length  ${data['data']['items']}
  :FOR  ${i}  in range  ${n}
  \  ${status}  Run Keyword If  "${id}" in "${data['data']['items'][${i}]['description']}"  Set Variable  Pass
  \  ${relatedLot}  Run Keyword If  "${status}" == "Pass"  Set Variable  ${data['data']['items'][${i}]['relatedLot']}
  \  ${title}  Get title by lotid  ${data}  ${relatedLot}
  \  Run Keyword If  "${status}" == "Pass"  Exit For Loop
  [Return]  ${title}


Get title from feature
  [Arguments]  ${id}  ${data}
  ${n}  get length  ${data['data']['features']}
  :FOR  ${i}  in range  ${n}
  \  ${status}  Run Keyword If  "${id}" in "${data['data']['features'][${i}]['title']}"  Set Variable  Pass
  \  ${relatedItem}  Run Keyword If  "${status}" == "Pass"  Set Variable  ${data['data']['features'][${i}]['relatedItem']}
  \  ${relatedLot}  Get relatedLot for item  ${data}  ${relatedItem}
  \  ${title}  Get title by lotid  ${data}  ${relatedLot}
  \  Run Keyword If  "${status}" == "Pass"  Exit For Loop


Get relatedLot for item
  [Arguments]  ${data}  ${relatedItem}
  ${n}  get length  ${data['data']['items']}
  :FOR  ${i}  in range  ${n}
  \  ${status}  Run Keyword If  "${relatedItem}" in "${data['data']['items'][${i}]['id']}"  Set Variable  Pass
  \  ${relatedLot}  Run Keyword If  "${status}" == "Pass"  Set Variable  ${data['data']['items'][${i}]['relatedLot']}
  \  Run Keyword If  "${status}" == "Pass"  Exit For Loop
  [Return]  ${relatedLot}


Get title by lotid
  [Arguments]  ${data}  ${relatedLot}
  ${n}  get length  ${data['data']['lots']}
  :FOR  ${i}  in range  ${n}
  \  ${status}  Run Keyword If  "${relatedLot}" == "${data['data']['lots'][${i}]['id']}"  Set Variable  Pass
  \  ${title}  Run Keyword If  "${status}" == "Pass"  Set Variable  ${data['data']['lots'][${i}]['title']}
  \  Run Keyword If  "${status}" == "Pass"  Exit For Loop
  [Return]  ${title}


Повернутися до тендеру від лоту за необхідністю
  ${location status}  Run Keyword And Return Status  Location Should Contain  /lot/details/
  Run Keyword If  '${location status}' == '${True}'  Run Keywords
  ...  Go Back
  Location Should Contain  publichni-zakupivli


####################################
#      Робота з документами        #
####################################
Завантажити документ
  [Arguments]  ${username}  ${filepath}  ${tender_uaid}
  [Documentation]  Завантажує документ, який знаходиться по шляху filepath, до лоту tender_uaid користувачем username. [Повертає] reply (словник з інформацією про документ).
  Завантажити документ власником  ${username}  ${filepath}  ${tender_uaid}


Завантажити документ в тендер з типом
  [Arguments]  ${username}  ${tender_uaid}  ${filepath}  ${doc_type}
  [Documentation]  [Призначення] Завантажує документ, який знаходиться по шляху filepath і має певний documentType
  ...  (наприклад, x_nda, tenderNotice і т.д), до лоту tender_uaid користувачем username.
  ...  [Повертає] reply (словник з інформацією про документ).
  Pass Execution If  '${role}' == 'provider' or '${role}' == 'viewer'  Даний учасник не може завантажити документ в тендер
  Завантажити документ власником  ${username}  ${filepath}  ${tender_uaid}
  Вибрати тип завантаженого документу_  ${doc_type}
  [Teardown]  Закрити вікно редагування (webclient)


Завантажити ілюстрацію
  [Arguments]    ${username}  ${tender_uaid}  ${filepath}
  [Documentation]  Завантажує ілюстрацію, яка знаходиться по шляху filepath
  ...  і має documentType = illustration, до лоту tender_uaid користувачем username.
  smarttender.Завантажити документ в тендер з типом  ${username}  ${tender_uaid}  ${filepath}  illustration
  [Teardown]  Закрити вікно редагування (webclient)


Завантажити фінансову ліцензію
  [Arguments]  ${user}  ${tenderId}  ${license_path}
  [Documentation]  Завантажує фінансову ліцензію, яка знаходиться по шляху filepath
  ...  і має documentType = financialLicense, до ставки лоту tender_uaid користувачем username.
  ...  Фінансова ліцензія вантажиться до ставок лише для лотів типу dgfFinancialAssets на цбд1.
  smarttender.Завантажити документ в ставку  ${user}  ${license_path}  ${tenderId}


Завантажити протокол аукціону
  [Arguments]  ${user}  ${tenderId}  ${filePath}  ${index}
  [Documentation]  Завантажує протокол аукціону, який знаходиться по шляху filepath
  ...  і має documentType = auctionProtocol, до ставки кандидата на кваліфікацію лоту tender_uaid користувачем username.
  ...  Ставка, до якої потрібно додавати аукціон протоколу визначається за award_index.
  ...  [Повертає] reply (словник з інформацією про документ).
  Run Keyword  smarttender.Пошук тендера по ідентифікатору  ${user}  ${tenderId}
  ${href}=  Get Element Attribute  jquery=div#auctionResults div.row.well:eq(${index}) a.btn.btn-primary@href
  Go To  ${href}
  Click Element  jquery=a.attachment-button:eq(0)
  ${hrefQualification}=  Get Element Attribute  jquery=a.attachment-button:eq(0)@href
  go to  ${hrefQualification}
  Choose File  jquery=input[name='fieldUploaderTender_TextBox0_Input']:eq(0)    ${filePath}
  Click Element  jquery=div#SubmitButton__1_CD
  Page Should Contain  Кваліфікаційні документи відправлені


Змінити документацію в ставці
  [Arguments]  ${username}  ${tender_uaid}  ${doc_data}  ${doc_id}
  [Documentation]  Змінити тип документа з doc_id в заголовку в пропозиції
  ...  користувача username для тендера tender_uaid.
  ...  Дані про новий тип документа знаходяться в doc_data.
  ${confidentiality}  Get From Dictionary  ${doc_data.data}  confidentiality
  ${confidentialityRationale}  Get From Dictionary  ${doc_data.data}  confidentialityRationale
  ${doc}=  create_fake_doc
  ${path}  Set Variable  ${doc[0]}
  Замінити файл  ${doc_id}  ${path}
  Зазначити конфіденційність  ${doc_id}  ${confidentialityRationale}
  Подати пропозицію


Замінити файл
  [Arguments]  ${doc_id}  ${path}
  Click Element  xpath=//*[contains(text(), '${doc_id}')]/../../../..//*[@class="ivu-tooltip-rel"]/button
  Choose File  xpath=(//input[@type="file"])[1]  ${path}


Зазначити конфіденційність
  [Arguments]  ${doc_id}  ${confidentialityRationale}
  [Documentation]  Зазначує конфіденційність для батька(DOM) документа по ID
  Click Element  xpath=//*[contains(text(), '${doc_id}')]/../../../../../preceding-sibling::div[1]//*[@class="ivu-switch-inner"]
  Input Text  xpath=//*[contains(text(), '${doc_id}')]/../../../../../preceding-sibling::div[1]//*[@spellcheck]  ${confidentialityRationale}


Додати Virtual Data Room
  [Arguments]  ${user}  ${tenderId}  ${link}
  [Documentation]  Додає посилання на Virtual Data Room vdr_url з назвою title до лоту tender_uaid користувачем username.
  ...  Посилання на Virtual Data Room додається лише для лотів типу dgfFinancialAssets на цбд1.
  Pass Execution If  '${role}' == 'provider' or '${role}' == 'viewer'  Даний учасник не може завантажити ілюстрацію
  log to console  Додати Virtual Data Room
  debug
  Підготуватися до редагування тендеру (webclient)  ${user}  ${tenderId}
  Click Element  ${owner change}
  Wait Until Page Contains  Завантаження документації
  Click Element  jquery=#cpModalMode li.dxtc-tab:contains('Завантаження документації')
  Set Focus To Element  jquery=div#pcModalMode_PWC-1 table[data-name='VDRLINK'] input:eq(0)
  Input Text  jquery=div#pcModalMode_PWC-1 table[data-name='VDRLINK'] input:eq(0)  ${link}
  Press Key  jquery=div#pcModalMode_PWC-1 table[data-name='VDRLINK'] input:eq(0)  \\13
  Click Image  jquery=#cpModalMode div.dxrControl_DevEx a:contains('Зберегти') img


Додати публічний паспорт активу
  [Arguments]  ${user}  ${tenderId}  ${link}
  [Documentation]  Додає посилання на публічний паспорт активу certificate_url з назвою title до лоту tender_uaid користувачем username.
  Pass Execution If  '${role}' == 'provider' or '${role}' == 'viewer'  Даний учасник не може завантажити паспорт активу
  Log To Console  Додати публічний паспорт активу
  debug
  Підготуватися до редагування тендеру (webclient)  ${user}  ${tenderId}
  Click Element  ${owner change}
  Wait Until Page Contains  Завантаження документації
  Click Element  jquery=#cpModalMode li.dxtc-tab:contains('Завантаження документації')
  Set Focus To Element  jquery=div#pcModalMode_PWC-1 table[data-name='PACLINK'] input:eq(0)
  Input Text  jquery=div#pcModalMode_PWC-1 table[data-name='PACLINK'] input:eq(0)  ${link}
  Press Key  jquery=div#pcModalMode_PWC-1 table[data-name='PACLINK'] input:eq(0)  \\13
  Click Image  jquery=#cpModalMode div.dxrControl_DevEx a:contains('Зберегти') img


Додати офлайн документ
  [Arguments]  ${user}  ${tenderId}  ${description}
  [Documentation]  Додає документ з назвою title, деталями доступу accessDetails
  ...  та строго визначеним documentType = x_dgfAssetFamiliarizationдо лоту tender_uaid користувачем username.
  Pass Execution If  '${role}' == 'provider' or '${role}' == 'viewer'  Даний учасник не може додати офлайн документ
  log to console  Додати офлайн документ
  debug
  Підготуватися до редагування тендеру (webclient)  ${user}  ${tenderId}
  Click Element  ${owner change}
  Wait Until Page Contains  Завантаження документації  ${wait}
  Click Element  ${add files tab}
  Input Text  xpath=(//*[@data-type="EditBox"])[last()]//textarea  ${description}
  [Teardown]  Закрити вікно редагування (webclient)


Отримати інформацію із документа
  [Arguments]  ${username}  ${tender_uaid}  ${doc_id}  ${field}
  [Documentation]  Отримує значення поля field документа doc_id з лоту tender_uaid
  ...  для перевірки правильності відображення цього поля.
  ...  [Повертає] document['field'] (значення поля field)
  Відкрити сторінку  tender  ${tender_uaid}
  ${selector}=  document_fields_info  ${field}  ${doc_id}
  Scroll Page To Element XPATH  ${selector}
  ${result}  Get Text  ${selector}
  [Return]  ${result}


Отримати інформацію із документа по індексу
  [Arguments]  ${user}  ${tenderId}  ${doc_index}  ${field}
  [Documentation]  [Отримує значення поля field документа з індексом document_index з лоту tender_uaid
  ...  для перевірки правильності відображення цього поля.
  ...  [Повертає] field_value (значення поля field)
  ${result}=  Execute JavaScript  return(function(){ return $("div.row.document:eq(${doc_index+1}) span.info_attachment_type:eq(0)").text();})()
  ${resultDoctype}=  map_from_smarttender_document_type  ${result}
  [Return]  ${resultDoctype}


Отримати документ
  [Arguments]  ${username}  ${tender_uaid}  ${doc_id}
  [Documentation]  Завантажує файл з doc_id в заголовку з лоту tender_uaid в директорію ${OUTPUT_DIR}
  ...  для перевірки вмісту цього файлу.
  ...  [Повертає] filename (ім'я завантаженого файлу)
  Відкрити сторінку  tender  ${tender_uaid}
  ${fileUrl}=  Get Element Attribute  xpath=//*[contains(text(), '${doc_id}')]@href
  ${filename}=  Get Text  xpath=//*[contains(text(), '${doc_id}')]
  Sleep  120
  smarttender_service.download_file  ${fileUrl}  ${OUTPUT_DIR}/${filename}
  [Return]  ${filename}


Отримати документ до лоту
  [Arguments]  ${username}  ${tender_uaid}  ${lot_id}  ${doc_id}
  [Documentation]  Завантажити файл doc_id до лоту з lot_id в описі для тендера tender_uaid в директорію ${OUTPUT_DIR} для перевірки вмісту цього файлу.
  ...  [Повертає] filename (ім'я завантаженого файлу)
  Відкрити сторінку  tender  ${tender_uaid}
  ${fileUrl}=  Get Element Attribute  xpath=//*[contains(text(), '${doc_id}')]@href
  ${filename}=  Get Text  xpath=//*[contains(text(), '${doc_id}')]
  smarttender_service.download_file  ${fileUrl}  ${OUTPUT_DIR}/${filename}
  [Return]  ${ret}


####################################
#     Робота з активами лоту       #
####################################
Додати предмет закупівлі
  [Arguments]  ${user}  ${tenderId}  ${item}
  [Documentation]  Додає дані про предмет item до лоту tender_uaid користувачем username.
  Log To Console  Додати предмет закупівлі
  debug
  ${description}=  Get From Dictionary  ${item}  description
  ${quantity}=   Get From Dictionary  ${item}  quantity
  ${cpv}=  Get From Dictionary    ${item.classification}  id
  ${unit}=  Get From Dictionary  ${item.unit}  name
  ${unit}=  smarttender_service.convert_unit_to_smarttender_format  ${unit}
  smarttender.Підготуватися до редагування  ${user}  ${tenderId}
  click element  ${owner change}
  Wait Until Element Contains  jquery=#cpModalMode     Коригування  ${wait}
  Page Should Not Contain Element  jquery=#cpModalMode div.gridViewAndStatusContainer a[title='Додати']
  [Teardown]  Закрити вікно редагування (webclient)


Отримати інформацію із предмету
  [Arguments]  ${username}  ${tender_uaid}  ${item_id}  ${field_name}
  [Documentation]  Отримує значення поля field_name з предмету з item_id в описі лоту tender_uaid.
  ...  [Повертає] item['field_name'] (значення поля).
  Відкрити сторінку с потрібним лотом за необхідністю  ${item_id}
  ${response}=  Отримати та обробити дані із предмету  ${field_name}  ${item_id}
  Повернутися до тендеру від лоту за необхідністю
  [Return]  ${response}


Отримати та обробити дані із предмету
  [Arguments]  ${fieldname}  ${id}
  ${selector}  item_field_info  ${fieldname}  ${id}
  Scroll Page To Element XPATH  ${selector}
  ${value}=  Get Text  ${selector}
  ${length}  Get Length  ${value}
  Run Keyword If  ${length} == 0  Capture Page Screenshot  ${OUTPUTDIR}/my_screen{index}.png
  ${ret}  convert_result  ${fieldname}  ${value}
  [Return]  ${ret}


Отримати кількість предметів в тендері
  [Arguments]  ${user}  ${tenderId}
  [Documentation]  Отримує кількість активів лоту у лоті tender_uaid.
  ...  [Повертає] number_of_items (кількість активів лоту).
  smarttender.Пошук тендера по ідентифікатору  ${user}  ${tenderId}
  ${number_of_items}=  Get Element Count  xpath=//div[@id='home']//div[@class='well']
  [Return]  ${number_of_items}


####################################
# Запитання до лоту і активів лоту #
####################################
Задати запитання на предмет
  [Arguments]  ${username}  ${tender_uaid}  ${item_id}  ${question}
  [Documentation]  Створює запитання з даними question до активу лоту з item_id для лоту з tender_uaid користувачем username.
  ...  [Повертає] reply (словник з інформацією про запитання).  discuss
  ${title}=  Get From Dictionary  ${question.data}  title
  ${description}=  Get From Dictionary  ${question.data}  description
  Відкрити вкладку із запитаннями
  ${question_data}=  Задати запитання_  ${title}  ${description}  ${item_id}
  [Return]  ${question_data}


Задати запитання на тендер
  [Arguments]  ${username}  ${tender_uaid}  ${question}
  [Documentation]  Створює запитання з даними question до лоту з tender_uaid користувачем username.
  ...  [Повертає] reply (словник з інформацією про запитання).
  ${title}=  Get From Dictionary  ${question.data}  title
  ${description}=  Get From Dictionary  ${question.data}  description
  Відкрити вкладку із запитаннями
  #Відкрити сторінку questions
  ${question_data}=  Задати запитання_  ${title}  ${description}  no_id
  [Return]  ${question_data}


Отримати інформацію із запитання
  [Arguments]  ${user}  ${tenderId}  ${objectId}  ${field}
  [Documentation]  Отримує значення поля field_name із запитання з question_id в описі для тендера tender_uaid.
  ...  [Повертає] question['field_name'] (значення поля).
  Відкрити вкладку із запитаннями
  ${selector}=  question_field_info  ${field}  ${objectId}
  Scroll Page To Element XPATH  ${selector}
  ${status}  Run Keyword And Return Status  Get Text  ${selector}
  Run Keyword If  '${status}' == 'False'  Run Keywords
  ...  Виконати синхронізацію з майданчиком
  ...  AND  Відкрити вкладку із запитаннями
  Scroll Page To Element XPATH  ${selector}
  ${ret}  Get Text  ${selector}
  Закрити вкладку із запитаннями
  [Return]  ${ret}


Відповісти на запитання
  [Arguments]  ${username}  ${tender_uaid}  ${answer_data}  ${question_id}
  [Documentation]  Надає відповідь answer_data на запитання з question_id до лоту tender_uaid.
  ...  [Повертає] reply (словник з інформацією про відповідь).
  ${status}=  Run Keyword And Return Status  Location Should Contain  webclient
  Run Keyword If  '${status}' == '${False}'  Switch Browser  ${browserAlias}
  Location Should Contain  webclient
  Закрити інформаційне вікно за необхідністю (webclient)
  Перейти на вкладку меню тендера (webclient)  ' Обговорення закупівлі'
  Click Element  xpath=//*[@title="Перечитати (Shift+F4)"]
  Sleep  .5
  ${answer text}  Get From Dictionary  ${answer_data.data}  answer
  Wait Until Page Contains  ${question_id}
  Click Element  xpath=//td[contains(text(),'${question_id}')]
  Натиснути кнопку "Змінити F4" (webclient)
  Input Text  xpath=//*[@data-name="ANSWER"]//textarea  ${answer text}
  Click Element  xpath=//*[@data-type="CheckBox"]//*[text()='Зафіксувати відповідь']
  Sleep  .5
  Закрити вікно редагування (webclient)
  Погодитись надіслати відповідь до ЦБД
  Закрити вікно "конфлікт оновлення" за необхідністю
  Перейти на вкладку меню тендера (webclient)  'Тестові публічні закупівлі'


Закрити інформаційне вікно за необхідністю (webclient)
  Run Keyword And Ignore Error  Click Element  xpath=//*[@id="instantMessageFullScreenClose"]
  Run Keyword And Ignore Error  Wait Until Element Is Not Visible  xpath=//*[@id="instantMessageFullScreenContent"]


Закрити вікно "конфлікт оновлення" за необхідністю
  Run Keyword And Ignore Error  Click Element  xpath=//*[@title="Записати"]
  Run Keyword And Ignore Error  Wait Until Element Is Not Visible  xpath=//*[@title="Записати"]


Перейти на вкладку меню тендера (webclient)
  [Arguments]  ${tab name}
  Click Element  xpath=//div[text()=${tab name}]
  Дочекатись Загрузки Сторінки (webclient)
  Page Should Contain Element  xpath=//*[contains(@class,'active-tab')]//*[text()=${tab name}]


Погодитись надіслати відповідь до ЦБД
  Wait Until Page Contains  Надіслати відповідь
  Click Element  xpath=//*[text()='Так']
  Дочекатись загрузки сторінки (webclient)


Задати запитання на лот
  [Arguments]  ${username}  ${tender_uaid}  ${lot_id}  ${question}
  [Documentation]  Створити запитання з даними question до лоту з lot_id в описі для тендера tender_uaid.
  ${title}=  Get From Dictionary  ${question.data}  title
  ${description}=  Get From Dictionary  ${question.data}  description
  Відкрити вкладку із запитаннями
  Задати запитання_  ${title}  ${description}  no_id
  Закрити вкладку із запитаннями


Відкрити вкладку із запитаннями
  [Documentation]  Відкриває вкладку із запитаннями за необхідністю
  ${status}=  Run Keyword and return Status  Page Should Contain Element  xpath=//*[contains(text(), 'Запитання')]/ancestor::div[not(contains(@class,'active'))][2]  3s
  Run Keyword If  '${status}' == "True"  Run Keywords
  ...  smarttender.Оновити сторінку з тендером
  ...  AND  Click Element  xpath=//*[@data-qa='tabs']//*[contains(text(), 'Запитання')]


Закрити вкладку із запитаннями
  [Documentation]  Повертає з вкладки із запитаннями на вкладку тендер за необхідністю
  ${status}  Run Keyword And Return Status  Page Should Contain Element  xpath=//*[contains(text(), 'Запитання')]/ancestor::div[contains(@class,'active')]  3s
  Run Keyword If  '${status}' == "True"  Click Element  xpath=//*[@data-qa='tabs']//*[contains(text(),'Тендер')]


####################################
#       Цінові пропозиції          #
####################################
Подати цінову пропозицію
  [Arguments]  ${username}  ${tender_uaid}  ${bid}  ${lots_ids}=None  ${features_ids}=None
  [Documentation]  Подає цінову пропозицію bid до лоту tender_uaid користувачем username.
  ...  [Повертає] reply (словник з інформацією про цінову пропозицію).
  Відкрити сторінку  proposal  ${tender_uaid}
  log  ${mode}
  log  ${bid}
  log  ${lots_ids}
  log  ${features_ids}
  ${status}  ${amount}  Run Keyword And Ignore Error  Get From Dictionary  ${bid.data.lotValues[0].value}  amount
  ${amount}  Run Keyword If  '${status}' == 'FAIL'  Get From Dictionary  ${bid.data.value}  amount
  ...  ELSE  Set Variable  ${amount}
  ${amount}=  convert to string  ${amount}
  ${tenderers}=  Run Keyword IF  '${mode}' != 'belowThreshold'
  ...  Get From Dictionary  ${bid.data.tenderers[0].identifier}  id
  ${parameters}=  Run Keyword IF  ('${mode}' != 'belowThreshold' and '${mode}' != 'open_competitive_dialogue')
  ...  Get From Dictionary  ${bid.data.parameters[0]}  code
  Прийняти участь в тендері  ${username}  ${tender_uaid}  ${amount}
  ${response}=  Get Value  css=#lotAmount0>input
  ${response}=  Run Keyword if  "${response}" != "None"  smarttender_service.delete_spaces  ${response}
  [Return]  ${response}


Змінити цінову пропозицію
  [Arguments]  ${username}  ${tender_uaid}  ${fieldname}  ${fieldvalue}
  [Documentation]  Змінює поле fieldname на fieldvalue цінової пропозиції користувача username до лоту tender_uaid.
  ...  [Повертає] reply (словник з інформацією про цінову пропозицію)
  ${amount}=  convert to string  ${fieldvalue}
  Прийняти участь в тендері  ${username}  ${tender_uaid}  ${amount}
  ${response}=  Get Value  css=#lotAmount0>input
  ${response}=  Run Keyword if  '${response}' != 'None'  smarttender_service.delete_spaces  ${response}
  [Return]  ${response}


Скасувати цінову пропозицію
  [Arguments]  ${username}  ${tender_uaid}
  [Documentation]  Змінює статус цінової пропозиції до лоту tender_uaid користувача username на cancelled.
  ...  [Повертає] reply (словник з інформацією про цінову пропозицію). Цей ківорд реалізовуємо лише для процедур на цбд1.
  Відкрити сторінку  proposal  ${tender_uaid}
  Unselect Frame
  Wait Until Page Contains Element  ${cancellation offers button}
  Run Keyword And Ignore Error  Click Element  ${cancellation offers button}
  Run Keyword And Ignore Error  Click Element  ${cancel. offers confirm button}
  Run Keyword And Ignore Error  Click Element  ${ok button}


Завантажити документ в ставку
  [Arguments]  ${username}  ${path}  ${tender_uaid}  @{doc_type}
  [Documentation]  Завантажує документ типу doc_type, який знаходиться за шляхом path,
  ...  до цінової пропозиції користувача username для тендера tender_uaid.
  ...  [Повертає] reply (словник з інформацією про завантажений документ).
  Choose File  xpath=(//input[@type="file"][1])[1]  ${path}
  ${status}  Run Keyword And Return Status  Log  ${doc_type[0]}
  ${doc_type}  Run Keyword If  '${status}' == '${True}'  Set Variable  ${doc_type[0]}
  Run Keyword If  '${status}' == '${True}'  Вибрати тип файлу  ${doc_type}
  Подати пропозицію


Вибрати тип файлу
    [Arguments]  ${doc_type}
    ${doc_type_ua}  map_to_smarttender_document_type  ${doc_type}
    Click Element  ${block}[1]${file container}[last()]${choice file button}
    Click Element  xpath=(//*[@class='ivu-card ivu-card-bordered'][1]//*[contains(text(), "${doc_type_ua}")])[last()]


Змінити документ в ставці
  [Arguments]  ${username}  ${tender_uaid}  ${path}  ${docid}
  [Documentation]  Змінює документ з doc_id в пропозиції користувача username для лоту tender_uaid на документ,
  ...  який знаходиться по шляху path.
  ...  [Повертає] uploaded_file (словник з інформацією про завантажений документ).
  smarttender.Завантажити документ в ставку  ${username}  ${path}  ${tender_uaid}


Отримати інформацію із пропозиції
  [Arguments]  ${username}  ${tender_uaid}  ${field}
  [Documentation]  Отримує значення поля field пропозиції користувача username для лоту tender_uaid.
  ...  [Повертає] bid['field'] (значення поля).
  ${selector}  proposal_field_info  ${field}
  ${ret}  Run Keyword If  '${field}' == 'lotValues[0].value.amount' or '${field}' == 'value.amount'
  ...  Отримати інформацію із пропозиції Get Value  ${selector}
  ...  ELSE  Отримати інформацію із пропозиції Get Text  ${username}  ${tender_uaid}  ${selector}  ${field}
  [Return]  ${ret}


Отримати інформацію із пропозиції Get Value
  [Arguments]  ${selector}
  ${value}  Get Value  ${selector}
  ${ret}  delete_spaces  ${value}
  [Return]  ${ret}


Отримати інформацію із пропозиції Get Text
  [Arguments]  ${username}  ${tender_uaid}  ${selector}  ${field}
  Відкрити сторінку  proposal  ${tender_uaid}
  ${text}  Get Text  ${selector}
  ${ret}  smarttender_service.convert_result  ${field}  ${text}
  [Return]  ${ret}


Отримати кількість документів в ставці
  [Arguments]  ${username}  ${tenderId}  ${bidIndex}
  [Documentation]  Отримує кількість документів у ціновій пропозиції з індексом bid_index до лоту tender_uaid.
  ...  [Повертає] number_of_documents (кількість доданих документів).
  Log To Console
  debug  Отримати кількість документів в ставці
  Run Keyword  smarttender.Підготуватися до редагування  ${username}  ${tenderId}
  Click Element  jquery=#MainSted2TabPageHeaderLabelActive_1
  ${normalizedIndex}=  normalize_index  ${bidIndex}  1
  Click Element  jquery=div[data-placeid='BIDS'] div.objbox.selectable.objbox-scrollable table tbody tr:eq(${normalizedIndex}) td:eq(2)
  Wait Until Page Contains  Вкладення до пропозиції  ${wait}
  ${count}=  Execute JavaScript  return(function(){ var counter = 0;var documentSelector = $("#cpModalMode tr label:contains('Кваліфікація')").closest("tr");while (true) { documentSelector = documentSelector.next(); if(documentSelector.length == 0 || documentSelector[0].innerHTML.indexOf("label") === -1){ break;} counter = counter +1;} return counter;})()
  [Return]  ${count}


Отримати дані із документу пропозиції
  [Arguments]  ${username}  ${tender_uaid}  ${bid_index}  ${document_index}  ${field}
  [Documentation]  Отримує значення поля field документу з індексом document_index пропозиції bid_index
  ...  користувача username для лоту tender_uaid.
  ...  [Повертає] field_value (значення поля).
  Log To Console  Отримати дані із документу пропозиції
  debug
  Run Keyword  smarttender.Підготуватися до редагування  ${username}  ${tender_uaid}
  Click Element  jquery=#MainSted2TabPageHeaderLabelActive_1
  ${normalizedIndex}=  normalize_index  ${bid_index}  1
  Click Element  jquery=div[data-placeid='BIDS'] div.objbox.selectable.objbox-scrollable table tbody tr:eq(${normalizedIndex}) td:eq(2)
  Wait Until Page Contains  Вкладення до пропозиції  ${wait}
  ${selectedType}=  Execute JavaScript  return(function(){ var startElement = $("#cpModalMode tr label:contains('Квалификации')"); var documentSelector = $(startElement).closest("tr").next(); if(${document_index} > 0){ for (i=0;i<=${document_index};i++) {documentSelector = $(documentSelector).next();}}if($(documentSelector).length == 0) {return "";} return "auctionProtocol";})()
  [Return]  ${selectedType}


Отримати посилання на аукціон для учасника
  [Arguments]  ${username}  ${tender_uaid}
  [Documentation]  Отримує посилання на участь в аукціоні для користувача username для лоту tender_uaid.
  ...  [Повертає] participationUrl (посилання).
  Click Element  xpath=(//*[@data-qa='auction-link-button']//span)[1]
  Wait Until Keyword Succeeds  30  3  Click Element  xpath=(//*[@data-qa='auction-link-button']//span)[2]
  ${href}  Get Element Attribute  xpath=//*[@data-qa='auction-link-button']//a@href
  Go To  ${href}
  Log Location
  Capture Page Screenshot  ${OUTPUTDIR}/auction{index}.png
  Go Back
  [Return]  ${href}


####################################
#     Кваліфікація кандидата       #
####################################
Завантажити документ рішення кваліфікаційної комісії
  [Arguments]  ${username}  ${file_path}  ${tender_uaid}  ${award_num}
  [Documentation]  Завантажує документ, який знаходиться по шляху file_path до кандидата під номером award_num для лоту tender_uaid.
  ...  [Повертає] doc (словник з інформацією про завантажений документ).
  Pass Execution If  '${role}' == 'provider' or '${role}' == 'viewer'  Даний учасник не може підтвердити постачальника
  log to console  Завантажити документ рішення кваліфікаційної комісії
  debug
  Підготуватися до редагування тендеру (webclient)  ${username}  ${tender_uaid}
  Click Element  jquery=#MainSted2TabPageHeaderLabelActive_1
  ${normalizedIndex}=  normalize_index  ${award_num}     1
  Click Element  jquery=div[data-placeid='BIDS'] div.objbox.selectable.objbox-scrollable table tbody tr:eq(${normalizedIndex}) td:eq(1)
  Click Element  jquery=a[title='Кваліфікація']
  Click Element  xpath=//span[text()='Перегляд...']
  Choose File  ${choice file path}  ${file_path}
  Click Element  ${ok add file}


Підтвердити постачальника
  [Arguments]  ${username}  ${tender_uaid}  ${award_num}
  [Documentation]  Переводить кандидата під номером award_num для лоту tender_uaid в статус active.
  ...  [Повертає] reply (словник з інформацією про кандидата).
  Pass Execution If  '${role}' == 'provider' or '${role}' == 'viewer'  Даний учасник не може підтвердити постачальника
  log to console  Підтвердити постачальника
  debug
  Підготуватися до редагування  ${username}  ${tender_uaid}
  Click Element  jquery=#MainSted2TabPageHeaderLabelActive_1
  ${normalizedIndex}=  normalize_index  ${award_num}  1
  Click Element  jquery=div[data-placeid='BIDS'] div.objbox.selectable.objbox-scrollable table tbody tr:eq(${normalizedIndex}) td:eq(1)
  Click Element  jquery=a[title='Кваліфікація']
  Click Element  query=div.dxbButton_DevEx:contains('Підтвердити оплату')
  Click Element  jquery=div#IMMessageBoxBtnYes
  ${status}=   Execute JavaScript  return  (function() { return $("div[data-placeid='BIDS'] tr.rowselected td:eq(5)").text() } )()
  Should Be Equal  '${status}'  'Визначений переможцем'


Дискваліфікувати постачальника
  [Arguments]  ${username}  ${tender_uaid}  ${award_num}  ${description}
  [Documentation]  Переводить кандидата під номером award_num для лоту tender_uaid в статус unsuccessful.
  ...  [Повертає] reply (словник з інформацією про кандидата).
  log to console  Дискваліфікувати постачальника
  debug
  Підготуватися до редагування  ${username}  ${tender_uaid}
  Click Element  jquery=#MainSted2TabPageHeaderLabelActive_1
  ${normalizedIndex}=  normalize_index  ${award_num}  1
  Click Element  jquery=div[data-placeid='BIDS'] div.objbox.selectable.objbox-scrollable table tbody tr:eq(${normalizedIndex}) td:eq(1)
  Click Element  xpath=//a[@title="Кваліфікація"]
  Click Element  jquery=div.dxbButton_DevEx.dxbButtonSys.dxbTSys span:contains('Відхилити пропозицію')
  Click Element  id=IMMessageBoxBtnNo_CD
  Set Focus To Element  jquery=#cpModalMode textarea
  Input Text  jquery=#cpModalMode textarea  ${description}
  Click Element  xpath=//span[text()="Зберегти"]
  Click Element  id=IMMessageBoxBtnYes_CD


Скасування рішення кваліфікаційної комісії
  [Arguments]    ${username}    ${tender_uaid}    ${award_num}
  [Documentation]  Переводить кандидата під номером award_num для лоту tender_uaid в статус cancelled.
  ...  [Повертає] reply (словник з інформацією про кандидата).
  Pass Execution If  '${role}' == 'provider' or '${role}' == 'tender_owner'  Доступно тільки для другого учасника
  Run Keyword  smarttender.Пошук тендера по ідентифікатору    ${username}  ${tender_uaid}
  Click Element  jquery=div#auctionResults div.row.well:eq(${award_num}) div.btn.withdraw:eq(0)
  Select Frame  css=iframe#cancelPropositionFrame
  Click Element  id=firstYes
  Click Element  id=secondYes


####################################
#      Підписання контракту        #
####################################
Підтвердити підписання контракту
  [Arguments]  ${username}  ${tender_uaid}  ${contract_num}
  [Documentation]  Переводить договір під номером contract_num до лоту tender_uaid в статус active.
  log to console  Підтвердити підписання контракту
  debug
  smarttender.Підготуватися до редагування    ${ARGUMENTS[0]}     ${ARGUMENTS[1]}
  Click Element  jquery=div[data-placeid='BIDS'] div.objbox.selectable.objbox-scrollable table tbody tr:contains('Визначений переможцем') td:eq(1)
  Click Element  jquery=a[title='Підписати договір']:eq(0)
  Click Element  jquery=#IMMessageBoxBtnYes_CD:eq(0)
  Click Element  jquery=#IMMessageBoxBtnOK:eq(0)


Завантажити угоду до тендера
  [Arguments]  ${username}  ${tender_uaid}  ${contract_num}  ${file_path}
  [Documentation]  Завантажує до контракту contract_num лоту tender_uaid документ,
  ...  який знаходиться по шляху filepath і має documentType = contractSigned, користувачем username.
  log to console  Завантажити угоду до тендера
  debug
  Run Keyword  smarttender.Підготуватися до редагування  ${username}  ${tender_uaid}
  Click Element  jquery=#MainSted2TabPageHeaderLabelActive_1
  Click Element  jquery=div[data-placeid='BIDS'] div.objbox.selectable.objbox-scrollable table tbody tr:contains('Визначений переможцем') td:eq(1)
  Click Element  jquery=a[title='Прикріпити договір']:eq(0)
  Wait Until Page Contains  Вкладення договірних документів
  Set Focus To Element  jquery=td.dxic input[maxlength='30']
  Input Text  jquery=td.dxic input[maxlength='30']  11111111111111
  click element  xpath=//span[text()="Перегляд..."]
  Choose File  ${choice file path}  ${ARGUMENTS[3]}
  Click Element  ${ok add file}
  Click Element  jquery=a[title='OK']:eq(0)
  Wait Until Element Is Not Visible  ${webClient loading}  ${wait}


################################################
#                 OPEN PAGE                    #
################################################
Відкрити сторінку
  [Arguments]  ${page}  ${tender_uaid}=None  ${index}=None
  [Documentation]  Відкриває сторінку location або оновлює поточну
  ...  tender
  ...  questions
  ...  cancellation
  ...  proposal
  ...  awards
  ...  claims
  ...  item
  ...  award_claims
  ${location}  ${page}=  location_converter  ${page}
  ${status}  Run Keyword If  '.2' in '${tender_uaid}'  Set Variable  ${False}
  ...  ELSE  Run Keyword And Return Status  Location Should Contain  ${location}
  ${location}  Run keyword if  '${status}' == '${False}' or '.2' in '${tender_uaid}'  Run Keywords
  ...       Відкрити сторінку tender  ${tender_uaid}
  ...  AND  Відкрити сторінку ${page}  ${tender_uaid}  ${index}
  ...  ELSE  Get Location


Відкрити сторінку tender
  [Arguments]  ${tender_uaid}=None  ${index}=None
  ${status}=  Run Keyword If  '.2' in '${tender_uaid}'  Set Variable  ${False}
  ...  ELSE  Run Keyword And Return Status  Location Should Contain  /publichni-zakupivli-prozorro/
  Run Keyword If  "${status}" != "True"  Відкрити сторінку tender continue  ${tender_uaid}


Відкрити сторінку tender continue
  [Arguments]  ${tender_uaid}=None
  ${tender_href}  Run Keyword If  '.2' in '${tender_uaid}'  Set Variable  ${NONE}
  ...  ELSE  Set Variable  ${tender_href}
  Run Keyword If  "${tender_href}" != "None"  Run Keywords
  ...       Go To  ${tender_href}
  ...  AND  Reload Page
  ...  ELSE  Відкрити сторінку tender перший пошук  ${tender_uaid}


Відкрити сторінку tender перший пошук
  [Arguments]  ${tender_uaid}
  Go To  ${path to find tender}
  Wait Until page Contains Element  ${find tender field }  ${wait}
  Run Keyword If  '${mode}' == 'negotiation' or '${mode}' == 'reporting'
  ...  Click Element  css=li:nth-child(2)>a[data-toggle=tab]
  Input Text  ${find tender field }  ${tender_uaid}
  Press Key  ${find tender field }  \\13
  Location Should Contain  f=${tender_uaid}
  ${status}  Run Keyword And Return Status  Wait Until Page Contains Element  ${tender found}
  Run Keyword If  '${status}' == 'False'  Run Keywords
  ...  Виконати синхронізацію з майданчиком
  ...  AND  Відкрити сторінку tender перший пошук  ${tender_uaid}
  ...  ELSE  Перейти до знайденего тендера


Перейти до знайденего тендера
  ${tender_href}=  Get Element Attribute  ${tender found}@href
  Log  ${tender_href}  WARN
  Set Global Variable  ${tender_href}
  Go To  ${tender_href}
  Закрити вспливаюче вікно про повідомлення
  Розгорнути детальніше
  ${info_idcbd}  Get Text  xpath=//*[@data-qa='prozorro-id']/div[2]/span
  Set Global Variable  ${info_idcbd}


Відкрити сторінку proposal
  [Arguments]  ${tender_uaid}=None  ${index}=None
  Wait Until Page Contains Element  xpath=//*[@data-qa='bid-button']
  ${href}=  Get Element Attribute  xpath=//*[@data-qa='bid-button']@href
  Go To  ${href}
  Wait Until Page Contains  Пропозиція


Відкрити сторінку questions
  [Arguments]  ${tender_uaid}=None  ${index}=None
  ${status}  Run Keyword And Return Status  Current Frame Contains  Відгуки Dozorro
  Run Keyword If  "${status}" == "True"  Run Keywords
  ...  Click Element  xpath=//a[@data-toggle='tab' and text()='Запитання ']
  ...  AND  Select frame  css=#iframeQuestions


Відкрити сторінку cancellation
  [Arguments]  ${tender_uaid}=None  ${index}=None
  Click Element  css=a#cancellation
  Select Frame  css=#widgetIframe


Розгорнути інформацію про учасника за потреби
  [Arguments]  ${tender_uaid}=None  ${index}=None
  ${status}  Run Keyword And Return Status  Wait Until Page Contains Element  xpath=//*[@data-qa='qualification-expanded-info']  2
  Run Keyword If  '${status}' == 'False'  Run Keywords
  ...  Click Element  xpath=//*[@data-qa='qualification-info']//*[@class='expander-title']
  ...  AND  Wait Until Page Contains Element  xpath=//*[@data-qa='qualification-expanded-info']
  ${decision status}  Run Keyword And Return Status  Wait Until Element Is Visible  xpath=//*[@data-qa="qualification-expanded-info"]//div/i  2
  Run Keyword If  '${decision status}' == 'False'  Run Keywords
  ...  Click Element  xpath=//*[@data-qa="qualification-expanded-info"]//div/i
  ...  AND  Wait Until Element Is Visible  xpath=//*[@data-qa="qualification-expanded-info"]//*[@data-qa="file-name"]  4
  #${href}=  Get Element Attribute  css=a.att-link[href]@href
  #Go To  ${href}
  #Wait Until Page Contains  Документи


Відкрити сторінку claims
  [Arguments]  ${tender_uaid}=None  ${index}=None
  Wait Until Page Contains Element  ${link to claims}
  Click Element  ${link to claims}
  Wait For Loading
  Page Should Contain Element  ${claims tab active}


Відкрити сторінку award_claims
  [Arguments]  ${tender_uaid}  ${award_index}
  Wait Until Page Contains Element  xpath=(//*[@data-qa='complaint-button'])[${award_index}+1]
  ${href}  Get Element Attribute   xpath=(//*[@data-qa='complaint-button'])[${award_index}+1]@href
  Go To  ${href}
  Location Should Contain  /AppealNew/


Відкрити сторінку multiple_items
  [Arguments]  ${tender_uaid}=None  ${lot_title}=None
  ${status}  Run Keyword And Return Status
  ...  Wait Until Keyword Succeeds  10  3  Click Element  xpath=//*[contains(text(), '${lot_title}')]
  Run Keyword If  '${status}' == 'False'  Run Keywords
  ...  Виконати Синхронізацію З Майданчиком
  ...  AND  Click Element  xpath=//*[contains(text(), '${lot_title}')]


################################################
#            SMARTTENDER KEYWORDS              #
################################################
Login_
  [Arguments]  ${username}
  Закрити вспливаюче вікно про повідомлення
  Click Element  ${open login button}
  Input Text  ${login field}  ${USERS.users['${username}'].login}
  Input Text  ${password field}  ${USERS.users['${username}'].password}
  Click Element  ${remember me}
  Click Element  ${login button}
  Run Keyword If  '${username}' != 'SmartTender_Owner'
  ...  Wait Until Page Contains  ${USERS.users['${username}'].login}  ${wait}
  ...  ELSE  Wait Until Element Is Not Visible  ${webClient loading}  ${wait}


Click Input Enter Wait
  [Arguments]  ${locator}  ${text}
  Wait Until Page Contains Element  ${locator}
  Sleep  .2  # don't touch
  Click Element At Coordinates  ${locator}  10  5
  Input Text  ${locator}  ${text}
  Press Key  ${locator}  \\13
  Wait Until Element Is Not Visible  ${webClient loading}  ${wait}
  Sleep  .3  # don't touch


Отримати та обробити дані із тендера_
  [Arguments]  ${fieldname}
  ${ret}  Run Keyword If  '${fieldname}' == 'stage2TenderID'  Отримати stage2TenderID із ЦДБ
  ...  ELSE  Отримати дані на сторінці з тендером  ${fieldname}
  [Return]  ${ret}


Отримати stage2TenderID із ЦДБ
  ${data}  get_tender_data  ${API_HOST_URL}/api/${API_VERSION}/tenders/${info_idcbd}
  ${data}  evaluate  json.loads($data)  json
  ${stage2TenderID}  Set Variable  ${data['data']['stage2TenderID']}
  [Return]  ${stage2TenderID}


Отримати дані на сторінці з тендером
  [Arguments]  ${fieldname}
  Run Keyword If  'awards' in '${fieldname}'  Розгорнути інформацію про учасника за потреби
  Змінити мову  ${fieldname}
  Set Window Size  1280  1024
  ${selector}=  tender_field_info  ${fieldname}
  ${get attribute}=  get_attribute  ${fieldname}
  Run Keyword If  'suppliers[0].contactPoint.telephone' in '${fieldname}'  Mouse Over  xpath=//table[@class='table-proposal'][1]//td[1]
  Run Keyword If  '${fieldname}' == 'qualificationPeriod.endDate'  Run Keywords
  ...  Виконати Синхронізацію З Майданчиком
  ${value}=  Run Keyword If  '${get attribute}' == 'True'  Get Element Attribute  ${selector}
  ...  ELSE  Get Text  ${selector}
  ${length}  Get Length  ${value}
  Run Keyword If  ${length} == 0  Capture Page Screenshot  ${OUTPUTDIR}/my_screen{index}.png
  ${ret}=  convert_result  ${fieldname}  ${value}
  Змінити мову на ua  ${fieldname}
  [Return]  ${ret}


Розгорнути детальніше
  ${status}  Run Keyword and Return Status  Element Should Be Visible  xpath=(//*[@class='smaller-font']/div[1])[1]
  Run Keyword If  '${status}' == 'False'  Розгорнути детальніше continue


Розгорнути детальніше continue
  ${n}  Get Matching Xpath Count  xpath=//label[@class="tooltip-label"]
  ${end}  Evaluate  ${n}+1
  :FOR  ${i}  in range  1  ${end}
  \  Click Element  xpath=(//label[@class="tooltip-label"])[${i}]


Змінити мову
  [Arguments]  ${fieldname}
  ${lan}  Run Keyword if
  ...           '_en' in '${fieldname}'  Set Variable  en
  ...  ELSE IF  '_ru' in '${fieldname}'  Set Variable  ru
  ...  ELSE IF  '_ua' in '${fieldname}'  Set Variable  uk
  ...  ELSE  Set Variable  default
  Run Keyword If  '${lan}' != 'default'  Run Keywords
  #...       Unselect Frame
  ...  AND  Click Element  ${change language}
  ...  AND  Click Element  css=a[href="javascript:setLanguage('${lan}');"]
  ...  AND  Sleep  3
  #...  AND  Select Frame  css=iframe
  ...  AND  Розгорнути детальніше


Змінити мову на ua
  [Arguments]  ${fieldname}
  ${lan}  Run Keyword if
  ...           '_en' in '${fieldname}'  Set Variable  en
  ...  ELSE IF  '_ru' in '${fieldname}'  Set Variable  ru
  ...  ELSE  Set Variable  default
  Run Keyword If  '${lan}' != 'default'  Змінити мову  _ua


Отримати та обробити дані із лоту_
  [Arguments]  ${fieldname}  ${id}
  ${selector}  lot_field_info  ${fieldname}  ${id}
  Set Window Size  1280  1024
  Scroll Page To Element XPATH  ${selector}
  ${value}=  Get Text  ${selector}
  ${length}  Get Length  ${value}
  Run Keyword If  ${length} == 0  Capture Page Screenshot  ${OUTPUTDIR}/my_screen{index}.png
  ${ret}  convert_result  ${fieldname}  ${value}
  [Return]  ${ret}


Змінити дані тендера
  [Arguments]  ${field}  ${value}
  ${value}  convert to string  ${value}
  Run Keyword if  '${field}' == 'tenderPeriod.endDate'  Заповнити endDate для tender  ${value}
  ...  ELSE IF    '${field}' == 'value.amount'  run keywords  Заповнити amount для tender  ${value}  AND  Заповнити minimalStep для tender  ${step_rate}
  ...  ELSE IF    '${field}' == 'minimalStep.amount'  Заповнити minimalStep для lot  ${value}
  ...  ESLE IF    '${field}' == 'description'  Заповнити description для tender  ${value}


Натиснути "Коригувати" тендер (webclient)
  Click Element  xpath=//*[@title="Коригувати"]
  Wait Until Page Contains Element  xpath=//*[contains(@class,'Disabled') and @title="Коригувати"]


Підготуватися до редагування тендеру (webclient)
  ${status}=  Run Keyword And Return Status  Location Should Contain  webclient
  Run Keyword If  '${status}' == '${False}'  Switch Browser  ${browserAlias}
  Location Should Contain  webclient
  Закрити інформаційне вікно за необхідністю (webclient)
  Натиснути кнопку "Змінити F4" (webclient)
  Натиснути "Коригувати" тендер (webclient)
  
  
Натиснути кнопку "Змінити F4" (webclient)
  Click Element  xpath=(//*[@title="Змінити (F4)"]//span)[3]
  Дочекатись Загрузки Сторінки (webclient)
  Wait Until Page Contains  Коригування


Закрити вікно редагування (webclient)
  [Documentation]  Закриває вікно та ігнорує помилки
  Wait Until Keyword Succeeds  20  2  Click Element  xpath=//*[@title="Зберегти"]
  Продовжити Період Подачі Пропозицій За Необхідністью
  Дочекатись загрузки сторінки (webclient)
  Відмовитись у повідомленні про накладання ЕЦП на тендер


Завантажити документ власником
  [Arguments]  ${username}  ${filepath}  ${tender_uaid}
  Підготуватися до редагування тендеру (webclient)
  Перейти на вкладку документи (webclient)
  Додати документ до тендара (webclient)  ${username}  ${filepath}  ${tender_uaid}
  Закрити вікно редагування (webclient)
  Підтвердити повідомлення про перевірку публікації документу за необхідністю


Додати документ до тендара (webclient)
  [Arguments]  ${username}  ${filepath}  ${tender_uaid}
  Click Element  xpath=//*[@data-name="BTADDATTACHMENT"]/div
  Дочекатись Загрузки Сторінки (webclient)
  Wait Until Page Contains Element  xpath=//*[@type='file'][1]
  Choose File  xpath=//*[@type='file'][1]  ${filepath}
  Click Element  xpath=(//span[.='ОК'])[1]
  Дочекатись Загрузки Сторінки (webclient)
  ${name}  Set Variable  ${filepath[5:]}
  Page Should Contain  ${name}


Вибрати тип завантаженого документу_
  [Arguments]  ${doc_type}
  ${documentTypeNormalized}=  map_to_smarttender_document_type  ${doc_type}
  Click Element  xpath=(//*[text()="Інший тип"])[last()-1]
  Click Element  xpath=(//*[text()="Інший тип"])[last()-1]
  Click Element  xpath=(//*[text()="${documentTypeNormalized}"])[2]


Задати запитання_
  [Arguments]  ${title}  ${description}  ${item_id}
  Відкрити бланк запитання_  ${item_id}
  Заповнити дані для запитання_  ${title}  ${description}
  Відправити запитання та перевірити відповідь


Відкрити бланк запитання_
  [Arguments]  ${item_id}
  Run Keyword if  '${item_id}' == 'no_id'
  ...    Click Element  css=button.question-button
  ...  ELSE
  ...    Відкрити бланк запитання з id  ${item_id}

Відкрити бланк запитання з id
  [Arguments]  ${item_id}
  Click Element  xpath=//*[contains(text(), 'Обрати')]/ancestor::div[@class='ivu-select-selection']
  Input Text  xpath=//div[@class='ivu-select-selection']/descendant::input[@type='text']  ${item_id}
  Click Element  xpath=//ul[@class='ivu-select-dropdown-list']/li[3]
  Wait Until Keyword Succeeds  3m  3  Кнопка поставити запитання


Кнопка поставити запитання
  Click Element  xpath=//*[contains(text(), 'Поставити запитання')]
  Element Should Be Visible  xpath=//*[@class="ivu-form-item-content"]//input


Заповнити дані для запитання_
  [Arguments]  ${title}  ${description}
  Wait Until Keyword Succeeds  30  3  Input Text  xpath=(//*[@class="ivu-form-item-content"]//input)[1]  ${title}
  Input Text  xpath=//*[@class="ivu-form-item-content"]//textarea  ${description}


Відправити запитання та перевірити відповідь
  Click Element  xpath=//button[@type='button']//*[text()='Подати']
  Wait Until Page Contains  Ваше питання було успішно надіслане  10s
  ${status}  Run Keyword And Return Status  Wait Until Element Is Not Visible  xpath=//*[@type='button']//*[contains(text(), 'Подати')]
  Run Keyword If  '${status}' == 'Fail'  Відправити запитання та перевірити відповідь


Пройти кваліфікацію для подачі пропозиції_
  [Arguments]  ${username}  ${tender_uaid}  ${bid}
  log to console  Пройти кваліфікацію для подачі пропозиції
  debug
  Відкрити сторінку  tender  ${tender_uaid}
  ${shouldQualify}=  Get Variable Value  ${bid['data'].qualified}
  Return From Keyword If  '${shouldQualify}' == '${False}'
  Wait Until Page Contains Element  jquery=a#participate  10
  ${lotId}=  Execute JavaScript  return(function(){return $("span.info_lotId").text()})()
  Click Element  jquery=a#participate
  Wait Until Page Contains Element  jquery=iframe#widgetIframe:eq(1)  ${wait}
  Select Frame  jquery=iframe#widgetIframe:eq(1)
  Wait Until Page Contains Element  xpath=.//*[@class="ivu-form-item ivu-form-item-required"][1]//input  ${wait}
  Input Text  xpath=.//*[@class="ivu-form-item ivu-form-item-required"][1]//input  Іван
  Input Text  xpath=.//*[@class="ivu-form-item ivu-form-item-required"][2]//input  Іванов
  Input Text  xpath=.//*[@class="ivu-form-item"][2]//input  Іванович
  Input Text  xpath=.//*[@class="ivu-form-item ivu-form-item-required"][3]//input  +38011111111
  ${file_path}  ${file_name}  ${file_content}=  create_fake_doc
  Run Keyword And Ignore Error  Choose File  jquery=input#GUARAN  ${file_path}
  Run Keyword And Ignore Error  Choose File  jquery=input#FIN  ${file_path}
  Run Keyword And Ignore Error  Choose File  jquery=input#NOTDEP  ${file_path}
  Run Keyword And Ignore Error  Choose File  xpath=//input[@type="file"]  ${file_path}
  Click Element  xpath=//*[@class="group-line"]//input
  Click Element  xpath=//button[@class="ivu-btn ivu-btn-primary pull-right ivu-btn-large"]
  Unselect Frame
  Select Frame  ${iframe}
  Click Element  xpath=//*[@class="modal-dialog "]//*[ @class="close"]
  Open Browser  http://test.smarttender.biz/ws/webservice.asmx/ExecuteEx?calcId=_QA.ACCEPTAUCTIONBIDREQUEST&args={"IDLOT":"${lotId}","SUCCESS":"true"}&ticket=  chrome
  Wait Until Page Contains  True
  Close Browser
  Switch Browser  ${browserAlias}
  Reload Page
  Select Frame  ${iframe}


Прийняти участь в тендері
  [Arguments]  ${username}  ${tender_uaid}  ${amount}
  Відкрити сторінку  proposal  ${tender_uaid}
  Розгорнути всі лоти
  Заповнити дані для подачі пропозиції_  ${amount}  ${tender_uaid}
  Подати пропозицію


Розгорнути всі лоти
  [Documentation]  expand all lots
  Sleep  1
  ${blocks amount}=  Get Matching Xpath Count  .//*[@class='ivu-card ivu-card-bordered']
  Run Keyword If  '${blocks amount}'<'3'
  ...  fatal error  Нету нужных елементов на странице(не та страница)
  ${lots amount}  Evaluate  ${blocks amount}-2
  :FOR  ${INDEX}  IN RANGE  ${lots amount}
  \  ${n}  Evaluate  ${INDEX}+2
  \  Run Keyword And Ignore Error  Click Element  ${block}[${n}]//button


Подати пропозицію
  ${message}  Натиснути надіслати пропозицію та вичитати відповідь
  Виконати дії відповідно повідомленню  ${message}
  Wait Until Page Does Not Contain Element  ${ok button}


Натиснути надіслати пропозицію та вичитати відповідь
  Click Element  ${send offer button}
  Run Keyword And Ignore Error  Wait Until Element Is Visible  ${loading}  10
  Run Keyword And Ignore Error  Wait Until Element Is Not Visible  ${loading}  600
  ${status}  ${message}  Run Keyword And Ignore Error  Get Text  ${validation message}
  Capture Page Screenshot  ${OUTPUTDIR}/my_screen{index}.png
  [Return]  ${message}


Виконати дії відповідно повідомленню
  [Arguments]  ${message}
  Run Keyword If  "${empty error}" in """${message}"""  Подати пропозицію
  ...  ELSE IF  "${EMPTY}" == """${message}"""  Ignore error
  ...  ELSE IF  "${error1}" in """${message}"""  Ignore error
  ...  ELSE IF  "${error2}" in """${message}"""  Ignore error
  ...  ELSE IF  "${error3}" in """${message}"""  Ignore error
  ...  ELSE IF  "${succeed}" in """${message}"""  Click Element  ${ok button}
  ...  ELSE IF  "${succeed2}" in """${message}"""  Click Element  ${ok button}
  ...  ELSE  Fail  Look to message above


Ignore error
  Click Element  ${ok button}
  Wait Until Page Does Not Contain Element  ${ok button}
  Sleep  30
  Подати пропозицію


Заповнити дані для подачі пропозиції_
  [Arguments]  ${value}  ${tender_uaid}=None
  Wait Until Page Contains Element  ${send offer button}
  Sleep  .5
  Run Keyword If  '${NUMBER_OF_ITEMS}' != '1' or 'open' in '${mode}'  Розгорнути лот
  Run Keyword if  ('${mode}' == 'open_competitive_dialogue' or '${value}' == 'active')
  ...  No Operation
  ...  ELSE  Заповнити поле з ціною учасником  ${value}
  Run Keyword If  '.2' in '${tender_uaid}'
  ...  Заповнити поле з ціною учасником  ${value}
  Run Keyword If  '${mode}' != 'belowThreshold'  Підтвердити відповідність
  Додати файл  1     #раніше було  Run Keyword If  '${mode}' == 'openeu'  Додати файл  1


Додати файл
  [Arguments]  ${block}
  ${doc}=  create_fake_doc
  ${path}  Set Variable  ${doc[0]}
  Choose File  xpath=(//input[@type="file"][1])[${block}]  ${path}


Розгорнути лот
  Click Element  ${block}[2]//button


Заповнити поле з ціною учасником
  [Arguments]  ${value}
  Input Text  jquery=div#lotAmount0 input  ${value}


Підтвердити відповідність
  Select Checkbox  ${checkbox1}
  Select Checkbox  ${checkbox2}


####################################
#            PLANNING              #
####################################
Оновити сторінку з планом
  [Arguments]  ${role}  ${tender_id}
  No Operation


Отримати інформацію із плану
  [Arguments]  ${role}  ${tender_id}  ${field}
  No Operation


####################################
#             CLAIMS               #
####################################
##############viewer
Отримати інформацію із скарги
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${field_name}  ${award_index}=None
  [Documentation]  Отримати значення поля field_name скарги/вимоги complaintID про виправлення умов закупівлі/лоту
  ...  для тендера tender_uaid (скарги/вимоги про виправлення визначення переможця під номером award_index,
  ...  якщо award_index != None).
  Run Keyword If  "${TEST_NAME}" == 'Відображення кінцевих статусів двох останніх вимог'  Отримати Інформацію Із Скарги Continue
  ...  ELSE IF  'cancelled' in "${TEST_NAME}"  Отримати Інформацію Із Скарги Continue
  Run Keyword If  '${award_index}' == 'None'  Відкрити сторінку вимог
  ...  ELSE  Відкрити сторінку  award_claims  ${award_index}  ${award_index}   #...  ELSE  Відкрити сторінку award_claims  ${tender_uaid}  ${award_index}
  ${title}  Отримати title по complaintID із ЦБД  ${complaintID}  ${award_index}
  ${selector}  claim_field_info  ${field_name}  ${title}
  Розгорнути потрібну скаргу  ${title}
  ${status}  Run Keyword And Return Status  Element Should Be Visible  ${selector}
  Run Keyword If  '${status}' == 'False'  Run Keywords
  ...  Оновити сторінку вимог
  ...  AND  Розгорнути потрібну скаргу  ${title}
  Scroll Page To Element XPATH  ${selector}
  ${value}  Get Text  ${selector}
  ${response}  convert_claim_result_from_smarttender  ${value}
  [Return]  ${response}


Отримати Інформацію Із Скарги Continue
  ${award_index}  Set Variable  None
  Set Global Variable   ${award_index}
  Reload Page


Отримати інформацію із документа до скарги
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${doc_id}  ${field_name}
  [Documentation]  Отримати значення поля field_name з документу doc_id до скарги/вимоги
  ...  complaintID для тендера tender_uaid.
  ${title}  Отримати title по complaintID із ЦБД  ${complaintID}  0
  Розгорнути потрібну скаргу  ${title}
  ${selector}  claim_file_field_info  ${field_name}  ${doc_id}
  Scroll Page To Element XPATH  ${selector}
  ${response}  Get Text  ${selector}
  [Return]  ${response}


Розгорнути потрібну скаргу
  [Arguments]  ${title}
  ${expand element}  Set Variable  xpath=//*[contains(text(), "${title}")]/ancestor::*[@data-qa='complaint']//*[@data-qa="expander"]
  ${status}  Run Keyword and Return Status  Click Element  ${expand element}
  Run Keyword If  '${status}' == 'False'  Розгорнути потрібну скаргу  ${title}
  ${status}  Run Keyword and Return Status  Wait Until Page Contains Element  xpath=//*[contains(text(), "${title}")]/ancestor::*[@data-qa='complaint']//*[@data-qa='expander' and contains(text(), 'Сховати')]  5
  Run Keyword If  '${status}' == 'False'  Розгорнути потрібну скаргу  ${title}


Відкрити сторінку вимог
  [Arguments]  ${tender_uaid}=None
  Reload Page
  Wait Until Keyword Succeeds  30s  3s  Click Element  xpath=//*[@data-qa='tabs']//span[contains(text(),'Вимоги')]
  Wait Until Page Contains Element  xpath=//*[@data-qa="filter"]  60


Оновити сторінку вимог
  Виконати синхронізацію з майданчиком
  Відкрити сторінку вимог


Вибрати тип вимоги у фільтрі
  [Arguments]  ${type}=None
  Click Element  xpath=//*[@data-qa="filter"]
  Sleep  1
  Run Keyword If  "${type}" == "None"
  ...        Click Element  xpath=//*[@data-qa='filter']//ul[2]/li[1]
  ...  ELSE  Click Element  xpath=//*[@data-qa='filter']//*[contains(text(), '${type}')]
  Wait Until Element Is Not Visible  xpath=//*[@data-qa="filter"]//ul[2]/li[1]


Подати вимогу авторизованим користувачем
  [Arguments]  ${title}  ${description}  ${document}=None  ${award_index}=None
  # Натиснути подати вимогу
  Wait Until Keyword Succeeds  10  3  CLick Element  xpath=//*[@data-qa="submit-claim"]
  Wait For Loading
  # Заповнити дані
  Input Text  xpath=//*[@data-qa='subject']//input  ${title}
  Input Text  xpath=//*[@data-qa='description']//textarea  ${description}
  # Додати файл
  Run Keyword If  '${document}' != 'None'  Choose File  xpath=//*[@data-qa="add-files"]//input[@multiple]  ${document}
  # Натиснути подати вимогу
  Click Element  xpath=//*[@data-qa="add-complaint"]
  Wait For Loading
  Wait Until Element Is Not Visible  xpath=//*[@data-qa='subject']//input  ${wait}
  # return complaintID from the CDB
  ${complaintID}  Отримати complaintID по title із ЦБД  ${title}  ${award_index}
  Run Keyword And Ignore Error  Закрити вікно з повідомленням за необхідністю
  [Return]  ${complaintID}


Закрити вікно з повідомленням за необхідністю
  ${promt window}  Set Variable  xpath=(//*[@data-qa='unsent-documents']//span)[1]
  Wait Until Element Is Visible  ${promt window}  10
  ${message}  Get Text  ${promt window}
  Log  ${message}
  Click Element  xpath=(//*[@data-qa='unsent-documents']//span)[2]
  Wait Until Element Is Not Visible  ${promt window}  10


# Отримати complaintID по title із ЦБД
Отримати complaintID по title із ЦБД
  [Arguments]  ${title}  ${award_index}=None
  ${data}  get_tender_data  ${API_HOST_URL}/api/${API_VERSION}/tenders/${info_idcbd}
  ${data}  evaluate  json.loads($data)  json
  ${complaintID}  Run Keyword If  '${award_index}' == 'None'
  ...        Отримати complaintID по title із ЦБД на умові закупівлі  ${data}  ${title}
  ...  ELSE  Отримати complaintID по title із ЦБД на award  ${data}  ${title}  ${award_index}
  [Return]  ${complaintID}


Отримати complaintID по title із ЦБД на умові закупівлі
  [Arguments]  ${data}  ${title}
  ${n}  Get Length  ${data['data']['complaints']}
  :FOR  ${item}  IN RANGE  ${n}
  \  ${status}  Run Keyword If  "${title}" == "${data['data']['complaints'][${item}]['title']}"  Set Variable  Pass
  \  ${complaintID}  Run Keyword If  "${status}" == "Pass"  Set Variable  ${data['data']['complaints'][${item}]['complaintID']}
  \  Run Keyword If  "${status}" == "Pass"  Exit For Loop
  [Return]  ${complaintID}


Отримати complaintID по title із ЦБД на award
  [Arguments]  ${data}  ${title}  ${award_index}
  ${n}  Get Length  ${data['data']['awards'][${award_index}]['complaints']}
  :FOR  ${item}  IN RANGE  ${n}
  \  ${status}  Run Keyword If  "${title}" == "${data['data']['awards'][${award_index}]['complaints'][${item}]['title']}"  Set Variable  Pass
  \  ${complaintID}  Run Keyword If  "${status}" == "Pass"  Set Variable  ${data['data']['awards'][${award_index}]['complaints'][${item}]['complaintID']}
  \  Run Keyword If  "${status}" == "Pass"  Exit For Loop
  [Return]  ${complaintID}


# Отримати title по complaintID із ЦБД
Отримати title по complaintID із ЦБД
  [Arguments]  ${complaintID}  ${award_index}=None
  log  ${award_index}
  ${data}  get_tender_data  ${API_HOST_URL}/api/${API_VERSION}/tenders/${info_idcbd}
  ${data}  evaluate  json.loads($data)  json
  ${title}  Run Keyword If  '${award_index}' == 'None' or "${TEST_NAME}" == 'Відображення заголовку документації вимоги'
  ...        Отримати title по complaintID із ЦБД на умові закупівлі  ${data}  ${complaintID}
  ...  ELSE  Отримати title по complaintID із ЦБД на award  ${data}  ${complaintID}  ${award_index}
  [Return]  ${title}


Отримати title по complaintID із ЦБД на умові закупівлі
  [Arguments]  ${data}  ${complaintID}
  ${n}  Get Length  ${data['data']['complaints']}
  :FOR  ${item}  IN RANGE  ${n}
  \  ${status}  Run Keyword If  "${complaintID}" == "${data['data']['complaints'][${item}]['complaintID']}"  Set Variable  Pass
  \  ${title}  Run Keyword If  "${status}" == "Pass"  Set Variable  ${data['data']['complaints'][${item}]['title']}
  \  Run Keyword If  "${status}" == "Pass"  Exit For Loop
  [Return]  ${title}


Отримати title по complaintID із ЦБД на award
  [Arguments]  ${data}  ${complaintID}  ${award_index}
  ${n}  Get Length  ${data['data']['awards'][${award_index}]['complaints']}
  :FOR  ${item}  IN RANGE  ${n}
  \  ${status}  Run Keyword If  "${complaintID}" == "${data['data']['awards'][${award_index}]['complaints'][${item}]['complaintID']}"  Set Variable  Pass
  \  ${title}  Run Keyword If  "${status}" == "Pass"  Set Variable  ${data['data']['awards'][${award_index}]['complaints'][${item}]['title']}
  \  Run Keyword If  "${status}" == "Pass"  Exit For Loop
  [Return]  ${title}


Створити чернетку вимоги про виправлення умов закупівлі
  [Arguments]  ${username}  ${tender_uaid}  ${claim}
  [Documentation]  Створює вимогу claim про виправлення умов закупівлі у статусі draft для тендера tender_uaid.
  Відкрити сторінку  claims  ${tender_uaid}
  ${title}  Set Variable  ${claim.data.title}
  ${description}  Set Variable  ${claim.data.description}
  Вибрати тип вимоги у фільтрі
  ${complaintID}  Подати вимогу авторизованим користувачем  ${title}  ${description}
  [Return]  ${complaintID}


Створити чернетку вимоги про виправлення умов лоту
  [Arguments]  ${username}  ${tender_uaid}  ${claim}  ${lot_id}
  [Documentation]   Створює вимогу claim про виправлення умов лоту у статусі draft для тендера tender_uaid.
  Відкрити сторінку  claims  ${tender_uaid}
  ${title}  Set Variable  ${claim.data.title}
  ${description}  Set Variable  ${claim.data.description}
  Вибрати тип вимоги у фільтрі  ${lot_id}
  ${complaintID}  Подати вимогу авторизованим користувачем  ${title}  ${description}
  [Return]  ${complaintID}


Створити чернетку вимоги про виправлення визначення переможця
  [Arguments]  ${username}  ${tender_uaid}  ${claim}  ${award_index}
  [Documentation]   Створює вимогу claim про виправлення визначення переможця під номером award_index в статусі draft для тендера tender_uaid.
  Відкрити сторінку  award_claims  ${award_index}  ${award_index}
  ${title}  Set Variable  ${claim.data.title}
  ${description}  Set Variable  ${claim.data.description}
  ${complaintID}  Подати вимогу авторизованим користувачем  ${title}  ${description}  None  ${award_index}
  [Return]  ${complaintID}


Створити вимогу про виправлення умов закупівлі
  [Arguments]  ${username}  ${tender_uaid}  ${claim}  ${document}=None
  [Documentation]   Створює вимогу claim про виправлення умов закупівлі у статусі claim для тендера tender_uaid. Можна створити вимогу як з документом, який знаходиться за шляхом document, так і без нього.
  ${title}  Set Variable  ${claim.data.title}
  ${description}  Set Variable  ${claim.data.description}
  Відкрити сторінку вимог
  Вибрати тип вимоги у фільтрі
  ${complaintID}  Подати вимогу авторизованим користувачем  ${title}  ${description}  ${document}
  Відкрити сторінку tender
  [Return]  ${complaintID}


Створити вимогу про виправлення умов лоту
  [Arguments]  ${username}  ${tender_uaid}  ${claim}  ${lot_id}  ${document}=None
  [Documentation]   Створює вимогу claim про виправлення умов лоту у статусі claim для тендера tender_uaid. Можна створити вимогу як з документом, який знаходиться за шляхом document, так і без нього.
  ${title}  Set Variable  ${claim.data.title}
  ${description}  Set Variable  ${claim.data.description}
  Відкрити сторінку вимог
  Вибрати тип вимоги у фільтрі  ${lot_id}
  ${complaintID}  Подати вимогу авторизованим користувачем  ${title}  ${description}  ${document}
  [Return]  ${complaintID}


Створити вимогу про виправлення визначення переможця
  [Arguments]  ${username}  ${tender_uaid}  ${claim}  ${award_index}  ${document}=None
  [Documentation]   Створює вимогу claim про виправлення визначення переможця під номером award_index в статусі claim для тендера tender_uaid. Можна створити вимогу як з документом, який знаходиться за шляхом document, так і без нього.
  ${title}  Set Variable  ${claim.data.title}
  ${description}  Set Variable  ${claim.data.description}
  Відкрити сторінку  award_claims  ${award_index}  ${award_index}
  ${complaintID}  Подати вимогу авторизованим користувачем  ${title}  ${description}  ${document}  ${award_index}
  [Return]  ${complaintID}


Завантажити документацію до вимоги
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${document}
  [Documentation]   Додати документ, який знаходиться за шляхом document, до вимоги complaintID для тендера tender_uaid.
  log to console  Завантажити документацію до вимоги
  debug


Завантажити документацію до вимоги про виправлення визначення переможця
  [Arguments]   ${username}  ${tender_uaid}  ${complaintID}  ${award_index}  ${document}
  [Documentation]   Додати документ, який знаходиться за шляхом document, до вимоги complaintID про виправлення визначення переможця під номером award_index для тендера tender_uaid.
  log to console  Завантажити документацію до вимоги про виправлення визначення переможця
  debug


Подати вимогу
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${confirmation_data}
  [Documentation]   Переводить вимогу complaintID для тендера tender_uaid зі статусу draft у статус claim, використовуючи при цьому дані confirmation_data.
  log to console  Подати вимогу
  debug


Подати вимогу про виправлення визначення переможця
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${award_index}  ${confirmation_data}
  [Documentation]   Переводить вимогу complaintID про виправлення визначення переможця під номером award_index для тендера tender_uaid зі статусу draft у статус claim, використовуючи при цьому дані confirmation_data.
  log to console  Подати вимогу про виправлення визначення переможця
  debug


Відповісти на вимогу про виправлення умов закупівлі
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${answer_data}
  [Documentation]   Відповісти на вимогу complaintID про виправлення умов закупівлі для тендера tender_uaid, використовуючи при цьому дані answer_data.
  log to console  Відповісти на вимогу про виправлення умов закупівлі
  debug


Відповісти на вимогу про виправлення умов лоту
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${answer_data}
  [Documentation]   Відповісти на вимогу complaintID про виправлення умов лоту для тендера tender_uaid, використовуючи при цьому дані answer_data.
  log to console  Відповісти на вимогу про виправлення умов лоту
  debug


Відповісти на вимогу про виправлення визначення переможця
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${answer_data}  ${award_index}
  [Documentation]   Відповісти на вимогу complaintID про виправлення визначення переможця під номером award_index для тендера tender_uaid, використовуючи при цьому дані answer_data.
  log to console  Відповісти на вимогу про виправлення визначення переможця
  debug


Підтвердити вирішення вимоги про виправлення умов закупівлі
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${confirmation_data}
  [Documentation]   Перевести вимогу complaintID про виправлення умов закупівлі для тендера tender_uaid у статус resolved, використовуючи при цьому дані confirmation_data.
  ${status}  Run Keyword And Return Status  Page Should Contain Element  ${claims tab active}
  Run Keyword If  '${status}' == 'False'  Click Element  ${link to claims}
  ${satisfied}  Set Variable  ${confirmation_data['data']['satisfied']}
  ${title}  Отримати title по complaintID із ЦБД  ${complaintID}
  Натиснути коригувати  ${title}
  Run Keyword If  "${satisfied}" == "True"  Click Element  xpath=//*[@data-qa="satisfied-decision"]
  ...  ELSE  Click Element  xpath=//*[@data-qa="unsatisfied-decision"]
  Wait For Loading
  Wait Until Element Is Not Visible  xpath=//*[@data-qa="satisfied-decision"]


Підтвердити вирішення вимоги про виправлення умов лоту
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${confirmation_data}
  [Documentation]   Перевести вимогу complaintID про виправлення умов лоту для тендера tender_uaid у статус resolved, використовуючи при цьому дані confirmation_data.
  log to console  Підтвердити вирішення вимоги про виправлення умов лоту
  debug


Підтвердити вирішення вимоги про виправлення визначення переможця
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${confirmation_data}  ${award_index}
  [Documentation]   Перевести вимогу complaintID про виправлення визначення переможця під номером award_index для тендера tender_uaid у статус resolved, використовуючи при цьому дані cancellation_data.
  ${satisfied}  Set Variable  ${confirmation_data['data']['satisfied']}
  ${title}  Отримати title по complaintID із ЦБД  ${complaintID}  ${award_index}
  Натиснути коригувати  ${title}
  Run Keyword If  "${satisfied}" == "True"  Click Element  xpath=//*[@data-qa="satisfied-decision"]
  ...  ELSE  Click Element  xpath=//*[@data-qa="unsatisfied-decision"]
  Wait For Loading
  Wait Until Element Is Not Visible  xpath=//*[@data-qa="satisfied-decision"]


Скасувати вимогу про виправлення умов закупівлі
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${cancellation_data}
  [Documentation]   Перевести вимогу complaintID про виправлення умов закупівлі для тендера tender_uaid у статус cancelled, використовуючи при цьому дані cancellation_data.
  ${cancellationReason}  Set Variable   ${cancellation_data['data']['cancellationReason']}
  ${title}  Отримати title по complaintID із ЦБД  ${complaintID}
  Відкрити сторінку вимог
  Натиснути коригувати  ${title}
  Скасувати вимогу  ${cancellationReason}


Натиснути коригувати
  [Arguments]  ${title}
  Click Element  xpath=//*[contains(text(), "${title}")]/ancestor::div[@data-qa="complaint"]//*[@data-qa="start-edit-mode"]
  Wait For Loading


Скасувати вимогу
  [Arguments]  ${cancellationReason}
  Click Element  xpath=//*[@data-qa="cancel-complaint"]
  Wait Until Keyword Succeeds  1m  5  Run Keywords
  ...  Input Text  xpath=//*[@data-qa="cancel-reason"]//input  ${cancellationReason}
  ...  AND  Click Element  xpath=//*[@data-qa="cancel-modal-submit"]
  ...  AND  Wait For Loading
  ...  AND  Wait Until Element Is Not Visible   xpath=//*[@data-qa="cancel-modal-submit"]
  Відкрити сторінку tender


Скасувати вимогу про виправлення умов лоту
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${cancellation_data}
  [Documentation]   Перевести вимогу complaintID про виправлення умов лоту для тендера tender_uaid у статус cancelled, використовуючи при цьому дані cancellation_data.
  ${cancellationReason}  Set Variable   ${cancellation_data['data']['cancellationReason']}
  ${title}  Отримати title по complaintID із ЦБД  ${complaintID}
  Відкрити сторінку вимог
  Натиснути коригувати  ${title}
  Скасувати вимогу  ${cancellationReason}


Скасувати вимогу про виправлення визначення переможця
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${cancellation_data}  ${award_index}
  [Documentation]  Перевести вимогу complaintID про виправлення визначення переможця під номером award_index для тендера tender_uaid у статус cancelled, використовуючи при цьому дані confirmation_data.
  ${cancellationReason}  Set Variable   ${cancellation_data['data']['cancellationReason']}
  ${title}  Отримати title по complaintID із ЦБД  ${complaintID}  ${award_index}
  Натиснути коригувати  ${title}
  Скасувати вимогу  ${cancellationReason}


Перетворити вимогу про виправлення умов закупівлі в скаргу
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${escalating_data}
  [Documentation]   Перевести вимогу complaintID про виправлення умов закупівлі для тендера tender_uaid у статус pending, використовуючи при цьому дані cancellation_data.
  log to console  Перетворити вимогу про виправлення умов закупівлі в скаргу
  debug


Перетворити вимогу про виправлення умов лоту в скаргу
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${escalating_data}
  [Documentation]   Перевести вимогу complaintID про виправлення умов лоту для тендера tender_uaid у статус pending, використовуючи при цьому дані escalating_data.
  log to cosnole  Перетворити вимогу про виправлення умов лоту в скаргу
  debug


Перетворити вимогу про виправлення визначення переможця в скаргу
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${escalating_data}
  [Documentation]   Перевести вимогу complaintID про виправлення визначення переможця під номером award_index для тендера tender_uaid у статус pending, використовуючи при цьому дані escalating_data. award_index
  log to console  Перетворити вимогу про виправлення визначення переможця в скаргу
  debug


Отримати документ до скарги
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${doc_id}
  [Documentation]   Завантажити файл doc_id до скарги complaintID для тендера tender_uaid в директорію ${OUTPUT_DIR} для перевірки вмісту цього файлу.
  log to console  Отримати документ до скарги
  debug
  [Return]  ${filename}


Wait For Loading
  Run Keyword And Ignore Error  Wait Until Element Is Visible  ${loading}  10
  Run Keyword And Ignore Error  Wait Until Element Is Not Visible  ${loading}  600


Закрити вспливаюче вікно про повідомлення
  Run Keyword And Ignore Error  Wait Until Element Is Visible  ${promt window}  10
  Run Keyword And Ignore Error  Click Element  ${close promt}
  Run Keyword And Ignore Error  Wait Until Element Is Not Visible  ${promt window}  10


Scroll Page To Element XPATH
  [Arguments]    ${xpath}
  Run Keyword And Ignore Error  Execute JavaScript  document.evaluate('${xpath.replace("xpath=", "")}', document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.scrollIntoView({behavior: 'auto', block: 'center', inline: 'center'});
  Run Keyword And Ignore Error  Execute JavaScript  document.evaluate("${xpath.replace('xpath=', '')}", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.scrollIntoView({behavior: 'auto', block: 'center', inline: 'center'});

