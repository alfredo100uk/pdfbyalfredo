#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn VarUnset, Off

; --- RUTA DE DEPENDENCIAS EN APPDATA\LOCAL ---
global appDataDir := EnvGet("LOCALAPPDATA") "\pdfbyalfredo"
if (!DirExist(appDataDir))
    DirCreate(appDataDir)

; --- COMPROBACIÓN Y DESCARGA AUTOMÁTICA DE DEPENDENCIAS ---
ComprobarYDescargarDependencias()

; --- INICIALIZACIÓN DE VARIABLES GLOBALES ---
global T := Map()
global idiomaActual := "es"

; Diccionario de textos en Español
T["es"] := Map(
    "title", "PDF's ©by Alfredo 2026 v0.0.8",
    "drop", "Arrastra PDFs (Doble clic para editar páginas):",
    "top", "Mantener siempre visible",
    "col1", "#",
    "col2", "Estado",
    "col3", "Ruta del Archivo y Páginas",
    "subir", "▲ Subir",
    "bajar", "▼ Bajar",
    "abrirUno", "👁 Abrir PDF",
    "firmarUno", "🔏 Firmar PDF",
    "eliminar", "Eliminar",
    "limpiar", "Limpiar",
    "unir", "Unir PDFs",
    "r90", "↻",
    "r180", "Rotar 180°",
    "r270", "↺",
    "ayuda", "Ayuda",
    "salir", "Salir",
    "ayudaTitulo", "Manual de Ayuda e Información",
    "ayudaCoke", "¡Invítame a una cocacola!",
    "ayudaEmail", "Contacto:",
    "emailAddr", "alfredo100uk@gmail.com",
    "cerrar", "Cerrar",
    "errEngine", "No se encontró 'pdftk.exe' en AppData\Local.",
    "errSignEngine", "No se encontró un ejecutable 'pdfsign.exe' válido en AppData\Local.`n`nPor favor, descarga 'pdfsign.exe' y colócalo manualmente en:`n",
    "errMin2", "Añade al menos 2 PDFs.",
    "errMin1", "Añade al menos un PDF a la lista para rotar.",
    "errNoSelect", "Por favor, selecciona un PDF de la lista.",
    "guardarComo", "Guardar PDF unido como...",
    "procesoOk", "PROCESANDO...",
    "uniendo", "Uniendo...",
    "firmando", "Firmando...",
    "completado", "COMPLETADO",
    "finTitulo", "¡Finalizado!",
    "pdfGuardado", "PDF guardado en:",
    "abrirPdf", "Abrir PDF",
    "abrirCarpeta", "Abrir Carpeta"
)

; Diccionario de textos en Inglés
T["en"] := Map(
    "title", "PDF's ©by Alfredo 2026 v0.0.8",
    "drop", "Drag PDFs (Double-click to edit pages):",
    "top", "Keep always on top",
    "col1", "#",
    "col2", "Status",
    "col3", "File Path & Pages",
    "subir", "▲ Move Up",
    "bajar", "▼ Move Down",
    "abrirUno", "👁 Open PDF",
    "firmarUno", "🔏 Sign PDF",
    "eliminar", "Delete",
    "limpiar", "Clear",
    "unir", "Merge PDFs",
    "r90", "↻",
    "r180", "Rotate 180°",
    "r270", "↺",
    "ayuda", "Help",
    "salir", "Exit",
    "ayudaTitulo", "Help & Information Manual",
    "ayudaCoke", "Buy me a Coca-Cola!",
    "ayudaEmail", "Contact:",
    "emailAddr", "alfredo100uk@gmail.com",
    "cerrar", "Close",
    "errEngine", "'pdftk.exe' was not found in AppData\Local.",
    "errSignEngine", "A valid 'pdfsign.exe' was not found in AppData\Local.`n`nPlease place 'pdfsign.exe' manually in:`n",
    "errMin2", "Please add at least 2 PDFs.",
    "errMin1", "Please add at least one PDF to rotate.",
    "errNoSelect", "Please select a PDF from the list.",
    "guardarComo", "Save merged PDF as...",
    "procesoOk", "PROCESSING...",
    "uniendo", "Merging...",
    "firmando", "Signing...",
    "completado", "COMPLETED",
    "finTitulo", "Finished!",
    "pdfGuardado", "PDF saved to:",
    "abrirPdf", "Open PDF",
    "abrirCarpeta", "Open Folder"
)

