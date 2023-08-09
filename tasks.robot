*** Settings ***
Library     RPA.HTTP
Library     RPA.Tables
Library     RPA.Browser.Selenium    auto_close=${false}
Library     RPA.FileSystem
Library     RPA.PDF
Library     RPA.Archive


*** Variables ***
${PDF_TEMP_IMAGES}      ${CURDIR}${/}Receipts_images
${PDF_TEMP_RECEIPTS}    ${CURDIR}${/}Receipts


*** Tasks ***
Order A Bot In A Website Form
    Set Up Directories
    Open Web Browser
    Get Orders From Csv
    Fill The Order Form
    Order The Robot
    Get The Order Receipt
    Create A Zip Folder


*** Keywords ***
Open Web Browser
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order    maximized=${TRUE}

Get Orders From Csv
    Download    https://robotsparebinindustries.com/orders.csv    Orders.csv    overwrite=${TRUE}
    ${Orders}=    Read table from CSV    %{ROBOT_ROOT}${/}Orders.csv    ${TRUE}
    FOR    ${Row}    IN    @{Orders}
        Close The Annoying Modal
        Fill The Order Form    ${Row}
        Wait Until Keyword Succeeds    5 times    1 second    Order The Robot    ${Row}
        Get The Order Receipt    ${Row}
    END
    Create A Zip Folder

Fill The Order Form
    [Arguments]    ${Row}
    Select From List By Index    css:#head    ${Row}[Head]
    Click Element    css:#id-body-${Row}[Body]
    Input Text    xpath:/html/body/div/div/div[1]/div/div[1]/form/div[3]/input    ${Row}[Legs]
    Input Text    css:#address    ${Row}[Address]
    Click Button    css:#preview

Get The Order Receipt
    [Arguments]    ${Row}
    ${Receipt_pdf}=    Get Element Attribute    css:#receipt    outerHTML
    Html To Pdf    ${Receipt_pdf}    ${PDF_TEMP_RECEIPTS}${/}${Row}[Order number].pdf
    Screenshot    css:#robot-preview-image    ${PDF_TEMP_IMAGES}${/}${Row}[Order number].png
    Create The Pdf Receipt Support    ${Row}
    Click Button When Visible    css:#order-another

Close The Annoying Modal
    Click Button    css:#root > div > div.modal > div > div > div > div > div > button.btn.btn-dark

Order The Robot
    [Arguments]    ${Row}
    Click Button    css:#order
    Wait Until Element Is Visible    css:#receipt    1 second

Create The Pdf Receipt Support
    [Arguments]    ${Row}
    ${Picture}=    Create List    ${PDF_TEMP_IMAGES}${/}${Row}[Order number].png
    Add Files To Pdf    ${Picture}    ${PDF_TEMP_RECEIPTS}${/}${Row}[Order number].pdf    ${TRUE}

Create A Zip Folder
    ${Zip_receipts}=    Set Variable    ${OUTPUT_DIR}${/}PDFs.zip
    Archive Folder With Zip    ${PDF_TEMP_RECEIPTS}    ${Zip_receipts}

Set Up Directories
    Create Directory    ${PDF_TEMP_IMAGES}    ${FALSE}
    Create Directory    ${PDF_TEMP_RECEIPTS}    ${FALSE}
