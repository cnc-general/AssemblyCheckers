
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

columnHeader BYTE " 01234567", 0
rowHeader BYTE " ",0

defaultColor DWORD white+(black*16)

redSquareColor DWORD black+(red*16)
whiteSquareColor DWORD black+(white*16)
redPieceColor DWORD red+(white*16)
greenPieceColor DWORD green+(white*16)

emptySquare BYTE " ",0
filledSquare BYTE "O",0
kingSquare BYTE "K",0

endl BYTE 0dh,0ah,0

currentRow DWORD 0
currentColumn DWORD 0

outerLoopAction DWORD 0
innerLoopAction DWORD 0

requestedRow DWORD ?
requestedColumn DWORD ?
requestedSquare DWORD ?

requestedPiece DWORD 0
requestedPieceID DWORD 0
requestedPieceStatus DWORD 0

rows DWORD 64 DUP (0)

CreatePieceCount DWORD 0

RedPieceCount DWORD 0
GreenPieceCount DWORD 0

.code

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Start of main

main PROC
	;call init
	;call input

	call CreatePieces
	call InitBoard

	call ReplotBoard

	;call GetPieceCounts
	exit
main ENDP

InitBoard PROC
	mov innerLoopAction, OFFSET PlacePiece
	mov outerLoopAction, OFFSET innerLoop
	
	call outerLoop

	mov CreatePieceCount, 0

	ret
InitBoard ENDP


PlacePiece proc
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
		call AddPieceToBoard
		jmp endPiece

	evenRow:
		mov eax, [currentcolumn]
		mov ebx, 2
		div ebx
		cmp edx, 0
		je evenRowEvenColumn
		jmp endPiece

	evenRowEvenColumn:
		call AddPieceToBoard
		jmp endPiece

	endPiece:
	pop edx
	pop ebx
	pop eax
	ret
PlacePiece ENDP

AddPieceToBoard PROC
	push eax
	push ebx
	push ecx
	
	mov eax, [currentRow]
	mov requestedRow, eax

	mov ebx, [currentColumn]
	mov requestedColumn, ebx

	call GetSquare

	cmp eax, 2
	jle piece

	cmp eax, 5
	jge piece

	jmp end_add

	piece:
		mov ecx, CreatePieceCount
		imul ecx, 8
		
		mov eax, [requestedSquare]
		mov eax, [eax]

		mov eax, [requestedSquare]
		lea ebx, Pieces
		add ebx, ecx

		mov DWORD PTR [eax], ebx

		mov eax, [requestedSquare]
		mov eax, [eax]

		mov eax, CreatePieceCount
		inc eax
		mov CreatePieceCount, eax

	end_add:
		pop ecx
		pop ebx
		pop eax
		ret
AddPieceToBoard ENDP

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

CreatePieces PROC
	call PiecesOuterLoop
	ret
CreatePieces ENDP

PiecesOuterLoop PROC
	push ecx

	mov ecx, 0
	loop_start: 
		call PiecesInnerLoop
		inc ecx
		cmp ecx, 2
		jl loop_start
	pop ecx
	ret
PiecesOuterLoop ENDP

PiecesInnerLoop PROC
	push ecx
	push ebx

	mov ebx, ecx

	mov ecx, 0
	loop_start: 
		call CreatePiece
		inc ecx
		cmp ecx, 12
		jl loop_start
	
	pop ebx
	pop ecx
	ret
PiecesInnerLoop ENDP

CreatePiece PROC
	push eax
	push ebx
	push ecx
	push edx
	
	;ebx = player
	;ecx = piece

	mov eax, ebx
	imul eax, 96

	mov edx, ecx
	imul edx, 8

	add edx, eax
	lea eax,Pieces
	add eax, edx

	mov dword ptr[eax], ebx
	add eax, 4
	mov dword ptr[eax], 01h

	pop edx
	pop ecx
	pop ebx
	pop eax
	ret
CreatePiece ENDP

GetRequestedPiece PROC
	push eax
	push ebx

	mov eax, requestedPiece

	mov ebx, [eax]
	mov requestedPieceID, ebx
	add eax, 4

	mov ebx, [eax]
	mov requestedPieceStatus, ebx

	pop ebx
	pop eax
	ret
GetRequestedPiece ENDP

