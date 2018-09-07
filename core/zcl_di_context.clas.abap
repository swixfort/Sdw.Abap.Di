CLASS zcl_di_context DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_class_register_entity,
        time_added TYPE timestampl,
        namespace  TYPE string,
        class_name TYPE string,
      END OF ty_class_register_entity,

      ty_class_register TYPE STANDARD TABLE OF ty_class_register_entity WITH KEY time_added.

    METHODS add
      IMPORTING
        i_namespace  TYPE string
        i_class_name TYPE string.

    METHODS get
      IMPORTING
                i_namespace         TYPE string
                i_class_name        TYPE string
      RETURNING VALUE(r_class_name) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA:
      _class_register TYPE ty_class_register,
      _new_entity     TYPE ty_class_register_entity.

ENDCLASS.



CLASS zcl_di_context IMPLEMENTATION.

  METHOD add.

    GET TIME STAMP FIELD me->_new_entity-time_added.
    me->_new_entity-namespace = i_namespace.
    me->_new_entity-class_name = i_class_name.
    TRANSLATE me->_new_entity-class_name TO UPPER CASE.

    INSERT me->_new_entity INTO me->_class_register INDEX 1.

  ENDMETHOD.

  METHOD get.

    DATA interface_descriptor TYPE REF TO cl_abap_intfdescr.

    FIELD-SYMBOLS <class_register_entity> TYPE ty_class_register_entity.

    LOOP AT me->_class_register
        ASSIGNING <class_register_entity>
        WHERE namespace EQ i_namespace.

      IF <class_register_entity>-class_name EQ i_class_name.
        r_class_name = i_class_name.
        EXIT.
      ENDIF.

      interface_descriptor ?= cl_abap_intfdescr=>describe_by_name( i_class_name ).

      IF interface_descriptor->applies_to_class( <class_register_entity>-class_name ).
        r_class_name = <class_register_entity>-class_name.
        EXIT.
      ENDIF.

    ENDLOOP.

    IF r_class_name IS INITIAL.
      RAISE EXCEPTION TYPE zcx_di_class_not_found.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
