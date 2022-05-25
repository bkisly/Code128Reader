.include "setcarray.asm"
	
	# structure fields declaration
.eqv ImgInfo_fname	0
.eqv ImgInfo_hdrdat 	4
.eqv ImgInfo_imdat	8
.eqv ImgInfo_width	12
.eqv ImgInfo_height	16
.eqv ImgInfo_lbytes	20

.eqv MAX_IMG_SIZE	147456	# 768 * 64 * 3

.eqv BMPHeader_Size 54
.eqv BMPHeader_width 18
.eqv BMPHeader_height 22

.eqv system_OpenFile	1024
.eqv system_ReadFile	63
.eqv system_CloseFile	57
.eqv system_printString	4
.eqv system_printInt	1
.eqv system_printHex	34
.eqv system_printBin	35
.eqv system_terminate	10

	.data
imgInfo: .space	24	# deskryptor obrazu

	.align 2		# wyrównanie do granicy słowa
dummy:		.space 2
bmpHeader:	.space	BMPHeader_Size

	.align 2
imgData: 	.space	MAX_IMG_SIZE

ifname:	.asciz "cbarcode2.bmp"
newline:	.asciz	"\n"
err_wrongseq:	.asciz	"\nBarcode contains invalid sequence. Remember to load Code128C barcode.\n"
err_loadimg:	.asciz	"\nInvalid image file, try loading another image.\n"

	.text
main:
	# fill the struct
	la a0, imgInfo 
	la t0, ifname
	sw t0, ImgInfo_fname(a0)
	la t0, bmpHeader
	sw t0, ImgInfo_hdrdat(a0)
	la t0, imgData
	sw t0, ImgInfo_imdat(a0)
	jal read_bmp
	bnez a0, main_failure
	
	# set the pointer to (0, height / 2)
	
	la t0, imgInfo
	lw t1, ImgInfo_imdat(t0)
	lw t2, ImgInfo_height(t0)
	lw t3, ImgInfo_lbytes(t0)
	lw t4, ImgInfo_width(t0)
	
	mul t2, t2, t3
	srli t2, t2, 1
	add a1, t1, t2
	
	# find min bar length - base of the sequence
	slli a2, t4, 1
	add a2, a2, t4
	add a2, a2, a1
	jal find_min
	
	li a7, system_printInt
	ecall
	
	mv a2, a0
	jal write_line
	
	# write the sequence of decoded bar lengths
main_write_code:
	li a3, stop_code	# stop code
	
	mv a0, a2
	jal read_seq
	
	jal print_seq
	
	#li a7, system_printBin
	#ecall
	
	#mv a4, a0
	#jal write_line
	
	bne a0, a3, main_write_code
	b main_end
	
main_failure:
	la a0, err_loadimg
	li a7, system_printString
	ecall

main_end:
	li a7, system_terminate
	ecall
	

#============================================================================
# print_seq:
#	`prints the binary sequence of code 128
# arguments:
#	a0 - binary code 128 sequence
# returns:
#	nothing, may terminate the program in case of invalid sequence

print_seq:
	li t2, start_code
	li t3, stop_code
	
	beq a0, t2, print_seq_ret
	beq a0, t3, print_seq_ret
	
	la t0, setcarray
	add t0, t0, a0	# get the address of converted sequence value
	lb t1, (t0)
		
	bltz t1, print_seq_err
	
	li t2, 10
	li a7, system_printInt
	bge t1, t2, print_seq_write
	mv a0, zero
	ecall
	
print_seq_write:
	mv a0, t1
	ecall
	b print_seq_ret
	
print_seq_err:
	la a0, err_wrongseq
	li a7, system_printString
	ecall
	
	li a0, 1
	li a7, system_terminate
	ecall
	
print_seq_ret:
	jr ra
	

#============================================================================
# find_min:
# 	calculates min bar length, checking the whole image and moves the pointer to point the first bar
# arguments:
#	a2 - last pixel address, a1 - first pixel address
# returns:
#	a0 - minimum bar length

