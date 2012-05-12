#include "arm.s"

/*
 * int cas(ulong *p, ulong ov, ulong nv);
 */

TEXT	cas+0(SB),0,$12		/* r0 holds p */
TEXT	casp+0(SB),0,$12	/* r0 holds p */
	MOVW	ov+4(FP), R1
	MOVW	nv+8(FP), R2
spincas:
	LDREX(0,3)	/*	LDREX	0(R0),R3	*/
	CMP.S	R3, R1
	BNE	fail
	STREX(2,0,4)	/*	STREX	0(R0),R2,R4	*/
	CMP.S	$0, R4
	BNE	spincas
	MOVW	$1, R0
	BARRIERS
	RET
fail:
	CLREX
	MOVW	$0, R0
	RET

TEXT _xinc(SB), $0	/* void	_xinc(long *); */
TEXT ainc(SB), $0	/* long ainc(long *); */
spinainc:
	LDREX(0,3)	/*	LDREX	0(R0),R3	*/
	ADD	$1,R3
	STREX(3,0,4)	/*	STREX	0(R0),R3,R4	*/
	CMP.S	$0, R4
	BNE	spinainc
	MOVW	R3, R0
	RET

TEXT _xdec(SB), $0	/* long _xdec(long *); */
TEXT adec(SB), $0	/* long adec(long *); */
spinadec:
	LDREX(0,3)	/*	LDREX	0(R0),R3	*/
	SUB	$1,R3
	STREX(3,0,4)	/*	STREX	0(R0),R3,R4	*/
	CMP.S	$0, R4
	BNE	spinadec
	MOVW	R3, R0
	RET

TEXT loadlinked(SB), $0	/* long loadlinked(long *); */
	LDREX(0,0)	/*	LDREX	0(R0),R0	*/
	RET

TEXT storecond(SB), $0	/* int storecond(long *, long); */
	MOVW	ov+4(FP), R3
	STREX(3,0,0)	/*	STREX	0(R0),R3,R0	*/
	RSB	$1, R0
	RET
