include drawstat

draw proc 
    call clear_screen
    mov   ax, 0b800h
    mov   es, ax
    mov   ah, 02h
    mov   al, '#'
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
    jmp end_draw
get_position:
  push ax
  mov al, cl
  mul line_lenght
  xor bh, bh
  mov bl, ch
  add ax, bx
  mov di, ax
  pop ax
  ret

end_draw:
  call draw_fruit
  mov cx, snake[0]
  xchg ch, cl
  call get_position
  mov al,'@'
  stosw
  call drawstat
  cmp is_game_over, 1
  je GAMEOVER
  jmp lop
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
draw endp