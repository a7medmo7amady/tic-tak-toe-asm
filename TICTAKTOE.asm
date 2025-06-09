; Tic Tac Toe Game in x86 Assembly
; Fixed and improved version

org 100h

.DATA
    grid db '1','2','3'     ; 3x3 game board
         db '4','5','6'
         db '7','8','9'
         
    currentPlayer db ?       ; Current player ('x' or 'o')
    welcomeMsg db 'Welcome to Tic Tac Toe! $'   
    inputMsg db 'Enter position (1-9), Player $'
    turnMsg db "'s turn: $"
    invalidMsg db 'Invalid move! Try again.$'
    drawMsg db 'Game ended in draw! $'
    winMsg db 'Player $'  
    wonMsg db ' wins! $'
    newline db 0Dh, 0Ah, '$' ; Carriage return + line feed

.CODE
main:
    mov cx, 9               ; Maximum 9 moves in Tic Tac Toe
    
gameLoop:
    call clearScreen
    call printWelcome
    call printBoard
    
    ; Determine current player (alternates between x and o)
    mov bx, cx
    and bx, 1
    jz playerO
    mov currentPlayer, 'x'
    jmp getInput
playerO:
    mov currentPlayer, 'o'

getInput:
    call printInputPrompt
    
    ; Read player input
    mov ah, 1
    int 21h
    
    ; Validate input (1-9)
    cmp al, '1'
    jb invalidInput
    cmp al, '9'
    ja invalidInput
    
    ; Check if position is available
    mov bx, 0
    mov cx, 9
checkPosition:
    cmp [grid + bx], al
    je positionFound
    inc bx
    loop checkPosition
    
    ; Position not found (shouldn't happen with valid input)
    jmp invalidInput
    
positionFound:
    ; Mark the position with player's symbol
    mov dl, currentPlayer
    mov [grid + bx], dl
    
    ; Check for win condition
    call checkWin
    cmp al, 1              ; checkWin returns 1 in AL if win detected
    je gameOver
    
    ; Continue game loop
    mov cx, bx             ; Preserve counter
    loop gameLoop
    
    ; If we get here, it's a draw
    call printDraw
    jmp exitGame

invalidInput:
    call printNewLine
    lea dx, invalidMsg
    mov ah, 9
    int 21h
    call printNewLine
    jmp getInput

gameOver:
    call clearScreen
    call printBoard
    call printWinMessage

exitGame:
    ; Wait for any key press before exiting
    mov ah, 0
    int 16h
    ret

; --------------------------
; Subroutine: printWelcome
; Prints welcome message
; --------------------------
printWelcome:
    lea dx, welcomeMsg
    mov ah, 9
    int 21h
    call printNewLine
    ret

; --------------------------
; Subroutine: printBoard
; Displays the current game board
; --------------------------
printBoard:
    mov bx, 0
    mov cx, 3               ; 3 rows
    
printRow:
    push cx
    call printNewLine
    
    mov cx, 3               ; 3 columns per row
printCol:
    mov dl, [grid + bx]
    mov ah, 2
    int 21h
    
    ; Print space between cells
    mov dl, ' '
    int 21h
    
    inc bx
    loop printCol
    
    pop cx
    loop printRow
    
    call printNewLine
    ret

; --------------------------
; Subroutine: printInputPrompt
; Shows which player's turn it is
; --------------------------
printInputPrompt:
    call printNewLine
    lea dx, inputMsg
    mov ah, 9
    int 21h
    
    mov dl, currentPlayer
    mov ah, 2
    int 21h
    
    lea dx, turnMsg
    mov ah, 9
    int 21h
    ret

; --------------------------
; Subroutine: printWinMessage
; Displays the winner message
; --------------------------
printWinMessage:
    lea dx, winMsg
    mov ah, 9
    int 21h
    
    mov dl, currentPlayer
    mov ah, 2
    int 21h
    
    lea dx, wonMsg
    mov ah, 9
    int 21h
    ret

; --------------------------
; Subroutine: printDraw
; Displays draw message
; --------------------------
printDraw:
    call printNewLine
    lea dx, drawMsg
    mov ah, 9
    int 21h
    ret

; --------------------------
; Subroutine: printNewLine
; Prints CR+LF
; --------------------------
printNewLine:
    lea dx, newline
    mov ah, 9
    int 21h
    ret

; --------------------------
; Subroutine: clearScreen
; Clears the console screen
; --------------------------
clearScreen:
    mov ax, 3
    int 10h
    ret

; --------------------------
; Subroutine: checkWin
; Checks all possible win conditions
; Returns: AL=1 if win detected, AL=0 otherwise
; --------------------------
checkWin:
    ; Check rows
    mov bl, [grid]
    cmp bl, [grid+1]
    jne checkRow2
    cmp bl, [grid+2]
    je winDetected
    
checkRow2:
    mov bl, [grid+3]
    cmp bl, [grid+4]
    jne checkRow3
    cmp bl, [grid+5]
    je winDetected
    
checkRow3:
    mov bl, [grid+6]
    cmp bl, [grid+7]
    jne checkCol1
    cmp bl, [grid+8]
    je winDetected
    
    ; Check columns
checkCol1:
    mov bl, [grid]
    cmp bl, [grid+3]
    jne checkCol2
    cmp bl, [grid+6]
    je winDetected
    
checkCol2:
    mov bl, [grid+1]
    cmp bl, [grid+4]
    jne checkCol3
    cmp bl, [grid+7]
    je winDetected
    
checkCol3:
    mov bl, [grid+2]
    cmp bl, [grid+5]
    jne checkDiag1
    cmp bl, [grid+8]
    je winDetected
    
    ; Check diagonals
checkDiag1:
    mov bl, [grid]
    cmp bl, [grid+4]
    jne checkDiag2
    cmp bl, [grid+8]
    je winDetected
    
checkDiag2:
    mov bl, [grid+2]
    cmp bl, [grid+4]
    jne noWin
    cmp bl, [grid+6]
    jne noWin
    
winDetected:
    mov al, 1
    ret
    
noWin:
    mov al, 0
    ret

end main