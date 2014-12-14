.code

Init_Checkers PROC
	
	call CreatePieces
	call Init_Board
	call Board_Replot
	ret
Init_Checkers ENDP

Init_Board PROC
	mov innerLoopAction, OFFSET Init_PlacePiece
	mov outerLoopAction, OFFSET Helpers_InnerLoop
	
	call Helpers_OuterLoop

	mov CreatePieceCount, 0

	ret
Init_Board ENDP


Init_PlacePiece proc
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
		call Init_AddPieceToBoard
		jmp endPiece

	evenRow:
		mov eax, [currentcolumn]
		mov ebx, 2
		div ebx
		cmp edx, 0
		je evenRowEvenColumn
		jmp endPiece

	evenRowEvenColumn:
		call Init_AddPieceToBoard
		jmp endPiece

	endPiece:
	pop edx
	pop ebx
	pop eax
	ret
Init_PlacePiece ENDP

Init_AddPieceToBoard PROC
	push eax
	push ebx
	push ecx
	
	mov eax, [currentRow]
	mov requestedRow, eax

	mov ebx, [currentColumn]
	mov requestedColumn, ebx

	call Board_GetRequestedSquare

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
Init_AddPieceToBoard ENDP



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
		call Init_CreatePiece
		inc ecx
		cmp ecx, 12
		jl loop_start
	
	pop ebx
	pop ecx
	ret
PiecesInnerLoop ENDP

Init_CreatePiece PROC
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
		;mov dword ptr[eax], 0FFFFFFFFh
	add eax, 4
	mov dword ptr[eax], 01h

	pop edx
	pop ecx
	pop ebx
	pop eax
	ret
Init_CreatePiece ENDP