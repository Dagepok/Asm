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
include ints.asm
include buffer.asm
include Fruit.asm
include Draw.asm

reboot:
  int 19h

main proc 
  call isFruitAlive
  call draw
mainLoop: 
    hlt
    mov    bx, head
    cmp    bx, tail
    jz    mainLoop
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
    jmp mainLoop
@@custom_speed_lvl:
	sub al, 0Fh
	mov speed_level,al
	mov game_speed, 07h
	sub game_speed, al
	jmp mainLoop
@@custom_speed_down:
	cmp speed_level, 0
	je mainLoop
	dec speed_level
	inc game_speed
	jmp mainLoop
@@custom_speed_up:
	cmp speed_level, 6
	je mainLoop
	inc speed_level
	dec game_speed
	jmp mainLoop
@@pause:
  xor working, 1
  jmp mainLoop
@@change_next_direction:
    mov next_direction, al
    jmp mainLoop
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
  call fruit_eaten
  call isFruitAlive
  jmp draw

  @@add_size:
    add snake_size, 2
    mov al, speed_level
    inc al
    mov bl, 11
    mul bl
    add score, ax
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

GAMEOVER proc near
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
GAMEOVER endp

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