; --- INTERFAZ GRÁFICA (GUI) ---
MyGui := Gui("-Resize", T[idiomaActual]["title"])
MyGui.MarginX := 12
MyGui.MarginY := 12

LblDrop := MyGui.Add("Text", "x12 y12 w300 h20", T[idiomaActual]["drop"])
DDLIdioma := MyGui.Add("DropDownList", "x320 y8 w85 Choose1", ["Español", "English"])
DDLIdioma.OnEvent("Change", CambiarIdioma)
ChkAlwaysOnTop := MyGui.Add("Checkbox", "x415 y10 w215 h23 Checked", T[idiomaActual]["top"])
ChkAlwaysOnTop.OnEvent("Click", AlternarSiempreVisible)

LV := MyGui.Add("ListView", "x12 y35 w480 h180 -Multi r9", [T[idiomaActual]["col1"], T[idiomaActual]["col2"], T[idiomaActual]["col3"]])
LV.ModifyCol(1, 35)
LV.ModifyCol(2, 85)
LV.ModifyCol(3, 350)
LV.OnEvent("DoubleClick", EditarPaginasPrompt)

; Botonera Lateral
BtnSubir    := MyGui.Add("Button", "x505 y35 w125 h26", T[idiomaActual]["subir"])
BtnBajar    := MyGui.Add("Button", "x505 y63 w125 h26", T[idiomaActual]["bajar"])
BtnAbrir    := MyGui.Add("Button", "x505 y91 w125 h26", T[idiomaActual]["abrirUno"])
BtnFirmar   := MyGui.Add("Button", "x505 y119 w125 h26", T[idiomaActual]["firmarUno"])
BtnEliminar := MyGui.Add("Button", "x505 y147 w125 h26", T[idiomaActual]["eliminar"])
BtnLimpiar  := MyGui.Add("Button", "x505 y175 w125 h26", T[idiomaActual]["limpiar"])

; Botonera Inferior
BtnUnir     := MyGui.Add("Button", "x12 y230 w100 h35 Default", T[idiomaActual]["unir"])

BtnRotar90  := MyGui.Add("Button", "x116 y230 w80 h35 Center", T[idiomaActual]["r90"])
BtnRotar90.SetFont("s22 bold")

BtnRotar180 := MyGui.Add("Button", "x200 y230 w80 h35", T[idiomaActual]["r180"])

BtnRotar270 := MyGui.Add("Button", "x284 y230 w80 h35 Center", T[idiomaActual]["r270"])
BtnRotar270.SetFont("s22 bold")

BtnAyuda    := MyGui.Add("Button", "x368 y230 w75 h35", T[idiomaActual]["ayuda"])
BtnSalir    := MyGui.Add("Button", "x447 y230 w183 h35", T[idiomaActual]["salir"])

TxtEstado   := MyGui.Add("Text", "x12 y275 w618 Center", "")
TxtEstado.SetFont("s10 bold")
MyGui.Opt("+AlwaysOnTop")

