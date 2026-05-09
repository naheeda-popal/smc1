rpn# LC-3 RPN Calculator - Code Breakdown

This breakdown explains the LC-3 assembly code line-by-line in simple terms, following the logic of the program.

## 1. Program Startup and Welcome

START LEA R0, TITLE PUTS: Finds the "TITLE" text and prints "SMC RPN calculator" to the screen.
LEA R0, HELP1 PUTS: Prints the first line of instructions: "Enter numbers, then Space or Enter".
LEA R0, HELP2 PUTS: Prints the second instruction line: "Use + - * / to compute...".
BR RESET: Jumps to the RESET section to clear everything and get ready for work.

## 2. Setting Up the Workspace

RESET LD R6, STACK_TOP_INIT: Sets up the "Stack Pointer" (R6). Think of this as a pointer that keeps track of the top of a tray of numbers.
AND R4, R4, #0: Clears register R4. This register is the "workspace" where a number is built as you type it.
AND R5, R5, #0: Clears R5. This counts how many digits (0-9) you have typed so far.
ST R5, STACK_COUNT: Stores a "0" in the memory location that tracks how many items are currently in the stack.
SHOW_PROMPT LEA R0, PROMPT PUTS: Prints the > symbol to tell you it's your turn to type.

## 3. Reading Your Input

MAIN GETC OUT: Waits for you to press a key (GETC) and then shows that character on the screen (OUT).
READ_DIGIT ADD R2, R5, #-4 BRzp OVERFLOW_ERROR: Checks if you have already typed 4 digits. If you try to type a 5th, it jumps to an error because the number is too long.
CHECK_ENTRY (LD R1, NEG_SPACE... BRz COMMIT_ONLY): This section checks if the key you pressed was Space, Enter (LF/CR), or an operator. If it was a space or enter, it means you are finished typing that number and want to save it.

## 4. Saving Numbers (The Stack)

COMMIT_NUMBER ADD R5, R5, #0 BRz COMMIT_DONE: Checks if you actually typed any digits. If the digit count (R5) is zero, it skips this part.
JSR PUSH_R3: Takes the finished number and "pushes" it onto the stack (the memory tray).
AND R4, R4, #0 / AND R5, R5, #0: Clears the workspace (R4 and R5) so you can start typing a brand new number.
PUSH_R3: This routine calculates where the next empty spot in memory is, puts your number there, and moves the pointer (R6).

## 5. Doing the Math

When you type an operator (+, -, *, or /), the program runs these steps:
POP2: This routine "pops" (takes) the top two numbers off your stack so the calculator can work with them.
ADD_OP: Adds the two numbers together.
SUB_OP: Subtracts the numbers. It does this by turning the second number negative and then adding it to the first.
MUL_OP: Performs multiplication. Since the computer can't multiply directly, it uses a loop (MUL_LOOP) to add the first number to itself multiple times.
DIV_OP: Performs division. It uses a loop (DIV_LOOP) to see how many times the second number can be subtracted from the first.
PUSH_RESULT: Takes the answer from the math you just did and puts it back onto the stack so you can use it for the next calculation.

## 6. Showing the Result

PRINT_TOP LDR R0, R6, #0 JSR PRINT_DECIMAL: Grabs the number currently on top of the stack and starts the process of printing it.
PRINT_DECIMAL: This is a large section of code that converts the "computer version" of a number (binary) into human digits (0-9). It repeatedly divides the number by 10 to find the 1000s, 100s, 10s, and 1s places.
PD_EMIT ADD R0, R1, #0 PUTS: Finally prints the converted readable number to your screen.

## 7. Handling Errors

STACK_ERROR: Prints $ if you try to do math (like 1 +) but don't have enough numbers on the stack.
MATH_ERROR: Prints ? if you try to do something impossible, like dividing by zero.
OVERFLOW_ERROR: Prints ! if a number becomes too large for the computer to handle (greater than 32,767 or less than -32,768).