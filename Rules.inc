.code
Rules_PerformCommand PROC

	mov JumpInitiated, 0
	mov MoveIsJump, 0
	mov	JumpIsAvailable, 0

	call Rules_VerifyInput

	call Rules_CheckDiagonal
	mov eax, InputErrorOccured
	cmp eax, 1
		je end_perform

	call Rules_CheckAdjacent
	mov eax, InputErrorOccured
	cmp eax, 1
		je jump

	jmp not_jump

	jump:
		call Rules_CheckTwoAway
		mov eax, InputErrorOccured
		cmp eax, 1
			je end_perform

	not_jump:
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
		
		mov eax, JumpInitiated
		cmp eax, 1
			je check_jump

		jmp after_check

	check_jump:
		call Rules_CheckValidJump
	
	after_check:
		call Rules_CheckPlayerJumpAvailable

		call Rules_RequiredJumpOccured
		mov eax, InputErrorOccured
		cmp eax, 1
			je end_perform

		call Rules_MovePiece

		mov eax, MoveIsJump
		cmp eax, 0
			je end_perform

		call Rules_RemoveJump

		call Rules_CheckShouldKing

	end_perform:
		ret
Rules_PerformCommand ENDP

Rules_VerifyInput PROC
	push eax

	mov eax, R1
	cmp eax, 7
		jg error_occured

	mov eax, C1
	cmp eax, 7
		jg error_occured

	mov eax, R2
	cmp eax, 7
		jg error_occured

	mov eax, C2
	cmp eax, 7
		jg error_occured

	jmp end_verify

	error_occured:
		mov InputErrorOccured, 1
		jmp end_verify

	end_verify:
		pop eax
		ret
Rules_VerifyInput ENDP


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

	NEG eax
	cmp eax, 1
		jg error_occured
		

	sub ebx, edx
	cmp ebx, 1
		jg error_occured

	NEG ebx
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

Rules_CheckTwoAway PROC
	push eax
	push ebx

	mov eax, R1
	sub eax, R2
	cmp eax, 2
		jg error_occured

	NEG eax
	cmp eax, 2
		jg error_occured

	mov eax, C1
	sub eax, C2
	cmp eax, 2
		jg error_occured

	NEG eax
	cmp eax, 2
		jg error_occured

	jump_init:
		mov JumpInitiated, 1
		mov InputErrorOccured, 0
		jmp end_check

	error_occured:
		mov InputErrorOccured, 1
		jmp end_check

	end_check:
		pop ebx
		pop eax
		ret
Rules_CheckTwoAway ENDP

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
		jne error_occured

	jmp end_check

	error_occured:
		mov InputErrorOccured, 1
		jmp end_check

	end_check:
		pop ebx
		pop eax
		ret
Rules_CheckDestination ENDP

Rules_CheckPlayerJumpAvailable PROC
	push eax
	push ebx
	push ecx
	push edx

	mov ecx, R1
	mov edx, C1

	mov outerLoopAction, OFFSET Helpers_InnerLoop
	mov innerLoopAction, OFFSET	Rules_CheckSquareJumpAvailable
	call Helpers_OuterLoop

	end_check:

		mov R1, ecx
		mov C1, edx

		pop edx
		pop ecx
		pop ebx
		pop eax
		ret
Rules_CheckPlayerJumpAvailable ENDP

Rules_CheckSquareJumpAvailable PROC
	push eax
	push ebx
	push ecx
	push edx

	mov eax, currentRow
	mov requestedRow, eax

	mov ebx, currentColumn
	mov requestedColumn, ebx

	call Board_GetRequestedSquare

	mov eax, [requestedSquare]
	mov eax, [eax]
	cmp eax, 0
		je end_check

	mov requestedPiece, eax
	call Pieces_GetRequestedPiece
	
	mov eax, requestedPieceID
	mov ebx, CurrentPlayerID
	cmp eax, ebx
	jne end_check

	mov eax, currentRow
	mov R1, eax

	mov ebx, currentColumn
	mov C1, ebx

	call Rules_CheckJumpAvailable

	end_check:
		pop edx
		pop ecx
		pop ebx
		pop eax
		ret
Rules_CheckSquareJumpAvailable ENDP

