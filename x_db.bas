rem Xtra Basic Link Module 1.0
rem Copyright 1996 Xtra Designs
rem All rights reserved.
rem Name: X_DB.BAS - General SUBs and FUNCTIONs for database-accessing.

public xsubout$,xsubout%,xsuberr%,xsuberr$


sub xcut (a$,search$)
cutoff$=search$+"="
xsubout$=ltrim$(a$,cutoff$)
end sub



sub xdb.read.entry (file$,section$,entry$)
fileid%=freefile
open file$ for input as fileid%
xsubout%=0
section$=lcase$(section$)
entry$=lcase$(entry$)
searched$="["+section$+"]"
do
xsubout%=xsubout%+1
line input #fileid%,readed$
readed$=lcase$(readed$)
loop until readed$=searched$ or 0<> eof(fileid%)
if 0<>eof(fileid%) then goto xsub.xdb.read.entry.end
do
xsubout%=xsubout%+1
line input #fileid%,xdb1$
x=instr(xdb1$,"=")
if x=>1 then x=x-1
xdb3$=left$(xdb1$,x)
xdb3$=lcase$(xdb3$)
if xdb3$=entry$ then z=1
xdb2$=mid$(xdb1$,1,1)
y=eof(1)
if y<>0 then entry$=""
loop until xdb2$="[" or entry$="" or z=1
xsub.xdb.read.entry.end:
if not entry$="" then xsubout$=xdb1$ else xsuberr%=0001 : xsubout%=-1
if xdb2$="[" then xsuberr%=0002 : xsubout%=-2
if z=2 then xsuberr%=0003 : xsubout%=-3
close fileid%
end sub



sub xdb.change.entry (file$,section$,entry$,value$)
fileid%=freefile
oldentry$=entry$
xdb.read.entry file$,section$,entry$
entry$=oldentry$
open file$ for input as fileid%
fileid2%=freefile
open "x_db.tmp" for output as fileid2%
xsubout%=xsubout% -1
for i=1 to xsubout%
line input #fileid%,source$
print #fileid2%,source$
next i
newstring$=entry$+"="+value$
print #fileid2%,newstring$
line input #fileid%,dummy$
do until y<>0
line input #fileid%,source$
print #fileid2%,source$
y=eof(fileid%)
loop
close fileid2%
close fileid%
on error resume next
kill "backup.xdb"
name file$ as "backup.xdb"
name "x_db.tmp" as file$
end sub



sub xdb.create.section (file$,section$)
fileid%=freefile
open file$ for input as fileid%
searched$="["+section$+"]"
searched$=lcase$(searched$)
x=0
do
line input #fileid%,readed$
readed$=lcase$(readed$)
if readed$=searched$ then x=1
loop until 0<>eof(fileid%)
close fileid%
if x=1 then goto xsub.xdb.create.section.end
open file$ for input as fileid%
fileid2%=freefile
open "x_db.tmp" for output as fileid2%
xsubout%=1
do
line input #fileid%,dummy$
print #fileid2%,dummy$
'xsubout%=xsubout% + 1
loop until 0<>eof(fileid%)
fullsectionname$="["+section$+"]"
if not dummy$="" then print #fileid2%,""
print #fileid2%,fullsectionname$
print #fileid2%,""
close fileid%
close fileid2%
on error resume next
kill "backup.xdb"
name file$ as "backup.xdb"
name "x_db.tmp" as file$
xsub.xdb.create.section.end:
end sub



sub xdb.delete.section (file$,section$)
fileid%=freefile
open file$ for input as fileid%
fileid2%=freefile
open "x_db.tmp" for output as fileid2%
x=0
do
line input #fileid% ,dummy$
readed$=lcase$(dummy$)
searched$="["+section$+"]"
searched$=lcase$(searched$)
if readed$=searched$ then x=1
if x=0 then print #fileid2% ,dummy$
loop until x=1 or 0<>eof(fileid%)
x=0
do until 0<>eof(fileid%)
line input #fileid% ,dummy$
klammer$=left$(dummy$,1)
if klammer$="[" then x=1
loop until x=1 or 0<>eof(fileid%)
if x=1 then
print #fileid2%, dummy$
do until 0<>eof(fileid%)
line input #fileid% ,dummy$
print #fileid2%, dummy$
loop until 0<>eof(fileid%)
end if
close fileid%
close fileid2%
on error resume next
kill "backup.xdb"
name file$ as "backup.xdb"
name "x_db.tmp" as file$
end sub



sub xdb.create.entry (file$,section$,entry$)
fileid%=freefile
open file$ for input as fileid%
fileid2%=freefile
open "x_db.tmp" for output as fileid2%
'Search for section'
x=0
do
line input #fileid%, dummy$
readed$=lcase$(dummy$)
searched$="["+section$+"]"
searched$=lcase$(searched$)
print #fileid2%,dummy$
loop until 0<>eof(fileid%) or readed$=searched$
'Search for space after last entry and add new entry'
x=0
newentry$=entry$+"="
do until 0<>eof(fileid%)
line input #fileid%, dummy$
if dummy$="" and not x=2 then x=1
if x=0 or x=2 then print #fileid2%, dummy$
if x=1 then print #fileid2%, newentry$
if x=1 then print #fileid2%,"" : x=2
loop until 0<>eof(fileid%)
close fileid%
close fileid2%
on error resume next
kill "backup.xdb"
name file$ as "backup.xdb"
name "x_db.tmp" as file$
end sub

