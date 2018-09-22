CLASS zcl_di_class_entity DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        i_registry_entry TYPE REF TO zcl_di_context=>ty_class_register_entity.
    METHODS as_instance.
    METHODS class_name
      RETURNING VALUE(r_class_name) TYPE string.
    METHODS instance
      RETURNING VALUE(r_instance) TYPE REF TO object.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA _registry_entry TYPE REF TO zcl_di_context=>ty_class_register_entity.

ENDCLASS.



CLASS zcl_di_class_entity IMPLEMENTATION.

  METHOD constructor.

    me->_registry_entry = i_registry_entry.

  ENDMETHOD.

  METHOD as_instance.

    IF me->_registry_entry->instance IS NOT BOUND.
      TRY.
          CREATE OBJECT me->_registry_entry->instance TYPE (me->_registry_entry->class_name).
        CATCH cx_sy_create_object_error.
      ENDTRY.
    ENDIF.

  ENDMETHOD.

  METHOD class_name.
    r_class_name = me->_registry_entry->class_name.
  ENDMETHOD.

  METHOD instance.

    r_instance = me->_registry_entry->instance.

  ENDMETHOD.

ENDCLASS.
