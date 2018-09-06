*&---------------------------------------------------------------------*
*& Report z_di_test_report
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_di_test_report.

DATA service TYPE REF TO zif_di_test_service_1.

DATA(container) = zcl_di_container=>create_default( ).

container->register( 'ZCL_DI_TEST_SERVICE_1' ).
container->register( 'zcl_di_test_dependency_1_a' ).
container->register( 'zcl_di_test_dependency_2' ).

container->get_instance(
  CHANGING
    c_target = service
).
