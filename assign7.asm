; Program Description: Assignment #7 Assembly -Searching and Sorting
; Author: Austin English (Did not copy any of the functions shown in lecture)
; Creation Date: 5/3/16


.386 
.MODEL FLAT 
ExitProcess PROTO NEAR32 stdcall, dwExitCode:dword 
include io.h 
cr EQU 0dh ; cr = carriage return 
lf EQU 0ah ; lf = line feed 


.STACK 4096 

	
; MACRO: sets up stack data for the selection sort proc

callSelectionSort MACRO 

push	  OFFSET array	
push      LENGTHOF array
push      TYPE array
call	  selectionSort

ENDM

;MACRO: sets up stack data for printArray proc

callPrintArray MACRO

push	  OFFSET array
push      LENGTHOF array
push      TYPE array
call	  OutputArray

ENDM

; MACRO: sets up stack data for linear search proc

LinearSearch MACRO num

push OFFSET array
push LENGTHOF array
push TYPE array
push num
call LinearSerach

ENDM

; MACRO: used to input number to search for

inputNum MACRO

output Newline
output Prompt1
input  inputStr,16
atod   inputStr
mov searchNum, eax

ENDM
	

.DATA 


Prompt1 	BYTE "Enter an integer to search for: ",0 		; out prompt
prompt2         BYTE "Index #  ",0					; out prompt
strMod          BYTE 16 DUP(?)						; used for string manip

array	 	BYTE 4, 1, 7, 12, 8, 13, 9,  21				; array 
searchNum	DWORD ? 						; number to search for

inputStr 	BYTE 16 DUP (?) ; input string for numbers 		; input from user
answer		BYTE 12 DUP (0) ; sum in string form 			; answer(index)
Newline 	BYTE cr, lf, 0  ;new line			
right           BYTE "The number you selected is at index:",0		; out prompt
wrong           BYTE "The number you selected is not in the array",0	; out prompt
sort		BYTE "Performing selection sort!",0			; out prompt


.CODE 
_start: 

	
	mov ecx, 4			; count for number location(ran 4 times)
		
	callPrintArray			; MACRO call: ecx as count,esi as a pointer, and TYPE
					; *uses stack
Loop1:				

	 inputNum			; MACRO:  to input number to searchNum 
	 LinearSearch searchNum		; MACRO: pass in the search number
					; *uses stack
		
	 cmp 	  eax, 0		; if less than zero, not found in linear search
	 jl 	  Nfound1			
	
	 call 	  OutputRightData	; found dat output in proc
		
	 jmp 	  done1			; jump over not found data
	
nFound1: output   wrong			; not found output
					
done1:
	 output   Newline
	 loop 	  Loop1			; loop control 
	
	 output   Newline
	 output   sort			; output
	 output   NewLine
	
	 callSelectionSort		; MACRO: ecx = count, esi = array pointer,TYPE
					; *uses stack  Written by Austin English
	 output  Newline	
		
	 callPrintArray			; MACRO(same as above)
		
	 output  Newline
	
	 mov     edx, 4			; next loop control 
		
Loop2:   inputNum			; MACRO: input number
		
	 mov 	 esi, OFFSET array	; set up registers, *register proc
	 mov 	 ecx, LENGTHOF array
	 mov 	 edi, searchNum
	 call 	 BinarySearch		; call binary search (Written by Austin English)
		
		
	 cmp 	 eax, 0			; does the same as above if found or not found
	 jl 	 Nfound2
			
	 call 	 OutputRightData	; found
	 jmp 	 done2
			
nFound2: output  wrong			; not found
							
done2:
	 output  Newline
	 dec 	 edx
	 cmp 	 edx,0			; do while loop: too large for "loop" instruction
	 jle 	 endPro
	 jmp 	 Loop2
endPro:	
	 output Newline
		
		

INVOKE ExitProcess, 0 


PUBLIC _start



