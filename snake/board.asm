board_pos struc
Nam db 8 dup(0)
Point dw ? 
board_pos ends

write_score proc
	push es 
	push cs
	pop es
	call set_current
	xor dx, dx
	mov cx, 0101h
	mov ax, 0301h
	mov bx, offset score_board
	int 13h
	pop es
	jmp draw
write_score endp

set_current proc
	mov si, 8
	mov ax, score
@@findPos:
	mov bx, [offset score_board+si]
	cmp ax,bx 
	jg @@set
	add si, 10
	cmp si, 58
	jge @@end
	jmp @@findPos
@@set:
	mov bx, si
	sub bx, 8
	mov si, 38
	mov di, 48
	add bx, offset score_board
	add si, offset score_board
	add di, offset score_board
	std 
@@let_down_string:
    movsw
	cmp si, bx
	jge @@let_down_string
	cld
	push bx
	call ask_name
	pop bx
	mov si, bx
	mov di, offset dname 
	xchg di, si
	mov cx, 4
	rep movsw
	mov ax, score
	mov [di],ax
@@end:
	mov is_asking_name, 0
	mov score_added, 1
	ret
	
set_current endp

ask_name proc
 	push es
  	push cs
  	pop es
	mov bp, offset uname
	mov dx, 0D25h
	mov cx, 16
	mov ax, 1300h
	mov bx, 0007h
	int 10h
	pop es
	mov  is_asking_name, 1
	xor si,si
	mov di, 2190
	mov ah, 07h
@@ask_lop:	
	hlt 
    mov    bx, head
    cmp    bx, tail
    jz    @@ask_lop
    call read_buf
    cmp al, 9ch
    je @@enter
    cmp al, 8eh
    je @@backspace
    cmp al, 90h
    jl @@ask_lop
    cmp al, 0B4h
    jg @@ask_lop
    jmp @@add_letter
@@enter:
	ret
@@backspace:
	test si,si
	jz @@ask_lop
	dec si
	sub di, 2
	mov al, ' '
	push es
	mov dx, 0b800h
	mov es, dx
	stosw
	sub di, 2
	pop es
	mov dname[si], al
	jmp @@ask_lop
@@add_letter:
	cmp si, 8
	je @@ask_lop
	mov bx, offset alphabet
	sub al, 90h
	xlat
	cmp al, '.'
	je @@ask_lop
	mov dname[si], al
	push es
	mov dx, 0b800h
	mov es, dx
	stosw
	inc si
	pop es
	jmp @@ask_lop

ask_name endp


read_score proc 
	push es 
	push cs
	pop es
	xor dx, dx
	mov cx, 0101h
	mov ax, 0201h
	mov bx, offset score_board
	int 13h
	pop es
	ret
@@error:
	jmp GAMEOVER
read_score endp
is_asking_name db 0
dname db '        '
uname db 'Write your name:'
alphabet db 'QWERTYUIOP{}..ASDFGHJKL:"...ZXCVBNM<>?'
score_board:
org 512h