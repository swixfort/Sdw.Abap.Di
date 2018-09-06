*"* use this source file for your ABAP unit test classes
CLASS ltc_create_default_should DEFINITION FOR TESTING
DURATION SHORT
RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    METHODS:
      create_instance_with_defaults FOR TESTING,
      "! not overwrite context, given context is provided
      set_context__given_provided FOR TESTING,
      set_namespace__given_provided FOR TESTING.
ENDCLASS.

CLASS ltc_create_default_should IMPLEMENTATION.

  METHOD create_instance_with_defaults.

    DATA:
      container TYPE REF TO zcl_di_container,
      passed    TYPE abap_bool.

    " Arrange

    " Act
    container = zcl_di_container=>create_default( ).

    " Assert
    passed = cl_aunit_assert=>assert_bound(
        act = container
        msg = `DI container was NOT created` ).

    IF passed = abap_true.
      cl_aunit_assert=>assert_bound(
          act = container->_context
          msg = `DI context was NOT created` ).

      cl_aunit_assert=>assert_equals(
          act = container->_namespace
          exp = 'urn:default'
          msg = `DI namespace is NOT correct` ).
    ENDIF.

  ENDMETHOD.

  METHOD set_context__given_provided.

    DATA:
      container TYPE REF TO zcl_di_container,
      context   TYPE REF TO zcl_di_context.

    " Arrange
    CREATE OBJECT context.

    " Act
    container = zcl_di_container=>create_default( i_context = context ).

    " Assert

    cl_aunit_assert=>assert_equals(
        act = container->_context
        exp = context
        msg = `DI context was NOT set correctly` ).

  ENDMETHOD.

  METHOD set_namespace__given_provided.

    DATA:
      container TYPE REF TO zcl_di_container,
      namespace TYPE string.

    " Arrange
    namespace = `urn:custom_namespace`.

    " Act
    container = zcl_di_container=>create_default( i_namespace = namespace ).

    " Assert

    cl_aunit_assert=>assert_equals(
        act = container->_namespace
        exp = namespace
        msg = `DI namespace was NOT set correctly` ).

  ENDMETHOD.

ENDCLASS.


CLASS ltc_register_should DEFINITION FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    DATA:
      _cut TYPE REF TO zcl_di_container.  "class under test

    METHODS:
      setup,
      raise_error__given_no_class FOR TESTING,
      register_class_to_context FOR TESTING,
      allow_mixed_case FOR TESTING.

ENDCLASS.       "ltc_Container_Should


CLASS ltc_register_should IMPLEMENTATION.

  METHOD setup.

    me->_cut = zcl_di_container=>create_default( ).

  ENDMETHOD.

  METHOD raise_error__given_no_class.

    " Arrange

    " Act
    TRY.
        me->_cut->register( `VBELN` ).

        " Assert
        cl_aunit_assert=>fail( msg = `Registration successful despite no valid class.` ).
      CATCH zcx_di_not_a_class.
    ENDTRY.

  ENDMETHOD.

  METHOD register_class_to_context.

    DATA actual_name TYPE string.
    " Arrange
    " Act
    me->_cut->register( `ZCL_DI_TEST_SERVICE_1` ).
    actual_name = me->_cut->_context->get(
        i_namespace  = me->_cut->_namespace
        i_class_name = `ZCL_DI_TEST_SERVICE_1` ).

    " Assert
    cl_aunit_assert=>assert_equals(
      act = actual_name
      exp = `ZCL_DI_TEST_SERVICE_1`
      msg = `Class was not registered in context` ).


  ENDMETHOD.

  METHOD allow_mixed_case.

    DATA actual_name TYPE string.
    " Arrange
    " Act
    me->_cut->register( `Zcl_DI_teST_SERvICE_1` ).
    actual_name = me->_cut->_context->get(
        i_namespace  = me->_cut->_namespace
        i_class_name = `ZCL_DI_TEST_SERVICE_1` ).

    " Assert
    cl_aunit_assert=>assert_equals(
      act = actual_name
      exp = `ZCL_DI_TEST_SERVICE_1`
      msg = `Class was not registered in context` ).

  ENDMETHOD.

ENDCLASS.       "ltc_Container_Should

CLASS ltc_get_instance_should DEFINITION FOR TESTING
DURATION SHORT
RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    DATA _cut TYPE REF TO zcl_di_container.

    METHODS:
      setup,
      return_instance FOR TESTING,
      return_inst__given_class FOR TESTING,
      ret_instance_with_dependecies FOR TESTING,
      raise_err__given_miss_dpendncy FOR TESTING,
      raise_err__given_already_bound FOR TESTING.

ENDCLASS.

CLASS ltc_get_instance_should IMPLEMENTATION.

  METHOD setup.

    me->_cut = zcl_di_container=>create_default( ).

  ENDMETHOD.

  METHOD return_instance.

    DATA service TYPE REF TO zif_di_test_service_2.

    " Arrange
    me->_cut->register( `ZCL_DI_TEST_SERVICE_2` ).

    " Act
    me->_cut->get_instance( CHANGING c_target = service ).

    " Assert
    cl_aunit_assert=>assert_bound( act = service msg = `Reference was not instantiated.` ).

  ENDMETHOD.

  METHOD ret_instance_with_dependecies.

    DATA service TYPE REF TO zif_di_test_service_1.


    " Arrange
    me->_cut->register( `ZCL_DI_TEST_SERVICE_1` ).
    me->_cut->register( `zcl_di_test_dependency_1_a` ).
    me->_cut->register( `zcl_di_test_dependency_2` ).

    " Act
    me->_cut->get_instance( CHANGING c_target = service ).

    " Assert
    IF service IS NOT BOUND.
      cl_aunit_assert=>fail( msg = `Reference was not instantiated.` ).
    ENDIF.

  ENDMETHOD.

  METHOD raise_err__given_miss_dpendncy.

    DATA service TYPE REF TO zif_di_test_service_1.


    " Arrange
    me->_cut->register( `ZCL_DI_TEST_SERVICE_1` ).
    me->_cut->register( `zcl_di_test_dependency_1_a` ).

    " Act
    me->_cut->get_instance( CHANGING c_target = service ).

    " Assert
    IF service IS NOT BOUND.
      cl_aunit_assert=>fail( msg = `Reference was not instantiated.` ).
    ENDIF.

  ENDMETHOD.

  METHOD raise_err__given_already_bound.

    DATA service TYPE REF TO zif_di_test_service_2.

    " Arrange
    CREATE OBJECT service TYPE zcl_di_test_service_2.
    me->_cut->register( `ZCL_DI_TEST_SERVICE_2` ).

    TRY.
        " Act
        me->_cut->get_instance(
          CHANGING
            c_target = service
        ).

        " Assert
        cl_aunit_assert=>fail( msg = `No exception was thrown despite already bound parameter.`).

      CATCH zcx_di_target_already_bound.
    ENDTRY.

  ENDMETHOD.

  METHOD return_inst__given_class.

    DATA service TYPE REF TO zcl_di_test_service_2.

    " Arrange
    me->_cut->register( `ZCL_DI_TEST_SERVICE_2` ).

    " Act
    me->_cut->get_instance( CHANGING c_target = service ).

    " Assert
    cl_aunit_assert=>assert_bound( act = service msg = `Reference was not instantiated.` ).

  ENDMETHOD.

ENDCLASS.
