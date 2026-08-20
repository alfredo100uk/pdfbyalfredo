#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn VarUnset, Off

; --- COMPROBACIÓN Y DESCARGA AUTOMÁTICA DE DEPENDENCIAS ---
ComprobarYDescargarDependencias()

ComprobarYDescargarDependencias() {
    enginePath := A_ScriptDir "\pdftk.exe"
    dllPath := A_ScriptDir "\libiconv2.dll"
    
    if (!FileExist(enginePath)) {
        try {
            Download("https://github.com/alfredo100uk/pdfbyalfredo/raw/main/pdftk.exe", enginePath)
        } catch {
        }
    }
    
    if (!FileExist(dllPath)) {
        try {
            Download("https://github.com/alfredo100uk/pdfbyalfredo/releases/download/v0.0.2/libiconv2.dll", dllPath)
        } catch {
            try {
                Download("https://github.com/alfredo100uk/pdfbyalfredo/raw/main/libiconv2.dll", dllPath)
            } catch {
            }
        }
    }
}
; ---------------------------------------------------------

global T := Map()
global idiomaActual := "es"

T["es"] := Map(
    "title", "PDF's ©by Alfredo 2026",
    "drop", "Arrastra y suelta tus archivos PDF en la lista:",
    "top", "Mantener siempre visible",
    "col1", "#",
    "col2", "Estado",
    "col3", "Ruta del Archivo",
    "subir", "▲ Subir",
    "bajar", "▼ Bajar",
    "eliminar", "Eliminar",
    "limpiar", "Limpiar",
    "unir", "Unir PDFs",
    "r90", "Rotar 90º",
    "r180", "Rotar 180º",
    "r270", "Rotar 270º",
    "ayuda", "Ayuda",
    "salir", "Salir",
    "ayudaTitulo", "Ayuda e Información",
    "ayudaNecesario", "Necesarios los ficheros pdftk.exe y libiconv2.dll de:",
    "ayudaCoke", "¡Invitame a una cocacola!",
    "ayudaEmail", "Contacto:",
    "emailAddr", "alfredo100uk@gmail.com",
    "cerrar", "Cerrar",
    "errEngine", "No se encontró 'pdftk.exe' en la carpeta.",
    "errMin2", "Añade al menos 2 PDFs.",
    "errMin1", "Añade al menos un PDF a la lista para rotar.",
    "guardarComo", "Guardar como...",
    "rotando", "ROTANDO ARCHIVOS...",
    "rotado", "Rotado",
    "rotandoEstado", "Rotando...",
    "rotacionOk", "¡ROTACIÓN COMPLETADA!",
    "rotacionMsg", "Se han rotado todos los archivos de la lista con éxito.",
    "procesoOk", "PROCESANDO...",
    "uniendo", "Uniendo...",
    "completado", "COMPLETADO",
    "finTitulo", "¡Finalizado!",
    "pdfGuardado", "PDF guardado en:",
    "abrirPdf", "Abrir PDF",
    "abrirCarpeta", "Abrir Carpeta"
)
T["en"] := Map(
    "title", "PDF's ©by Alfredo 2026",
    "drop", "Drag and drop your PDF files into the list:",
    "top", "Keep always on top",
    "col1", "#",
    "col2", "Status",
    "col3", "File Path",
    "subir", "▲ Move Up",
    "bajar", "▼ Move Down",
    "eliminar", "Delete",
    "limpiar", "Clear",
    "unir", "Merge PDFs",
    "r90", "Rotate 90º",
    "r180", "Rotate 180º",
    "r270", "Rotate 270º",
    "ayuda", "Help",
    "salir", "Exit",
    "ayudaTitulo", "Help & Information",
    "ayudaNecesario", "Required files pdftk.exe and libiconv2.dll from:",
    "ayudaCoke", "Buy me a Coca-Cola!",
    "ayudaEmail", "Contact:",
    "emailAddr", "alfredo100uk@gmail.com",
    "cerrar", "Close",
    "errEngine", "'pdftk.exe' was not found in the folder.",
    "errMin2", "Please add at least 2 PDFs.",
    "errMin1", "Please add at least one PDF to rotate.",
    "guardarComo", "Save as...",
    "rotando", "ROTATING FILES...",
    "rotado", "Rotated",
    "rotandoEstado", "Rotating...",
    "rotacionOk", "ROTATION COMPLETED!",
    "rotacionMsg", "All files in the list have been rotated successfully.",
    "procesoOk", "PROCESSING...",
    "uniendo", "Merging...",
    "completado", "COMPLETED",
    "finTitulo", "Finished!",
    "pdfGuardado", "PDF saved to:",
    "abrirPdf", "Open PDF",
    "abrirCarpeta", "Open Folder"
)

; --- INTERFAZ GRÁFICA ---
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

