PAGE 60,80
TITLE Fibanocci


CDSG SEGMENT PARA 'CDSG'
    ORG 100H ; COM PROGRAM 100H'DEN BAŞLAR
    ASSUME CS:CDSG, SS:CDSG, DS:CDSG, ES:CDSG
    

    ANA PROC NEAR

        ;CODE
        MOV SI,0 ; prime dizi indexi
        MOV DI,0 ; notPrime dizi indexi

        mov cx, 20 ;20 sayı bulmak için for loopu 20 kez dönmeli

        mov ax, 0 
        mov bx, 1
        
generateFibanocci:
        call isPrime ; sayı prime mı
        push ax
        add ax, bx ; yeni fibanocci sayısını üret
        pop bx

        LOOP generateFibanocci


        MOV     AX,4C00H ; exit the program
        INT     21H
        ret
        RET
    ANA ENDP

    


    
    isPrime PROC NEAR
        push bx
        cmp ax, 2  
        jb notPrime ;0 ve 1 sayıları prime değildir
        je prime ; 2 primedır
        mov bx,2
        push ax
        mov dx,0
        div bx ; AX/2 işleminden kalan yoksa yani DX == 0 ise sayı asal değildir
        pop ax
        cmp dx, 0
        jz notPrime
        ;sayı 2 ile bölünmüyorsa devam
        
        mov bx, 3 ;divisor olarak görev alır

primeCheckCont: ;prime kontrolüne devam et
        cmp bx, ax
        jae prime ; divisor, sayıdan büyük eşitse sayı asaldır

        push ax
        mov dx,0
        div bx ; sayı / divisor
        pop ax
        cmp dx, 0 ;tam bölünüyorsa prime değildir
        jz notPrime
        add bx, 2 ;bölünmüyorsa divisor 2 arttırılarak devam edilir
        
        jmp primeCheckCont


prime:  
        MOV [prime_ + SI], ax ;prime dizisine ekle
        INC SI
        INC SI
        jmp endPrime

notPrime: 
        MOV [notPrime_ + DI], ax ;notPrime dizisine ekle
        INC DI
        INC DI
        
endPrime:   pop bx
            ret
isPrime endp ;bx=1 ise sayı asal, 0 ise değil
    prime_   DW 20 DUP(0) ; Asal sayılar için dizi
    notPrime_ DW 20 DUP(0) ; Asal olmayan sayılar için dizi
    num1 dw 0
    num2 dw 1
   
   
    
CDSG ENDS

    END ANA


