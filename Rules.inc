.code

Rules_MovePiece PROC
	push eax
	push ebx
	push ecx

	mov eax, R1
	mov ebx, C1

	mov requestedRow, eax
	mov requestedColumn, ebx
	call Board_GetRequestedSquare
	
	mov eax, [requestedSquare]
	mov ecx, DWORD PTR [eax]
	mov DWORD PTR [eax], 0

	mov eax, R2
	mov ebx, C2

	mov requestedRow, eax
	mov requestedColumn, ebx
	call Board_GetRequestedSquare

	mov eax, [requestedSquare]
	;mov eax, [eax]
	mov DWORD PTR [eax], ecx

	pop ecx
	pop ebx
	pop eax
	ret
Rules_MovePiece ENDP

Rules_PerformCommand PROC
	
	call Rules_CheckDiagonal
	mov eax, InputErrorOccured
	cmp eax, 1
		je end_perform

	call Rules_CheckAdjacent
	mov eax, InputErrorOccured
	cmp eax, 1
		je end_perform

	call Rules_CheckSource
	mov eax, InputErrorOccured
	cmp eax, 1
		je end_perform

	call Rules_CheckDirection
	mov eax, InputErrorOccured
	cmp eax, 1
		je end_perform

	call Rules_CheckDestination
	mov eax, InputErrorOccured
	cmp eax, 1
		je end_perform

	call Rules_MovePiece

	end_perform:
		ret
Rules_PerformCommand ENDP

Rules_SwapPlayers PROC
	push eax
		mov eax, CurrentPlayerID
		XOR eax, 000000001h
		mov CurrentPlayerID, eax
	pop eax
	ret
Rules_SwapPlayers ENDP

Rules_CheckIfError PROC
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

		call Output_PrintNewLine
		jmp end_check

		no_error:
			call Rules_SwapPlayers
			jmp end_check
	end_check:
		mov InputErrorOccured, 0
		pop eax
		ret
Rules_CheckIfError ENDP

Rules_CheckDiagonal PROC
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
Rules_CheckDiagonal ENDP

Rules_CheckAdjacent PROC
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
Rules_CheckAdjacent ENDP

Rules_CheckSource PROC
	push eax
	push ebx

	mov eax, R1
	mov ebx, C1

	mov requestedRow, eax
	mov requestedColumn, ebx
	call Board_GetRequestedSquare

	mov eax, [requestedSquare]
	mov eax, [eax]
	cmp eax, 0
		je error_occured

	mov requestedPiece, eax
	call Pieces_GetRequestedPiece
	
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
Rules_CheckSource ENDP

Rules_CheckDirection Proc
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
Rules_CheckDirection ENDP

Rules_CheckDestination PROC
	push eax
	push ebx

	mov eax, R2
	mov ebx, C2

	mov requestedRow, eax
	mov requestedColumn, ebx
	call Board_GetRequestedSquare

	mov eax, [requestedSquare]
	mov eax, [eax]
	cmp eax, 0
		je move_standard

	mov requestedPiece, eax
	call Pieces_GetRequestedPiece
	
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
Rules_CheckDestination ENDP

Rules_EndIfWon PROC
	push eax

	call Pieces_GetPieceCounts
	
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

Rules_EndIfWon ENDP