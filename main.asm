
TITLE MASM Template						(main.asm)

; Description:
; 
; Revision date:

INCLUDE Irvine32.inc
.data

Userinput DWORD 0
X1 DWORD 0
Y1 DWORD 0
X2 DWORD 0
Y2 DWORD 0

Pieces DWORD 48 DUP (0)

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

rows DWORD 64 DUP (0)

initPieceCount DWORD 0

.code

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Start of main

main PROC
	;call init
	;call plot
	call input
	call PieceInit
	exit
main ENDP

	input proc

	push eax
	push ebx
	push edx



	call readint

	XOR edx, edx

	mov Userinput,eax
	mov ebx, 1000
	div ebx
	mov X1, eax
	mov eax, edx

	XOR edx, edx

	mov ebx, 100
	div ebx
	mov Y1, eax
	mov eax, edx 

	XOR edx, edx

	mov ebx, 10
	div ebx
	mov X2, eax
	mov eax, edx

	mov Y2, edx 

	pop edx
	pop ebx
	pop eax

	ret
input endp

PieceInit proc
	push eax
	push ebx
	push edx

	XOR edx, edx

	mov eax, [currentRow]
	mov ebx, 2
	div ebx
	cmp edx, 1
	je oddRow
	jmp evenRow

	oddRow: 
		mov eax, [currentcolumn]
		mov ebx, 2
		div ebx
		cmp edx, 1
		je oddRowOddColumn
		jmp endPiece

	oddRowOddColumn:
		call AddPiece
		jmp endPiece

	evenRow:
		mov eax, [currentcolumn]
	mov ebx, 2
	div ebx
		cmp edx, 0
		je evenRowEvenColumn
		jmp endPiece

	evenRowEvenColumn:
		call AddPiece
		jmp endPiece

	endPiece:
	pop edx
	pop ebx
	pop eax

		ret
PieceInit endp

FillPieces PROC
	push ecx
	
	pop ecx
	ret
FillPieces ENDP

PiecesOuterLoop PROC
	push ecx
		mov ecx, 0

		loop_start:
		call PiecesInnerLoop
	pop ecx
	ret
PiecesOuterLoop ENDP

PiecesInnerLoop PROC
	ret
PiecesInnerLoop ENDP

AddPiece PROC
	push eax

	mov eax,[currentRow]
	mov requestedRow, eax

	mov eax, [currentColumn]
	mov requestedColumn, eax

	call getSquare
	


	pop eax
	ret
AddPiece ENDP

init PROC
	mov outerLoopAction, OFFSET innerLoop
	mov innerLoopAction, OFFSET fillPieces
	call outerLoop
	ret
init ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End of fillPieces subroutine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Start of plot subroutine

plot PROC
	push edx
	push eax

	mov outerLoopAction, OFFSET innerLoop
	mov innerLoopAction, OFFSET	callBoard						;change:printRedPiece

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
		

		inc ecx
		cmp ecx, 8
	jnge loop_start

	call printNewLine

	pop eax
	pop ecx
	
	ret
innerLoop ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

callBoard PROC								; printEmptyRed  printEmptyWhite
	push eax
	push ecx
					
	mov	 currentRow,eax
	xor edx,edx
	mov ebx,2
	div ebx

	cmp edx,1
	je oddRow

	jmp evenRow

	evenRow:
		mov eax,currentColumn
		xor edx,edx
		mov ebx,2
		div ebx

		cmp edx,1
		je eroc
		jmp erec

	eroc:
		call printEmptyRed
		jmp endBoard
	erec:
		call ActiveSquare		;Call activesquare to check if there is something there
		jmp endBoard

	oddRow:
		mov eax,currentColumn
		xor edx,edx
		mov ebx,2
		div ebx

		cmp edx,1

		je oroc
		jmp orec

	orec:
		call printEmptyRed
		jmp endBoard
	oroc:
		call ActiveSquare		;Call activesquare to check if there is something there
		jmp endBoard


	endBoard:
		pop ecx
		pop eax
		ret
callBoard ENDP

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

ActiveSquare PROC
	push eax
	push ecx

	mov eax, currentRow
	mov ecx, currentColumn

	mov requestedRow, eax
	mov requestedColumn, ecx
	call getSquare
	
	mov eax, [requestedSquare]
	mov eax, [eax]
	cmp eax,0
	je emptyActiveSquare

	jmp checkPiece

	emptyActiveSquare:
		call printEmptyWhite
		jmp endActiveSquare

	checkPiece:
		
		jmp endActiveSquare


	endActiveSquare:
		pop ecx
		pop eax
		ret
ActiveSquare ENDP




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