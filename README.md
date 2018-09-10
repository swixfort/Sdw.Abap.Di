# Dependency Injection Container
This project targets to create dependency injection in ABAP with using a dependency injection container.

## Contributing
If you're interested in contributing to this project, just create a pull request or create an issue.

### Reporting Bugs
If you find a bug, please create an issue.

### How to use it
The following report shows how to use the container. One creates a variable which references an interface or a class. Then create a container and _register_ __classes__ which you depend on, including the aforementioned variable. After registering all necessary classes, call _get_instance_ of the container to create the objects, including the dependencies. Note that it doesn't matter whether you use upper case.
```ABAP
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
```

This interface is used for the _main_ class.
```ABAP
interface ZIF_DI_TEST_SERVICE_1
  public .

endinterface.
```

The following two interfaces are used for dependencies:
```ABAP
interface ZIF_DI_TEST_DEPENDENCY_1
  public .

endinterface.

interface ZIF_DI_TEST_DEPENDENCY_2
  public .

endinterface.
```

This class is the _main_ class which has two dependencies. Those dependencies are __non__ optional parameters of type _type ref to class_ or _type ref to interface_.
```ABAP
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
```

The following two classes are used as the concrete variants of the dependencies:
```ABAP
CLASS zcl_di_test_dependency_1_a DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  interfaces zif_di_test_dependency_1.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_di_test_dependency_1_a IMPLEMENTATION.
ENDCLASS.


CLASS zcl_di_test_dependency_2 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES zif_di_test_dependency_2.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_di_test_dependency_2 IMPLEMENTATION.
ENDCLASS.
````
