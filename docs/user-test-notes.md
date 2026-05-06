# User Test Notes

These notes document a minimal-instruction usability pass. They can be repeated with another person during a 1:1 review.

## Test Script

Give the tester only this instruction:

> This is an RPN calculator. Enter numbers, then an operator. Use `.` to print the top value.

Ask them to try:

```text
12 3 + .
10 25 - .
7 8 * .
20 6 / .
```

## Expected Findings

- Users familiar with RPN usually try Space between values first.
- Users unfamiliar with RPN often expect `12 + 3` to work. The README examples should therefore show operands before operators clearly.
- `.` is not obvious to everyone as "print result", so the startup heading and README both call it out.
- Supporting Enter as well as Space makes the calculator easier for first-time users.

## Documentation Changes From Findings

- The README begins usage examples with full input and output.
- The startup text says to use `.` to display top of stack.
- Error prompts include a short text explanation after the required symbol.