Rules_CheckJumpAvailable PROC
	push eax
	push ebx
	push ecx
	push edx

	mov eax, R1
	mov ebx, C1

	mov requestedRow, eax
	mov requestedColumn, ebx
	call Board_GetRequestedSquare

	mov eax, [requestedSquare]
	mov eax, [eax]

	mov requestedPiece, eax
	call Pieces_GetRequestedPiece

	mov eax, requestedPieceStatus
	cmp eax, 2
		je king
	jmp regular

	king:
		call Rules_CheckJumpAvailableKing
		jmp end_check

	regular:
		call Rules_CheckJumpAvailableRegular
		jmp end_check

	end_check:
		pop edx
		pop ecx
		pop ebx
		pop eax
		ret
Rules_CheckJumpAvailable ENDP

Rules_CheckJumpAvailableKing PROC
	push eax
	push ebx

	call Rules_CheckUpLeft
	mov eax, JumpIsAvailable
	cmp eax, 1
		je end_check

	call Rules_CheckUpRight
		mov eax, JumpIsAvailable
		cmp eax, 1
		je end_check

	call Rules_CheckDownLeft
		mov eax, JumpIsAvailable
		cmp eax, 1
		je end_check

	call Rules_CheckDownRight
		mov eax, JumpIsAvailable
		cmp eax, 1
		je end_check

	end_check:
		pop ebx
		pop eax
		ret
Rules_CheckJumpAvailableKing ENDP

Rules_CheckJumpAvailableRegular PROC
	push eax
	push ebx

	mov eax, CurrentPlayerID
	cmp eax, 0
		je red_player

	jmp green_player

	red_player:
		call Rules_CheckDownLeft
			mov eax, JumpIsAvailable
			cmp eax, 1
			je end_check

		call Rules_CheckDownRight
			mov eax, JumpIsAvailable
			cmp eax, 1
			je end_check

		jmp end_check
		

	green_player:
		call Rules_CheckUpLeft
			mov eax, JumpIsAvailable
			cmp eax, 1
				je end_check

		call Rules_CheckUpRight
			mov eax, JumpIsAvailable
			cmp eax, 1
			je end_check

		jmp end_check

	end_check:
		pop ebx
		pop eax
		ret
Rules_CheckJumpAvailableRegular ENDP

Rules_CheckUpLeft PROC
	push eax
	push ebx
	push ecx
	push edx

	mov eax, R1
	mov ebx, C1

	cmp eax, 1
		jle end_check

	cmp ebx, 1
		jle end_check

	sub eax, 1
	sub ebx, 1

	mov requestedRow, eax
	mov requestedColumn, ebx

	call Board_GetRequestedSquare

	mov ecx, eax
	mov edx, ebx

	mov eax, [requestedSquare]
	mov eax, [eax]
	cmp eax, 0
		je end_check

	mov requestedPiece, eax
	call Pieces_GetRequestedPiece
	
	mov eax, requestedPieceID
	mov ebx, CurrentPlayerID
	cmp eax, ebx
		je end_check

	mov ebx, edx
	mov eax, ecx

	sub eax, 1
	sub ebx, 1

	mov requestedRow, eax
	mov requestedColumn, ebx

	call Board_GetRequestedSquare

	mov eax, [requestedSquare]
	mov eax, [eax]
	cmp eax, 0
		jne end_check

	mov JumpIsAvailable, 1

	end_check:
		pop edx
		pop ecx
		pop ebx
		pop eax
		ret
Rules_CheckUpLeft ENDP

Rules_CheckUpRight PROC
	push eax
	push ebx
	push ecx
	push edx

	mov eax, R1
	mov ebx, C1

	cmp eax, 1
		jle end_check

	cmp ebx, 6
		jge end_check

	sub eax, 1
	add ebx, 1

	mov requestedRow, eax
	mov requestedColumn, ebx

	call Board_GetRequestedSquare

	mov ecx, eax
	mov edx, ebx

	mov eax, [requestedSquare]
	mov eax, [eax]
	cmp eax, 0
		je end_check

	mov requestedPiece, eax
	call Pieces_GetRequestedPiece
	
	mov eax, requestedPieceID
	mov ebx, CurrentPlayerID
	cmp eax, ebx
		je end_check

	mov ebx, edx
	mov eax, ecx

	sub eax, 1
	add ebx, 1

	mov requestedRow, eax
	mov requestedColumn, ebx

	call Board_GetRequestedSquare

	mov eax, [requestedSquare]
	mov eax, [eax]
	cmp eax, 0
		jne end_check

	mov JumpIsAvailable, 1

	end_check:
		pop edx
		pop ecx
		pop ebx
		pop eax
		ret
