*&---------------------------------------------------------------------*
*& Report  z_di_test_report
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

report zzdi_test_report.

data service type ref to zif_di_test_service_1.
data container type ref to zcl_di_container.

container = zcl_di_container=>create_default( ).

container->register( 'ZCL_DI_TEST_SERVICE_1' ).
container->register( 'zcl_di_test_dependency_1_a' )->as_instance( ).
container->register( 'zcl_di_test_dependency_2' ).

container->get_instance(
  changing
    c_target = service
).

service->write( ).