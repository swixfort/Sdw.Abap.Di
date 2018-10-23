*&---------------------------------------------------------------------*
*& Report  z_di_test_report
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT zzdi_test_report.

DATA service TYPE REF TO zif_di_test_service_1.
DATA container TYPE REF TO zcl_di_container.

container = zcl_di_container=>create_default( ).

container->register( 'zcl_di_test_service_1' ).
container->register( 'zcl_di_test_dependency_1_a' )->as_instance( ).
container->register_instance( new zcl_di_test_dependency_2( ) ).

container->get_instance(
  CHANGING
    c_target = service
).

service->write( ).
