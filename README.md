# Simple Math Calculator (SMC)

SMC is an LC-3 Reverse Polish Notation (RPN) calculator. It accepts unsigned decimal numbers up to 4 digits, stores them on a stack, and applies operators to the top stack values.

## Features

- Numbers up to 4 digits: `0` through `9999`
- Operators: `+`, `-`, `*`, `/`
- Print command: `.` displays the top of stack without removing it
- Prompt and error symbols required by the assignment:
  - `>` ready for input
  - `?` math error, such as divide by zero
  - `$` stack error, such as too few operands
  - `!` numeric overflow, underflow, or too many digits
- Ignores unsupported characters
- Resets calculator state after any error

## Repository Layout

```text
smc-rpn-calculator/
  src/          LC-3 assembly source
  docs/         design notes, tool guidance, and user testing notes
  examples/     sample input sessions
  LICENSE       MIT license
  README.md     project overview
```

## Installation

This repository now includes a Java-based simulator at `tools/PennSim.jar`.

1. Ensure Java is installed.
2. Open `src/smc.asm` in PennSim, or run PennSim from the command line.
3. Assemble `tools/lc3tools_v12/lc3tools/lc3os.asm`.
4. Assemble `src/smc.asm`.
5. Load both object files.
6. Start the calculator at address `x3000`.

No external libraries are required.

## Included Java Tooling

- `tools/PennSim.jar`: Java LC-3 assembler/simulator
- `tools/lc3tools_v12/`: supporting LC-3 materials, including `lc3os.asm`
- `tools/pennsim-commands.txt`: scripted text-mode test harness

To run the scripted Java check used in this repository:

```text
cmd /c "java -jar tools\PennSim.jar -t < tools\pennsim-commands.txt"
```

That harness assembles the OS and calculator, loads both, starts execution at `x3000`, feeds `12 3+`, and verifies that the computed result is `15`.

## Usage

SMC uses RPN input. Enter two numbers first, then the operator.

Data entry is accepted with either `Space` or `Enter`. This choice supports both common calculator styles:

- `Space` keeps a full expression readable on one line, such as `12 3 + .`
- `Enter` feels natural when entering one number at a time

Operators also commit a pending number, so `12 3+.` works the same as `12 3 + .`.

## Examples

Add two numbers:

```text
>12 3 + .
15
```

Subtract:

```text
>10 25 - .
-15
```

Multiply:

```text
>7 8 * .
56
```

Integer division:

```text
>20 6 / .
3
```

Stack error:

```text
>9 +
$ stack error
```

Divide by zero:

```text
>9 0 /
? math error
```

Too many digits:

```text
>12345
! overflow or underflow
```

## Notes and Limitations

- Input numbers are unsigned. Negative values can be produced by subtraction and later used by operators.
- Division is integer division. The remainder is discarded.
- The stack holds 16 values.
- The program detects stack underflow, stack overflow, divide by zero, too many input digits, and arithmetic overflow.
- After an error, the stack and current number are cleared and the program returns to the `>` prompt.
- In PennSim text mode, scripted file input proved reliable for operator execution but not for automating a trailing `.` print command. Interactive use in PennSim remains the intended way to exercise `.`.

## License

This project uses the MIT License so it can be reused in educational materials with minimal restriction. See `LICENSE`.
