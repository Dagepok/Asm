include drawstat.asm


draw proc 
    call clear_screen
    mov   ax, 0b800h
    mov   es, ax
    mov   ah, 02h
    mov   al, 07h
    mov si, 0
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
    call get_position
    stosw
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
  call drawstat
  call draw_walls
   call draw_fruit
  cmp is_game_over, 1
  je @@jmp_to_gameover
  jmp mainLoop

clear_screen:
  mov ax, 0B800h
  mov di, 0
  mov es, ax
  xor ax,ax
  mov cx, 4000
  rep stosw
  ret
remove_cursor:
  mov    ah, 2
  xor    bh,bh
  mov    dx, 8126
  int    10h
  ret
@@jmp_to_gameover:
    jmp GAMEOVER
draw endp
