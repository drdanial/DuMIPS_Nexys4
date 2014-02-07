
	.text

main:		ori		$s0, $zero, 0xC000  		# set pointer to memory mapped I/O
			lw		$s2, 0($s0)					# read switches
												
			sw		$s2, 128($s0)				# display on LEDs
			
			
			lw		$s1, 8($s0)					# get the counter value
done:		
			sw		$s1, 0x84($s0)				# display the value on right most seven segment display.
			beq		$zero $zero main