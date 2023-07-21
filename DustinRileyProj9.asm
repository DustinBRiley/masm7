INCLUDE Irvine32.inc

.386
.model flat,stdcall
.stack 4096
ExitProcess proto,dwExitCode:dword

.data
max = 100
source BYTE max+1 DUP (?)
target BYTE max+1 DUP (?)
sourcep BYTE "Enter source string (the string to search for): ", 0
targetp BYTE "Enter target string (the string to search from): ", 0
found BYTE "Source string found at position ", 0
found2 BYTE " in Target string (counting from zero).", 0
nfound BYTE "Source string not found in Target string.", 0
prompt BYTE "Do you want to do another search? y/n or Y/N: ", 0
error BYTE "Error ", 0
error2 BYTE " is not y/n or Y/N.", 0
indexs DWORD 0
indexp DWORD 0
pos DWORD 0
.code
Str_find proc s: ptr byte, t: ptr byte 
	mov esi, s
	mov edi, t
	S1:
		mov al, [esi]	; al = character at source[esi]
		mov dl, [edi]	; dl = character at target[edi]
		cmp al, 0		; end of source?
		je S4			; yes: jump to S4
		cmp dl, 0		; no: end of target?
		je S5			; yes: jump to S5
		cmp al,dl		; no: characters equal?
		jne S3			; no: jump to S3
		inc esi			; yes: point to next in source
		inc indexs		; increase indexs
		inc edi			; point to next in target
		inc indexp		; increase indexp
		jmp S1			; jump to S1
	S3:
		mov esi, s		; set esi back to start of source
		mov ecx, indexs	; move indexs to register
		sub edi, ecx	; go back by indexs
		sub indexp, ecx	; go back by indexs
		inc edi			; point to next in target
		inc indexp		; increase indexp
		mov indexs, 0	; reset count
		jmp S1
	S4:
		mov ecx, indexs	; move indexs to register
		sub indexp, ecx	; go back by indexs
		mov eax, indexp	; save indexp to eax
		mov indexs, 0	; reset indexs
		cmp indexs, 0	; set zero flag
		ret			
	S5:
		mov al, 0
		cmp al, 1		; unset zero flag
		ret
Str_find endp

main proc
	L1:
		mov edx, OFFSET sourcep						; write out sourcep
		call writestring
		mov ecx, max								; set max string size
		mov edx, OFFSET source						; read in string to source
		call readstring
		mov edx, OFFSET targetp						; write out targetp
		call writestring
		mov ecx, max								; set max string size
		mov edx, OFFSET target						; read in string to target
		call readstring
		invoke Str_find, ADDR source, ADDR target	; call Str_find, send source and target addresses
		jnz notFound								; if zero flag is not set source was not found inside target
		mov pos, eax								; store the position value
		mov edx, OFFSET found						; write out found
		call writestring
		mov eax, pos								; write out pos
		call writedec
		mov edx, OFFSET found2						; write out found2
		call writestring
		call crlf									; write new line
		call crlf									; write new line
		jmp con
	notFound:
		mov edx, OFFSET nfound						; write out nfound
		call writestring
		call crlf									; write new line
		call crlf									; write new line
		jmp con
	con:
		mov edx, OFFSET prompt						; write out prompt
		call writestring
		call readchar								; reads character from keyboard to al
		call crlf									; write new line
		cmp al, 121									; compare character to ascii y (121)
		je L2										; jump if equal, to L2
		cmp al, 89									; compare character to ascii Y (89)
		je L2										; jump if equal, to L2
		cmp al, 110									; compare character to ascii n (110)
		je L3										; jump if equal, to L3
		cmp al, 78									; compare character to ascii N (78)
		je L3										; jump if equal, to L3
		mov edx, OFFSET error						; write out error
		call writestring
		call writechar								; write out character
		mov edx, OFFSET error2						; write out error2
		call writestring
		call crlf									; write new line
		jmp con										; jump to con (y/n or Y/N not entered)
	L2:
		mov ecx, 0
		reset:
			mov [byte ptr source + ecx], 0
			mov [byte ptr target + ecx], 0
			inc ecx
			cmp ecx, max+1
			jb reset
		mov pos, 0
		mov indexp, 0
		jmp L1
	L3:
		call crlf									; write new line
		call waitmsg
	invoke ExitProcess, 0
main endp
end main