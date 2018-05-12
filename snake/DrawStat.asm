
include drawN.asm

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
  mov di, 38
  mov al, 0b1h
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