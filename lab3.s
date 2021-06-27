ldr r0,=Textfile
mov r1,#0
swi 0x66 ; open file
bcs Exit

ldr r1,=MyFileHandle

str r0,[r1] ; store file handle in memory

ldr r2,=MyInteger

; The following instructions do the same thing
mov r5,#78
mov r5,#0x4E
mov r5,#'N'

str r5,[r2] ; Store the value in memory

ldr r4,=MyFileHandle
ldr r0,[r4] ; Recall file handle from memory

ldr r1,=MyString
mov r2,#30

swi 0x6a ; read string

mov r0,#1 ; file handle 1 is standard output
ldr r1,=MyString

swi 0x69 ; print string to file

ldr r1,=Textfile
ldrb r6,[r1] ; load first character into R6

add r1,r1,#1 
ldrb r7,[r1] ; load second character into R7

add r7,r7,#1

strb r7,[r1] ; store modified character into memory

Exit:
swi 0x11

MyFileHandle: .skip 4
MyInteger: .skip 4
Textfile: .asciz "text.txt"
MyString: .skip 30