GetPieceCounts PROC
	push eax
	push ebx
	push ecx

	mov RedPieceCount, 0
	mov GreenPieceCount, 0

	mov ecx, 24

	loop_start:
		lea eax, Pieces
		mov ebx, ecx
		imul ebx, 8
		add eax, ebx

		mov requestedPiece, eax
		call GetRequestedPiece

		call TrackPieceCount
	loop loop_start

	mov eax, RedPieceCount
	mov ebx, GreenPieceCount
	
	pop ecx
	pop ebx
	pop eax
	ret
GetPieceCounts ENDP

TrackPieceCount PROC
	push eax
	push ebx

	mov eax, requestedPieceID
	mov ebx, requestedPieceStatus
	
	cmp ebx, 0
	jg valid_piece

	jmp end_piece

	valid_piece:
		cmp eax, 0
		je red_piece
		jmp Green_piece

	red_piece:
		mov eax, RedPieceCount
		inc eax
		mov RedPieceCount, eax
		jmp end_piece

	Green_piece:
		mov eax, GreenPieceCount
		inc eax
		mov GreenPieceCount, eax
		jmp end_piece

	end_piece:
		pop ebx
		pop eax
		ret
TrackPieceCount ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Start of ReplotBoard subroutine

ReplotBoard PROC
	push edx
	push eax

	lea edx, columnHeader
	call WriteString
	call printNewLine

	mov outerLoopAction, OFFSET ReplotBoardOuterAction
	mov innerLoopAction, OFFSET	CreateSquare

	call outerLoop

	pop eax
	pop edx

	ret
ReplotBoard ENDP

ReplotBoardOuterAction PROC
	push eax
	mov eax, ecx
	call WriteDec

	call innerLoop
	call printNewLine

	pop eax
	ret
ReplotBoardOuterAction ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End of ReplotBoard subroutine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Start of outerLoop

outerLoop PROC
	push ecx
	mov ecx, 0
	
	loop_start: 
		mov currentRow,ecx
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
	push ecx
	push eax

	mov ecx, 0
	loop_start:
		mov currentColumn, ecx
		call innerLoopAction
		inc ecx
		cmp ecx, 8
	jnge loop_start
	
	pop eax
	pop ecx
	
	ret
innerLoop ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CreateSquare PROC								; printEmptyRed  printEmptyWhite
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
CreateSquare ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GetSquare PROC
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
GetSquare ENDP

ActiveSquare PROC
	push eax
	push ecx

	mov eax, currentRow
	mov ecx, currentColumn

	mov requestedRow, eax
	mov requestedColumn, ecx
	call GetSquare
	
	mov eax, [requestedSquare]
	mov eax, [eax]
	cmp eax,0
	je emptyActiveSquare

	jmp checkPiece

	emptyActiveSquare:
		call printEmptyWhite
		jmp endActiveSquare

	checkPiece:
		mov requestedPiece, eax
		call GetRequestedPiece

		mov eax, requestedPieceID
		cmp eax, 0
		je is_red
		jmp is_green

	is_red:
		mov eax, requestedPieceStatus
		cmp eax, 2
		je red_king
		jmp red_piece

	red_piece:
		call printRedPiece
		jmp endActiveSquare

	red_king:
		call printRedKing
		jmp endActiveSquare

	is_green:
		mov eax, requestedPieceStatus
		cmp eax, 2
		je green_piece
		jmp green_piece

	green_piece:
		call printGreenPiece
		jmp endActiveSquare

	green_king:
		call printGreenKing
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
	lea edx, emptySquare

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
	lea edx, emptySquare

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
	lea edx, filledSquare

	call SetTextColor
	call WriteString

	mov eax, defaultColor
	call SetTextColor

	pop edx
	pop eax
	ret
printRedPiece ENDP

printRedKing PROC
	push eax
	push edx

	mov eax, redPieceColor
	lea edx, kingSquare

	call SetTextColor
	call WriteString

	mov eax, defaultColor
	call SetTextColor

	pop edx
	pop eax
	ret
printRedKing ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

printGreenPiece PROC
	push eax
	push edx

	mov eax, greenPieceColor
	lea edx, filledSquare

	call SetTextColor
	call WriteString

	mov eax, defaultColor
	call SetTextColor

	pop edx
	pop eax
	ret
printGreenPiece ENDP

printGreenKing PROC
	push eax
	push edx

	mov eax, greenPieceColor
	lea edx, filledSquare

	call SetTextColor
	call WriteString

	mov eax, defaultColor
	call SetTextColor

	pop edx
	pop eax
	ret
printGreenKing ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

printNewLine PROC
	push eax
	push edx

	lea edx, endl
	call WriteString

	mov eax, defaultColor
	call SetTextColor

	pop edx
	pop eax
	ret
printNewLine ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

END main