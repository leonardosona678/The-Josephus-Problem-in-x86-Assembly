dis macro xxx
    push dx
    push ax
    mov dx,offset xxx
    mov ah,9
    int 21h
    pop ax
    pop dx
endm
PILA SEGMENT STACK 'STACK'
    DB 64 dup('STACK')
PILA ENDS

DATI SEGMENT PUBLIC 'DATA'
    CR EQU 13
    LF EQU 10
    DOLLAR EQU '$'
    crlf db CR,LF,DOLLAR
originalstring db "What I cannot create, I do not understand."
n equ $-originalstring
k equ 22
temporitorno db 1 dup(0)
legge_permutazioni db n dup(?)  , DOLLAR
temp1 db n dup(?),DOLLAR
temp2 db n dup(?), DOLLAR
messaggio1 db "Lunghezza della stringa = ", DOLLAR
messcaratteri db " caratteri" ,DOLLAR
messaggio2 db "Passo decimazione (Josephus) = ",DOLLAR
messaggio3 db "Tempo di ritorno = ",DOLLAR
messpermutazioni db " permutazioni",DOLLAR
messaggio5 db "Numero di invarianze = ",DOLLAR
messaggio6 db " indici: ",DOLLAR
stampa db 1 dup(?),DOLLAR
indici db n dup(?), DOLLAR  
n_invarianze db 1 dup(?), DOLLAR
dati ends

CSEG1 SEGMENT PUBLIC 'CODE'
ASSUME CS:CSEG1,DS:DATI,SS:PILA,ES:NOTHING
; ---------------------------------------------------------
; PROCEDURA: STAMPA_LEGGE
; Stampa contenuto dell'array "legge_permutazioni"
; come sequenza di numeri decimali separati da spazi.
; ---------------------------------------------------------
STAMPA_LEGGE PROC NEAR
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI

    ; Stampo un messaggio di testa 
    MOV DL, 13      ; CR
    MOV AH, 2     ; comando per stampare un solo carattere (Carriage return o line feed in questo caso)
    INT 21H
    MOV DL, 10      ; LF
    MOV AH, 2
    INT 21H
    
    
    XOR SI, SI      ; Indice array (parte da 0)
    XOR CX, CX      ;pulisco cx
    MOV CL, n       ; Carico la lunghezza (n) nel contatore
                    
                     

