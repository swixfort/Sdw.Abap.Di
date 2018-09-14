*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
class ltc_add_should definition deferred.
class ltc_get_should definition deferred.

class zcl_di_context definition
  local friends
    ltc_add_should
    ltc_get_should.