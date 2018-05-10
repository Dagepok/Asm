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