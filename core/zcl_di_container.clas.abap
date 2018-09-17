class zcl_di_container definition
  public
  final
  create private .

  public section.

    constants co_default_namespace  type string value `urn:default`.
    constants co_method_constructor type string value `CONSTRUCTOR`.
    constants co_interface_or_class type string value `ICRicr`.

    "! <p class="shorttext synchronized" lang="en">This will create a new DI-Container</p>
    "! If no <strong>context</strong> will be provided a default one will be created.
    "! owever, it is possible to use one container across multiple containers.
    "! One can differentiate classes with <strong>namespace</strong>s or use the same.<br/>
    "! If no <strong>namespace</strong> will be provided a default one will be used.
    "!
    "! @parameter i_context | <p class="shorttext synchronized" lang="en">Context where the classes to resolve will be stored.</p>
    "! @parameter i_namespace | <p class="shorttext synchronized" lang="en">Namespace to differ between multiple containers and context.</p>
    "! @parameter r_container | <p class="shorttext synchronized" lang="en">A new DI-Container</p>
    class-methods create_default
      importing
                i_context          type ref to zcl_di_context optional
                i_namespace        type string default co_default_namespace
      returning value(r_container) type ref to zcl_di_container.

    "! <p class="shorttext synchronized" lang="en">This method registers a class with the context.</p>
    "! When <strong>i_class_name</strong> is not a class, the exception type <strong>zcx_di_not_a_class</strong> will be raised.
    "!
    "! @parameter i_class_name | <p class="shorttext synchronized" lang="en">Class name to be registered</p>
    methods register
      importing
        i_class_name type string
      returning value(r_class_entity) type ref to zcl_di_class_entity.


    "! <p class="shorttext synchronized" lang="en">Register a class via a given instance</p>
    "!
    "! @parameter i_instance | <p class="shorttext synchronized" lang="en">Instance to be registered.</p>
    methods register_instance
      importing
        i_instance type ref to object
      returning value(r_class_entity) type ref to zcl_di_class_entity.

    "! <p class="shorttext synchronized" lang="en">This method tries to resolve dependencies.</p>
    "! With this method all dependencies will be resolved and <strong>c_target</strong> will be instantiated if it is possible.<br/>
    "!
    "! Following Exceptions can be raised during this method call:
    "! <ul>
    "! <li>zcx_di_target_already_bound : <strong>c_target</strong> is already bound</li>
    "! <li>zcx_di_invalid_type : <strong>c_target</strong> is neither an interface nor a class</li>
    "! <li>zcx_di_class_not_found : Not enough classes were registered using <strong>register</strong></li>
    "! </ul>
    "!
    "! @parameter c_target | <p class="shorttext synchronized" lang="en">Reference which shall be instantiated</p>
    methods get_instance
      changing
        c_target type any.

    "! <p class="shorttext synchronized" lang="en">Forces instantiation of optional dependecies if true.</p>
    "!
    "! @parameters i_value | <p class="shorttext synchronized" lang="en">true = force optional parameters / false = instantiate only non optional parameters</p>
    methods force_optional_dependencies
      importing
        i_value type abap_bool default abap_true.

  protected section.
  private section.

    data _context type ref to zcl_di_context.
    data _namespace type string.
    data _force_optional type abap_bool value abap_false.

    methods:
      constructor
        importing
          i_context   type ref to zcl_di_context
          i_namespace type string.

endclass.



