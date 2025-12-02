MACHINE:	EQU	1	; "AL80"
;MACHINE:	EQU	2	; "MintZ80"

OFFSET	EQU	2400h	; offset of memory start for the program. Originally 0

; VTL2.ASM
; ------------
;
; MITS VTL-2 -- A Very Tiny Language for the Altair 8800
; by Frank McCoy, Copyright 1976, 2007
; Version 3.0
;
;
CASSTS	EQU	6	; Cassette Status
CASSTD	EQU	7	; Cassette Data

UART_BASE:	EQU 008h         ; Base port address, P8250A/USART uses 8 ports.
UART0:       EQU    UART_BASE+00h			;Data in/out
UART1:       EQU    UART_BASE+01h            	;Check RX
UART2:       EQU    UART_BASE+02h            	;Interrupts
UART3:       EQU    UART_BASE+03h            	;Line control
UART4:       EQU    UART_BASE+04h            	;Modem control
UART5:       EQU    UART_BASE+05h            	;Line status
UART6:       EQU    UART_BASE+06h            	;Modem status
UART7:       EQU    UART_BASE+07h            	;Scratch register		

SIO_BASE:	EQU 018h			; SIO port
SIO_DA:	EQU SIO_BASE
SIO_CA:	EQU SIO_BASE+1
SIO_DB:	EQU SIO_BASE+2
SIO_CB:	EQU SIO_BASE+3

;--------------------------------
; MITS Altair or Imsai 8800 I/O ports used:
; If your system has one of these board's I/O addressed at a
; non-standard location, then just change the appropriate
; definition of the three below; and reassemble the program.
;
;SIOBRD	EQU	0	; MITS Single-SIO board usually Port-0
;SIO2BRD	EQU	16	; MITS Dual-SIO board usually Ports-16 & 18
;PTPLUSS	EQU	0	; Processor-Technology 3P+S board at Port-0
;
;
; The bits input from the SENSE switches are defined as follows:
;    00000000B
;        | ||
;        | ||    0 = MITS SIO  board at Port-0  (Default)
;        | |+----1 = MITS 2SIO board at Port-16
;        | +-----2 = Processor-Technology 3P+S board at Port-0
;        +-------8 = MITS 2SIO board at Port-18
;
; The bits are tested in-order, right-to-left
; 2SIO at 16 first 3P+S second, 2SIO at 18 third.
; If none of the three bits are set, then is MITS SIO board.
; The odd grouping is for compatibility with MITS software;
; Specifically MITS BASIC.
;
; Thus default (00H) assumes a single MITS SIO board at port-0
;
;SENSE	EQU	0FFH	; Sense-Switches at 0xFF on Altair 8800
;
; From above, we get the following:
;
;SIOS	EQU	SIOBRD	; MITS Single SIO board Status
;SIOD	EQU	SIOS+1	; MITS Single SIO board Data
;
;SIOS0	EQU	SIO2BRD	; MITS 2SIO Board Lower Status
;SIOD0	EQU	SIOS0+1	; MITS 2SIO Board Lower Data
;SIOS1	EQU	SIOS0+2	; MITS 2SIO Board Upper Status
;SIOD1	EQU	SIOS1+1	; MITS 2SIO Board Upper Data
;
;PTSS	EQU	PTPLUSS	; Processor-Technology 3P+S Serial Status
;PTSD	EQU	PTSS+1	; Processor-Technology 3P+S Serial Data
;
;
; I/0 byte equates:
;
CLEAR	EQU	01H	; Clear 2SIO boards
INTCI	EQU	11H	; Sets clock and interupts on 2SIO boards
;
;--------------------------------
; ASCII characters used (ASR-33 Teletype).
;
CTRLC	EQU	03H	; Abort key (Control-C)
LF	EQU	0AH	; Line-Feed
CR	EQU	0DH	; Carriage-Return

;--------------------------------
;       Buffer area
;-------------------------------- (SV = System Variable)
;-------------------------------- (GV = Usable Variable)
;
	ORG	0000H+OFFSET	; Bottom of memory
