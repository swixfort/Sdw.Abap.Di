CLASS zcl_di_context DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_class_register_entity,
        time_added   TYPE timestampl,
        namespace    TYPE string,
        class_name   TYPE string,
        as_singleton TYPE abap_bool,
        instance     TYPE REF TO object,
      END OF ty_class_register_entity,

      ty_class_register TYPE STANDARD TABLE OF ty_class_register_entity WITH KEY time_added.

    "! <p class="shorttext synchronized" lang="en">Adding classes to the context</p>
    "!
    "! @parameter i_namespace | <p class="shorttext synchronized" lang="en">Namespace to be used</p>
    "! @parameter i_class_name | <p class="shorttext synchronized" lang="en">Class name to be registered</p>
    "! @parameter r_class_entity | < class="shorttext synchronized" lang="en">Class entity object</p>
    METHODS add
      IMPORTING
                i_namespace           TYPE string
                i_class_name          TYPE string
                i_instance            TYPE REF TO object OPTIONAL
      RETURNING VALUE(r_class_entity) TYPE REF TO zcl_di_class_entity.

    "! <p class="shorttext synchronized" lang="en">Getting classes from context based on interface or class.</p>
    "! This method may raise <strong>zcx_di_class_not_found</strong> when there was no class in the context
    "! which <strong>i_class_name</strong> applies to.
    "!
    "! @parameter i_namespace | <p class="shorttext synchronized" lang="en">Namespace to look up.</p>
    "! @parameter i_class_name | <p class="shorttext synchronized" lang="en">Class name or interface</p>
    "! @parameter r_class_entity | <p class="shorttext synchronized" lang="en">Class entity object</p>
    METHODS get
      IMPORTING
                i_namespace           TYPE string
                i_class_name          TYPE string
      RETURNING VALUE(r_class_entity) TYPE REF TO zcl_di_class_entity.

  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA:
      _class_register TYPE ty_class_register,
      _new_entity     TYPE ty_class_register_entity.

ENDCLASS.



CLASS zcl_di_context IMPLEMENTATION.


  METHOD add.

    DATA registry_entry TYPE REF TO ty_class_register_entity.

    GET TIME STAMP FIELD me->_new_entity-time_added.
    me->_new_entity-namespace = i_namespace.
    me->_new_entity-class_name = i_class_name.
    TRANSLATE me->_new_entity-class_name TO UPPER CASE.
    me->_new_entity-instance = i_instance.

    IF i_instance IS BOUND
    AND me->_new_entity-class_name NE cl_abap_typedescr=>describe_by_object_ref( i_instance )->get_relative_name( ).
      RAISE EXCEPTION TYPE zcx_di_mismatching_type.
    ENDIF.

    INSERT me->_new_entity INTO me->_class_register INDEX 1 REFERENCE INTO registry_entry.
    CREATE OBJECT r_class_entity
      EXPORTING
        i_registry_entry = registry_entry.

  ENDMETHOD.


  METHOD get.

    DATA interface_descriptor TYPE REF TO cl_abap_intfdescr.
    DATA class_descriptor TYPE REF TO cl_abap_classdescr.
    DATA registry_entry TYPE REF TO ty_class_register_entity.

    LOOP AT me->_class_register
        REFERENCE INTO registry_entry
        WHERE namespace EQ i_namespace.

      IF registry_entry->class_name EQ i_class_name.
        CREATE OBJECT r_class_entity
          EXPORTING
            i_registry_entry = registry_entry.
        EXIT.
      ENDIF.

      CASE cl_abap_typedescr=>describe_by_name( i_class_name )->kind.
        WHEN cl_abap_typedescr=>kind_intf.

          interface_descriptor ?= cl_abap_intfdescr=>describe_by_name( i_class_name ).

          IF interface_descriptor->applies_to_class( registry_entry->class_name ) EQ abap_true.
            CREATE OBJECT r_class_entity
              EXPORTING
                i_registry_entry = registry_entry.
            EXIT.
          ENDIF.

        WHEN cl_abap_typedescr=>kind_class.
          class_descriptor ?= cl_abap_classdescr=>describe_by_name( i_class_name ).
          IF class_descriptor->applies_to_class( registry_entry->class_name ) EQ abap_true.
            CREATE OBJECT r_class_entity
              EXPORTING
                i_registry_entry = registry_entry.
            EXIT.
          ENDIF.
      ENDCASE.

    ENDLOOP.

    IF r_class_entity IS INITIAL.
      RAISE EXCEPTION TYPE zcx_di_missing_dependency.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
