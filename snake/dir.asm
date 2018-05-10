locals 

change_direction proc 
@@start:
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
    mov bx, snake[di]
    mov snake[di], dx
    mov snake[si], bx
    add si, 2
    sub di, 2
    cmp si,di
    jl  @@changing
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
@@checkTop:
  add bh, 1
  cmp bh, snake[2].Y
  je @@end_changing_head
@@end_changing:
    mov ah, next_direction
    mov direction, ah
    jmp @@end
@@end_changing_head:
   mov ah, direction
   mov next_direction, ah
@@end:
   ret
change_direction endp 