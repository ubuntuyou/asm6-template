;;;;;;;;;;;;;;;;;;;;;;;
;;;   iNES HEADER   ;;;
;;;;;;;;;;;;;;;;;;;;;;;

    .db  "NES", $1a     ;identification of the iNES header
    .db  PRG_COUNT      ;number of 16KB PRG-ROM pages
    .db  $02            ;number of 8KB CHR-ROM pages
    .db  $00|MIRRORING  ;mapper 0 and mirroring
    .dsb $09, $00       ;clear the remaining bytes

    .fillvalue $FF      ; Sets all unused space in rom to value $FF

;;;;;;;;;;;;;;;;;;;;;
;;;   VARIABLES   ;;;
;;;;;;;;;;;;;;;;;;;;;

    .enum $0000 ; Zero Page variables

somePointer     .dsb 2

    .ende

    .enum $0400 ; Variables at $0400. Can start on any RAM page

sleeping        .dsb 1

    .ende
;;;;;;;;;;;;;;;;;;;;;
;;;   CONSTANTS   ;;;
;;;;;;;;;;;;;;;;;;;;;

PRG_COUNT       = 2       ;1 = 16KB, 2 = 32KB
MIRRORING       = %0001   ;%0000 = horizontal, %0001 = vertical, %1000 = four-screen

PPU_Control     .equ $2000
PPU_Mask        .equ $2001
PPU_Status      .equ $2002
PPU_Scroll      .equ $2005
PPU_Address     .equ $2006
PPU_Data        .equ $2007

    .org $8000
;;;;;;;;;;;;;;;;;
;;;   RESET   ;;;
;;;;;;;;;;;;;;;;;

RESET:
    sei
    cld
    lda #$40
    sta $4017
    lda #$FF
    pha
    lda #$00
    sta PPU_Control
    sta PPU_Mask
    sta $4010
    
vblank1:
    bit PPU_Status
    bpl vblank1

clrmem:
    lda #$00
    sta $0000,x
    sta $0100,x
    sta $0300,x
    sta $0400,x
    sta $0500,x
    sta $0600,x
    sta $0700,x
    lda #$FE
    sta $0200,x
    inx
    bne clrmem

vblank2:
    bit PPU_Status
    bpl vblank2
    
    ;  INIT code goes here

    jmp MAIN
    
;;;;;;;;;;;;;;;;;;;;;;;
;;;   SUBROUTINES   ;;;
;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;
;;;   MAIN   ;;;
;;;;;;;;;;;;;;;;

MAIN:
    inc sleeping
loop:
    lda sleeping
    bne loop
    
    ; Game logic goes here

    jmp MAIN
MAINdone:

;;;;;;;;;;;;;;;
;;;   NMI   ;;;
;;;;;;;;;;;;;;;

NMI:
    pha
    txa
    pha
    tya
    pha

    lda #$00
    sta $2003
    lda #$02
    sta $4014

    lda #$00
    sta PPU_Address
    sta PPU_Address

    lda #$00
    sta PPU_Scroll
    sta PPU_Scroll

    lda #%10010000
    sta PPU_Control
    lda #%00011110
    sta PPU_Mask
    dec sleeping

    pla
    tay
    pla
    tax
    pla
    rti
NMIdone

;;;;;;;;;;;;;;;
;;;   ETC   ;;;
;;;;;;;;;;;;;;;

    .pad $C000
palette:
    .db $0F,$00,$07,$10,  $0F,$31,$21,$11,  $0F,$07,$1A,$39,  $0F,$0C,$16,$30   ;;background palette
    .db $31,$27,$17,$07,  $0F,$20,$10,$00,  $0F,$1C,$15,$14,  $0F,$02,$38,$3C   ;;sprite palette

;;;;;;;;;;;;;;;;;;;
;;;   VECTORS   ;;;
;;;;;;;;;;;;;;;;;;;

    .pad $FFFA

    .dw NMI
    .dw RESET
    .dw 0


;;;;;;;;;;;;;;;;;;;
;;;   CHR-ROM   ;;;
;;;;;;;;;;;;;;;;;;;

    .incbin ""

