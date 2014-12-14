.code
Helpers_OuterLoop PROC
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
Helpers_OuterLoop ENDP


Helpers_InnerLoop PROC
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
Helpers_InnerLoop ENDP