BRKPNT	DS	0	; Address of RST 0
RST0:		DS	8	; Restarts
RST1:		DS	8	;
RST2:		DS	8	;
RST3:		DS	8	;
RST4:		DS	8	;
RST5:		DS	8	;
RST6:		DS	8	;
RST7:		DS	8	;
AT:		DS	2	; SV: Usable storage since '@' not allowed
VARS:		DS	52	; Variables A - Z (26 variables)
BRAK:		DS	2	; [
SLISH:	DS	2	; \
BRIK:		DS	2	; ]
UP:		DS	2	; ^ SV: Number of terminal option running
LINPTR:	DS	2	; _ SV: Current line-pointer save
SPAC:		DS	2	;   GV: Space
EXCLAM:	DS	2	;   SV: RETURN pointer (Excalmation-Point)
QUOTE:	DS	2	; "
NUMBR:	DS	2	; # SV: Line-Number
DOLLAR	DS	2	; $ SV: Character pointer
PERCNT:	DS	2	; % SV: Remainder after divide
AMPERS:	DS	2	; & SV: Next byte past user program - Array start
QUITE:	DS	2	; ' SV: Random Number
PAREN:	DS	2	; ( SV: Not used
PARIN:	DS	2	; ) SV: Not used
STAR:		DS	2	; * SV: Next byte past user program (Array area)
PLUS:		DS	2	; + GV: General Purpose variable
COMMA:	DS	2	; , SV: Number of nulls after each cr/lf
MINUS:	DS	2	; - GV: General Purpose variable
PERIOD:	DS	2	; . SV: Terminal echo switch
SLASH:	DS	2	;   SV: General Purpose variable
;
EVALPT:	DS	2	; 0 Eval pointer
SV1:		DS	2	; 1 SV: Not used
SV2:		DS	2	; 2 SV: Not used
SV3:		DS	2	; 3 SV: Not used
SV4:		DS	2	; 4 SV: Not used
SV5:		DS	2	; 5 SV: Not used
RESULT:	DS	2	; 6 SV: Result of expression evaluation
LINUMB:	DS	2	; 7 SV: Line number
CURENT:	DS	2	; 8 SV: Current line number
VALVAR:	DS	2	; 9 SV: Value of variable?
;
COLN:		DS	2	; : GV: General purpose variable
SEMI		DS	2	; ; GV: General Purpose variable
LESS:		DS	2	; < GV: General Purpose variable
EQAL:		DS	2	; = GV: General Purpose variable
GRAT:		DS	2	; > SV: Return-value from Machine-language
;
DECBUF:	DS	4	; Decimal buffer ("54321")
LASTD:	DS	1	; Last byte in decimal-buffer
DELIM:	DS	1	; Delimiter space for buffer-end
LINBUF:	DS	72	; Line buffer (TTY = 72 Characters)
;
;--------------------------------
;	User program
;--------------------------------
;
	ORG	0140H+OFFSET	; = 320 in decimal
;
stack	EQU	$	; Stack goes from here down to line-buffer
prgm	EQU	$	; Programming space: here to end of memory
;
;--------------------------------
;       Main operating system
;--------------------------------
;
	ORG	0F800H	; Probably a ROM
;
; Cold-Start ("Boot").
;
RSTRT:	mvi a,01
    out 0f8h
    LXI	H,CLEAR	; = 3 to clear various things
	SHLD	PERIOD	; To see the program as it comes in
    LXI	H,0	; no null after CRLF
	SHLD	COMMA	; Number of nulls after each cr/lf
;
; By default, VTL-2 expects that the MITS Altair 8800 system
; it is running on has a terminal via one 2SIO board, either
; at I/O port 16, or at port 18. Since it has no way to know
; which one will be used, it simply initialize the 2SIO board
; at both I/O ports...
;
;	skip init. We're entering from monitor or boot loader and SIO ports are initialized
;	MOV	A,L	; = 3 Resets the chip of the 2SIO board
;	OUT	SIOS0	; I/O port 16 = 2SIO board Status
;	OUT	SIOS1	; I/O port 18 = 2SIO board Status
;	MVI	A,INTCI	; = 17 Sets the clock and interrupts
;	OUT	SIOS0	; I/O port 16 = 2SIO board Status
;	OUT	SIOS1	; I/O port 18 = 2SIO board Status
;
;
;
; Warm-Start (Ctrl-C).
;
; On Entry, register contents don't matter.
;
START:	LXI	SP,STACK	; Set up stack (before user program)
	XRA	A	; Initialize delimiter
	STA	DELIM	; Save delimiter for decimal-printing
	LXI	H,OKM	; Point to "OK" prompt
	CALL	STRNG	; Display it on terminal
;
; Main loop of VTL-2 interpreter.
;
; BC: ?, DE: ?, HL: ?
;
LOOP:	LXI	H,0000H	; Clear line-number for fall-through
	SHLD	NUMBR	; If no change during this line, then next
	CALL	CVTLN	; Was a line number inputted?
	JNC	STMNT	; 0: List (display) user program statements
	CALL	EXEC	; If no line, then execute direct statement
	JZ	START	; If end, then stop
;
LOOP2:	CALL	FIND	; Load real line-number
;
; Start processing "=" statements.
;
EQSTRT:	JNC	START	; If end, then stop
;
	CALL	LXHN	; Get real line number
	SHLD	NUMBR	; And save it for program
	LHLD	LINPTR	; Get crrent spot in line
	INX	H	; Bump past 0-byte delimiter
	INX	H	; Bump past line-number
	INX	H	; 
	CALL	EXEC	; Execute statement in line
;
	XCHG		;
	JZ	LOOP3	; If line-number == 0, then continue
	LHLD	LINPTR	; Else get new line
	CALL	LXHN	; and see if it's changed
	JZ	LOOP3	; If unchanged, then continue
	INX	H	; Else, increment old line-number
	SHLD	EXCLAM	; And save as RETURN value
	JMP	LOOP2	; Then continue at new line
;
LOOP3:	PUSH	H	; Save line number
	LHLD	AMPERS	; Next byte of user program
	MOV	B,H	;
	MOV	C,L	; Copy it into BC
	POP	H	; Restore line number
	CALL	FND3	; Find next line
	JMP	EQSTRT	; And THEN continue
