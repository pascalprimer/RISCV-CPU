	.org 0x0
	.globl _start

_start:
	ori x1, x0, 0xff
	sb x1, 0x108(x0)
.L0:
	sb x1, 0x108(x0)
	j .L0
