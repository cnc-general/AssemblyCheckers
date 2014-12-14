TITLE MASM Template						(main.asm)

; Description:
; 
; Revision date:

INCLUDE Irvine32.inc
INCLUDE Data.inc
.data

Userinput DWORD 0
R1 DWORD 0
C1 DWORD 0
R2 DWORD 0
C2 DWORD 0

Pieces DWORD 48 DUP (0)
rows DWORD 64 DUP (0)

;=======Strings======
endl BYTE 0dh,0ah,0
columnHeader BYTE " 01234567", 0
rowHeader BYTE " ",0
inputString BYTE 0dh, 0ah, "Please Enter Command as 4 digit number...", 0dh, 0ah, "Enter using format: SrcRow_SrcCol_DstRow_DstCol", 0dh,0ah, "Example: 0123", 0dh,0ah, "Command: ",0
errorString BYTE 0dh, 0ah, "That is an invalid move. ",0

greenPlayerString BYTE 0dh, 0ah, "Green Player's Turn!",0dh, 0ah,0dh, 0ah,0
redPlayerString BYTE 0dh, 0ah, "Red Player's Turn!",0dh, 0ah,0dh, 0ah,0

emptySquare BYTE " ",0
filledSquare BYTE "O",0
kingSquare BYTE "K",0
;====================

;========Colors======
defaultColor DWORD white+(black*16)
redSquareColor DWORD black+(red*16)
whiteSquareColor DWORD black+(white*16)
redPieceColor DWORD red+(white*16)
greenPieceColor DWORD green+(white*16)
greenPlayerColor DWORD green+(black*16)
redPlayerColor DWORD red+(black*16)
;====================

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

CreatePieceCount DWORD 0
RedPieceCount DWORD 0
GreenPieceCount DWORD 0

InputErrorOccured DWORD 0
MoveIsJump DWORD 0
CurrentPlayerID DWORD 0

.code

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Start of main

main PROC
	call InitCheckers

	start:
		call GetCommand
		call PerformCommand
		call CheckIfError
		call EndIfWon

		call ReplotBoard
		jmp start

main ENDP

SwapPlayers PROC
	push eax
		mov eax, CurrentPlayerID
		XOR eax, 000000001h
		mov CurrentPlayerID, eax
	pop eax
	ret
SwapPlayers ENDP

CheckIfError PROC
	push eax

	mov eax, InputErrorOccured
	cmp eax, 1
		je error_occured
	jmp no_error

	error_occured:
		push edx
		lea edx, errorString
		call WriteString
		pop edx

		call WaitMsg

		call printNewLine
		jmp end_check

		no_error:
			call SwapPlayers
			jmp end_check
	end_check:
		mov InputErrorOccured, 0
		pop eax
		ret
CheckIfError ENDP

MovePiece PROC
	push eax
	push ebx
	push ecx

	mov eax, R1
	mov ebx, C1

	mov requestedRow, eax
	mov requestedColumn, ebx
	call GetRequestedSquare
	
	mov eax, [requestedSquare]
	mov ecx, DWORD PTR [eax]
	mov DWORD PTR [eax], 0

	mov eax, R2
	mov ebx, C2

	mov requestedRow, eax
	mov requestedColumn, ebx
	call GetRequestedSquare

	mov eax, [requestedSquare]
	;mov eax, [eax]
	mov DWORD PTR [eax], ecx

	pop ecx
	pop ebx
	pop eax
	ret
MovePiece ENDP

PerformCommand PROC
	
	call CheckDiagonal
	mov eax, InputErrorOccured
	cmp eax, 1
		je end_perform

	call CheckAdjacent
	mov eax, InputErrorOccured
	cmp eax, 1
		je end_perform

	call CheckSource
	mov eax, InputErrorOccured
	cmp eax, 1
		je end_perform

	call CheckDirection
	mov eax, InputErrorOccured
	cmp eax, 1
		je end_perform

	call CheckDestination
	mov eax, InputErrorOccured
	cmp eax, 1
		je end_perform

	call MovePiece

	end_perform:
		ret
PerformCommand ENDP

CheckDiagonal PROC
	push eax
	push ebx
	push ecx
	push edx

	mov eax, R1
	mov ebx, C1
	mov ecx, R2
	mov edx, C2

	cmp eax, ecx
		je error_occured

	cmp ebx, edx
		je error_occured

	jmp end_check

	error_occured:
		mov InputErrorOccured, 1
		jmp end_check

	end_check:
		pop edx
		pop ecx
		pop ebx
		pop eax
		ret
CheckDiagonal ENDP

CheckAdjacent PROC
	push eax
	push ebx
	push ecx
	push edx

	mov eax, R1
	mov ebx, C1
	mov ecx, R2
	mov edx, C2

	sub eax, ecx
	cmp eax, 1
		jg error_occured

	sub ebx, edx
	cmp ebx, 1
		jg error_occured

	jmp end_check

	error_occured:
		mov InputErrorOccured, 1
		jmp end_check
	
	end_check:
		pop edx
		pop ecx
		pop ebx
		pop eax
		ret
