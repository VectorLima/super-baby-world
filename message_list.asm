@includefrom message_box_expansion.asm

        ; this table determines which message to show
        ; depending on the current level and screen number.
        ; this is what you're supposed to edit.

        ; just follow the format and you'll be good.

        ; example:
        ; dw $0105 : db $00 : dl Message04
        ; means "in level 105, screen 00, use Message04".



;  level   screen   message
dw $0105 : db $00 : dl Message05
dw $0105 : db $01 : dl Message06
dw $0105 : db $02 : dl Message07
dw $0105 : db $03 : dl Message08
dw $0105 : db $04 : dl Message09

dw $01CB : db $00 : dl Message10




