
    CLASS
      STYLE
          COLOR 8 135 68
          SYMBOL 'bordje'
          color 8 135 68
          outlinecolor 255 255 255
          size 30
      END
      LABEL
        EXPRESSION ('[hectometer]' ~ '.')
        TEXT '[hectometer]' 
        ALIGN right
        COLOR  255 255 255
        FONT "anwb-uu"
        TYPE truetype
        SIZE 8
        OFFSET 0 7
        POSITION cc
        PARTIALS true
        FORCE true
      END
      LABEL
        EXPRESSION (('[wegnummer]' ~ '.') AND ('[wegnummer]' ~* 'A'))
        TEXT '[wegnummer]'
        ALIGN left   
        COLOR  255 255 255
        FONT "anwb-uu"
        TYPE truetype
        SIZE 8
        OFFSET 0 -6
        POSITION cc 
        PARTIALS true
        FORCE true
        #BUFFER 12        
        STYLE
          GEOMTRANSFORM 'labelpoly'
          OUTLINECOLOR 255 255 255
          WIDTH 2
        END
        STYLE
          GEOMTRANSFORM 'labelpoly'
          COLOR 255 0 0
          WIDTH 1
        END
      END
      LABEL
        EXPRESSION (('[wegnummer]' ~ '.') AND ('[wegnummer]' ~* 'N'))
        TEXT '[wegnummer]'
        ALIGN right   
        COLOR  0 0 0
        FONT "anwb-uu"
        TYPE truetype
        SIZE 8
        OFFSET 0 -6
        POSITION cc 
        PARTIALS true
        FORCE true
        #BUFFER 12        
        STYLE
          GEOMTRANSFORM 'labelpoly'
          COLOR 255 186 0
          WIDTH 3
        END
      END      
    END     
