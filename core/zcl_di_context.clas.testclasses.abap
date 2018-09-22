*"* use this source file for your ABAP unit test classes
CLASS ltc_add_should DEFINITION FOR TESTING FINAL
DURATION SHORT
RISK LEVEL HARMLESS.

  PUBLIC SECTION.
    CONSTANTS:
      co_default_namespace TYPE string VALUE `urn:default`.

  PRIVATE SECTION.
    DATA _cut TYPE REF TO zcl_di_context.

    METHODS:
      setup,
      add_to_register FOR TESTING,
      add_twice__given_same_call FOR TESTING,
      convert_to_upper_case FOR TESTING.
    METHODS raise_error__given_wrong_type FOR TESTING.
    METHODS add_to_reg__given_correct_type FOR TESTING.
    METHODS return_class_entity_object FOR TESTING.

ENDCLASS.

CLASS ltc_add_should IMPLEMENTATION.

  METHOD setup.

    CREATE OBJECT me->_cut.

  ENDMETHOD.

  METHOD add_to_register.

    DATA expected_entry_count TYPE int4.

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
  ENDMETHOD.
  METHOD add_twice__given_same_call.
    DATA expected_entry_count TYPE int4.
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

  ENDMETHOD.

  METHOD convert_to_upper_case.

    " Arrange
    me->_cut->add(
            i_namespace = co_default_namespace
            i_class_name = `Zcl_Di_Test_Service_1`
        ).

    " Act
    READ TABLE me->_cut->_class_register
        TRANSPORTING NO FIELDS
        WITH KEY class_name = `ZCL_DI_TEST_SERVICE_1`.

    " Assert
    IF sy-subrc IS NOT INITIAL.
      cl_aunit_assert=>fail( `Class name was not translated to upper case.` ).
    ENDIF.

  ENDMETHOD.

  METHOD raise_error__given_wrong_type.

    DATA instance TYPE REF TO zcl_di_test_service_2.


    " Arrange
    CREATE OBJECT instance.

    " Act
    TRY.
        me->_cut->add(
                i_namespace = co_default_namespace
                i_class_name = `Zcl_Di_Test_Service_1`
                i_instance = instance ).

        cl_aunit_assert=>fail( `No exception was raised despite mismatching type.` ).
        " Assert
      CATCH zcx_di_mismatching_type.
    ENDTRY.

  ENDMETHOD.

  METHOD add_to_reg__given_correct_type.

    DATA instance TYPE REF TO zcl_di_test_service_2.


    " Arrange
    CREATE OBJECT instance.

    " Act
    TRY.
        me->_cut->add(
                i_namespace = co_default_namespace
                i_class_name = `Zcl_Di_Test_Service_2`
                i_instance = instance ).

        " Assert
      CATCH zcx_di_mismatching_type.
        cl_aunit_assert=>fail( `No exception was raised despite matching type.` ).
    ENDTRY.

  ENDMETHOD.

  METHOD return_class_entity_object.

    DATA class_entity TYPE REF TO zcl_di_class_entity.

    " Arrange
    " Act
    class_entity = me->_cut->add(
                i_namespace = co_default_namespace
                i_class_name = `Zcl_Di_Test_Service_2` ).

    " Assert
    cl_aunit_assert=>assert_bound(
      EXPORTING
        act = class_entity
        msg = `No class entity was returned.` ).


  ENDMETHOD.

ENDCLASS.

CLASS ltc_get_should DEFINITION FOR TESTING FINAL
DURATION SHORT
RISK LEVEL HARMLESS.

  PUBLIC SECTION.
    CONSTANTS:
      co_default_namespace TYPE string VALUE `urn:default`.

  PRIVATE SECTION.
    DATA _cut TYPE REF TO zcl_di_context.

    METHODS:
      setup,
      ret_latest_cls__given_cls_name FOR TESTING,
      ret_latest_cls__given_if_name FOR TESTING,
      raise_exception__given_no_data FOR TESTING.



ENDCLASS.

CLASS ltc_get_should IMPLEMENTATION.

  METHOD setup.

    CREATE OBJECT me->_cut.

  ENDMETHOD.

  METHOD ret_latest_cls__given_cls_name.

    DATA class_name TYPE string.

    " Arrange
    me->_cut->add(
      EXPORTING
        i_namespace  = co_default_namespace
        i_class_name = `ZCL_DI_TEST_SERVICE_2`
    ).

    me->_cut->add(
      EXPORTING
        i_namespace  = co_default_namespace
        i_class_name = `ZCL_DI_TEST_SERVICE_1`
    ).

    me->_cut->add(
      EXPORTING
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

  ENDMETHOD.

  METHOD ret_latest_cls__given_if_name.

    DATA class_name TYPE string.

    " Arrange
    me->_cut->add(
      EXPORTING
        i_namespace  = co_default_namespace
        i_class_name = `ZCL_DI_TEST_SERVICE_2`
    ).

    me->_cut->add(
      EXPORTING
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

  ENDMETHOD.

  METHOD raise_exception__given_no_data.

    " Arrange

    " Act
    TRY.
        me->_cut->get(
                    i_namespace  = co_default_namespace
                      i_class_name = `ZCL_DI_TEST_SERVICE_1`
                    ).

        " Assert
        cl_aunit_assert=>fail(
          msg = `Something was returned despite no data was provided.`
        ).
      CATCH zcx_di_missing_dependency.
                                                        "#EC NO_HANDLER
    ENDTRY.


  ENDMETHOD.

ENDCLASS.
