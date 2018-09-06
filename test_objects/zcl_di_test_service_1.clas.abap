CLASS zcl_di_test_service_1 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  interfaces zif_di_test_service_1.

  methods constructor
    IMPORTING
      i_dependency_1 TYPE REF TO zif_di_test_dependency_1
      i_dependency_2 TYPE REF TO zif_di_test_dependency_2.

  PROTECTED SECTION.
  PRIVATE SECTION.
  data _dependency_1 TYPE REF TO zif_di_test_dependency_1.
  data _dependency_2 TYPE REF TO zif_di_test_dependency_2.

ENDCLASS.



CLASS zcl_di_test_service_1 IMPLEMENTATION.
  METHOD constructor.

    me->_dependency_1 = i_dependency_1.
    me->_dependency_2 = i_dependency_2.

  ENDMETHOD.

ENDCLASS.
