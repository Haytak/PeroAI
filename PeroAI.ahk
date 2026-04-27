#Requires AutoHotkey v2.0
#SingleInstance Force
#Include Neutron.ahk
TraySetIcon(FileExist(A_ScriptDir "\app.ico") ? A_ScriptDir "\app.ico" : "")
SendMode "Input"
SetWorkingDir A_ScriptDir

; Глобальні змінні
CurrentLanguage := ReadLanguage()
L := GetLoc(CurrentLanguage)
CurrentMode := ""
CurrentPromptMode := ""
CurrentModelName := ""
QuickButtons := []
MainHotkey := ""
SettingsHotkey := ""
PromptHotkey := ""
CurrentSelectedText := ""
PromptNeutron := ""
ResultNeutron := ""
SettingsNeutron := ""
WarningNeutron := ""

Init()

; Реєстрація гарячих клавіш
Hotkey MainHotkey, (*) => Main()
Hotkey SettingsHotkey, (*) => OpenSettings()
Hotkey PromptHotkey, (*) => PromptWindow()

ReadHotkey(keyName, default) {
    try {
        val := IniRead(A_ScriptDir "\settings.ini", "Hotkeys", keyName, default)
        return val
    } catch {
        return default
    }
}

ReadMode(section := "Settings", key := "Mode") {
    mode := IniRead(A_ScriptDir "\settings.ini", section, key, "confirm")
    if (mode = "auto" || mode = "confirm" || mode = "clipboard")
        return mode
    return "confirm"
}

ReadQuickButtons(lang) {
    buttons := []
    lObj := GetLoc(lang)
    try {
        ; Читаємо всю секцію. У AHK v2 IniRead(file, section) повертає Key=Value пари
        content := IniRead(A_ScriptDir "\settings.ini", "QuickButtons")
        
        for line in StrSplit(content, "`n") {
            parts := StrSplit(line, "=", , 2)
            if (parts.Length = 2) {
                label := parts[1]
                prompt := parts[2]
                
                ; Якщо це стандартний промпт, локалізуємо його назву
                if (prompt == "Переклади на англійську")
                    label := lObj.qbtn_translate
                else if (prompt == "Поясни що це означає")
                    label := lObj.qbtn_explain
                else if (prompt == "Зроби цей текст коротшим")
                    label := lObj.qbtn_shorten
                    
                buttons.Push({label: label, prompt: prompt})
            }
        }
    } catch {
        if (buttons.Length = 0) {
            ; Значення за замовчуванням
            buttons.Push({label: lObj.qbtn_translate, prompt: "Переклади на англійську"})
            buttons.Push({label: lObj.qbtn_explain, prompt: "Поясни що це означає"})
            buttons.Push({label: lObj.qbtn_shorten, prompt: "Зроби цей текст коротшим"})
        }
    }
    return buttons
}

ReadAutostart() {
    try {
        RegRead("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run", "PeroAI")
        return true
    } catch {
        return false
    }
}

ReadLanguage() {
    return IniRead(A_ScriptDir "\settings.ini", "Settings", "Language", "uk")
}

GetLoc(lang) {
    if (lang = "en") {
        return {
            settings: "Settings",
            api_config: "API Configuration",
            api_key: "Groq API Key",
            show_key: "Show key",
            how_to_get: "How to get Groq API Key?",
            show_result: "Confirm (Show result window)",
            auto_replace: "Auto-replace",
            copy_to_clipboard: "Copy to clipboard",
            ai_prompt_mode: "AI PROMPT MODE (WIN+A)",
            quick_buttons: "QUICK BUTTONS",
            add_button: "+ Add button",
            system: "SYSTEM",
            run_startup: "Run at Windows startup",
            save: "Save",
            cancel: "Cancel",
            copy: "Copy",
            copied: "Copied to clipboard!",
            replace: "Replace",
            original: "ORIGINAL",
            result: "RESULT",
            result_ai: "AI RESPONSE",
            no_selection: "No text selected.",
            no_fix_needed: "No corrections needed.",
            processing: "Processing request...",
            language: "Language",
            your_request: "Your request / Text",
            main_hk: "Main",
            prompt_hk: "Prompt",
            settings_hk: "Settings",
            what_to_do: "What to do with text?",
            send: "Send",
            close: "Close",
            win_a_title: "AI Assistant",
            api_missing_title: "API Key Not Found",
            api_missing_msg: "To use the program, you must specify the Groq API key in the settings. Without it, automatic text correction is impossible.",
            error: "Error",
            api_error: "API Error: HTTP ",
            request_error: "Request Error",
            hotkeys: "Hotkeys",
            prompt_placeholder: "Example: translate to English...",
            qbtn_translate: "Translate",
            qbtn_explain: "Explain",
            correction_mode: "Correction Mode",
            qbtn_shorten: "Shorten",
            ai_model: "AI Model",
            gemini_key: "Gemini API Key",
            groq_key: "Groq API Key",
            how_to_get: "How to get Groq API Key?",
            how_to_get_gemini: "How to get Gemini API Key?",
            name_label: "Name",
            prompt_label: "Prompt"
        }
    } else {
        return {
            settings: "Налаштування",
            api_config: "Налаштування API",
            api_key: "Ключ Groq API",
            show_key: "Показати ключ",
            how_to_get: "Як отримати Groq API Key?",
            how_to_get_gemini: "Як отримати Gemini API Key?",
            show_result: "Confirm (Показувати вікно результату)",
            auto_replace: "Автозаміна",
            copy_to_clipboard: "Копіювати в буфер",
            ai_prompt_mode: "AI PROMPT MODE (WIN+A)",
            quick_buttons: "ШВИДКІ КНОПКИ",
            add_button: "+ Додати кнопку",
            system: "СИСТЕМА",
            run_startup: "Запускати разом з Windows",
            save: "Зберегти",
            cancel: "Скасувати",
            copy: "Копіювати",
            copied: "Скопійовано в буфер!",
            replace: "Замінити",
            original: "ОРИГІНАЛ",
            result: "РЕЗУЛЬТАТ",
            result_ai: "ВІДПОВІДЬ AI",
            no_selection: "Текст не виділено.",
            no_fix_needed: "Виправлення не потрібні.",
            processing: "Обробка запиту...",
            language: "Мова",
            your_request: "Ваш запит / Текст",
            main_hk: "Основний",
            prompt_hk: "Промпт",
            settings_hk: "Налаштування",
            what_to_do: "Що зробити з текстом?",
            send: "Відправити",
            close: "Закрити",
            win_a_title: "AI Помічник",
            api_missing_title: "API ключ не знайдено",
            api_missing_msg: "Для роботи програми необхідно вказати Groq API ключ у налаштуваннях. Без нього автоматичне виправлення тексту неможливе.",
            error: "Помилка",
            api_error: "Помилка API: HTTP ",
            request_error: "Помилка запиту",
            hotkeys: "Гарячі клавіші",
            prompt_placeholder: "Наприклад: переклади на англійську...",
            qbtn_translate: "Переклади",
            qbtn_explain: "Поясни",
            correction_mode: "Режим виправлення",
            qbtn_shorten: "Скороти",
            ai_model: "Модель AI",
            gemini_key: "Ключ Gemini API",
            groq_key: "Ключ Groq API",
            name_label: "Назва",
            prompt_label: "Промпт"
        }
    }
}

SetAutostart(neutron, enable) {
    regPath := "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run"
    if (enable) {
        cmd := A_IsCompiled ? '"' A_ScriptFullPath '"' : '"' A_AhkPath '" "' A_ScriptFullPath '"'
        RegWrite(cmd, "REG_SZ", regPath, "FixerAI")
    } else {
        try RegDelete(regPath, "FixerAI")
    }
}