; Registro de Eventos
MyGui.OnEvent("DropFiles", Gui_DropFiles)
BtnSubir.OnEvent("Click", (*) => MoverItem(-1, LV))
BtnBajar.OnEvent("Click", (*) => MoverItem(1, LV))
BtnAbrir.OnEvent("Click", (*) => AbrirPDFEnVentanaPropia(LV))
BtnFirmar.OnEvent("Click", (*) => FirmarPDFSeleccionado(LV))
BtnEliminar.OnEvent("Click", (*) => EliminarItem(LV))
BtnLimpiar.OnEvent("Click", (*) => LV.Delete())
BtnUnir.OnEvent("Click", (*) => UnirPDFs(LV))
BtnRotar90.OnEvent("Click", (*) => RotarPDFs("right", "_rota90", LV))
BtnRotar180.OnEvent("Click", (*) => RotarPDFs("down", "_rota180", LV))
BtnRotar270.OnEvent("Click", (*) => RotarPDFs("left", "_rota270", LV))
BtnAyuda.OnEvent("Click", (*) => MostrarAyuda())
BtnSalir.OnEvent("Click", (*) => ExitApp())
MyGui.OnEvent("Close", (*) => ExitApp())

MyGui.Show()

; --- FUNCIONES DEL SCRIPT ---

ComprobarYDescargarDependencias() {
    enginePath  := appDataDir "\pdftk.exe"
    dllPath     := appDataDir "\libiconv2.dll"
    sumatraPath := appDataDir "\SumatraPDF.exe"
    pdfsignPath := appDataDir "\pdfsign.exe"
    
    if (!FileExist(enginePath)) {
        try Download("https://github.com/alfredo100uk/pdfbyalfredo/raw/main/pdftk.exe", enginePath)
    }
    
    if (!FileExist(dllPath)) {
        try Download("https://github.com/alfredo100uk/pdfbyalfredo/raw/main/libiconv2.dll", dllPath)
    }

    if (!FileExist(sumatraPath)) {
        try Download("https://www.sumatrapdfreader.org/dl/rel/3.5.2/SumatraPDF-3.5.2-64.exe", sumatraPath)
    }

    if (FileExist(pdfsignPath) && FileGetSize(pdfsignPath) < 1000000) {
        try FileDelete(pdfsignPath)
    }
    
    if (!FileExist(pdfsignPath)) {
        ; Intento principal desde la web del creador
        try {
            Download("https://github.com/IcoDeveloper/PDFSign/releases/download/1.3.0/pdfsign_merged.exe", pdfsignPath)
        }
        
        ; Ruta alternativa (fallback) si falla la descarga anterior
        if (!FileExist(pdfsignPath) || FileGetSize(pdfsignPath) < 1000000) {
            try {
                Download("https://raw.githubusercontent.com/alfredo100uk/pdfbyalfredo/main/pdfsign.exe", pdfsignPath)
            }
        }
    }
}