Rules_CheckUpRight ENDP

Rules_CheckDownLeft PROC
	push eax
	push ebx
	push ecx
	push edx

	mov eax, R1
	mov ebx, C1

	cmp eax, 6
		jge end_check

	cmp ebx, 1
		jle end_check

	add eax, 1
	sub ebx, 1

	mov requestedRow, eax
	mov requestedColumn, ebx

	call Board_GetRequestedSquare

	mov ecx, eax
	mov edx, ebx

	mov eax, [requestedSquare]
	mov eax, [eax]
	cmp eax, 0
		je end_check

	mov requestedPiece, eax
	call Pieces_GetRequestedPiece
	
	mov eax, requestedPieceID
	mov ebx, CurrentPlayerID
	cmp eax, ebx
		je end_check

	mov ebx, edx
	mov eax, ecx

	add eax, 1
	sub ebx, 1

	mov requestedRow, eax
	mov requestedColumn, ebx

	call Board_GetRequestedSquare

	mov eax, [requestedSquare]
	mov eax, [eax]
	cmp eax, 0
		jne end_check

	mov JumpIsAvailable, 1

	end_check:
		pop edx
		pop ecx
		pop ebx
		pop eax
		ret
Rules_CheckDownLeft ENDP

Rules_CheckDownRight PROC
	push eax
	push ebx
	push ecx
	push edx

	mov eax, R1
	mov ebx, C1

	cmp eax, 6
		jge end_check

	cmp ebx, 6
		jge end_check

	add eax, 1
	add ebx, 1

	mov requestedRow, eax
	mov requestedColumn, ebx

	call Board_GetRequestedSquare

	mov ecx, eax
	mov edx, ebx

	mov eax, [requestedSquare]
	mov eax, [eax]
	cmp eax, 0
		je end_check

	mov requestedPiece, eax
	call Pieces_GetRequestedPiece
	
	mov eax, requestedPieceID
	mov ebx, CurrentPlayerID
	cmp eax, ebx
		je end_check

	mov ebx, edx
	mov eax, ecx

	add eax, 1
	add ebx, 1

	mov requestedRow, eax
	mov requestedColumn, ebx

	call Board_GetRequestedSquare

	mov eax, [requestedSquare]
	mov eax, [eax]
	cmp eax, 0
		jne end_check

	mov JumpIsAvailable, 1

	end_check:
		pop edx
		pop ecx
		pop ebx
		pop eax
		ret
Rules_CheckDownRight ENDP

Rules_CheckValidJump PROC
	push eax
	push ebx

	mov eax, R1
	mov ebx, R2
	cmp eax, ebx
		jl down
	jmp up

	up:
		mov eax, C1
		mov ebx, C2
		cmp eax, ebx
			jl up_right
		jmp up_left

	up_right:
		call Rules_CheckUpRight
		jmp finish_check

	up_left:
		call Rules_CheckUpLeft
		jmp finish_check

	down:
		mov eax, C1
		mov ebx, C2
		cmp eax, ebx
			jl down_right
		jmp down_left

	down_right:
		call Rules_CheckDownRight
		jmp finish_check

	down_left:
		call Rules_CheckDownRight
		jmp finish_check

	finish_check:
		mov eax, JumpIsAvailable
		cmp eax, 1
			je is_jump

	is_jump:
		mov MoveIsJump, 1
		jmp end_check

	end_check:

		mov JumpIsAvailable, 0

		pop ebx
		pop eax
		ret
Rules_CheckValidJump ENDP

Rules_RequiredJumpOccured PROC
	push eax
	push ebx

	mov eax, MoveIsJump
	mov ebx, JumpIsAvailable
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
Rules_RequiredJumpOccured ENDP

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

