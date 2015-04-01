
#include "hdroidgui.ch"

FUNCTION HDroidMain( lFirst )

   LOCAL oWnd, oLayV, oBrw
   LOCAL aSamples := { ;
      { " Calculator", {||Calcul()} }, { " Dbf Browse", {||dbfBrowse()} }, ;
      { " Progress dialog", {||pdDialog()} }, { " Photo", {||Photo()} }, ;
      { " Login  dialog", {||LoginDlg()} } ;
   }

   INIT WINDOW oWnd TITLE "HDroidGUI Demo"

   MENU
      MENUITEM "Exit" ACTION hd_MsgYesNo( "Really exit?", {|o|Iif(o:nres==1,hd_calljava_s_v("exit:"),.t.)} )
   ENDMENU

   BEGIN LAYOUT oLayV SIZE MATCH_PARENT,MATCH_PARENT

   BROWSE oBrw ARRAY aSamples SIZE MATCH_PARENT, MATCH_PARENT ;
      ON CLICK {|o|Eval(o:data[o:nCurrent,2])}

   oBrw:nRowHeight := 60
   oBrw:AddColumn( HDColumn():New( {|o|o:data[o:nCurrent,1]},0 ) )

   END LAYOUT oLayV

   ACTIVATE WINDOW oWnd

   RETURN Nil

STATIC Function pdDialog()

   hd_Progress( @thfunc(), "Progress dialog", "Wait..." )
   RETURN Nil

STATIC FUNCTION thfunc( oTimer )

   LOCAL nSec := Seconds()

   DO WHILE Seconds() - nSec < 4
   ENDDO
   hd_ThreadClosed( oTimer )

   RETURN Nil

STATIC Function Photo()

   LOCAL oWnd, oLayV, oBtn1, oImage
   LOCAL bExit := {||
      IF !Empty( oImage:cargo )
         hd_MsgYesNo( "Erase photo?", {|o|Iif(o:nres==1,delPhoto(oImage),.t.)} )
      ENDIF
      Return .T.
   }

   INIT WINDOW oWnd TITLE "Photo" ON EXIT bExit

   MENU
      MENUITEM "Exit" ACTION hd_calljava_s_v("finish:")
   ENDMENU

   BEGIN LAYOUT oLayV SIZE MATCH_PARENT,MATCH_PARENT

   IMAGEVIEW oImage BACKCOLOR "#C7C7C7" SIZE MATCH_PARENT,0

   BUTTON oBtn1 TEXT "Take photo" SIZE MATCH_PARENT, WRAP_CONTENT ;
         ON CLICK {||takePhoto(oImage)}
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
