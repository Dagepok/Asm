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
	ret
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
	call ask_name
	mov si, bx
	mov di, offset dname 
	xchg di, si
	mov cx, 4
	rep movsw
	mov ax, score
	mov [di],ax
@@end:
	ret
set_current endp

ask_name proc


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
dname db '________'
score_board:
org 512h