class zcl_di_container implementation.


  method constructor.

    me->_namespace = i_namespace.
    me->_context = i_context.
    if me->_context is not bound.
      create object me->_context.
    endif.

  endmethod.


  method create_default.

    create object r_container
      exporting
        i_context   = i_context
        i_namespace = i_namespace.

  endmethod.


  method get_instance.

    data reference_descriptor type ref to cl_abap_refdescr.
    data class_descriptor type ref to cl_abap_classdescr.
    data new_parameter type abap_parmbind.
    data parameters type abap_parmbind_tab.
    data dependency type ref to data.
    data type_descriptor type ref to cl_abap_typedescr.
    data class_name type string.
    data referenced_type_name type string.
    data parameter_type type string.
    data class_entity type ref to zcl_di_class_entity.

    field-symbols <method_description> type abap_methdescr.
    field-symbols <parameter_description> type abap_parmdescr.
    field-symbols <dependency> type any.


    type_descriptor = cl_abap_typedescr=>describe_by_data( c_target ).
    if type_descriptor->kind ne cl_abap_typedescr=>kind_ref.
      raise exception type zcx_di_invalid_type.
    endif.

    if c_target is bound.
      raise exception type zcx_di_target_already_bound.
    endif.

    reference_descriptor ?= type_descriptor.
    referenced_type_name = reference_descriptor->get_referenced_type( )->get_relative_name( ).

    type_descriptor = type_descriptor->describe_by_name( referenced_type_name ).

    case type_descriptor->kind.
      when cl_abap_typedescr=>kind_class
        or cl_abap_typedescr=>kind_intf.

        class_entity = me->_context->get(
          i_namespace  = me->_namespace
          i_class_name = referenced_type_name ).
        if class_entity->instance( ) is bound.
          c_target ?= class_entity->instance( ).
          return.
        else.
          class_name = class_entity->class_name( ).
        endif.

        class_descriptor ?= cl_abap_typedescr=>describe_by_name( class_name ).
        read table class_descriptor->methods assigning <method_description> with key name = co_method_constructor.
        if sy-subrc is initial.
          loop at <method_description>-parameters assigning <parameter_description>.

            if ( <parameter_description>-is_optional eq abap_false or me->_force_optional eq abap_true )
            and <parameter_description>-type_kind ca co_interface_or_class.

              data parameter_descriptor type ref to cl_abap_typedescr.

              parameter_descriptor = class_descriptor->get_method_parameter_type(
                  p_method_name = co_method_constructor
                  p_parameter_name = <parameter_description>-name ).

              if parameter_descriptor->kind eq cl_abap_typedescr=>kind_ref.
                reference_descriptor ?= parameter_descriptor.
                parameter_type = reference_descriptor->get_referenced_type( )->get_relative_name( ).
              endif.

              new_parameter-kind = 'E'.
              new_parameter-name = <parameter_description>-name.

              create data dependency type ref to (parameter_type).
              assign dependency->* to <dependency>.

              me->get_instance( changing c_target = <dependency> ).

*              DATA(parameter_class_type) = cl_abap_classdescr=>describe_by_object_ref( <dependency> )->get_relative_name( ).
              create data new_parameter-value type ref to object.
              new_parameter-value ?= dependency.
              insert new_parameter into table parameters.

            endif.
          endloop.

        endif.

        if parameters is not initial.
          create object c_target type (class_name)
            parameter-table parameters.
        else.
          create object c_target type (class_name).
        endif.

      when others.
        raise exception type zcx_di_invalid_type.

    endcase.

  endmethod.


  method register.

    if cl_abap_typedescr=>describe_by_name( i_class_name )->kind ne cl_abap_typedescr=>kind_class.
      raise exception type zcx_di_not_a_class.
    endif.

    r_class_entity = me->_context->add( i_class_name = i_class_name i_namespace = me->_namespace ).

  endmethod.


  method register_instance.

    data class_descriptor type ref to cl_abap_classdescr.
    data class_name type string.

    if cl_abap_typedescr=>describe_by_object_ref( i_instance )->kind ne cl_abap_typedescr=>kind_class.
      raise exception type zcx_di_not_a_class.
    endif.

    class_descriptor ?= cl_abap_typedescr=>describe_by_object_ref( i_instance ).
    class_name = class_descriptor->get_relative_name( ).

    r_class_entity = me->_context->add( i_class_name = class_name i_namespace = me->_namespace i_instance = i_instance ).

  endmethod.

  method force_optional_dependencies.

    me->_force_optional = i_value.

  endmethod.

endclass.
