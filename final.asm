%include "/usr/local/share/csc314/asm_io.inc"

%define INDENT 13

segment .data
        title db 10,"     _                           _     _          _   ____                     _       ",10,"    / \   ___ ___  ___ _ __ ___ | |__ | | ___  __| | / ___|  ___  ___ _ __ ___| |_ ___ ",10,"   / _ \ / __/ __|/ _ \ '_ ` _ \| '_ \| |/ _ \/ _` | \___ \ / _ \/ __| '__/ _ \ __/ __|",10,"  / ___ \\__ \__ \  __/ | | | | | |_) | |  __/ (_| |  ___) |  __/ (__| | |  __/ |_\__ \",10," /_/   \_\___/___/\___|_| |_| |_|_.__/|_|\___|\__,_| |____/ \___|\___|_|  \___|\__|___/",10,10,10,0
        border db "        ****************************************",10,0
        menu db "        ENTER (1) TO START",10,0
        characterSheet db 13,27,"[36m","(i)ntelligence - %d |",27,"[35m","(p)erception - %d |",27,"[34m","(e)mpathy - %d |",10,13,27,"[32m"," (v)isualization - %d | ",27,"[33m","(c)omposure - %d | ",27,"[31m","(s)treetwise - %d | ",27,"[0m",10,13,0

        testStuff db "this sure is testing something",10,13,0
        raw_mode_on_cmd      db "stty raw -echo",0
        raw_mode_off_cmd     db "stty -raw echo",0
        newLines        db "\n\n\n\n\n\n\n\n",13,0
        clear_screen_code    db 27,"[2J",27,"[H",0
        press_space     db "Press (SPACEBAR) to continue...",10,13,0

        ;roll
        roll db 0
        rollResult db "You rolled a: %d ",10,13,0
        ;stats
        intelligence dd 1
        intColor db 27,"[36m",0

        perception dd 1
        perColor db 27,"[35m",0

        empathy dd 1
        empColor db 27,"[34m",0

        visualization dd 1
        visColor db 27,"[32m",0

        composure dd 1
        comColor db 27,"[33m",0

        streetwise dd 1
        strColor db 27,"[31m",0

        regColor db 27,"[0m",0

        ;files to read
        introduction  db "introduction.txt",0
        mainmenu      db "mainmenu.txt",0
        read          db "r",0

        kevin         db "kevin.txt",0
        irene         db "irene.txt",0
        elijah        db "elijah.txt",0
        beatrice      db "beatrice.txt",0
        donsley       db "donsley.txt",0
        edmund        db "edmund.txt",0

segment .bss

        fileString resd 500
        fileBuffer resd 6000


segment .text

        global asm_main
        global raw_mode_on
        global raw_mode_off
        global interview
        global cleanArray
        global fileStringLooper
        global print_response
        global roll_Stat
        global text_scroll

        extern puts
        extern printf
        extern system
        extern putchar
        extern getchar
        extern fopen
        extern fread
        extern fgetc
        extern fgets
        extern fclose
        extern srand
        extern rand
        extern time
        extern sleep
