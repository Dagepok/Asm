.model tiny
.data
pos struc
X db ?
Y db ?
pos ends
.code
locals
org 100h
start:
    call _change_int8h
    call _change_int9h
    jmp main

include dir.asm
include random.asm

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

read_buf proc near
  mov    bx, head
  mov   al, byte ptr ds:[bx]
  inc   bx
  cmp   bx, offset bufend
  jnz   @@1
  mov   bx, offset buf
@@1:
  mov    head, bx
  ret
read_buf  endp
isFruitAlive proc near
    cmp fruit.X, 255
    jne @@exit

@@get_position:
    mov bx, seconds
    add bx, word ptr time_tick
    call get_random_num
    push ax
    xor ah,ah
    mov bl, 120
    div bl
    mov fruit.X, ah
    add fruit.X, 40
    test fruit.X, 1
    jz @@Y
    dec fruit.X
@@Y:
    pop ax
    xor al,al
    xchg al, ah
    mov bl, 24
    div bl
    mov fruit.Y, ah
    @@check_fruit:
   mov ax, fruit
   mov si, 0
@@check_next:
    mov bx, snake[si]
    cmp ax,bx 
    je @@get_position
    add si, 2
    cmp si, snake_size
    jne @@check_next
@@exit:
  ret
isFruitAlive endp

main proc near
  call isFruitAlive
  call @@draw
@@lop: 
    hlt
    mov    bx, head
    cmp    bx, tail
    jz    @@lop
    call read_buf
    cmp al, 9
    jge @@custom_speed_lvl
    cmp al, 7
    je @@custom_speed_up
    cmp al, 8 
    je @@custom_speed_down
    cmp al, 6
    je @@pause
    cmp al, 4
    je reboot
    cmp al, 5
    jl @@change_next_direction
    je @@move
    jmp @@lop
reboot:
  int 19h
@@custom_speed_lvl:
	sub al, 0Fh
	mov speed_level,al
	mov game_speed, 07h
	sub game_speed, al
	jmp @@lop
@@custom_speed_down:
	cmp speed_level, 0
	je @@lop
	dec speed_level
	inc game_speed
	jmp @@lop
@@custom_speed_up:
	cmp speed_level, 6
	je @@lop
	inc speed_level
	dec game_speed
	jmp @@lop
@@pause:
  xor working, 1
  jmp @@lop
@@change_next_direction:
    mov next_direction, al
    jmp @@lop
@@move:
  call @@speed_up
  call change_direction
  inc moves_count
  mov ah, moves_count
  cmp ah, moves_per_up
  jne @@move_it
  call @@add_size
  mov moves_count, 0
@@move_it:
  mov bx, snake_size  ;индекс последнего
  mov si, snake_size  ;индекс предпоследнего
  sub si, 2
  mov al, direction
  cmp al, 2 
  jl @@left_right
@@up_down:
      cmp al, 3
      je @@down
@@up:
    mov cx, snake[si]
    mov snake[bx], cx
    sub si, 2
    sub bx, 2
    cmp bx, 0  
    jne @@up
    dec snake[0].Y
    jmp @@check_poses
@@down:
   mov cx, snake[si]
    mov snake[bx], cx
    sub si, 2
    sub bx, 2
    cmp bx, 0  
    jne @@down
    inc snake[0].Y
    jmp @@check_poses
@@left_right:
    cmp al, 0
    jne @@left
   
@@right:
    mov cx, snake[si]
    mov snake[bx], cx
    sub si, 2
    sub bx, 2
    cmp bx, 0  
    jne @@right
    add snake[0].X, 2
    jmp @@check_poses
@@left:
    mov cx, snake[si]
    mov snake[bx], cx
    sub si, 2
    sub bx, 2
    cmp bx, 0  
    jne @@left
    sub snake[0].X, 2
    jmp @@check_poses
@@end_check_pos:
  call @@fruit_eaten
  call isFruitAlive
  jmp @@draw

  @@add_size:
    add snake_size, 2
    mov al, speed_level
    inc al
    mov bl, 11
    mul bl
    add score, ax

    ret 
@@fruit_eaten:
    mov ax, fruit
    cmp snake[0].X, al 
    jne @@not_eaten
    cmp snake[0].Y, ah
    jne @@not_eaten
    mov fruit.X, 255
    add snake_size, 2
    mov ax, 3
    mov bl, speed_level
    add bl, 2
    mul bl
    add score, ax
@@not_eaten:
    ret
@@check_poses:
    call @@check_crossing
    xor si,si
    @@check_pos:
      cmp si, snake_size
        je @@end_check_pos
      call @@check_line
      call @@check_col
      add si, 2
    jmp @@check_pos
@@check_line:
    mov al, snake[si].X
    call @@check1
    mov snake[si].X, al
    ret
@@check1:
    cmp al, 40
    je @@set_max_line
    cmp al, 160
    je @@set_min_line
    ret
@@set_min_line:
    mov al, 42
    ret
@@set_max_line:
    mov al, 158
    ret
@@check_col:
    mov al, snake[si].Y
    call @@check2
    mov snake[si].Y, al
    ret
@@check2:
    cmp al, -1
    je @@set_max_col
    cmp al, 25
    je @@set_min_col
    ret
@@set_min_col:
    xor al,al
    ret
@@set_max_col:
    mov al, 24
    ret
@@draw:
    call @@clear_screen
    mov   ax, 0b800h
    mov   es, ax
    mov   ah, 02h
    mov   al, '#'
    mov si, 0
    jmp @@drawpos
@@draw_fruit:
  mov al, '*'
  mov ch, fruit.X
  mov cl, fruit.Y
  call @@get_position
  stosw
  ret
