*"* use this source file for your ABAP unit test classes
CLASS ltc_as_instance_should DEFINITION FOR TESTING FINAL
DURATION SHORT
RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    DATA _cut TYPE REF TO zcl_di_class_entity.

    METHODS setup.
    METHODS create_inst__given_not_bound FOR TESTING.
    METHODS do_nothing__given_bound FOR TESTING.

ENDCLASS.

CLASS ltc_as_instance_should IMPLEMENTATION.

  METHOD setup.
  ENDMETHOD.

  METHOD create_inst__given_not_bound.

    DATA registry_entry TYPE REF TO zcl_di_context=>ty_class_register_entity.

    " Arrange
    CREATE DATA registry_entry.
    registry_entry->class_name = `ZCL_DI_TEST_SERVICE_2`.
    CREATE OBJECT me->_cut
      EXPORTING
        i_registry_entry = registry_entry.

    " Act
    me->_cut->as_instance( ).

    " Assert
    cl_aunit_assert=>assert_bound(
      act = registry_entry->instance
      msg = `Instance was not created.`
    ).

  ENDMETHOD.

  METHOD do_nothing__given_bound.

    DATA registry_entry TYPE REF TO zcl_di_context=>ty_class_register_entity.
    DATA instance TYPE REF TO zcl_di_test_service_2.

    " Arrange
    CREATE DATA registry_entry.
    registry_entry->class_name = `ZCL_DI_TEST_SERVICE_2`.
    CREATE OBJECT registry_entry->instance TYPE zcl_di_test_service_2.
    instance ?= registry_entry->instance.
    CREATE OBJECT me->_cut
      EXPORTING
        i_registry_entry = registry_entry.

    " Act
    me->_cut->as_instance( ).

    " Assert
    cl_aunit_assert=>assert_equals(
      act = registry_entry->instance
      exp = instance
      msg = `Instance was created despite initial bound value.`
    ).

  ENDMETHOD.

ENDCLASS.
