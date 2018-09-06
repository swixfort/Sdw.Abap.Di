CLASS zcl_di_container DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE .

  PUBLIC SECTION.

    CONSTANTS:
      co_default_namespace TYPE string VALUE `urn:default`.

    CLASS-METHODS create_default
      IMPORTING
                i_context          TYPE REF TO zcl_di_context OPTIONAL
                i_namespace        TYPE string DEFAULT co_default_namespace
      RETURNING VALUE(r_container) TYPE REF TO zcl_di_container.

    METHODS register
      IMPORTING
        i_class_name TYPE string.
    METHODS get_instance
      CHANGING
        c_target TYPE any.

  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA _context TYPE REF TO zcl_di_context.
    DATA _namespace TYPE string.

    METHODS:
      constructor
        IMPORTING
          i_context   TYPE REF TO zcl_di_context
          i_namespace TYPE string.

ENDCLASS.



CLASS zcl_di_container IMPLEMENTATION.
  METHOD constructor.

    me->_namespace = i_namespace.
    me->_context = i_context.
    IF me->_context IS NOT BOUND.
      me->_context = NEW #( ).
    ENDIF.

  ENDMETHOD.

  METHOD create_default.

    r_container = NEW #( i_context = i_context i_namespace = i_namespace ).

  ENDMETHOD.

  METHOD get_instance.

  ENDMETHOD.

  METHOD register.

  ENDMETHOD.

ENDCLASS.