@@drawpos:
    cmp si, snake_size
    je @@end_draw
    mov ch, snake[si].X
    mov cl, snake[si].Y
    call @@get_position
    stosw
    add si, 2
    jmp @@drawpos
    jmp @@end_draw
@@get_position:
  push ax
  mov al, cl
  mul line_lenght
  xor bh, bh
  mov bl, ch
  add ax, bx
  mov di, ax
  pop ax
  ret

@@end_draw:
  call @@draw_fruit
  mov cx, snake[0]
  xchg ch, cl
  call @@get_position
  mov al,'@'
  stosw
  call drawstat
  cmp is_game_over, 1
  je GAMEOVER
  jmp @@lop
@@clear_screen:
  mov ax, 0B800h
  mov di, 0
  mov es, ax
  xor ax,ax
  mov cx, 4000
  rep stosw
   ret

@@remove_cursor:
  mov    ah, 2
  xor    bh,bh
  mov    dx, 8126
  int    10h
  ret
@@speed_up:
  cmp speed_level, 6
  je @@end_speed_up
  mov ax, snake_size
  mov bl, speed_up_size
  div bl
  test ah,ah
  jnz @@change_upped
  cmp speed_upped, 1
  je @@end_speed_up
  mov speed_upped, 1
  inc speed_level
  dec game_speed
@@end_speed_up:
  ret
@@change_upped:
	mov speed_upped, 0
	jmp @@end_speed_up
@@check_crossing:
    mov ax, snake[0]
    mov si, 2
@@check_next:
    mov bx, snake[si]
    cmp ax,bx 
    je GAMEOVER
    add si, 2
    cmp si, snake_size
    jne @@check_next
    ret
main endp

GAMEOVER:
  mov is_game_over, 1
  hlt
  mov    bx, head
  cmp    bx, tail
  jz    GAMEOVER
  mov bp, offset game_over
  mov cx, 9 
  mov dx, 0B28h
  push es
  push cs
  pop es
  mov ax, 1300h
  mov bx, 0004h
  int 10h
  pop es
  call read_buf
  cmp al, 4
  jne GAMEOVER
  jmp reboot

drawstat proc near
  call @@drawSeparator
  call @@drawScore
  call @@drawSpeed
  call @@drawSize
  call @@draw_time
  call @@drawGameName
  ret
@@drawSpeed:
  mov bp, offset speed_text
  mov cx, 12
  mov dx, 0503h
  call write_string
  mov al, speed_level
  xor ah,ah
  inc al
  mov di, 834
  call write_num_in_ax
  ret
@@drawSize:
  mov bp, offset size_text
  mov cx, 11
  mov dx, 0703h
  call write_string
  mov ax, snake_size
  mov bl, 2
  div bl
  xor ah,ah
  mov di, 1154
  call write_num_in_ax
  ret
@@drawScore: 
  mov bp, offset score_name
  mov cx, 6
  mov dx, 0303h
  call write_string
  mov ax, score
  mov di, 502
  call write_num_in_ax
  ret
@@draw_time:
  mov bp, offset time
  mov cx, 5
  mov dx, 0903h
  call write_string
  mov ax, seconds
  mov di, 1460
  call write_num_in_ax
  ret
@@drawSeparator:
  mov di, 40
  mov al, 0DDh
  mov cx, 25
  mov dx, 158
@@drawSep:
  stosw
  add di, dx
  loop @@drawSep
  ret
@@drawGameName:
  mov dx, 0104h
  mov bp, offset gamename
  mov cx, 10
  call write_string
  ret
write_string: ;в cx - длина строки, в bp - offset строки dx - позиция
  push ax
  push es
  push cs
  pop es
  mov ax, 1300h
  mov bx, 0002h
  int 10h
  pop es
  pop ax
  ret
drawstat endp

buf db 15 dup(0)
bufend:
head dw offset buf
tail dw offset buf
write_buf   proc near
  push   di
  push   bx
  push   bp
  mov   di, cs:tail
  mov   bx, di
  inc    di
  cmp   di, offset bufend
  jnz   @@1
  mov   di, offset buf
@@1:  
  mov   bp, di
  cmp   di, cs:head
  jz    @@9
  mov   di, bx
  mov    byte ptr cs:[di], al ;процедура записи
  mov   cs:tail, bp
@@9:
  pop   bp
  pop   bx
  pop   di
  ret
write_buf   endp

new_int9 proc near
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

write_num_in_ax proc near ;ax - number, di - position to draw
  mov bx, 10 
  xor cx, cx 
@@div: 
  xor dx, dx 
  div bx 
  push dx 
  inc cx 
  cmp ax, 0 
  jne @@div
@@print_char:
  pop ax
  add al, '0' 
  mov ah, 02h
  dec cx 
  stosw
  cmp cx, 0 
  je @@finish 
jmp @@print_char
@@finish:
 ret
write_num_in_ax endp



new_timer proc near
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

working db 1
time_tick db 0
ticks_count db 0
time_tick_sec db 18
moves_per_up db 20
moves_count db 0 
game_speed db 7
speed_level db 0
line_lenght db 160
column_lenght db 24
next_direction db 0
direction db 0  ;0 - вправо, 1  - влево, 2 - вверх, 3 - вниз
score dw 0
seconds dw 0
gamename db 'SUPERSNAKE'
score_name db 'Score:'
time db 'Time:'
size_text db 'Snake size:'
speed_text db 'Speed level:'
game_over db 'GAME OVER'
is_game_over db 0
fruit pos <255,255>
speed_up_size db 12
speed_upped db 0
snake_size dw 8 ;Указывается в 2 раза больше(реальное значение = snake_size/2)
snake pos <82,10>, <80, 10>,<78, 10>,<76, 10>
end start