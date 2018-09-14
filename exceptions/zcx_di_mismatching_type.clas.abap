class zcx_di_mismatching_type definition
  public
  inheriting from zcx_di
  final
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional .
  protected section.
  private section.
ENDCLASS.



CLASS ZCX_DI_MISMATCHING_TYPE IMPLEMENTATION.


  method constructor ##adt_suppress_generation.
    call method super->constructor
      exporting
        previous = previous.
    clear me->textid.
    if textid is initial.
      if_t100_message~t100key = if_t100_message=>default_textid.
    else.
      if_t100_message~t100key = textid.
    endif.
  endmethod.
ENDCLASS.