Init() {
    global L, CurrentLanguage, CurrentMode, CurrentPromptMode, CurrentModelName, QuickButtons, MainHotkey, SettingsHotkey, PromptHotkey
    
    configPath := A_ScriptDir "\config.ini"
    settingsPath := A_ScriptDir "\settings.ini"
    
    ; Створюємо config.ini, якщо він відсутній
    if (!FileExist(configPath)) {
        FileAppend("[Groq]`nApiKey=`n[Gemini]`nApiKey=`n", configPath, "UTF-16")
    }
    
    ; Створюємо settings.ini з налаштуваннями за замовчуванням, якщо він відсутній
    if (!FileExist(settingsPath)) {
        defaultSettings := "[Settings]`nLanguage=uk`nMode=confirm`nPromptMode=confirm`nModel=llama-3.3-70b-versatile`n`n[Hotkeys]`nMain=#q`nSettings=#s`nPrompt=#a`n`n[QuickButtons]`nПереклади на англійську=Переклади на англійську`nПоясни що це означає=Поясни що це означає`nЗроби цей текст коротшим=Зроби цей текст коротшим`n"
        FileAppend(defaultSettings, settingsPath, "UTF-16")
    }
    
    CurrentLanguage := ReadLanguage()
    L := GetLoc(CurrentLanguage)
    CurrentMode := ReadMode()
    CurrentPromptMode := ReadMode("Settings", "PromptMode")
    CurrentModelName := IniRead(A_ScriptDir "\settings.ini", "Settings", "Model", "llama-3.3-70b-versatile")
    QuickButtons := ReadQuickButtons(CurrentLanguage)
    MainHotkey := ReadHotkey("Main", "#q")
    SettingsHotkey := ReadHotkey("Settings", "#s")
    PromptHotkey := ReadHotkey("Prompt", "#a")
}

Main() {
    global L, CurrentMode, CurrentModelName
    
    if (InStr(CurrentModelName, "gemini-")) {
        configPath := A_ScriptDir "\config.ini"
        apiKey := IniRead(configPath, "Gemini", "ApiKey", "")
        apiFunc := CallGeminiAPI
    } else {
        configPath := A_ScriptDir "\config.ini"
        apiKey := IniRead(configPath, "Groq", "ApiKey", "")
        apiFunc := CallGroqAPI
    }
    
    if (apiKey = "" || apiKey = "ERROR" || apiKey = -1) {
        ShowMissingKeyWarning()
        return
    }
    
    originalText := GetSelectedText()
    if (!originalText) {
        MsgBox L.no_selection
        return
    }

    lang := DetectLanguage(originalText)
    
    if (lang = "en") {
        systemPrompt := "You are a professional text corrector. Fix grammar, spelling, and punctuation. Return ONLY the corrected text without any comments, explanations, or repetitions."
        userPrompt := "Correct this text: " originalText
    } else {
        systemPrompt := "Ти — професійний коректор. Виправ граматичні, пунктуаційні та стилістичні помилки. Поверни ТІЛЬКИ виправлений текст без коментарів, пояснень та повторів."
        userPrompt := "Виправ цей текст: " originalText
    }

    ; Показуємо невелике вікно завантаження або просто курсор
    ToolTip L.processing
    correctedText := apiFunc(systemPrompt, userPrompt, apiKey)
    ToolTip

    if (correctedText = "ERROR" || correctedText = "EMPTY") {
        return
    }
    
    if (correctedText = originalText) {
        MsgBox L.no_fix_needed
        return
    }
    
    global CurrentMode
    if (CurrentMode = "auto") {
        AutoReplace(originalText, correctedText)
    } else if (CurrentMode = "clipboard") {
        A_Clipboard := correctedText
        ToolTip L.copied
        SetTimer () => ToolTip(), -2000
    } else {
        ShowPopup(originalText, correctedText)
    }
}