;
;--------------------------------
; Get line number from user program.
;
LXHN:	MOV	A,M	;
	INX	H	;
	MOV	H,M	;
	MOV	L,A	;
;
; ... and falls through
;
; Compare HL with DE.
;
CPHD:	MOV	A,L	;
	CMP	E	; First test high bytes
	RNZ		; Done, if not same
	MOV     A,H	; 
	CMP	D	; Else test low bytes
	RET		;
;
;--------------------------------
;	Execute direct statements.
;
EXEC:	SHLD	LINUMB	; Save line position for store
	CALL	VAR2	; Skip past variable or array-element
;
	INX	H	; Get first term
SKIP:	MOV	A,M	;
	CALL	EVIL	; Evaluate expression 
;
OUTX:	LHLD	NUMBR	; Get char ptr
	MOV	A,H	; 16-bits test if it is zero
	ORA	L	; (Sets Zero flag)
	RET		;
;
;--------------------------------
;	List (display) user program statements.
;
; BC: ?, DE: ?, HL: ?
;
STMNT:	SHLD	CURENT	; Save current line number
	MOV	L,C	; Copy BC (?) to HL
	MOV	H,B	;
	SHLD	NUMBR	; And save it in char ptr
	MOV	A,B	; 16-bits test if BC is zero
	ORA	C	; 
	JNZ	SKP2	; Skip if line-number <> 0
;
	LHLD	AMPERS	; Point past end of program
	XCHG		; Put it in DE
	LXI	H,PRGM	; point to start of user program
;
; List (display) program on terminal.
;
LST2:	CALL	CPHD	; Check if next = start (= no program)
;
	JZ	START	; Yes: Return to interpreter
;
	PUSH	D	; No:
	MOV	C,M	;
	INX	H	; Get line number from memory
	MOV	B,M	;   and put it into BC.
	PUSH	H	; Save line-pointer
	CALL	PRNT2	; Print 16-bit line number in decimal
;
	POP	H	; Restore line-pointer
	INX	H	; Move past line-number content
	CALL	PNTMSG	; Print contents of line
;
	CALL	CRLF	; End of line
;
	POP	D	;
	JMP	LST2	; Loop until end of program
;
;--------------------------------
; Next text?
;
NXTXT:	LHLD	LINPTR	; Line-pointer
	INX	H	; Point past Line-Number
LOOKAG:	INX	H	; Find end of line
	MOV	A,M	;
	ANA	A	;
	JNZ	LOOKAG	; Look again...
;
; Closing-Paren in line also uses those 2 instructions...
;
OUTH:	INX	H	; And point to next
	RET		; Done
;
;--------------------------------
; Find line-number
;
FIND:	LHLD	AMPERS	; Point at first byte of user program
	MOV	C,L	;
	MOV	B,H	; Copy it to BC
	LHLD	NUMBR	; Char ptr
	XCHG		; Copy it to DE
	LXI	H,PRGM	; PC of user program
FND2:	SHLD	LINPTR	; Set it equal to line-pointer
	MOV	A,H	; Get and compare
	CMP	B	; High bytes
	JNZ	NXTUU	; Non-zero if high-bytes don't match
	MOV	A,L	; If high bytes match, then compare
	CMP	C	; Low bytes
	RZ		; Zero: Return with no carry, equal
;
; Not zero: ?
;
NXTUU:	MOV	A,M	; Get low byte of user program
	SUB	E	; Subtract low byte of char ptr
	INX	H	; Point to next byte
	MOV	A,M	; Get high byte of user program
	SBB	D	; Subtract low byte of char ptr
	DCX	H	; Point to previous byte
	CMC		; Complement Carry flag
	RC		; Return if DE > M(HL)
;
; Else, find next line
;
FND3:	CALL	NXTXT	;
;
	JMP	FND2	;
;
;--------------------------------
;
;         Subroutine to evaluate line
;
EVIL:	CPI	022h	; Is it a quote surrounding strings?
	JZ	QUOTE2	; Yes: go process it
;
	CALL	EVAL	; No: Evaluate expression
;
	PUSH	B	;
	LHLD	LINUMB	; ?
	CALL	CONVP	; Convert pointer to point to variable
;
	POP	B	; Get back pointer to storage
	CPI	'$'	; Is it a single character string?
	JNZ	ANDT	; No: Go check if it is a "?" char
;
	MOV	A,C	; Yes:
	JMP	OUTCH	; Print the character
;
; It is not a single char string. Is it "?" char?
;
ANDT:	SUI	'?'	;
	JZ	PRNT2	; Yes: print the value in decimal 
;
; System Variable "Greater Than" subroutine.
;
; Pass a 16-bits value in BC to a machine language subroutine.
;
; Note: Value from executing line is in BC register.
; Machine-Language routine can return another value in this
; Register-pair; and it will be saved in the ">" variable.
; The Accumulator passed cleared; but can be freely used.
; All other registers other than the BC and registers *must* be
; returned unchanged!
;
	INR	A	; Is it a ">" char?
	CZ	BRKPNT	; Call RST 0 at 0000H
