; Simple Math Calculator (SMC)
; LC-3 Reverse Polish Notation calculator
;
; Input model:
;   - Type unsigned decimal integers up to 4 digits.
;   - End a number with Space, Enter, or an operator.
;   - Supported operators: + - * / .
;   - Any other input character is ignored after echoing.
;
; Prompt meanings:
;   > ready for input
;   ? math error, such as divide by zero
;   $ stack error, such as too few operands
;   ! numeric overflow, underflow, or too many digits

        .ORIG x3000

START
        LEA R0, TITLE
        PUTS
        LEA R0, HELP1
        PUTS
        LEA R0, HELP2
        PUTS
        BR RESET

TITLE           .STRINGZ "SMC RPN calculator\n"
HELP1           .STRINGZ "Enter numbers, then Space or Enter.\n"
HELP2           .STRINGZ "Use + - * / to compute. . also displays TOS.\n"
PROMPT          .STRINGZ ">"

NEG_ASCII_0     .FILL #-48
NEG_ASCII_9     .FILL #-57
NEG_SPACE       .FILL #-32
NEG_LF          .FILL #-10
NEG_CR          .FILL #-13
NEG_PLUS        .FILL #-43
NEG_MINUS       .FILL #-45
NEG_STAR        .FILL #-42
NEG_SLASH       .FILL #-47
NEG_DOT         .FILL #-46

RESET
        LD R6, STACK_TOP_INIT
        AND R4, R4, #0          ; current number being typed
        AND R5, R5, #0          ; current digit count
        ST R5, STACK_COUNT
        BR SHOW_PROMPT

SHOW_PROMPT
        LEA R0, PROMPT
        PUTS

MAIN
        GETC
        OUT

        ; Is it a decimal digit?
        LD R1, NEG_ASCII_0
        ADD R1, R0, R1          ; R1 = char - '0'
        BRn CHECK_ENTRY
        LD R2, NEG_ASCII_9
        ADD R2, R0, R2          ; char - '9'
        BRp CHECK_ENTRY

READ_DIGIT
        ADD R2, R5, #-4
        BRzp OVERFLOW_ERROR

        ; R4 = R4 * 10 + R1
        ADD R2, R4, R4          ; 2x
        ADD R3, R2, R2          ; 4x
        ADD R3, R3, R3          ; 8x
        ADD R2, R2, R3          ; 10x
        ADD R4, R2, R1
        ADD R5, R5, #1
        BR MAIN

CHECK_ENTRY
        ; Space, LF, or CR commits the current number to the stack.
        LD R1, NEG_SPACE
        ADD R1, R0, R1
        BRz COMMIT_ONLY
        LD R1, NEG_LF
        ADD R1, R0, R1
        BRz COMMIT_ONLY
        LD R1, NEG_CR
        ADD R1, R0, R1
        BRz COMMIT_ONLY

        ; Operators also commit the current number first.
        JSR COMMIT_NUMBER

        LD R1, NEG_PLUS
        ADD R1, R0, R1
        BRz ADD_OP
        LD R1, NEG_MINUS
        ADD R1, R0, R1
        BRz SUB_OP
        LD R1, NEG_STAR
        ADD R1, R0, R1
        BRz MUL_OP
        LD R1, NEG_SLASH
        ADD R1, R0, R1
        BRz DIV_OP
        LD R1, NEG_DOT
        ADD R1, R0, R1
        BRz PRINT_TOP
        BR MAIN

COMMIT_ONLY
        JSR COMMIT_NUMBER
        BR MAIN

; If digits are pending, push R4 and clear the number buffer.
COMMIT_NUMBER
        ADD R5, R5, #0
        BRz COMMIT_DONE
        ADD R3, R4, #0
        ST R7, COMMIT_SAVE_R7
        JSR PUSH_R3
        LD R7, COMMIT_SAVE_R7
        AND R4, R4, #0
        AND R5, R5, #0
COMMIT_DONE
        RET

COMMIT_SAVE_R7  .BLKW #1