;--------------------------------------------------------------------------------
;selectionSort (WROTE BY AUSTIN ENGLISH)
;
; * helps the tortouse and hare problem with bubble sort + a little faster...
;
; does a selection sort on the data
; Receives: pushed count*dataSize and pushed array pointer, and pushed size type
; Returns : nothing, array formatted here
; Requires: ecx and esi values and a pushed size type
;--------------------------------------------------------------------------------
selectionSort PROC USES ecx edx eax ebx esi

		push 	ebp 
		mov     ebp,esp 		; need a ret
		
		mov  	esi, [ebp+36]		; grab array address
		mov  	ecx, [ebp+32]		; grab the count
		sub     esp,4
		mov	edx,[ebp + 28]
		mov	DWORD PTR [ebp-4],edx	; local var for the size
	
		sub	eax,eax			; saftey precausion
		mov 	edx, 0
		sub	ebx,ebx

jumpOuterLoop:	push	ecx			; push original count
		sub	ecx,[ebp-4] 		; use local for size
		cmp 	edx,ecx
		jge  	exitOuterLoop 		; edx is greater than array count
		mov	ebx,edx			; int index = i
				
		pop	ecx			; need to use orignal count
		add	eax,edx
		add	eax,[ebp-4] 
jumpInnerLoop:	cmp	eax,ecx
		jge	exitInnerLoop
		
		push 	edx			; save outter count
		mov	dl, [esi+eax]
		cmp 	dl, [esi+ebx]
		jge	L1
	
		mov	ebx,eax			; index = j	
L1:		pop	edx
		add	eax,[ebp-4] 
		jmp	jumpInnerLoop
		
exitInnerLoop:	
		push	ecx			; save array size
		mov	cl,[esi+ebx]		; smallerNum = array[index]
		mov	al,[esi+edx]
		mov	[esi+ebx],al		; arr[index] = arr[i]
		mov	[esi+edx],cl
		pop     ecx
		add	edx,[ebp-4]		; next element
		mov	eax,0
		
		
		jmp	jumpOuterLoop		; next iteration 

exitOuterLoop:
		pop 	ecx
		mov 	esp,ebp  		; free local space 
		pop 	ebp

ret 12
selectionSort ENDP


;-------------------------------------------------------------------------------------
;LinearSerach
; 
; searches the data one element at a time
; Receives: pushed esi PTR to array, pushed count and pushed TYPE and pushed searchNum
; Returns : EAX as either the found idndex or -1 if not found
; Requires: ecx with the count + array pointer ans search number and TYPE
;-------------------------------------------------------------------------------------
LinearSerach PROC USES  edx ecx esi ebx


		push 	ebp 
		mov     ebp,esp
		
		mov     ecx, [ebp + 32]		; count
		mov	esi, [ebp + 36]		; array PTR
		mov     edx, [ebp + 24]		; search element
		mov     eax, 0
		mov     ebx, 0
		
		L1:
		mov     bl, [esi]		; move elemnt into bl
		cmp     ebx,edx
		je 	finish			; if searchNum == array[index] : found
		add     esi, [ebp+28]		; add type to array
		inc     eax			; increment return index
		loop 	L1
		jmp 	notFound
	
notFound:       mov     eax,-1			;returns eax

		
finish:
		pop	ebp
ret 16
LinearSerach ENDP

;--------------------------------------------------------------------------------
;BinarySearch (WROTE BY AUSTIN ENGLISH) *could not get lecture copy to work
; 
; searches sorted data and finds the idex to return if found, -1 if not
; Receives: esi = array PTR, ecx = count, edi = searchNum
; Returns : eax as the index
; Requires: the above recieves to function properly 
;--------------------------------------------------------------------------------
BinarySearch PROC USES  ecx edx esi ebx edi
LOCAL start:DWORD, mid:DWORD, last:DWORD, storePTR:DWORD

		; local variables used ^
		
		mov 	start,0  		; int start = 0

		dec 	ecx
		mov  	last, ecx		; int last = array.length-1
		mov 	storePtr, esi
		

