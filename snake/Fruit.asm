
include random.asm

isFruitAlive proc near
    cmp fruit.X, 255
    jne @@exit

@@get_position:
    call get_random_num
    push ax
    xor ah,ah
    mov bl, 120
    div bl
    mov fruit.X, ah
    add fruit.X, 38
    test fruit.X, 1
    jz @@Y
    dec fruit.X
@@Y:
    pop ax
    xor al,al
    xchg al, ah
    mov bl, 22
    div bl
    mov fruit.Y, ah
    add fruit.Y, 1
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
    call @@check_walls
@@exit:
  ret
@@check_walls:
    mov ax, fruit
    xchg ah,al
   xor si,si
@@check:
    cmp si, 44
    je @@exit
    cmp ax, wallsleft[si]
    je @@get_position
    add si, 2
    jmp @@check
    ret
isFruitAlive endp

fruit_eaten:
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