*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
CLASS ltc_add_should DEFINITION DEFERRED.
CLASS ltc_get_should DEFINITION DEFERRED.

CLASS zcl_di_context DEFINITION
  LOCAL FRIENDS
    ltc_add_should
    ltc_get_should.