asm_main:
        push    ebp
        mov     ebp, esp
        ; ********** CODE STARTS HERE **********
        ;random number generation
        push 0
        call time
        add esp, 4

        push eax
        call srand
        add esp, 4
        ;print out enter screen

        push title
        call printf
        add esp, 4
        push border
        call printf
        add esp, 4
        push menu
        call printf
        add esp,4
        push border
        call printf
        add esp,4

        titleLoop:
                call read_char
        cmp eax, "1"
                jne titleLoop


        ;character creation
        call raw_mode_on ;enter raw mode to make it look nice
        mov edi, 10
        charactersheetLoop:
        push clear_screen_code ;refresh the screen
        call printf
        add esp,4

        mov esi, edi; put amount of stats remaining into counter variable
        statpointLoop:
                cmp esi, 0
                je statpointLoopEnd

                mov eax, "|"
                call print_char

                dec esi
                jmp statpointLoop
        statpointLoopEnd:
        call print_nl


        push DWORD[streetwise]
        push DWORD[composure]
        push DWORD[visualization]
        push DWORD[empathy]
        push DWORD[perception]
        push DWORD[intelligence]
        push characterSheet
        call printf
        add esp, 28


        call read_char  ;check to quit
        cmp eax, "q"
        je charactersheetLoopEnd

        cmp eax, "i"
        jne notInt
                inc DWORD[intelligence]
                dec edi
        notInt:

        cmp eax, "p"
        jne notPer
                inc DWORD[perception]
                dec edi
        notPer:

        cmp eax, "e"
        jne notEmp
                inc DWORD[empathy]
                dec edi
     notEmp:

        cmp eax, "v"
        jne notVis
                inc DWORD[visualization]
                dec edi
        notVis:

        cmp eax, "c"
        jne notCom
                inc DWORD[composure]
                dec edi
        notCom:

        cmp eax, "s"
        jne notStr
                inc DWORD[streetwise]
                dec edi
        notStr:

        ;check if edi is empty
        cmp edi, 0
        je charactersheetLoopEnd

        jmp charactersheetLoop

        charactersheetLoopEnd:

        push clear_screen_code ;refresh the screen
        call printf
        add esp,4
        push DWORD[streetwise]
        push DWORD[composure]
        push DWORD[visualization]
        push DWORD[empathy]
        push DWORD[perception]
        push DWORD[intelligence]
        push characterSheet
        call printf
        add esp, 28


        ;the game begins!
        ;eax = fopen(introduction.txt, "r");
        push read
        push introduction
        call fopen
        add esp,8
        mov edi, eax

        ;fgets(fileString, 400, eax)
        mov ebx, 500
        introLoop:


        push edi
        push ebx
       push fileString
        call fgets
        add esp, 12



        cmp eax, 0
        je introLoopEnd
;       call text_scroll
        push fileString
        call printf
        add esp,4

        mov eax, 13
        call print_char

        jmp introLoop
        introLoopEnd:
        ;fclose(introduction)
        push edi
        call fclose
        add esp, 4



        ;SPACE TO CONTINUE
        beforeMenu:
        push press_space
        call printf
        add esp,4

        call read_char
        cmp eax," "
        jne beforeMenu




        push read
        push mainmenu
        call fopen
        add esp,8
        mov edi, eax

        mainMenuLoop:
        push edi
        push ebx
        push fileString
        call fgets
        add esp, 12


        cmp eax, 0
        je mainMenuLoopEnd
        push fileString
   call printf
        add esp,4

        mov eax, 13
        call print_char

        jmp mainMenuLoop
        mainMenuLoopEnd:



        ;fclose(introduction)
        push edi
        call fclose
        add esp, 4

        getInputLooper:
        call read_char

        cmp eax, "1"
        jne notKevin
                push kevin
                call interview
                add esp,4
                push clear_screen_code
                call printf
                add esp,4
        notKevin:

        cmp eax, "2"
        jne notIrene
                push irene
                call interview
                add esp,4
                push clear_screen_code
                call printf
                add esp,4
        notIrene:
        cmp eax, "3"
        jne notElijah
                push elijah
                call interview
                add esp,4
                push clear_screen_code
                call printf
                add esp,4
        notElijah:

        cmp eax, "4"
        jne notBeatrice
                push beatrice
                call interview
                add esp,4
                push clear_screen_code
                call printf
                add esp,4
        notBeatrice:

        cmp eax, "5"
        jne notDonsley
                push donsley
                call interview
                add esp,4
                push clear_screen_code
                call printf
                add esp,4
        notDonsley:

        cmp eax, "6"
        jne notEdmund
                push edmund
                call interview
                add esp,4
                push clear_screen_code
                call printf
                add esp,4
        notEdmund:

        cmp eax, "0"
        jne beforeMenu

        call raw_mode_off








        ; *********** CODE ENDS HERE ***********
        mov             eax, 0
        mov             esp, ebp
        pop             ebp
        ret