STAMPA_CICLO:
    XOR AX, AX
    MOV AL, legge_permutazioni[SI]  ; Carico il valore (l'indice)
    
    ; --- Conversione in Decimale (AL -> ASCII) ---
    MOV BL, 10
    DIV BL          ; AL = Decine, AH = UnitÃ . Quoziente=decine, resto=unità
    
    MOV DX, AX      ; Salvo il risultato in DX (DH=unita, DL=decine)
    
    ; Controllo se c'e la decina (es. numero >= 10)
    CMP DL, 0
    JE STAMPA_UNITA ; Se decina Ã¨ 0, salto e stampo solo unitÃ 
    
    ADD DL, 30h     ; Converto 
    MOV AH, 02h
    INT 21H
    
STAMPA_UNITA:
    ; Stampa UnitÃ 
    MOV DL, DH      ; Recupero le unitÃ   perchè per stampare ho bisogno che il carattere sia in DL
    ADD DL, 30h     ; Converto in ASCII
    MOV AH, 02h
    INT 21H
    
    ; --- Stampa Separatore (spazio) ---
    MOV DL, ' '     ; Spazio
    MOV AH, 02h
    INT 21H

    INC SI          ; Incremento indice array
    LOOP STAMPA_CICLO ; Decrementa CX e va a stampa_ciclo se non zero

    ; Ritorno a capo finale
    MOV DL, 13
    MOV AH, 2
    INT 21H
    MOV DL, 10
    MOV AH, 2
    INT 21H

    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
STAMPA_LEGGE ENDP
 stampa_ascii proc near

    xor dx,dx
    mov ax,cx
    mov bx,10
    div bx
    add dx,'0'  ; il quoziente va in ax, il resto in dx, perchè avendo diviso per bx
    add ax,'0'  ; facciamo unna divisione estesa che utilizz la coppia ax, dx
    mov stampa[0],al ; decina
    dis stampa
    mov stampa[0],dl
    dis stampa       ; unità(resto)
    ret
    stampa_ascii endp

MAIN PROC FAR
    mov ax,DATI
    mov ds,ax

    ;copio in temp1 originalstring per il calcolo della legge
    mov si,offset originalstring ; puntatore alla stringa orig
    mov di,offset temp1 ; scorre su temp1
    mov cl,n ;contatore
    riempitemp1:
    mov al, [si]    ;uso al e non ax perchè [si] e [di] rappr. un byte (8 bit), e creo meno confusione 
    mov [di], al
    inc si
    inc di
    dec cl
    jnz riempitemp1

    ; calcolo la legge di permutazione
    xor si,si ; 
    sub si,1     ; si parte da -1
    xor di,di ;
    permutazione:
    
    mov ch,k ; ch contiene k

   loopstringa:
    inc si
    cmp si, n           ; Controllo fine stringa
    jl controllo_usato
    xor si, si          ; Se arrivo a n, ricomincio da 0 

controllo_usato:
    mov al, temp1[si]
    cmp al, '-'         ; Se è un trattino, non lo contare
    je loopstringa           ; Salta e riprova con il prossimo SI
    
    dec ch              ; Ho trovato un carattere valido, decremento CH
    jnz loopstringa          ; Se non ho finito i k passi, continua a cercare

    ; --- ELEMENTO TROVATO ---
    mov bx, si
    mov legge_permutazioni[di], bl ; Salvo l'indice
    mov temp1[si], '-'             ; Segno come usato
    inc di
    cmp di, n           
    jl permutazione     
    exit:
    call stampa_legge     
    ;PAUSA (solo per vedere meglio l'output)
    mov ah,08h
    int 21h
    
    ;-- CALCOLO INVARIANZE
    xor si, si 
    xor di, di
    mov n_invarianze, 0
    mov cx, n
    
   calcolo_invarianze:     
    xor ax, ax ; pulisco ax per eventuali problemi di compilazione  
    mov al, legge_permutazioni[si] 
    cmp ax, si
    jne incremento 
    mov indici[di],al
    inc di
    inc n_invarianze
    
    incremento:
    inc si
    dec cx 
    jnz calcolo_invarianze   ; (potevo risparmiare codice con "loop calcolo_invarianze"




    ; ricopio originalstring in temp1
    mov si,offset originalstring ; puntatore alla stringa original
    mov di,offset temp1 ; scorre su temp1
    mov cl,n ;contatore
    riempitemp1_ancora: ; la ri-riempio perche temp1 e dventata una stringa di "-"
    mov al, [si]
    mov [di], al
    inc si
    inc di
    dec cl
    jnz riempitemp1_ancora


    ; ho la legge di permutazione, che uso come lookup table
    ; in temp2 calcolo la permutazione della stringa partendo da temp1
    ; uso temp1 come stringa per confrontare con originalstring
    xor bh,bh

    crea_nuova_stringa:

    xor si,si; si scorre sia su temp2 che su legge_permutazione 
    ; cotruisco temp2
    


    costruisci_temp2:
    mov bl,legge_permutazioni[si]
    mov al,temp1[bx]
    mov temp2[si],al
    inc si
    cmp si,n
    jl costruisci_temp2
    inc temporitorno ; increento il tempo di ritorno
   
    ; ricopio temp2 in temp1
    xor di,di 
    costruisci_temp1:
    mov al,temp2[di]
    mov temp1[di],al
    inc di
    cmp di,n
    jl costruisci_temp1
    
    dis crlf 
    dis temp1

    
    ; confronto temp1 con orig
    xor si,si 
    confronto:
    mov al,temp1[si]
    mov ah,originalstring[si]
    cmp al,ah
    je incrementa
    jmp crea_nuova_stringa
    incrementa:
    inc si
    cmp si,n
    jl confronto
   
   dis crlf 
   dis messaggio1
   mov cx,n
   call stampa_ascii  ; ha bisogno del numero da stampare in cx
   dis messcaratteri
   dis crlf
   dis messaggio2
   mov cx,k
   call stampa_ascii
   dis messcaratteri 
   dis crlf
   dis messaggio3
   mov cl,temporitorno
   xor ch,ch
   call stampa_ascii
   dis messpermutazioni
   dis crlf       
   ; --- STAMPA NUMERO INVARIANZE ---
    dis messaggio5          ; 
    mov cl, n_invarianze    ; Carico il numero trovato
    xor ch, ch              ; Azzero CH per sicurezza (stampa_ascii usa CX)
    call stampa_ascii       
    dis crlf                  
    
    ; --- STAMPA LISTA INDICI ---
    mov cl, n_invarianze    ; Uso il numero di invarianze come contatore del ciclo
    xor ch, ch
    cmp cx, 0               
    je fine_stampa_indici

    dis messaggio6          ; " indici: "
    xor si, si              ; SI punta al primo elemento di 'indici'

ciclo_stampa_indici:
    push cx                 ; SALVO CX: stampa_ascii lo modificherebbe rovinando il loop
    
    mov al, indici[si]      ; Prendo l'indice salvato
    mov cl, al              ; Lo metto in CL per la procedura
    xor ch, ch              ;pulisco ch per sicurezza
    call stampa_ascii       ; Stampa l'indice

    ; Stampa uno spazio tra un numero e l'altro
    mov dl, ' '
    mov ah, 02h
    int 21h

    pop cx                  ; RECUPERO CX originale per il loop
    inc si                  ; Prossimo indice nell'array
    dec cx
    jnz ciclo_stampa_indici ; per questiultimi 2 comandi, bastava usare loop
    

fine_stampa_indici:
    dis crlf
    



    
   

   




 MOV AH,4CH
    INT 21H
MAIN ENDP
CSEG1 ENDS
END MAIN
    




