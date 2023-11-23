STSG SEGMENT PARA STACK 'STSGM'
    DW 200 DUP (?)
STSG ENDS

DTSG SEGMENT PARA 'DTSGM'
    sayilar dw 0,0,0,0,0,0,0,0,0,0
    N dw 20 ; eleman sayısı *2
    MEDYAN dw 1
    CR	EQU 13
    LF	EQU 10
    HATA	DB CR, LF, 'Dikkat !!! Sayi vermediniz yeniden giris yapiniz.!!!  ', 0
    MSG1	DB 'dizinin elenman sayisini giriniz: ',0
    MSG2	DB CR, LF, 'sayiyi giriniz: ', 0
    MSG3    DB 'dizi: ',0
    MSG4    DB '  medyan: ',0
    comma   DB ', ',0

DTSG ENDS

CDSG SEGMENT PARA 'CDSGM'
    ASSUME CS: CDSG, DS: DTSG, SS: STSG

    GETC	PROC NEAR
        ;------------------------------------------------------------------------
        ; Klavyeden basılan karakteri AL yazmacına alır ve ekranda gösterir. 
        ; işlem sonucunda sadece AL etkilenir. 
        ;------------------------------------------------------------------------
        MOV AH, 1h
        INT 21H
        RET 
GETC	ENDP 

PUTC	PROC NEAR
        ;------------------------------------------------------------------------
        ; AL yazmacındaki değeri ekranda gösterir. DL ve AH değişiyor. AX ve DX 
        ; yazmaçlarının değerleri korumak için PUSH/POP yapılır. 
        ;------------------------------------------------------------------------
        PUSH AX
        PUSH DX
        MOV DL, AL
        MOV AH,2
        INT 21H
        POP DX
        POP AX
        RET 
PUTC 	ENDP 

GETN 	PROC NEAR
        ;------------------------------------------------------------------------
        ; Klavyeden basılan sayiyi okur, sonucu AX yazmacı üzerinden dondurur. 
        ; DX: sayının işaretli olup/olmadığını belirler. 1 (+), -1 (-) demek 
        ; BL: hane bilgisini tutar 
        ; CX: okunan sayının islenmesi sırasındaki ara değeri tutar. 
        ; AL: klavyeden okunan karakteri tutar (ASCII)
        ; AX zaten dönüş değeri olarak değişmek durumundadır. Ancak diğer 
        ; yazmaçların önceki değerleri korunmalıdır. 
        ;------------------------------------------------------------------------
        PUSH BX
        PUSH CX
        PUSH DX
GETN_START:
        MOV DX, 1	                        ; sayının şimdilik + olduğunu varsayalım 
        XOR BX, BX 	                        ; okuma yapmadı Hane 0 olur. 
        XOR CX,CX	                        ; ara toplam değeri de 0’dır. 
NEW:
        CALL GETC	                        ; klavyeden ilk değeri AL’ye oku. 
        CMP AL,CR 
        JE FIN_READ	                        ; Enter tuşuna basilmiş ise okuma biter
        CMP  AL, '-'	                        ; AL ,'-' mi geldi ? 
        JNE  CTRL_NUM	                        ; gelen 0-9 arasında bir sayı mı?
NEGATIVE:
        MOV DX, -1	                        ; - basıldı ise sayı negatif, DX=-1 olur
        JMP NEW		                        ; yeni haneyi al
CTRL_NUM:
        CMP AL, '0'	                        ; sayının 0-9 arasında olduğunu kontrol et.
        JB error 
        CMP AL, '9'
        JA error		                ; değil ise HATA mesajı verilecek
        SUB AL,'0'	                        ; rakam alındı, haneyi toplama dâhil et 
        MOV BL, AL	                        ; BL’ye okunan haneyi koy 
        MOV AX, 10 	                        ; Haneyi eklerken *10 yapılacak 
        PUSH DX		                        ; MUL komutu DX’i bozar işaret için saklanmalı
        MUL CX		                        ; DX:AX = AX * CX
        POP DX		                        ; işareti geri al 
        MOV CX, AX	                        ; CX deki ara değer *10 yapıldı 
        ADD CX, BX 	                        ; okunan haneyi ara değere ekle 
        JMP NEW 		                ; klavyeden yeni basılan değeri al 
ERROR:
        MOV AX, OFFSET HATA 
        CALL PUT_STR	                        ; HATA mesajını göster 
        JMP GETN_START                          ; o ana kadar okunanları unut yeniden sayı almaya başla 
FIN_READ:
        MOV AX, CX	                        ; sonuç AX üzerinden dönecek 
        CMP DX, 1	                        ; İşarete göre sayıyı ayarlamak lazım 
        JE FIN_GETN
        NEG AX		                        ; AX = -AX
FIN_GETN:
        POP DX
        POP CX
        POP DX
        RET 
GETN 	ENDP 

PUTN 	PROC NEAR
        ;------------------------------------------------------------------------
        ; AX de bulunan sayiyi onluk tabanda hane hane yazdırır. 
        ; CX: haneleri 10’a bölerek bulacağız, CX=10 olacak
        ; DX: 32 bölmede işleme dâhil olacak. Soncu etkilemesin diye 0 olmalı 
        ;------------------------------------------------------------------------
        PUSH CX
        PUSH DX 	
        XOR DX,	DX 	                        ; DX 32 bit bölmede soncu etkilemesin diye 0 olmalı 
        PUSH DX		                        ; haneleri ASCII karakter olarak yığında saklayacağız.
                                                ; Kaç haneyi alacağımızı bilmediğimiz için yığına 0 
                                                ; değeri koyup onu alana kadar devam edelim.
        MOV CX, 10	                        ; CX = 10
        CMP AX, 0
        JGE CALC_DIGITS	
        NEG AX 		                        ; sayı negatif ise AX pozitif yapılır. 
        PUSH AX		                        ; AX sakla 
        MOV AL, '-'	                        ; işareti ekrana yazdır. 
        CALL PUTC
        POP AX		                        ; AX’i geri al 
        
