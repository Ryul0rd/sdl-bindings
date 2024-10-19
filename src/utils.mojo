"""Defines utility functions."""

from collections import Optional


@always_inline("nodebug")
fn adr[T: AnyType, //](ref [_]arg: T) -> Ptr[T]:
    return Ptr[T](__mlir_op.`lit.ref.to_pointer`(__get_mvalue_as_litref(arg)))


@always_inline("nodebug")
fn opt2ptr(optional: Optional) -> Ptr[optional.T]:
    if optional:
        return adr(optional.unsafe_value())
    else:
        return Ptr[optional.T]()
