
include random.asm

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