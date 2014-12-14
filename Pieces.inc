.code
Pieces_GetRequestedPiece PROC
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
Pieces_GetRequestedPiece ENDP

Pieces_GetPieceCounts PROC
	push eax
	push ebx
	push ecx

	mov RedPieceCount, 0
	mov GreenPieceCount, 0

	mov ecx, 0

	loop_start:
		lea eax, Pieces
		mov ebx, ecx
		imul ebx, 8
		add eax, ebx

		mov requestedPiece, eax
		call Pieces_GetRequestedPiece

		call Pieces_TrackPieceCount
		inc ecx
		cmp ecx, 24
	jl loop_start

	mov eax, RedPieceCount
	mov ebx, GreenPieceCount
	
	pop ecx
	pop ebx
	pop eax
	ret
Pieces_GetPieceCounts ENDP

Pieces_TrackPieceCount PROC
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
Pieces_TrackPieceCount ENDP