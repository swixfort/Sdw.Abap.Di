class zcl_di_test_service_1 definition
  public
  final
  create public .

  public section.
    interfaces zif_di_test_service_1.
    data _dependency_3 type ref to zif_di_test_dependency_2 read-only.

    methods:
      constructor
        importing
          i_dependency_1 type ref to zif_di_test_dependency_1
          i_dependency_2 type ref to zif_di_test_dependency_2
          i_dependency_3 type ref to zif_di_test_dependency_2 optional.
  protected section.
  private section.
    data _dependency_1 type ref to zif_di_test_dependency_1.
    data _dependency_2 type ref to zif_di_test_dependency_2.
endclass.



class zcl_di_test_service_1 implementation.
  method constructor.

    me->_dependency_1 = i_dependency_1.
    me->_dependency_2 = i_dependency_2.
    me->_dependency_3 = i_dependency_3.

  endmethod.

  method zif_di_test_service_1~write.

    write: `zcl_di_test_service_1`.

  endmethod.

endclass.