PromptWindow() {
    global L, QuickButtons, PromptNeutron, CurrentSelectedText
    
    configPath := A_ScriptDir "\config.ini"
    apiKey := IniRead(configPath, "Groq", "ApiKey", "")
    
    if (apiKey = "" || apiKey = "ERROR" || apiKey = -1) {
        ShowMissingKeyWarning()
        return
    }
    
    CurrentSelectedText := GetSelectedText()
    if (!CurrentSelectedText) {
        MsgBox L.no_selection
        return
    }

    css := "
    (
        * { outline: none !important; box-sizing: border-box; }
        header { display: none; }
        html, body { 
            margin: 0; padding: 0; background-color: #1e2227; color: #abb2bf; font-family: 'Segoe UI', system-ui, sans-serif; height: 100%; 
            overflow: hidden;
        }
        .container { 
            display: flex; 
            flex-direction: column; 
            padding: 12px; 
            border: 1px solid #3e4451;
            border-radius: 8px;
            background-color: #1e2227;
        }
        .header { 
            font-size: 13px; 
            font-weight: 600; 
            color: #5c6370; 
            margin-bottom: 10px; 
            user-select: none;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .header b { color: #3b82f6; }
        .input-area {
            background: #21252b;
            border: 1px solid #3e4451;
            border-radius: 6px;
            padding: 8px;
            margin-bottom: 10px;
            flex-grow: 1;
            display: flex;
            flex-direction: column;
        }
        textarea { 
            background: transparent; 
            border: none; 
            color: #dcdfe4; 
            width: 100%; 
            height: 100%;
            resize: none; 
            font-size: 13px; 
            line-height: 1.6;
            font-family: inherit;
        }
        .quick-actions { 
            display: flex; 
            flex-wrap: wrap;
            gap: 8px; 
            margin-bottom: 12px;
            max-height: 120px;
            overflow-y: auto;
            padding-right: 4px;
        }
        .quick-actions::-webkit-scrollbar { width: 4px; }
        .quick-actions::-webkit-scrollbar-thumb { background: #3e4451; border-radius: 2px; }
        
        .btn-quick {
            background: #2c313a; 
            color: #abb2bf; 
            border: 1px solid #3e4451;
            padding: 6px 12px;
            font-size: 12px;
            border-radius: 6px;
            cursor: pointer;
            transition: all 0.2s;
        }
        .btn-quick:hover { 
            background: #3b82f6; 
            color: white; 
            border-color: #3b82f6;
        }
        
        .footer { display: flex; justify-content: flex-end; gap: 8px; align-items: center; }
        button { 
            padding: 6px 12px; 
            border-radius: 4px; 
            border: 1px solid transparent; 
            cursor: pointer; 
            font-size: 12px; 
            transition: 0.2s; 
        }
        .btn-send { background: #10b981; color: #fff; font-weight: 600; }
        .btn-send:hover { background: #059669; }
        .btn-cancel { background: #2c313a; color: #abb2bf; border-color: #3e4451; }
        .btn-cancel:hover { background: #3e4451; color: #fff; }
    )"
    
    buttonsHtml := ""
    for btn in QuickButtons {
        btnLabel := HtmlEscape(btn.label, true)
        btnPrompt := HtmlEscape(btn.prompt, true)
        ; Використовуємо одинарні лапки для HTML атрибутів, щоб уникнути конфліктів з AHK рядками
        buttonsHtml .= "<button class='btn-quick' onclick='ahk.OnQuickPrompt(this, `"" btnPrompt "`")'>" btnLabel "</button> "
    }
    
    html := "
    (
        <div class='container' onmousedown='if (event.target == this) neutron.DragTitleBar()'>
            <div class='header' onmousedown='neutron.DragTitleBar()'>{{L_WHAT_TO_DO}}</div>
            
            <div class='input-area'>
                <textarea id='promptInput' placeholder='{{L_PLACEHOLDER}}' autofocus></textarea>
            </div>
            
            <div class='quick-actions'>
                {{BUTTONS}}
            </div>
            
            <div class='footer'>
                <button class='btn-send' onclick='ahk.OnSendPrompt()'>🚀 {{L_SEND}}</button>
                <button class='btn-cancel' onclick='ahk.OnCancelPrompt()'>❌ {{L_CANCEL}}</button>
            </div>
        </div>
    )"
    html := StrReplace(html, "{{BUTTONS}}", buttonsHtml)
    html := StrReplace(html, "{{L_WHAT_TO_DO}}", L.what_to_do)
    html := StrReplace(html, "{{L_PLACEHOLDER}}", L.prompt_placeholder)
    html := StrReplace(html, "{{L_SEND}}", L.send)
    html := StrReplace(html, "{{L_CANCEL}}", L.cancel)
    
    PromptNeutron := NeutronWindow(html, css, "", L.win_a_title)
    PromptNeutron.gui.Opt("-Caption +ToolWindow +AlwaysOnTop")
    PromptNeutron.gui.BackColor := "1a1b1e"
    
    ; Отримуємо ID активного вікна перед показом для "прив'язки"
    activeHwnd := WinActive("A")
    if (activeHwnd)
        PromptNeutron.gui.Opt("+Owner" activeHwnd)
        
    PromptNeutron.Show("w500 h280 Center")
    
    ; Фокус на поле вводу та обробка Enter
    PromptNeutron.doc.getElementById("promptInput").focus()
    
    ; Додаємо обробку натискання клавіш
    PromptNeutron.doc.getElementById("promptInput").onkeydown := OnPromptKeyDown
}

OnPromptKeyDown(neutron, e) {
    if (e.keyCode == 13 && !e.shiftKey) {
        e.preventDefault()
        OnSendPrompt(neutron)
    }
    if (e.keyCode == 27) {
        OnCancelPrompt(neutron)
    }
}

OnQuickPrompt(neutron, event, promptText) {
    neutron.doc.getElementById("promptInput").value := promptText
    OnSendPrompt(neutron)
}

OnCancelPrompt(neutron) {
    neutron.Close()
}

OnSendPrompt(neutron) {
    global L, CurrentSelectedText, CurrentPromptMode, CurrentModelName
    
    promptText := Trim(neutron.doc.getElementById("promptInput").value)
    neutron.Close()
    
    if (InStr(CurrentModelName, "gemini-")) {
        configPath := A_ScriptDir "\config.ini"
        apiKey := IniRead(configPath, "Gemini", "ApiKey", "")
        apiFunc := CallGeminiAPI
    } else {
        configPath := A_ScriptDir "\config.ini"
        apiKey := IniRead(configPath, "Groq", "ApiKey", "")
        apiFunc := CallGroqAPI
    }
    
    lang := DetectLanguage(CurrentSelectedText)
    
    if (lang = "uk") {
        langName := "Ukrainian"
        instrLabel := "Інструкція: "
        textLabel := "Текст: "
        noTrans := "НЕ ПЕРЕКЛАДАЙ. Зберігай мову оригіналу."
    } else {
        langName := "English"
        instrLabel := "Instruction: "
        textLabel := "Text: "
        noTrans := "DO NOT TRANSLATE. Keep the original language."
    }
    
    systemPrompt := "You are a helpful AI assistant. "
        . "Return ONLY the resulting text without any comments, explanations, or repetitions. "
        . "CRITICAL: You MUST respond in " langName ". " noTrans
    
    if (promptText != "")
        userPrompt := instrLabel promptText "`n`n" textLabel CurrentSelectedText
    else
        userPrompt := CurrentSelectedText
    
    ; Показуємо невелике вікно завантаження або просто курсор
    ToolTip L.processing
    result := apiFunc(systemPrompt, userPrompt, apiKey)
    ToolTip
    
    if (result = "ERROR" || result = "EMPTY")
        return
        
    if (CurrentPromptMode = "auto") {
        AutoReplace(CurrentSelectedText, result)
    } else if (CurrentPromptMode = "clipboard") {
        A_Clipboard := result
        ToolTip L.copied
        SetTimer () => ToolTip(), -2000
    } else {
        ShowPopup(CurrentSelectedText, result, "prompt")
    }
}

OpenSettings(*) {
    global L, CurrentLanguage, CurrentMode, CurrentPromptMode, CurrentModelName, SettingsNeutron, MainHotkey, SettingsHotkey, PromptHotkey, QuickButtons
    
    configPath := A_ScriptDir "\config.ini"
    currentApiKey := IniRead(configPath, "Groq", "ApiKey", "")
    
    ; Підготовка тексту для швидких кнопок
    buttonsText := ""
    for btn in QuickButtons {
        buttonsText .= btn.label "=" btn.prompt (A_Index < QuickButtons.Length ? "`n" : "")
    }

    css := "
    (
        * { outline: none !important; box-sizing: border-box; }
        header { display: none; }
        html, body { 
            margin: 0; padding: 0; background-color: #1e2227; color: #abb2bf; font-family: 'Segoe UI', system-ui, sans-serif; height: 100%; 
            overflow: hidden;
        }
        .container { 
            display: flex; 
            flex-direction: column; 
            height: 100%; 
            padding: 16px; 
            border: 1px solid #3e4451;
            border-radius: 8px;
        }
        .header { 
            font-size: 14px; 
            font-weight: 600; 
            color: #dcdfe4; 
            margin-bottom: 20px; 
            user-select: none;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .scroll-area { 
            flex-grow: 1; 
            overflow-y: auto; 
            padding-right: 8px; 
            margin-bottom: 16px;
        }
        .scroll-area::-webkit-scrollbar { width: 6px; }
        .scroll-area::-webkit-scrollbar-track { background: transparent; }
        .scroll-area::-webkit-scrollbar-thumb { background: #3e4451; border-radius: 3px; }

        .section { 
            background: #21252b; 
            border: 1px solid #3e4451; 
            border-radius: 6px; 
            padding: 14px; 
            margin-bottom: 16px; 
        }
        .section-title { 
            font-size: 11px; 
            text-transform: uppercase; 
            color: #3b82f6; 
            letter-spacing: 1px; 
            margin-bottom: 15px; 
            font-weight: 700;
        }
        
        .form-group { margin-bottom: 12px; }
        label { display: block; font-size: 12px; color: #abb2bf; margin-bottom: 6px; }
        
        input[type='text'], input[type='password'], select {
            width: 100%;
            background: #21252b;
            border: 1px solid #3e4451;
            border-radius: 4px;
            padding: 8px 12px;
            color: #dcdfe4;
            font-size: 13px;
            outline: none;
        }
        input[type='text']:focus, input[type='password']:focus, select:focus { border-color: #3b82f6; }

        .hotkey-row {
            display: flex;
            gap: 8px;
        }
        .hotkey-row select {
            background: #21252b;
            border: 1px solid #3e4451;
            color: #dcdfe4;
            padding: 6px;
            border-radius: 4px;
            font-size: 13px;
            width: 80px;
        }
        .hotkey-row input {
            flex-grow: 1;
            text-align: center;
            text-transform: uppercase;
        }

        .checkbox-item { 
            display: flex; 
            align-items: center; 
            gap: 8px; 
            cursor: pointer; 
            font-size: 13px;
            color: #abb2bf;
        }
        .checkbox-item input { margin: 0; }

        .quick-buttons-list { display: flex; flex-direction: column; gap: 8px; }
        .quick-btn-row { display: flex; gap: 4px; align-items: stretch; }
        .quick-btn-row .btn-label { width: 35%; flex-shrink: 0; }
        .quick-btn-row .btn-prompt { flex-grow: 1; min-width: 0; }
        .btn-remove { 
            background: #2c313a; 
            color: #ef4444; 
            border: 1px solid #3e4451; 
            padding: 0 8px; 
            border-radius: 4px; 
            cursor: pointer;
            flex-shrink: 0;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 14px;
        }

        .footer { display: flex; justify-content: flex-end; gap: 8px; padding-top: 12px; border-top: 1px solid #3e4451; }
        button { 
            padding: 6px 14px; 
            border-radius: 4px; 
            border: 1px solid transparent; 
            cursor: pointer; 
            font-size: 12px; 
            font-weight: 500;
            transition: 0.2s; 
        }
        .btn-save { background: #3b82f6; color: #fff; }
        .btn-save:hover { background: #2563eb; }
        .btn-cancel { background: #2c313a; color: #abb2bf; border-color: #3e4451; }
        .btn-cancel:hover { background: #3e4451; color: #fff; }
        .btn-add { background: #2c313a; color: #abb2bf; border: 1px dashed #3e4451; width: 100%; margin-top: 8px; }
        .btn-add:hover { border-color: #abb2bf; color: #fff; }
    )"
    
    html := "
    (
        <div class='container'>
            <div class='header' onmousedown='neutron.DragTitleBar()'>{{L_SETTINGS}}</div>
            
            <div class='scroll-area'>
                <div class='section'>
                    <div class='section-title'>{{L_API_CONFIG}}</div>
                    <div class='form-group'>
                        <label>{{L_GROQ_KEY}}</label>
                        <input type='password' id='apiKey' placeholder='gsk_...' oninput='ahk.UpdateModelVisibility(this.value, document.getElementById("geminiApiKey").value)'>
                        <div style='margin-top: 4px;'>
                            <a href='#' onclick='ahk.OpenGuide()' style='color:#3b82f6; font-size:11px; text-decoration:none;'>{{L_HOW_TO_GET}}</a>
                        </div>
                    </div>
                    <div class='form-group' style='margin-top: 10px;'>
                        <label>{{L_GEMINI_KEY}}</label>
                        <input type='password' id='geminiApiKey' placeholder='AIza...' oninput='ahk.UpdateModelVisibility(document.getElementById("apiKey").value, this.value)'>
                        <div style='margin-top: 4px;'>
                            <a href='#' onclick='ahk.OpenGeminiGuide()' style='color:#3b82f6; font-size:11px; text-decoration:none;'>{{L_HOW_TO_GET_GEMINI}}</a>
                        </div>
                    </div>
                    <div style='margin-top: 6px;'>
                        <label class='checkbox-item' style='margin-bottom: 0;'>
                            <input type='checkbox' onchange='ahk.TogglePassword(this.checked)'>
                            <span style='font-size: 11px;' id='showKeyLabel'>{{L_SHOW_KEY}}</span>
                        </label>
                    </div>
                </div>

                <div class='section'>
                    <div class='section-title'>{{L_LANGUAGE}}</div>
                    <div class='form-group'>
                        <select id='uiLang'>
                            <option value='uk'>Українська</option>
                            <option value='en'>English</option>
                        </select>
                    </div>
                </div>

                <div class='section'>
                    <div class='section-title'>{{L_HOTKEYS}}</div>
                    <div class='form-group'>
                        <label>{{L_MAIN}} (Win+Q)</label>
                        <div class='hotkey-row'>
                            <select id='modMain'>
                                <option value='#'>Win</option>
                                <option value='^'>Ctrl</option>
                                <option value='!'>Alt</option>
                                <option value='+'>Shift</option>
                            </select>
                            <input type='text' id='keyMain' maxlength='1' placeholder='Q'>
                        </div>
                    </div>
                    <div class='form-group'>
                        <label>{{L_PROMPT}} (Win+A)</label>
                        <div class='hotkey-row'>
                            <select id='modPrompt'>
                                <option value='#'>Win</option>
                                <option value='^'>Ctrl</option>
                                <option value='!'>Alt</option>
                                <option value='+'>Shift</option>
                            </select>
                            <input type='text' id='keyPrompt' maxlength='1' placeholder='A'>
                        </div>
                    </div>
                    <div class='form-group'>
                        <label>{{L_SETTINGS}} (Win+S)</label>
                        <div class='hotkey-row'>
                            <select id='modSettings'>
                                <option value='#'>Win</option>
                                <option value='^'>Ctrl</option>
                                <option value='!'>Alt</option>
                                <option value='+'>Shift</option>
                            </select>
                            <input type='text' id='keySettings' maxlength='1' placeholder='S'>
                        </div>
                    </div>
                </div>

                <div class='section'>
                    <div class='section-title'>{{L_AI_MODEL}}</div>
                    <div class='form-group'>
                        <select id='modelName'>
                            <optgroup id='groupGroq' label='Groq Cloud (Developer Plan 2026)'>
                                <option value='meta-llama/llama-4-scout-17b-16e-instruct'>Llama 4 Scout 17B (30 RPM, 1K RPD, 30K TPM)</option>
                                <option value='llama-3.3-70b-versatile'>Llama 3.3 70B (30 RPM, 1K RPD, 12K TPM)</option>
                                <option value='llama-3.1-8b-instant'>Llama 3.1 8B (30 RPM, 14.4K RPD, 6K TPM)</option>
                                <option value='openai/gpt-oss-120b'>GPT-OSS 120B (30 RPM, 1K RPD, 8K TPM)</option>
                                <option value='openai/gpt-oss-20b'>GPT-OSS 20B (30 RPM, 1K RPD, 8K TPM)</option>
                                <option value='qwen/qwen3-32b'>Qwen 3 32B (60 RPM, 1K RPD, 6K TPM)</option>
                                <option value='groq/compound'>Groq Compound (30 RPM, 250 RPD, 70K TPM)</option>
                                <option value='groq/compound-mini'>Groq Compound Mini (30 RPM, 250 RPD, 70K TPM)</option>
                            </optgroup>
                            <optgroup id='groupGemini' label='Google Gemini (Free Tier)'>
                                <option value='gemini-2.5-flash'>Gemini 2.5 Flash (5 RPM, 20 RPD)</option>
                                <option value='gemini-2.5-flash-lite'>Gemini 2.5 Flash Lite (10 RPM, 20 RPD)</option>
                            </optgroup>
                        </select>
                    </div>
                </div>

                <div class='section'>
                    <div class='section-title'>{{L_CORRECTION_MODE}} (Win+Q)</div>
                    <div class='form-group'>
                        <select id='mode'>
                            <option value='confirm'>{{L_SHOW_RESULT}}</option>
                            <option value='auto'>{{L_AUTO_REPLACE}}</option>
                            <option value='clipboard'>{{L_COPY_TO_CLIPBOARD}}</option>
                        </select>
                    </div>
                </div>

                <div class='section'>
                    <div class='section-title'>{{L_AI_PROMPT_MODE}}</div>
                    <div class='form-group'>
                        <select id='promptMode'>
                            <option value='confirm'>{{L_SHOW_RESULT}}</option>
                            <option value='auto'>{{L_AUTO_REPLACE}}</option>
                            <option value='clipboard'>{{L_COPY_TO_CLIPBOARD}}</option>
                        </select>
                    </div>
                </div>

                <div class='section'>
                    <div class='section-title'>{{L_QUICK_BUTTONS}}</div>
                    <div id='quickButtonsContainer' class='quick-buttons-list'>
                        <!-- Кнопки додаються через JS -->
                    </div>
                    <button class='btn-add' onclick='ahk.AddQuickButton()'>{{L_ADD_BUTTON}}</button>
                </div>

                <div class='section'>
                    <div class='section-title'>{{L_SYSTEM}}</div>
                    <label class='checkbox-item'>
                        <input type='checkbox' id='autostart' onchange='ahk.SetAutostart(this.checked)'>
                        <span>{{L_RUN_STARTUP}}</span>
                    </label>
                </div>
            </div>

            <div class='footer'>
                <button class='btn-save' onclick='ahk.SaveSettings()'>{{L_SAVE}}</button>
                <button class='btn-cancel' onclick='neutron.Close()'>{{L_CANCEL}}</button>
            </div>
        </div>
    )"
    
    html := StrReplace(html, "{{L_SETTINGS}}", L.settings)
    html := StrReplace(html, "{{L_API_CONFIG}}", L.api_config)
    html := StrReplace(html, "{{L_GROQ_KEY}}", L.groq_key)
    html := StrReplace(html, "{{L_GEMINI_KEY}}", L.gemini_key)
    html := StrReplace(html, "{{L_SHOW_KEY}}", L.show_key)
    html := StrReplace(html, "{{L_HOW_TO_GET}}", L.how_to_get)
    html := StrReplace(html, "{{L_HOW_TO_GET_GEMINI}}", L.how_to_get_gemini)
    html := StrReplace(html, "{{L_LANGUAGE}}", L.language)
    html := StrReplace(html, "{{L_HOTKEYS}}", L.hotkeys)
    html := StrReplace(html, "{{L_MAIN}}", L.main_hk)
    html := StrReplace(html, "{{L_PROMPT}}", L.prompt_hk)
    html := StrReplace(html, "{{L_CORRECTION_MODE}}", L.correction_mode)
    html := StrReplace(html, "{{L_AI_MODEL}}", L.ai_model)
    html := StrReplace(html, "{{L_AI_PROMPT_MODE}}", L.ai_prompt_mode)
    html := StrReplace(html, "{{L_QUICK_BUTTONS}}", L.quick_buttons)
    html := StrReplace(html, "{{L_ADD_BUTTON}}", L.add_button)
    html := StrReplace(html, "{{L_SYSTEM}}", L.system)
    html := StrReplace(html, "{{L_RUN_STARTUP}}", L.run_startup)
    html := StrReplace(html, "{{L_SAVE}}", L.save)
    html := StrReplace(html, "{{L_CANCEL}}", L.cancel)
    html := StrReplace(html, "{{L_SHOW_RESULT}}", L.show_result)
    html := StrReplace(html, "{{L_AUTO_REPLACE}}", L.auto_replace)
    html := StrReplace(html, "{{L_COPY_TO_CLIPBOARD}}", L.copy_to_clipboard)

    SettingsNeutron := NeutronWindow(html, css, "", L.settings)
    SettingsNeutron.gui.Opt("-Caption +ToolWindow")
    SettingsNeutron.gui.BackColor := "1a1b1e"
    
    activeHwnd := WinActive("A")
    if (activeHwnd)
        SettingsNeutron.gui.Opt("+Owner" activeHwnd)
    
    ; Розбиваємо хоткеї на мод та клавішу
    modM := SubStr(MainHotkey, 1, 1), keyM := SubStr(MainHotkey, 2)
    modP := SubStr(PromptHotkey, 1, 1), keyP := SubStr(PromptHotkey, 2)
    modS := SubStr(SettingsHotkey, 1, 1), keyS := SubStr(SettingsHotkey, 2)

    ; Встановлюємо стани
    geminiApiKey := IniRead(A_ScriptDir "\config.ini", "Gemini", "ApiKey", "")
    SettingsNeutron.doc.getElementById("apiKey").value := currentApiKey
    SettingsNeutron.doc.getElementById("geminiApiKey").value := geminiApiKey
    
    ; Викликаємо початкове оновлення видимості моделей
    UpdateModelVisibility(SettingsNeutron, currentApiKey, geminiApiKey)
    
    SettingsNeutron.doc.getElementById("modMain").value := modM
    SettingsNeutron.doc.getElementById("keyMain").value := keyM
    SettingsNeutron.doc.getElementById("modPrompt").value := modP
    SettingsNeutron.doc.getElementById("keyPrompt").value := keyP
    SettingsNeutron.doc.getElementById("modSettings").value := modS
    SettingsNeutron.doc.getElementById("keySettings").value := keyS
    SettingsNeutron.doc.getElementById("mode").value := CurrentMode
    SettingsNeutron.doc.getElementById("modelName").value := CurrentModelName
    SettingsNeutron.doc.getElementById("promptMode").value := CurrentPromptMode
    SettingsNeutron.doc.getElementById("uiLang").value := CurrentLanguage
    SettingsNeutron.doc.getElementById("autostart").checked := ReadAutostart()
    
    ; Завантаження швидких кнопок
    for btn in QuickButtons {
        AddQuickButton(SettingsNeutron, btn.label, btn.prompt)
    }
    
    SettingsNeutron.Show("w500 h680 Center")
}

TogglePassword(neutronObj, checked) {
    input1 := neutronObj.doc.getElementById("apiKey")
    input2 := neutronObj.doc.getElementById("geminiApiKey")
    input1.type := checked ? "text" : "password"
    input2.type := checked ? "text" : "password"
}

UpdateModelVisibility(neutronObj, groqKey, geminiKey) {
    groqGroup := neutronObj.doc.getElementById("groupGroq")
    geminiGroup := neutronObj.doc.getElementById("groupGemini")
    
    ; Перевіряємо чи ключі не порожні
    hasGroq := (Trim(groqKey) != "")
    hasGemini := (Trim(geminiKey) != "")
    
    ; Ховаємо/показуємо групи
    groqGroup.style.display := hasGroq ? "" : "none"
    geminiGroup.style.display := hasGemini ? "" : "none"
    
    ; Якщо поточна обрана модель належить до прихованої групи, перемикаємо на першу доступну
    select := neutronObj.doc.getElementById("modelName")
    currentVal := select.value
    
    isGroqModel := false
    options := groqGroup.getElementsByTagName("option")
    Loop options.length {
        opt := options.item(A_Index - 1)
        if (opt.value == currentVal) {
            isGroqModel := true
            break
        }
    }
    
    isGeminiModel := false
    options := geminiGroup.getElementsByTagName("option")
    Loop options.length {
        opt := options.item(A_Index - 1)
        if (opt.value == currentVal) {
            isGeminiModel := true
            break
        }
    }
    
    if ((isGroqModel && !hasGroq) || (isGeminiModel && !hasGemini)) {
        if (hasGroq)
            select.value := groqGroup.getElementsByTagName("option").item(0).value
        else if (hasGemini)
            select.value := geminiGroup.getElementsByTagName("option").item(0).value
    }
}

OpenGroqURL(*) {
    Run("https://console.groq.com/keys")
}

OpenGuide(*) {
    Run(A_ScriptDir "\groq-api-key-guide.html")
}

OpenGeminiGuide(*) {
    Run(A_ScriptDir "\gemini-api-key-guide.html")
}

OnCancelSettings(neutron) {
    neutron.Close()
}

ShowMissingKeyWarning() {
    global L, WarningNeutron
    
    css := "
    (
        * { outline: none !important; }
        header { display: none; }
        html, body { 
            margin: 0; padding: 0; background-color: #1a1b1e; color: #e1e1e6; font-family: 'Segoe UI', sans-serif; height: 100%; overflow: hidden;
            -ms-overflow-style: none;
        }
        .container { 
            display: flex; 
            flex-direction: column; 
            height: 100%; 
            padding: 25px; 
            box-sizing: border-box; 
            align-items: center;
            text-align: center;
        }
        .icon { 
            font-size: 48px; 
            margin-bottom: 15px; 
            color: #ff9a00;
        }
        .title { 
            font-size: 18px; 
            font-weight: bold; 
            color: #ff9a00; 
            margin-bottom: 15px; 
        }
        .message { 
             font-size: 14px; 
             color: #e1e1e6; 
             line-height: 1.5;
             margin-bottom: 20px;
             display: block;
             width: 100%;
             max-width: 450px;
             word-wrap: break-word;
             overflow-wrap: break-word;
             white-space: normal;
         }
        .footer { 
             display: flex; 
             gap: 12px; 
             margin-top: 25px; 
             width: 100%;
             justify-content: center;
         }
        button { 
            padding: 10px 20px; 
            border-radius: 8px; 
            border: 1px solid transparent; 
            cursor: pointer; 
            font-weight: bold; 
            font-size: 13px; 
            transition: 0.2s; 
        }
        .btn-settings { background: #ff9a00; color: #121214; }
        .btn-settings:hover { background: #ffb74d; transform: translateY(-1px); }
        .btn-close { background: #29292e; color: #e1e1e6; border-color: #3a3a42; }
        .btn-close:hover { background: #3a3a42; border-color: #4a4a52; }
        
        .link { color: #ff9a00; text-decoration: none; font-size: 13px; margin-top: 15px; }
        .link:hover { text-decoration: underline; }
    )"
    
    html := "
    (
        <div class='container' onmousedown='if (event.target == this) neutron.DragTitleBar()'>
            <div class='icon'>⚠️</div>
            <div class='title'>{{L_TITLE}}</div>
            <div class='message'>{{L_MESSAGE}}</div>
            <a href='#' onclick='ahk.OpenGuide()' class='link'>{{L_HOW_TO}}</a>
            <div class='footer'>
                <button class='btn-settings' onclick='ahk.OnWarningSettings()'>⚙️ {{L_SETTINGS}}</button>
                <button class='btn-close' onclick='ahk.OnWarningClose()'>{{L_CLOSE}}</button>
            </div>
        </div>
    )"
    
    html := StrReplace(html, "{{L_TITLE}}", L.api_missing_title)
    html := StrReplace(html, "{{L_MESSAGE}}", L.api_missing_msg)
    html := StrReplace(html, "{{L_HOW_TO}}", L.how_to_get)
    html := StrReplace(html, "{{L_SETTINGS}}", L.settings)
    html := StrReplace(html, "{{L_CLOSE}}", L.close)
    title := "PeroAI - " L.error
    
    WarningNeutron := NeutronWindow(html, css, "", title)
    WarningNeutron.gui.Opt("-Caption +ToolWindow +AlwaysOnTop")
    WarningNeutron.gui.BackColor := "1a1b1e"
    
    ; Отримуємо ID активного вікна перед показом для "прив'язки"
    activeHwnd := WinActive("A")
    if (activeHwnd)
        WarningNeutron.gui.Opt("+Owner" activeHwnd)
    
    WarningNeutron.Show("w500 h350 Center")
}

OnWarningSettings(neutron) {
    neutron.Close()
    OpenSettings()
}

OnWarningClose(neutron) {
    neutron.Close()
}

SaveSettings(neutron) {
    global CurrentMode, CurrentPromptMode, CurrentLanguage, CurrentModelName, L, QuickButtons, MainHotkey, SettingsHotkey, PromptHotkey
    
    apiKey := Trim(neutron.doc.getElementById("apiKey").value)
    geminiApiKey := Trim(neutron.doc.getElementById("geminiApiKey").value)
    mode := neutron.doc.getElementById("mode").value
    modelName := neutron.doc.getElementById("modelName").value
    promptMode := neutron.doc.getElementById("promptMode").value
    lang := neutron.doc.getElementById("uiLang").value
    
    ; Формуємо хоткеї з вибраних модифікаторів та клавіш
    hkMain := neutron.doc.getElementById("modMain").value . neutron.doc.getElementById("keyMain").value
    hkPrompt := neutron.doc.getElementById("modPrompt").value . neutron.doc.getElementById("keyPrompt").value
    hkSettings := neutron.doc.getElementById("modSettings").value . neutron.doc.getElementById("keySettings").value

    configPath := A_ScriptDir "\config.ini"
    settingsPath := A_ScriptDir "\settings.ini"
    
    IniWrite(apiKey, configPath, "Groq", "ApiKey")
    IniWrite(geminiApiKey, configPath, "Gemini", "ApiKey")
    IniWrite(mode, settingsPath, "Settings", "Mode")
    IniWrite(modelName, settingsPath, "Settings", "Model")
    IniWrite(promptMode, settingsPath, "Settings", "PromptMode")
    IniWrite(lang, settingsPath, "Settings", "Language")
    
    CurrentMode := mode
    CurrentModelName := modelName
    CurrentPromptMode := promptMode
    CurrentLanguage := lang
    L := GetLoc(lang)
    
    ; Оновлюємо хоткеї
    if (StrLen(hkMain) > 1)
        IniWrite(hkMain, A_ScriptDir "\settings.ini", "Hotkeys", "Main")
    if (StrLen(hkPrompt) > 1)
        IniWrite(hkPrompt, A_ScriptDir "\settings.ini", "Hotkeys", "Prompt")
    if (StrLen(hkSettings) > 1)
        IniWrite(hkSettings, A_ScriptDir "\settings.ini", "Hotkeys", "Settings")
    
    ; Збереження швидких кнопок
    IniDelete(A_ScriptDir "\settings.ini", "QuickButtons")
    rows := neutron.doc.getElementById("quickButtonsContainer").querySelectorAll(".quick-btn-row")
    loop rows.length {
        row := rows.item(A_Index-1)
        elLabel := row.querySelector(".btn-label")
        elPrompt := row.querySelector(".btn-prompt")
        
        if (elLabel && elPrompt) {
            label := Trim(elLabel.value)
            prompt := Trim(elPrompt.value)
            if (label != "" && prompt != "") {
                IniWrite(prompt, A_ScriptDir "\settings.ini", "QuickButtons", label)
            }
        }
    }
    
    neutron.Close()
    Reload()
}

AddQuickButton(neutron, label := "", prompt := "") {
    global L
    container := neutron.doc.getElementById("quickButtonsContainer")
    div := neutron.doc.createElement("div")
    div.className := "quick-btn-row"
    
    ; Екрануємо для безпечного вставлення в HTML attributes
    escLabel := HtmlEscape(label, true)
    escPrompt := HtmlEscape(prompt, true)
    
    div.innerHTML := '<input type="text" class="btn-label" placeholder="' L.name_label '" value="' escLabel '"> '
                  . '<input type="text" class="btn-prompt" placeholder="' L.prompt_label '" value="' escPrompt '"> '
                  . '<button class="btn-remove" onclick="this.parentElement.parentNode.removeChild(this.parentElement)">&times;</button>'
    container.appendChild(div)
}

GetSelectedText() {
    saved := ClipboardAll()
    A_Clipboard := ""
    Sleep 50
    SendInput "^c"
    Sleep 200
    text := A_Clipboard
    A_Clipboard := saved
    return text
}

DetectLanguage(text) {
    hasLatin := RegExMatch(text, "[A-Za-z]")
    hasCyrillic := RegExMatch(text, "[А-Яа-яЁёЫыЭэЇїЄєҐґ]")
    
    if (hasCyrillic && !hasLatin)
        return "uk"
    return "en"
}

AutoReplace(original, corrected) {
    PerformPaste(corrected)
}

PerformPaste(text) {
    saved := ClipboardAll()
    A_Clipboard := text
    Sleep 100
    SendInput "^v"
    Sleep 150
    A_Clipboard := saved
}

EscapeJson(str) {
    str := StrReplace(str, "\", "\\")
    str := StrReplace(str, "`n", "\n")
    str := StrReplace(str, "`r", "\r")
    str := StrReplace(str, "`t", "\t")
    str := StrReplace(str, '"', '\"')
    return str
}

CallGeminiAPI(systemPrompt, userPrompt, apiKey) {
    global L, CurrentModelName
    try {
        http := ComObject("MSXML2.ServerXMLHTTP.6.0")
        
        ; В 2026 році сучасні моделі (Gemini 3, 2.5) використовують v1
        apiVersion := "v1"
        
        url := "https://generativelanguage.googleapis.com/" apiVersion "/models/" CurrentModelName ":generateContent?key=" apiKey
        http.Open("POST", url, false)
        http.setRequestHeader("Content-Type", "application/json")

        ; Gemini JSON structure with system_instruction for better quality in newer models
        json := '{"system_instruction": {"parts": [{"text": "' EscapeJson(systemPrompt) '"}]}, "contents": [{"parts": [{"text": "' EscapeJson(userPrompt) '"}]}], "generationConfig": {"temperature": 0.3, "maxOutputTokens": 4096}}'

        http.send(json)

        ; Якщо v1 видає 404 або 400, спробуємо v1beta (для деяких експериментальних або специфічних моделей)
        if (http.status == 404 || http.status == 400) {
            apiVersion := "v1beta"
            url := "https://generativelanguage.googleapis.com/" apiVersion "/models/" CurrentModelName ":generateContent?key=" apiKey
            http.Open("POST", url, false)
            http.setRequestHeader("Content-Type", "application/json")
            http.send(json)
        }
        
        ; Якщо все ще 400, можливо модель не підтримує system_instruction (старий формат)
        if (http.status == 400) {
            json := '{"contents":[{"parts":[{"text":"' EscapeJson(systemPrompt "`n`n" userPrompt) '"}]}],"generationConfig":{"temperature":0.3,"maxOutputTokens":4096}}'
            http.Open("POST", url, false)
            http.setRequestHeader("Content-Type", "application/json")
            http.send(json)
        }

        if (http.status != 200) {
            if (http.status == 429) {
                if (InStr(CurrentModelName, "pro")) {
                    MsgBox "Помилка: Вичерпано ліміти для Pro-моделі.`n`nБезкоштовний план Gemini Pro має дуже низькі обмеження (зазвичай 2 запити на хвилину або 50 на день).`n`nСпробуйте Flash-модель або зачекайте."
                } else {
                    MsgBox "Помилка: Вичерпано загальні ліміти Gemini API (Quota Exceeded).`n`nЗачекайте кілька хвилин або спробуйте іншу модель."
                }
            } else {
                MsgBox L.api_error http.status "`n" http.responseText
            }
            return "ERROR"
        }

        response := http.responseText
        
        ; Parsing Gemini response
        pos := InStr(response, '"text": "')
        if (!pos)
            return "EMPTY"
        
        start := pos + 9
        end := start
        while (end <= StrLen(response)) {
            ch := SubStr(response, end, 1)
            if (ch = '"' && SubStr(response, end - 1, 1) != "\") {
                break
            }
            end++
        }
        
        result := SubStr(response, start, end - start)
        result := StrReplace(result, "\n", "`n")
        result := StrReplace(result, "\r", "`r")
        result := StrReplace(result, "\t", "`t")
        result := StrReplace(result, '\"', '"')
        result := StrReplace(result, "\\", "\")
        
        return Trim(result)
    } catch Error as e {
        MsgBox L.request_error ": " e.Message
        return "ERROR"
    }
}

CallGroqAPI(systemPrompt, userPrompt, apiKey) {
    global L, CurrentModelName
    try {
        http := ComObject("MSXML2.ServerXMLHTTP.6.0")
        http.Open("POST", "https://api.groq.com/openai/v1/chat/completions", false)
        http.setRequestHeader("Content-Type", "application/json")
        http.setRequestHeader("Authorization", "Bearer " apiKey)

        json := '{"model":"' CurrentModelName '","messages":[{"role":"system","content":"' EscapeJson(systemPrompt) '"},{"role":"user","content":"' EscapeJson(userPrompt) '"}],"max_tokens":2048,"temperature":0.3}'

        http.send(json)

        if (http.status != 200) {
            MsgBox L.api_error http.status
            return "ERROR"
        }

        response := http.responseText
        
        pos := InStr(response, '"content":"')
        if (!pos)
            return "EMPTY"
        
        start := pos + 11
        end := start
        while (end <= StrLen(response)) {
            ch := SubStr(response, end, 1)
            if (ch = "\" && SubStr(response, end + 1, 1) = "n") {
                end++
            } else if (ch = '"' && SubStr(response, end - 1, 1) != "\") {
                break
            }
            end++
        }
        
        result := SubStr(response, start, end - start)
        result := StrReplace(result, "\n", "`n")
        result := StrReplace(result, "\r", "`r")
        result := StrReplace(result, "\t", "`t")
        result := StrReplace(result, '\"', '"')
        result := StrReplace(result, "\\", "\")
        
        ; Remove common repetitions if AI gets stuck
        lines := StrSplit(result, "`n")
        uniqueLines := []
        seen := Map()
        for line in lines {
            trimmed := Trim(line)
            if (trimmed != "") {
                if (!seen.Has(trimmed)) {
                    uniqueLines.Push(line)
                    seen[trimmed] := true
                }
            }
        }
        
        finalResult := ""
        for line in uniqueLines
            finalResult .= line (A_Index < uniqueLines.Length ? "`n" : "")
            
        return Trim(finalResult)
    } catch {
        MsgBox L.request_error
        return "ERROR"
    }
}

ShowPopup(original, corrected, mode := "fix") {
    global L, ResultNeutron
    original := Trim(original, " `t`r`n")
    corrected := Trim(corrected, " `t`r`n")
    
    if (mode == "prompt") {
        ; Для промпту просто використовуємо текст без diff
        diffObj := {htmlBefore: HtmlEscape(original), htmlAfter: HtmlEscape(corrected)}
        title := L.result_ai
        labelOrig := L.your_request
        labelRes := L.result_ai
        displayOrig := "none"
    } else {
        diffObj := GenerateDiff(original, corrected)
        title := L.result
        labelOrig := L.original
        labelRes := L.result
        displayOrig := "block"
    }
    
    ; CSS стилі для Neutron
    css := "
    (
        * { outline: none !important; box-sizing: border-box; }
        header { display: none; }
        html, body { 
            margin: 0; padding: 0; background-color: #1e2227; color: #abb2bf; font-family: 'Segoe UI', system-ui, sans-serif;
            overflow: hidden;
        }
        .container { 
            display: flex; 
            flex-direction: column;
            padding: 10px 10px 14px 10px; 
            border: 1px solid #3e4451;
            border-radius: 8px;
            background-color: #1e2227;
        }
        .header { 
            font-size: 13px; 
            font-weight: 600; 
            color: #5c6370; 
            margin-bottom: 10px; 
            user-select: none;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .header b { color: #3b82f6; }
        .scroll-area { 
            flex-grow: 1; 
            overflow-y: auto; 
            padding-right: 4px; 
            margin-bottom: 10px;
            display: flex;
            flex-direction: column;
            gap: 8px;
        }
        .scroll-area::-webkit-scrollbar { width: 6px; }
        .scroll-area::-webkit-scrollbar-track { background: transparent; }
        .scroll-area::-webkit-scrollbar-thumb { background: #3e4451; border-radius: 3px; }

        .card { 
            background: #21252b; 
            border: 1px solid #3e4451; 
            border-radius: 6px; 
            padding: 0; 
            margin-bottom: 4px;
            overflow: hidden;
            display: flex;
            flex-direction: column;
            flex-shrink: 0;
        }
        .label { 
            display: block; 
            font-size: 10px; 
            text-transform: uppercase; 
            letter-spacing: 1px; 
            padding: 2px 12px;
            font-weight: 700;
            color: #5c6370;
            background: #282c34;
            border-bottom: 1px solid #3e4451;
            margin: 0;
        }
        .label span { color: #3b82f6; }
        .content-box { 
            font-size: 13px; 
            line-height: 1.4; 
            color: #dcdfe4; 
            white-space: pre-wrap; 
            word-wrap: break-word;
            padding: 4px 12px;
            margin: 0;
        }
        .content { margin: 0; padding: 0; }
        
        .add { background: rgba(59, 130, 246, 0.15); color: #60a5fa; padding: 1px 2px; border-radius: 3px; }
        .del { background: rgba(244, 63, 94, 0.15); color: #fb7185; text-decoration: line-through; padding: 1px 2px; border-radius: 3px; }

        .footer { 
            display: flex; 
            justify-content: flex-end; 
            gap: 12px; 
            padding-top: 10px; 
            border-top: 1px solid #3e4451; 
            margin-top: 10px;
        }
        .footer-right {
            display: flex;
            gap: 8px;
            justify-content: flex-end;
            width: 100%;
        }
        button { 
            padding: 6px 14px; 
            border-radius: 4px; 
            border: 1px solid transparent; 
            cursor: pointer; 
            font-size: 12px; 
            font-weight: 500;
            transition: 0.2s; 
        }
        .btn-primary { 
            background: #3b82f6; 
            color: white; 
            border: none; 
            padding: 8px 16px; 
            border-radius: 6px; 
            font-size: 13px;
            font-weight: 500;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 6px;
        }
        .btn-primary:hover { background: #2563eb; }
        .btn-secondary { background: #2c313a; color: #abb2bf; border-color: #3e4451; }
        .btn-secondary:hover { background: #3e4451; color: #fff; }
    )"
    
    ; HTML контент
    html := "
    (
        <div id='wrapper' class='container'>
            <div class='header' onmousedown='neutron.DragTitleBar()'>{{TITLE}}</div>
            
            <div class='scroll-area' id='scrollArea'>
                <div class='card' style='display: {{DISPLAY_ORIG}}'>
                    <span class='label' style='color:#abb2bf'>{{LABEL_ORIG}}</span>
                    <div class='content-box'><div class='content'>{{ORIGINAL}}</div></div>
                </div>
                <div class='card'>
                    <span class='label' style='color:#3b82f6'>{{LABEL_RES}}</span>
                    <div class='content-box'><div id='mainCorrText' class='content'>{{CORRECTED_PLAIN}}</div></div>
                </div>
            </div>

            <div class='footer'>
                <div class='footer-right' style='width: 100%; display: flex; justify-content: flex-end; gap: 8px;'>
                    <button class='btn-primary' onclick='ahk.OnReplace()'>{{L_REPLACE}}</button>
                    <button class='btn-secondary' onclick='ahk.OnCancel()'>{{L_CANCEL}}</button>
                </div>
            </div>
        </div>
    )"
    html := StrReplace(html, "{{TITLE}}", title)
    html := StrReplace(html, "{{LABEL_ORIG}}", labelOrig)
    html := StrReplace(html, "{{LABEL_RES}}", labelRes)
    html := StrReplace(html, "{{DISPLAY_ORIG}}", displayOrig)
    html := StrReplace(html, "{{ORIGINAL}}", diffObj.htmlBefore)
    html := StrReplace(html, "{{CORRECTED_PLAIN}}", diffObj.htmlAfter)
    html := StrReplace(html, "{{L_REPLACE}}", L.replace)
    html := StrReplace(html, "{{L_CANCEL}}", L.cancel)
    
    global neutron := NeutronWindow(html, css, "", title)
    
    ; Налаштування GUI
    neutron.gui.Opt("+AlwaysOnTop -Caption +ToolWindow")
    neutron.gui.BackColor := "1a1b1e"
    
    UpdateWindowHeight(neutron, true)
}

UpdateWindowHeight(neutronObj, isFirstShow := false) {
    if (isFirstShow) {
        ; Тільки при першому показі використовуємо Hide/Center для ідеального позиціонування
        neutronObj.Show("w600 Hide")
        Sleep 200 ; Збільшено час для рендерингу
    }
    
    try {
        ; Розраховуємо висоту wrapper. 
        ; scrollHeight для wrapper дає реальний розмір вмісту.
        ; Додаємо запас для футера та відступів.
        contentHeight := neutronObj.doc.getElementById("wrapper").scrollHeight + 80
    } catch {
        contentHeight := 450
    }
    
    ; Обмеження висоти вікна (не більше 85% висоти екрана)
    maxH := A_ScreenHeight * 0.85
    if (contentHeight > maxH) contentHeight := maxH
    if (contentHeight < 260) contentHeight := 260
    
    if (isFirstShow) {
        neutronObj.Show("w600 h" Integer(contentHeight) " Center")
    } else {
        ; При оновленні просто змінюємо висоту
        neutronObj.gui.Show("h" Integer(contentHeight) " NoActivate")
    }
}

; Обробники подій для Neutron
OnReplace(neutron) {
    try {
        ; Отримуємо текст з нашого блоку результату
        text := neutron.doc.getElementById("mainCorrText").innerText
        neutron.Close()
        ReplaceAction(text)
    } catch {
        neutron.Close()
    }
}

OnCancel(neutron) {
    neutron.Close()
}

GenerateDiff(oldText, newText) {
    ; Використовуємо рідкісний символ для розділення, щоб уникнути конфліктів з текстом
    delim := Chr(1)
    pattern := '([\s\.,!\?\(\)\[\]\{\}:;"' . "'" . '])'
    
    oldWords := []
    for m in StrSplit(RegExReplace(oldText, pattern, delim "$1" delim), delim)
        if (m != "") oldWords.Push(m)
        
    newWords := []
    for m in StrSplit(RegExReplace(newText, pattern, delim "$1" delim), delim)
        if (m != "") newWords.Push(m)
        
    mLen := oldWords.Length
    nLen := newWords.Length
    
    dp := Array()
    loop mLen + 1 {
        row := Array()
        loop nLen + 1
            row.Push(0)
        dp.Push(row)
    }
    
    loop mLen {
        iIdx := A_Index
        loop nLen {
            jIdx := A_Index
            if (oldWords[iIdx] == newWords[jIdx])
                dp[iIdx+1][jIdx+1] := dp[iIdx][jIdx] + 1
            else
                dp[iIdx+1][jIdx+1] := Max(dp[iIdx][jIdx+1], dp[iIdx+1][jIdx])
        }
    }
    
    i := mLen, j := nLen
    diff := []
    
    while (i > 0 && j > 0) {
        if (oldWords[i] == newWords[j]) {
            diff.InsertAt(1, {type: "same", text: oldWords[i]})
            i--, j--
        } else if (dp[i][j+1] >= dp[i+1][j]) {
            diff.InsertAt(1, {type: "del", text: oldWords[i]})
            i--
        } else {
            diff.InsertAt(1, {type: "add", text: newWords[j]})
            j--
        }
    }
    
    while (i > 0) {
        diff.InsertAt(1, {type: "del", text: oldWords[i]})
        i--
    }
    while (j > 0) {
        diff.InsertAt(1, {type: "add", text: newWords[j]})
        j--
    }
    
    merged := []
    if (diff.Length > 0) {
        current := diff[1]
        loop diff.Length - 1 {
            next := diff[A_Index + 1]
            if (next.type == current.type) {
                current.text .= next.text
            } else {
                merged.Push(current)
                current := next
            }
        }
        merged.Push(current)
    }
    
    htmlBefore := "", htmlAfter := ""
    for item in merged {
        txt := HtmlEscape(item.text)
        if (item.type == "same") {
            htmlBefore .= txt
            htmlAfter .= txt
        } else if (item.type == "del") {
            htmlBefore .= "<span class='del'>" txt "</span>"
        } else if (item.type == "add") {
            htmlAfter .= "<span class='add'>" txt "</span>"
        }
    }
    
    return {htmlBefore: htmlBefore, htmlAfter: htmlAfter}
}

HtmlEscape(str, isRaw := false) {
    str := StrReplace(str, "&", "&amp;")
    str := StrReplace(str, "<", "&lt;")
    str := StrReplace(str, ">", "&gt;")
    str := StrReplace(str, '"', "&quot;")
    str := StrReplace(str, "'", "&#39;")
    if (!isRaw)
        str := StrReplace(str, "`n", "<br>")
    return str
}

; Функція заміни
ReplaceAction(text) {
    PerformPaste(text)
}