whilel:		mov 	esi, storePtr
		mov 	edx, start
		cmp 	edx, last
		jg   	exitl			; while(start<=end)

		mov 	eax, 0
		add 	eax, start
		add  	eax, last
		shr  	eax, 1			
		mov  	mid,eax			; int mid = (start + end)/2

		mov 	edx,0
		add 	esi, mid    		; add mid to array address
		mov 	dl, [esi]
		
		cmp 	edi,edx
		je  	numFound			
		jmp 	case2			; if(key==array[mid])

numFound:	mov 	eax, mid
		jmp 	done			; return mid

case2:          cmp 	edi,edx			; if(key<array[mid]
		jl  	shrinkLast
		jmp 	case3

shrinkLast:	mov 	ebx,0
		mov 	ebx, mid			
		dec 	ebx
		mov 	last, ebx		; end = mid - 1
		
		jmp 	whilel


case3:          mov 	ebx,0
		mov 	ebx, mid
		inc 	ebx
		mov 	start,ebx
		jmp 	whilel			; start = mid + 1

exitl:		mov 	eax, -1			; -1 returned


done:
		

ret 12
BinarySearch ENDP

;--------------------------------------------------------------------------------
;OutputArray
; 
; outputs data
; Receives: pushed LENGHTHOF, pushed array PTR, and pushed TYPE
; Returns : nothing, prints values
; Requires: ecx with the count*data size(in this case 4)
;--------------------------------------------------------------------------------
OutputArray PROC USES  eax ecx edx


		push 	ebp 
		mov     ebp,esp
		mov     ecx, [ebp + 24]		; count
		mov	esi, [ebp + 28]		; array PTR
	
		sub     eax, eax
		sub     edx, edx
		
	L1:	
		mov 	dl,[esi]		; mov value of array
		dtoa    answer,edx		
		call    concatArrayOutPut	; function call for formatting
		add	esi,[ebp+20]		; type of array
		inc     eax			; increment index for formatting
		loop    L1
		pop	ebp
		
ret 8
OutputArray ENDP

;--------------------------------------------------------------------------------
;concatArrayOutPut
; 
; puts multiple string together in the format "Index # eax + 'answer' "
; Receives: answer = edx array value, and eax as the index value
; Returns : nothing, prints array
; Requires: eax and the answer stord with array value
;--------------------------------------------------------------------------------
concatArrayOutPut PROC USES  esi eax ecx edx

	mov esi, OFFSET prompt2
	mov ecx, LENGTHOF prompt2
	mov edi, OFFSET strMod

	push eax		; push count
L1:	lodsb                   ; copy [ESI] into al
	stosb                   ; store al at [EDI]
	loop L1			; copy prompt2 to strMod
	
	pop eax
	or  eax,0FFFFFF30h	; convert the count to ascii
	
	add esi, 8		; size of strMod to get to end
	mov [esi],eax		; add the ascii number at the end
	inc esi			; move to next
	
	mov eax,":"		; move the : on the end
	mov [esi],eax
	
	mov edx,OFFSET answer	; get array and end now
	
	cmp dl, 10		; get rid of whiteSpace
	jg  L2
	jmp L3
	
L2:	add edx,9		; if number is over 9, get first char first
	inc esi
	mov eax, 20h		; put a space next, do both digits if 10 or more
	
	mov[esi],eax		; add space
	inc esi			; next spot
	mov eax,[edx]		; offset of answer into eax
	mov[esi],eax		; move into esi
	
L3:     inc esi			; otherwise get single char, do single digit in ascii
	inc edx
	mov eax,[edx]
	mov [esi],eax

	
	output strMod		; output combined string 
	output Newline
		
ret 
concatArrayOutPut ENDP

;--------------------------------------------------------------------------------
;OutputRightData
; 
; outputs data
; Receives: eax as index
; Returns : nothing, prints values
; Requires: eax
;--------------------------------------------------------------------------------
OutputRightData PROC USES  eax  

	output  right
	dtoa    answer,eax	;output right index if found from above 
	output  answer
		
ret 
OutputRightData ENDP


END