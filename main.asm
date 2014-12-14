TITLE MASM Template						(main.asm)

INCLUDE Irvine32.inc

INCLUDE Board.inc
INCLUDE Data.inc
INCLUDE Helpers.inc
INCLUDE Init.inc
INCLUDE Input.inc
INCLUDE Output.inc
INCLUDE Pieces.inc
INCLUDE Rules.inc



.code
main PROC
	call Init_Checkers

	start:
		call Input_GetCommand
		call Rules_PerformCommand
		call Rules_CheckIfError
		call Rules_EndIfWon

		call Board_Replot
		jmp start

main ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Start of outerLoop



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



END main