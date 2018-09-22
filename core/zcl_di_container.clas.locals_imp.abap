*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
CLASS ltc_create_default_should DEFINITION DEFERRED.
CLASS ltc_register_should DEFINITION DEFERRED.
CLASS ltc_register_instance_should DEFINITION DEFERRED.


CLASS zcl_di_container DEFINITION
  LOCAL FRIENDS
    ltc_create_default_should
    ltc_register_should
    ltc_register_instance_should.
