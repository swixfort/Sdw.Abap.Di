CLASS zcl_di_container DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE .

  PUBLIC SECTION.

    CONSTANTS co_default_namespace  TYPE string VALUE `urn:default`.
    CONSTANTS co_method_constructor TYPE string VALUE `CONSTRUCTOR`.
    CONSTANTS co_interface_or_class TYPE string VALUE `*+r`. " TODO: need to be renamed

    "! <p class="shorttext synchronized" lang="en">This will create a new DI-Container</p>
    "! If no <strong>context</strong> will be provided a default one will be created.
    "! owever, it is possible to use one container across multiple containers.
    "! One can differentiate classes with <strong>namespace</strong>s or use the same.<br/>
    "! If no <strong>namespace</strong> will be provided a default one will be used.
    "!
    "! @parameter i_context | <p class="shorttext synchronized" lang="en">Context where the classes to resolve will be stored.</p>
    "! @parameter i_namespace | <p class="shorttext synchronized" lang="en">Namespace to differ between multiple containers and context.</p>
    "! @parameter r_container | <p class="shorttext synchronized" lang="en">A new DI-Container</p>
    CLASS-METHODS create_default
      IMPORTING
                i_context          TYPE REF TO zcl_di_context OPTIONAL
                i_namespace        TYPE string DEFAULT co_default_namespace
      RETURNING VALUE(r_container) TYPE REF TO zcl_di_container.

    "! <p class="shorttext synchronized" lang="en">This method registers a class with the context.</p>
    "! When <strong>i_class_name</strong> is not a class, the exception type <strong>zcx_di_not_a_class</strong> will be raised.
    "!
    "! @parameter i_class_name | <p class="shorttext synchronized" lang="en">Class name to be registered</p>
    METHODS register
      IMPORTING
                i_class_name          TYPE string
      RETURNING VALUE(r_class_entity) TYPE REF TO zcl_di_class_entity.


    "! <p class="shorttext synchronized" lang="en">Register a class via a given instance</p>
    "!
    "! @parameter i_instance | <p class="shorttext synchronized" lang="en">Instance to be registered.</p>
    METHODS register_instance
      IMPORTING
                i_instance            TYPE REF TO object
      RETURNING VALUE(r_class_entity) TYPE REF TO zcl_di_class_entity.

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
    METHODS get_instance
      CHANGING
        c_target TYPE any.

    "! <p class="shorttext synchronized" lang="en">Forces instantiation of optional dependecies if true.</p>
    "!
    "! @parameters i_value | <p class="shorttext synchronized" lang="en">true = force optional parameters / false = instantiate only non optional parameters</p>
    METHODS force_optional_dependencies
      IMPORTING
        i_value TYPE abap_bool DEFAULT abap_true.

  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA _context TYPE REF TO zcl_di_context.
    DATA _namespace TYPE string.
    DATA _force_optional TYPE abap_bool VALUE abap_false.

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
      CREATE OBJECT me->_context.
    ENDIF.

  ENDMETHOD.


  METHOD create_default.

    CREATE OBJECT r_container
      EXPORTING
        i_context   = i_context
        i_namespace = i_namespace.

  ENDMETHOD.


  METHOD get_instance.

    DATA reference_descriptor TYPE REF TO cl_abap_refdescr.
    DATA class_descriptor TYPE REF TO cl_abap_classdescr.
    DATA new_parameter TYPE abap_parmbind.
    DATA parameters TYPE abap_parmbind_tab.
    DATA dependency TYPE REF TO data.
    DATA type_descriptor TYPE REF TO cl_abap_typedescr.
    DATA class_name TYPE string.
    DATA referenced_type_name TYPE string.
    DATA parameter_type TYPE string.
    DATA class_entity TYPE REF TO zcl_di_class_entity.

    FIELD-SYMBOLS <method_description> TYPE abap_methdescr.
    FIELD-SYMBOLS <parameter_description> TYPE abap_parmdescr.
    FIELD-SYMBOLS <dependency> TYPE any.


    type_descriptor = cl_abap_typedescr=>describe_by_data( c_target ).
    IF type_descriptor->kind NE cl_abap_typedescr=>kind_ref.
      RAISE EXCEPTION TYPE zcx_di_invalid_type.
    ENDIF.

    IF c_target IS BOUND.
      RAISE EXCEPTION TYPE zcx_di_target_already_bound.
    ENDIF.

    reference_descriptor ?= type_descriptor.
    referenced_type_name = reference_descriptor->get_referenced_type( )->get_relative_name( ).

    type_descriptor = type_descriptor->describe_by_name( referenced_type_name ).

    CASE type_descriptor->kind.
      WHEN cl_abap_typedescr=>kind_class
        OR cl_abap_typedescr=>kind_intf.

        class_entity = me->_context->get(
          i_namespace  = me->_namespace
          i_class_name = referenced_type_name ).
        IF class_entity->instance( ) IS BOUND.
          c_target ?= class_entity->instance( ).
          RETURN.
        ELSE.
          class_name = class_entity->class_name( ).
        ENDIF.

        class_descriptor ?= cl_abap_typedescr=>describe_by_name( class_name ).
        READ TABLE class_descriptor->methods ASSIGNING <method_description> WITH KEY name = co_method_constructor.
        IF sy-subrc IS INITIAL.
          LOOP AT <method_description>-parameters ASSIGNING <parameter_description>.

            IF ( <parameter_description>-is_optional EQ abap_false OR me->_force_optional EQ abap_true )
            AND <parameter_description>-type_kind CA co_interface_or_class.

              DATA parameter_descriptor TYPE REF TO cl_abap_typedescr.

              parameter_descriptor = class_descriptor->get_method_parameter_type(
                  p_method_name = co_method_constructor
                  p_parameter_name = <parameter_description>-name ).

              IF parameter_descriptor->kind EQ cl_abap_typedescr=>kind_ref.
                reference_descriptor ?= parameter_descriptor.
                parameter_type = reference_descriptor->get_referenced_type( )->get_relative_name( ).
              ENDIF.

              new_parameter-kind = 'E'.
              new_parameter-name = <parameter_description>-name.

              CREATE DATA dependency TYPE REF TO (parameter_type).
              ASSIGN dependency->* TO <dependency>.

              me->get_instance( CHANGING c_target = <dependency> ).

