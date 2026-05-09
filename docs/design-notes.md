# Design Notes

## User Interface Choice

SMC accepts both Space and Enter as data-entry keys.

Space is useful when someone wants to type an entire RPN expression on one line:

```text
12 3 + .
```

Enter is useful for someone who thinks of the workflow as "type a number, press Enter":

```text
12
3
+
.
```

Both are supported because the assignment leaves the data-entry key open, and the two choices help different users without making the parser much more complex.

## Error Handling

Errors display the required prompt symbol and a short explanation:

- `$ stack error`
- `? math error`
- `! overflow or underflow`

After any error, SMC clears the current number and stack, then returns to the `>` prompt. This follows the assignment requirement that an error resets the program to the beginning.

## Arithmetic Behavior

- `+` adds the top two stack values.
- `-` subtracts the top stack value from the next stack value.
- `*` multiplies the top two stack values.
- `/` divides the next stack value by the top stack value.
- `.` displays the top stack value without popping it.

Division is integer division and discards the remainder.

## Stack

The stack is stored in local program memory and grows downward from `STACK_END`. It holds 16 values. A separate `STACK_COUNT` value is maintained so the program can reliably detect too few operands before an operation.

## Known Limits

- Input numbers cannot be negative, although operations may produce negative results.
- Input is limited to 4 digits by assignment.
- The stack capacity is fixed at 16 values.
- Arithmetic is limited by LC-3 signed 16-bit integer range.
