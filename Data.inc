.data

;======Strings======
endl BYTE 0dh,0ah,0
columnHeader BYTE " 01234567", 0
rowHeader BYTE " ",0
inputString BYTE 0dh, 0ah, "Please Enter Command as 4 digit number...", 0dh, 0ah, "Enter using format: SrcRow_SrcCol_DstRow_DstCol", 0dh,0ah, "Example: 0123", 0dh,0ah, "Command: ",0
errorString BYTE 0dh, 0ah, "That is an invalid move. ",0

redCountString BYTE 09h, "Red: ",0
greenCountString BYTE 09h, "Green: ",0

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

;======Command=======
Userinput DWORD 0
R1 DWORD 0
C1 DWORD 0
R2 DWORD 0
C2 DWORD 0
;====================

Pieces DWORD 48 DUP (0)
Rows DWORD 64 DUP (0)

outerLoopAction DWORD 0
innerLoopAction DWORD 0

currentRow DWORD 0
currentColumn DWORD 0

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

JumpInitiated DWORD 0
MoveIsJump DWORD 0
JumpIsAvailable DWORD 0

CurrentPlayerID DWORD 0