; Push R3 onto the stack.
PUSH_R3
        LD R1, STACK_BASE_ADDR
        NOT R1, R1
        ADD R1, R1, #1
        ADD R1, R6, R1          ; R6 - STACK_BASE
        BRz STACK_ERROR

        ADD R6, R6, #-1
        STR R3, R6, #0
        LD R1, STACK_COUNT
        ADD R1, R1, #1
        ST R1, STACK_COUNT
        RET

; Pop two operands.
; Returns R1 = right operand/TOS, R2 = left operand/next stack item.
POP2
        LD R3, STACK_COUNT
        ADD R3, R3, #-2
        BRn STACK_ERROR

        LDR R1, R6, #0
        ADD R6, R6, #1
        LDR R2, R6, #0
        ADD R6, R6, #1

        LD R3, STACK_COUNT
        ADD R3, R3, #-2
        ST R3, STACK_COUNT
        RET

STACK_TOP_INIT  .FILL STACK_END
STACK_BASE_ADDR .FILL STACK_BASE
STACK_COUNT     .BLKW #1
STACK_BASE      .BLKW #16
STACK_END

ADD_OP
        JSR POP2
        ADD R3, R2, R1

        ; Overflow when operands have the same sign but result differs.
        ADD R0, R1, #0
        BRn ADD_RIGHT_NEG
        ADD R0, R2, #0
        BRn PUSH_RESULT
        ADD R0, R3, #0
        BRn OVERFLOW_ERROR
        BR PUSH_RESULT
ADD_RIGHT_NEG
        ADD R0, R2, #0
        BRzp PUSH_RESULT
        ADD R0, R3, #0
        BRzp OVERFLOW_ERROR
        BR PUSH_RESULT

SUB_OP
        JSR POP2                ; R3 = R2 - R1
        NOT R3, R1
        ADD R3, R3, #1
        ADD R3, R2, R3

        ; Overflow when operands have different signs and result sign
        ; differs from the left operand.
        ADD R0, R2, #0
        BRn SUB_LEFT_NEG
        ADD R0, R1, #0
        BRzp PUSH_RESULT
        ADD R0, R3, #0
        BRn OVERFLOW_ERROR
        BR PUSH_RESULT
SUB_LEFT_NEG
        ADD R0, R1, #0
        BRn PUSH_RESULT
        ADD R0, R3, #0
        BRzp OVERFLOW_ERROR
        BR PUSH_RESULT

MUL_OP
        JSR POP2
        AND R0, R0, #0          ; sign flag, 1 means negative result

        ADD R1, R1, #0
        BRzp MUL_RIGHT_POS
        NOT R1, R1
        ADD R1, R1, #1
        BRn OVERFLOW_ERROR
        ADD R0, R0, #1
MUL_RIGHT_POS
        ADD R2, R2, #0
        BRzp MUL_LEFT_POS
        NOT R2, R2
        ADD R2, R2, #1
        BRn OVERFLOW_ERROR
        ADD R0, R0, #1
MUL_LEFT_POS
        AND R3, R3, #0
MUL_LOOP
        ADD R2, R2, #0
        BRz MUL_SIGN
        ADD R3, R3, R1
        BRn OVERFLOW_ERROR      ; positive + positive wrapped
        ADD R2, R2, #-1
        BR MUL_LOOP
MUL_SIGN
        ADD R0, R0, #-1
        BRnp PUSH_RESULT        ; sign flag was 0 or 2
        NOT R3, R3
        ADD R3, R3, #1
        BR PUSH_RESULT

DIV_OP
        JSR POP2
        ADD R1, R1, #0
        BRz MATH_ERROR
        AND R0, R0, #0          ; sign flag

        ADD R1, R1, #0
        BRzp DIV_RIGHT_POS
        NOT R1, R1
        ADD R1, R1, #1
        BRn OVERFLOW_ERROR
        ADD R0, R0, #1
DIV_RIGHT_POS
        ADD R2, R2, #0
        BRzp DIV_LEFT_POS
        NOT R2, R2
        ADD R2, R2, #1
        BRn OVERFLOW_ERROR
        ADD R0, R0, #1
DIV_LEFT_POS
        AND R3, R3, #0
