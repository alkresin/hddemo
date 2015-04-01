
#include "hdroidgui.ch"

FUNCTION HDroidMain( lFirst )

   LOCAL oWnd, oLayV, oBrw
   LOCAL aSamples := { ;
      { " Calculator", {||Calcul()} }, { " Dbf Browse", {||dbfBrowse()} } }

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

