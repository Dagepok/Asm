
_change_int9h:
    xor ax,ax
    mov ds,ax
    cli
    mov ax, offset new_int9
    mov ds:36, ax
    mov ax,cs
    mov ds:38, ax
    sti
    push cs
    pop ds
    ret
    
_change_int8h:
    cli
    xor ax, ax
    mov es, ax
    mov bx, 32
    mov ax, [es:bx]
    mov old_new_timer, ax
    mov ax, [es:bx + 2]
    mov di, offset old_new_timer
    add di, 2
    mov [di], ax
    mov [es:bx], offset new_timer
    add bx, 2
    mov [es:bx], cs
    sti
    ret

new_int9 proc
cli
    push ax
    in    al, 60h

    cmp al, 82h
    je @@set_speed_lvl
    cmp al, 83h
    je @@set_speed_lvl
    cmp al, 84h
    je @@set_speed_lvl
    cmp al, 85h
    je @@set_speed_lvl
    cmp al, 86h
    je @@set_speed_lvl
    cmp al, 87h
    je @@set_speed_lvl
    cmp al, 88h
    je @@set_speed_lvl
    cmp al, 81h
    je @@set_reboot
    cmp al, 0CDh
    je @@set_right
    cmp al, 0CBh
    je @@set_left
    cmp al, 0C8h
    je @@set_top
    cmp al, 0D0h
    je @@set_bot
    cmp al, 0b9h
    je @@set_pause
    cmp al, 08dh
    je @@set_speed_up
    cmp al, 08ch
    je @@set_speed_down
    jmp @@exit
@@set_speed_lvl:
    push ax
    sub al, 73h
    jmp @@write_to_buf
@@set_speed_up: 
    push ax
    mov al, 7
    jmp @@write_to_buf
@@set_speed_down:
    push ax
    mov al, 8
    jmp @@write_to_buf    
@@set_pause:
  push ax
  mov al,6 
  jmp @@write_to_buf
@@set_right:
  push ax
  mov al, 0
  jmp @@write_to_buf
@@set_left:
  push ax
  mov al, 1
  jmp @@write_to_buf
@@set_top:
  push ax
  mov al, 2
  jmp @@write_to_buf
@@set_bot:
  push ax
  mov al, 3
  jmp @@write_to_buf
@@set_reboot:
  push ax
  mov al, 4
  jmp @@write_to_buf

@@write_to_buf:
  call write_buf
  pop ax
  jmp @@exit

@@exit:
    in    al, 61h
    mov   ah,al
    or    al,80h    ;установить бит "подтверждения ввода"
    out   61h,al
    xchg  ah,al     ;вывести старое значение РВ
    out   61h,al
    mov   al,20h    ;послать сигнал EOI
    out   20h,al    ;контроллеру прерываний
    pop ax
  sti
  iret

new_int9 endp


new_timer proc
    cli
    push ax
    cmp working, 0
    je @@exit
    inc time_tick
    mov al, time_tick
    cmp time_tick_sec,  al
    je @@add_sec
@@add_tick:    
    inc cs:ticks_count

@@check_tick:
    mov al, game_speed
    cmp cs:ticks_count, al
    jge @@tick
    jmp @@exit
@@add_sec:
    inc seconds
    mov time_tick, 0
    jmp @@add_tick
@@tick:
    push ax
    mov al, 5
    call write_buf
    pop ax
    mov cs:ticks_count, 0
 
@@exit:
    sti
     pop ax
db 0eah
old_new_timer dw 0, 0
    
new_timer endp