BtnSubir    := MyGui.Add("Button", "x505 y35 w125 h30", T[idiomaActual]["subir"])
BtnBajar    := MyGui.Add("Button", "x505 y70 w125 h30", T[idiomaActual]["bajar"])
BtnEliminar := MyGui.Add("Button", "x505 y105 w125 h30", T[idiomaActual]["eliminar"])
BtnLimpiar  := MyGui.Add("Button", "x505 y140 w125 h30", T[idiomaActual]["limpiar"])
BtnUnir     := MyGui.Add("Button", "x12 y230 w100 h35 Default", T[idiomaActual]["unir"])
BtnRotar90  := MyGui.Add("Button", "x116 y230 w80 h35", T[idiomaActual]["r90"])
BtnRotar180 := MyGui.Add("Button", "x200 y230 w80 h35", T[idiomaActual]["r180"])
BtnRotar270 := MyGui.Add("Button", "x284 y230 w80 h35", T[idiomaActual]["r270"])
BtnAyuda    := MyGui.Add("Button", "x368 y230 w75 h35", T[idiomaActual]["ayuda"])
BtnSalir    := MyGui.Add("Button", "x447 y230 w183 h35", T[idiomaActual]["salir"])

TxtEstado   := MyGui.Add("Text", "x12 y275 w618 Center", "")
TxtEstado.SetFont("s10 bold")
MyGui.Opt("+AlwaysOnTop")

; Asignación de Eventos
MyGui.OnEvent("DropFiles", Gui_DropFiles)
BtnSubir.OnEvent("Click", (*) => MoverItem(-1))
BtnBajar.OnEvent("Click", (*) => MoverItem(1))
BtnEliminar.OnEvent("Click", (*) => EliminarItem())
BtnLimpiar.OnEvent("Click", (*) => LV.Delete())
BtnUnir.OnEvent("Click", UnirPDFs)
BtnRotar90.OnEvent("Click", (*) => RotarPDFs("right", "_rota90"))
BtnRotar180.OnEvent("Click", (*) => RotarPDFs("down", "_rota180"))
BtnRotar270.OnEvent("Click", (*) => RotarPDFs("left", "_rota270"))
BtnAyuda.OnEvent("Click", (*) => MostrarAyuda())
BtnSalir.OnEvent("Click", (*) => ExitApp())
MyGui.OnEvent("Close", (*) => ExitApp())
MyGui.Show()

; --- FUNCIONES ---

CambiarIdioma(ddl, info) {
    global idiomaActual
    idiomaActual := (ddl.Text = "English" ? "en" : "es")
    ActualizarTextosInterfaz()
}

ActualizarTextosInterfaz() {
    global MyGui, LblDrop, ChkAlwaysOnTop, LV, BtnSubir, BtnBajar, BtnEliminar, BtnLimpiar
    global BtnUnir, BtnRotar90, BtnRotar180, BtnRotar270, BtnAyuda, BtnSalir, idiomaActual
    MyGui.Title := T[idiomaActual]["title"]
    LblDrop.Value := T[idiomaActual]["drop"]
    ChkAlwaysOnTop.Text := T[idiomaActual]["top"]
    LV.ModifyCol(1, , T[idiomaActual]["col1"])
    LV.ModifyCol(2, , T[idiomaActual]["col2"])
    LV.ModifyCol(3, , T[idiomaActual]["col3"])
    BtnSubir.Text := T[idiomaActual]["subir"]
    BtnBajar.Text := T[idiomaActual]["bajar"]
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
    for file in filenames
        if (SubStr(file, -4) = ".pdf")
            LV.Add("", LV.GetCount() + 1, (idiomaActual = "es" ? "Pendiente" : "Pending"), file)
    ReorganizarIndices()
}

ReorganizarIndices() {
    global LV
    Loop LV.GetCount()
        LV.Modify(A_Index, "", A_Index)
}

MoverItem(dir) {
    global LV
    row := LV.GetNext()
    if (!row || (row + dir) < 1 || (row + dir) > LV.GetCount())
        return
    
    estadoActual := LV.GetText(row, 2)
    rutaActual   := LV.GetText(row, 3)
    
    estadoDestino := LV.GetText(row + dir, 2)
    rutaDestino   := LV.GetText(row + dir, 3)
    
    LV.Modify(row, "", row, estadoDestino, rutaDestino)
    LV.Modify(row + dir, "", row + dir, estadoActual, rutaActual)
    
    LV.Modify(row, "-Select -Focus")
    LV.Modify(row + dir, "Select Focus")
}

EliminarItem() {
    global LV
    row := LV.GetNext()
    if (row)
        LV.Delete(row), ReorganizarIndices()
}

MostrarAyuda() {
    global T, idiomaActual
    
    hGui := Gui("+AlwaysOnTop +ToolWindow", T[idiomaActual]["ayudaTitulo"])
    hGui.MarginX := 20, hGui.MarginY := 20
    
    t1 := hGui.Add("Text", "w380 cBlue", "PDF's ©by Alfredo 2026")
    t1.SetFont("Bold")
    
    hGui.Add("Text", "w380 y+10", T[idiomaActual]["ayudaNecesario"])
    
    lnk := hGui.Add("Text", "w380 y+5 cBlue", "https://portableapps.com/apps/office/pdftk_builder_portable")
    lnk.SetFont("Underline")
    lnk.OnEvent("Click", (*) => Run("https://portableapps.com/apps/office/pdftk_builder_portable"))
    
    t2 := hGui.Add("Text", "w380 y+15 cRed", T[idiomaActual]["ayudaCoke"])
    t2.SetFont("Bold")
    
    hGui.Add("Text", "w380 y+5", T[idiomaActual]["ayudaEmail"])
    email := hGui.Add("Text", "w380 cBlue", T[idiomaActual]["emailAddr"])
    email.SetFont("Underline")
    email.OnEvent("Click", (*) => Run("mailto:" T[idiomaActual]["emailAddr"]))
    
    btn := hGui.Add("Button", "y+15 w380 h30 Default", T[idiomaActual]["cerrar"])
    btn.OnEvent("Click", (*) => hGui.Destroy())
    hGui.Show()
}

