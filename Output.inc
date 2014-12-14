.code
Output_PrintEmptyWhite PROC
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
Output_PrintEmptyWhite ENDP

;*****************************************************************

Output_PrintEmptyRed PROC
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
Output_PrintEmptyRed ENDP

;*****************************************************************

Output_PrintRedPiece PROC
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
Output_PrintRedPiece ENDP

;*****************************************************************

Output_PrintRedKing PROC
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
Output_PrintRedKing ENDP

;*****************************************************************

Output_PrintGreenPiece PROC
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
Output_PrintGreenPiece ENDP

;*****************************************************************

Output_PrintGreenKing PROC
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
Output_PrintGreenKing ENDP

;*****************************************************************

Output_PrintNewLine PROC
	push eax
	push edx

	lea edx, endl
	call WriteString

	mov eax, defaultColor
	call SetTextColor

	pop edx
	pop eax
	ret
Output_PrintNewLine ENDP

Output_PrintTurnString PROC
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
Output_PrintTurnString ENDP
