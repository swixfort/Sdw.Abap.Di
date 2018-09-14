*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
class ltc_create_default_should definition deferred.
class ltc_register_should definition deferred.


class zcl_di_container definition
  local friends
    ltc_create_default_should
    ltc_register_should
    ltc_register_instance_should.