FirmarPDFSeleccionado(lvObj) {
    global TxtEstado, idiomaActual, T, appDataDir
    
    row := lvObj.GetNext()
    if (!row) {
        MsgBox(T[idiomaActual]["errNoSelect"], "Aviso", "Icon!")
        return
    }
    
    pdfsignExe := appDataDir "\pdfsign.exe"
    if (!FileExist(pdfsignExe) || FileGetSize(pdfsignExe) < 1000000) {
        MsgBox(T[idiomaActual]["errSignEngine"] appDataDir, "Error de Ejecutable", "Iconx")
        return
    }
    
    lineaCompleta := lvObj.GetText(row, 3)
    filePath := RegExReplace(lineaCompleta, "\s+\d+-\d+$")
    filePath := Trim(filePath, ' "')
    
    if !FileExist(filePath) {
        MsgBox("No se encontró el archivo de origen:`n" filePath, "Error", "Iconx")
        return
    }
        
    SplitPath(filePath, , &outDir, , &outNameNoExt)
    outputFile := outDir "\" outNameNoExt "_firmado.pdf"
    
    TxtEstado.Value := T[idiomaActual]["procesoOk"]
    lvObj.Modify(row, "Col2", T[idiomaActual]["firmando"])
    
    tmpFile := appDataDir "\selected_cert.txt"
    psScriptFile := appDataDir "\select_cert.ps1"
    
    if FileExist(tmpFile)
        FileDelete(tmpFile)
    if FileExist(psScriptFile)
        FileDelete(psScriptFile)
        
    psContent := 
    (
        "try {
            $certs = Get-ChildItem Cert:\CurrentUser\My | Where-Object { $_.HasPrivateKey -and $_.NotAfter -gt (Get-Date) }
            if ($certs) {
                $selected = $certs | Select-Object Thumbprint, Subject | Out-GridView -Title 'Selecciona Certificado Digital' -OutputMode Single
                if ($selected) {
                    $rawThumb = $selected.Thumbprint.ToString().Trim().ToUpper() -replace '[^A-F0-9]', ''
                    [System.IO.File]::WriteAllText('" tmpFile "', $rawThumb, [System.Text.Encoding]::UTF8)
                }
            } else {
                [System.IO.File]::WriteAllText('" tmpFile "', 'NOCERTS', [System.Text.Encoding]::UTF8)
            }
        } catch {
            [System.IO.File]::WriteAllText('" tmpFile "', ('ERROR:' + $_.Exception.Message), [System.Text.Encoding]::UTF8)
        }"
    )
    
    FileAppend(psContent, psScriptFile, "UTF-8")
    RunWait('powershell -NoProfile -ExecutionPolicy Bypass -File "' psScriptFile '"', , "Hide")
    
    if FileExist(psScriptFile)
        FileDelete(psScriptFile)
    
    if (!FileExist(tmpFile)) {
        lvObj.Modify(row, "Col2", "Pendiente")
        TxtEstado.Value := ""
        return
    }
    
    resultText := Trim(FileRead(tmpFile))
    if FileExist(tmpFile)
        FileDelete(tmpFile)
    
    if (SubStr(resultText, 1, 6) = "ERROR:" || resultText = "NOCERTS" || resultText = "") {
        MsgBox("No se seleccionó un certificado válido con clave privada.", "Aviso", "Icon!")
        lvObj.Modify(row, "Col2", "Pendiente")
        TxtEstado.Value := ""
        return
    }
    
    ; Normalización limpia de la huella
    thumbprint := Format("{:U}", RegExReplace(resultText, "[^a-fA-F0-9]+"))
    logFile := appDataDir "\pdfsign_log.txt"
    if FileExist(logFile)
        FileDelete(logFile)

    ; Uso correcto de los parámetros de la CLI de pdfsign (--store y --thumbprint)
    cmdCall := '"' pdfsignExe '" -i "' filePath '" -o "' outputFile '" --store=CurrentUser --thumbprint=' thumbprint
    cmdCallWithLog := cmdCall ' > "' logFile '" 2>&1'
    exitCode := RunWait(A_ComSpec ' /c "' cmdCallWithLog '"', , "Hide")
    
    if FileExist(outputFile) {
        lvObj.Modify(row, "Col2", T[idiomaActual]["completado"])
        TxtEstado.Value := T[idiomaActual]["completado"]
        MsgBox(T[idiomaActual]["pdfGuardado"] "`n" outputFile, T[idiomaActual]["finTitulo"], "Iconi")
    } else {
        logError := FileExist(logFile) ? FileRead(logFile) : "Sin salida de consola registrada."
        
        diagnostico := "DIAGNÓSTICO DE EJECUCIÓN CLI:`n"
            . "--------------------------------------------------`n"
            . "Comando ejecutado:`n" cmdCall "`n`n"
            . "Huella enviada (SHA1): " thumbprint "`n"
            . "Código de salida: " exitCode "`n`n"
            . "Respuesta CLI:`n" logError "`n"
            . "--------------------------------------------------`n`n"
            . "¿Deseas ejecutar de nuevo este comando en una ventana de consola visible para depurar?"

        pregunta := MsgBox(diagnostico, "Error de Firma - Detalle Consola", "YesNo Iconx")
        
        if (pregunta = "Yes") {
            Run(A_ComSpec ' /k "' cmdCall '"')
        }
        
        lvObj.Modify(row, "Col2", "Pendiente")
        TxtEstado.Value := ""
    }
}

