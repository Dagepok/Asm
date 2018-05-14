change_direction proc 
@@start:
    call set_next_gr
    cmp direction, 1
    jg @@is_head_top
@@is_head_left:
  cmp direction, 1
  jne @@is_head_right
  cmp next_direction, 0
  je @@change_head
  jmp @@end_changing
@@is_head_right:
  cmp next_direction, 1
  je @@change_head
  jmp @@end_changing
@@is_head_top:
  cmp direction, 2
  jne @@is_head_bot
  cmp next_direction, 3
  je @@change_head
  jmp @@end_changing
@@is_head_bot:
   cmp next_direction, 2
   jne @@end_changing
    
@@change_head:
    mov si, 0
    mov di, snake_size
    sub di, 2
@@changing:
    mov dx, snake[si]
    mov ax, snake[di]
    mov snake[di], dx
    mov snake[si], ax
    add si, 2
    sub di, 2
    cmp si,di
    jl  @@changing
   
@@change_gr:
  mov di, snake_size
  sub di, 2
  shr di,1 
  xor si, si
@@changing_gr:
  mov dh, snake_gr[si]
  mov dl, snake_gr[di]
  mov snake_gr[di], dh
  mov snake_gr[si], dl
  inc si
  dec di
  cmp si, di
  jl @@changing_gr
@@compute_direction:
    mov bx, snake[0]
@@checkX:
    cmp direction, 0
    je @@checkRight

@@checkLeft:
    add bl, 2
    cmp bl, snake[2].X
    je @@end_changing_head
    jne @@check_Y
@@checkRight: 
    sub bl, 2
    cmp bl, snake[2].X
    je @@end_changing_head
    jne @@check_Y
    jmp @@end_changing_head
@@check_Y:
    cmp direction, 2
    je @@checkTop
@@checkBot:
  sub bh, 1
  cmp bh, snake[2].Y
  je @@end_changing_head
  jne @@end_changing

@@end_changing:
    mov ah, next_direction
    mov direction, ah
    jmp @@end
@@checkTop:
  add bh, 1
  cmp bh, snake[2].Y
  je @@end_changing_head
@@end_changing_head:
   mov ah, direction
   mov next_direction, ah
@@end:
   ret
change_direction endp 

set_next_gr proc
  cmp direction, 2
  jl @@left_right
@@top_bot:
    cmp next_direction, 1
    jg @@set_ver
    cmp direction, 2
    je @@top
@@bot:
    cmp next_direction, 0
    je @@set_lb
    jne @@set_rb
@@top:
    cmp next_direction, 0
    je @@set_lu
    jne @@set_ru
@@left_right:
  cmp next_direction, 1
  jle @@set_hor
  cmp direction, 0
  je @@right
@@left:
  cmp next_direction, 2
  je @@set_lb
  jne @@set_lu
@@right:
  cmp next_direction, 2
  je @@set_rb
  jne @@set_ru
@@set_hor:
  mov snake_gr[0], 0cdh
  ret
@@set_ver:
  mov snake_gr[0], 0bah
  ret
@@set_lb:
  mov snake_gr[0], 0c8h
  ret
@@set_lu:
  mov snake_gr[0], 0c9h 
  ret
@@set_ru:
  mov snake_gr[0], 0BBh
  ret
@@set_rb:
  mov snake_gr[0], 0bCH
  ret

set_next_gr endp 