*              DATA(parameter_class_type) = cl_abap_classdescr=>describe_by_object_ref( <dependency> )->get_relative_name( ).
              CREATE DATA new_parameter-value TYPE REF TO object.
              new_parameter-value ?= dependency.
              INSERT new_parameter INTO TABLE parameters.

            ENDIF.
          ENDLOOP.

        ENDIF.

        IF parameters IS NOT INITIAL.
          CREATE OBJECT c_target TYPE (class_name)
            PARAMETER-TABLE parameters.
        ELSE.
          CREATE OBJECT c_target TYPE (class_name).
        ENDIF.

      WHEN OTHERS.
        RAISE EXCEPTION TYPE zcx_di_invalid_type.

    ENDCASE.

  ENDMETHOD.


  METHOD register.

    IF cl_abap_typedescr=>describe_by_name( i_class_name )->kind NE cl_abap_typedescr=>kind_class.
      RAISE EXCEPTION TYPE zcx_di_not_a_class.
    ENDIF.

    r_class_entity = me->_context->add( i_class_name = i_class_name i_namespace = me->_namespace ).

  ENDMETHOD.


  METHOD register_instance.

    DATA class_descriptor TYPE REF TO cl_abap_classdescr.
    DATA class_name TYPE string.

    IF cl_abap_typedescr=>describe_by_object_ref( i_instance )->kind NE cl_abap_typedescr=>kind_class.
      RAISE EXCEPTION TYPE zcx_di_not_a_class.
    ENDIF.

    class_descriptor ?= cl_abap_typedescr=>describe_by_object_ref( i_instance ).
    class_name = class_descriptor->get_relative_name( ).

    r_class_entity = me->_context->add( i_class_name = class_name i_namespace = me->_namespace i_instance = i_instance ).

  ENDMETHOD.

  METHOD force_optional_dependencies.

    me->_force_optional = i_value.

  ENDMETHOD.

ENDCLASS.
