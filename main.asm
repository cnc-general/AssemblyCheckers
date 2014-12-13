TITLE MASM Template						(main.asm)

; Description:
; 
; Revision date:

INCLUDE Irvine32.inc
.data

defaultColor DWORD white+(black*16)

redSquareColor DWORD black+(red*16)
whiteSquareColor DWORD black+(white*16)
redPieceColor DWORD red+(white*16)
blackPieceColor DWORD black+(white*16)

emptySquare BYTE " ",0
filledSquare BYTE "O",0

endl BYTE 0dh,0ah,0

currentRow DWORD 0
currentColumn DWORD 0

outerLoopAction DWORD 0
innerLoopAction DWORD 0

requestedRow DWORD ?
requestedColumn DWORD ?
requestedSquare DWORD ?

rows DWORD 64 DUP (0Fh)

.code

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Start of main

main PROC
	;call init
	call plot
	exit
main ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End of main
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Start of init subroutine

init PROC
	mov outerLoopAction, OFFSET innerLoop
	mov innerLoopAction, OFFSET fillPieces
	call outerLoop
	ret
init ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End of init subroutine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Start of fillPieces subroutine

fillPieces PROC
	push eax
	push ebx
	push edx

	mov eax, [currentRow]
	mov requestedRow, eax
	mov ebx, 2
	div ebx
	cmp eax, 1

	pop edx
	pop ebx
	pop eax
	ret
fillPieces ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End of fillPieces subroutine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Start of plot subroutine

plot PROC
	push edx
	push eax

	mov outerLoopAction, OFFSET innerLoop
	mov innerLoopAction, OFFSET printRedPiece

	call outerLoop

	pop eax
	pop edx

	ret
plot ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End of plot subroutine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Start of outerLoop

outerLoop PROC
	push ecx
	mov ecx, 0
	
	loop_start: 
		call outerLoopAction
		inc ecx
		cmp ecx, 8
		jnge loop_start

	pop ecx
	ret
outerLoop ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

innerLoop PROC
	mov currentRow,ecx
	push ecx
	push eax

	mov ecx, 0
	loop_start:
		mov currentColumn, ecx
		mov eax, currentRow

		mov requestedRow, eax
		mov requestedColumn, ecx

		call innerLoopAction
		
		;call getSquare

		;mov eax, [requestedSquare]
		;mov eax, [eax]

		inc ecx
		cmp ecx, 8
	jnge loop_start

	call printNewLine

	pop eax
	pop ecx
	
	ret
innerLoop ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

getSquare PROC
	push eax
	push ebx

	mov eax, [requestedRow]
	imul eax, 32

	mov ebx, [requestedColumn]
	imul ebx, 4

	add eax,ebx
	add eax,OFFSET rows

	mov requestedSquare, eax
		
	pop ebx
	pop eax

	ret
getSquare ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

printEmptyWhite PROC
	push eax
	push edx

	mov eax, whiteSquareColor
	mov edx, OFFSET emptySquare

	call SetTextColor
	call WriteString
		
	mov eax, defaultColor
	call SetTextColor

	pop edx
	pop eax
	ret
printEmptyWhite ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

printEmptyRed PROC
	push eax
	push edx

	mov eax, redSquareColor
	mov edx, OFFSET emptySquare

	call SetTextColor
	call WriteString

	mov eax, defaultColor
	call SetTextColor

	pop edx
	pop eax
	ret
printEmptyRed ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

printRedPiece PROC
	push eax
	push edx

	mov eax, redPieceColor
	mov edx, OFFSET filledSquare

	call SetTextColor
	call WriteString

	mov eax, defaultColor
	call SetTextColor

	pop edx
	pop eax
	ret
printRedPiece ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

printBlackPiece PROC
	push eax
	push edx

	mov eax, blackPieceColor
	mov edx, OFFSET filledSquare

	call SetTextColor
	call WriteString

	mov eax, defaultColor
	call SetTextColor

	pop edx
	pop eax
	ret
printBlackPiece ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

printNewLine PROC
	push eax
	push edx

	mov edx, OFFSET endl
	call WriteString

	mov eax, defaultColor
	call SetTextColor

	pop edx
	pop eax
	ret
printNewLine ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

END main