;
; "At the conclusion of the machine language subroutine,
; a Intel 8080 RET instruction returns control to VTL-2,
;
; The value in B&C is stored in the appropriate variable.
;
	MOV	M,C	; Copy BC to Variable Storage
	INX	H	;
	MOV	M,B	;
	LHLD	QUITE	; Get Random-number
	DAD	B	; Add current value to random number
	SHLD	QUITE	; And save new random number
;
; Compare BC and DE and return with flags
;
CPBD:	MOV	A,C	; 
	CMP	E	;
	RNZ		;
	MOV	A,B	; DE = ?
	CMP	D	;
	RET		;
;
;--------------------------------
;
SKP2:	CALL	FIND	; Find either same line or place for insert
;
	JNC	INSRT	; If past end, then insert
	CALL	LXHN	; Check if line found is same line
	JNZ	INSRT	; If not, then Insert
	CALL	NXTXT	; Else bump past current line
;
	XCHG		;
	LHLD	LINPTR	; Line-pointer
DELT:	CALL	CPBD	; Compare BC with DE
	JZ	FITIT	; Equal: If finished deleting, then continue
	LDAX	D	; Move byte at M(DE)
	MOV	M,A	;   to M(HL).
	INX	H	; Increment HL
	INX	D	; Increment DE
	JMP	DELT	; Loop and continue removing line
;
; Insert a program line in program "text".
;
FITIT:	SHLD	AMPERS	; Save address of new end of user program
	MOV	B,H	; Copy HL to BC
	MOV	C,L	;
INSRT:	LHLD	CURENT	; Count new line-length
	LXI	D,0003H	; 3 = delimiter (0-byte) + line number
	MOV	A,M	; Get byte
	ANA	A	; Is it the end-of-line?
	JZ	LOOP	; Yes: Back to main loop of interpreter
;
CNTLN:	INX	D	; No: Calculate new end
	INX	H	;
	MOV	A,M	; Get next byte
	ANA	A	;
	JNZ	CNTLN	; Not zero: Back to main loop of interpreter
;
; Zero: ?
;
OPEN:	XCHG		; 
	DAD	B	; Add BC
	XCHG		; Put result in DE
	LXI	H,STAR	; Memory size
	MOV	A,E	; Subtract memory size from program length?
	SUB	M	;
	INX	H	;
	MOV	A,D	;
	SBB	M	;
	JNC	START	; If too big, then stop
;
; Some available memory is present.
;
	XCHG		;
	SHLD	AMPERS	; Then, this must be next byte of user PGM?
	INX	B	;
	INX	H	;
	PUSH	H	;
	LHLD	LINPTR	; Line-pointer
	XCHG		;
	POP	H	;
;
SLIDE:	DCX	B	; Slide open gap for new line
	DCX	H	;
	LDAX	B	; A = M(BC)
	MOV	M,A	;
	CALL	CPBD	; Until space is made for new one
	JNZ	SLIDE	; Move program above new line up.
;
DON:	LHLD	NUMBR	; Char ptr
	MOV	A,L	; Get M(HL)
	STAX	B	; M(BC) = A
	INX	B	; Increment BC
	MOV	A,H	; Get M(HL)
	STAX	B	; M(BC) = A  Save new line-number in program
	LHLD	CURENT	; Point at line-buffer
;
MOVL:	INX	B	; Move line from line-buffer to program
	MOV	A,M	;
	STAX	B	; M(BC) = A
	INX	H	;
	ANA	A	;
	JNZ	MOVL	; Until end-of-line in line-buffer
	JMP	LOOP	; Back to main loop of interpreter
;
;--------------------------------
;       I/O subroutines
;--------------------------------
; The following routines:
; INCH   or Input-Character  from Terminal
; OUTCH  or Output-Character   to Terminal
; POLCAT or Poll-For-Character on Terminal
; are each repeated 4 times, once for each I/O port.
; The POLSNS routine is used to check which of the
; four following routines to execute; depending on the
; Terminal settings in the sense-switches.
;
; The INCH and OUTCH routines both use the common
; routine: POLCAT to see if a character is ready
; for input or output on the selected terminal.
;--------------------------------
;
;
; Poll for character at terminal
; Status returns carry-flag set if input character available
; Status returns non-zero if output is ready for character
;
.if MACHINE = 1
;
; 8250 UART of AL80
;
POLCAT:	IN	UART5	; I/O Port-0 = Single-SIO board
	ANI	021H	; bit0 = RX data available, bit5 TX empty
	RAR		; TBE bit to bit-4; RDA bit to carry
	RNC		; Zero and carry status right if low
	ANA	A	; Else check new shifted output bit
	STC		; And set the carry
	RET		; Return with status
.else		; Z80 SIO/0
;
; SIO/0 UART of MintZ80
;
POLCAT:	push b
	mvi a,1		; select RR1
	out SIO_CA
	in SIO_CA
	ani 001h		; 7c bit 0 is TX ready
	ral			; rotate to bit 1
	mov b,a		; save in reg B

	sub a			; 4c clear a, write into WR0: select RR0
	out SIO_CA		; 11c
	in SIO_CA		; 11c read RRx
	ani 001h			; 7c bit 0 is RX ready
	ora b
	pop b

	RAR		; TBE bit to bit-4; RDA bit to carry
	RNC		; Zero and carry status right if low
	ANA	A	; Else check new shifted output bit
	STC		; And set the carry
	RET		; Return with status