sub xdb.delete.entry (file$,section$,entry$)
fileid%=freefile
open file$ for input as fileid%
fileid2%=freefile
open "x_db.tmp" for output as fileid2%
'Search for section'
x=0
do
line input #fileid%, dummy$
readed$=lcase$(dummy$)
searched$="["+section$+"]"
searched$=lcase$(searched$)
print #fileid2%,dummy$
loop until 0<>eof(fileid%) or readed$=searched$
'Search for entry to be deleted'
x=0
delentry$=entry$+"="
delentry$=LCASE$(delentry$)
elength%=LEN(delentry$)
do until 0<>eof(fileid%)
line input #fileid%, dummy$
readentry$=left$(dummy$,elength%)
readentry$=LCASE$(readentry$)
klammer$=left$(readentry$,1)
if klammer$="[" then ex=1
if not delentry$=readentry$ then print #fileid2%, dummy$ : b=1
if ex=1 and b<>1 then print #fileid2%, dummy$
loop until 0<>eof(fileid%)
close fileid%
close fileid2%
on error resume next
kill "backup.xdb"
name file$ as "backup.xdb"
name "x_db.tmp" as file$
end sub

sub xdb.change.section (file$,section$,newname$)
fileid%=freefile
open file$ for input as fileid%
fileid2%=freefile
open "x_db.tmp" for output as fileid2%
'Search for section'
x=0
do
line input #fileid%, dummy$
readed$=lcase$(dummy$)
searched$="["+section$+"]"
searched$=lcase$(searched$)
if readed$=searched$ then dummy$="["+newname$+"]"
print #fileid2%,dummy$
loop until 0<>eof(fileid%)
close fileid%
close fileid2%
on error resume next
kill "backup.xdb"
name file$ as "backup.xdb"
name "x_db.tmp" as file$
end sub



sub xdb.list.section (file$,startpos%)
fileid%=freefile
open file$ for input as fileid%
'Search for section'
xsubout%=0
for i=1 to startpos%
if not 0<>eof(fileid%) then line input #fileid%, dummy$
xsubout%=xsubout%+1
next i
do until 0<>eof(fileid%)
line input #fileid%, dummy$
xsubout%=xsubout%+1
readed$=lcase$(dummy$)
readed$=left$(readed$,1)
loop until 0<>eof(fileid%) or readed$="["
if readed$="[" then xsubout$=dummy$
if 0<>eof(fileid%) then xsubout%=-1
close fileid%
end sub

sub xdb.create.database (file$,projectname$)
fileid%=freefile
open file$ for output as fileid%
print #fileid%,"[HEADER]"
print #fileid%,""
close fileid%
xdb.create.entry file$,"HEADER","fileformat"
xdb.create.entry file$,"HEADER","projectname"
xdb.create.entry file$,"HEADER","readonly"
xdb.change.entry file$,"HEADER","fileformat","XDBF2"
xdb.change.entry file$,"HEADER","projectname",projectname$
xdb.change.entry file$,"HEADER","readonly","false"
end sub


function xdb.check.exist.section% (file$,section$)
fileid%=freefile
open file$ for input as fileid%
section$=lcase$(section$)
searched$="["+section$+"]"
do
line input #fileid%, dummy$
dummy$=lcase$(dummy$)
dummy$=ltrim$(dummy$)
dummy$=rtrim$(dummy$)
if searched$=dummy$ then z=1
loop until z=1 or 0<>eof(fileid%)
if z=1 then xdb.check.exist.section%=1 else xdb.check.exist.section%=0
close fileid%
end function

function xdb.check.readonly% (file$)
xdb.read.entry file$,"HEADER","readonly"
if xsubout$="readonly=false" then xdb.check.readonly%=0 : PRINT "FALSE"
if xsubout$="readonly=true" then xdb.check.readonly%=1 : print "TRUE"
end function

sub xdb.default.entry (file$,enumber%,entryname$)
if xdb.check.exist.section(file$,"DEFAULT")=0 then xdb.create.section file$,"DEFAULT"
xdb.delete.entry file$,"DEFAULT","
end sub

rem TEST ROUTINES MUST BE WRITTEN ABOVE THIS !!!'
rem XCUT - Benîtigt fÅr Weiterverarbeitung - FERTIG
rem XDB.READ.ENTRY - Lesen des Eintrages einer Sektion - FERTIG
rem XDB.CHANGE.ENTRY - éndern eines VORHANDENEN Eintrages - FERTIG
rem XDB.CREATE.SECTION - Erstellen einer leeren Sektion - FERTIG
rem XDB.DELETE.SECTION - Lîschen einer Sektion mit ihren EintrÑgen - FERTIG
rem XDB.CREATE.ENTRY - Eintrag in einer Sektion erstellen - FERTIG
rem XDB.DELETE.ENTRY - Eintrag in einer Sektion entfernen - FERTIG
rem XDB.CHANGE.SECTION - éndern des Sektionsnamens - FERTIG
rem XDB.LIST.SECTION - Liste der Sektionen - FERTIG
rem XDB.DEFAULT.ENTRY - FÅgt StandardeintrÑge in die Sektion ein - VIELLEICHT
rem XDB.CREATE.DATABASE - Erstellt eine neue Datenbankdatei mit HEADER - FERTIG
rem XDB.CHECK.READONLY - Testet Schreibschutz der Datenbank ! - FERTIG
rem XDB.SORT.DATABASE - Sortieren der Datenbank. Sortierfolge mit Parameter
rem XDB.CHECK.EXIST.SECTION - Testen, ob SECTION vorhanden ist - FERTIG
rem 			einstellbar. Z.b. von%,bis%
rem
rem *1 Sinnvoll wenn das testen des Vorhandenseins mîglich ist, oder wenn
rem    man es fÅr eine Indexsuche nutzen kann.
