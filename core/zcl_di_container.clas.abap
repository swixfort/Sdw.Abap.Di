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
        i_class_name type string.
    methods get_instance
      changing
        c_target type any.

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

  ENDMETHOD.

  METHOD create_default.

  ENDMETHOD.

  METHOD get_instance.

  ENDMETHOD.

  METHOD register.

  ENDMETHOD.

ENDCLASS.