AbrirPDFEnVentanaPropia(lvObj) {
    row := lvObj.GetNext()
    if (!row) {
        MsgBox(T[idiomaActual]["errNoSelect"], "Aviso", "Icon!")
        return
    }
    
    lineaActual := lvObj.GetText(row, 3)
    filePath := RegExReplace(lineaActual, "\s+\d+-\d+$")
    filePath := Trim(filePath, ' "')

    if FileExist(filePath) {
        sumatraPath := appDataDir "\SumatraPDF.exe"
        if FileExist(sumatraPath) {
            Run('"' sumatraPath '" "' filePath '"')
        } else {
            Run('"' filePath '"')
        }
    }
}

CambiarIdioma(ddl, info) {
    global idiomaActual
    idiomaActual := (ddl.Text = "English" ? "en" : "es")
    ActualizarTextosInterfaz()
}

ActualizarTextosInterfaz() {
    global MyGui, LblDrop, ChkAlwaysOnTop, LV, BtnSubir, BtnBajar, BtnAbrir, BtnFirmar, BtnEliminar, BtnLimpiar
    global BtnUnir, BtnRotar90, BtnRotar180, BtnRotar270, BtnAyuda, BtnSalir, idiomaActual
    MyGui.Title := T[idiomaActual]["title"]
    LblDrop.Value := T[idiomaActual]["drop"]
    ChkAlwaysOnTop.Text := T[idiomaActual]["top"]
    LV.ModifyCol(1, , T[idiomaActual]["col1"])
    LV.ModifyCol(2, , T[idiomaActual]["col2"])
    LV.ModifyCol(3, , T[idiomaActual]["col3"])
    BtnSubir.Text := T[idiomaActual]["subir"]
    BtnBajar.Text := T[idiomaActual]["bajar"]
    BtnAbrir.Text := T[idiomaActual]["abrirUno"]
    BtnFirmar.Text := T[idiomaActual]["firmarUno"]
    BtnEliminar.Text := T[idiomaActual]["eliminar"]
    BtnLimpiar.Text := T[idiomaActual]["limpiar"]
    BtnUnir.Text := T[idiomaActual]["unir"]
    BtnRotar90.Text := T[idiomaActual]["r90"]
    BtnRotar180.Text := T[idiomaActual]["r180"]
    BtnRotar270.Text := T[idiomaActual]["r270"]
    BtnAyuda.Text := T[idiomaActual]["ayuda"]
    BtnSalir.Text := T[idiomaActual]["salir"]
}

AlternarSiempreVisible(chkCtrl, info) {
    MyGui.Opt((chkCtrl.Value ? "+" : "-") "AlwaysOnTop")
}

Gui_DropFiles(guiObj, controlObj, filenames, x, y) {
    global LV, idiomaActual
    for file in filenames {
        if (SubStr(file, -4) = ".pdf") {
            maxPags := ObtenerTotalPaginas(file)
            infoCompleta := file " 1-" maxPags
            LV.Add("", LV.GetCount() + 1, (idiomaActual = "es" ? "Pendiente" : "Pending"), infoCompleta)
        }
    }
    ReorganizarIndices(LV)
}

ObtenerTotalPaginas(pdfPath) {
    enginePath := appDataDir "\pdftk.exe"
    if (!FileExist(enginePath))
        return 1
    tmpTxt := appDataDir "\temp_info.txt"
    if FileExist(tmpTxt)
        FileDelete(tmpTxt)
    RunWait(A_ComSpec ' /c ""' enginePath '" "' pdfPath '" dump_data > "' tmpTxt '""', , "Hide")
    totalPags := 1
    if FileExist(tmpTxt) {
        texto := FileRead(tmpTxt)
        FileDelete(tmpTxt)
        if RegExMatch(texto, "i)NumberOfPages:\s*(\d+)", &match)
            totalPags := match[1]
    }
    return totalPags
}

