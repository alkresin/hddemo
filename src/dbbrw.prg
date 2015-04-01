
#include "hdroidgui.ch"

FUNCTION DbfBrowse()

   LOCAL oWnd, oLayV, oLayH, oBrw, oBtn1, oBtn2, cPath
   LOCAL i, arr := {"Petr","Fedor","Alexander","Viktor","Nikolay","Ivan","Anton", ;
      "Boris","Alexey","Andrey","Konstantin","Oleg","Igor","Pavel","Sergey","Mikhail","Dmitry", ;
      "Artem","Nikita","Ilya","Vladimir","Vyacheslav","Efim","Lev","Roman","Semen","Miron","Matvey","Leonid"}

   SET DATE FORMAT "dd/mm/yyyy"

   INIT WINDOW oWnd TITLE "Dbf Browse" ON EXIT {||dbCloseAll()}

   MENU
      MENUITEM "Exit" ACTION hd_calljava_s_v("finish:")
   ENDMENU

   BEGIN LAYOUT oLayV SIZE MATCH_PARENT,MATCH_PARENT

   cPath := hd_HomeDir()
   RDDSETDEFAULT( "DBFCDX" )
   IF !File( cPath+"testa.dbf" )
      dbCreate( cPath+"testa", { {"NAME","C",10,0}, {"NUM","N",4,0}, {"INFO","C",32,0}, {"DINFO","D",8,0} } )

      USE ( cPath+"testa" ) New EXCLUSIVE
      FOR i := 1 TO Len(arr)
         APPEND BLANK
         REPLACE NAME WITH arr[i], NUM WITH 1000+i, INFO WITH "Record number "+Ltrim(Str(i)), DINFO WITH Date()+i
      NEXT
   ELSE
      USE ( cPath+"testa" ) New EXCLUSIVE
   ENDIF
   GO TOP

   IF !Empty( Alias() )
      
      BROWSE oBrw DBF Alias() HSCROLL SIZE MATCH_PARENT, 0 ;
         ON CLICK {|o,n|EditRec( oBrw,.F. )}

      oBrw:nRowHeight := 40
      oBrw:nHeadHeight := 24
      oBrw:HeadBColor := "#0000CD"
      oBrw:AddColumn( HDColumn():New( {|o|(o:data)->NAME}, 120, "Name" ) )
      oBrw:AddColumn( HDColumn():New( {|o|Str((o:data)->NUM,4)}, 120, "Num" ) )
      oBrw:AddColumn( HDColumn():New( {|o|(o:data)->INFO}, 180, "Info" ) )

   ENDIF

   BEGIN LAYOUT oLayH HORIZONTAL SIZE MATCH_PARENT,WRAP_CONTENT

      BUTTON oBtn1 TEXT "Add record" SIZE 0, MATCH_PARENT ;
            ON CLICK {||EditRec( oBrw,.T. )}
      oBtn1:nMarginL := oBtn1:nMarginR := 12
      oBtn1:nMarginT := 4
      oBtn1:nMarginB := 2

   END LAYOUT oLayH

   END LAYOUT oLayV

   ACTIVATE WINDOW oWnd

   RETURN NIL

STATIC FUNCTION EditRec( oBrw,lNew )

   LOCAL oWnd, oLayV, oBtn1, oBtn2, oBtn3, oEdit1, oEdit2, oEdit3, oEdit4
   LOCAL nRec := Iif( lNew, 0, (oBrw:data)->( RecNo() ) ), lUpd := .F.

   INIT WINDOW oWnd TITLE Iif( lNew, "Add record", "Edit record" )

   BEGIN LAYOUT oLayV SIZE MATCH_PARENT,MATCH_PARENT

   EDITBOX oEdit1 HINT "Name"  TEXT Iif( lNew, "", (oBrw:data)->NAME )
   EDITBOX oEdit2 HINT "Number" TEXT Iif( lNew, "", Ltrim(Str((oBrw:data)->NUM )))
   EDITBOX oEdit3 HINT "Info" TEXT Iif( lNew, "", (oBrw:data)->INFO )
   EDITBOX oEdit4 HINT "dd/mm/yyyy" TEXT Iif( lNew, "", Dtoc((oBrw:data)->DINFO ))

   BEGIN LAYOUT oLayH HORIZONTAL SIZE MATCH_PARENT,WRAP_CONTENT

      oLayH:nMarginT := 24
      BUTTON oBtn1 TEXT Iif( lNew, "Add&Close", "Update" ) SIZE 0, MATCH_PARENT ;
            ON CLICK {||Addrec(oBrw,nRec,oEdit1,oEdit2,oEdit3,oEdit4),Iif(lNew,oBrw:Refresh(),oBrw:RefreshRow()),hd_calljava_s_v("finish:")}
      oBtn1:nMarginL := oBtn1:nMarginR := 8

      IF lNew
         BUTTON oBtn2 TEXT "Add" SIZE 0, MATCH_PARENT ;
               ON CLICK {||Addrec(oBrw,0,oEdit1,oEdit2,oEdit3,oEdit4),CleanForm(oEdit1,oEdit2,oEdit3,oEdit4),lUpd := .T.}
      ENDIF

      BUTTON oBtn3 TEXT "Close" SIZE 0, MATCH_PARENT ;
            ON CLICK {||Iif(lUpd,oBrw:Refresh(),.F.),hd_calljava_s_v("finish:")}
      oBtn3:nMarginL := oBtn3:nMarginR := 8

   END LAYOUT oLayH

   END LAYOUT oLayV

   ACTIVATE WINDOW oWnd

   RETURN NIL

STATIC FUNCTION AddRec( oBrw, nRec, oEdit1, oEdit2, oEdit3, oEdit4 )

   IF nRec == 0
      APPEND BLANK
   ELSEIF nRec != (oBrw:data)->( RecNo() )
      (oBrw:data)->( dbGoTo(nRec) )
   ENDIF
   REPLACE NAME WITH oEdit1:GetText(), NUM WITH Val( oEdit2:GetText() ), ;
      INFO WITH oEdit3:GetText(), DINFO WITH Ctod( oEdit4:GetText() )

   RETURN NIL

STATIC FUNCTION CleanForm( oEdit1, oEdit2, oEdit3, oEdit4 )

   oEdit1:SetText( "" )
   oEdit2:SetText( "" )
   oEdit3:SetText( "" )
   oEdit4:SetText( "" )

   RETURN NIL