raw_mode_on:

        push    ebp
        mov             ebp, esp

        push    raw_mode_on_cmd
        call    system
        add             esp, 4

        mov             esp, ebp
        pop             ebp
        ret

raw_mode_off:

        push    ebp
        mov             ebp, esp
      push    raw_mode_off_cmd
        call    system
        add             esp, 4

        mov             esp, ebp
        pop             ebp
        ret


interview:
        push    ebp
        mov     ebp, esp

        restart:
        sub esp, 16 ;store 4 local variables
        mov DWORD[ebp-4], 0 ;counter
        mov DWORD[ebp-8], 0 ;
        mov DWORD[ebp-12], 5000 ;buffer size
        mov DWORD[ebp-16], 1 ; buffer variable size


        ;fopen
        push read
        push DWORD[ebp+8]
        call fopen
        add esp,8
        mov edi, eax

        push eax
        push DWORD[ebp-12]
        push DWORD[ebp-16]
        push fileBuffer
        call fread
        add esp, 16

        push edi
        call fclose
        add esp, 4


        ;;takes in a string from the file with counter ecx
        mov ecx, 0

        interviewLoop:
                printInterviewLoop:
                mov ecx, DWORD[ebp-4]
                mov esi, 0
          fileStringLoop:

                 mov al, BYTE[fileBuffer+ecx]
                 cmp al, 10
                 je fileStringLoopEnd
                 mov BYTE[fileString+esi], al
                        inc ecx
                        inc esi
                        jmp fileStringLoop
                        fileStringLoopEnd:
                mov BYTE[fileString+esi], 10
                        mov BYTE[fileString+esi+1], 13
                        mov BYTE[fileString+esi+2], 0

                add ecx, 1
                mov DWORD[ebp-4],ecx

                push fileString
                call printf
                add esp, 4



                cmp BYTE[fileString+ecx],"*"
                je printInterviewLoopEnd
                jmp printInterviewLoop
                printInterviewLoopEnd:

                interviewInputLoop:
                        call read_char
                        mov BYTE[ebp-8],al

                        cmp BYTE[ebp-8], "1"
                        jne notOne
                                mov ebx, "!"
                                push ebx
                                call print_response
                                add esp, 4
                                jmp endPrintResponse
                        notOne:

                        cmp BYTE[ebp-8], "2"
                        jne notTwo
                                mov ebx, "@"
                                push ebx
                                call print_response
                                add esp, 4
                                jmp endPrintResponse

                        notTwo:

                        cmp BYTE[ebp-8], "3"
                        jne notThree
                                mov ebx, "#"
                                push ebx
                                call print_response
                                add esp, 4
                                jmp endPrintResponse
                        notThree:

                        cmp BYTE[ebp-8], "4"
                        jne notFour
                                mov ebx, "$"
                                push ebx
                                call print_response
                                add esp, 4
                                jmp endPrintResponse
                notFour:

                        cmp BYTE[ebp-8], "5"
                        jne notFive
                                mov ebx, "%"
                                push ebx
                                call print_response
                                add esp, 4
                                jmp endPrintResponse
                        notFive:

                        cmp BYTE[ebp-8], "6"
                        jne notSix
                                mov ebx, "\"
                                push ebx
                                call print_response
                                add esp, 4
                                jmp endinterviewLoop
                        notSix:

                        endPrintResponse:

                        push press_space
                        call printf
                        add esp, 4

                        call read_char

                        push clear_screen_code
                        call printf
                        add esp, 4


                        jmp restart




        endinterviewLoop:









        mov esp, ebp
        pop ebp
        ret