ReorganizarIndices(lvObj) {
    Loop lvObj.GetCount()
        lvObj.Modify(A_Index, "", A_Index)
}

MoverItem(dir, lvObj) {
    row := lvObj.GetNext()
    if (!row || (row + dir) < 1 || (row + dir) > lvObj.GetCount())
        return
    
    estadoActual := lvObj.GetText(row, 2)
    rutaActual   := lvObj.GetText(row, 3)
    
    estadoDestino := lvObj.GetText(row + dir, 2)
    rutaDestino   := lvObj.GetText(row + dir, 3)
    
    lvObj.Modify(row, "", row, estadoDestino, rutaDestino)
    lvObj.Modify(row + dir, "", row + dir, estadoActual, rutaActual)
    
    lvObj.Modify(row, "-Select -Focus")
    lvObj.Modify(row + dir, "Select Focus")
}

EliminarItem(lvObj) {
    row := lvObj.GetNext()
    if (row)
        lvObj.Delete(row), ReorganizarIndices(lvObj)
}

EditarPaginasPrompt(lvObj, row) {
    if (!row)
        return
    lineaActual := lvObj.GetText(row, 3)
    filePath := RegExReplace(lineaActual, "\s+\d+-\d+$")
    filePath := Trim(filePath, ' "')
        
    maxPags := ObtenerTotalPaginas(filePath)
    
    dVal := "1"
    hVal := maxPags
    if RegExMatch(lineaActual, ".*?(\d+)-(\d+)$", &m) {
        dVal := m[1]
        hVal := m[2]
    }
    
    pGui := Gui("+AlwaysOnTop +ToolWindow", idiomaActual = "es" ? "Seleccionar Páginas" : "Select Pages")
    pGui.MarginX := 20, pGui.MarginY := 20
    
    pGui.Add("Text", "w300", idiomaActual = "es" ? "Archivo seleccionado:" : "Selected file:")
    pGui.Add("Edit", "w300 r2 ReadOnly", filePath)
    
    pGui.Add("Text", "y+10", idiomaActual = "es" ? "Desde la página:" : "From page:")
    txtDesde := pGui.Add("Edit", "w80", dVal)
    
    pGui.Add("Text", "y+10", idiomaActual = "es" ? "Hasta la página (Total: " maxPags "):" : "To page (Total: " maxPags "):")
    txtHasta := pGui.Add("Edit", "w80", hVal)
    
    btnOk := pGui.Add("Button", "y+15 w300 h35 Default", idiomaActual = "es" ? "Aceptar" : "OK")
    btnOk.OnEvent("Click", (*) => GuardarRangoPaginas(filePath, txtDesde.Value, txtHasta.Value, lvObj, row, pGui))
    pGui.Show()
}

GuardarRangoPaginas(filePath, desde, hasta, lvObj, row, ventana) {
    desdeVal := Trim(desde) == "" ? "1" : Trim(desde)
    hastaVal := Trim(hasta) == "" ? "1" : Trim(hasta)
    nuevaLinea := filePath " " desdeVal "-" hastaVal
    lvObj.Modify(row, "", row, lvObj.GetText(row, 2), nuevaLinea)
    ventana.Destroy()
}

