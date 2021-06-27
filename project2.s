; Brandon Cobb
; March 6, 2018
; Computer Architecture

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This program prints to the standout. It capitalizes all first letters and
; doesnt work well with punctuation. Here is sample text that you can use
; so you know that it works in at least some cases.
; *****i'd like to have lot's of useful text's*****

; The output is hard to read. It first prints the original input text. Then
; it immiidiately prints the sometimes correct output text. Then it
; immiidiately prints more random text that is stored in memory like
; "file failed to open" and stuff like that. The file didnt actually fail
; to open.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;Open Input File;;;;;;;;;;;;; 
ldr r0, =FileName
mov r1,#0
swi 0x66
bcs OpenFileFail

ldr r1,=MyFileHandle
str r0,[r1]					; file handle to memory

;;;;;;;;;;Open Output File;;;;;;;;;;;;;
ldr r0,=FileNameOutput
mov r1,#1
swi 0x66

ldr r2,=MyFileHandleOutput
str r0,[r2]

; READ STRING
ldr r1,=MyFileHandle
ldr r0,[r1]
ldr r1,=MyString
mov r2,#100
swi 0x6a					; read string

; ; PRINT INPUT TEXT
; mov r0,#1
; ldr r1,=InputText
; swi 0x69					; print string



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;CHAR COMPUTATION;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Read First Char[0] in MyString
ldr r2,=MyNewString	
ldr r1,=MyString
ldrb r5,[r1]				; load char into r5
mov r0,r5
swi 0x00					; print char
cmp r5,#97					
bmi DontUpperCaseFirstChar	; if current char is lower case (is current char < 97?) then dont change case
cmp r5,#122
bpl DontUpperCaseFirstChar	; if current char is lower case (is current char > 122?) then dont change case
sub r5,r5,#32				; make it upper case
DontUpperCaseFirstChar:		; go here if first char is upper case	
str r5,[r2]					; add new char to MyNewString
add r2,r2,#4				; increment MyNewString
add r1,r1,#1				; increment MyString

;Read chars [1]-[n]
;SET Boolean == 0
mov r7,#0					; space == false(0)

;CHECK FOR SPACE
ldrb r5,[r1]				; load char into r5
mov r0,r5
swi 0x00					; print char
cmp r5,#32
bne CheckForChar
Spaceloop:
mov r0,r5
swi 0x00					; print char
;SET Boolean == 1
mov r7,#1					; space == true(1)
str r5,[r2]					; add new char to MyNewString
add r2,r2,#4				; increment MyNewString
add r1,r1,#1				; increment MyString
ldrb r5,[r1]				; load char into r5
CheckForSpace:
mov r0,r5
swi 0x00					; print char
cmp r5,#32					; as long as char == space then restart Spaceloop, else continue
beq Spaceloop
NoSpace:

;CHECK IF END OF FILE
cmp r5,#0
beq FileEnded				; if end of file is reached then leave loop

;CHECK FOR CHAR
CheckForChar:
;ldr r1,=MyString
cmp r5,#97					
bmi DontUpperCaseChar		; if current char is lower case (is current char < 97?) then dont change case
cmp r5,#122
bpl DontUpperCaseChar		; if current char is lower case (is current char > 122?) then dont change case
;CASE CHAR
;IF R7==0
cmp r7,#0					; if r7 == 0? then skip char
beq SkipChar
;IF R7!=0
sub r5,r5,#32				; else make it upper case
;ldr r2,=MyNewString			
str r5,[r2]					; add new char to MyNewString
add r2,r2,#4				; increment MyNewString
add r1,r1,#1				; increment MyString
ldrb r5,[r1]				; load char into r5
mov r7,#0					; Now there is no previous space
bal DontSkipChar
SkipChar:
;ldr r2,=MyNewString			
str r5,[r2]					; add new char to MyNewString
add r2,r2,#4				; increment MyNewString
add r1,r1,#1				; increment MyString
ldrb r5,[r1]				; load char into r5
mov r7,#0					; Now there is no previous space
DontSkipChar:
bal CheckForSpace			; There was a char so CheckForSpace
DontUpperCaseChar:
;CASE NO CHAR

;CHECK FOR PUNC
CheckForPunctuational:
cmp r5,#65					; if char is less than 65 then CasePunc
bmi CasePunc
cmp r5,#91					; if char is less than 91 then CaseNoPunc
bmi CaseNoPunc
cmp r5,#97					; if char is less than 97 then CasePunc
bmi CasePunc
cmp r5,#122					; if char is less than 123 then CaseNoPunc
bmi CaseNoPunc
;CASE PUNC
CasePunc:
;code for punctuation case
mov r5,#45
str r5,[r2]					; insert - into MyNewString
add r2,r2,#4				; increment MyNewString
add r1,r1,#1				; increment MyString
ldrb r5,[r1]				; load char into r5
bal CheckForSpace
;CASE NO PUNC
CaseNoPunc:
mov r0,#37
swi 0x00					; print char

FileEnded:



;;;;;;;;;;;;;;;;;;; PRINT MYNEWSTRING ;;;;;;;;;;;;;;;;;;;;;;;
; PRINT OUTPUT TEXT
; mov r0,#1
; ldr r1,=OutputText
; swi 0x69					; print string

mov r0,#1
ldr r1,=MyNewString
mov r9,#0					; loop counter
PrintLoop:
swi 0x69					; print MyNewString
add r1,r1,#4				; increment MyNewString
add r9,r9,#1				; increment coutner
ldr r8,[r1]
cmp r8,#0					; if char == 0 then leave loop 
beq LeavePrintLoop
cmp r9,#100
beq LeavePrintLoop
bal PrintLoop
LeavePrintLoop:


; OUTPUT TO FILE
ldr r0,=MyFileHandleOutput
ldr r1,=MyNewString
swi 0x69


; CLOSE FILES
ldr r0,=MyFileHandle
swi 0x68
ldr r0,=MyFileHandleOutput
swi 0x68
swi 0x011

FileEmpty:					; if the file is empty...
ldr r0, =FileEmptyStr
swi 0x02
swi 0x011

OpenFileFail:
ldr r0, =OpenFileFailStr
swi 0x02
swi 0x11

MyFileHandle: .skip 4
MyFileHandleOutput: .skip 4
MyString: .skip 100
MyNewString: .skip 100
InputText: .asciz "\nInput Text:"
OutputText: .asciz "\nOutputText:"
NewLine: .asciz "    /n"
FileName: .asciz "input.txt"
FileNameOutput: .asciz "output.txt"
OpenFileFailStr: .asciz "File failed to open"
FileEmptyStr: .asciz "The file is empty"