DuMIPS
======

MIPS VHDL implementation for the Nexys 4 board . 

This implementation is based on version for the Altera chips in James Hamblen's book, 
"Rapid Prototyping of Digital Systems."  It is a single cycle MIPS architecture with enough instructions
to make programming fairly easy (unless you want to Mulitply and Divide or work with floating point
numbers.  

The implementation is used to allow students to implement assembly code on a physical chip with 
switches, buttons, and LEDs for I/O.  

Things that are needed to be implemented yet are:

- Keyboard input
- VGA output
- Use of external memory for program code

# Small changes from Nexys2
- needed to divide system clock by 2 because 100 MHz is too fast
- there is a reset pin available on the Nexys4, but it is inverted, so needed to invert signal in top level file.  