MostrarAyuda() {
    global T, idiomaActual
    
    hGui := Gui("+AlwaysOnTop +ToolWindow", T[idiomaActual]["ayudaTitulo"])
    hGui.MarginX := 20
    hGui.MarginY := 15
    
    if (idiomaActual = "es") {
        t1 := hGui.Add("Text", "w480 h26 cBlue", "PDF's ©by Alfredo 2026 - Manual de Uso")
        t1.SetFont("Bold s11")
        
        hGui.Add("Text", "w480 y+8", "• Arrastrar y Soltar PDFs:")
        hGui.Add("Text", "w480 y+2 c666666", "  Arrastra uno o varios archivos PDF a la ventana principal.")
        
        hGui.Add("Text", "w480 y+10", "• Abrir PDF:")
        hGui.Add("Text", "w480 y+2 c666666", "  Selecciona un archivo y haz clic en '👁 Abrir PDF' para abrirlo con SumatraPDF.")
        
        hGui.Add("Text", "w480 y+10", "• Firmar PDF:")
        hGui.Add("Text", "w480 y+2 c666666", "  Selecciona un archivo y haz clic en '🔏 Firmar PDF' para firmarlo usando tu certificado digital.")
        
        hGui.Add("Text", "w480 y+10", "• Editar Páginas:")
        hGui.Add("Text", "w480 y+2 c666666", "  Haz doble clic en cualquier archivo de la lista para definir el rango de páginas a incluir.")
        
        tCoke := hGui.Add("Text", "w480 y+15 cRed", T[idiomaActual]["ayudaCoke"])
        tCoke.SetFont("Bold")
        
        hGui.Add("Text", "w480 y+3", T[idiomaActual]["ayudaEmail"])
        email := hGui.Add("Text", "w480 cBlue", T[idiomaActual]["emailAddr"])
        email.SetFont("Underline")
        email.OnEvent("Click", (*) => Run("mailto:" T[idiomaActual]["emailAddr"]))
        
    } else {
        t1 := hGui.Add("Text", "w480 h26 cBlue", "PDF's ©by Alfredo 2026 - User Manual")
        t1.SetFont("Bold s11")
        
        hGui.Add("Text", "w480 y+8", "• Drag and Drop PDFs:")
        hGui.Add("Text", "w480 y+2 c666666", "  Drop one or multiple PDF files into the main window.")
        
        hGui.Add("Text", "w480 y+10", "• Open PDF:")
        hGui.Add("Text", "w480 y+2 c666666", "  Select a file and click '👁 Open PDF' to open it using SumatraPDF.")
        
        hGui.Add("Text", "w480 y+10", "• Sign PDF:")
        hGui.Add("Text", "w480 y+2 c666666", "  Select a file and click '🔏 Sign PDF' to sign it with your digital certificate.")
        
        tCoke := hGui.Add("Text", "w480 y+15 cRed", T[idiomaActual]["ayudaCoke"])
        tCoke.SetFont("Bold")
        
        hGui.Add("Text", "w480 y+3", T[idiomaActual]["ayudaEmail"])
        email := hGui.Add("Text", "w480 cBlue", T[idiomaActual]["emailAddr"])
        email.SetFont("Underline")
        email.OnEvent("Click", (*) => Run("mailto:" T[idiomaActual]["emailAddr"]))
    }
    
    btn := hGui.Add("Button", "y+15 w480 h35 Default", T[idiomaActual]["cerrar"])
    btn.OnEvent("Click", (*) => hGui.Destroy())
    hGui.Show()
}

