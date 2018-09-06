*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
class ltc_add_should DEFINITION DEFERRED.
class ltc_get_should DEFINITION DEFERRED.

class zcl_di_context DEFINITION
  local friends
    ltc_add_should
    ltc_get_should.
