CLASS zcl_di_container DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE .

  PUBLIC SECTION.

    CONSTANTS co_default_namespace  TYPE string VALUE `urn:default`.
    CONSTANTS co_method_constructor TYPE string VALUE `CONSTRUCTOR`.
    CONSTANTS co_interface_or_class TYPE string VALUE `IC`.

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
    DATA new_parameter TYPE abap_parmbind.
    DATA parameters TYPE abap_parmbind_tab.
    DATA dependency TYPE REF TO data.


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

        DATA(class_name) = me->_context->get(
          i_namespace  = me->_namespace
          i_class_name = referenced_type ).

        class_descriptor ?= cl_abap_typedescr=>describe_by_name( class_name ).
        READ TABLE class_descriptor->methods ASSIGNING FIELD-SYMBOL(<method_description>) WITH KEY name = co_method_constructor.
        IF sy-subrc IS INITIAL.
          LOOP AT <method_description>-parameters ASSIGNING FIELD-SYMBOL(<parameter_description>).

            IF <parameter_description>-is_optional EQ abap_false
            AND <parameter_description>-parm_kind CA co_interface_or_class.

              DATA parameter_descriptor TYPE REF TO cl_abap_typedescr.

              parameter_descriptor = class_descriptor->get_method_parameter_type(
                  p_method_name = co_method_constructor
                  p_parameter_name = <parameter_description>-name ).

              IF parameter_descriptor->kind EQ cl_abap_typedescr=>kind_ref.
                reference_descriptor ?= parameter_descriptor.
                DATA(parameter_type) = reference_descriptor->get_referenced_type( )->get_relative_name( ).
              ENDIF.

              new_parameter-kind = <parameter_description>-parm_kind.
              new_parameter-name = <parameter_description>-name.

              CREATE DATA dependency TYPE REF TO (parameter_type).
              ASSIGN dependency->* TO FIELD-SYMBOL(<dependency>).

              me->get_instance( CHANGING c_target = <dependency> ).

*              GET REFERENCE OF dependency INTO new_parameter-value.
              new_parameter-value = dependency.
              INSERT new_parameter INTO TABLE parameters.

            ENDIF.
          ENDLOOP.

          IF parameters IS NOT INITIAL.
            TRY.
                CREATE OBJECT c_target TYPE (class_name)
                  PARAMETER-TABLE parameters.
              CATCH cx_sy_dyn_call_illegal_type.
              write `AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAH!!!!!`.
            ENDTRY.
          ELSE.
            CREATE OBJECT c_target TYPE (class_name).
          ENDIF.

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
