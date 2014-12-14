.code
Board_Replot PROC
	push edx
	push eax

	call Clrscr
	call Output_PrintTurnString

	lea edx, columnHeader
	call WriteString
	call Output_PrintNewLine

	mov outerLoopAction, OFFSET Board_ReplotBoardOuterAction
	mov innerLoopAction, OFFSET	Board_CreateSquare
	call Helpers_OuterLoop

	pop eax
	pop edx

	ret
Board_Replot ENDP

Board_ReplotBoardOuterAction PROC
	push eax
	mov eax, ecx
	call WriteDec

	call Helpers_InnerLoop
	call Output_PrintNewLine

	pop eax
	ret
Board_ReplotBoardOuterAction ENDP

Board_CreateSquare PROC								; printEmptyRed  printEmptyWhite
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
		je evenRowOddColumn
		jmp evenRowEvenColumn

	evenRowOddColumn:
		call Output_PrintEmptyRed
		jmp endBoard

	evenRowEvenColumn:
		call Board_ActiveSquare
		jmp endBoard

	oddRow:
		mov eax,currentColumn
		xor edx,edx
		mov ebx,2
		div ebx

		cmp edx,1

		je oddRowOddColumn
		jmp oddRowEvenColumn

	oddRowEvenColumn:
		call Output_PrintEmptyRed
		jmp endBoard

	oddRowOddColumn:
		call Board_ActiveSquare
		jmp endBoard

	endBoard:
		pop ecx
		pop eax
		ret
Board_CreateSquare ENDP

Board_GetRequestedSquare PROC
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
Board_GetRequestedSquare ENDP

Board_ActiveSquare PROC
	push eax
	push ecx

	mov eax, currentRow
	mov ecx, currentColumn

	mov requestedRow, eax
	mov requestedColumn, ecx
	call Board_GetRequestedSquare
	
	mov eax, [requestedSquare]
	mov eax, [eax]
	cmp eax,0
	je emptyActiveSquare

	jmp checkPiece

	emptyActiveSquare:
		call Output_PrintEmptyWhite
		jmp endActiveSquare

	checkPiece:
		mov requestedPiece, eax
		call Pieces_GetRequestedPiece

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
		call Output_PrintRedPiece
		jmp endActiveSquare

	red_king:
		call Output_PrintRedKing
		jmp endActiveSquare

	is_green:
		mov eax, requestedPieceStatus
		cmp eax, 2
		je green_king
		jmp green_piece

	green_piece:
		call Output_PrintGreenPiece
		jmp endActiveSquare

	green_king:
		call Output_PrintGreenKing
		jmp endActiveSquare

	endActiveSquare:
		pop ecx
		pop eax
		ret
Board_ActiveSquare ENDP