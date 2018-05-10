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