RotarPDFs(modoRotacion, sufijo, lvObj) {
    global TxtEstado, BtnUnir, BtnRotar90, BtnRotar180, BtnRotar270, BtnSalir, BtnAyuda, idiomaActual, T
    total := lvObj.GetCount()
    if (total < 1)
        return MsgBox(T[idiomaActual]["errMin1"], "Aviso", "Icon!")
    enginePath := appDataDir "\pdftk.exe"
    if (!FileExist(enginePath))
        return MsgBox(T[idiomaActual]["errEngine"], "Error", "Iconx")
    TxtEstado.Value := T[idiomaActual]["procesoOk"]
    for ctrl in [BtnUnir, BtnRotar90, BtnRotar180, BtnRotar270, BtnSalir, BtnAyuda]
        ctrl.Enabled := false
    Loop total {
        lineaCompleta := lvObj.GetText(A_Index, 3)
        filePath := RegExReplace(lineaCompleta, "\s+\d+-\d+$")
        filePath := Trim(filePath, ' "')
        
        rangoPaginas := "1-end"
        if RegExMatch(lineaCompleta, ".*?(\d+-\d+)$", &m)
            rangoPaginas := m[1]
            
        SplitPath(filePath, , &outDir, , &outNameNoExt)
        outputFile := outDir "\" outNameNoExt sufijo ".pdf"
        if FileExist(outputFile)
            FileDelete(outputFile)
        lvObj.Modify(A_Index, "Col2", T[idiomaActual]["uniendo"])
        RunWait(A_ComSpec ' /c ""' enginePath '" A="' filePath '" cat A' rangoPaginas modoRotacion ' output "' outputFile '""', , "Hide")
        lvObj.Modify(A_Index, "Col2", T[idiomaActual]["completado"])
    }
    TxtEstado.Value := T[idiomaActual]["completado"]
    MsgBox(T[idiomaActual]["finTitulo"], "Proceso Finalizado", "Iconi")
    for ctrl in [BtnUnir, BtnRotar90, BtnRotar180, BtnRotar270, BtnSalir, BtnAyuda]
        ctrl.Enabled := true
}

UnirPDFs(lvObj) {
    global TxtEstado, BtnUnir, BtnRotar90, BtnRotar180, BtnRotar270, BtnSalir, BtnAyuda, idiomaActual, T
    total := lvObj.GetCount()
    if (total < 2)
        return MsgBox(T[idiomaActual]["errMin2"], "Aviso", "Icon!")
    enginePath := appDataDir "\pdftk.exe"
    if (!FileExist(enginePath))
        return MsgBox(T[idiomaActual]["errEngine"], "Error", "Iconx")
    
    primerItemText := lvObj.GetText(1, 3)
    primerFilePath := RegExReplace(primerItemText, "\s+\d+-\d+$")
    primerFilePath := Trim(primerFilePath, ' "')
    
    SplitPath(primerFilePath, , &outDir, , &outNameNoExt)
    
    defaultName := outDir "\" (outNameNoExt ? outNameNoExt "_unido" : "DocumentoUnido") ".pdf"
    
    OutputFile := FileSelect("S16", defaultName, T[idiomaActual]["guardarComo"], "PDF (*.pdf)")
    if (!OutputFile)
        return
    if (SubStr(OutputFile, -4) != ".pdf")
        OutputFile .= ".pdf"
        
    TxtEstado.Value := T[idiomaActual]["procesoOk"]
    for ctrl in [BtnUnir, BtnRotar90, BtnRotar180, BtnRotar270, BtnSalir, BtnAyuda]
        ctrl.Enabled := false
    Loop total
        lvObj.Modify(A_Index, "Col2", T[idiomaActual]["uniendo"])
    
    inputFiles := ""
    catInstruction := ""
    
    Loop total {
        itemText := lvObj.GetText(A_Index, 3)
        filePath := RegExReplace(itemText, "\s+\d+-\d+$")
        filePath := Trim(filePath, ' "')
        
        rango := "1-end"
        if RegExMatch(itemText, ".*?(\d+-\d+)$", &m)
            rango := m[1]
            
        if FileExist(filePath) {
            letraHandle := Chr(64 + A_Index)
            inputFiles .= ' ' letraHandle '="' filePath '"'
            catInstruction .= ' ' letraHandle rango
        }
    }
    
    RunWait(A_ComSpec ' /c ""' enginePath '"' inputFiles ' cat' catInstruction ' output "' OutputFile '""', , "Hide")
    Loop total
        lvObj.Modify(A_Index, "Col2", T[idiomaActual]["completado"])
    TxtEstado.Value := T[idiomaActual]["completado"]
    MsgBox(T[idiomaActual]["finTitulo"], "Proceso Finalizado", "Iconi")
    for ctrl in [BtnUnir, BtnRotar90, BtnRotar180, BtnRotar270, BtnSalir, BtnAyuda]
        ctrl.Enabled := true
}