cleanArray:

        push ebp
  mov ebp, esp
        c1leanArrayLoop:
                cmp BYTE[fileString + ecx],10
                je c1leanArrayLoopEnd
                mov BYTE[fileString + ecx],10
                inc ecx
                jmp c1leanArrayLoop
        c1leanArrayLoopEnd:

        mov esp, ebp
        pop ebp
        ret


print_response:

        push ebp
        mov ebp, esp

        mov ebx, DWORD[ebp+8]
        mov ecx, 0



        responseLoop:
                inc ecx
                cmp bl, BYTE[fileBuffer+ecx]  ;compare the key with the current character
                jne responseLoop ;increment until we find the special character
                                ;once we find it continue to loop + print until we find it again
                        inc ecx
                        responseLoop2:
                        cmp bl, BYTE[fileBuffer+ecx] ;look for special key again
                        je responseLoopEnd ;if key is found end


                        ;key wasn't found, start checking for stat rolls
                        ;INTELLIGENCE
                                cmp BYTE[fileBuffer+ecx], "<"
                                jne StatNotInt
                                        ;roll + color

                                        push DWORD[intelligence]
                                        push intColor
                                        call roll_Stat
                                        add esp, 8

                                        cmp DWORD[roll], 10
                                        jge StatPrintInt
                                        ;if fail roll, loop through but dont print
                                        mov dl, BYTE[fileBuffer+ecx]
                                        inc ecx
                                        responseLoopInt1:
                                        cmp dl, BYTE[fileBuffer+ecx]
                                        je responseLoopIntEnd
                                        inc ecx
                                        jmp responseLoopInt1
                                        ;else we print