.endif
;
;--------------------------------
; Print 16-bit line number in decimal.
;
; On Entry, BC = Number to be printed
;
; On exit, all registers are used and changed
;
PRNT2:	LXI	D,DECBUF-1	; Decimal buffer (5 chars long)
	LXI	H,PWRS10	; Table of decimal values
CVD1:	INX	D	; To save program space, do incr here
	PUSH	D	; Save address of next character-space
	MOV	D,B	; Copy Number (or remainder of it) to DE
	MOV	E,C	; For upcoming divide
	MOV	C,M	; Get Decimal divider in BC
	INX	H	;
	MOV	B,M	; 
	INX	H	; Then point to next decimal divisor
	PUSH	H	; Save address current divisor
; 			  BC: divisor, DE: dividend
	CALL	DIV	; Divide by 10,000, 1000, 100, 10, 1
; 			  DE: quotient, HL: remainder
	MOV	A,E	; Temp save result of divide in A
	MOV	B,H	; Copy remainder to BC for next divide
	MOV	C,L	;
	POP	H	; Restore address of next divisor to HL
	POP	D	; Restore address of where to store char.
	ADI	'0'	; Make result of divide an ASCII number
	STAX	D	; Store new decimal character
	MOV	A,E	; Get pointer byte
	CPI	lsb(LASTD)	; See if at end of number
	JC	CVD1	; If not past table, then continue.
;
; Suppress zeroes.
;
	LDAX	D	; Get last digit
	ORI	10000000B	; Add high-bit so 0 gets printed
	STAX	D	; Save last digit with high-bit set
	LXI	H,DECBUF-1	; Point before decimal buffer
ZRSUP:	INX	H	; Point to next char
	MOV	A,M	; Get it
	CPI	'0'	; Is it an ASCII zero?
	JZ	ZRSUP	; Yes: Loop, not showing zeroes
;
; Print message -- Init delimiter to zero.
;
PNTMSG:	XRA	A	; Init delimiter to zero
;
; Print a message.
; Delimiter is in A.  (Might be 0 byte or quote.)
;
STRMSG:	MOV	B,A	; and put it in B-reg.
OUTMSG:	MOV	A,M	; Get char from memory
	INX	H	; Update memory pointer
	CMP	B	; Is it the delimiter?
	JZ	CONTC	; Yes: Check if it is Ctrl-C
	CALL	ASCII	; No: Display the char on the terminal
	JMP	OUTMSG	; and loop until delimiter found.
;
; Check for Control-C.
;
CONTC:	CALL	POLCAT	; Poll character at terminal?
	RNC		; None available: Return
	CALL	INCH	; One char present: Get it
	CPI	CTRLC	; Is it Control-C?
	JZ	START	; Yes: Return to interpreter
			; No: Get char (Implement Pause)
;
;
; Input a character, whatever the I/O ports involved.
;
INCH:	CALL	POLCAT	; Check status for character input
	JC	INA	; One available: Go process it
;
; Status was FALSE: There is no char in one of the I/O
; ports, so let's check the Cassette tape player, instead.
;
	LDA	PERIOD	; Terminal/Cassette echo switch
	ANI	0010B
;		 |||
;		 ||+--> 0 = Nothing displayed on terminal
;		 ||     1 = Chars.  displayed on terminal
;		 |+---> 2 = Input from Cassette
;		 +----> 4 = Output  to Cassette
;
	JZ	INCH	; No cassete input wanted; so loop
;
; No: Input from cassette
;
	IN	CASSTS	; I/O port 6 = Cassette Status
	RRC		; Check if character ready yet
	JC	INCH	; Loop while waiting for char
	IN	CASSTD	; I/O port 7 = cassette Data
	ANI	01111111B	; Strip off upper bit
	JMP	OUTCAS	; Don't echo to Cassete from Cassette
;
; Status was TRUE: There is a char in one of the I/O ports.
;
.if MACHINE = 1
INA:	IN	UART0	; I/O port  1 = Single-SIO Data
.else if MACHINE = 2
INA:	IN	SIO_DA	; I/O port  1 = Single-SIO Data
.endif
	JMP	ASCII	;
;
ASCII:	ANI	01111111B	; Strip off upper bit
;
; Fall through to the "output char" subroutine.
;
; For all the checking of terminal options and cassete-I/O.
; The OUTCH or Output-Character routine doesn't change
; ANY registers except the stack; returning to the calling
; routine with all registers unchanged.
;
OUTCH:	PUSH	PSW	; Save char to check if cassette echo
	LDA	PERIOD	; Terminal/Cassette echo switch
	ANI	0100B
;		 |||
;		 ||+--> 0 = Nothing displayed on terminal
;		 ||     1 = Chars.  displayed on terminal
;		 |+---> 2 = Input from Cassette
;		 +----> 4 = Output  to Cassette
;
	JZ	OUTA	; Skip if don't want Cassette output
