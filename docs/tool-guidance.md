# Tool Guidance

This project is intentionally small so another student can rebuild it from scratch.

## Recommended Tools

- LC-3 simulator: PennSim
- Text editor: VS Code, Notepad++, or any editor that preserves plain text
- Git: optional, but useful for saving versions while experimenting
- Java runtime: required for `tools/PennSim.jar`

## Build From Scratch

1. Create a project folder.
2. Create these subfolders:
   - `src`
   - `docs`
   - `examples`
3. Place the calculator assembly in `src/smc.asm`.
4. Add a `README.md` with install and usage instructions.
7. Assemble `tools/lc3tools_v12/lc3tools/lc3os.asm`.
8. Assemble `src/smc.asm`.
9. Load both object files in PennSim.
10. Set `PC` to `x3000`.
11. Run the program.

## Suggested Verification Checklist

Run these inputs in the simulator:

```text
12 3 + .
10 25 - .
7 8 * .
20 6 / .
9 +
9 0 /
12345
```

Expected behavior:

- Valid calculations print the top stack value.
- `9 +` prints `$ stack error`.
- `9 0 /` prints `? math error`.
- `12345` prints `! overflow or underflow`.
- After each error, the program clears the stack and returns to `>`.

## Implementation Notes

The assembly uses named ASCII constants instead of subtracting small immediate values from input characters. LC-3 immediates are limited to 5-bit signed values, so expressions such as `ADD R1, R0, #-48` are not legal. The program loads values such as `-48` from memory before comparing input characters.

The repository includes a text-mode PennSim harness in `tools/pennsim-commands.txt`. It is useful for repeatable arithmetic checks under Java without opening the GUI.

The calculator keeps two forms of state:

- `R4` and `R5` hold the number currently being typed and its digit count.
- `R6` and `STACK_COUNT` hold the stack pointer and number of stack items.

This makes stack error checks easier to read than comparing only memory addresses.
