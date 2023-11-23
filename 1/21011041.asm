STSG SEGMENT PARA STACK 'STSGM'
	DW 20 DUP (?)
STSG ENDS

DTSG SEGMENT PARA 'DTSGM'
	kilo dw 82,62,64,86 
    boy dw 160,172,179,182
    VKI dw 0,0,0,0
    
DTSG ENDS
							
CDSG SEGMENT PARA 'CDSGM'
	ASSUME CS: CDSG, DS: DTSG, SS: STSG
	
	ANA PROC FAR
        ;EXE tipi için gerekli kodlar
		PUSH DS
		XOR AX, AX
		PUSH AX
						
		MOV AX, DTSG
		MOV DS, AX
		
		;vücut kitle endeksi hesaplama algoritması
        	XOR SI, SI	
			mov cx, 4 ;hesaplanacak 4 değer olduğu için loop 4 kez döndürülmeli
			mov bx, 100 ;cm->m dönüştürmesi için 100 ile çarpılır
				
    calculate_vki:	
    ;hesap kısmında taşma olmaması için sırasıyla:
    ;kilo değeri 100 ile çarpılır ve boy değerine bölünür
    ;elde edilen değer tekrar 100 ile çarpılır ve boy değerine bölünür.
			xor ax, ax
			MOV AX, [kilo + si] ;kilo değerleri AX'e alınır.
            mul bx ;100 ile çarpma
            div [boy + si] ;sonuç boy değerlerine bölünür
            mul bx
            div [boy + si]
			inc ax
			mov [VKI + si], AX ;hesaplanan değeri VKI dizisine aktar
	
			add si, 2; SI'ya 2 eklenerek bir sonraki değere geçilir.
			loop calculate_vki 

        ; selection sort
		MOV CX, 4 ; Dizi boyutu
		XOR SI, SI ; SI'yi sıfırla

		sort:
			MOV DI, SI ; DI'yi SI ile başlat
			MOV AX, [VKI + DI] ; AX'e VKI değeri atanır.
			MOV BX, DI ; BX'i maksimum değerin dizindeki indeksi olarak işaretle

			inner_loop:
				ADD DI, 2 ; sonraki VKI değeri
				CMP DI, 8 ; Dizinin sonuna gelip gelmmediğinin kontrolü
				JAE max_deger

				CMP AX, [VKI + DI]
				JA inner_loop ;  AX büyükse swap yok
				MOV AX, [VKI + DI]
				MOV BX, DI
				JMP inner_loop


			max_deger:
				; Maksimum değeri en başa taşı
				MOV DX, [VKI + SI]
				MOV [VKI + SI], AX
				MOV [VKI + BX], DX

				ADD SI, 2
				CMP SI, 6 ;dizi sonuna gelindi mi
				JB sort

		done:
		RETF
	ANA ENDP 


CDSG ENDS

	END ANA