;
; No: Save on cassette.
;
OUTC:	IN	CASSTS	; I/O port 6 = cassette Status
	INR	A	; Check if exists
	JZ	OUTA	; If not, then skip Cassette output
	RLC		; Check Cassette status
	JC	OUTC	; Loop while waiting for char
	POP	PSW	; Restore char
	OUT	CASSTD	; I/O port 7 = cassette Data
OUTCAS	PUSH	PSW	; And then save it again
;
; Now, determine on which terminal to display the char.
;
OUTA:	LDA	PERIOD	; Terminal/Cassette echo switch
	RRC		; Test Terminal echo bit
;               0001B
;		 |||
;		 ||+--> 0 = Nothing displayed on terminal
;		 ||     1 = Chars.  displayed on terminal
;		 |+---> 2 = Input from Cassette
;		 +----> 4 = Output  to Cassette
;
	JNC	OUTD	; No terminal output wanted; so skip
OUTB:	CALL	POLCAT	; Check if ready for output
	JZ	OUTB	; Wait until ready
	POP	PSW	; Get character back
.if MACHINE = 1
	OUT	UART0		; I/O port 1 = Single-SIO board Data
.else
	OUT	SIO_DA	; I/O port 1 = Single-SIO board Data
.endif
	RET		; Done

;
;--------------------------------
; Evaluate expressions
;
; HL = Pointer to expression to be evaluated.
; A zero-byte (end-of-line) or right-paren ')'
; Ends evaluation.
; The right-paren can be start of a comment
; or the end of a parenthesized expression
; or the end of an array definition
;
EVAL:	CALL	GETVAL	; Get value of a number
;
; Next term of an expression
; HL = Pointer to current position in line
; BC = Current value as expressed so far
;
NXTRM:	MOV	A,M	; 
	ANA	A	; End-of-line?
	RZ		; Yes: Return
	CPI	')'	; No: Is it a closing parenthesis?
	JZ	OUTH	; Yes: INC HL past paren and return
	CALL	TERM	; No: Process term of expression
	MOV	B,H	; Copy result of expression to BC
	MOV	C,L	;
	LHLD	EVALPT	; Load eval pointer
	JMP	NXTRM	; and loop until end of terms found.
;
;--------------------------------
; Process one term of an arithmetic expression.
;
; BC always comes in with last value
; HL points to next operator
; Character after operator is next value to be operted on
; HL always returns with value of term as effected by operator
;
TERM:	PUSH	B	; Save present-value on Stack
	MOV	A,M	; Get operator
	PUSH	PSW	; Save operator on stack
	INX	H	; Point to next value to be worked with
	CALL	GETVAL	; Get value of next number or variable
;			  New value returns in BC
	SHLD	EVALPT	; Save save current position in line
	POP	PSW	; Restore operator for testing
	POP	H	; Place old value in HL
;
; Is it addition?
;
	CPI	'+'	; Addition?
	JNZ	EVAL2	; No: Check next arithmetic operation
;
; Yes: 16-bit addition.
;
	DAD	B	; Add BC to HL
	RET		; Result in HL
;
;--------------------------------
; Is it subtraction?
;
EVAL2:	CPI	'-'	; Subtraction?
	JNZ	EVAL3	; No: Check next arithmetic operation
;
; Yes: 16-bit subtraction subroutine.
;
HSUBB:	MOV	A,L	; Subtract BC from HL
	SUB	C	;
	MOV	L,A	;
	MOV	A,H	;
	SBB	B	;
	MOV	H,A	;
	RET		; Result in HL Carry in flags
;
;--------------------------------
; Is it multiplication?
;
EVAL3:	CPI	'*'	;
	JNZ	EVAL4	; No: Check next arithmetic operation
;
; Yes: 16-bit multiplication subroutine.
;
	XCHG		; Put multiplicand in DE
	LXI	H,0000H	; Clear partial product
	MVI	A,10H	; Set loop count to 16 bits
MULT1:	PUSH	PSW	; Save it on Stack
	DAD	H	; Add to product
	XCHG		; Put it into DE
	DAD	H	; Add to product
	XCHG		; Put it into HL
	JNC	MULT2	; If the result has 17 bits,
;
	DAD	B	;   add multiplier to product.
MULT2:	POP	PSW	; Restore count
	DCR	A	; Decrement it
	JNZ	MULT1	; Not end: Loop
;
	RET		; Result in HL
;
;--------------------------------
; Is it division?
;
EVAL4:	CPI	'/'	; Division?
	JNZ	EVAL5	; No: Now, check relational operators
;
	XCHG		; Swap current number into dividend
	CALL	DIV	; Yes: Use division subroutine
	SHLD	PERCNT	; Save remainder of divide operation
	XCHG		;
	RET		; Result in HL
