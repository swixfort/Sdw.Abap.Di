CLASS zcl_di_container DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE .

  PUBLIC SECTION.

    CONSTANTS co_default_namespace  TYPE string VALUE `urn:default`.
    CONSTANTS co_method_constructor TYPE string VALUE `CONSTRUCTOR`.

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

    DATA reference_descriptor TYPE REF TO cl_abap_refdescr.
    DATA class_descriptor TYPE REF TO cl_abap_classdescr.

    IF c_target IS BOUND.
      RAISE EXCEPTION TYPE zcx_di_target_already_bound.
    ENDIF.

    " 1. get interface/class name
    DATA(type_descriptor) = cl_abap_typedescr=>describe_by_data( c_target ).
    IF type_descriptor->kind NE cl_abap_typedescr=>kind_ref.
      " TODO: No reference, what shall we do?
      RETURN.
    ENDIF.

    reference_descriptor ?= type_descriptor.
    DATA(referenced_type) = reference_descriptor->get_referenced_type( )->get_relative_name( ).

    type_descriptor = type_descriptor->describe_by_name( referenced_type ).

    CASE type_descriptor->kind.
      WHEN cl_abap_typedescr=>kind_class
        OR cl_abap_typedescr=>kind_intf.

        " 2. get class name
        DATA(class_name) = me->_context->get(
          i_namespace  = me->_namespace
          i_class_name = referenced_type ).

        " 3. constructor?
        class_descriptor ?= cl_abap_typedescr=>describe_by_name( class_name ).
        READ TABLE class_descriptor->methods ASSIGNING FIELD-SYMBOL(<method_description>) WITH KEY name = co_method_constructor.
        IF sy-subrc IS INITIAL.
          " 3.1 get params of constructor
          " 3.2
        ELSE.
          CREATE OBJECT c_target TYPE (class_name).
        ENDIF.

      WHEN OTHERS.
    ENDCASE.

  ENDMETHOD.

  METHOD register.

    IF cl_abap_typedescr=>describe_by_name( i_class_name )->kind NE cl_abap_typedescr=>kind_class.
      RAISE EXCEPTION TYPE zcx_di_not_a_class.
    ENDIF.

    me->_context->add( i_class_name = i_class_name i_namespace = me->_namespace ).

  ENDMETHOD.

ENDCLASS.