Rules_RemoveJump PROC
	push eax
	push ebx

	mov eax, R1
	mov ebx, R2
	cmp eax, ebx
		jl down
	jmp up

	up:
		mov eax, C1
		mov ebx, C2
		cmp eax, ebx
			jl up_right
		jmp up_left

	up_right:
		mov eax, R1
		sub eax, 1

		mov ebx, C1
		add ebx, 1

		mov requestedRow, eax
		mov requestedColumn, ebx
		call Board_GetRequestedSquare
	
		mov eax, [requestedSquare]
		mov ecx, DWORD PTR [eax]

		mov ebx, [eax]
		add ebx, 4
		mov DWORD PTR [ebx], 0

		mov DWORD PTR [eax], 0

		jmp finish_check

	up_left:
		mov eax, R1
		sub eax, 1

		mov ebx, C1
		sub ebx, 1

		mov requestedRow, eax
		mov requestedColumn, ebx
		call Board_GetRequestedSquare
	
		mov eax, [requestedSquare]
		mov ecx, DWORD PTR [eax]

		mov ebx, [eax]
		add ebx, 4
		mov DWORD PTR [ebx], 0

		mov DWORD PTR [eax], 0

		jmp finish_check

	down:
		mov eax, C1
		mov ebx, C2
		cmp eax, ebx
			jl down_right
		jmp down_left

	down_right:
		mov eax, R1
		add eax, 1

		mov ebx, C1
		add ebx, 1

		mov requestedRow, eax
		mov requestedColumn, ebx
		call Board_GetRequestedSquare
	
		mov eax, [requestedSquare]
		mov ecx, DWORD PTR [eax]

		mov ebx, [eax]
		add ebx, 4
		mov DWORD PTR [ebx], 0

		mov DWORD PTR [eax], 0

		jmp finish_check

	down_left:
		mov eax, R1
		add eax, 1

		mov ebx, C1
		sub ebx, 1

		mov requestedRow, eax
		mov requestedColumn, ebx
		call Board_GetRequestedSquare
	
		mov eax, [requestedSquare]
		mov ecx, DWORD PTR [eax]

		mov ebx, [eax]
		add ebx, 4
		mov DWORD PTR [ebx], 0

		mov DWORD PTR [eax], 0

		jmp finish_check

	finish_check:
		mov JumpIsAvailable, 0

		pop ebx
		pop eax
		ret

Rules_RemoveJump ENDP

Rules_CheckShouldKing PROC
	push eax
	push ebx

	mov eax, R2
	mov ebx, C2

	mov R1, eax
	mov C1, ebx

	mov ebx, eax

	mov eax, CurrentPlayerID
	cmp eax, 0
		je player_0
	jmp player_1

	player_0:
		cmp ebx, 7
			je king

	player_1:
		cmp ebx, 0
			je king

	jmp end_check

	king:
		call Rules_KingPiece

	end_check:
		pop ebx
		pop ebx
		ret
Rules_CheckShouldKing ENDP

Rules_KingPiece PROC
	push eax
	push ebx

	mov eax, R1
	mov ebx, C1

	mov requestedRow, eax
	mov requestedColumn, ebx
	call Board_GetRequestedSquare
	
	mov eax, [requestedSquare]
	mov ecx, DWORD PTR [eax]

	mov ebx, [eax]
	add ebx, 4
	mov DWORD PTR [ebx], 2

	end_king:
		pop ebx
		pop ebx
		ret
Rules_KingPiece ENDP

Rules_SwapPlayers PROC
	push eax

	mov eax, R2
	mov R1, eax

	mov eax, C2
	mov C1, eax

	mov eax, MoveIsJump
	cmp eax, 0
		je perform_swap

	call Rules_CheckJumpAvailable

	mov eax, JumpIsAvailable
	cmp eax, 1
		je end_swap

	perform_swap:
		mov eax, CurrentPlayerID
		XOR eax, 000000001h
		mov CurrentPlayerID, eax

	end_swap:

		mov JumpIsAvailable, 0
		pop eax
		ret
Rules_SwapPlayers ENDP

Rules_EndIfWon PROC
	push eax

	call Pieces_GetPieceCounts
	
	mov eax, RedPieceCount
	
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