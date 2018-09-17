*"* use this source file for your ABAP unit test classes
class ltc_add_should definition for testing final
duration short
risk level harmless.

  public section.
    constants:
      co_default_namespace type string value `urn:default`.

  private section.
    data _cut type ref to zcl_di_context.

    methods:
      setup,
      add_to_register for testing,
      add_twice__given_same_call for testing,
      convert_to_upper_case for testing.
    methods raise_error__given_wrong_type for testing.
    methods add_to_reg__given_correct_type for testing.
    methods return_class_entity_object for testing.

endclass.

class ltc_add_should implementation.

  method setup.

    create object me->_cut.

  endmethod.

  method add_to_register.

    data expected_entry_count type int4.

    " Arrange
    expected_entry_count = lines( me->_cut->_class_register ) + 1.

    " Act
    me->_cut->add(
        i_namespace = co_default_namespace
        i_class_name = `ZCL_DI_TEST_SERVICE_1`
    ).

    " Assert
    cl_aunit_assert=>assert_equals(
        exp = expected_entry_count
        act = lines( me->_cut->_class_register )
        msg = `Register wasn't updated correctly.`
    ).
  endmethod.
  method add_twice__given_same_call.
    data expected_entry_count type int4.
    " Arrange
    expected_entry_count = lines( me->_cut->_class_register ) + 2.
    " Act
    me->_cut->add(
        i_namespace = co_default_namespace
        i_class_name = `ZCL_DI_TEST_SERVICE_1`
    ).
    me->_cut->add(
        i_namespace = co_default_namespace
        i_class_name = `ZCL_DI_TEST_SERVICE_1`
    ).
    " Assert
    cl_aunit_assert=>assert_equals(
        exp = expected_entry_count
        act = lines( me->_cut->_class_register )
        msg = `Register wasn't updated correctly.`
    ).

  endmethod.

  method convert_to_upper_case.

    " Arrange
    me->_cut->add(
            i_namespace = co_default_namespace
            i_class_name = `Zcl_Di_Test_Service_1`
        ).

    " Act
    read table me->_cut->_class_register
        transporting no fields
        with key class_name = `ZCL_DI_TEST_SERVICE_1`.

    " Assert
    if sy-subrc is not initial.
      cl_aunit_assert=>fail( `Class name was not translated to upper case.` ).
    endif.

  endmethod.

  method raise_error__given_wrong_type.

    data instance type ref to zcl_di_test_service_2.


    " Arrange
    create object instance.

    " Act
    try.
        me->_cut->add(
                i_namespace = co_default_namespace
                i_class_name = `Zcl_Di_Test_Service_1`
                i_instance = instance ).

        cl_aunit_assert=>fail( `No exception was raised despite mismatching type.` ).
        " Assert
      catch zcx_di_mismatching_type.
    endtry.

  endmethod.

  method add_to_reg__given_correct_type.

    data instance type ref to zcl_di_test_service_2.


    " Arrange
    create object instance.

    " Act
    try.
        me->_cut->add(
                i_namespace = co_default_namespace
                i_class_name = `Zcl_Di_Test_Service_2`
                i_instance = instance ).

        " Assert
      catch zcx_di_mismatching_type.
        cl_aunit_assert=>fail( `No exception was raised despite matching type.` ).
    endtry.

  endmethod.

  METHOD return_class_entity_object.

    data class_entity type ref to zcl_di_class_entity.

    " Arrange
    " Act
    class_entity = me->_cut->add(
                i_namespace = co_default_namespace
                i_class_name = `Zcl_Di_Test_Service_2` ).

    " Assert
    cl_aunit_assert=>assert_bound(
      exporting
        act = class_entity
        msg = `No class entity was returned.` ).


  ENDMETHOD.

endclass.

class ltc_get_should definition for testing final
duration short
risk level harmless.

  public section.
    constants:
      co_default_namespace type string value `urn:default`.

  private section.
    data _cut type ref to zcl_di_context.

    methods:
      setup,
      ret_latest_cls__given_cls_name for testing,
      ret_latest_cls__given_if_name for testing,
      raise_exception__given_no_data for testing.



endclass.

class ltc_get_should implementation.

  method setup.

    create object me->_cut.

  endmethod.

  method ret_latest_cls__given_cls_name.

    data class_name type string.

    " Arrange
    me->_cut->add(
      exporting
        i_namespace  = co_default_namespace
        i_class_name = `ZCL_DI_TEST_SERVICE_2`
    ).

    me->_cut->add(
      exporting
        i_namespace  = co_default_namespace
        i_class_name = `ZCL_DI_TEST_SERVICE_1`
    ).

    me->_cut->add(
      exporting
        i_namespace  = co_default_namespace
        i_class_name = `ZCL_DI_TEST_SERVICE_2`
    ).

    " Act
    class_name = me->_cut->get(
                   i_namespace  = co_default_namespace
                   i_class_name = `ZCL_DI_TEST_SERVICE_1`
               )->class_name( ).

    " Assert
    cl_aunit_assert=>assert_equals(
      act = class_name
      exp = `ZCL_DI_TEST_SERVICE_1`
      msg = `Wrong class name was returned.`
    ).

  endmethod.

  method ret_latest_cls__given_if_name.

    data class_name type string.

    " Arrange
    me->_cut->add(
      exporting
        i_namespace  = co_default_namespace
        i_class_name = `ZCL_DI_TEST_SERVICE_2`
    ).

    me->_cut->add(
      exporting
        i_namespace  = co_default_namespace
        i_class_name = `ZCL_DI_TEST_SERVICE_1`
    ).

    " Act
    class_name = me->_cut->get(
                   i_namespace  = co_default_namespace
                   i_class_name = `ZIF_DI_TEST_SERVICE_1`
               )->class_name( ).

    " Assert
    cl_aunit_assert=>assert_equals(
      act = class_name
      exp = `ZCL_DI_TEST_SERVICE_1`
      msg = `Wrong class name was returned.`
    ).

  endmethod.

  method raise_exception__given_no_data.

    " Arrange

    " Act
    try.
        me->_cut->get(
                    i_namespace  = co_default_namespace
                      i_class_name = `ZCL_DI_TEST_SERVICE_1`
                    ).

        " Assert
        cl_aunit_assert=>fail(
          msg = `Something was returned despite no data was provided.`
        ).
      catch zcx_di_missing_dependency.
                                                        "#EC NO_HANDLER
    endtry.


  endmethod.

endclass.