CALC_DIGITS:
        DIV CX  		                ; DX:AX = AX/CX  AX = bölüm DX = kalan 
        ADD DX, '0'	                        ; kalan değerini ASCII olarak bul 
        PUSH DX		                        ; yığına sakla 
        XOR DX,DX	                        ; DX = 0
        CMP AX, 0	                        ; bölen 0 kaldı ise sayının işlenmesi bitti demek
        JNE CALC_DIGITS	                        ; işlemi tekrarla 
        
DISP_LOOP:
                                                ; yazılacak tüm haneler yığında. En anlamlı hane üstte 
                                                ; en az anlamlı hane en alta ve onu altında da 
                                                ; sona vardığımızı anlamak için konan 0 değeri var. 
        POP AX		                        ; sırayla değerleri yığından alalım
        CMP AX, 0 	                        ; AX=0 olursa sona geldik demek 
        JE END_DISP_LOOP 
        CALL PUTC 	                        ; AL deki ASCII değeri yaz
        JMP DISP_LOOP                           ; işleme devam
        
END_DISP_LOOP:
        POP DX 
        POP CX
        RET
PUTN 	ENDP 

PUT_STR	PROC NEAR
        ;------------------------------------------------------------------------
        ; AX de adresi verilen sonunda 0 olan dizgeyi karakter karakter yazdırır.
        ; BX dizgeye indis olarak kullanılır. Önceki değeri saklanmalıdır. 
        ;------------------------------------------------------------------------
	PUSH BX 
        MOV BX,	AX			        ; Adresi BX’e al 
        MOV AL, BYTE PTR [BX]	                ; AL’de ilk karakter var 
PUT_LOOP:   
        CMP AL,0		
        JE  PUT_FIN 			        ; 0 geldi ise dizge sona erdi demek
        CALL PUTC 			        ; AL’deki karakteri ekrana yazar
        INC BX 				        ; bir sonraki karaktere geç
        MOV AL, BYTE PTR [BX]
        JMP PUT_LOOP			        ; yazdırmaya devam 
PUT_FIN:
	POP BX
	RET 
PUT_STR	ENDP






    MEDYAN_HESAP PROC NEAR
        push ax
        push bx

        mov bx,4 
        ; elemanlar word tipinde olduğu için, elemansayısını 2 yerine 4'e bölmek gerekir
        mov ax, N
        xor dx, dx
        div bx ;ax/2 ile dizinin yarısına gelinir
        mov bx,2
        push dx ;mul işleminde dx'in kaybolmaması için push ve pop
        mul bx ; ax = ax*2
        pop dx
        mov SI, ax
        mov ax, sayilar[SI]
        cmp dx,0 ;dizi sayısı çift mi tek mi
        JNZ get_medyan ;tek

    cift:
        ;çiftse ax ve ax+2 ortalaması
        add ax, sayilar[SI - 2] 
        ;ax'e bir önceki eleman da eklenir ve 2'ye bölünerek ortalaması alınır
        xor dx, dx
        mov bx,2
        div bx ;ax/2
    get_medyan:
        mov MEDYAN, ax

        pop bx
        pop ax
        ret
        MEDYAN_HESAP endp
 

    GIRIS_DIZI MACRO 
        LOCAL get_num_loop

        MOV AX, OFFSET MSG1
        CALL PUT_STR    ; dizinin eleman sayisini giriniz
        CALL GETN ; eleman sayısı ax'te tutulur.
        mov cx, ax
        ;N = ax*2
        add ax, ax
        mov N, AX


        ;dizi elemanları alma
        xor SI, SI
    get_num_loop:
        MOV AX, OFFSET MSG2
        CALL PUT_STR ;sayiyi giriniz:
        CALL GETN ;girilen sayi ax'te
        mov sayilar[SI], ax
        add SI, 2
        loop get_num_loop
    ENDM


    ANA PROC FAR
        PUSH DS
        XOR AX, AX
        PUSH AX

        MOV AX, DTSG
        MOV DS, AX

        ; CODE

        GIRIS_DIZI

        ;Insertion Sort İşlemleri
        mov SI, 2
    forloop:
        mov bx, sayilar[SI] ;key değerine sakla
        mov DI, SI
        sub DI, 2 ; DI = SI - 2
    whileloop:
        cmp DI, 0
        JB end_while

        mov ax, sayilar[DI]
        cmp BX, ax
        jae end_while

        mov sayilar[DI + 2], ax
        sub DI, 2
        cmp DI, 0
        JAE whileloop

    end_while:
        mov sayilar[DI + 2], bx ; j+1. elemana key değerini koy
        add SI, 2
        cmp SI, N
        JB forloop

        call MEDYAN_HESAP

        ;MOV AX, OFFSET MSG3
        ;CALL PUT_STR    ; dizi:

        mov SI,0
    print_array:
        
        mov ax, sayilar[SI]
        call PUTN; ax'teki değeri yazdır
        MOV AX, OFFSET comma
        CALL PUT_STR    ; virgül
        
        add SI, 2
        cmp SI, N
        JB print_array

        MOV AX, OFFSET MSG4
        CALL PUT_STR    ; medyan yazdır
        mov ax, medyan
        call putn


        RETF
    ANA ENDP
CDSG ENDS

END ANA