DIV_LOOP
        NOT R4, R1
        ADD R4, R4, #1
        ADD R4, R2, R4
        BRn DIV_SIGN
        ADD R2, R4, #0
        ADD R3, R3, #1
        BR DIV_LOOP
DIV_SIGN
        ADD R0, R0, #-1
        BRnp PUSH_RESULT
        NOT R3, R3
        ADD R3, R3, #1
        BR PUSH_RESULT

PUSH_RESULT
        JSR PUSH_R3
        AND R4, R4, #0
        AND R5, R5, #0
        BR PRINT_TOP

PRINT_TOP
        LD R1, STACK_COUNT
        BRz STACK_ERROR
        LDR R0, R6, #0
        JSR PRINT_DECIMAL
        LD R0, ASCII_LF
        OUT
        BR SHOW_PROMPT

STACK_ERROR
        LEA R0, STACK_MSG
        PUTS
        BR RESET

MATH_ERROR
        LEA R0, MATH_MSG
        PUTS
        BR RESET

OVERFLOW_ERROR
        LEA R0, OVER_MSG
        PUTS
        BR RESET

STACK_MSG       .STRINGZ "$ stack error\n"
MATH_MSG        .STRINGZ "? math error\n"
OVER_MSG        .STRINGZ "! overflow or underflow\n"

; Print signed decimal integer in R0.
PRINT_DECIMAL
        ST R0, SAVE_R0
        ST R1, SAVE_R1
        ST R2, SAVE_R2
        ST R3, SAVE_R3
        ST R4, SAVE_R4
        ST R5, SAVE_R5
        ST R7, SAVE_R7

        LEA R1, PRINT_BUF
        ADD R1, R1, #7
        AND R2, R2, #0
        STR R2, R1, #0          ; NUL terminator
        ADD R3, R0, #0
        AND R5, R5, #0          ; sign flag
        ADD R3, R3, #0
        BRnp PD_NONZERO

        ADD R1, R1, #-1
        LD R2, ASCII_0
        STR R2, R1, #0
        BR PD_EMIT

PD_NONZERO
        BRzp PD_ABS_READY
        ADD R5, R5, #1
        LD R2, MIN_INT
        ADD R2, R3, R2
        BRz PD_MIN_INT
        NOT R3, R3
        ADD R3, R3, #1

PD_ABS_READY
PD_DIGIT_LOOP
        AND R4, R4, #0          ; quotient
        ADD R2, R3, #0          ; working remainder
PD_DIV10_LOOP
        ADD R0, R2, #-10
        BRn PD_STORE_DIGIT
        ADD R2, R2, #-10
        ADD R4, R4, #1
        BRnzp PD_DIV10_LOOP

PD_STORE_DIGIT
        ADD R1, R1, #-1
        LD R0, ASCII_0
        ADD R0, R0, R2
        STR R0, R1, #0
        ADD R3, R4, #0
        BRp PD_DIGIT_LOOP
        ADD R5, R5, #0
        BRz PD_EMIT
        ADD R1, R1, #-1
        LD R0, ASCII_MINUS
        STR R0, R1, #0
        BR PD_EMIT

PD_MIN_INT
        LEA R0, MIN_INT_MSG
        PUTS
        BR PD_DONE

PD_EMIT
        ADD R0, R1, #0
        PUTS

PD_DONE
        LD R0, SAVE_R0
        LD R1, SAVE_R1
        LD R2, SAVE_R2
        LD R3, SAVE_R3
        LD R4, SAVE_R4
        LD R5, SAVE_R5
        LD R7, SAVE_R7
        RET
ASCII_0         .FILL x0030
ASCII_LF        .FILL x000A
ASCII_MINUS     .FILL x002D
MIN_INT         .FILL x8000
MIN_INT_MSG     .STRINGZ "-32768"
PRINT_BUF       .BLKW #8
SAVE_R0         .BLKW #1
SAVE_R1         .BLKW #1
SAVE_R2         .BLKW #1
SAVE_R3         .BLKW #1
SAVE_R4         .BLKW #1
SAVE_R5         .BLKW #1
SAVE_R7         .BLKW #1

        .END