StatPrintInt:


                                        mov dl, BYTE[fileBuffer+ecx]
                                        inc ecx
                                        responseLoopInt:

                                        cmp dl, BYTE[fileBuffer+ecx]
                                        je responseLoopIntEnd
                                        mov al, BYTE[fileBuffer+ecx]
                                        call print_char
                                        cmp al, 10
                                        jne noNewLineInt ;append formatting to newline characters
                                        mov al, 13
                                        call print_char
                                        noNewLineInt:

                                        inc ecx
                                        jmp responseLoopInt
                                        responseLoopIntEnd:


                                        inc ecx
                                        mov eax, 13
                                        call print_char
                                        StatNotInt:

                                ;PERCEPTION
                                cmp BYTE[fileBuffer+ecx], ">"
                                jne StatNotPer
                                        ;roll
                                        push DWORD[perception]
                                        push perColor
                                        call roll_Stat
                                        add esp, 8

                                        cmp DWORD[roll],10
                                        jge StatPrintPer
                                        ;if fail loop no print
                                        mov dl, BYTE[fileBuffer+ecx]
                                        inc ecx
                                        responseLoopPer1:
                                        cmp dl, BYTE[fileBuffer+ecx]
                                        je responseLoopPerEnd
                                        inc ecx
                                        jmp responseLoopPer1
                                        ; else print
                                        StatPrintPer:
                                        mov dl, BYTE[fileBuffer+ecx]
                                        inc ecx
                                        responseLoopPer:
                                        cmp dl, BYTE[fileBuffer+ecx]
                                        je responseLoopPerEnd
                                        mov al, BYTE[fileBuffer+ecx]
                                        call print_char
                                        cmp al, 10
                                        jne noNewLinePer ;append formatting to newline characters
 mov al, 13
                                        call print_char
                                        noNewLinePer:

                                        inc ecx
                                        jmp responseLoopPer
                                        responseLoopPerEnd:
                                        inc ecx
                                        mov eax, 13
                                        call print_char
                                StatNotPer:
                                ;EMPATHY
                                cmp BYTE[fileBuffer+ecx], "^"
                                jne StatNotEmp
                                        ;roll to see
                                        push DWORD[empathy]
                                        push empColor
                                        call roll_Stat
                                        add esp, 8

                                        cmp DWORD[roll], 10
                                        jge StatPrintEmp
                                        ;if fail, loop no print
                                        mov dl, BYTE[fileBuffer+ecx]
                                        inc ecx
                                        responseLoopEmp1:
                                        cmp dl, BYTE[fileBuffer+ecx]
                                        je responseLoopEmpEnd
                                        inc ecx
                                        jmp responseLoopEmp1
                                        ;else print
                                        StatPrintEmp:
                                        mov dl, BYTE[fileBuffer+ecx]
                                        inc ecx
                                        responseLoopEmp:
                                        cmp dl, BYTE[fileBuffer+ecx]
                                        je responseLoopEmpEnd
                                        mov al, BYTE[fileBuffer+ecx]
                                        call print_char
                                        cmp al, 10
                                        jne noNewLineEmp ;append formatting to newline characters
                                        mov al, 13
                                        call print_char
                                        noNewLineEmp:

                                        inc ecx
                                        jmp responseLoopEmp
                                        responseLoopEmpEnd:
                                        inc ecx
                                        mov eax, 13
                                        call print_char
                                StatNotEmp:

                                ;VISUALIZATION
                                cmp BYTE[fileBuffer+ecx], "&"
                                jne StatNotVis
                                        ;roll to see
  push DWORD[visualization]
                                        push visColor
                                        call roll_Stat
                                        add esp, 8

                                        cmp DWORD[roll], 10
                                        jge StatPrintVis
                                        ;if fail roll, loop through but dont print
                                        mov dl, BYTE[fileBuffer+ecx]
                                        inc ecx
                                        responseLoopVis1:
                                        cmp dl, BYTE[fileBuffer+ecx]
                                        je responseLoopVisEnd
                                        inc ecx
                                        jmp responseLoopVis1
                                        StatPrintVis:
                                        ;jump if less else print
                                        mov dl, BYTE[fileBuffer+ecx]
                                        inc ecx
                                        responseLoopVis:
                                        cmp dl, BYTE[fileBuffer+ecx]
                                        je responseLoopVisEnd
                                        mov al, BYTE[fileBuffer+ecx]
                                        call print_char
                                        cmp al, 10
                                        jne noNewLineVis ;append formatting to newline characters
                                        mov al, 13
                                        call print_char
                                        noNewLineVis:

                                        inc ecx
                                        jmp responseLoopVis
                                        responseLoopVisEnd:
                                        inc ecx
                                        mov eax, 13
                                        call print_char
                                StatNotVis:
                                ;COMPOSURE
                                cmp BYTE[fileBuffer+ecx], "~"
                                jne StatNotCom
                                        ;roll to see
                                        ;roll to see
                                        push DWORD[composure]
                                        push comColor
                                        call roll_Stat
                                        add esp, 8

                                        cmp DWORD[roll], 10
                                        jge StatPrintCom
                                        ;if fail roll, loop through but dont print
                                        mov dl, BYTE[fileBuffer+ecx]
                                        inc ecx
                                        responseLoopCom1:
                                        cmp dl, BYTE[fileBuffer+ecx]
                                        je responseLoopComEnd
                                        inc ecx
                                        jmp responseLoopCom1
                StatPrintCom:
                                        ;jump if less else print
                                        mov dl, BYTE[fileBuffer+ecx]
                                        inc ecx
                                        responseLoopCom:
                                        cmp dl, BYTE[fileBuffer+ecx]
                                        je responseLoopComEnd
                                        mov al, BYTE[fileBuffer+ecx]
                                        call print_char
                                        cmp al, 10
                                        jne noNewLineCom ;append formatting to newline characters
                                        mov al, 13
                                        call print_char
                                        noNewLineCom:

                                        inc ecx
                                        jmp responseLoopCom
                                                responseLoopComEnd:
                                        inc ecx
                                        mov eax, 13
                                        call print_char
                                StatNotCom:
                                ;STREETWISE
                                cmp BYTE[fileBuffer+ecx], "|"
                                jne StatNotStr
                                        ;roll to see
                                        push DWORD[streetwise]
                                        push strColor
                                        call roll_Stat
                                        add esp, 8

                                        cmp DWORD[roll], 10
                                        jge StatPrintStr
                                        ;if fail roll, loop through but dont print
                                        mov dl, BYTE[fileBuffer+ecx]
                                        inc ecx
                                        responseLoopStr1:
                                        cmp dl, BYTE[fileBuffer+ecx]
                                        je responseLoopStrEnd
                                        inc ecx
                                        jmp responseLoopStr1
                                        StatPrintStr:

                                        ;jump if less else print
                                        mov dl, BYTE[fileBuffer+ecx]
                                        inc ecx
                                        responseLoopStr:
                                        cmp dl, BYTE[fileBuffer+ecx]
                                        je responseLoopStrEnd
                                        mov al, BYTE[fileBuffer+ecx]
                                        call print_char

                                        cmp al, 10
                                        jne noNewLineStr ;append formatting to newline characters
                                        mov al, 13
                                        call print_char
                                        noNewLineStr:

                                        inc ecx
                                        jmp responseLoopStr
                                        responseLoopStrEnd:
                                        inc ecx
                                        mov eax, 13
                                        call print_char
                                StatNotStr:

                        mov al, BYTE[fileBuffer+ecx]  ;move character
                        call print_char

                        cmp al, 10
                        jne noNewLine ;append formatting to newline characters
                                mov al, 13
                                call print_char
                        noNewLine:

                        inc ecx
                        jmp responseLoop2

                        responseLoopEnd:

                mov eax, 13
                call print_char

        mov esp, ebp
        pop ebp
        ret