RotarPDFs(modoRotacion, sufijo) {
    global LV, TxtEstado, BtnUnir, BtnRotar90, BtnRotar180, BtnRotar270, BtnSalir, BtnAyuda, idiomaActual, T
    total := LV.GetCount()
    if (total < 1)
        return MsgBox(T[idiomaActual]["errMin1"], "Aviso", "Icon!")
    enginePath := A_ScriptDir "\pdftk.exe"
    if (!FileExist(enginePath))
        return MsgBox(T[idiomaActual]["errEngine"], "Error", "Iconx")
    TxtEstado.Value := T[idiomaActual]["rotando"]
    for ctrl in [BtnUnir, BtnRotar90, BtnRotar180, BtnRotar270, BtnSalir, BtnAyuda]
        ctrl.Enabled := false
    Loop total {
        filePath := LV.GetText(A_Index, 3)
        SplitPath(filePath, , &outDir, , &outNameNoExt)
        outputFile := outDir "\" outNameNoExt sufijo ".pdf"
        if FileExist(outputFile)
            FileDelete(outputFile)
        LV.Modify(A_Index, "Col2", T[idiomaActual]["rotandoEstado"])
        RunWait(A_ComSpec ' /c ""' enginePath '" "' filePath '" cat 1-end' modoRotacion ' output "' outputFile '""', , "Hide")
        LV.Modify(A_Index, "Col2", T[idiomaActual]["rotado"])
    }
    TxtEstado.Value := T[idiomaActual]["rotacionOk"]
    MsgBox(T[idiomaActual]["rotacionMsg"], "Proceso Finalizado", "Iconi")
    for ctrl in [BtnUnir, BtnRotar90, BtnRotar180, BtnRotar270, BtnSalir, BtnAyuda]
        ctrl.Enabled := true
}

UnirPDFs(*) {
    global LV, TxtEstado, BtnUnir, BtnRotar90, BtnRotar180, BtnRotar270, BtnSalir, BtnAyuda, idiomaActual, T
    total := LV.GetCount()
    if (total < 2)
        return MsgBox(T[idiomaActual]["errMin2"], "Aviso", "Icon!")
    enginePath := A_ScriptDir "\pdftk.exe"
    if (!FileExist(enginePath))
        return MsgBox(T[idiomaActual]["errEngine"], "Error", "Iconx")
    OutputFile := FileSelect("S16", "PDF_Unido.pdf", T[idiomaActual]["guardarComo"], "PDF (*.pdf)")
    if (!OutputFile)
        return
    TxtEstado.Value := T[idiomaActual]["procesoOk"]
    for ctrl in [BtnUnir, BtnRotar90, BtnRotar180, BtnRotar270, BtnSalir, BtnAyuda]
        ctrl.Enabled := false
    Loop total
        LV.Modify(A_Index, "Col2", T[idiomaActual]["uniendo"])
    inputFiles := ""
    Loop total
        inputFiles .= ' "' LV.GetText(A_Index, 3) '"'
    if FileExist(OutputFile)
        FileDelete(OutputFile)
    RunWait(A_ComSpec ' /c ""' enginePath '"' inputFiles ' cat output "' OutputFile '""', , "Hide")
    Loop total
        LV.Modify(A_Index, "Col2", T[idiomaActual]["completado"])
    TxtEstado.Value := T[idiomaActual]["completado"]
    MostrarVentanaExito(OutputFile)
    for ctrl in [BtnUnir, BtnRotar90, BtnRotar180, BtnRotar270, BtnSalir, BtnAyuda]
        ctrl.Enabled := true
}

MostrarVentanaExito(filePath) {
    global idiomaActual, T
    eGui := Gui("+AlwaysOnTop +ToolWindow", T[idiomaActual]["finTitulo"])
    eGui.MarginX := 15, eGui.MarginY := 15
    eGui.Add("Text", "w400", T[idiomaActual]["pdfGuardado"])
    eGui.Add("Edit", "w400 r2 ReadOnly", filePath)
    btn1 := eGui.Add("Button", "w190 h35", T[idiomaActual]["abrirPdf"])
    btn2 := eGui.Add("Button", "x+20 w190 h35", T[idiomaActual]["abrirCarpeta"])
    btn1.OnEvent("Click", (*) => Run('"' filePath '"'))
    btn2.OnEvent("Click", (*) => Run('explorer.exe /select,"' filePath '"'))
    eGui.Show()
}