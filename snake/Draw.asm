include drawstat.asm


draw proc 

    call clear_1page
    mov   ax, 0b800h
    mov   es, ax
    mov   ah, 02h
    ;mov   al, 07h
    mov si, 0
    mov bx, 0
    jmp drawpos
draw_fruit:
  mov al, '*'
  mov ch, fruit.X
  mov cl, fruit.Y
  call get_position
  stosw
  ret

drawpos:
    cmp si, snake_size
    je end_draw
    mov ch, snake[si].X
    mov cl, snake[si].Y
    mov al, snake_gr[bx]
    call get_position
    stosw
    inc bx 
    add si, 2
    jmp drawpos
get_position:
  push ax
  push cx
  push bx
  mov al, cl
  mul line_lenght
  xor bh, bh
  mov bl, ch
  add ax, bx
  mov di, ax
  pop bx
  pop cx
  pop ax
  ret

end_draw:
  mov cx, snake[0]
  xchg ch, cl
  call get_position
  mov al,02h
  stosw
  call drawportal
  call drawstat
  call draw_walls
  call draw_fruit
  call rewrite_screen
  cmp is_game_over, 1
  je @@jmp_to_gameover
  jmp mainLoop

rewrite_screen:
  push es
  push ds
  mov cx, page_size
  mov di, cx 
  xor si, si
  cld 
  mov ax, 0B800h 
  mov es, ax
  mov ds, ax
  rep movsb
  pop ds
  pop es
  ret
clear_1page:
  push es
  xor di, di
  mov cx ,page_size
  mov ax, 0B800h
  mov es, ax
  xor ax,ax
  rep stosb
  pop es
  ret
remove_cursor:
  mov    ah, 02h
  mov    bh, 01h
  mov    dx, 8126
  int    10h
  ret
drawportal:
  push  es
  mov ax, 0B800h
  mov es, ax
  mov ax, 0240h
  mov di, portal1
  stosw
  mov di, portal2
  stosw
  mov al, '#'
  mov di, portal3
  stosw
  mov di, portal4
  stosw
  pop es
  ret 

@@jmp_to_gameover:
    jmp GAMEOVER
draw endp

page_size dw 4096
portal1 dw 900
portal2 dw 3100
portal3 dw 1010
portal4 dw 3660