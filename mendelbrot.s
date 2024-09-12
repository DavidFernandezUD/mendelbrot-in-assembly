;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;; MENDELBROT SET x86-64 VISUALIZER;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
%define MAX_ITERS   4096
%define THRESHOLD   4
%define FTHRESHOLD  4.0
%define HEIGHT      32
%define WIDTH       128
%define BUF_SIZE    WIDTH * HEIGHT

global _start

section .text
_start:

        xor rdx, rdx            ; y = 0
        cmp rdx, HEIGHT
        jge .y_exit
.y_loop:
        
        xor rcx, rcx            ; x = 0
        cmp rcx, WIDTH
        jge .x_exit
.x_loop:

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;;;;;;;;; LOOP CONTENT ;;;;;;;;
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        
        ; scaled_x = ((double) x / width) * 4 - 2
        cvtsi2sd xmm0, rcx
        divsd xmm0, QWORD [width]
        mulsd xmm0, QWORD [ffour]
        subsd xmm0, QWORD [ftwo]
        
        ; scaled_y = ((double) y / height) * 2 - 1
        cvtsi2sd xmm1, rdx
        divsd xmm1, QWORD [height]
        mulsd xmm1, QWORD [ftwo]
        subsd xmm1, QWORD [fone]

        xorpd xmm2, xmm2    ; z_x = 0.0
        xorpd xmm3, xmm3    ; z_y = 0.0
        
        xor rdi, rdi        ; iter = 0

.while_loop:
        
        ; xmm4 = z_x*z_x, xmm5 = z_y*z_y
        movsd xmm4, xmm2
        mulsd xmm4, xmm4
        movsd xmm5, xmm3
        mulsd xmm5, xmm5
        
        ; xmm6 = z_x*z_x + z_y*z_y
        movsd xmm6, xmm4
        addsd xmm6, xmm5
        
        ; if (z_x*z_x + z_y*z_y > THRESHOLD) exit
        movsd xmm7, [threshold]
        ucomisd xmm6, xmm7
        ja .while_exit
        
        cmp rdi, MAX_ITERS
        jge .while_exit

        ; xtmp = z_x*z_x - z_y*z_y + scaled_x
        subsd xmm4, xmm5
        addsd xmm4, xmm0

        ; z_y = 2*z_x*z_y + scaled_y
        mulsd xmm3, xmm2
        mulsd xmm3, [ftwo]
        addsd xmm3, xmm1

        ; z_x = xtmp
        movsd xmm2, xmm4
        
        inc rdi                 ; iter++
        jmp .while_loop

.while_exit:

        cmp rdi, MAX_ITERS
        jl .skip
        
        mov rax, rdx
        imul rax, WIDTH
        add rax, rcx
        mov BYTE [buffer + rax], '*'
.skip:

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        inc rcx                 ; x++
        cmp rcx, WIDTH
        jl .x_loop              ; if (x < width) loop
.x_exit:
        
        inc rdx                 ; y++
        cmp rdx, HEIGHT
        jl .y_loop              ; if (y < height) loop
.y_exit:

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;;;;;;;;;; DRAW BUFFER ;;;;;;;;
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        mov rbx, buffer
        mov rbp, rbx
        add rbp, BUF_SIZE
.print_loop:
        cmp rbx, rbp
        jge .print_exit
        
        ; write(1, buffer, width)
        mov rax, 1
        mov rdi, 1
        mov rsi, rbx
        mov rdx, WIDTH
        syscall
        
        ; write(1, &line_break, 1)
        mov rax, 1
        mov rdi, 1
        mov rsi, line_break
        mov rdx, 1
        syscall

        add rbx, WIDTH          ; buffer += width

        jmp .print_loop
.print_exit:

        ; exit(0)
        mov rax, 60
        mov rdi, 0
        syscall

section .data

; Buffer filled with space characters
buffer:     times BUF_SIZE db ' '

; Floating point constants
height:     dq 32.0
width:      dq 128.0
ftwo:       dq 2.0
ffour:      dq 4.0
fone:       dq 1.0
threshold:  dq FTHRESHOLD

; line break
line_break: db 10

