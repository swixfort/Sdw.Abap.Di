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

    "! <p class="shorttext synchronized" lang="en">Adding classes to the context</p>
    "!
    "! @parameter i_namespace | <p class="shorttext synchronized" lang="en"></p>
    "! @parameter i_class_name | <p class="shorttext synchronized" lang="en"></p>
    METHODS add
      IMPORTING
        i_namespace  TYPE string
        i_class_name TYPE string.

    "! <p class="shorttext synchronized" lang="en">Getting classes from context based on interface or class.</p>
    "! This method may raise <strong>zcx_di_class_not_found</strong> when there was no class in the context
    "! which <strong>i_class_name</strong> applies to.
    "!
    "! @parameter i_namespace | <p class="shorttext synchronized" lang="en">Namespace to look up.</p>
    "! @parameter i_class_name | <p class="shorttext synchronized" lang="en">Class name or interface</p>
    "! @parameter r_class_name | <p class="shorttext synchronized" lang="en">Found class name</p>
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