CheckAdjacent ENDP

CheckSource PROC
	push eax
	push ebx

	mov eax, R1
	mov ebx, C1

	mov requestedRow, eax
	mov requestedColumn, ebx
	call GetRequestedSquare

	mov eax, [requestedSquare]
	mov eax, [eax]
	cmp eax, 0
		je error_occured

	mov requestedPiece, eax
	call GetRequestedPiece
	
	mov eax, requestedPieceID
	mov ebx, CurrentPlayerID
	cmp eax, ebx
		jne error_occured

	jmp end_check

	error_occured:
		mov InputErrorOccured, 1
		jmp end_check

	end_check:
		pop ebx
		pop eax
		ret
CheckSource ENDP

CheckDirection Proc
	push eax
	push ebx

	mov eax, requestedPieceStatus
	cmp eax, 2
		je end_check

	mov eax, CurrentPlayerID
	cmp eax, 0
		je player_0
	jmp player_1

	player_0:
		mov eax, R1
		mov ebx, R2
		cmp eax, ebx
			jge error_occured
		jmp end_check

	player_1:
		mov eax, R1
		mov ebx, R2
		cmp eax, ebx
			jle error_occured
		jmp end_check

	error_occured:
		mov InputErrorOccured, 1
		jmp end_check

	end_check:
		pop ebx
		pop eax
		ret
CheckDirection ENDP

CheckDestination PROC
	push eax
	push ebx

	mov eax, R2
	mov ebx, C2

	mov requestedRow, eax
	mov requestedColumn, ebx
	call GetRequestedSquare

	mov eax, [requestedSquare]
	mov eax, [eax]
	cmp eax, 0
		je move_standard

	mov requestedPiece, eax
	call GetRequestedPiece
	
	mov eax, requestedPieceID
	mov ebx, CurrentPlayerID
	cmp eax, ebx
		je error_occured
	
	jmp move_jump


	move_jump:
		mov MoveIsJump, 1
		jmp end_check


	move_standard:
		mov MoveIsJump, 0
		jmp end_check

	error_occured:
		mov InputErrorOccured, 1
		jmp end_check

	end_check:
		pop ebx
		pop eax
		ret
CheckDestination ENDP

EndIfWon PROC
	push eax

	call GetPieceCounts
	
	mov eax, RedPieceCount

			;DEBUG;
				;mov eax, 0

	cmp eax, 0
	je end_program

	mov eax, GreenPieceCount
	cmp eax, 0
	je end_program

	jmp return_main
	
	end_program:
		exit

	return_main:
		pop eax
		ret

EndIfWon ENDP

InitCheckers PROC
	
	call CreatePieces
	call InitBoard
	call ReplotBoard
	ret
InitCheckers ENDP

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

	call GetRequestedSquare

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

		mov eax, CreatePieceCount
		inc eax
		mov CreatePieceCount, eax

	end_add:
		pop ecx
		pop ebx
		pop eax
		ret
AddPieceToBoard ENDP

GetCommand PROC
	call PromptCommand
	call ReadCommand
	ret
GetCommand ENDP

PromptCommand PROC
	push edx
		lea edx, inputString
		call WriteString
	pop edx
	ret
PromptCommand ENDP

ReadCommand PROC
	push eax
	push ebx
	push edx

	call readint
	
	cmp eax, 7777
	jg end_read

	XOR edx, edx

	mov Userinput,eax
	mov ebx, 1000
	div ebx
	mov R1, eax
	mov eax, edx

	XOR edx, edx

	mov ebx, 100
	div ebx
	mov C1, eax
	mov eax, edx 

	XOR edx, edx

	mov ebx, 10
	div ebx
	mov R2, eax
	mov eax, edx

	mov C2, edx 


	end_read:
		pop edx
		pop ebx
		pop eax

		ret
ReadCommand ENDP

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
	lea eax, Pieces
	add eax, edx

	mov dword ptr[eax], ebx
	add eax, 4
	mov dword ptr[eax], 02h

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

	call Clrscr
	call PrintTurnString

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

PrintTurnString PROC
	push eax
	push edx
	
	mov eax, CurrentPlayerID
	cmp eax, 0
		je red_player
	jmp green_player

		red_player:
			lea edx, redPlayerString
			mov eax, redPlayerColor
			jmp end_print

		green_player:
			lea edx, greenPlayerString
			mov eax, greenPlayerColor
			jmp end_print

	end_print:
		call SetTextColor
		call WriteString
		mov eax, defaultColor
		call SetTextColor
		pop edx
		pop eax
		ret
PrintTurnString ENDP

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

GetRequestedSquare PROC
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
GetRequestedSquare ENDP

ActiveSquare PROC
	push eax
	push ecx

	mov eax, currentRow
	mov ecx, currentColumn

	mov requestedRow, eax
	mov requestedColumn, ecx
	call GetRequestedSquare
	
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
		je green_king
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
	lea edx, kingSquare

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