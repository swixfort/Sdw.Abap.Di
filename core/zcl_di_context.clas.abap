class zcl_di_context definition
  public
  final
  create public .

  public section.
    types:
      begin of ty_class_register_entity,
        time_added type timestampl,
        namespace  type string,
        class_name type string,
        as_singleton type abap_bool,
        instance type ref to object,
      end of ty_class_register_entity,

      ty_class_register type standard table of ty_class_register_entity with key time_added.

    "! <p class="shorttext synchronized" lang="en">Adding classes to the context</p>
    "!
    "! @parameter i_namespace | <p class="shorttext synchronized" lang="en">Namespace to be used</p>
    "! @parameter i_class_name | <p class="shorttext synchronized" lang="en">Class name to be registered</p>
    "! @parameter r_class_entity | < class="shorttext synchronized" lang="en">Class entity object</p>
    methods add
      importing
        i_namespace  type string
        i_class_name type string
        i_instance type ref to object optional
      returning value(r_class_entity) type ref to zcl_di_class_entity.

    "! <p class="shorttext synchronized" lang="en">Getting classes from context based on interface or class.</p>
    "! This method may raise <strong>zcx_di_class_not_found</strong> when there was no class in the context
    "! which <strong>i_class_name</strong> applies to.
    "!
    "! @parameter i_namespace | <p class="shorttext synchronized" lang="en">Namespace to look up.</p>
    "! @parameter i_class_name | <p class="shorttext synchronized" lang="en">Class name or interface</p>
    "! @parameter r_class_name | <p class="shorttext synchronized" lang="en">Found class name</p>
    methods get
      importing
                i_namespace         type string
                i_class_name        type string
      returning value(r_class_entity) type ref to zcl_di_class_entity.

  protected section.
  private section.

    data:
      _class_register type ty_class_register,
      _new_entity     type ty_class_register_entity.

endclass.



class zcl_di_context implementation.

  method add.

    data registry_entry type ref to ty_class_register_entity.

    get time stamp field me->_new_entity-time_added.
    me->_new_entity-namespace = i_namespace.
    me->_new_entity-class_name = i_class_name.
    translate me->_new_entity-class_name to upper case.

    if i_instance is bound
    and me->_new_entity-class_name ne cl_abap_typedescr=>describe_by_object_ref( i_instance )->get_relative_name( ).
      raise exception type zcx_di_mismatching_type.
    endif.

    insert me->_new_entity into me->_class_register index 1 reference into registry_entry.
    create object r_class_entity exporting i_registry_entry = registry_entry.

  endmethod.

  method get.

    data interface_descriptor type ref to cl_abap_intfdescr.
    data registry_entry type ref to ty_class_register_entity.

    loop at me->_class_register
        reference into registry_entry
        where namespace eq i_namespace.

      if registry_entry->class_name eq i_class_name.
        create object r_class_entity exporting i_registry_entry = registry_entry.
        exit.
      endif.

      interface_descriptor ?= cl_abap_intfdescr=>describe_by_name( i_class_name ).

      if interface_descriptor->applies_to_class( registry_entry->class_name ) eq abap_true.
        create object r_class_entity exporting i_registry_entry = registry_entry.
        exit.
      endif.

    endloop.

    if r_class_entity is initial.
      raise exception type zcx_di_class_not_found.
    endif.

  endmethod.

endclass.