;
;--------------------------------
; 16-bit division subroutine.
;
; On entry:
; BC: divisor, DE: dividend
; On return:
; BC: divisor, DE: quotient, HL: remainder
;
; The divide routine shifs the dividend left 16 bits
; A bit at a time into the remainder
; With each shift-left (*2) the divisor is subtracted;
; and if a good subtract, a new bit for the quotient
; is put in the result.
;
DIV:	LXI	H,0000H	; Initialize remainder in HL
	MOV	A,B	; Checks if 16-bit divisor = zero
	ORA	C	;
	MVI	A,16	; Set loop count to 16 bits
DIV1:	RZ		; Yes: Return (division by zero is forbidden)
	PUSH	PSW	; Save loop-count on Stack
	DAD	H	; Remainder * 2 Since dividend will be shifted
	XCHG		;
	DAD	H	; And dividend * 2
	XCHG		; 
	JNC	DIV2	; Shift high-bit from dividend into remainder
	INX	H	;
DIV2:	CALL	HSUBB	; Subtract Divisor from Current remainder
	INX	D	; If good subtract, then shift bit to quotient
	JNC	DIV3	; And continue if good
	DAD	B	; Else add subtracted number back
	DCX	D	; And remove shifted-in bit
DIV3:	POP	PSW	; Restore loop count
	DCR	A	; Decrement it
	JMP	DIV1	; Not end: Loop
;
;--------------------------------
; Now, check the relational operators.
;
EVAL5:	XCHG		; Move old-value to DE for tests
	LXI	H,0000H	; Init HL with FALSE value
;
;--------------------------------
; Is it equality-test?
;
EVIL5:	SUI	'='	;
	JNZ	EVIL6	; No: Check next relational operators
;
	MOV	A,D	; Get low byte
	CMP	B	; And check with high-byte
	RNZ		; Return if value not zero
	MOV	A,E	; Get low byte
	CMP	C	; And check with high-byte
	RNZ		; Return if value not zero
	INX	H	; Yes: = 1 (TRUE value)
	RET		;
;
;--------------------------------
; Is it greater-than-or-equals test?
;
EVIL6:	DCR	A	; "=" - 1 = "<"
	JZ	EVIL7	; Yes: Check relational operator
;
; Default is less-than test.
;
	MOV	A,E	; Subtract BC from DE
	SUB	C	;
	MOV	A,D	;
	SBB	B	;
	RNC		; Return if test is FALSE
	INX	H	; = 1 (TRUE value)
	RET		;
;
;--------------------------------
; Test for greater-than-or-equals
;
EVIL7:	MOV	A,E	; Subtract BC from DE
	SUB	C	;
	MOV	A,D	;
	SBB	B	;
	RC		; Return if test is FALSE
	INX	H	; = 1 (TRUE value)
	RET		;
;
;--------------------------------
; Get next value
;
; HL = Pointer to variable or other to be evaluated.
; BC returns value
;
GETVAL:	CALL	CVBIN	; Convert to binary number
;
	RNC		; It was a number: Done
;
	CPI	'?'	; Is it a PRINT statement?
	INX	H	; Increment mem ptr past ?
	JNZ	VAR	; No: Check if it is a variable name
;
; Yes: ?
;
	SHLD	VALVAR	; Save value of variable?
	CALL	INLN	; Get line from operator
;
	CALL	EVAL	; Evaluate line
	LHLD	VALVAR	; Return value of line operator enters
	RET		;
;
;--------------------------------
; Is it a variable name?
;
; BC: ?, DE: ?, HL: ?
;
VAR:	CPI	'$'	; Is it an String-INPUT statement?
	JNZ	VAR1	; No: Check next possibility
;
	CALL	INCH	; Yes: Input next char
;
	MOV	C,A	;
	MVI	B,00H	; Make sure a char is a byte value
	RET		;
;
; Is it the start of an expression?
;
VAR1:	CPI	'('	; If left-paren, then
	JZ	EVAL	; Evaluate whole expression
;
	DCX	H	; No: Re-point to character
;
VAR2:	CALL	CONVP	; Get line and convert to value
;
	MOV	C,M	; 
	INX	H	;
	MOV	B,M	;
	LHLD	RESULT	; ?
	RET		;
;
;--------------------------------
; Obviously, deal with array DEEK/DOKE...
;
ARRAY:	CALL	EVAL	; Evaluate expression to find which element
;
	SHLD	RESULT	; Save result of evaluation?
	LHLD	AMPERS	; Get address of next byte of user program
	DAD	B	;
	DAD	B	; Two bytes for every element in array
	POP	PSW	;
	RET		; Return with pointer to array in HL
;
;--------------------------------
; Convert character to pointer to memory
; HL returns with pointer to value
;
CONVP:	MOV	A,M	; Get variable letter
	INX	H	;
	PUSH	PSW	;
	CPI	':'	; Is it the start of an array statement?
	JZ	ARRAY	; Yes: Go to ARRAY subroutine
;
; All characters map as:
; '@' to '_' as 00H to 1FH (Includes 'A' to 'Z')
; ' ' to '?' as 20H to 3FH (Includes '0' to '9')
; Note inversion!
; '@' maps BEFORE space not after it
;
	SHLD	RESULT	; Save value of expression
	ANI	00111111B	; = 3FH (Uppercase Only)
	LXI	H,AT/2	; We're going to double this, so ....
	ADD	L	; Add Character offset into var table
	MOV	L,A	; Calculate standard letter variables
	DAD	H	; 2 bytes for each variable