find_min:
	# skip quiet zone
	lbu t0, (a1)
	addi a1, a1, 3
	bnez t0, find_min
	
	# calculate min
	addi a1, a1, -3
	mv t0, a1	# stop modifying a1 from here, t0 stores the address
	mv t1, zero	# t1 stores previous pixel
	li t2, -1	# t2 stores current length
	li a0, 0x0fffffff	# a0 stores min length

find_min_loop:
	bge t0, a2, find_min_ret
	lbu t3, (t0)
	addi t0, t0, 3
	addi t2, t2, 1
	beq t3, t1, find_min_store_previous
	
	blt t2, a0, find_min_store_min
	mv t2, zero
	b find_min_store_previous
	
find_min_store_min:
	mv a0, t2
	mv t2, zero
	
find_min_store_previous:
	mv t1, t3
	b find_min_loop
	
find_min_ret:
	jr ra
	

#============================================================================
# read_seq:
# 	reads the bars sequence
# arguments:
#	a0 - min bar length
#	a1 - address from where to start reading
# returns:
# 	a0 - calculated sequence in hex format, 1 number per byte
#	a1 - moved pixel address

read_seq:
	mv t0, a0	# t0 stores min bar length
	mv a0, zero
	li t1, 6	# t1 stores the length of the bar-space sequence (3 bar-space pairs)
	mv t3, zero	# t3 stores previous pixel
	mv t4, zero	# t4 stores pixel counter
	mv t5, zero	# t5 stores bar counter
	
read_seq_loop:
	lbu t2, (a1)	# t2 stores current pixel
	bne t2, t3, read_seq_store
	addi t4, t4, 1
	b read_seq_store_previous
	
read_seq_store:
	addi a1, a1, -3
	divu t4, t4, t0
	addi t5, t5, 1
read_seq_store_loop:	
	beqz t4, read_seq_store_previous
	addi t4, t4, -1
	slli a0, a0, 1
	bnez t3, read_seq_store_loop
	addi a0, a0, 2
	b read_seq_store_loop

read_seq_store_previous:
	addi a1, a1, 3
	mv t3, t2
	bge t5, t1, read_seq_ret
	b read_seq_loop

read_seq_ret:
	srli a0, a0, 1
	jr ra
	
	
#============================================================================
# write_line:
#	prints the new line on the standard output

write_line:
	la a0, newline
	li a7, system_printString
	ecall
	
	jr ra
	
#============================================================================
# read_bmp: 
#	reads the content of a bmp file into memory
# arguments:
#	a0 - address of image descriptor structure
#		input filename pointer, header and image buffers should be set
# return value: 
#	a0 - 0 if successful, error code in other cases
read_bmp:
	mv t0, a0	# preserve imgInfo structure pointer
	
#open file
	li a7, system_OpenFile
    	lw a0, ImgInfo_fname(t0)	#file name 
    	li a1, 0					#flags: 0-read file
    	ecall
	
	blt a0, zero, rb_error
	mv t1, a0					# save file handle for the future
	
#read header
	li a7, system_ReadFile
	lw a1, ImgInfo_hdrdat(t0)
	li a2, BMPHeader_Size
	ecall
	
#extract image information from header
	lw a0, BMPHeader_width(a1)
	sw a0, ImgInfo_width(t0)
	
	# compute line size in bytes - bmp line has to be multiple of 4
	add a2, a0, a0
	add a0, a2, a0	# pixelbytes = width * 3 
	addi a0, a0, 3
	srai a0, a0, 2
	slli a0, a0, 2	# linebytes = ((pixelbytes + 3) / 4 ) * 4
	sw a0, ImgInfo_lbytes(t0)
	
	lw a0, BMPHeader_height(a1)
	sw a0, ImgInfo_height(t0)

#read image data
	li a7, system_ReadFile
	mv a0, t1
	lw a1, ImgInfo_imdat(t0)
	li a2, MAX_IMG_SIZE
	ecall

#close file
	li a7, system_CloseFile
	mv a0, t1
    	ecall
	
	mv a0, zero
	jr ra
	
rb_error:
	li a0, 1	# error opening file	
	jr ra