roll_Stat:
        push ebp
        mov ebp, esp
        sub esp, 24 ;i hope this works
        mov DWORD[ebp-4], eax
        mov DWORD[ebp-8], ebx
        mov DWORD[ebp-12], ecx
        mov DWORD[ebp-16], edx
        mov DWORD[ebp-20], edi
        mov DWORD[ebp-20], esi

        mov edi, DWORD[ebp+12] ;stat goes into edi
        mov ebx, DWORD[ebp+8] ;color goes into ebx
        mov esi, 6 ;dice into esi
        mov DWORD[roll],0
                        ;roll 2d6
        call rand
        cdq
        div esi
        inc edx
  add DWORD[roll],edx

        call rand
        cdq
        div esi
        inc edx
        add DWORD[roll],edx

        add DWORD[roll],edi ;add stat

        mov eax, DWORD[roll]

        push ebx
        call printf
        add esp, 4
        mov eax, DWORD[roll]
        cmp eax, 10
        jl noPrint
                call print_int
                call print_nl
        noPrint:
        push regColor
        call printf
        add esp, 4


        mov eax, DWORD[ebp-4]
        mov ebx, DWORD[ebp-8]
        mov ecx, DWORD[ebp-12]
        mov edx, DWORD[ebp-16]
        mov edi, DWORD[ebp-20]
        mov esi, DWORD[ebp-24]
        mov esp, ebp
        pop ebp
        ret

;WIP
text_scroll:
        push ebp
        mov ebp, esp
        sub esp, 24 ;i hope this works
        mov DWORD[ebp-4], eax
        mov DWORD[ebp-8], ebx
        mov DWORD[ebp-12], ecx
        mov DWORD[ebp-16], edx
        mov DWORD[ebp-20], edi
        mov DWORD[ebp-20], esi

        mov eax, 1
        push eax
        call sleep
        add esp,4



        mov eax, DWORD[ebp-4]
        mov ebx, DWORD[ebp-8]
        mov ecx, DWORD[ebp-12]
        mov edx, DWORD[ebp-16]
        mov edi, DWORD[ebp-20]
        mov esi, DWORD[ebp-24]
        mov esp, ebp
        pop ebp
        ret
                                                                                                                                                                                                                                                                                                                                                                                     627,6-41      68%
                                                                                                                                                                                                                                                                                                                                                                         