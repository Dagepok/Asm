get_random_num proc
  mov   ax,[seed]             ;считать последнее случайное число
  test  ax,ax                 ;проверить его, если это -1,
  js    @@fetch_seed            ;функция ещё ни разу не вызывалась
                              ; ..и надо создать начальные значения
@@randomize:
  mul   [rand_a]              ;умножить число на а
  xor   dx,dx
  div   [rand_m]           ;взять остаток от деления 2^31-1
  mov   ax,dx
  mov   [seed],ax             ;сохранить для следующих вызовов
  ret
 
@@fetch_seed:
  push  ds 
  mov ax, 40h
  push ax
  ;push  0040h
  pop   ds
  mov   ax,word[ds:006ch]    ;считать текущее число тактов таймера
  pop   ds
  jmp   @@randomize            
 
 rand_a   dw  63621
 rand_m   dw  7fffh
 seed     dw  -1
 get_random_num endp