;
; "Output a char" also uses those 2 instructions...
;
OUTD:	POP	PSW	; Restore accumulator
	RET		;
;
;--------------------------------
; Table of powers of 10.
;
PWRS10: DW	10000
	DW	1000
	DW	100
	DW	10
	DW	1
;
;--------------------------------
; Test if character is an ASCII numeric
;
TSTN:	MOV	A,M	; Get char
	CPI	'9'+1	; Is it > "9" ?
	CMC		;
	RC		;
	CPI	'0'	; Is it < "0" ?
	RET		;
;
;--------------------------------
; Get line and convert it to a value
;
CVTLN:	CALL	INLN	;
;
; Convert to binary number.
; If non-numeric, then carry set and character is in A
; If numeric, then carry clear, and value returned in BC
;
CVBIN:	CALL	TSTN	; Is it a number?
	RC		; No: Return
;
; Yes: Convert the ASCII char to binary number.
;
	LXI	B,0000H	; Clear initial value in BC
CBLOOP:	MOV	A,M	; Get next numeric char
	SUI	'0'	; Convert from ASCII to binary
	ADD	C	; Add to value already in BC
	MOV	C,A	;
	MVI	A,00H	;
	ADC	B	;
	MOV	B,A	;
	INX	H	; Point to next char
	CALL	TSTN	; Is it a number?
	CMC		;
	RNC		; No: Return with value in BC and Carry cleared
;
; Yes: multiply old number in BC by ten to put new number in
;
	PUSH	H	; Save pointer
	MOV	H,B	; Copy BC to HL
	MOV	L,C	;
	DAD	H	; HL = BC times 2
	DAD	H	; HL = BC times 4
	DAD	B	; HL = BC times 5
	DAD	H	; HL = BC times 10
	MOV	B,H	; Move result back to BC
	MOV	C,L	;
	POP	H	; Restore pointer
	JMP	CBLOOP	; Loop until not a number
;
;--------------------------------
; Process line input from terminal.
;
INLN6:	CPI	'@'	; Discard line inputted?
	JZ	NEWLIN	; Yes: Start a new line
;
; No: We are in a line. Are we at the end?
;
	INX	H	; Increment line pointer
	MOV	A,L	; Get its low byte
	CPI	lsb(LINBUF+72)   ; Are we at the end of the line?
	JNZ	INLN2	; No: Get next char
;
; Yes: Start a new line on the terminal.
;
NEWLIN:	CALL	CRLF	; Return "cursor" at beginning of next line
;
;         Subroutine __________________________
;
INLN:	LXI	H,LINBUF+1	; Point to first char in line buffer
;
; Check if we reached the beginning of the line,
; that is to say: erased all the line, backspacing chars.
;
INLN5:	DCX	H	; Point before the first char
	MOV	A,L	;
	CPI	lsb(LINBUF-1)	; Is it the beginning of the line?
	JZ	NEWLIN	; Yes: Start a new line
;
; Not at end of line: Get another char, and check it.
;
INLN2:	CALL	INCH	; Input another char
	CPI	CR
	JZ	INLN2		; IGNORE CRs
;
	MOV	M,A	; Sve it in line
	CPI	'_'	; Backspace to erase a char?
	JZ	INLN5	; Yes: Check if we erased everything
;
; No: Check if the user had ended inputting a line.
;
INLN3:	CPI	LF	;
	JC	INLN2	; No: Get another char
;
	JNZ	INLN6	; Yes: Go proceed another line
;
INLN4:	XRA	A	; Mark end of line with a 00H
	MOV	M,A	; 
	LXI	H,LINBUF	; Point back to beginning of line
	JMP	PRLF	; It was CR: add LF and done
;
;--------------------------------
;
QUOTE2:	INX	H	; Skip beginning quote
;
;         Subroutine __________________________
;
STRNG:	CALL	STRMSG	; Print string
	MOV	A,M	; Get char *after* delimiter
	CPI	';'	; Is it a semicolon?
	RZ		; Yes: Then, no CR/LF after PRINT
;
; No: End of line reached, output CR and LF.
;
CRLF:	MVI	A,CR	; Carriage-Return
	CALL	OUTCH	;
PRLF:	MVI	A,LF	; Line-Feed
	CALL	OUTCH   ;
;
;	System Variable COMMA subroutine.
;
; Outputs the number of null bytes (00H) stored in COMMA,
; while the printhead of the ASR-33 Teletype returns to
; the left side of the roll of punched paper.
;
	LDA	COMMA	; Number of null bytes after cr/lf
NULL:	DCR	A	; Number should be less than 128
	RM		; Return if no more nulls wanted
	PUSH	PSW	;
	XRA	A	; = Null byte in A-reg
	CALL	OUTCH	;
	POP	PSW	;
	JMP	NULL	; Loop the number of null bytes
;
;--------------------------------
;
OKM:	DB	CR,LF,'OK',00H
;
;--------------------------------
;
	END