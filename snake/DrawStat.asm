
include drawN.asm

drawstat proc near
  call @@drawSeparator
  call @@drawScore
  call @@drawSpeed
  call @@drawSize
  call @@draw_time
  call @@drawGameName
  call @@drawScoreBoard
  ret
@@drawSpeed:
  mov bp, offset speed_text
  mov cx, 12
  mov dx, 0503h
  call write_string
  mov al, speed_level
  xor ah,ah
  inc al
  mov di, 832
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
  mov di, 1152
  call write_num_in_ax
  ret
@@drawScore: 
  mov bp, offset score_name
  mov cx, 6
  mov dx, 0303h
  call write_string
  mov ax, score
  mov di, 500
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
  mov di, 38
  mov al, 0b0h
  mov cx, 25
  mov dx, 158
  call @@drawSepl
  mov di, 158
  mov cx, 25
  call @@drawSepl
  ret

@@drawSepl:
  stosw
  add di, dx
  loop @@drawSepl
  ret

@@drawGameName:
  mov dx, 0104h
  mov bp, offset gamename
  mov cx, 10
  call write_string
  ret
@@drawScoreBoard:
  mov cx, 10
  mov bp, offset scn
  mov dx, 0B03h
  call write_string
  mov di, 2108
  mov bp, offset score_board - 10
   mov dx, 0B03h
  call @@drawScoreLine
  mov di, 2428
  mov dx, 0D03h
  call @@drawScoreLine
   mov di, 2748
   mov dx, 0F03h
  call @@drawScoreLine
  mov di, 3068
  mov dx, 1103h
  call @@drawScoreLine
   mov di, 3388
   mov dx, 1303h
  call @@drawScoreLine
  ret

@@drawScoreLine:
  add bp, 10
  mov cx, 8
  add dh, 2
  call write_string
  mov ax, [bp+8]
  call write_num_in_ax
  add di, 318
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

scn db 'Scoreboard'