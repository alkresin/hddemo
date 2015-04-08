
#include "hdroidgui.ch"

FUNCTION HDroidMain( lFirst )

   LOCAL oWnd, oLayV, oText0, oBrw, oStyleN, oStyleP, oFont
   LOCAL aSamples := { ;
      { " Calculator", {||Calcul()} }, { " Dbf Browse", {||dbfBrowse()} }, ;
      { " Browse with checkboxes", {||ArrBrowse()} }, ;
      { " Progress dialog", {||pdDialog()} }, { " Photo", {||Photo()} }, ;
      { " Login  dialog", {||LoginDlg()} }, { " Set hrb name", {||SetMod()} }, ;
      { " External hrb module", {||ExtMod()} } ;
   }

   INIT STYLE oStyleN COLORS "#255779","#A6C0CD" ORIENT 1 CORNERS 8
   INIT STYLE oStyleP COLORS "#255779","#A6C0CD" ORIENT 6 CORNERS 8

   INIT WINDOW oWnd

   MENU
      MENUITEM "Exit" ACTION hd_MsgYesNo( "Really exit?", {|o|Iif(o:nres==1,hd_calljava_s_v("exit:"),.t.)} )
   ENDMENU
   oWnd:bBack := {|| hd_MsgYesNo( "Exit program?", {|o|Iif(o:nres==1,hd_calljava_s_v("finish:"),.t.)} ) }

   BEGIN LAYOUT oLayV SIZE MATCH_PARENT,MATCH_PARENT

   TEXTVIEW oText0 TEXT "HDroidGUI Demo" TEXTCOLOR "#FFD700" BACKCOLOR "#255779" SIZE MATCH_PARENT,32
   oText0:nAlign := ALIGN_VCENTER
   oText0:nPaddL := 10

   PREPARE FONT oFont HEIGHT 18 // STYLE FONT_BOLD
   BROWSE oBrw ARRAY aSamples SIZE MATCH_PARENT, MATCH_PARENT ;
      BACKCOLOR "#C7C7C7" FONT oFont ON CLICK {|o|Eval(o:data[o:nCurrent,2])}
   oBrw:rowTColor := 0 //"#C7C7C7" //"#FFD700"

   oBrw:nRowHeight := 56
   oBrw:oRowStyle := {oStyleN,, oStyleP}
   oBrw:AddColumn( HDColumn():New( {|o|o:data[o:nCurrent,1]},0,,,ALIGN_CENTER+ALIGN_VCENTER ) )

   END LAYOUT oLayV

   ACTIVATE WINDOW oWnd

   RETURN Nil

STATIC Function pdDialog()

   hd_Progress( @thfunc(), "Progress dialog", "Wait...",{||hd_toast("Done!")} )
   RETURN Nil

STATIC FUNCTION thfunc( oTimer )

   LOCAL nSec := Seconds()

   DO WHILE Seconds() - nSec < 4
   ENDDO
   hd_ThreadClosed( oTimer )

   RETURN Nil

STATIC Function Photo()

   LOCAL oWnd, oLayV, oBtn1, oImage, oStyleN, oStyleP
   LOCAL bExit := {||
      IF !Empty( oImage:cargo )
         hd_MsgYesNo( "Erase photo?", {|o|Iif(o:nres==1,delPhoto(oImage),.t.)} )
      ENDIF
      Return .T.
   }

   INIT STYLE oStyleN COLORS "#255779","#A6C0CD" ORIENT 1 CORNERS 8
   INIT STYLE oStyleP COLORS "#255779","#A6C0CD" ORIENT 6 CORNERS 8

   INIT WINDOW oWnd TITLE "Photo" ON EXIT bExit

   MENU
      MENUITEM "Exit" ACTION hd_calljava_s_v("finish:")
   ENDMENU

   BEGIN LAYOUT oLayV SIZE MATCH_PARENT,MATCH_PARENT

   IMAGEVIEW oImage BACKCOLOR "#C7C7C7" SIZE MATCH_PARENT,0

   BUTTON oBtn1 TEXT "Take photo" SIZE MATCH_PARENT, WRAP_CONTENT ;
         ON CLICK {||takePhoto(oImage)}
   oBtn1:oStyle := { oStyleN,,oStyleP }
   oBtn1:nMarginL := oBtn1:nMarginR := 12
   oBtn1:nMarginT := 4
   oBtn1:nMarginB := 2

   END LAYOUT oLayV

   ACTIVATE WINDOW oWnd

   RETURN Nil

STATIC Function takePhoto( oImage )

   LOCAL b1 := {|s| oImage:cargo := s, oImage:SetImage(s) }

   hd_takePhoto( ,"demo_1", b1 )

   RETURN Nil

STATIC Function delPhoto( oImage )

   FErase( oImage:cargo )
   RETURN Nil

STATIC FUNCTION LoginDlg()

   LOCAL oDlg, oEdit1, oEdit2, oEdit3, oBtnYes, oBtnNo
   LOCAL bExit := {|o|
      IF o:nRes == 1
         hd_Toast( "Login info:" + Chr(10) + o:aRes[1] + Chr(10) + o:aRes[2] + Chr(10) + o:aRes[3] )
      ENDIF
      Return .T.
   }

   INIT DIALOG oDlg TITLE "Login" ON EXIT bExit

   EDITBOX oEdit1 HINT "Server address"
   EDITBOX oEdit2 HINT "Login name"
   EDITBOX oEdit3 HINT "Password" PASSWORD

   BUTTON oBtnYes TEXT "Ok"
   BUTTON oBtnNo TEXT "Cancel"

   ACTIVATE DIALOG oDlg

   RETURN Nil

