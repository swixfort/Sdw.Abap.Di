*"* use this source file for your ABAP unit test classes
class ltc_create_default_should definition for testing final
duration short
risk level harmless.

  private section.

    methods:
      create_instance_with_defaults for testing,
      "! not overwrite context, given context is provided
      set_context__given_provided for testing,
      set_namespace__given_provided for testing.
endclass.

class ltc_create_default_should implementation.

  method create_instance_with_defaults.

    data:
      container type ref to zcl_di_container,
      passed    type abap_bool.

    " Arrange

    " Act
    container = zcl_di_container=>create_default( ).

    " Assert
    passed = cl_aunit_assert=>assert_bound(
        act = container
        msg = `DI container was NOT created` ).

    if passed = abap_true.
      cl_aunit_assert=>assert_bound(
          act = container->_context
          msg = `DI context was NOT created` ).

      cl_aunit_assert=>assert_equals(
          act = container->_namespace
          exp = 'urn:default'
          msg = `DI namespace is NOT correct` ).
    endif.

  endmethod.

  method set_context__given_provided.

    data:
      container type ref to zcl_di_container,
      context   type ref to zcl_di_context.

    " Arrange
    create object context.

    " Act
    container = zcl_di_container=>create_default( i_context = context ).

    " Assert

    cl_aunit_assert=>assert_equals(
        act = container->_context
        exp = context
        msg = `DI context was NOT set correctly` ).

  endmethod.

  method set_namespace__given_provided.

    data:
      container type ref to zcl_di_container,
      namespace type string.

    " Arrange
    namespace = `urn:custom_namespace`.

    " Act
    container = zcl_di_container=>create_default( i_namespace = namespace ).

    " Assert

    cl_aunit_assert=>assert_equals(
        act = container->_namespace
        exp = namespace
        msg = `DI namespace was NOT set correctly` ).

  endmethod.

endclass.


class ltc_register_should definition for testing final
  duration short
  risk level harmless.

  private section.
    data:
      _cut type ref to zcl_di_container.  "class under test

    methods:
      setup,
      raise_error__given_no_class for testing,
      register_class_to_context for testing,
      allow_mixed_case for testing.

endclass.       "ltc_Container_Should


class ltc_register_should implementation.

  method setup.

    me->_cut = zcl_di_container=>create_default( ).

  endmethod.

  method raise_error__given_no_class.

    " Arrange

    " Act
    try.
        me->_cut->register( `VBELN` ).

        " Assert
        cl_aunit_assert=>fail( msg = `Registration successful despite no valid class.` ).
      catch zcx_di_not_a_class.
                                                        "#EC NO_HANDLER
    endtry.

  endmethod.

  method register_class_to_context.

    data actual_name type string.
    " Arrange
    " Act
    me->_cut->register( `ZCL_DI_TEST_SERVICE_1` ).
    actual_name = me->_cut->_context->get(
        i_namespace  = me->_cut->_namespace
        i_class_name = `ZCL_DI_TEST_SERVICE_1` )->class_name( ).

    " Assert
    cl_aunit_assert=>assert_equals(
      act = actual_name
      exp = `ZCL_DI_TEST_SERVICE_1`
      msg = `Class was not registered in context` ).


  endmethod.

  method allow_mixed_case.

    data actual_name type string.
    " Arrange
    " Act
    me->_cut->register( `Zcl_DI_teST_SERvICE_1` ).
    actual_name = me->_cut->_context->get(
        i_namespace  = me->_cut->_namespace
        i_class_name = `ZCL_DI_TEST_SERVICE_1` )->class_name( ).

    " Assert
    cl_aunit_assert=>assert_equals(
      act = actual_name
      exp = `ZCL_DI_TEST_SERVICE_1`
      msg = `Class was not registered in context` ).

  endmethod.

endclass.

class ltc_register_instance_should definition for testing final
duration short
risk level harmless.

  private section.

    data _cut type ref to zcl_di_container.

    methods setup.
    methods register_instance_to_context.
    methods register_class_to_context.

endclass.

class ltc_get_instance_should definition for testing final
duration short
risk level harmless.

  private section.

    data _cut type ref to zcl_di_container.

    methods:
      setup,
      return_instance for testing,
      return_inst__given_class for testing,
      ret_instance_with_dependecies for testing,
      raise_err__given_miss_dpendncy for testing,
      raise_err__given_already_bound for testing,
      raise_exception_given_inv_type for testing.

endclass.

class ltc_get_instance_should implementation.

  method setup.

    me->_cut = zcl_di_container=>create_default( ).

  endmethod.

  method return_instance.

    data service type ref to zif_di_test_service_2.

    " Arrange
    me->_cut->register( `ZCL_DI_TEST_SERVICE_2` ).

    " Act
    me->_cut->get_instance( changing c_target = service ).

    " Assert
    cl_aunit_assert=>assert_bound( act = service msg = `Reference was not instantiated.` ).

  endmethod.

  method ret_instance_with_dependecies.

    data service type ref to zif_di_test_service_1.


    " Arrange
    me->_cut->register( `ZCL_DI_TEST_SERVICE_1` ).
    me->_cut->register( `zcl_di_test_dependency_1_a` ).
    me->_cut->register( `zcl_di_test_dependency_2` ).

    " Act
    me->_cut->get_instance( changing c_target = service ).

    " Assert
    if service is not bound.
      cl_aunit_assert=>fail( msg = `Reference was not instantiated.` ).
    endif.

  endmethod.

  method raise_err__given_miss_dpendncy.

    data service type ref to zif_di_test_service_1.


    " Arrange
    me->_cut->register( `ZCL_DI_TEST_SERVICE_1` ).
    me->_cut->register( `zcl_di_test_dependency_1_a` ).

    " Act
    try.
        me->_cut->get_instance( changing c_target = service ).

        " Assert
        cl_aunit_assert=>fail( msg = `Exception was not triggered despite missing dependency.` ).
      catch zcx_di_class_not_found.
                                                        "#EC NO_HANDLER
    endtry.

  endmethod.

  method raise_err__given_already_bound.

    data service type ref to zif_di_test_service_2.

    " Arrange
    create object service type zcl_di_test_service_2.
    me->_cut->register( `ZCL_DI_TEST_SERVICE_2` ).

    try.
        " Act
        me->_cut->get_instance(
          changing
            c_target = service
        ).

        " Assert
        cl_aunit_assert=>fail( msg = `No exception was thrown despite already bound parameter.`).

      catch zcx_di_target_already_bound.
                                                        "#EC NO_HANDLER
    endtry.

  endmethod.

  method return_inst__given_class.

    data service type ref to zcl_di_test_service_2.

    " Arrange
    me->_cut->register( `ZCL_DI_TEST_SERVICE_2` ).

    " Act
    me->_cut->get_instance( changing c_target = service ).

    " Assert
    cl_aunit_assert=>assert_bound( act = service msg = `Reference was not instantiated.` ).

  endmethod.

  method raise_exception_given_inv_type.

    data service type vbeln.

    " Arrange
    me->_cut->register( `ZCL_DI_TEST_SERVICE_2` ).

    " Act
    try.
        me->_cut->get_instance( changing c_target = service ).

        " Assert
        cl_aunit_assert=>fail( msg = `Exception was not raised despite invalid type.` ).
      catch zcx_di_invalid_type.
                                                        "#EC NO_HANDLER
    endtry.

  endmethod.

endclass.