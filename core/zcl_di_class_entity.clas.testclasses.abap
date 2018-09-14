*"* use this source file for your ABAP unit test classes
class ltc_as_instance_should definition for testing final
duration short
risk level harmless.

  private section.
    data _cut type ref to zcl_di_class_entity.

    methods setup.
    methods create_inst__given_not_bound for testing.
    methods do_nothing__given_bound for testing.

endclass.

class ltc_as_instance_should implementation.

  method setup.
  endmethod.

  method create_inst__given_not_bound.

    data registry_entry type ref to zcl_di_context=>ty_class_register_entity.

    " Arrange
    create data registry_entry.
    registry_entry->class_name = `ZCL_DI_TEST_SERVICE_2`.
    create object me->_cut
      exporting
        i_registry_entry = registry_entry.

    " Act
    me->_cut->as_instance( ).

    " Assert
    cl_aunit_assert=>assert_bound(
      act = registry_entry->instance
      msg = `Instance was not created.`
    ).

  endmethod.

  method do_nothing__given_bound.

    data registry_entry type ref to zcl_di_context=>ty_class_register_entity.
    data instance type ref to zcl_di_test_service_2.

    " Arrange
    create data registry_entry.
    registry_entry->class_name = `ZCL_DI_TEST_SERVICE_2`.
    create object registry_entry->instance type zcl_di_test_service_2.
    instance ?= registry_entry->instance.
    create object me->_cut
      exporting
        i_registry_entry = registry_entry.

    " Act
    me->_cut->as_instance( ).

    " Assert
    cl_aunit_assert=>assert_equals(
      act = registry_entry->instance
      exp = instance
      msg = `Instance was created despite initial bound value.`
    ).

  endmethod.

endclass.