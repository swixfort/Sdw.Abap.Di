class zcl_di_class_entity definition
  public
  final
  create public .

  public section.
    methods constructor
      importing
        i_registry_entry type ref to zcl_di_context=>ty_class_register_entity.
    methods as_instance.
    methods class_name
      returning value(r_class_name) type string.
    methods instance
      returning value(r_instance) type ref to object.
  protected section.
  private section.
    data _registry_entry type ref to zcl_di_context=>ty_class_register_entity.

endclass.



class zcl_di_class_entity implementation.

  method constructor.

    me->_registry_entry = i_registry_entry.

  endmethod.

  method as_instance.

    if me->_registry_entry->instance is not bound.
      try.
          create object me->_registry_entry->instance type (me->_registry_entry->class_name).
        catch cx_sy_create_object_error.
      endtry.
    endif.

  endmethod.

  method class_name.
    r_class_name = me->_registry_entry->class_name.
  endmethod.

  method instance.

    r_instance = me->_registry_entry->instance.

  endmethod.

endclass.