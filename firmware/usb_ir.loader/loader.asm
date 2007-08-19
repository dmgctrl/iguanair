include "loader.inc"

; exported variables
export control_pkt
export buffer
export buffer_ptr
export tmp1
export tmp2
export tmp3

; TODO: must pin these down
AREA bss
buffer:
	BLK BUFFER_SIZE ; the main data buffer
buffer_ptr:
	BLK 1 ; current index into buffer

; temporary variables might as well be shared to save space
tmp1:
	BLK 1
tmp2:
	BLK 1
tmp3:
    BLK 1

; intentionally overlap the control packet buffer with the
; bytes needed for reflashing pages so that we KNOW what is
; being destroyed by the functions used for flashing.
; NOTE: does not get counted in "RAM % full"
AREA pkt_bss               (RAM, ABS, CON)
    org FIRST_FLASH_VAR
control_pkt:
	BLK PACKET_SIZE ; control packet buffer
