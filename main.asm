TITLE MASM Template						(main.asm)

; Description:
; 
; Revision date:

INCLUDE Irvine32.inc
.data

defaultColor DWORD white+(black*16)

redSquareColor DWORD black+(red*16)
whiteSquareColor DWORD black+(white*16)
redPieceColor DWORD red+(white*16)
blackPieceColor DWORD black+(white*16)

emptySquare BYTE " ",0
filledSquare BYTE "O",0

endl BYTE 0dh,0ah,0

currentRow DWORD 0

requestedRow DWORD ?
requestedColumn DWORD ?
requestedSquare DWORD ?

rows DWORD 64 DUP (0Fh)

.code
main PROC
	mov rows+252, 0FFFFh
	jmp plot
	exit
main ENDP

plot PROC
	push edx
	push eax

	call rowLoop

	pop eax
	pop edx

	ret
plot ENDP

rowLoop PROC
	mov ecx, 8

	loop_start: 
		call columnLoop
		loop loop_start

	ret
rowLoop ENDP

columnLoop PROC
	mov currentRow,ecx
	push ecx
	push eax

	mov ecx, 0
	loop_start:
		mov eax, currentRow
		mov requestedRow, eax
		mov requestedColumn, ecx
		
		call getSquare

		mov eax, [requestedSquare]
		mov eax, [eax]

		inc ecx
		cmp ecx, 8

	jnge loop_start

	mov edx, OFFSET endl
	call WriteString

	pop eax
	pop ecx
	
	ret
columnLoop ENDP

getSquare PROC
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
getSquare ENDP

END main