STATIC FUNCTION SetMod()

   LOCAL oDlg, oEdit1, oEdit2, oBtnYes, oBtnNo
   LOCAL cIniName := hd_HomeDir() + "hddemo.ini", hIni, csName := "HRBMOD"
   LOCAL cSection, aSect, cKey
   LOCAL cAddr := "http://kresin.ru/down/android/", cName := "hddemo_mod.hrb"
   LOCAL lSectExi := .F.

   LOCAL bExit := {|o|
      IF o:nRes == 1
         hIni[ csName ][ "addr" ] := o:aRes[1]
         hIni[ csName ][ "name" ] := o:aRes[2]
         hb_iniWrite( cIniName, hIni,,, .F. )
         hd_toast( "Saved in hddemo.ini" )
      ENDIF
      Return .T.
   }

   hIni := hb_iniRead( cIniName )
   IF Empty( hIni )
      hIni := hb_IniNew( cIniName )
   ENDIF

   FOR EACH cSection IN hIni:Keys
      IF Upper( cSection ) == csName
         lSectExi := .T.
         aSect := hIni[ cSection ]
         FOR EACH cKey IN aSect:Keys
            IF Lower( cKey ) == "addr"
               cAddr := aSect[ cKey ]
            ELSEIF Lower( cKey ) == "name"
               cName := aSect[ cKey ]
            ENDIF
         NEXT
         EXIT
      ENDIF
   NEXT

   IF !lSectExi
      hIni[ csName ] := { => }
   ENDIF

   INIT DIALOG oDlg TITLE "Hrb module" ON EXIT bExit

   EDITBOX oEdit1 HINT "Address" TEXT cAddr
   EDITBOX oEdit2 HINT "Name" TEXT cName

   BUTTON oBtnYes TEXT "Ok"
   BUTTON oBtnNo TEXT "Cancel"

   ACTIVATE DIALOG oDlg

   RETURN Nil

STATIC FUNCTION ExtMod()

   LOCAL cIniName := hd_HomeDir() + "hddemo.ini", hIni, csName := "HRBMOD"
   LOCAL cSection, aSect, cKey

   STATIC cAddr := "http://kresin.ru/down/android/", cName := "hddemo_mod.hrb"
   PUBLIC th_aData := {"","","",""}, hrbHandle, hf

   th_aData[3] := cAddr
   th_aData[4] := cName
   hIni := hb_iniRead( cIniName )
   IF !Empty( hIni )
      FOR EACH cSection IN hIni:Keys
         IF Upper( cSection ) == csName
            aSect := hIni[ cSection ]
            FOR EACH cKey IN aSect:Keys
               IF Lower( cKey ) == "addr"
                  th_aData[3] := aSect[ cKey ]
                  IF Right( th_aData[3],1 ) != "/"
                     th_aData[3] += "/"
                  ENDIF
               ELSEIF Lower( cKey ) == "name"
                  th_aData[4] := aSect[ cKey ]
               ENDIF
            NEXT
            EXIT
         ENDIF
      NEXT
   ENDIF

   IF !( cAddr == th_aData[3] ) .OR. !( cName == th_aData[4] ) .OR. Empty( m->hf )
      IF !Empty( m->hrbHandle )
         hb_hrbUnload( m->hrbHandle )
      ENDIF
      hd_Progress( @thfunc2(), "Loading Hrb", "Wait...", {||DoMod()}, th_aData )
      cAddr := th_aData[3]
      cName := th_aData[4]
   ELSE
      DoMod()
   ENDIF

   RETURN Nil

STATIC FUNCTION DoMod()

   IF !Empty( m->th_aData[1] )
      hd_toast( m->th_aData[1] )
      m->th_aData[1] := ""
   ELSE
      IF !Empty( m->th_aData[2] )
         IF !( Asc( m->th_aData[2] ) ) == 192 .OR. !( Substr( m->th_aData[2],2,3 ) == "HRB" )
            hd_toast( "Hrb is absent or broken" )
            RETURN Nil
         ENDIF
         m->hrbHandle := hb_hrbLoad( 4, m->th_aData[2] )
         m->th_aData[2] := ""
         IF !Empty( m->hrbHandle )
            m->hf := hb_hrbGetFunsym( m->hrbHandle, "FMODULE" )
         ELSE
            hd_toast( "Can't load module" )
         ENDIF
      ENDIF
      IF Empty( m->hf )
         hd_toast( "Try next time" )
      ELSE
         DO( m->hf )
      ENDIF
   ENDIF

   RETURN Nil

STATIC FUNCTION thfunc2( oTimer, th_aData )

   LOCAL oHttp

   oHttp := TIPClientHTTP():new( th_aData[3]+th_aData[4] )
   oHttp:nConnTimeout := 20000

   IF ! oHttp:open()
      th_aData[1] := "Connection error:" + Chr(10) + oHttp:lastErrorMessage()
   ELSE
      th_aData[2] := oHttp:readAll()
      IF Empty( th_aData[2] )
         th_aData[1] := "Read error" + Chr(10) + oHttp:lastErrorMessage()
      ENDIF
      oHttp:close()
   ENDIF

   hd_ThreadClosed( oTimer )

   RETURN Nil
