"""Defines utility functions."""


alias _Ptr = UnsafePointer


@always_inline("nodebug")
fn adr[T: AnyType, //](ref [_]arg: T) -> _Ptr[T]:
    return _Ptr[T](__mlir_op.`lit.ref.to_pointer`(__get_mvalue_as_litref(arg)))


@always_inline("nodebug")
fn opt2ptr(optional: Optional) -> _Ptr[optional.T]:
    if optional:
        return adr(optional.unsafe_value())
    else:
        return _Ptr[optional.T]()
