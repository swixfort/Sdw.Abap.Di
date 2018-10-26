CLASS zcl_di_test_service_1 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES zif_di_test_service_1.
    DATA _dependency_3 TYPE REF TO zif_di_test_dependency_2 READ-ONLY.

    METHODS:
      constructor
        IMPORTING
          i_dependency_1 TYPE REF TO zif_di_test_dependency_1
          i_dependency_2 TYPE REF TO zif_di_test_dependency_2
          i_dependency_3 TYPE REF TO zif_di_test_dependency_2 OPTIONAL.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA _dependency_1 TYPE REF TO zif_di_test_dependency_1.
    DATA _dependency_2 TYPE REF TO zif_di_test_dependency_2.
ENDCLASS.



CLASS zcl_di_test_service_1 IMPLEMENTATION.
  METHOD constructor.

    me->_dependency_1 = i_dependency_1.
    me->_dependency_2 = i_dependency_2.
    me->_dependency_3 = i_dependency_3.

  ENDMETHOD.

  METHOD zif_di_test_service_1~write.

    WRITE:/ `zcl_di_test_service_1`.
    IF me->_dependency_1 IS BOUND.
      WRITE:/ `Dependency 1 loaded`.
    ENDIF.

    IF me->_dependency_2 IS BOUND.
      WRITE:/ `Dependency 2 loaded`.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
