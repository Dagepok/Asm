check_walls proc
	mov ax, snake[0]
	xchg ah, al
	mov si, 0
@@check:
	cmp si, 44
	je @@exit
	cmp ax, wallsleft[si]
	je @@check_dir
	add si, 2
	jmp @@check
@@check_dir:
	cmp si, 22
	jge @@right_wall
	cmp direction, 1
	je @@eat_wall
	jmp GAMEOVER
@@right_wall:
	cmp direction, 0	
	je @@eat_wall
	jmp GAMEOVER
@@eat_wall:
	mov wallsleft[si], 0FFh
@@exit:
	ret
check_walls endp


draw_walls proc
	xor si,si
	mov al, 11h
	mov bx, offset wallsleft
	call @@draw
	mov al, 10h
	mov bx, offset wallsright
	xor si,si
	call @@draw
	call @@drawTopBot
	jmp @@end
@@draw:
	cmp si, 22
	je @@ret
	mov cx, [bx+si]
 	call get_position
    stosw
    add si, 2
    jmp @@draw
@@drawTopBot:
	mov di, 38
	mov al, 0dbh
	mov cx, 61
	rep stosw
	mov di, 3878
	mov cx, 61
	rep stosw
	ret
@@ret:
    ret
@@end:
	ret	
draw_walls endp

wallsleft pos <7,80>,<8,80>,<9,80>,<10,80>,<11,80>,<12,80>, <13,80>,<14,80>,<15,80>,<16,80>,<17,80>
wallsright pos  <7,120>,<8,120>,<9,120>,<10,120>,<11,120>,<12,120>, <13,120>,<14,120>,<15,120>,<16,120>,<17,120>