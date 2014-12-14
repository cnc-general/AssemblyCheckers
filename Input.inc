.code

Input_GetCommand PROC
	call Input_PromptCommand
	call Input_ReadCommand
	ret
Input_GetCommand ENDP

Input_PromptCommand PROC
	push edx
		lea edx, inputString
		call WriteString
	pop edx
	ret
Input_PromptCommand ENDP

Input_ReadCommand PROC
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
Input_ReadCommand ENDP